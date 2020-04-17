%% Summary
% This demo script uses BOSS Device to track Ossciliation Amplitude & Phase and Triggers Single Pulses on a defined Amplitude range and Phase
% Resources:   1) BOSS Device Switched On
%              2) BOSS Device Open Source MATLAB API
%              3) Biosignal Amplifier streaming atleast 5 EEG Channels
% Press Ctrl+C on MATLAB command line to stop the script anytime

%% Initializing Demo Script Variables;
no_of_trials=25;
minimium_inter_trigger_interval=4; %s
phase=0; %[positive]
phase_tolerance=pi/40;
amplitude_threshold=[75 95;5 25]; %[min max] in percentile
atcond=1;
amplitude_assignment_period=30; %s
individual_peak_frequency=11; % Hz
bandpassfilter_order= 75;
eeg_channels=1; %Assigning Number of channels as equivalent to Num of Channels streamed by Biosignal Processor
spatial_filter_weights=[1]'; %Column Vector of Spatial Filter Indexed wrt corrosponding Channels
time=0;
plasticity_protocol_sequence=[];

%% Initializing BOSS Device API
bd=bossdevice;
bd.sample_and_hold_period=0;
bd.calibration_mode = 'no';
bd.armed = 'no';
bd.sample_and_hold_period=0;
bd.theta.ignore; pause(0.1)
bd.beta.ignore; pause(0.1)
bd.alpha.ignore; pause(0.1)
bd.eeg_channels=eeg_channels;

%% Preparing an Individual Peak Frequency based Band Pass Filter for mu Alpha
bpf_fir_coeffs = firls(bandpassfilter_order, [0 (individual_peak_frequency + [-5 -2 +2 +5]) (500/2)]/(500/2), [0 0 1 1 0 0], [1 1 1] );

%% Setting Filters on BOSS Device
bd.spatial_filter_weights=spatial_filter_weights;
bd.alpha.bpf_fir_coeffs = bpf_fir_coeffs;

%% Configuring Real-Time Scopes for Amplitude Tracking
AMP_TRACING_SCOPES_IDS = [101 102];

% remove any pre-existing scopes with these ids
for id = AMP_TRACING_SCOPES_IDS
    if(find(bd.tg.Scopes == id))
        fprintf('\nRemoving scope %i', id)
        remscope(bd.tg, id);
    end
end

sig_id_amp = getsignalid(bd.tg, 'OSC/alpha/IA'); %amplitude
sig_id_qly = getsignalid(bd.tg, 'QLY/Logical Operator2'); %eeg_is_clean

sc = addscope(bd.tg, 'host', AMP_TRACING_SCOPES_IDS);
addsignal(sc, [sig_id_amp sig_id_qly]);

sc(1).NumSamples = 500;
sc(1).Decimation = 10;
sc(1).TriggerSample = -1;

sc(2).NumSamples = 500;
sc(2).Decimation = 10;
sc(2).TriggerSample = -1;

sc(1).TriggerMode = 'Scope';
sc(1).TriggerScope = AMP_TRACING_SCOPES_IDS(2);

sc(2).TriggerMode = 'Scope';
sc(2).TriggerScope = AMP_TRACING_SCOPES_IDS(1);

start(sc); % now they are ready for being triggered

activeScope = 1;
mAmplitudeScopeCircBufTotalBlocks = amplitude_assignment_period;
mAmplitudeScopeCircBufCurrentBlock = 1;
mAmplitudeScopeCircBuf = [];
hAmplitudeHistoryAxes = subplot(1,2,1);
hAmplitudeDistributionAxes = subplot(1,2,2);

trigger(sc(activeScope));

