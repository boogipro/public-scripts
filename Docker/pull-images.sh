#!/bin/sh

# Get list of all local images (repository:tag)
images=$(docker image ls --format "{{.Repository}}:{{.Tag}}" | grep ":latest$" | grep -v "<none>")

if [ -z "$images" ]; then
    echo "No local images with :latest found."
    exit 0
fi

echo "Updating the following images:"
echo "$images"
echo ""

# Loop through each image and pull it
for img in $images; do
    echo "Pulling $img ..."
    docker pull "$img"
done

echo ""
echo "All existing images updated."