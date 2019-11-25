#!/bin/sh

set -e
set -o pipefail

echo "starting to execute script"

echo 'value of environment variables' $HUGO_VERSION $PUSH_TOKEN $GITHUB_TOKEN $INPUT_REPO-TOKEN 'delimiter' $GITHUB_WORKSPACE 'delimiter' $TARGET_REPO

if [[ -z "$PUSH_TOKEN" ]]; then
        echo "using PUSH_TOKEN env variable."
	exit 1
fi

if [[ -z "$TARGET_REPO" ]]; then
	echo "Set the TARGET_REPO env variable."
	exit 1
fi

if [[ -z "$HUGO_VERSION" ]]; then
	HUGO_VERSION=0.59.1
    echo 'No HUGO_VERSION was set, so defaulting to '$HUGO_VERSION
fi

# echo `ls -al $GITHUB_WORKSPACE`

echo 'Downloading hugo'
curl -sSL https://github.com/spf13/hugo/releases/download/v${HUGO_VERSION}/hugo_${HUGO_VERSION}_Linux-64bit.tar.gz > /tmp/hugo.tar.gz && tar -f /tmp/hugo.tar.gz -xz

echo 'Download complete'
cd website
rm -fr public
echo 'deleted public'

../hugo

git checkout -b temp_branch

echo 'Moving the content over'
cp -r public/* ..

cd -
echo "check files"
echo `ls -al`

if git config --get user.name; then
      git config --global user.name "${GITHUB_ACTOR}"
fi

if ! git config --get user.email; then
      git config --global user.email "${GITHUB_ACTOR}@users.noreply.github.com"
fi

git add *.html *.xml *.png *.svg
git commit -m -a "updates to the website"
# git push orgin temp_branch
# git remote set-url origin git@gitserver.com:pkanwar23/pkanwar.github.io.git
# git add --all && \
# git commit -m "Github Action Build ${GITHUB_SHA} `date +'%Y-%m-%d %H:%M:%S'`" --allow-empty && \
git remote set-url origin https://${GITHUB_ACTOR}:${PUSH_TOKEN}@github.com/pkanwar23/pkanwar23.github.io.git
git push origin temp_branch

echo 'Complete'
