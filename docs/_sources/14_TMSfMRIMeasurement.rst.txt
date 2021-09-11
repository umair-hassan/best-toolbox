.. BEST toolbox documentation master file, created by
   sphinx-quickstart on Fri Jul  9 21:52:50 2021.
   You can adapt this file completely to your liking, but it should at least
   contain the root `toctree` directive.



============================================
TMS fMRI Measurement
============================================

TMS fMRI Measurement Protocol of the BEST Toolbox allows to deliver TTL output signal in order to trigger TMS or any other device connected with the TTL output of an Arduino and LM555 Timer IC (circuit attached at the page end). The embedded system of the microcontrolling circuit is programmed to read in the MRI Volume triggers as inputs and perform book keeping of the triggers in order to precisely deliver the TMS pulse in between the MRI Volumes.

Parameters Syntax
---------------------------------------------

Time of Acquisition (TA)
^^^^^^^^^^^^^^^^^^^^^^^^^^

TA in ms , scalar.

Trigger Delay
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Scalar period in ms that defines the time of trigger relative to start of the volume. For an instance, given the TA of 916ms, if one desires to deliver the stimulation trigger output at the 930ms relative to start of this volume, that reflect the output trigger is delayed by 14ms in the period of silence i.e. when there is no acquisition of Volume is taking place. TA+Trigger Delay=Time of Output Trigger

Total Volumes
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Number of total volumes in the whole scan e.g. 900.

Inter Trial Interval
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

1xN vector of Volumes number to be randomly selected as interval between triggers e.g. [18 19 20 21 22]. The trigger happens at the Volume immediately after the given volume number, e.g. if the ITI is 18 then the next stimulation trigger will occur at the Time to 18 Volumes + TA+ Trigger delay .

Stimulation Intensities
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

1xN vector of Intensities condition e.g. [30 40 50 60 70 80]

Intensity Units
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

%MSO corresponds to Maximum Stimulation Output, %MT corresponds to Motor Threshold

Motor Threshold
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

If the Intensity Units are %MT then an integral Threshold intensity is required here in %MSO units such as 45

Volume Vector:
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Variable name that has been created in MATLAB’s base workspace (default of MATLAB Command window). Its a 1xN vector of Volumes number after each of which the trigger output has to be generated , where as N equals Number of Total Volumes.

Starting the Protocol
----------------------------------------------------

To start the Protocol, just press the “Run” button at the bottom of the “Experiment Controller”. Unlike all other measures, this measure cannot be pause/unpause however can be stopped, In order to check if all the parameters have been setup correctly, pressing the “Compile” button would prompt the results of compiled code whether its good to go or not.

An instance of the filled stimulation parameters panel is shown below.


.. figure:: figures/fig8_tmsfmri_starting.png
    :align: center

.. figure:: figures/Figure9MicrocontrollingCircuitTMSfMRI.png
    :align: center
