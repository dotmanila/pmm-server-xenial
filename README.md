# PMM2 Server Docker Image Build with Ubuntu 16.04

WARNING: Based on reverse engineering PMM Server 2.0-beta6.

## How To Use

I use an i3.xlarge EC2 instance for this environment, the run the following.

  ./bootstrap-init.sh
  # logoff/logon
  ./bootstrap-prepare.sh

Once everything is setup and initial build of image is running you can use `./buildrun.sh` to recreate the image.
