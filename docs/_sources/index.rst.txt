.. User Manual - bossdevice research documentation master file, created by
   sphinx-quickstart on Fri Jul  9 21:52:50 2021.
   You can adapt this file completely to your liking, but it should at least
   contain the root `toctree` directive.



============================================
Introduction to BEST Toolbox
============================================

Brain Electrophysiological recording and STimulation (BEST) Toolbox, is a MATLAB based open source software that interfaces with a wide variety of EEG, EMG, TMS and other stimulating devices, and allows to run flexibly configured but fully automated closed-loop Brain Stimulation protocols.

BEST Toolbox allows user to run customized Brain Stimulation experiments including basic measures of cortical excitability such as motor hotspot search, motor threshold hunting, motor evoked potential (MEP) and TMS-evoked EEG potential (TEP) measurements, estimation of stimulus-response curves, rTMS intervention protocols, etc., and since recently also Brain State-dependent or real-time EEG-triggered stimulation.

Along with its many technical abilities, the toolbox features a state-of-the-art and flexible MATLAB based application – a Graphical User Interface to easily design experiments, online interactions with the data, visualization of data and a standardized format for the data under collection.


Hardware Interfaces
=============================================

BEST Toolbox is currently optimized for bossdevice  (`sync2brain <https://sync2brain.com>`_) , a data processing and control system implemented as Simulink© Real-Time model on a high performance computer system receiving a digital real-time data stream from an EEG system such such as:

* NeurOne TESLA (Bittium, FL)

* actiCHamp Plus (BrainProducts, DE)

* CED 1400 (Power and Micro)

Additionaly a native implementation of following buffers is also part of the toolbox.

* FieldTrip Real-Time Buffer

Input Devices
---------------------------------------------

The bossdevice and FieldTrip real-time buffer in turn allows the BEST Toolbox to interface with a wide variety of hardware and streaming platforms. Including but not limited to followings:

* Java

* Python

* Arduino

* BCI2000 includes the FieldTripBuffer and the FieldTripBufferSource modules

* BrainVision

* NeurOne TESLA

* BrainStream

* ANT NeuroSDK

* Artinis Medical Systems (NIRS)

* BrainVision Recorder

* Biosemi

* CTF (MEG)

* Emotiv

* Neuromag/Elekta (MEG)

* Jinga-Hi (LFP/EEG)

* Micromed (ECoG)

* ModularEEG/OpenEEG

* Neuralynx (LFP)

* Neurosky ThinkCap

* OpenBCI

* TMSI

* TOBI

The details about implementation of FieldTrip real-time buffer can be found `here <https://www.fieldtriptoolbox.org/development/realtime/implementation/>`_. 

Output Devices
----------------------------------------------

BEST Toolbox is integrated with MAGIC toolbox in order to control and interact directly with the TMS devices that accepts TTL input for triggering and features API to set the device parameters:

* MagVenture

* MagStim

* BiStim

* Rapid

* DuoMag

In addition, it can also trigger any stimulation devices that can receive a TTL input trigger.

.. toctree::
   :numbered:
   :hidden:
   
   1_Home
   2_DownloadAndSetup
   3_StartBESTToolboxApplication
   4_DesignExperiment
   5_HardwareConfiguration
   6_MEPHotspotSearch
   7_MEPThresholdHunting
   8_MEPDoseResponseCurve
   9_MEPMeasurement
   10_rsEEGMeasurement
   11_TEPMeasurement
   12_rTMSIntervention
   13_TUSIntervention
   14_TMSfMRIMeasurement
   14_ERPMeasurement
   15_SensoryThresholdHunting
   15_IssuesBugsRequests
   16_Workshops
   17_About Us
