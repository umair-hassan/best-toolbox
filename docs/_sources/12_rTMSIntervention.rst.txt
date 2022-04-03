.. BEST toolbox documentation master file, created by
   sphinx-quickstart on Fri Jul  9 21:52:50 2021.
   You can adapt this file completely to your liking, but it should at least
   contain the root `toctree` directive.




============================================
rTMS Intervention
============================================

.. important::

    This protocol is being refactored and improved continuously, so documentation and software may not be completely synchronized.  

Parameters Syntax
-------------------------------------------

Brain State
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

In Brain State Independent case, Inter Trial Interval controls the timing of the stimulus whereas in Brain State dependent case, real-time EEG analysis allows to track the ongoing Phase and Amplitude thresholds thereby allowing to determine specific Brain States such as mu-Rhythm Peak Phase etc. and then delivers the stimulus upon a parametric case match.

Input Device
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Select the input device using drop down menu from previously added devices

Inter Trial Interval
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

ITI scalar, or a range in seconds e.g. 4 or [4 6] or a cell array in order to create ITI based experimental conditions e.g. {4,5,6}

Trials Per Condition
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Various conditions can be created using ITI, Oscillation Target Phase and/or Amplitude and using the interactive Stimulation Parameters Designer. This field applies to all the created conditions and should be a scalar number e.g. 10 or 20 etc.

EMG Display Channels
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Type the channel name as a 1xN cell array in order to visualize its online results e.g. { ‘APBr’}. Note that the channel name must resolve to the name in your streaming data, however Display Channels does not contributes for Threshold Measurement, these channels are merely for visualization e.g. in case when neighboring muscles are also required to be monitored.

EMG Extraction Period
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

[min max] in ms

EMG Display Period
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

[min max] in ms

MEP Search Window
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Time window to look for the MEP P2P amplitude. [min max] in ms

Trials to Average
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Both of the threshold methods , average certain number of trials in order to estimate the final threshold value, this parameter is specified as a scalar e.g. 10 and can be updated in run time as well.

Real-Time Channels Montage
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

1xN cell array of Channel Names being streamed from the bio signal processor e.g. { ‘C3’, ‘FC1’, ‘FC5’, ‘CP1’, ‘CP5’}

Real-Time Channels Weights
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
1xN Numeric array of weights indexed w.r.t. to Channels Montage explained above e.g. 1 -0.25 -0.25 -0.25 -0.25

Frequency Band
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Choose the respective frequency band from the dropdown (Hz).

Peak Frequency
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Scalar Peak Frequency in Hz. In order to import it from created or successful rsEEG Measurement Protocol, select the respective rsEEG Measurement protocol from the adjacent dropdown menu.

Target Phase
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

1xN Numeric array of Phase angles in radians. This parameter also creates N experimental conditions crossed over with all the other experimental conditions. If columns in this parameter is balanced with the rows in Amplitude Threshold parameter, then balanced conditions are created otherwise these 2 parameters are also crossed over.

Phase Tolerance
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Scalar Tolerance value in radians. Defining absolute target phase angles in order to detect a brain state is often prone to error mainly due to the resolution of data obtained after sampling rate transition. In order to overcome this digitization resolution error another parameter has to be defined such that the vicinities of the target phase shall be made clear to the detection algorithm. For an instance, while detecting a 0 radians phase, the phase vector would probably look like this [-0.001324 -0.00234 0.00243 0.004324], and since none of them are mathematically equivalent to zero therefore in order to not allow to skip such Oscillatory Peak events and to increase the accuracy of the phase detection, a tolerance value is to be provided.

Amplitude Threshold
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Nx2 Numeric array of Amplitude Thresholds. The 2 column dimensions are minimum and maximum thresholds where as N (number of rows) creates N Amplitude Threshold conditions crossed over with all the other experimental conditions. If columns in this parameter is balanced with the rows in Target Phase parameter, then balanced conditions are created otherwise these 2 parameters are also crossed over. Units are selected from the drop-down adjacent to the parameter.

Amplitude Assignment Period
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

If the Amplitude Threshold units are percentile, then the percentile is calculated over a certain time period defined in this parameter. This parameter enables the Brain State detection algorithms to cope with the variations in amplitude of large scale oscillatory activity e.g. due to variations in background neuronal activity.

EEG Extraction Period
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

[min max] in ms


EEG Display Period
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

[min max] in ms

Creating Conditions Using Stimulation Parameters Designer
------------------------------------------------------------------------

The Target Channels and Stimulation Trigger pattern can be defined in an interactive Stimulation Parameters Designer comprising of a tabular and graphical view. Following video illustrates that how conditions can be created using the intuitive designer. Note that the example below is associated to Motor Threshold Hunting however exactly same procedure applies for the MEP Measurement Protocol to create various measuring conditions.

.. youtube:: nY-j2WL1dk4&t=1s

Starting the Protocol
--------------------------------------------------------

To start this Protocol, just press the “Run” button at the bottom of the “Experiment Controller”. The measurement can be stopped, paused/unpaused. In order to check if all the parameters have been setup correctly, pressing the “Compile” button would prompt the results of compiled code whether its good to go or not.
