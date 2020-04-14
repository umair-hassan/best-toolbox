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
start(sc);
activeScope = 1;
mAmplitudeScopeCircBufTotalBlocks = amplitude_assignment_period;
mAmplitudeScopeCircBufCurrentBlock = 1;
mAmplitudeScopeCircBuf = [];
trigger(sc(activeScope));

%% Controlling BOSS Device for mu Alpha Phase Locked Triggering
if (strcmp(sc(activeScope).Status, 'Finished') || strcmp(sc(activeScope).Status, 'Interrupted'))
    data = sc(activeScope).Data;
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
    circular_buffer_data = cell2mat(mAmplitudeScopeCircBuf);
    % Switch to the next data block
    if(mAmplitudeScopeCircBufCurrentBlock < mAmplitudeScopeCircBufTotalBlocks)
        mAmplitudeScopeCircBufCurrentBlock = mAmplitudeScopeCircBufCurrentBlock + 1;
    else
        mAmplitudeScopeCircBufCurrentBlock = 1;
    end
    % remove post-stimulus data
    amplitude_clean = circular_buffer_data(1, circular_buffer_data(2,:) == 1);
    % calculate percentiles
    amp_lower = quantile(amplitude_clean, amplitude_threshold(1)/100); % TODO: INCLUDE THIS IN INFO STRUCT
    amp_upper = quantile(amplitude_clean, amplitude_threshold(2)/100); % TODO: INCLUDE THIS IN INFO STRUCT
    % set amplitude threshold
    bd.alpha.amplitude_min(1)=amp_lower;
    bd.alpha.amplitude_max(1)=amp_upper;
end % handle the amplitude tracking