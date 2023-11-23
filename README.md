# Tinystatus Container

This is a fork of `tinystatus`. Tinystatus is a service monitoring page generator made with shell script. For information about tinystatus itself, visit [tinystatus repo](https://github.com/bderenzo/tinystatus).

This guide explains how to set up and run a forked `tinystatus` inside a Docker container using the provided Dockerfile. This is my custom version after I forked it and I don't try to keep in sync with the original.


## Prerequisites

Before starting, ensure you have the following installed on your system:
- [Docker](https://docs.docker.com/get-docker/)


## Getting Started

Follow these steps to get your Docker container up and running:

### Step 1: Clone the Repository

Clone the project repository to your local machine using:

```bash
git clone https://github.com/username/tinystatus-container.git
cd tinystatus-container
```

### Step 2: Build the Docker Image
Build your Docker image from the project directory using the Dockerfile:
```bash
docker build --tag tinystatus-image .
```
`tinystatus-image` is a tag. You can change it, but change it in step 3 also.


### Step 3: Run the Docker Container

Run the built image as a container:
```bash
docker run --detach --publish 8081:8081 --name tinystatus-container tinystatus-image

```
`tinystatus-container` is a the name of this instance. We will use the name to refer to it with the remaining commands.


### Step 4: Access the Application
Once the container is up and running, the application should now be accessible at http://localhost:8081. Note that the first report will be generated on startup then on the 5's every hour.

## Other container actions
To stop the container, execute:

```bash
docker stop tinystatus-container
```

After stopping the container, you can remove it with:
```bash
docker rm tinystatus-container
```


## Debugging
By default, error and access logs are written to `/dev/stdout` (see `nginx.conf`)

To jump into the container shell for debugging, use:
```bash
docker exec -it tinystatus-container /bin/bash
```

## Configure
You may customize some things (like the HTML title and header) in `tinystatus-config.cfg` before you build the image.

## Support
To report issues, open an issue in the [GitHub issue tracker](https://github.com/chevybowtie/tinystatus-container/issues) for this project.


## What is it doing
A `cron` task runs the `tinystatus` shell script on a schedule. The status page will be regenerated every 5 minutes by reading your configured services to inspect from `checks.csv` and any recent outages of note from the `incidents.txt` files. 

The `tinystatus` shell script will attempt to reach out to each configured service and match to the expected response. Then it builds a HTML report on the successes or failures.

If you want to change the 5 minute interval
* in the `Dockerfile`, change the `*/5` where the `cron` task is created:
```
RUN (crontab -l ; echo "*/5 * * * * /usr/bin/tinystatus /etc/tinystatus/checks.csv /etc/tinystatus/incidents.txt | tee /var/www/html/index.html") | crontab -
```
See https://crontab.guru/ if you need help creating your `cron` schedule.

There is a footnote you'll want to change in the HTML too (see `tinystatus`).


### Config
The syntax of `checks.csv` file is:
```
Command, Expected Code, Status Text, Host to check
```

Command can be:
* `http` - Check http status
* `ping` - Check ping status 
* `port` - Check open port status

There are also `http4`, `http6`, `ping4`, `ping6`, `port4`, `port6` for IPv4 or IPv6 only check.
