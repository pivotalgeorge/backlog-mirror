#!/bin/bash
set -e

# environment:
#TRACKER_API_TOKEN

CSV_IN_FILE="$HOME/Downloads/in.csv"
CSV_OUT_FILE="out.csv"

PUBLIC_BACKLOG_URL="https://www.pivotaltracker.com/n/projects/2345567"
echo
echo "Dear user, please download csv from $PRIVATE_BACKLOG_URL to ~/Downloads/in.csv"
echo
read

head -1 $CSV_IN_FILE > $CSV_OUT_FILE
cat $CSV_IN_FILE | awk -F ',' '{label=$3; if (label=="public") print $0}' >> $CSV_OUT_FILE

PUBLIC_BACKLOG_URL="https://www.pivotaltracker.com/n/projects/2345570"
echo
echo "Dear user, please delete all stories in $PUBLIC_BACKLOG_URL"
echo
read

# DELETE_URL="https://www.pivotaltracker.com/services/v5/commands?envelope=true"
# # TODO idk maybe use a non-internal API endpoint or something
# curl -X POST $DELETE_URL

echo
echo "Dear user, please upload out.csv to $PUBLIC_BACKLOG_URL"
echo


