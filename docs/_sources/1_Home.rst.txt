.. BEST toolbox documentation master file, created by
   sphinx-quickstart on Fri Jul  9 21:52:50 2021.
   You can adapt this file completely to your liking, but it should at least
   contain the root `toctree` directive.



============================================
Introduction to BEST Toolbox
============================================

To facilitate objectivity, reliability, and reproducibility of non-invasive brain stimulation (NIBS) studies and to empower students, researchers, and clinicians alike to conduct state-of-the-art multimodal NIBS studies, an automated but yet flexible tool for data collection and analysis is needed.

**B**\rain **E**\lectrophysiological recording and **ST**\imulation (**BEST**\) Toolbox is an easy-to-use MATLAB-based open-source software with a powerful graphical user interface (GUI), which allows the user to flexibly design, run, analyze, and share multi-protocol/multi-session NIBS studies, involving transcranial magnetic, electric, and ultrasound stimulation (TMS, tES, TUS) in combination with EMG, EEG, and fMRI.

The BEST toolbox interfaces with a large variety of recording and stimulation devices to analyze data and set stimulation parameters on-the-fly, thereby enabling closed-loop protocols and real-time applications. Its growing functionality includes e.g., TMS motor hotspot search, automated motor threshold estimation, measurement of motor evoked potentials (MEP) and TMS-evoked EEG potentials (TEP), dose-response curves, paired-pulse and dual-coil TMS, rTMS interventions, real-time EEG-triggered stimulation, concurrent TMS-fMRI, etc.





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

BEST Toolbox is integrated with `neuroFUS open source APIs <https://github.com/nigelrogasch/MAGIC/>`_ MAGIC toolbox and `neuroFUS open source APIs <https://github.com/umair-hassan/neurofus-api/>`_  in order to control and interact directly with the TMS devices that accepts TTL input for triggering and features API to set the device parameters:

* MagVenture (TMS)

* MagStim (TMS)

* BiStim (TMS)

* Rapid (TMS)

* DuoMag (TMS)

* neuroFUS (TUS)


In addition, it can also trigger any stimulation devices that can receive a TTL input trigger.


