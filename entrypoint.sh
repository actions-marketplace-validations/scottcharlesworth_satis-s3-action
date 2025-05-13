#!/bin/bash
set -e

# Set environment variables
export SATIS="/root/satis/bin/satis"
export OUT_PATH="~/compiled"
export CONFIG_PATH="${GITHUB_WORKSPACE}/${INPUT_CONFIG_FILE}"

# If AUTH_GITHUB is set then add to composer config
if [ ! -z "$AUTH_GITHUB" ]; then
	composer config --global github-oauth.github.com "$AUTH_GITHUB"
	echo ""
fi

# If AUTH_BITBUCKET_KEY and AUTH_BITBUCKET_SECRET is set then add to composer config
if [ ! -z "$AUTH_BITBUCKET_KEY" ] && [ ! -z "$AUTH_BITBUCKET_SECRET" ]; then
	composer config --global bitbucket-oauth.bitbucket.org "$AUTH_BITBUCKET_KEY" "$AUTH_BITBUCKET_SECRET"
	echo ""
fi

# Trust the workspace folder, no matter its ownership
git config --global --add safe.directory "${GITHUB_WORKSPACE:-$(pwd)}"

echo "Create OUT_PATH directory ..."
mkdir -p $OUT_PATH
echo ""

# Download the existing repo from S3
echo "Downloading existing repo from AWS S3 ..."
aws s3 sync s3://$INPUT_S3_BUCKET/$INPUT_S3_PATH $OUT_PATH
echo ""

if [ "$INPUT_DEBUG" = true ] ; then
  # List contents of OUT_PATH
  echo "Listing contents of OUT_PATH ..."
  ls -la $OUT_PATH
  echo ""

  # List contents of home directory
  echo "Listing contents of home dir ..."
  ls -la ~/
  echo ""

  # List contents of /root/satis/
  echo "Listing contents of Satis directory ..."
  ls -la /root/satis/
  echo ""

  # List contents of GitHub Workspace
  echo "Listing contents of GitHub Workspace ..."
  ls -la $GITHUB_WORKSPACE
  echo ""
fi

# Rebuild the repo
echo "Run Composer Satis ..."
php $SATIS build --verbose $CONFIG_PATH $OUT_PATH
echo ""

if [ "$INPUT_PURGE" = true ] ; then
  # Purge unreferenced archives
  echo "Purge unreferenced archives ..."
  php $SATIS purge $CONFIG_PATH $OUT_PATH
  echo ""
fi

# Push files back to S3
echo "Push files back to AWS S3 bucket ..."
aws s3 sync --delete $OUT_PATH s3://$INPUT_S3_BUCKET/$INPUT_S3_PATH
echo ""

if [ "$INPUT_DEBUG" = true ] ; then
  # List contents of OUT_PATH
  echo "Listing contents of OUT_PATH ..."
  ls -la $OUT_PATH
fi
