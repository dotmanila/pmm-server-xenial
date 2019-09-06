#!/bin/bash

docker run -d -p 8888:8888 -p 8843:8843 --name pmm-server --restart always pmm-server-xenial:20190902202803

