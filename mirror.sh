#!/bin/bash
set -ex

# environment:
#TRACKER_API_TOKEN

CSV_IN_FILE="in.csv"
CSV_OUT_FILE="out.csv"

PUBLIC_BACKLOG_URL="https://www.pivotaltracker.com/n/projects/2345567"
echo
echo "Dear user, please download csv from $PRIVATE_BACKLOG_URL"
echo

head -1 $CSV_IN_FILE > $CSV_OUT_FILE
cat $CSV_IN_FILE | awk -F ',' '{label=$3; entire_line=$0 if (label=="public") print entire_line}' >> $CSV_OUT_FILE

PUBLIC_BACKLOG_URL="https://www.pivotaltracker.com/n/projects/2345570"
echo
echo "Dear user, please delete all stories in $PUBLIC_BACKLOG_URL"
echo

# DELETE_URL="https://www.pivotaltracker.com/services/v5/commands?envelope=true"
# # TODO idk maybe use a non-internal API endpoint or something
# curl -X POST $DELETE_URL

echo
echo "Dear user, please upload csv to $PUBLIC_BACKLOG_URL"
echo


