Restrictions
% stimmde on one stimulators should remains same
% stim_devic for all stimulators on one conditions should be different, no
% same stimulators should be allowed to add

the MT capability for Multimodal will be dealt later on, the si coloumn can be updated in case if there is a MT available
or if MT is specified then multiply it by that factor, otherwise its just 100%
























the last timing arrows and t is not needed
the first t on the on stim axes is not needed
the first t on all the other axes are needed from a reference line drawn in between [bottom of first stim axes till start of all the stim axes]

the time text, and its arrows will have to be given a dedicated handle so that they can be deleted later on if the condition is deleted

ON THE BASIS OF THE time axes information of any of the stimulator axes, the measurement can be put up accordingly where it should be measured




get current condition using Selected Child



TAB PER PANEL BANO AUR US PANEL PER PHIR AXES DALO PHIR JA K ROLA SAHI HOGA


make the small inputdialg based input boxes quickly as callbacks for the 
make the pulses for all the axes 

saving the parameters of 1)time, 2)pulses and 3)input boxes, and 4)stimulators on the specific data structures
delete handles for 1)stimulators, 2) pulses and 3) conditions
making the icons on buttons
change the sp, pp and train to which stimulators are required 

go trial by trial and make it appropaite


save t, sp, pp, train, input boxes into their appropriate matriex in condition, stimulator, pulse, timing manner
make the input dialgoues for the sp, pp , train, input boxes, 


make all of the systems on it






















start the multimodal development and go untill 3:30 agenda is to make the condmat

make the handle if the input and output device device list is empty then it should be basically empty but not give an error

inputdlg box for sp, pp, train, all kind of measurements etc 


show warning that the stimulation intensity changing on the same stimulator with a very short time interval is difficult

will have to make a figure basically for the sp pp train and input boxes where i need any kind of fancy selection



TODAY
MAKE THE INPUT PANELS for sp pp train and measures and then store them systematicaly 

prepare the % 11-Mar-2020 14:44:11





















make factorized conditions
    reationalize factors as did for MEPs case
make the trial vector
make the axes appearing as they should be
make the scat plot and ioc fit functions
make the mep stats function
run it altogether


proceed towards thresholding function



display mean of last N and connect with the uimenu for last K mean
move pause and stop over to the general analytics panel
check the problem with first axes


update the yaxis ticks when the lims are changed manualy

Dayend: write pesudo code complete untill now

uistack grid lines of motor threshold level to be top but lets see with real , baseline corrected data



DONT STOP UNTILL ITS DONE AT THE LEVEL OF WHERE YOU LEFT IT (MEP, HOTSPOT, THRESHOLDING, IOC)










Today: let there be a warning that there shouldnt be any 0 elements in this because, if any of ylim elements is zero then it would be problem in normalizing that, later on mouse gestures can be imlemented
Today: the manual limits inputs dialogue box is stopping the background loop, make a func to create a figure and then put its button press callback to be executing the limits 
    
    
    
then make the timevector and then integerate it inside plot and then mark the xlim xticks ylim yticks etc 

Improve the hardware configuration function and save its defaults so that entereis dont have to be uploaded regularly 



Error handling of axes up down (if the max-min=25 microvolts then stop decreasing it further and show warning)


use this link for DBSP https://www.mathworks.com/help/matlab/matlab_oop/example-using-events-to-update-graphs.html



















TODO List

MAJOR BUGS:
After the trials are prepared, make a vector obj.inputs.allOutputDevices, and obj.inputs.allInputDevices, this will help in the booting functions 


Things to not for BOSSBOX
1. need an exg_scope function containing first eeg channels and then emg channels inside one scope, the eeg_scope and emg_scope can there exist seperately as well;
1. the trigger function needs to be able to send trigger to multiple ports in a time a part manner, and should also have a layer of as if 
    a. only trigger pulse
    b. only trigger scope
    c. trigger both pulse and scope
abhi me ne last jo kam kia he k axes as per the inputs ban jayen ab agla kam me waiting period vala likhna he, tic likh dia he me ne stim k bad bus toc kero time note kero aur testing kero



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
















When ITI is set to be three or more different conditioning variables then the space is also considered as one of the intended ITI , solve it 
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
if t is a 1x1 array containing 1xn cells then string([t{:}]) would give you a 1xn strings and char would give 1xn chars and may be useful in future
display table on command line just like the way is shown by EEGLAB using this command: T=cell2table(ans.bst.inputs.condMat)
https://www.mathworks.com/help/matlab/ref/inputdlg.html


-------------------old mep 
% %             %old code
% %             obj.info.event.best_mep_amp=1;
% %             obj.info.event.best_mep_plot=1;
% %             obj.info.event.best_mt_pest=NaN;
% %             obj.info.event.best_mt_plot=NaN;
% %             obj.info.event.best_ioc_plot=NaN;
% %             obj.info.event.hotspot=0;
% %             obj.info.event.best_mt_pest_tc=0;
% %             obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.update_event=0;
% %             obj.info.event.pest_tc=0;
% %             
% %             
% %             figHandle = findobj('Tag','umi1')
% %             panelhandle=findobj(figHandle,'Type','axes')
% %             obj.info.axes.mep=findobj( panelhandle,'Type','axes','Tag','mep')
% %             obj.best_trialprep;
% %             obj.best_stimloop;
            