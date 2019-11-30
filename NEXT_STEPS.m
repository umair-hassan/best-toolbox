NEXT STEPS

Make sure that best toolbox GUI makes the designed folder as cd so that whatever figures and data is saved is done with in same cd
1-listboxes error, when there is a error in the run command, make the listbox enabled again, put try and catch

when a new measurement is added after copying and pasting, the new measurement number (the digit at the end is equivalent to total session's no but it should be equivalent to whats the max in the list and +1 to it or somewhat stronger
The MT measure is sstill shown in TMS-fMRI panel rather show that drop down and link that drop here for easy use


while copy pasting the session or its measurements, make all enable on that are required by default in any func so 
when copying an already runned session because of current general settings for making a plot, it immediately throws an error because its copy is not runned yet and therefore have no data yet
delete then delete the bst data and show warning dialog box, if dialogi is ok delete then delete it
if listbox is empty create a handle for every listbox uimenu function as create in listbox measure delete func

the results (means graphs) of already runned to be shown when the show results is clicked from uimenu
update/pause correction  (just make it written as unpause when pause is pressed) thats it, reproduce it for all input functions works with uiwait but later on or store the trial number and the duration of pause in another matrix thats even better
multiple muscles target for same stimulation (MEP-IOC - Thresholding)
multiple muscles target for different stimulation (MEP-IOC-Thresholding)
paired pulse paradigms for each of meas (MEP - IOC)
make the documentation and send it to til for further review 


Ability to be able to change no of trials to average for calculation of MT
The next stim intensity to be shown on the top of results write next stim intnesity stuff on the top of results anywhere
make a seperate default load func for each of seperate function

subject specific panel_row and tables for extra info




OPTIONAL

make a flag for sim_mode so that when its 0 actual experiment is hapenning when its 1 its loading mat sim data and running simulations only
Enable Motor Threshold (%MSO) lines in MEP meas and IOC only when %MT units are selected otherwise off
Font size for entire GUI figure, as an option try this by just setting fig font set to some bigger val















Most Important Comments






Important Comments
MT IP the thresholding method drop down is not being selected properly value=2 in case of PTC method
MT PTC method is not showing the threshold written on top of plot 
ALL Input panels: make the update and stop button inactive untill the first method is runned first time, after one one complete run the stop would again be disabled along with run bt update not
ALL Inputs panels: better to put that in volts so that entering 0 shouldnt be a problem and there should be a handle in general setttng for setting it to mv or micro volts tooo#
MTnMTPC are showing the lasttrial+1 in their trial number x axiess too this in post hoc mode , this is basically due to the reason that on last run the next trial is still save, delete that total+1 stim value
MeasureValueChangeListBox when it is active and measure has taken place already, then if the person asks to show the results, create then only but not everytime - smart solution to avoid conflict
Adding session after loading the saved file is giving an issue, but the measures are correct ER1, possibly because it wants to load the measures listbox for that session but that doesnt exists
In global settings there should be a root directory folder , for each of new experiment, matlab using mkdir function will search that folders using dir function ,if they name exists matlab throws an error otherwise it creates a folder and saves everything there in seperated folder, figures in seperated folder and data in seperated folder



Comments for PostHoc
FONTSZIE of posthoc plots is not picking up the last set value
Interaction with Posthoc plots for Y axis lims, the mean annotation and the plt scopes to be made yet
Posthoc plots make the red line on top of all lines and black line on second top and the gray lines on last 
When session or measure is added go to the latest


DoneList
Putting saving figure commands after all the RUN functions
Correct IOC stuff, that RMT line etc
MTPTC Starting stim intensity is not being taken care of by the code investigate also it is adding the step size for the first intensity again while storing it, this results in a misleading graph, the trigger is sent at the accurate stim inten but the graph isnt, at graphs its +step size so omit the stop size for first trial
Randomization stuff (discuss with Til, in case of numel=1 for trial per condition the block randomization is used, for unequal trial per condition the entire stimuli vector is randomized)
Stop IOC anywhere and it should proceed towards plotting
STOP MT anywhere and it should proceed towards final steps of saving results
horizontal line on MEP plot for the case of MT 
MT mapping to the input panel 
Show the MT on the parameters too just above the run button
update MT result and save for load par functions so that they can be adjusted as per their normal range
hotspot to just send the triggers out but not the intensity commmands so that the user be able to set it on their own
when MEP plot for MT is crecreated or exported to matlab the horizontal dotted lines disapper
check if in cb_session_add(obj) the session no should not be being minused twice
paste dwn and move up down are too easy to operate then
if newsession_copy already exists then make a newsession_copy(2) by making a matrix that keep record of all copied sessions exist then make a copy_2 or similar 
The experiment title, subject code, session title and measure name cant be same at all at one time its throwing error
the uicontextmenu copy paste delete etc for listboxes
disable the listbox movements before a stop is actually pressed for ongoing measure + disable the uimenu for both of listboxes
if anything was copied but not pasted on the list, that would count towards the copybuffer so make copy buffer in the paste func
sessions listbox delet copy paste up paste down moveup move down funcs
If paused is pressed, and then stopped is pressed, the uiwait will not let the stop happen or update happen too, so just atlest put uiresumt when the stop is pressed
update the saving feature ability to all of the functions
introduce pause unpause fully into all function along with its info vector
save the trial by trial in a proper time effeicient manner so that its not lost at all
make sure that previously written info is not overwritten otherwis that would need to be saved everytime


%% For RTCLS
The spatial_filter_weights property have two fields namely signal_id, underwhat circumstances the 2nd signal_id is expected to be populated?
What is the units of the eye_artifact_threshold ? In some older scripts its 1e6 wheereas in some its only 250 or 0.25 , what should be be preferable as a default value?
What are units of eeg_artifact_threshold? In some older scripts I found it to be around 90 or 1e6 , also they row vector have two elements, what is their signifnance that are identical, is there any signifiance or its just a buffer?
What kind of value pair is the property calibration_markers expecting ? 



