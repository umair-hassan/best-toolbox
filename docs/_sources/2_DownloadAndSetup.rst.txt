.. BEST toolbox documentation master file, created by
   sphinx-quickstart on Fri Jul  9 21:52:50 2021.
   You can adapt this file completely to your liking, but it should at least
   contain the root `toctree` directive.



============================================
Download & Setup
============================================

MATLAB Version
===========================================

The BEST Toolbox application is compatible with any MATLAB version older than r2006, however MATLAB version should exactly be r2017b when the BEST Toolbox is to be used in conjunction with the bossdevice. The verification and validation of the toolbox has also been performed in r2017b and therefore release 2017b is recommended while getting started with the BEST Toolbox.

Download BEST Toolbox Repository
--------------------------------------------


The latest repository of BEST Toolbox released version can be downloaded from `here <https://github.com/umair-hassan/best-toolbox/releases>`_


Sign up for BEST Toolbox Newsletter
--------------------------------------------

To sign up for the BEST toolbox newsletter to be informed about updates, please click `here <https://forms.gle/eURXqdzFx5jqFHDW9>`_


Required APIs & MATLAB Toolboxes
-------------------------------------------


BEST Toolbox is dependent on following APIs and MATLAB Toolboxes:

* `Bossdevice release 2017 API <https://api.sync2brain.com/>`_  (also part of BEST Toolbox repository – no download required)

* `MAGIC <https://github.com/nigelrogasch/MAGIC>`_  (also part of BEST Toolbox repository – no download required)

* FieldTrip Toolbox (download required)

Additionally if the BEST Toolbox is intended to be used with bossdevice firmware 2017b then please setup the bossdevice API for firmware 2017b as instructed on its website `here <https://api.sync2brain.com/>`_.  Generally, this will require following MathWorks products:

* Simulink Real-Time

* Simulink Coder

Setup
------------------------------------------
BEST Toolbox
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

After downloading BEST Toolbox from the branch as instructed above, perform the following steps:

1.Unzip the repository’s zip file

2.Copy the path of unzipped repository

3.Use the following command syntax on your MATLAB Command Window after replacing <path_to_besttoolbox_downloaded_UNZipped_repository> with the path copied in 2nd step

.. code-block:: matlab

		addpath(genpath('<path_to_besttoolbox_downloaded_UNZipped_repository>'));
		savepath;


FieldTrip Toolbox
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
In order to setup FieldTrip properly please follow the tutorial given `here <https://www.fieldtriptoolbox.org/faq/should_i_add_fieldtrip_with_all_subdirectories_to_my_matlab_path/>`__

