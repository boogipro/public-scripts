#!/bin/sh

# Use -r to ensure backslashes aren't misinterpreted
images=$(docker image ls --format "{{.Repository}}:{{.Tag}}" | grep ":latest$")

if [ -z "$images" ]; then
    echo "No local images with :latest found."
    exit 0
fi

echo "Updating the following images:"
echo "$images"
echo ""

# Using a while loop is safer for command output
echo "$images" | while read -r img; do
    echo "Pulling $img ..."
    docker pull "$img"
done

echo ""
echo "All existing images updated."