#!/bin/bash
# Source https://github.com/snod/slack-now-playing-spotify
#
# Simple bash script to post the currently played song of your spotify app
# to a slack channel

# Configuration

CONFIGFILE="slackspotify.cfg"

### End of Config

# check if the config file exists

if [[ ! -f "$CONFIGFILE" ]]; then
        echo "config file $CONFIGFILE could not be found"
        exit 1
fi

# load the config

. "$CONFIGFILE"

# gather all data from spotify
ARTIST=$(osascript -e 'tell application "Spotify" to artist of current track')
SONGNAME=$(osascript -e 'tell application "Spotify" to name of current track')
SONGURL=$(osascript -e 'tell application "Spotify" to spotify url of current track')
ARTWORKURL=$(osascript -e 'tell application "Spotify" to artwork url of current track')
FALLBACK="np: $ARTIST - $SONGNAME"

# convert Spotify app link to https link
SONGURL=${SONGURL/spotify:track:/https:\/\/open.spotify.com\/track\/}

# create a JSON
read -d '' JSON <<"EOF"
{
    "channel": "CHANNEL",
    "as_user": true,
    "attachments": [
        {
            "fallback": "FALLBACK",
            "color": "COLOR",
            "author_name": "ARTIST",
            "title": "SONGNAME",
            "title_link": "SONGURL",
            "thumb_url": "ARTWORKURL",
            "footer": "now playing",
            "footer_icon": "FOOTER_ICON",
        }
    ]
}
EOF

# replace the placeholders in the JSON variable
JSON=${JSON/CHANNEL/$CHANNEL}
JSON=${JSON/FALLBACK/$FALLBACK}
JSON=${JSON/COLOR/$COLOR}
JSON=${JSON/ARTIST/$ARTIST}
JSON=${JSON/SONGNAME/$SONGNAME}
JSON=${JSON/SONGURL/$SONGURL}
JSON=${JSON/ARTWORKURL/$ARTWORKURL}
JSON=${JSON/FOOTER_ICON/$FOOTER_ICON}

# post the stuff to slack
curl  -H "Content-Type: application/json" -H "Authorization: Bearer $TOKEN" -X POST -d "$JSON" "https://slack.com/api/chat.postMessage" > /dev/null
