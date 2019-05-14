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
read
#curl -X POST -H "X-TrackerToken: $TRACKER_API_TOKEN" -H "Content-Type: application/json" -d '{"story_ids":[551]}' "https://www.pivotaltracker.com/services/v5/projects/$PROJECT_ID/export"
#PUBLIC_STORIES=$(
PROJECT_ID=$PRIVATE_PROJECT_ID
# curl -X GET -H "X-TrackerToken: $TRACKER_API_TOKEN" "https://www.pivotaltracker.com/services/v5/projects/$PRIVATE_BACKLOG_ID/stories" #|jq '.[] | select ( .labels | .[] | select (.name=="public"))'


head -1 $CSV_IN_FILE > $CSV_OUT_FILE
cat $CSV_IN_FILE | awk -F ',' '{label=$3; if (label=="public") print $0}' >> $CSV_OUT_FILE

#PUBLIC_BACKLOG_URL="https://www.pivotaltracker.com/n/projects/2345570"
public_backlog_url="https://www.pivotaltracker.com/n/projects/$PUBLIC_BACKLOG_ID"
echo "Dear user: please DELETE all stories in $public_backlog_url. [Return] to continue"
read
#VAR=$(curl -X GET -H "X-TrackerToken: $TRACKER_API_TOKEN" "https://www.pivotaltracker.com/services/v5/projects/$PUBLIC_BACKLOG_ID/stories" |jq '.[] | select ( .labels | .[] | select (.name=="public"))')
VAR2=$(curl -X GET -H "X-TrackerToken: $TRACKER_API_TOKEN" "https://www.pivotaltracker.com/services/v5/projects/$PUBLIC_BACKLOG_ID/stories" |jq '.[] | select ( .labels | .[] | select (.name=="public")) |.id')
echo $VAR2
for s in $VAR2; do
  curl -X DELETE -H "X-TrackerToken: $TRACKER_API_TOKEN" "https://www.pivotaltracker.com/services/v5/projects/$PUBLIC_BACKLOG_ID/stories/$s"
done
#curl -X POST -H "X-TrackerToken: $TRACKER_API_TOKEN" "https://www.pivotaltracker.com/services/v5/projects/$PUBLIC_BACKLOG_ID/stories" |jq '.[] | select ( .labels | .[] | select (.name=="public"))'

# DELETE_URL="https://www.pivotaltracker.com/services/v5/commands?envelope=true"
# # TODO idk maybe use a non-internal API endpoint or something
# curl -X POST $DELETE_URL

public_backlog_manual_url="https://www.pivotaltracker.com/projects/$PUBLIC_BACKLOG_ID/import"
echo "Dear user: please upload $(dirname $0)/out.csv to $public_backlog_manual_url"
echo

