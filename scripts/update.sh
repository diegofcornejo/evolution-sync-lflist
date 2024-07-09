#!/bin/bash

# Configuration variables
REPO_URL="https://github.com/diegofcornejo/evolution-server-lflist.git"
BRANCH="main"
ORIGIN_REPO="fallenstardust/YGOMobile-cn-ko-en"
FILE_PATH="mobile/assets/data/conf/lflist.conf"
COMMIT_MESSAGE="Update banlists with new KS lists"

# Get the SHA of the latest commit that modified the target file from the origin repository
LATEST_COMMIT_SHA=$(curl -s "https://api.github.com/repos/$ORIGIN_REPO/commits?path=$FILE_PATH&per_page=1" | jq -r '.[0].sha')

# Check if the SHA was successfully retrieved
if [ "$LATEST_COMMIT_SHA" == "null" ] || [ -z "$LATEST_COMMIT_SHA" ]; then
  echo "Error: Unable to retrieve the latest commit SHA for $FILE_PATH from $ORIGIN_REPO."
  exit 1
fi

COMMIT_MESSAGE="$COMMIT_MESSAGE - based on $LATEST_COMMIT_SHA"
echo "Commit message: $COMMIT_MESSAGE"

# Ensure the new directory exists and has files
if [ -d "new" ] && [ "$(ls -A new)" ]; then
  # Clone the remote repository
  git clone $REPO_URL repo

  # Copy the new files to the cloned repository
  cp -R new/* repo/

  # Change to the repository directory
  cd repo

  # Set git user configuration
  git config user.name "Evolution Bot"
  git config user.email "bot@evolutionygo.com"

  # Add new files to the repository
  git add .

  # Commit the changes
  git commit -m "$COMMIT_MESSAGE"

  # Pull the latest changes to avoid conflicts
  git pull origin $BRANCH --rebase

  # Push the changes to the remote repository
  git push origin $BRANCH

else
  echo "No files to commit in the 'new' directory."
fi
