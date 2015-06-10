FROM centos

MAINTAINER J.C. Jones "jcjones@letsencrypt.org"

# Boulder exposes its web application at port TCP 4000
EXPOSE 4000

# The OCSP Responder uses TCP 4001, when running
EXPOSE 4001

# Assume the configuration is in /etc/boulder
ENV BOULDER_CONFIG /etc/boulder/config.json

# Make a Boulder /etc/ dir, and a /var/ dir for the DB.
RUN mkdir -p /etc/boulder/ && mkdir -p /var/boulder/

VOLUME [ "/etc/boulder", "/var/boulder" ]

# Upgrade and install libtool-ltdl for PKCS11 support
RUN yum update -y && yum install -y libtool-ltdl

# Copy in the Boulder sources
ADD etc/default-boulder-config.json /etc/boulder/config.json
ADD etc/test-ca.pem /etc/boulder/
ADD etc/test-ca.key /etc/boulder/
ADD bin/* /usr/bin/

# Default to monolithic Boulder
CMD /usr/bin/boulder
