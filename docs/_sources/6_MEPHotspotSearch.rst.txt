..  BEST toolbox documentation master file, created by
   sphinx-quickstart on Fri Jul  9 21:52:50 2021.
   You can adapt this file completely to your liking, but it should at least
   contain the root `toctree` directive.

============================================
MEP Hotspot Searchh
============================================

Motor Hotspot Search function of the BEST Toolbox, trigger the stimulating device on trial by trial basis in a given inter-trial-interval and presents you online results of MEPs in order to visualize the MEP shape and its amplitude stability at a given hotspot.

Parameters Syntax
-------------------------------

Input Device
^^^^^^^^^^^^^^^^^^^^^^^^

Select the input device using drop down menu from previously added devices

Output Device
^^^^^^^^^^^^^^^^^^^^^^

Select the output device using drop down menu from previously added devices

Protocol Mode
^^^^^^^^^^^^^^^^^^^^^^^^^

Automated allows you to set an Inter Trial Interval for trigger control whereas upon selection of Manual mode, the Protocol

EMG Display Channels
^^^^^^^^^^^^^^^^^^^^^^^

Type the channel name as a cell array in order to visualize its online results e.g. { ‘APBr’}. Note that the channel name must resolve to the name in your streaming data.

EMG Extraction Period
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

[min max] in ms

EMG Display Period
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

[min max] in ms

MEP Search Window
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Time window to look for the MEP P2P amplitude. [min max] in ms

No. of Trials
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Total number of trials e.g. 100

Inter Trial Interval
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

ITI scalar, or a range in seconds e.g. 4 or [4 6]

Starting the Protocol
--------------------------------------------

To start Motor Hotspot Search Protocol, just press the “Run” button at the bottom of the “Experiment Controller”. The measurement can be stopped, paused/unpaused. In order to check if all the parameters have been setup correctly, pressing the “Compile” button would prompt the results of compiled code whether its good to go or not.

An instance of the filled stimulation parameters panel is shown below.

.. figure:: figures/fig5_MEPHotspotStarting_the_Protocol.png
    :align: center
MEP amplitude estimation procedure
--------------------------------------------------------

MEP amplitude estimation follows procedure described in Bergmann et al, Journal of Neuroscience 2019. 