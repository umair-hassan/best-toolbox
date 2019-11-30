%% inputs

% % To me it looks like
% % 1. Initiliaze Real time sys
% % 2. Assign channel labels
% % 3. Remove any EMG channels
% % 4. set spatial filter clab property
% % 5. set any eye detection
% % 6. set any EEG artifcat detection
% % 7. set phase target
% % 8. set phase tolerance
% % 9. set iti
% % 10. disarm the device
% % 11. run it in the loop for required no of trials (or there shuld be some infinite)

making_this_change='intentional'

totaltrials=20;
phase_target=0; %0 for peak, pi for trough
phase_plusminus=pi/50;
iti=4;
port=1; % that from which TTL out port the trigger is going to be send out
marker=1; % probably this marker is also sent out to the neurone data, this can be an 8bit marker about the stim parm
random_delay_range=0;

%% initiliaze dbsp
rtcls = dbsp('10.10.10.1');


%% read channel labels from neurone xml and set spatial_filter_clab property
clab = neurone_digitalout_clab_from_xml(xmlread('MUSEP MOTOS Layout.xml'));
clab = clab(1:64); % remove EMG channels
clab{65} = 'FCz';
rtcls.spatial_filter_clab = clab;


rtcls.calibration_mode = 'no';
rtcls.armed = 'no';


% eye blink detection
dbsp_set_eye_artifact_detection(rtcls.tg, neurone_digitalout_clab_from_xml(xmlread('MUSEP MOTOS Layout.xml')), 1:64, {'F7', 'F8', 'Fp1', 'Fp2', 'T7', 'T8'}, [1 0 -1 0 0 0; 0 1 0 -1 0 0; 1 0 0 -1 0 0; 0 1 -1 0 0 0; 0 0 0 0 0 0; 0 0 0 0 0 0])
setparam(rtcls.tg, 'QLY', 'eye_artifact_threshold', 1e6)


% set spatial filter, look into this that why do it ned two seperate lines 
set_spatial_filter(rtcls, {'F3', 'AF7', 'AFp1', 'FC5', 'FC1'}, [1 -0.25 -0.25 -0.25 -0.25], 1)
set_spatial_filter(rtcls, {}, [], 2)

%% Set EEG artifact threshold
eeg_artifact_threshold = 90
setparam(rtcls.tg, 'QLY', 'eeg_artifact_threshold', [eeg_artifact_threshold eeg_artifact_threshold])




%% main loop executes here

trial=0;

while (trial<=totaltrials)
    
    if(strcmp(rtcls.armed, 'no'))
        rtcls.triggers_remaining = 1;
        rtcls.alpha.phase_target(1) = phase_target;
        rtcls.alpha.phase_plusminus(1) = phase_plusminus;
        rtcls.configure_time_port_marker([random_delay_range, port, marker])
        rtcls.min_inter_trig_interval = iti;    
        pause(0.1)
        rtcls.arm;
    end
    
    
     if(rtcls.triggers_remaining == 0)
        trial=trial+1;
        rtcls.disarm;
    end
    
    pause(0.01);
    
    
end
   






