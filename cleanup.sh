#!/bin/bash

for im in $(docker image ls | tail -n+2 | egrep 'none|pmm-server-xenial'|awk '{print $3}'|xargs); do docker image rm -f $im ; done

