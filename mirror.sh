#!/bin/bash
set -e

# environment:
#TRACKER_API_TOKEN
#PRIVATE_BACKLOG_ID
#PUBLIC_BACKLOG_ID

if [ -z $TRACKER_API_TOKEN ]; then
  echo
  echo 'Please `export TRACKER_API_TOKEN=[your api token]`, found in [Username] > Profile.'
  echo
  exit
fi

if [ -z $PRIVATE_BACKLOG_ID ] | [ -z $PUBLIC_BACKLOG_ID ]; then
  echo
  echo '$PRIVATE_BACKLOG_ID and/or $PUBLIC_BACKLOG_ID not set. CONTINUING WITH TEST BACKLOG VALUES'
  PRIVATE_BACKLOG_ID=2345567
  PUBLIC_BACKLOG_ID=2345570
fi

CSV_IN_FILE="$HOME/Downloads/in.csv"
CSV_OUT_FILE="out.csv"

test_endpoint_errors=$(curl -Ss -X GET -H "X-TrackerToken: $TRACKER_API_TOKEN" https://www.pivotaltracker.com/services/v5/me | jq .code)
if [ $test_endpoint_errors != "null" ]; then
  echo $test_endpoint_errors
  echo 'Auth check failed. is $TRACKER_API_TOKEN valid?'
fi

private_backlog_manual_url="https://www.pivotaltracker.com/projects/$PRIVATE_BACKLOG_ID/export"
echo
echo "Dear user: please download csv from $private_backlog_manual_url to ~/Downloads/in.csv. [Return] to continue"
#curl -X POST -H "X-TrackerToken: $TRACKER_API_TOKEN" -H "Content-Type: application/json" -d '{"story_ids":[551]}' "https://www.pivotaltracker.com/services/v5/projects/$PROJECT_ID/export"
#PUBLIC_STORIES=$(
PROJECT_ID=$PRIVATE_PROJECT_ID
VAR0=$(curl -X GET -H "X-TrackerToken: $TRACKER_API_TOKEN" "https://www.pivotaltracker.com/services/v5/projects/$PRIVATE_BACKLOG_ID/stories")
VAR1=$(curl -X GET -H "X-TrackerToken: $TRACKER_API_TOKEN" "https://www.pivotaltracker.com/services/v5/projects/$PRIVATE_BACKLOG_ID/stories" |jq -c '.[] | select ( .labels | .[] | select (.name=="public")) | .name')
echo $VAR0
read


head -1 $CSV_IN_FILE > $CSV_OUT_FILE
cat $CSV_IN_FILE | awk -F ',' '{label=$3; if (label=="public") print $0}' >> $CSV_OUT_FILE

#PUBLIC_BACKLOG_URL="https://www.pivotaltracker.com/n/projects/2345570"
public_backlog_url="https://www.pivotaltracker.com/n/projects/$PUBLIC_BACKLOG_ID"
echo "Dear user: please DELETE all stories in $public_backlog_url. [Return] to continue"
VAR2=$(curl -X GET -H "X-TrackerToken: $TRACKER_API_TOKEN" "https://www.pivotaltracker.com/services/v5/projects/$PUBLIC_BACKLOG_ID/stories" |jq '.[] | select ( .labels | .[] | select (.name=="public")) |.id')
echo $VAR2
for s in $VAR2; do
  curl -X DELETE -H "X-TrackerToken: $TRACKER_API_TOKEN" "https://www.pivotaltracker.com/services/v5/projects/$PUBLIC_BACKLOG_ID/stories/$s"
done
read

# DELETE_URL="https://www.pivotaltracker.com/services/v5/commands?envelope=true"
# # TODO idk maybe use a non-internal API endpoint or something
# curl -X POST $DELETE_URL

public_backlog_manual_url="https://www.pivotaltracker.com/projects/$PUBLIC_BACKLOG_ID/import"
echo "Dear user: please upload $(dirname $0)/out.csv to $public_backlog_manual_url"

# echo $VAR1 | jq -c '.[]' | while read s; do
echo "$VAR1" | while IFS= read -r line ; do
# for s in $VAR1; do
  payload="{\"name\": $line}"
  echo "I don't do sadness"
  echo \'$payload\'
  curl -X POST -H "X-TrackerToken: $TRACKER_API_TOKEN" -H "Content-Type: application/json" -d \'${payload}\' "https://www.pivotaltracker.com/services/v5/projects/$PUBLIC_BACKLOG_ID/stories"
  # curl -X POST -H "X-TrackerToken: $TRACKER_API_TOKEN" -d '{"name": "Buggy chore"}' "https://www.pivotaltracker.com/services/v5/projects/$PUBLIC_BACKLOG_ID/stories"
done

