#!/bin/bash
# Run end 2 end tests without polluting this repository
echo $TRAVIS_PULL_REQUEST
if [ "$TRAVIS_PULL_REQUEST" == "false" ]; then
  echo "Not a pull request, skipping e2e tests"
  exit 0
fi

ENV='TEST_REPO="contentful/starter-gatsby-blog" TEST_BRANCH="'$TRAVIS_BRANCH'" TEST_CMD_BUILD="sh ../tests/starter-gatsby-blog/build-repo.sh" CYPRESS_BASE_URL="http://localhost:9000" CYPRESS_INTEGRATION_FOLDER="tests/starter-gatsby-blog/integration"'

BODY="{
  \"request\": {
    \"message\": \"$TRAVIS_REPO_SLUG Triggered Request\",
    \"branch\":\"travis_experiments\",
    \"config\": {\"env\": $ENV}
  }
}"

# api-coverage
curl -s -X POST \
	-d "$BODY" \
    -H "Content-Type: application/json" \
    -H "Accept: application/json"   \
    -H "Travis-API-Version: 3"   \
    -H "Authorization: token $TRAVIS_E2E_TOKEN" \
    'https://api.travis-ci.com/repo/20307164/requests'
