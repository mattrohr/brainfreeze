<p align="center">
<img width="50%" src="https://i.imgur.com/KBu69Ng.png" alt="Banner">
</p>

<p align="center">
<b>Stabilize image motion</b>
</p>

<p align="center">
<a href="https://github.com/mattrohr/compensation-stage/actions?query=workflow%3Abuild">
<img src="https://github.com/mattrohr/compensation-stage/workflows/build/badge.svg?branch=main" alt="Build Status Badge">
</a>
</p>

## About
Brains are important<sup>1, 2</sup>. When imaging the brain, breathing causes the image to drift in and out of focus. This repository measures this motion and counteracts it in realtime. This change in path-length also means light waves interfere at different depths, resulting in an apparent noise.

## Installation
1. [Install raspberry pi imager](https://www.raspberrypi.org/software/)
2. [image and configure OS](https://learn.adafruit.com/circuitpython-on-raspberrypi-linux/installing-circuitpython-on-raspberry-pi)
3. [wire raspberry pi and IMU sensor](https://learn.adafruit.com/adafruit-9-dof-orientation-imu-fusion-breakout-bno085/python-circuitpython)
4. give python script executable permissions with
```
chmod u+x record_kinematics.py
```

## Usage
1. Download demo data (~100MB) with:
```bash
git lfs pull
```

2. Results should match [`data/final`](./data/final)

3. Record your own data with:
```python
./record_kinematics.py
```

## Notes
- Sources of motion: breathing, heart beat, bulk tissue movement, galvanometer mirror jitter, stage motor jitter, external system, other
- Stage resolution
- Stage speed and Response Time
- IMU resolution: There's an FFT peak at 0 [Hz], which represents the DC bias of the signal. So the slower the breathing, the closer to the peak our signal is, and the harder it will be to seperate it. The longer the experiment, the more bins of data we'll collect, the larger the 0-Hz peak and the breathing rate signal. Qualitatively, a signal around 0.3Hz can be distinguished from 0Hz. So 0.3Hz * 60 seconds = 18 breaths per minute. Anything below that would not easily be detectable. [rats have about about 80 breaths per minute](https://www.google.com/search?q=rat+breaths+per+minute&client=safari&rls=en&ei=1HZuYNzTIYWUtAaip7HwBg&oq=rat+breaths+per+minute&gs_lcp=Cgdnd3Mtd2l6EAMyBwgAEEcQsAMyBwgAEEcQsAMyBwgAEEcQsAMyBwgAEEcQsAMyBwgAEEcQsAMyBwgAEEcQsAMyBwgAEEcQsAMyBwgAEEcQsAMyBwgAELADEENQ2FtYj11g2V1oAnACeACAAfcBiAHSA5IBAzItMpgBAKABAaoBB2d3cy13aXrIAQnAAQE&sclient=gws-wiz&ved=0ahUKEwjcjdPl2O3vAhUFCs0KHaJTDG4Q4dUDCAw&uact=5). This might be lower while anesthetized. 
- IMU accuracy: Measured about 1.69 Hz, but machine was supposedly producing 1.667 Hz. So 1.3% accuracy.
- IMU drift and error: When Sensor is at rest, how much does it read other values than 0?

## Acknowledgements
- [INSERT FIRST LAST](URL) for his [INSERT project name](INSERT PROJECT URL])