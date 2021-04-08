#!/usr/bin/env sh

rsync -avz -e ssh pi@raspberrypi:/media/pi/Seagate/compensation-stage/data/ ./../data/
ffmpeg -framerate 30 -i camera_output.h264 -c copy ../../interim/20210408-151807_sensor-orbit_100RPM/camera_output.mp4  