%% Controlling BOSS Device for mu Alpha Phase Locked Triggering
condition_index=0;
while (condition_index <= no_of_trials)
    if (strcmp(sc(activeScope).Status, 'Finished') || ...
            strcmp(sc(activeScope).Status, 'Interrupted'))
        
        time = sc(activeScope).Time;
        data = sc(activeScope).Data;
        plot(hAmplitudeHistoryAxes, time, data(:,1));
        
        fprintf(['Restarting Scope ' num2str(activeScope)]);
        
        % Restart this scope.
        start(sc(activeScope));
        
        % Switch to the next scope.
        if(activeScope == 1)
            activeScope = 2;
        else
            activeScope = 1;
        end
        
        % append data in circular buffer
        mAmplitudeScopeCircBuf{mAmplitudeScopeCircBufCurrentBlock} = data';
        
        maxmindata = cell2mat(cellfun(@(data) quantile(data(1, data(2,:) == 1), [amplitude_threshold(atcond,1)/100 amplitude_threshold(atcond,2)/100])', mAmplitudeScopeCircBuf, 'UniformOutput', false))';
        maxmindata = circshift(maxmindata, mAmplitudeScopeCircBufCurrentBlock);
        plot(hAmplitudeHistoryAxes, maxmindata)
        xlim(hAmplitudeHistoryAxes, [1 mAmplitudeScopeCircBufTotalBlocks])
        set(hAmplitudeHistoryAxes, 'Xdir', 'reverse')
        
        circular_buffer_data = cell2mat(mAmplitudeScopeCircBuf);
        
        % Switch to the next data block
        if(mAmplitudeScopeCircBufCurrentBlock < mAmplitudeScopeCircBufTotalBlocks)
            mAmplitudeScopeCircBufCurrentBlock = mAmplitudeScopeCircBufCurrentBlock + 1;
        else
            mAmplitudeScopeCircBufCurrentBlock = 1;
        end
        
        %tic
        
        % remove post-stimulus data
        amplitude_clean = circular_buffer_data(1, circular_buffer_data(2,:) == 1);
        
        % calculate percentiles
        amplitude_sorted = sort(amplitude_clean);
        plot(hAmplitudeDistributionAxes, amplitude_sorted)
        
        amp_lower = quantile(amplitude_clean, amplitude_threshold(atcond,1)/100); % TODO: INCLUDE THIS IN INFO STRUCT
        amp_upper = quantile(amplitude_clean, amplitude_threshold(atcond,2)/100); % TODO: INCLUDE THIS IN INFO STRUCT
        
        hold(hAmplitudeDistributionAxes, 'on')
        plot(hAmplitudeDistributionAxes, [1 length(amplitude_clean)], [amp_lower amp_upper; amp_lower amp_upper]);
        hold(hAmplitudeDistributionAxes, 'off')
        
        if length(amplitude_clean) > 1
            xlim(hAmplitudeDistributionAxes, [1 length(amplitude_clean)]);
        end
        if (amplitude_sorted(end) > amplitude_sorted(1))
            ylim(hAmplitudeDistributionAxes, [amplitude_sorted(1) amplitude_sorted(end)]);
        end
        
        %toc
        
        % set amplitude threshold
        mDbsp.alpha.amplitude_min(1) = amp_lower;
        mDbsp.alpha.amplitude_max(1) = amp_upper;
        bd.alpha.amplitude_min(1)=amp_lower;
        bd.alpha.amplitude_max(1)=amp_upper;
        title(hAmplitudeDistributionAxes, ['Min Amplitude: ', num2str(amp_lower)]);
        
    end % handle the amplitude tracking
    if(strcmp(bd.armed, 'no'))
        bd.triggers_remaining = 1;
        bd.alpha.phase_target(1) = phase(randi(1:numel(phase), 1));
        atcond=randi(1:numel(amplitude_threshold)/2, 1);
        bd.alpha.phase_plusminus(1) = phase_tolerance;
        bd.configure_time_port_marker(([0, 1, 0]))
        bd.min_inter_trig_interval = minimium_inter_trigger_interval;
        pause(0.1)
        bd.arm;
    end
    % trigger has been executed, move to the next condition
    if(bd.triggers_remaining == 0)
        condition_index = condition_index + 1;
        bd.disarm;
        disp Triggered!
    end
    pause(0.01);
end

%% End