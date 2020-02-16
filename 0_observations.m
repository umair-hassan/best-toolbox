TODO List

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