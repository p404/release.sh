#!/bin/bash
# Pablo Opazo

PROJECT_NAME=$(basename "$PWD")
DESC_EDITOR="code"

function check_changes () {
    if [[ `git status --porcelain` ]]; then
        echo "Please commit your changes, before creating a release.";
        exit 0;
    fi
}

function latest_tag () {
    LATEST_TAG=$(git describe --tags 2> /dev/null)
    if [[ "$LATEST_TAG" ]]; then
        echo "Latest tag $LATEST_TAG";
    else
        echo "No tags has been found"
    fi
}

function ask_tag () {
    echo -n "Tag name: "; read TAG;
    echo -n "Tag description: "; read TAG_DESC;
}

function create_tag () {
    git tag -a "$TAG" -m "$TAG_DESC"
    git push origin --tag
}

function create_release_description () {
    RELEASE_NAME="$PROJECT_NAME $TAG"
    RELEASE_DESC_FILENAME_PATH="/tmp/$PROJECT_NAME-$TAG.md"
    echo "$RELEASE_NAME" > $RELEASE_DESC_FILENAME_PATH
    nohup code $RELEASE_DESC_FILENAME_PATH &
    wait
}

function create_release () {
    git release create -F $RELEASE_DESC_FILENAME_PATH $TAG
}

BRANCH=$(git rev-parse --abbrev-ref HEAD)
if [[ "$BRANCH" != "master" ]]; then
    echo "Please change to master branch.";
else
    check_changes
    latest_tag
    ask_tag
    create_tag
fi