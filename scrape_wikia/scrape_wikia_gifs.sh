#!/bin/env bash

set -e

#
# Scrape gifs from a wikia page
#

# Base URL (don't include the trailing '/')
BASE_URL=http://metalslug.wikia.com/wiki

# Desired 3-letter extension
EXTENSION=gif

# http://metalslug.wikia.com/wiki/Special:Statistics
CURRENT_DB_DUMP="http://s3.amazonaws.com/wikia_xml_dumps/m/me/metalslug_pages_current.xml.7z"

# Destination dir
PICS_DIR=pics/

#
# Logic block
#

# Fail on missing requirements
REQUIREMENTS="7z parallel wget curl sed grep tr"
for requirement in $REQUIREMENTS
do
   if ! $( which $requirement > /dev/null 2>&1 )
   then
     echo "Missing $requirement. Please install it. Exiting." && exit 50
   fi
done

# Create the pics dir
mkdir -p pics/

# Let's pull the DB dump
wget --no-verbose --output-document=- "$CURRENT_DB_DUMP" > temp.7z
7z -aoa -y x temp.7z
rm temp.7z


# Any file page with a .3-letter extension, then further grep for .gif
cat temp | grep -PZo 'File\:.*?\....' | grep "\.$EXTENSION" | tr ' ' '_' | sort | uniq > gifs.txt

parallel -a gifs.txt echo "$BASE_URL/{}" |
  parallel --retries 3 --eta --verbose wget --quiet "{}" -O "$PICS_DIR/{= s/.*?File:// =}" || true

# Cleanup
rm temp gifs.txt
