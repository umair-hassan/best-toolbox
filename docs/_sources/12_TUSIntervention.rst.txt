.. User Manual - bossdevice research documentation master file, created by
   sphinx-quickstart on Fri Jul  9 21:52:50 2021.
   You can adapt this file completely to your liking, but it should at least
   contain the root `toctree` directive.



============================================
Introduction to bossdevice research
============================================


The bossdevice research is a real-time digital signal processor consisting of hardware and software algorithms. It is designed to read-in a real-time raw data stream from a biosignal amplifier (electroencephalography, EEG), to continuously analyze the data and to detect patterns in this data based on oscillations in different frequencies. When such a pattern is detected, the device indicates this through a standard output port. This enables a stimulation device (such as a sound generator) to be triggered in response to a specific biosignal pattern occurring. The device can be programmed by the user to detect different patterns.

.. important::

    The bossdevice research is not a medical device. It may not be used outside of research and it may not be used in trials involving patients. It is not intended as an accessory to a medical device or to control a medical device. It may only be connected to a stimulation device if the stimulation device provides an input port for the purpose of receiving information regarding the desired timing of stimulation. Whether or not a stimulus is then generated in response to a signal from the bossdevice is determined by the stimulation device.



.. figure:: figures/Fig1_bossdeviceandneurone.png
    :align: center

    The bossdevice research placed along with Bittim NeurOne biosignal amplifier.

