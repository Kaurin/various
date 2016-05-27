#!/usr/bin/python

import httplib2
import os
# import sys

from apiclient.discovery import build
from apiclient.errors import HttpError
from oauth2client.client import flow_from_clientsecrets
from oauth2client.file import Storage
from oauth2client.tools import argparser, run_flow


# WL is the special "Watch Later" playlist that every YT account has.
# Because "WL" doesn't work in this script, you can try any other normal playlists
# CAREFUL: Your test playlist will get purged of playlist items
playlist_Id="PLkKPejrtZUZB-mWGYSdxmuSZW5Pzy0Wi2"
playlist_WL="WL"
wl_videos=[]

# The CLIENT_SECRETS_FILE variable specifies the name of a file that contains
# the OAuth 2.0 information for this application, including its client_id and
# client_secret. You can acquire an OAuth 2.0 client ID and client secret from
# the Google Developers Console at
# https://console.developers.google.com/.
# Please ensure that you have enabled the YouTube Data API for your project.
# For more information about using OAuth2 to access the YouTube Data API, see:
#   https://developers.google.com/youtube/v3/guides/authentication
# For more information about the client_secrets.json file format, see:
#   https://developers.google.com/api-client-library/python/guide/aaa_client_secrets
CLIENT_SECRETS_FILE = "client_secrets.json"

# This OAuth 2.0 access scope allows for full read/write access to the
# authenticated user's account.
YOUTUBE_READ_WRITE_SCOPE = "https://www.googleapis.com/auth/youtube"
YOUTUBE_API_SERVICE_NAME = "youtube"
YOUTUBE_API_VERSION = "v3"

# This variable defines a message to display if the CLIENT_SECRETS_FILE is
# missing.
MISSING_CLIENT_SECRETS_MESSAGE = """
WARNING: Please configure OAuth 2.0

To make this sample run you will need to populate the client_secrets.json file
found at:
   %s
with information from the APIs Console
https://console.developers.google.com

For more information about the client_secrets.json file format, please visit:
https://developers.google.com/api-client-library/python/guide/aaa_client_secrets
""" % os.path.abspath(os.path.join(os.path.dirname(__file__),
                                   CLIENT_SECRETS_FILE))

# Authorize the request and store authorization credentials.
def get_authenticated_service():
  flow = flow_from_clientsecrets(CLIENT_SECRETS_FILE, scope=YOUTUBE_READ_WRITE_SCOPE,
    message=MISSING_CLIENT_SECRETS_MESSAGE)

  storage = Storage("oauth_storage.json")
  credentials = storage.get()

  if credentials is None or credentials.invalid:
    flags = argparser.parse_args()
    credentials = run_flow(flow, storage, flags)

  return build(YOUTUBE_API_SERVICE_NAME, YOUTUBE_API_VERSION,
    http=credentials.authorize(httplib2.Http()))

## GET VIDO IDs (not playlist IDs) FROM WL
def get_wl_videos(youtube):
    playlistitems_list_request = youtube.playlistItems().list(
        playlistId="WL",
        part="snippet",
        maxResults=50
    )

    while playlistitems_list_request:
        playlistitems_list_response = playlistitems_list_request.execute()

        for playlist_item in playlistitems_list_response["items"]:
          wl_videos.append(playlist_item["snippet"]["resourceId"]["videoId"])

        playlistitems_list_request = youtube.playlistItems().list_next(
          playlistitems_list_request, playlistitems_list_response)

## Put 1 video into temporary playlist:
def insert_playlist_video(youtube, videoId):
    playlistitems_insert_request = youtube.playlistItems().insert(
      part="snippet",
      body=dict(
        snippet=dict(
          playlistId=playlist_Id,
          resourceId=dict(
            kind="youtube#video",
            videoId=videoId
          )
        )
      )
    )
    playlistitems_insert_response = playlistitems_insert_request.execute()






## MAIN
if __name__ == "__main__":
  youtube = get_authenticated_service()
  try:
    get_wl_videos(youtube)
    for videoId in wl_videos:
      print "Adding video: " + videoId
      insert_playlist_video(youtube,videoId)
  except HttpError, e:
    print "An HTTP error %d occurred:\n%s" % (e.resp.status, e.content)
  else:
    print "Done."
