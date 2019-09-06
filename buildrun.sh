#!/bin/bash

docker stop pmm-server ; \
docker rm pmm-server ; \
docker build --pull --force-rm --tag pmm-server-xenial:20190902202803 . ; \
docker run -d -p 8888:8888 -p 8843:8843 --name pmm-server --restart always pmm-server-xenial:20190902202803

