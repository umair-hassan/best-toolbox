classdef best_sync2brain_bossdevice <handle    
    properties
        bb %bossbox API object
        best_toolbox
        EMGScope
        IEEGScope
        IAScope
        IPScope
        FileScope
        EEGScope
    end
    
    methods
        function obj = best_sync2brain_bossdevice(best_toolbox)
            obj.best_toolbox=best_toolbox;
            obj.bb=bossdevice;
            %% Loading defaults
            obj.bb.calibration_mode = 'no';
            obj.bb.armed = 'no';
            obj.bb.sample_and_hold_period=0;
            obj.bb.theta.ignore; pause(0.1)
            obj.bb.beta.ignore; pause(0.1)
            obj.bb.alpha.ignore; pause(0.1)
            %% Setting Num of EEG & AUX Channels
            % these depends on Protocol for NeurOne, for ACS we can particularly ask the user to define Num of Aux and EEG Channels being streamed
            InputDevice=obj.best_toolbox.inputs.condMat{1,obj.best_toolbox.inputs.colLabel.inputDevices};
            if obj.best_toolbox.app.par.hardware_settings.(InputDevice).slct_device==1
                obj.bb.eeg_channels=nnz(strcmp(obj.best_toolbox.app.par.hardware_settings.(InputDevice).NeurOneProtocolChannelSignalTypes,'EEG'));
                obj.bb.aux_channels=nnz(strcmp(obj.best_toolbox.app.par.hardware_settings.(InputDevice).NeurOneProtocolChannelSignalTypes,'EMG'));
            end
            %% Setting Brain State Dependent Defaults 
            if(obj.best_toolbox.inputs.BrainState==2)                
                %% Preparing Spatial Filter Weights for BOSS Device
                if obj.best_toolbox.app.par.hardware_settings.(InputDevice).slct_device==1 || obj.best_toolbox.app.par.hardware_settings.(InputDevice).slct_device==6 %%NeurOneOnly OR NeurOnewithKeyboard
                    SpatialFilterWeights=zeros(obj.bb.eeg_channels,1);
                    MontageChannelsIndicies(1,numel(obj.best_toolbox.inputs.MontageChannels))=0;
                    for iMontageChannels=1:numel(obj.best_toolbox.inputs.MontageChannels)
                        MontageChannelsIndicies(iMontageChannels)=find(strcmp(obj.best_toolbox.app.par.hardware_settings.(InputDevice).NeurOneProtocolChannelLabels,obj.best_toolbox.inputs.MontageChannels{iMontageChannels}));
                    end
                    SpatialFilterWeights(MontageChannelsIndicies)=obj.best_toolbox.inputs.MontageWeights;
                end

                %% Setting Spatial Filter
                obj.bb.spatial_filter_weights=SpatialFilterWeights;
                
                %% Setting LowPas Filter Coefficients
                % For Future Use
                
                %% Setting BandPass Filter
                switch obj.best_toolbox.inputs.FrequencyBand
                    case 1 % Alpha
                        obj.bb.alpha.bpf_fir_coeffs =  firls(obj.best_toolbox.inputs.BandPassFilterOrder, [0 (obj.best_toolbox.inputs.PeakFrequency + [-5 -2 +2 +5]) (500/2)]/(500/2), [0 0 1 1 0 0], [1 1 1] );
                    case 2 % Theta
                        obj.bb.theta.bpf_fir_coeffs =  firls(obj.best_toolbox.inputs.BandPassFilterOrder, [0 (obj.best_toolbox.inputs.PeakFrequency + [-2 -1 +1 +2]) (250/2)]/(250/2), [0 0 1 1 0 0], [1 1 1]) ;
                    case 3 % Beta
                        obj.bb.beta.bpf_fir_coeffs =  firls(obj.best_toolbox.inputs.BandPassFilterOrder, [0 (obj.best_toolbox.inputs.PeakFrequency + [-5 -2 +2 +5]) (1000/2)]/(1000/2), [0 0 1 1 0 0], [1 1 1]) ;
                end
            end
            
        end
        
        function singlePulse(obj,portNo)
                obj.bb.sendPulse(portNo)
        end
        
        function multiPulse(obj,time_port_marker_vector)
            obj.bb.configure_time_port_marker(cell2mat(time_port_marker_vector'));
            obj.bb.manualTrigger;
        end
        
        function armPulse(obj)
            %% Choosing 1 from 3x Oscillitory Models, Load Phase, PhasePlusMinus, Amplitude Low and Amplitude High
            switch obj.best_toolbox.inputs.FrequencyBand
                case 1 % Alpha
                    obj.bb.alpha.phase_target(1) =  obj.best_toolbox.inputs.trialMat{obj.best_toolbox.inputs.trial,obj.best_toolbox.inputs.colLabel.phase}{1,1};
                    obj.bb.alpha.phase_plusminus(1) =obj.best_toolbox.inputs.trialMat{obj.best_toolbox.inputs.trial,obj.best_toolbox.inputs.colLabel.phase}{1,2};
                case 2 % Theta
                    obj.bb.theta.phase_target(1) = obj.best_toolbox.inputs.trialMat{obj.best_toolbox.inputs.trial,obj.best_toolbox.inputs.colLabel.phase}{1,1};
                    obj.bb.theta.phase_plusminus(1) = obj.best_toolbox.inputs.trialMat{obj.best_toolbox.inputs.trial,obj.best_toolbox.inputs.colLabel.phase}{1,2};
                case 3 % Beta
                    obj.bb.beta.phase_target(1) = obj.best_toolbox.inputs.trialMat{obj.best_toolbox.inputs.trial,obj.best_toolbox.inputs.colLabel.phase}{1,1};
                    obj.bb.beta.phase_plusminus(1) = obj.best_toolbox.inputs.trialMat{obj.best_toolbox.inputs.trial,obj.best_toolbox.inputs.colLabel.phase}{1,2};
            end
            obj.bb.triggers_remaining = 1;
            %% Configuring Trial's respective Trigger Pattern
            time_port_marker_vector=obj.best_toolbox.inputs.trialMat{obj.best_toolbox.inputs.trial,obj.best_toolbox.inputs.colLabel.tpm};
            obj.bb.configure_time_port_marker(cell2mat(time_port_marker_vector'))
            pause(0.1)
            %% Starting respective Scopes

            obj.IAScopeStart; % not sure if this would be necessary
            
            %% Starting 
            obj.bb.armed 
            obj.bb.triggers_remaining;
            obj.bb.min_inter_trig_interval = 2+rand(1);
            pause(0.1);
            obj.bb.arm;
            obj.bb.armed ;
            exit_flag=0;
%             trigger(obj.FileScope.sc(obj.FileScope.activeScope));
%             while ~(strcmp(obj.FileScope.sc(obj.FileScope.activeScope).Status, 'Finished') || strcmp(obj.FileScope.sc(obj.FileScope.activeScope).Status, 'Interrupted')), pause(0.01), end
            while (exit_flag<1)
                                disp TrialRestarted

                if ~(strcmp(obj.FileScope.sc(obj.FileScope.activeScope).Status, 'Finished') || strcmp(obj.FileScope.sc(obj.FileScope.activeScope).Status, 'Interrupted'))
                    trigger(obj.FileScope.sc(obj.FileScope.activeScope));
                    while ~(strcmp(obj.FileScope.sc(obj.FileScope.activeScope).Status, 'Finished') || strcmp(obj.FileScope.sc(obj.FileScope.activeScope).Status, 'Interrupted')), pause(0.01), end
                end

                    if (strcmp(obj.FileScope.sc(obj.FileScope.activeScope).Status, 'Finished') || strcmp(obj.FileScope.sc(obj.FileScope.activeScope).Status, 'Interrupted'))
                        disp --------------------------
                        time = obj.FileScope.sc(obj.FileScope.activeScope).Time;
                        data = obj.FileScope.sc(obj.FileScope.activeScope).Data;
                        plot(obj.FileScope.hAmplitudeHistoryAxes,time, data(:,1));
                        % Restart this scope.
                        start(obj.FileScope.sc(obj.FileScope.activeScope));
                        % Switch to the next scope.
                        if(obj.FileScope.activeScope == 1)
                            obj.FileScope.activeScope = 2;
                        else
                            obj.FileScope.activeScope = 1;
                        end
                        % append data in circular buffer
                        obj.FileScope.mAmplitudeScopeCircBuf{obj.FileScope.mAmplitudeScopeCircBufCurrentBlock} = data';
                        
                        if obj.best_toolbox.inputs.AmplitudeUnits==1
                            obj.FileScope.maxmindata = cell2mat(cellfun(@(data) quantile(data(1, data(2,:) == 1), [obj.best_toolbox.inputs.trialMat{obj.best_toolbox.inputs.trial,obj.best_toolbox.inputs.colLabel.IAPercentile}{1,1}/100 obj.best_toolbox.inputs.trialMat{obj.best_toolbox.inputs.trial,obj.best_toolbox.inputs.colLabel.IAPercentile}{1,2}/100])', obj.FileScope.mAmplitudeScopeCircBuf, 'UniformOutput', false))';
                        elseif obj.best_toolbox.inputs.AmplitudeUnits==2
                            obj.FileScope.maxmindata = cell2mat(cellfun(@(data) quantile(data(1, data(2,:) == 1), [0.01 0.99])', obj.FileScope.mAmplitudeScopeCircBuf, 'UniformOutput', false))';
                        end
                        obj.FileScope.maxmindata = circshift(obj.FileScope.maxmindata, obj.FileScope.mAmplitudeScopeCircBufCurrentBlock);
                        plot(obj.FileScope.hAmplitudeHistoryAxes, obj.FileScope.maxmindata)
                        xlim(obj.FileScope.hAmplitudeHistoryAxes, [1 obj.FileScope.mAmplitudeScopeCircBufTotalBlocks])
                        set(obj.FileScope.hAmplitudeHistoryAxes, 'Xdir', 'reverse')
% %                         xlabel(['Data for Past ' num2str(obj.best_toolbox.inputs.AmplitudeAssignmentPeriod) ' mins']);
% %                         ylabel('EEG Quantile Amplitude (\mu V)');
% %                         xticks([]); xticklabels([]);
% %                         drawnow;
                        
                        
                        obj.FileScope.circular_buffer_data = cell2mat(obj.FileScope.mAmplitudeScopeCircBuf);
                        % Switch to the next data block
                        if(obj.FileScope.mAmplitudeScopeCircBufCurrentBlock < obj.FileScope.mAmplitudeScopeCircBufTotalBlocks)
                            obj.FileScope.mAmplitudeScopeCircBufCurrentBlock = obj.FileScope.mAmplitudeScopeCircBufCurrentBlock + 1;
                        else
                            obj.FileScope.mAmplitudeScopeCircBufCurrentBlock = 1;
                        end
                        % remove post-stimulus data
                        obj.FileScope.amplitude_clean = obj.FileScope.circular_buffer_data(1, obj.FileScope.circular_buffer_data(2,:) == 1);
                        
                        obj.FileScope.amplitude_sorted = sort(obj.FileScope.amplitude_clean);
                        plot(obj.FileScope.hAmplitudeDistributionAxes, obj.FileScope.amplitude_sorted)
% %                         ylabel('Amplitude (microV)');
% %                         xticks([]); xticklabels([]);

                        
                        % calculate percentiles
                        if obj.best_toolbox.inputs.AmplitudeUnits==1
                            obj.FileScope.amp_lower= quantile(obj.FileScope.amplitude_clean, obj.best_toolbox.inputs.trialMat{obj.best_toolbox.inputs.trial,obj.best_toolbox.inputs.colLabel.IAPercentile}{1,1}/100);
                            obj.FileScope.amp_upper = quantile(obj.FileScope.amplitude_clean, obj.best_toolbox.inputs.trialMat{obj.best_toolbox.inputs.trial,obj.best_toolbox.inputs.colLabel.IAPercentile}{1,2}/100);
                            obj.best_toolbox.inputs.trialMat{obj.best_toolbox.inputs.trial,obj.best_toolbox.inputs.colLabel.IA}{1,1}= obj.FileScope.amp_lower;
                            obj.best_toolbox.inputs.trialMat{obj.best_toolbox.inputs.trial,obj.best_toolbox.inputs.colLabel.IA}{1,2} = obj.FileScope.amp_upper;
                        elseif obj.best_toolbox.inputs.AmplitudeUnits==2
                            obj.FileScope.amp_lower=  obj.best_toolbox.inputs.trialMat{obj.best_toolbox.inputs.trial,obj.best_toolbox.inputs.colLabel.IA}{1,1};
                            obj.FileScope.amp_upper =  obj.best_toolbox.inputs.trialMat{obj.best_toolbox.inputs.trial,obj.best_toolbox.inputs.colLabel.IA}{1,2};
                        end
                        
                        hold(obj.FileScope.hAmplitudeDistributionAxes, 'on')
                        plot(obj.FileScope.hAmplitudeDistributionAxes, [1 length(obj.FileScope.amplitude_clean)], [obj.FileScope.amp_lower obj.FileScope.amp_upper; obj.FileScope.amp_lower obj.FileScope.amp_upper]);
                        hold(obj.FileScope.hAmplitudeDistributionAxes, 'off')
                        
                        if length(obj.FileScope.amplitude_clean) > 1
                            xlim(obj.FileScope.hAmplitudeDistributionAxes, [1 length(obj.FileScope.amplitude_clean)]);
                        end
                        if (obj.FileScope.amplitude_sorted(end) > obj.FileScope.amplitude_sorted(1))
                            ylim(obj.FileScope.hAmplitudeDistributionAxes, [obj.FileScope.amplitude_sorted(1) obj.FileScope.amplitude_sorted(end)]);
                        end
                        
                        % set amplitude threshold
                        switch obj.best_toolbox.inputs.FrequencyBand
                            case 1 % Alpha
                                obj.bb.alpha.amplitude_min(1)=obj.best_toolbox.inputs.trialMat{obj.best_toolbox.inputs.trial,obj.best_toolbox.inputs.colLabel.IA}{1,1};
                                obj.bb.alpha.amplitude_max(1)=obj.best_toolbox.inputs.trialMat{obj.best_toolbox.inputs.trial,obj.best_toolbox.inputs.colLabel.IA}{1,2};
                            case 2 % Theta
                                obj.bb.theta.amplitude_min(1)=obj.best_toolbox.inputs.trialMat{obj.best_toolbox.inputs.trial,obj.best_toolbox.inputs.colLabel.IA}{1,1};
                                obj.bb.theta.amplitude_max(1)=obj.best_toolbox.inputs.trialMat{obj.best_toolbox.inputs.trial,obj.best_toolbox.inputs.colLabel.IA}{1,2};
                            case 3 % Beta
                                obj.bb.beta.amplitude_min(1)=obj.best_toolbox.inputs.trialMat{obj.best_toolbox.inputs.trial,obj.best_toolbox.inputs.colLabel.IA}{1,1};
                                obj.bb.beta.amplitude_max(1)=obj.best_toolbox.inputs.trialMat{obj.best_toolbox.inputs.trial,obj.best_toolbox.inputs.colLabel.IA}{1,2};
                        end
                        title(obj.FileScope.hAmplitudeDistributionAxes, ['Amplitude(Min Max): [', num2str(obj.FileScope.amp_lower) '  ' num2str(obj.FileScope.amp_upper) ']']);
                    end % handle the amplitude tracking

                
                if(obj.bb.triggers_remaining == 0)
                    obj.bb.disarm;
                    exit_flag=2;
                end
                
                
                pause(0.01);
            end
        end
        
        function EMGScopeBoot(obj,EMGDisplayPeriodPre,EMGDisplayPeriodPost)
            disp enteredEMGScopeboot
            NumSamples=round((EMGDisplayPeriodPost+EMGDisplayPeriodPre)*5);
            NumPrePostSamples=round(EMGDisplayPeriodPre*5);
            obj.EMGScope = addscope(obj.bb.tg, 'host', 90);
            AuxSignalID = getsignalid(obj.bb.tg, 'UDP/raw_aux') + int32(0:7);  
            MrkSignalID = getsignalid(obj.bb.tg, 'MRK/mrk_masked');
            addsignal(obj.EMGScope, AuxSignalID);
            obj.EMGScope.NumSamples = NumSamples;
            obj.EMGScope.NumPrePostSamples = -NumPrePostSamples;
            obj.EMGScope.Decimation = 1;
            obj.EMGScope.TriggerMode = 'Signal';
            obj.EMGScope.TriggerSignal = getsignalid(obj.bb.tg, 'gen_running'); %Remove it in Official Use
            % obj.EMGScope.TriggerSignal = MrkSignalID; % 31-May-2020 10:36:22
            obj.EMGScope.TriggerLevel = 0.5;
            obj.EMGScope.TriggerSlope = 'Rising';
            obj.best_toolbox.FilterCoefficients.HumNoiseNotchFilter=designfilt('bandstopiir','FilterOrder',2,'HalfPowerFrequency1',39,'HalfPowerFrequency2',61,'DesignMethod','butter','SampleRate',NumSamples);
            %% Starting Scope
            obj.EMGScopeStart;
        end
        
        function IEEGScopeBoot(obj)
            MrkSignalID = getsignalid(obj.bb.tg, 'MRK/mrk_masked');
            IPSignalID = getsignalid(obj.bb.tg, 'SPF/Matrix Multiply');
            NumSamples=round((obj.best_toolbox.inputs.EEGDisplayPeriodPost+obj.best_toolbox.inputs.EEGDisplayPeriodPre)*5);
            NumPrePostSamples=round(obj.best_toolbox.inputs.EEGDisplayPeriodPre*5);
            Decimation=1;
            obj.IEEGScope = addscope(obj.bb.tg, 'host', 92);
            addsignal(obj.IEEGScope, IPSignalID);
            % If 100 samples are extracted there will be a data of 400ms for Theta, 200ms for Alpha and 100ms for Beta
            obj.IEEGScope.NumSamples = NumSamples;
            obj.IEEGScope.NumPrePostSamples = NumPrePostSamples;
            obj.IEEGScope.Decimation = Decimation;
            obj.IEEGScope.TriggerMode = 'Signal';
            obj.IEEGScope.TriggerSignal = getsignalid(obj.bb.tg, 'gen_running'); %Remove it in Official Use
            obj.IEEGScope.TriggerSignal = MrkSignalID; % 31-May-2020 11:05:43
            obj.IEEGScope.TriggerLevel = 0.5;
            obj.IEEGScope.TriggerSlope = 'Rising';
            obj.best_toolbox.inputs.rawData.IEEG.time=linspace(-1*(obj.best_toolbox.inputs.EEGDisplayPeriodPre),obj.best_toolbox.inputs.EEGDisplayPeriodPost,NumSamples);
            %% Starting Scope
            obj.IEEGScopeStart;
        end
        
        function IPScopeBoot(obj)
            %% Choosing 1 from 3x Oscillitory Models, Load Phase, PhasePlusMinus, Amplitude Low and Amplitude High
            switch obj.best_toolbox.inputs.FrequencyBand
                case 1 % Alpha
                    IPSignalID = getsignalid(obj.bb.tg, 'OSC/alpha/IP') + int32(0);
                case 2 % Theta
                    IPSignalID = getsignalid(obj.bb.tg, 'OSC/theta/IP') + int32(0);
                case 3 % Beta
                    IPSignalID = getsignalid(obj.bb.tg, 'OSC/beta/IP') + int32(0);
            end
            MrkSignalID = getsignalid(obj.bb.tg, 'MRK/mrk_masked');
            obj.IPScope = addscope(obj.bb.tg, 'host', 91);
            addsignal(obj.IPScope, IPSignalID);
            % If 100 samples are extracted there will be a data of 400ms for Theta, 200ms for Alpha and 100ms for Beta
            obj.IPScope.NumSamples = 100;
            obj.IPScope.NumPrePostSamples = -99;
            obj.IPScope.Decimation = 1;
            obj.IPScope.TriggerMode = 'Signal';
            obj.IPScope.TriggerSignal = getsignalid(obj.bb.tg, 'gen_running'); %Remove it in Official Use
%             obj.IPScope.TriggerSignal = MrkSignalID; 
            obj.IPScope.TriggerLevel = 0.5;
            obj.IPScope.TriggerSlope = 'Rising';
            %% Starting Scope
            obj.IPScopeStart;
        end
        
        function IAScopeBoot(obj)
            %% Configuring Real-Time Scopes for Amplitude Tracking
            AMP_TRACING_SCOPES_IDS = [93 94];
            
            % remove any pre-existing scopes with these ids
            for id = AMP_TRACING_SCOPES_IDS
                if(find(obj.bb.tg.Scopes == id))
                    remscope(obj.bb.tg, id);
                end
            end
            switch obj.best_toolbox.inputs.FrequencyBand
                case 1 % Alpha
                    obj.FileScope.sig_id_amp = getsignalid(obj.bb.tg, 'OSC/alpha/IA'); %amplitude
                    obj.FileScope.sig_id_qly = getsignalid(obj.bb.tg, 'QLY/Logical Operator2'); %eeg_is_clean
                    
                    obj.FileScope.sc = addscope(obj.bb.tg, 'host', AMP_TRACING_SCOPES_IDS);
                    addsignal(obj.FileScope.sc, [obj.FileScope.sig_id_amp obj.FileScope.sig_id_qly]);
                    
                    obj.FileScope.sc(1).NumSamples = 500;
                    obj.FileScope.sc(1).Decimation = 10;
                    obj.FileScope.sc(1).TriggerSample = -1;
                    
                    obj.FileScope.sc(2).NumSamples = 500;
                    obj.FileScope.sc(2).Decimation = 10;
                    obj.FileScope.sc(2).TriggerSample = -1;
                    
                    obj.FileScope.sc(1).TriggerMode = 'Scope';
                    obj.FileScope.sc(1).TriggerScope = AMP_TRACING_SCOPES_IDS(2);
                    
                    obj.FileScope.sc(2).TriggerMode = 'Scope';
                    obj.FileScope.sc(2).TriggerScope = AMP_TRACING_SCOPES_IDS(1);
                case 2 % Theta
                    obj.FileScope.sig_id_amp = getsignalid(obj.bb.tg, 'OSC/theta/IA'); %amplitude
                    obj.FileScope.sig_id_qly = getsignalid(obj.bb.tg, 'QLY/Logical Operator2'); %eeg_is_clean
                    
                    obj.FileScope.sc = addscope(obj.bb.tg, 'host', AMP_TRACING_SCOPES_IDS);
                    addsignal(sc, [obj.FileScope.sig_id_amp obj.FileScope.sig_id_qly]);
                    
                    obj.FileScope.sc(1).NumSamples = 250;
                    obj.FileScope.sc(1).Decimation = 20;
                    obj.FileScope.sc(1).TriggerSample = -1;
                    
                    obj.FileScope.sc(2).NumSamples = 250;
                    obj.FileScope.sc(2).Decimation = 20;
                    obj.FileScope.sc(2).TriggerSample = -1;
                    
                    obj.FileScope.sc(1).TriggerMode = 'Scope';
                    obj.FileScope.sc(1).TriggerScope = AMP_TRACING_SCOPES_IDS(2);
                    
                    obj.FileScope.sc(2).TriggerMode = 'Scope';
                    obj.FileScope.sc(2).TriggerScope = AMP_TRACING_SCOPES_IDS(1);
                case 3 % Beta
                    obj.FileScope.sig_id_amp = getsignalid(obj.bb.tg, 'OSC/beta/IA'); %amplitude
                    obj.FileScope.sig_id_qly = getsignalid(obj.bb.tg, 'QLY/Logical Operator2'); %eeg_is_clean
                    
                    obj.FileScope.sc = addscope(obj.bb.tg, 'host', AMP_TRACING_SCOPES_IDS);
                    addsignal(sc, [obj.FileScope.sig_id_amp obj.FileScope.sig_id_qly]);
                    
                    obj.FileScope.sc(1).NumSamples = 1000;
                    obj.FileScope.sc(1).Decimation = 5;
                    obj.FileScope.sc(1).TriggerSample = -1;
                    
                    obj.FileScope.sc(2).NumSamples = 1000;
                    obj.FileScope.sc(2).Decimation = 5;
                    obj.FileScope.sc(2).TriggerSample = -1;
                    
                    obj.FileScope.sc(1).TriggerMode = 'Scope';
                    obj.FileScope.sc(1).TriggerScope = AMP_TRACING_SCOPES_IDS(2);
                    
                    obj.FileScope.sc(2).TriggerMode = 'Scope';
                    obj.FileScope.sc(2).TriggerScope = AMP_TRACING_SCOPES_IDS(1);
            end
            
            start(obj.FileScope.sc);
            
            obj.FileScope.activeScope = 1;
            obj.FileScope.mAmplitudeScopeCircBufTotalBlocks = obj.best_toolbox.inputs.AmplitudeAssignmentPeriod*60; %Conversion from Minutes into Seconds
            obj.FileScope.mAmplitudeScopeCircBufCurrentBlock = 1;
            obj.FileScope.mAmplitudeScopeCircBuf = [];
            % Exception Handling Only for the case when Plots are not required 05.05.2020
            if any(ismember(obj.best_toolbox.app.pr.ax_ChannelLabels,'OsscillationAmplitude'))
                axOsscillationAmplitude=['ax' num2str(find(contains(obj.best_toolbox.app.pr.ax_ChannelLabels,'OsscillationAmplitude')))];
                axAmplitudeDistribution=['ax' num2str(find(contains(obj.best_toolbox.app.pr.ax_ChannelLabels,'AmplitudeDistribution')))];
                obj.FileScope.hAmplitudeHistoryAxes = obj.best_toolbox.app.pr.ax.(axOsscillationAmplitude);
                obj.FileScope.hAmplitudeDistributionAxes = obj.best_toolbox.app.pr.ax.(axAmplitudeDistribution);
            else
                disp ('The Oscillation Amplitude Tracking and Distribution plots have been switched off');
                obj.FileScope.hAmplitudeHistoryAxes = axes('Visible','off');
                obj.FileScope.hAmplitudeDistributionAxes = axes('Visible','off');
            end
            axes(obj.FileScope.hAmplitudeHistoryAxes);
            %Future Use: xlabel(['Data for Past ' num2str(obj.best_toolbox.inputs.AmplitudeAssignmentPeriod) ' mins']);
            %Future Use: ylabel('EEG Quantile Amplitude (\mu V)');
            %Future Use: xticks([]); xticklabels([]);
            axes(obj.FileScope.hAmplitudeHistoryAxes);
            %Future Use: ylabel('Amplitude (microV)');
            %Future Use: xticks([]); xticklabels([]);
        end
        
        function EEGScopeBoot(obj,EEGDisplayPeriodPre,EEGDisplayPeriodPost)
            % ArgIn EEGDisplayPeriodPre is ms
            % ArgIn EEGDisplayPeriodPost is ms
            NumSamples=round((EEGDisplayPeriodPost+EEGDisplayPeriodPre*(-1))*5); %Maximum Limit is of 1020000 Samples imposed by Simulink Real Time
            NumPrePostSamples=round(EEGDisplayPeriodPre*5);
            obj.EEGScope = addscope(obj.bb.tg, 'host', 95);
            AuxSignalID = getsignalid(obj.bb.tg, 'UDP/raw_eeg') + int32(0:obj.bb.eeg_channels-1);
            MrkSignalID = getsignalid(obj.bb.tg, 'MRK/mrk_masked');
            addsignal(obj.EEGScope, AuxSignalID);
            obj.EEGScope.NumSamples = NumSamples;
            obj.EEGScope.NumPrePostSamples = NumPrePostSamples;
            obj.EEGScope.Decimation = 1;
            obj.EEGScope.TriggerMode = 'Signal';
            obj.EEGScope.TriggerSignal = getsignalid(obj.bb.tg, 'gen_running'); %Remove it in Official Usee
            obj.EEGScope.TriggerSignal = MrkSignalID;
            obj.EEGScope.TriggerLevel = 0.5;
            obj.EEGScope.TriggerSlope = 'Rising';
            %% Starting Scope
            obj.EEGScopeStart;
        end
        
        function EMGScopeStart(obj)
            start(obj.EMGScope);
%             pause(0.1); % give the scope time to pre-aquire
            while ~strcmpi(obj.EMGScope.Status,'Ready for being Triggered'), end
%             assert(strcmp(obj.EMGScope.Status, 'Ready for being Triggered'));
        end
        
        function IEEGScopeStart(obj)
            start(obj.IEEGScope);
             while ~strcmpi(obj.IEEGScope.Status,'Ready for being Triggered'), end
        end
        
        function IPScopeStart(obj)
             start(obj.IPScope);
             while ~strcmpi(obj.IPScope.Status,'Ready for being Triggered'), end
        end
        
        function EEGScopeStart(obj)
             start(obj.EEGScope);
             while ~strcmpi(obj.EEGScope.Status,'Ready for being Triggered'), disp('EEG Scope is started'); drawnow, end
        end
        
        function IAScopeStart(obj)
            %This has to be done inside armed loop therefore empty but just required as a Place holder for consistency of Architecture and may be used in future
        end
        function [Time, Data] = EMGScopeRead(obj,Channel)
            while ~strcmpi(obj.EMGScope.Status,'finished'), end
            Data=obj.EMGScope.Data(:,Channel)';
            Time=(obj.EMGScope.Time-obj.EMGScope.Time(1)+(obj.EMGScope.Time(2)-obj.EMGScope.Time(1)))';
            Time=(Time*1000)+obj.best_toolbox.inputs.EMGDisplayPeriodPre*(-1);
            if(obj.best_toolbox.inputs.EMGDisplayPeriodPre>0)
                cfg=[];
                ftdata.label={'ch1'};
                ftdata.fsample=5000;
                ftdata.trial{1}=Data;
                ftdata.time{1}=Time;
                cfg.demean='yes';
                cfg.detrend='yes';
                cfg.baselinewindow=[obj.best_toolbox.inputs.EMGDisplayPeriodPre*(-1)/1000 -10]; %[EMGDisplayPeriodPre_ms to -10ms]
                ProcessedData=ft_preprocessing(cfg, ftdata);
                Data=ProcessedData.trial{1};
                Time=ProcessedData.time{1};
            end
        end
        function Data = IPScopeRead(obj)
            while ~strcmpi(obj.IPScope.Status,'finished'), end
            Data=obj.IPScope.Data(end,1);
            obj.IPScopeStart;
        end
        function Data = IEEGScopeRead(obj)
            while ~strcmpi(obj.IEEGScope.Status,'finished'), end
            Data=obj.IEEGScope.Data(:,1)';
            obj.IEEGScopeStart;
        end
        function [Time, Data]=EEGScopeRead(obj)
            Time=0; Data=0;
            obj.EEGScope.Status,  trigger(obj.EEGScope); obj.EEGScope.Status, 
            while ~strcmpi(obj.EEGScope.Status,'finished') ,drawnow, if obj.best_toolbox.inputs.stop_event==1, break, end ,end
            if obj.best_toolbox.inputs.stop_event==1, return, end
            Data=obj.EEGScope.Data';
            Time=(obj.EEGScope.Time-obj.EEGScope.Time(1)+(obj.EEGScope.Time(2)-obj.EEGScope.Time(1)))';
            if ~strcmpi(obj.best_toolbox.inputs.Protocol,'rs EEG Measurement Protocol')
                Time=(Time*1000)+obj.best_toolbox.inputs.EEGDisplayPeriod(1);
            end
            obj.EEGScopeStart;
        end
        
        function EEGScopeTrigger(obj)
            trigger(obj.EEGScope);
        end
        
        function stop(obj)
            obj.bb.stop;
            stop([obj.EMGScope obj.IEEGScope obj.IAScope obj.IPScope obj. EEGScope]);
        end
        
    end
end

