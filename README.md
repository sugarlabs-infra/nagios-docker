# nagios-docker

This image is build in top of the official ubuntu 14.04 image.

What is difference from other existing images?

- The nagios installation is done through the official ubuntu repo.
- You don't have to link a mail container to have email notifications. This image lets you send email through an external SMTP provider (e.g Gmail).

# Image Configuration

This image have the following environment variables:

* NAGIOSADMIN_USER: the nagios admin user for the basic HTTP auth. Default: nagiosadmin
* NAGIOSADMIN_PASS: the password user for the basic HTTP auth. Default: admin
* SMTP_SERVER: the external smtp server address. Default: smtp.gmail.com
* SMTP_PORT: the external smtp server port. Default: 587
* SMTP_USER: username for smtp auth. Default: user@gmail.com.
* SMTP_PASS: password for smtp auth. Default: password. 

At least you should change the SMTP_USER and SMTP_PASS if you use a gmail smtp server.

# Usage

To build the image use the command below:

    sudo container.yml build .

To run container (in background) use the command below:

    sudo container.yml start -d

Replace 8081 for whatever available port on your docker host. The nagios web UI is available on the following URL:

    http://dockerhost:8081/nagios3

Replace the published container port inside the container.yml configuration file.

# Nagios configuration

You can customize your nagios configuration in the following ways:

1) Access the container and edit the configuration files in the folder /etc/nagios3.

    sudo docker exec -ti nagios bash

2) Edit the configuration files directly on your files located in the volume path. To locate the volume path you should find the "volumes" section inside the low-level information returned for docker inspect command.

    sudo docker inspect nagios

For example:

    "Volumes": {
        "/etc/nagios3": "/var/lib/docker/volumes/925f474f4866d64f3f4cb726f1b87be2e370ed92d4386538a81ce97184b25c80/_data",
        "/usr/lib/nagios/plugins": "/var/lib/docker/volumes/47a0baab8f6ccb563c476198139e04190ea3ebdda1786438c0a1e264edf7c30c/_data"
    },

Comment: You must have root access on your docker host to edit those files.
