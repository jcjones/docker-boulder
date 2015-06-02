FROM centos

MAINTAINER J.C. Jones "jcjones@letsencrypt.org"

# Boulder exposes its web application at port TCP 4000
EXPOSE 4000

# Assume the configuration is in /etc/boulder
ENV BOULDER_CONFIG /etc/boulder/config.json

# Make a Boulder etc dir
RUN mkdir -p /etc/boulder/ && mkdir -p /usr/bin/boulder

VOLUME [ "/etc/boulder" ]

# Copy in the Boulder sources
ADD etc/default-boulder-config.json /etc/boulder/config.json
ADD etc/test-ca.pem /etc/boulder/
ADD etc/test-ca.key /etc/boulder/
ADD bin/* /usr/bin/

