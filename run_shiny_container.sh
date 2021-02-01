#!/bin/bash


echo "Building docker image"

# Build docker image using docker buildkit ----
DOCKER_BUILDKIT=1 docker build -t usgs-bbs-dashboard:latest .

echo "USGS-BBS dashboard image ready!"

# Run Temporary Docker Container ----
echo "Starting temporary docker container."

docker run --rm -d -p 3838:3838 --name usgs-bbs-dashboard-container-shiny  usgs-bbs-dashboard

echo "Container ready! Go to http://localhost:3838 (on Linux OS) or http://<your ip address here>:3838 (Windows and Mac OS) to enter Shiny session"