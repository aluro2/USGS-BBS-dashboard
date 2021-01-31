FROM rocker/shiny-verse:4.0.3

# Apt dependencies
RUN apt-get update && apt-get install -y \
    sudo \
    pandoc \
    pandoc-citeproc \
    libcurl4-gnutls-dev \
    libcairo2-dev \
    libxt-dev \
    libssl-dev \
    libssh2-1-dev 

# Download R packages
RUN apt-get update \
  # Install R packages
  && install2.r --error \
    -r "https://packagemanager.rstudio.com/all/__linux__/focal/latest" \
    # Also install dependencies
    #-d TRUE \
    flexdashboard \
    hrbrthemes \
    data.table \
    dtplyr \
    zip

# Copy shiny app to image
COPY USGS-BBS-dashboard.Rproj /srv/shiny-server/
COPY us_birds_dashboard.Rmd /srv/shiny-server/
COPY US-silhouette-48x48.png /srv/shiny-server/
COPY data /srv/shiny-server/data

# select port
EXPOSE 3838

# allow permission
RUN chmod -R 755 /srv/

# run app
CMD ["R", "-e", "rmarkdown::run('/srv/shiny-server/us_birds_dashboard.Rmd', , shiny_args = list(port = 3838, host = '0.0.0.0'))"]