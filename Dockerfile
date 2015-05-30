FROM centos

MAINTAINER J.C. Jones "jjones@letsencrypt.org"

# Boulder exposes its web application at port TCP 4000
EXPOSE 4000

# Assume the configuration is in /etc/boulder
ENV BOULDER_CONFIG /etc/boulder/config.json

# Make a Boulder etc dir
RUN mkdir -p /etc/boulder/ && mkdir -p /usr/bin/boulder

VOLUME [ "/etc/boulder" ]

# Copy in the Boulder sources
ADD default-boulder-config.json /etc/boulder/config.json
ADD ./gocode/src/github.com/letsencrypt/boulder/test/test-ca.pem /etc/boulder/
ADD ./gocode/src/github.com/letsencrypt/boulder/test/test-ca.key /etc/boulder/
ADD ./gocode/src/github.com/letsencrypt/boulder/bin/* /usr/bin/

