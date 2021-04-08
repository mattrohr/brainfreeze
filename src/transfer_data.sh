#!/usr/bin/env sh

rsync -avz -e ssh pi@raspberrypi:/media/pi/Seagate/compensation-stage/data/ ./../data/
ffmpeg -framerate 30 -i video.h264 -c copy ./../data/interim/output.mp4
