#!/bin/bash
# Run end 2 end tests without polluting this repository
TRAVIS_PULL_REQUEST=4
TRAVIS_BRANCH="travis"
TRAVIS_E2E_TOKEN="jZ_gXkKfYtRmbExdfzqE7A"

if [ "$TRAVIS_PULL_REQUEST" == "false" ]; then
  echo "Not a pull request, skipping e2e tests"
  exit 0
fi

ENV="TEST_REPO=\\\"contentful/starter-gatsby-blog\\\" TEST_BRANCH="$TRAVIS_BRANCH" TEST_CMD_BUILD=\\\"sh ../tests/starter-gatsby-blog/build-repo.sh\\\" CYPRESS_BASE_URL=\\\"http://localhost:9000\\\" CYPRESS_INTEGRATION_FOLDER=\\\"tests/starter-gatsby-blog/integration\\\""

BODY="{
  \"request\": {
    \"message\": \"Starter Gatsby Blog Triggered Request\",
    \"branch\":\"travis\",
    \"config\": {\"env\": \"$ENV\"}
  }
}"

# api-coverage
REQUEST="$(curl -s -X POST \
	-d "$BODY" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json"   \
  -H "Travis-API-Version: 3"   \
  -H "Authorization: token $TRAVIS_E2E_TOKEN" \
  'https://api.travis-ci.org/repo/20489838/requests')"

REQUEST_ID="$(echo $REQUEST | jq '.request.id')"

if [ "$REQUEST_ID" == "null" ]; then
  echo "Unable to request CI build:"
  echo $REQUEST | jq
  exit 1
fi

echo "Successfully started request $REQUEST_ID"

# @todo post link to build

STATUS=0
while [ $STATUS -eq "0" ]
do
  REQUEST_RESPONSE="$(curl -s \
  -H "Content-Type: application/json" \
  -H "Accept: application/json"   \
  -H "Travis-API-Version: 3"   \
  -H "Authorization: token $TRAVIS_E2E_TOKEN" \
  'https://api.travis-ci.org/repo/20489838/request/$REQUEST_ID')"
  TYPE="$(echo $REQUEST_RESPONSE | jq '.["@type"]')"
  echo "$(date +"%T") Current request status: $TYPE"
  echo $REQUEST_RESPONSE | jq
  sleep 5
done

# @todo exit depending on the CI outcome
