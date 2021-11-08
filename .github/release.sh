#!/bin/bash

set -e

# Check if we're on main first.
git_branch=$(git rev-parse --abbrev-ref HEAD)
if [ "$git_branch" == "main" ]; then
    echo "Cannot release from 'main' branch. Please checkout to a release branch!"
    echo "Example: git checkout -b v1-release"
    exit 1
fi

# Set up release tag.
read -rp "Enter tag (example: v1.0.9) " git_tag
git push origin ":refs/tags/$git_tag"
git tag -fa "$git_tag" -m "Release $git_tag"
git push -u origin "$git_tag"
git push --tags

echo "Done!"
git_repo="$(git config --get remote.origin.url | cut -d ':' -f2 | sed "s/.git//")"
echo "You can now use this action with $git_repo@$git_tag"
