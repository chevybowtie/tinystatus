# Use Ubuntu minimal as the base image
FROM ubuntu:latest

# Define a variable for the tinystatus temporary directory
ARG TINYSTATUS_DIR=/tmp/tinystatus

# Install necessary tools
RUN apt-get update && apt-get install -y nginx git cron dos2unix curl netcat iputils-ping \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Clone the tinystatus-systemd repository
# RUN git clone https://github.com/chevybowtie/tinystatus-systemd-in-container.git ${TINYSTATUS_DIR}

# running locally
COPY ./ ${TINYSTATUS_DIR}


# ███████╗ ██████╗██████╗ ██╗██████╗ ████████╗███████╗
# ██╔════╝██╔════╝██╔══██╗██║██╔══██╗╚══██╔══╝██╔════╝
# ███████╗██║     ██████╔╝██║██████╔╝   ██║   ███████╗
# ╚════██║██║     ██╔══██╗██║██╔═══╝    ██║   ╚════██║
# ███████║╚██████╗██║  ██║██║██║        ██║   ███████║
# ╚══════╝ ╚═════╝╚═╝  ╚═╝╚═╝╚═╝        ╚═╝   ╚══════╝

# Copy the tinystatus scripts to /usr/bin 
RUN cp ${TINYSTATUS_DIR}/app/tinystatus /usr/bin/ && \
    cp ${TINYSTATUS_DIR}/app/tinystatus-config.cfg /usr/bin/ 

# Copy NGINX main configuration file
RUN cp ${TINYSTATUS_DIR}/app/nginx.conf /etc/nginx/nginx.conf

# Copy default server configuration
RUN cp ${TINYSTATUS_DIR}/app/default.conf /etc/nginx/conf.d/default.conf

# Create the /etc/tinystatus directory 
#
# (this is where the scheduled task expects the checks.csv
# and incidents.txt files to be)
#
RUN mkdir /etc/tinystatus

# Convert and copy checks.csv and incidents.txt
RUN dos2unix ${TINYSTATUS_DIR}/app/checks.csv && cp ${TINYSTATUS_DIR}/app/checks.csv /etc/tinystatus/
RUN dos2unix ${TINYSTATUS_DIR}/app/incidents.txt && cp ${TINYSTATUS_DIR}/app/incidents.txt /etc/tinystatus/

# Set the working directory
WORKDIR /var/www/html

# ██╗  ██╗████████╗███╗   ███╗██╗     
# ██║  ██║╚══██╔══╝████╗ ████║██║     
# ███████║   ██║   ██╔████╔██║██║     
# ██╔══██║   ██║   ██║╚██╔╝██║██║     
# ██║  ██║   ██║   ██║ ╚═╝ ██║███████╗
# ╚═╝  ╚═╝   ╚═╝   ╚═╝     ╚═╝╚══════╝

# Copy the tinystatus web content (HTML, CSS, and potentially other files) to the Nginx directory
RUN cp -r ${TINYSTATUS_DIR}/public_html/*.html ${TINYSTATUS_DIR}/public_html/*.png ${TINYSTATUS_DIR}/public_html/*.css /var/www/html/

# Setup the cron job
RUN chmod +x /usr/bin/tinystatus
RUN (crontab -l ; echo "*/5 * * * * /usr/bin/tinystatus /etc/tinystatus/checks.csv /etc/tinystatus/incidents.txt | tee /var/www/html/index.html") | crontab -

# Clean up the temporary directory
RUN rm -rf ${TINYSTATUS_DIR}

# ██████╗ ███████╗ █████╗ ██████╗ ██╗   ██╗
# ██╔══██╗██╔════╝██╔══██╗██╔══██╗╚██╗ ██╔╝
# ██████╔╝█████╗  ███████║██║  ██║ ╚████╔╝ 
# ██╔══██╗██╔══╝  ██╔══██║██║  ██║  ╚██╔╝  
# ██║  ██║███████╗██║  ██║██████╔╝   ██║   
# ╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝╚═════╝    ╚═╝   

# Expose port 8081
EXPOSE 8081

# Start Nginx and cron
CMD /usr/bin/tinystatus /etc/tinystatus/checks.csv /etc/tinystatus/incidents.txt | tee /var/www/html/index.html && \
    service cron start && \
    nginx -g 'daemon off;' 