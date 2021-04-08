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
When imaging the brain, breathing causes the image to drift in and out of focus. This repository measures this motion and counteracts it in realtime.  This change in path-length also means light waves interfere at different depths, resulting in an apparent noise.

## Installation
1. Install raspberry pi imager https://www.raspberrypi.org/software/
2. image and configure OS https://learn.adafruit.com/circuitpython-on-raspberrypi-linux/installing-circuitpython-on-raspberry-pi
3. https://learn.adafruit.com/adafruit-9-dof-orientation-imu-fusion-breakout-bno085?view=all
4. give python script executable permissions with
```
chmod u+x ger_sensor_data.py
```

## Usage
1. record data
```
./record_movement
```

## Notes
- Stage Jitter
- Stage Resolution
- Stage Response Time
- IMU resolution: There's an FFT peak at 0 [Hz], which represents the DC bias of the signal. So the slower the breathing, the closer to the peak our signal is, and the harder it will be to seperate it. The longer the experiment, the more bins of data we'll collect, the larger the 0-Hz peak and the breathing rate signal. Qualitatively, a signal around 0.3Hz can be distinguished from 0Hz. So 0.3Hz * 60 seconds = 18 breaths per minute. Anything below that would not easily be detectable. [rats have about about 80 breaths per minute](https://www.google.com/search?q=rat+breaths+per+minute&client=safari&rls=en&ei=1HZuYNzTIYWUtAaip7HwBg&oq=rat+breaths+per+minute&gs_lcp=Cgdnd3Mtd2l6EAMyBwgAEEcQsAMyBwgAEEcQsAMyBwgAEEcQsAMyBwgAEEcQsAMyBwgAEEcQsAMyBwgAEEcQsAMyBwgAEEcQsAMyBwgAEEcQsAMyBwgAELADEENQ2FtYj11g2V1oAnACeACAAfcBiAHSA5IBAzItMpgBAKABAaoBB2d3cy13aXrIAQnAAQE&sclient=gws-wiz&ved=0ahUKEwjcjdPl2O3vAhUFCs0KHaJTDG4Q4dUDCAw&uact=5). This might be lower while anesthetized. 
- IMU Accuracy: Measured about 1.69 Hz, but machine was supposedly producing 1.667 Hz. So 1.3% accuracy.
- IMU Error: When Sensor is at rest, how much does it read other values than 0?







- Observations about the quality of the project
```
this code can use some refactoring
did a quick implementation to get this to work but ABC would be better.
```

Todo items / issues that you would not want to formally record in an issue tracker

```
should make this method work for x < 0 but that's currently out of scope
```

Design decisions - especially non-trivial ones.
```
Our standard sort function performs a quick sort, but that does not preserve the order of items equal under the sorting condition, which we need here.
The obvious algorithm would be ABC but that fails here because x could be negative so we need the generalized form (Wikipedia link).
```

Problems encountered and how you solved them. A very important one, in my personal opinion: whenever you run into a problem note it in the log.

```
Checked out the code but it gave error XYZ0123, turns out I first had to upgrade component C to version 1.2 or higher.
```

The latter two points are very important. I've often encountered a similar situation or problem - sometimes in a completely different project - and thought "hmm, I remember spending a day on this, but what was the solution again?"

## Acknowledgements
- [INSERT FIRST LAST](INSERT URL) for her [INSERT project name]INSERT (PROJECT URL])
- [INSERT FIRST LAST](URL) for his [INSERT project name](INSERT PROJECT URL])
