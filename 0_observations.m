TODO List

MAJOR AGENDA
Make the generalized results panel



TODAY MILESTONE- MEP Measurement (sp, pp, multi stim, multi channel , different stimulators, should be done)
TOM MILESTNE- Thresholding (sp, multistim, multichannel, different stim should be done)
TOM MILESTONE- HOT Search (sp, multo channel, multi stim etc for all chnnels for all stimulators)
WED MULESTONE- IOC should be done 
THU MILESTONE- Meet Til and update him 
THU MILESTONE- TMSEEG for various stuff should be done 
FRI- rTMS, TEP measurement



BIG MILESTONES
- Rectifying Inputs panel
- Designig Results panel (the analytics dashboard, taking response buttons of pause, stop, update etc there) - PIRNICIPLE DECISION about 6 ch in MEP, HOTSPOT, 3 ch in Threshold, IOC 
- best_toolbox class architecture generalization



make a general rp and then add a layer of MEP monitor , Thresholding Trace, etc over it 


remove update button since the update will be an autonomous one, as we click the response button it will be update that particular thing,

1. when the font is increased set increase the fixed pixels as per the ratio of font increase from original font .this would make it quite respnsive
2. If the target channel list also contains the channels that are to be displayed, then they are updated only for the trials when those channels are targeted , otherwise all other channels are updated 
3. For multi stimulator module, each condition (the tab) will have a measurement associated to it and there it can be decided what to display, measurement leads to decision of display , in other modules the measurement coloumn remains same as of the module, but in the multi, stim thing the displays will be updated as per each condtion

1. group the mep all associated functions togehter since when i am working on it i will need them al togheter 
1. input device, output device, display emg channel are not being callbacked and saved properly in the pars 
1a. for thresholding add another row stating the 'Threshold Channel' which would eventually threshold by making each channel as a different condition whereas showing all channels results everytime 
2. for mep panel the last 4 parameters can go to the top of results panel and then the analytics about results may be shown underneath them
3. make different results panels for different display EMG channel conditions i.e. if 1, then on the right is fine , but if there are more than 1 then these should be subsequently tackled upto 6, 3x3 and if the display channels are more than 3 then there should be a warning thrown
4. Beutification: Load the channel labels and then make a drop down layout of selection in the measurement panel to address the display channels label thingy - make a cell array from those user inputs (selections of dropdown) and then proceed as you did with just a cell array

-group the outputs and inputs together in the trial vector since the input device things would remain only once so they may come at first
simulate possibilities for all of the designs possible and then modify if anything is necessary


Make a category of None input for all stuff, in that case no results are shown but only the outputs are generated


Continue with the MEP stuff for now and lets do it later on and start making the generalized trial vector, think of any smart solution about the trial vectors where the NAN doesnt need to be put where as the coloumn numbers in the stim loop should be dynamic

Hardware configu todo list
add a configure device panel
add handles for device name ; or make its underscore delimeters handle
When selecting Device (row2) n output device, selecting the 2-4 value eventually goes to value 1 automatically, and same for value 5-8

1. Start making MEP one and incorporate all of the functionalities in it





assign the spceicfic slots of trial tables to trial loop


1. BOSS Box Output hardware config panels:  Host PC COM Port Address

2. Think more about how to better fill in the stimulation intensities coloumn

3. Make a row of checkboxes indeicing CS+TS , TS+CS, TS Alone , CS Alone in the paired pulse , Burst modules etc 




Future Features:
3. IN FUTURE - (if this is done then there might be problem for stim loop to mark the particular index, identify particular coloumn for a particular variable in stim loop and store it somewhere - ) The trial matrix will be specific for a very spceicific measuremenent ( first its label matrix will be generated having matrix labels and then units underneath it)
then its further elements will be generated, depending on the type of measuremennt everything will be filled in whereas there will be no NaNs in the trial vector
then before the stimloop its variables are mapped with the coloumn number and stored in an object space in order to be use within stimloop

------------------------
MEP sp 
MEP pp
IOC sp
IOC pp -, SICI, ICF, SICF, LICI, LICF
Multi Stimulator Measurement (MEP, IOC, Motor Threshold, Psychometric Thresholdin) - SAI-LAI [in this case there will be more rows of output devices , 5 coloumns for each so 20 coloumns completely]
Multi Stimulator Intervenction , PAS- ccPAS
rTMS (TBS)
Psyhcometric Thresholding




2. add display channel to the eegtms panel
2. make defaults and then extract particular channel
3. use that particular channel to extract the phase in a particular pre post stim period






Start adding Input Device, Output Device, Channel to Display, three lines protocol by protocol and make its FT alternative too

















just prepare a handle for the scope in dbsp to read only the required channels from the scope, in principle all channels will be required but if less are req. then only those should be written in the rtcls.mep buffer
for multiple channels the raw data field will then have channel names field and then the data of corrosponding channels trial by trrial increasing over row
configure port tiem marker's time should never be set other than 0 because otherwise it will try to arm the signal even when the generator is off and will generate and error saying this have waste some time on this so its imp



make the magventure object, rtcls objects and other object as part of the bst object since that would need to be controlled in other call back functions


make the input panels working just as fine as other panels (dont worry about saving them to universal directory)
give reference of those fields in input panels, change the scope to be the "Display Channels etc"
Add the FieldTrip buffer ability for MEP, Hotspot, Thresholding, IOC, and then add the TEP , ERP measurement and in them too,
Then add rs EEG analysis func and add the functionality in that too
Then add the rTMS intervenctions 



make the toolbox settings panel too that will have some common defaults settings saved in the universal directory
--------------------------------------------------

cheat code

convert array into string use char command
numel(cell) e.g. numel({'APNR',1,'PN'} will give the number of elements in the cell
UI control Enable inactive allows to set the integers without even conversion to string and it has the same appearance as when Enable is set to 'on' but it is not operational, really helpful