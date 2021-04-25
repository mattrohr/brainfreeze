<p align="center">
<img width="50%" src="https://i.imgur.com/8rafq45.png" alt="Banner">
</p>

<p align="center">
<b>Stabilize brain motion while imaging</b>
</p>

<p align="center">
<a href="https://github.com/mattrohr/compensation-stage/actions?query=workflow%3Abuild">
<img src="https://github.com/mattrohr/compensation-stage/workflows/build/badge.svg?branch=main" alt="Build Status Badge">
</a>
</p>

## About
When imaging the brain, breathing causes image shift <sup>[1](https://pubmed.ncbi.nlm.nih.gov/22108978/)</sup> and may cause the image to drift in and out of focus. This repository includes hardware and software to counteract this motion in realtime.

## Installation
1. Purchase [bill of materials](./docs/BOM.xlsx)

2. [Configure operating system on acquisition computer](https://learn.adafruit.com/circuitpython-on-raspberrypi-linux/installing-circuitpython-on-raspberry-pi)

3. Place inertial measurement unit on flat surface and [connect to acquisition computer](https://learn.adafruit.com/adafruit-9-dof-orientation-imu-fusion-breakout-bno085/python-circuitpython). It does not matter which female connector you choose.

4. Calibrate sensor by placing inertial measurement unit waiting about 10 seconds. Rotate sensor about all axis for about 10 seconds. Rotate IMU sensor about all axis for about 10 seconds.

4. Copy this repository on both host computer and acquisition computer so it may write files:
```bash
git clone https://github.com/mattrohr/compensation-stage.git
```
5. Grant python script executable permissions:
```
chmod u+x ./src/record_kinematics.py
```
6. Sterilize components with alcohol wipes to minimize infection risk. Because of the low water content in 99% alcohol wipes, evaporation is quick and you may need to use several wipes. 

7. After board dries, apply black gaffer tape to red raspberry pi and green IMU LED status indicators to prevent contaminating oxygenation measurement.

<img align="right" width="50%" crop src="https://i.imgur.com/xJVPfHU.jpg" alt="IMU sensor orientation">

8. Attach IMU sensor Scotch double-sided adhesive square. The sensor has an orientation compass on the bottom right. Position the compass so it faces up, Y points to the snout, X points to the right ear, and the sensor is close to the cranial window. Ideally this area should be shaven for a secure fit.

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
**Design Considerations:**
- Sensor:
    - IMU: cheap ($20), ease of assembly because it's solder-less, fast sampling rate (500 [Hz]) which is well above Nyquist sampling rate 2.84 [Hz] (2 * [expected motion of 85 breaths per minute](http://web.jhu.edu/animalcare/procedures/rat.html) / 60 seconds), minimally invasive
    - LIDAR and laser distance meter: may interfere with already-crowded spectrum (red/green for oxygenation, blue for optogenetic stimulation, red also for blood velocity, infrared for OCT). We could choose a LIDAR unit that emits at a different wavelength, but no access to our power meter to verify emission spectrum.
    - magnetometer / hall sensor: The sensor has a limited working range--[our magnets](https://www.amazon.com/gp/product/B01I1XNV0I/ref=ppx_yo_dt_b_search_asin_title?ie=UTF8&psc=1) easily saturated the sensor. Field-strength quickly dropped as magnet moved away and undetectable because inverse square law. [Hemoglobin is magnetic](https://twitter.com/rainmaker1973/status/1019877124952481792), so a strong magnet may disrupt one of the measurements we're making.
    - test indicator / dial indicator: [test indicator is susceptible to cosine effect](https://www.mitutoyo.co.jp/eng/products/menu/QuickGuide_Dial-Indicators.pdf#page=4), [Mitutoyo ID-C](https://www.amazon.com/Mitutoyo-543-392B-Digimatic-Resolution-Specifications/dp/B002SG7PI4/ref=sr_1_1?dchild=1&keywords=mitutoyo+id-c&qid=1619141916&sr=8-1) digital read out and has the most frequent sampling, but it's still slower than our IMU (100 [Hz] vs 500 [Hz]), expensive ($400 vs $20 IMU), only measures 1-D. Starett said their fastest sampling rate was once every 5 seconds--seems too slow, my question was probably misunderstood.
    - [motion capture suit](https://en.wikipedia.org/wiki/Motion_capture): we don't need full body motion, just cortex motion. So we'd need several reflective orbs around an area already-packed with life support equipment.
    - ultrasonic sensor: limited working range because of the conical beam. Also the emission point is at a different point than the detection path. Because we're measuring a curved object, the distance we'd read would not be the real distance. Cheap off-the-shelf models are only accurate to around a couple [cm], insufficient for our purposes.
    - OCT feedback
    - Radar
    - GPS: good for ±1 [m], not [mm], [um], or [nm]
- Sensor disinfection: 99% alcohol wipes have low water content, so unlikely to short or corrode sensor. But that also means they quickly evaporate, so several might need to be applied to clean biological contamination. They're individually wrapped for sanitary environments. 
- Redundant method: camera
- Sensor mounting
    - medical-grade tape: [Nitto ST-2604](https://www.nitto.com/us/en/products/medical/003/) is breathable, non-irritating, has goldilocks tensile strength. But difficult to source on manufacturer, findtape, amazon, eBay, box stores, and elsewhere. You have to buy cases instead of individual rolls. Same story for 3M equivalents. Requested samples.
    - normal double sided tape: too high tensile strength will rip PCB pads and/or skin, cause skin irritation, non-breathable so moisture buildup and subsequent detachment
    - snap connector: difficult to source, Digi-key doesn't stock them. [Alibaba does](https://www.alibaba.com/product-detail/PCB-electrode-button-Medical-button-snap_60687245853.html). But now instead of figuring out how to mount the sensor to the rodent, we just push off the problem and now have to figure out how best to attach the snap connector to the sensor.
    - [veterinary glue](https://www.amazon.com/3M-Vetbond-084-1469SB-Vetbond-Tissue-Adhesive-1469Sb/dp/B004C12Q46):
    - single sided athletic tape:
    - double sided foam adhesive squares: Scotch Removable Mounting Square. Readily available at retail stores. 1 [lb] tensile strength seems adequately sticky. But because they're foam, they have 2 +/- 0.2 [mm] lateral and axial movement when squashed. They're pretty rigid, precut, perfectly sized, cheap. Adequate until we can source thinner, double-sided medical tape. No perceptible residue.
- stabilization method
    - optical stabilization (move lens)
    - in-body stabilization (move sensor)
    - digital stabilization (move objective)
    - subject stabilization (this method)
- Sensor sampling period: Nyquist sampling frequency
- Sensor accuracy:
- Stage resolution
- Stage response time
- Stage speed
- Stage vertical load capacity: > 17 [lbs] because Kopf stereotaxic holder is about 15 [lbs], adult lab rats are about 1 to 2 [lbs].
- FFT filter type and parameters: highpass
- other sources of motion than breathing: heart beat, muscular and tendon flexion and extension, optogenetic stimulation galvo jitter, external. One IMU will measure all movement that rodent experiences. To isolate external noise (e.g. IV pump), individual IMUs can be placed on or near them (e.g. table) to determine their frequency for filtering.

**Drawbacks:**
- IMU drift: Because we're integrating acceleration to calculate position, we're also accumulating sensor bias. Overtime the sensor reading will drift away from the true value. However because breathing is cyclic, we have a lower and upper bound on displacement in X- Y- and Z-axes. Therefore we can detrend by assigning all troughs a value of zero, and likewise for signal peaks. <img align="right" width="50%" crop src="https://i.imgur.com/YwBZfIa.png" alt="IMU sensor drift"> Nevertheless, displacement readings between peaks and troughs will have uncertainty because of sensor drift. 

- induced motor motion: as long as the motor doesn't induce more motion than the motion we're correcting for. Thorlabs stuff seems quite good (insert measurement). But note that Boas said even 1um is a lot for OCT. inertia of stage

- non-uniform sampling time: Because of Python sleep() function and/or lack of timing chip, time between recordings is irregular. Our fast Fourier transform needs these evenly-spaced samples, so we interpolate time and acceleration readings. Since our selected inertial measurement unit's sampling rate (500 [Hz]) is more than Nyquist sampling rate (about 3 [Hz]), we capture all expected dynamics. The interpolated data between recorded results are likely similar to true motion.

- non-uniform stage travel: flatness, straightness, roll, pitch, yaw

- system initialization 

- calibration: The IMU's reference frame depends on gravity and magnetic north. Down is opposite gravitational field. East is cross product of down and measured magnetic field. North is cross product of down and east. This means magnetic objects may distort headings. Gravity strength and [magnetic north change slow]((https://geomag.bgs.ac.uk/images/igrf/dIcolourful.jpg)) enough to be negligible.

- bulk vs local motion: Because an IMU only collects kinematics at one point, and a stage can only move the entire rodent, only bulk motion can be compensated for with this design. As [Boas' team noted, bulk was the most significantly detected motion](https://pubmed.ncbi.nlm.nih.gov/22108978/). This bulk motion may be drowning out local motion. If we compensate for the bulk motion mechanically, their algorithm may still be to complement this system by detecting and compensating for local motion. Additional IMUs may add redundancy, but several, modern off-the-shelf boards are be too big to fit near cranial window. 

Current state of project noted in [issues](https://github.com/mattrohr/compensation-stage/issues).
## Acknowledgements
- [Hadi Esfandi](https://linkedin.com/in/hadi-esfandi-ab004877) and [Mahshad Javidan](https://linkedin.com/in/mahshad-javidan-a0705677) for feedback on an earlier design
- [Luis Prado](https://thenounproject.com/search/?q=paparazzi&i=881234) and [Emily Baker](https://thenounproject.com/search/?q=paparazzi&i=881234) for their icons