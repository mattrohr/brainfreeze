#!/usr/bin/env python
#########################################################################################################
# record_movement.py reads and plots inertial measurement unit data (i.e. Adafruit BNO085 sensor) in format:
#
# |--- [s] --|-------- [m/s^2] ------|-------- [rads/s] --------|--------- [uT] --------|---------------------------------|
# 0           1       2       3       4        5        6        7       8       9       10       11       12       13
# UNIX time   acc_x   acc_y   acc_z   gyro_x   gyro_y   gyro_z   mag_x   mag_y   mag_z   quat_w   quat_x   quat_y   quat_z
###########################################################################################################################

import os
import time
import board
import busio
from adafruit_bno08x import (
    BNO_REPORT_ACCELEROMETER,
    BNO_REPORT_GYROSCOPE,
    BNO_REPORT_MAGNETOMETER,
    BNO_REPORT_ROTATION_VECTOR,
)
from adafruit_bno08x.i2c import BNO08X_I2C
from picamera import PiCamera

external_drive = "/media/pi/Seagate/compensation-stage/data/raw/"
experiment_time = time.strftime("%Y%m%d-%H%M%S")
experiment_type = "_sensor-orbit_100RPM"
path = external_drive + experiment_time + experiment_type
os.mkdir(path)

camera = PiCamera()
camera.rotation = 90

camera.start_preview()
sensor = "camera_output.h264"
filename = os.path.join(path, sensor)

camera.start_recording(filename)

i2c = busio.I2C(board.SCL, board.SDA, frequency=400000)
bno = BNO08X_I2C(i2c)

bno.enable_feature(BNO_REPORT_ACCELEROMETER)
bno.enable_feature(BNO_REPORT_GYROSCOPE)
bno.enable_feature(BNO_REPORT_MAGNETOMETER)
bno.enable_feature(BNO_REPORT_ROTATION_VECTOR)

sensor = "IMU_output.txt"
filename = os.path.join(path, sensor)

while True:

    time.sleep(0.002)
    t = time.time()
    accel_x, accel_y, accel_z = bno.acceleration  # pylint:disable=no-member
    gyro_x, gyro_y, gyro_z = bno.gyro  # pylint:disable=no-member
    mag_x, mag_y, mag_z = bno.magnetic  # pylint:disable=no-member
    quat_i, quat_j, quat_k, quat_w = bno.quaternion  # pylint:disable=no-member

    f = open(filename,'a')
    f.write("%0.6f %0.6f %0.6f %0.6f %0.6f %0.6f %0.6f %0.6f %0.6f %0.6f %0.6f %0.6f %0.6f %0.6f\n" % (t, accel_x, accel_y, accel_z, gyro_x, gyro_y, gyro_z, mag_x, mag_y, mag_z, quat_w, quat_i, quat_j, quat_k))
    #print("%0.6f %0.6f %0.6f %0.6f %0.6f %0.6f %0.6f %0.6f %0.6f %0.6f %0.6f %0.6f %0.6f %0.6f\n" % (t, accel_x, accel_y, accel_z, gyro_x, gyro_y, gyro_z, mag_x, mag_y, mag_z, quat_w, quat_i, quat_j, quat_k))
    #print("%0.6f %0.6f %0.6f %0.6f\n" %(t, mag_x, mag_y, mag_z))
    f.close()
