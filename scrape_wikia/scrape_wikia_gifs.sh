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
cat temp | grep -PZo 'File\:.*?\....' | grep "\.$EXTENSION" | sort | uniq > gifs.txt

# Loop over the resulting file, line by line (Easiest solution I found due to spaces in filenames)
while read line
do
  webfile="$(echo $line | tr ' ' '_')" # webfile has _ instead of spaces
  plainfile="$(echo $webfile | sed 's/^File://g')" # This is the file's basename
  # URLs we are interested in have the 'og:image' tag
  urls=$(curl -s  $BASE_URL/$webfile | grep 'og\:image' | grep -oP '"https://.*?"' | tr -d '"')
  num=1 # Control in case we have more than 1 'og:image'
  for url in $urls
  do
    (( $num > 1 )) && numfile=$num
    wget --no-verbose "$url" -O $PICS_DIR/$plainfile$numfile
    (( num++ ))
  done
done < gifs.txt

# Cleanup
rm temp gifs.txt
