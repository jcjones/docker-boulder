# Docker container for [Boulder](https://github.com/letsencrypt/boulder)

This container runs a simple copy of Boulder. It has several configuration points:
Hosts:
  * amqp
  * mail

Mountpoints
  * /etc/boulder (keys and config)
  * /var/boulder (database)

Ports:
  * 4000 (Boulder Web Front End)
  * 4001 (Boulder OCSP Responder, if you choose to run it)

If you want to change the configuration, or use your own keys, you need to bind a local path on top of `/etc/boulder` inside the container.

All of the Boulder executables are in /usr/bin/, including but not limited to:
  * boulder (Monolithic mode w/o AMQP)
  * ocsp-updater
  * ocsp-responder
  * admin-revoker
  * activity-monitor
  * boulder-wfe
  * boulder-va
  * boulder-ra
  * boulder-sa
  * boulder-ca

Getting started quickly can be done as simply as:

To use your own configuration, you can do something like:

``` shell
> mkdir .boulder-config
> cd .boulder-config
> wget https://raw.githubusercontent.com/letsencrypt/boulder/master/test/test-ca.pem
> wget https://raw.githubusercontent.com/letsencrypt/boulder/master/test/test-ca.key
> wget https://raw.githubusercontent.com/letsencrypt/boulder/master/test/boulder-config.json
> mv boulder-config.json config.json
> (( edit config.json -- you will probably need to specify a UDP syslog source ))
> cd ..
> docker run --name=boulder -v $(pwd)/.boulder-config:/etc/boulder:ro -p 4000:4000 quay.io/letsencrypt/boulder:latest boulder
```

