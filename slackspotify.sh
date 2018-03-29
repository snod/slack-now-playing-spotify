#!/bin/bash
# Source https://github.com/snod/slack-now-playing-spotify
#
# Simple bash script to post the currently played song of your spotify app
# to a slack channel

# Configuration

# get your token from here https://api.slack.com/custom-integrations/legacy-tokens
TOKEN="xoxp-yadayada"

# the channel to post the message to
CHANNEL="#soon-to-be-annoyed-people"

# the color of the message's border
COLOR="2eb886"

### End of Config

# gather all data from spotify
ARTIST=$(osascript -e 'tell application "Spotify" to artist of current track')
SONGNAME=$(osascript -e 'tell application "Spotify" to name of current track')
SONGURL=$(osascript -e 'tell application "Spotify" to spotify url of current track')
ARTWORKURL=$(osascript -e 'tell application "Spotify" to artwork url of current track')

# convert Spotify app link to https link
SONGURL=${SONGURL/spotify:track:/https:\/\/open.spotify.com\/track\/}

# create a JSON
read -d '' JSON <<"EOF"
{
    "channel": "CHANNEL",
    "as_user": true,
    "attachments": [
        {
            "fallback": "Just a simple np notification",
            "color": "COLOR",
            "author_name": "ARTIST",
            "title": "SONGNAME",
            "title_link": "SONGURL",
            "thumb_url": "ARTWORKURL",
            "footer": "now playing",
            "footer_icon": "http://somehost/spotify_icon.png",
        }
    ]
}
EOF

# replace the placeholders in the JSON variable
JSON=${JSON/CHANNEL/$CHANNEL}
JSON=${JSON/COLOR/$COLOR}
JSON=${JSON/ARTIST/$ARTIST}
JSON=${JSON/SONGNAME/$SONGNAME}
JSON=${JSON/SONGURL/$SONGURL}
JSON=${JSON/ARTWORKURL/$ARTWORKURL}

# post the stuff to slack
curl  -H "Content-Type: application/json" -H "Authorization: Bearer $TOKEN" -X POST -d "$JSON" "https://slack.com/api/chat.postMessage" > /dev/null
