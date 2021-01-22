# Run Docker Container ----
echo "Starting docker container."

docker run -d -p 8787:8787 -v $(pwd):/home/rstudio -e DISABLE_AUTH=true --name usgs-bbs-dashboard-container-rstudio  rocker/tidyverse:4.0.3

echo "Container ready! Go to http://localhost:8787(on Linux OS) or http://<your ip address here>:8787(Windows and Mac OS) to enter RStudio session"