<p align="center">
<img width="50%" src="https://i.imgur.com/8rafq45.png" alt="Banner">
</p>

<p align="center">
<b>Stabilize brain imaging motion</b>
</p>

<p align="center">
<a href="https://github.com/mattrohr/compensation-stage/actions?query=workflow%3Abuild">
<img src="https://github.com/mattrohr/compensation-stage/workflows/build/badge.svg?branch=main" alt="Build Status Badge">
</a>
</p>

## About
When imaging the brain, breathing causes image shift <sup>[1](https://pubmed.ncbi.nlm.nih.gov/22108978/)</sup> and may cause the image to drift in and out of focus. This repository includes hardware and software to counteract this motion in realtime.

## Installation
1. Purchase [bill of materials](./docs/bom.md)
2. [Image and configure operating system on acquisition computer](https://learn.adafruit.com/circuitpython-on-raspberrypi-linux/installing-circuitpython-on-raspberry-pi)
3. [Connect acquisition computer and inertial measurement unit](https://learn.adafruit.com/adafruit-9-dof-orientation-imu-fusion-breakout-bno085/python-circuitpython). It does not matter which female connector you choose.
4. Copy this repository on both host computer and acquisition computer:
```bash
git clone https://github.com/mattrohr/compensation-stage.git
```
5. Grant python script executable permissions:
```
chmod u+x ./src/record_kinematics.py
```
6. Sterilize components with alcohol wipes to minimize infection risk.

7. Attach IMU sensor 3M double-sided adhesive square. The sensor has an orientation compass on the bottom right. Position the compass so it faces up, X points to the right ear, Y points to the snout, and the sensor is close to the imaging area.
<img align="right" width="50%" crop src="https://i.imgur.com/xJVPfHU.jpg" alt="IMU sensor orientation">

## Usage
1. Run the demo with provided sample data. Results are located in [`data/final`](./data/final/20210408-190706_sensor-orbit_100RPM).
```bash
matlab -nodisplay -nosplash -nodesktop -r "run('./src/calculate_kinematics.m');exit;" 
```

2. Log into acquisition computer and record your own data:
```python
ssh pi@raspberrypi
./src/record_kinematics.py
```

4. On host computer, transfer data from acquisition computer:
```bash
./src/transfer_data.sh
```

6. Sterilize components again with alcohol wipe to remove tape residue and contaminants.

## Notes
Design Considerations:
- Sensor selection: IMU
    - LIDAR: may interfere with already-crowded spectrum (red/green for oxygenation, blue for optogenetic stimulation, red also for blood velocity, infrared for OCT). We could choose a LIDAR unit that emits at a different wavelength, but no access to our power meter to verify emission spectrum.
    - magnetometer / hall sensor: The sensor was easily saturated with our magnets, so the working range was limited. [Hemoglobin is magnetic](https://twitter.com/rainmaker1973/status/1019877124952481792), so a strong magnet may disrupt one of the measurements we're making.
    - test indicator: Mitotoyo ID-C has most frequent sampling and is slower than our IMU (100 [Hz] vs 500 [Hz]), expensive ($200 vs $20), [susceptible to cosine effect](https://www.mitutoyo.co.jp/eng/products/menu/QuickGuide_Dial-Indicators.pdf)
    - [motion capture suit](https://en.wikipedia.org/wiki/Motion_capture)
    - GPS: good for ±1 meter, not [mm], [um], or [nm]
- Redundant method: camera
- Sensor mounting
    - double sided tape
    - snap connector: difficult to source, digikey doesn't stock them. Alibaba does. But now instead of figuring out how to mount the sensor to the rodent, we just push off the problem and now have to figure out how best to attach the snap connector to the sensor.
    - veterinary glue
- Sensor sampling period: nyquist sampling frequency
- Stage resolution
- Stage response time
- Stage speed
- Stage vertical load capacity: > 17 [lbs]. Sterotaxic holder is ~15 [lbs], adult lab rats are ~1-2lbs.
- FFT filter type and parameters: highpass

Drawbacks:

## Acknowledgements
- [Luis Prado](https://thenounproject.com/search/?q=paparazzi&i=881234) and [Emily Baker](https://thenounproject.com/search/?q=paparazzi&i=881234) for their icons.
