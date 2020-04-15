classdef best_sync2brain_bossdevice <handle

    
    properties
        bb %bossbox API object
        best_toolbox
        EMGScope
        IEEGScope
        IAScope
        IPScope
        FileScope
    end
    
    methods
        function obj = best_sync2brain_bossdevice(best_toolbox)
            obj.best_toolbox=best_toolbox;
            obj.bb=dbsp('10.10.10.1');
            obj.bb.sample_and_hold_period=0;
            
            %% Set Number of EEG and AUX Channels Property 
            % to be done later
            
            if(obj.best_toolbox.inputs.BrainState==2)
                %% Loading defaults
                obj.bb.calibration_mode = 'no';
                obj.bb.armed = 'no';
                obj.bb.sample_and_hold_period=0;
                obj.bb.theta.ignore; pause(0.1)
                obj.bb.beta.ignore; pause(0.1)
                obj.bb.alpha.ignore; pause(0.1)
                
                %% Providing Channel Labels to Spatial Filter
                outputdevice=obj.best_toolbox.inputs.condMat{1,1};
%                 clab=obj.best_toolbox.app.par.hardware_settings.(outputdevice).NeurOneProtocolChannelLabels;
%                 clab = clab(1:64); % remove AUX Channels 
%                 clab{65} = 'FCz';
%                 obj.bb.spatial_filter_clab = clab;

                
                %% Setting Spatial Filter
                % set a spatial filter to C3 hjorth
%                 set_spatial_filter(obj.bb, obj.best_toolbox.inputs.MontageChannels, obj.best_toolbox.inputs.MontageWeights, 1)
% % %                 set_spatial_filter(obj.bb, {'C3', 'FC1', 'FC5', 'CP1', 'CP5'}, [1 -0.25 -0.25 -0.25 -0.25], 1)
%                 set_spatial_filter(obj.bb, {}, [], 2)
                obj.bb.spatial_filter_weights([1])

            end
            
        end
        
        function singlePulse(obj,portNo)
                obj.bb.sendPulse(portNo)
                pause(0.1)
% while ~strcmpi(sc.Status,'finished'), end;
% assert(strcmp(obj.EMGScope.Status, 'Finished'))
while ~strcmpi(obj.EMGScope.Status,'finished'), end
%             obj.bb.configure_time_port_marker([0 1 1]);
%             obj.bb.manualTrigger;
        end
        
        function multiPulse(obj,time_port_marker_vector)
            obj.EMGScopeStart;
            obj.bb.configure_time_port_marker(cell2mat(time_port_marker_vector'));
            obj.bb.manualTrigger;
            while ~strcmpi(obj.EMGScope.Status,'finished'), end
        end
        
        function armPulse(obj)
            %% Findling IA Low and High Cutoff Values
            % 
            %% Choosing 1 from 3x Oscillitory Models, Load Phase, PhasePlusMinus, Amplitude Low and Amplitude High
            switch obj.best_toolbox.inputs.FrequencyBand
                case 1 % Alpha
%                     obj.best_toolbox.inputs.trialMat{obj.best_toolbox.inputs.trial,obj.best_toolbox.inputs.colLabel.tpm}
                    obj.bb.alpha.phase_target(1) =  obj.best_toolbox.inputs.trialMat{obj.best_toolbox.inputs.trial,obj.best_toolbox.inputs.colLabel.phase}{1,1};
                    obj.bb.alpha.phase_plusminus(1) =obj.best_toolbox.inputs.trialMat{obj.best_toolbox.inputs.trial,obj.best_toolbox.inputs.colLabel.phase}{1,2};
                    if obj.best_toolbox.inputs.AmplitudeUnits==2
                        obj.bb.alpha.amplitude_min(1)=obj.best_toolbox.inputs.trialMat{obj.best_toolbox.inputs.trial,obj.best_toolbox.inputs.colLabel.IA}{1,1};
                        obj.bb.alpha.amplitude_max(1)=obj.best_toolbox.inputs.trialMat{obj.best_toolbox.inputs.trial,obj.best_toolbox.inputs.colLabel.IA}{1,2};
                    end
                case 2 % Theta
                    obj.bb.theta.phase_target(1) = obj.best_toolbox.inputs.trialMat{obj.best_toolbox.inputs.trial,obj.best_toolbox.inputs.colLabel.phase}{1,1};
                    obj.bb.theta.phase_plusminus(1) = obj.best_toolbox.inputs.trialMat{obj.best_toolbox.inputs.trial,obj.best_toolbox.inputs.colLabel.phase}{1,2};
                    if obj.best_toolbox.inputs.AmplitudeUnits==2
                        obj.bb.theta.amplitude_min(1)=obj.best_toolbox.inputs.trialMat{obj.best_toolbox.inputs.trial,obj.best_toolbox.inputs.colLabel.IA}{1,1};
                        obj.bb.theta.amplitude_max(1)=obj.best_toolbox.inputs.trialMat{obj.best_toolbox.inputs.trial,obj.best_toolbox.inputs.colLabel.IA}{1,2};
                    end
                case 3 % Beta
                    obj.bb.beta.phase_target(1) = obj.best_toolbox.inputs.trialMat{obj.best_toolbox.inputs.trial,obj.best_toolbox.inputs.colLabel.phase}{1,1};
                    obj.bb.beta.phase_plusminus(1) = obj.best_toolbox.inputs.trialMat{obj.best_toolbox.inputs.trial,obj.best_toolbox.inputs.colLabel.phase}{1,2};
                    if obj.best_toolbox.inputs.AmplitudeUnits==2
                        obj.bb.beta.amplitude_min(1)=obj.best_toolbox.inputs.trialMat{obj.best_toolbox.inputs.trial,obj.best_toolbox.inputs.colLabel.IA}{1,1};
                        obj.bb.beta.amplitude_max(1)=obj.best_toolbox.inputs.trialMat{obj.best_toolbox.inputs.trial,obj.best_toolbox.inputs.colLabel.IA}{1,2};
                    end
            end
            obj.bb.triggers_remaining = 1;
            %% Configuring Trial's respective Trigger Pattern
            time_port_marker_vector=obj.best_toolbox.inputs.trialMat{obj.best_toolbox.inputs.trial,obj.best_toolbox.inputs.colLabel.tpm};
            obj.bb.configure_time_port_marker(cell2mat(time_port_marker_vector'))
            pause(0.1)
            %% Starting respective Scopes
            obj.EMGScopeStart;
            obj.IEEGScopeStart;
            obj.IPScopeStart;
            obj.IAScopeStart; % not sure if this would be necessary
            
            %% Starting 
            obj.bb.armed 
            obj.bb.triggers_remaining;
            obj.bb.min_inter_trig_interval = 2+rand(1);
            pause(0.1);
            obj.bb.arm;
            obj.bb.armed ;
            exit_flag=0;
            while (exit_flag<1)
                if obj.best_toolbox.inputs.AmplitudeUnits==1
                    if (strcmp(obj.FileScope.sc(obj.FileScope.activeScope).Status, 'Finished') || strcmp(obj.FileScope.sc(obj.FileScope.activeScope).Status, 'Interrupted'))
                        data = obj.FileScope.sc(obj.FileScope.activeScope).Data;
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
                        obj.FileScope.circular_buffer_data = cell2mat(obj.FileScope.mAmplitudeScopeCircBuf);
                        % Switch to the next data block
                        if(obj.FileScope.mAmplitudeScopeCircBufCurrentBlock < obj.FileScope.mAmplitudeScopeCircBufTotalBlocks)
                            obj.FileScope.mAmplitudeScopeCircBufCurrentBlock = obj.FileScope.mAmplitudeScopeCircBufCurrentBlock + 1;
                        else
                            obj.FileScope.mAmplitudeScopeCircBufCurrentBlock = 1;
                        end
                        % remove post-stimulus data
                        obj.FileScope.amplitude_clean = obj.FileScope.circular_buffer_data(1, obj.FileScope.circular_buffer_data(2,:) == 1);
                        % calculate percentiles
                        obj.best_toolbox.inputs.trialMat{obj.best_toolbox.inputs.trial,obj.best_toolbox.inputs.colLabel.IA}{1,1}= quantile(obj.FileScope.amplitude_clean, obj.best_toolbox.inputs.trialMat{obj.best_toolbox.inputs.trial,obj.best_toolbox.inputs.colLabel.IA}{1,1}/100); 
                        obj.best_toolbox.inputs.trialMat{obj.best_toolbox.inputs.trial,obj.best_toolbox.inputs.colLabel.IA}{1,2} = quantile(obj.FileScope.amplitude_clean, obj.best_toolbox.inputs.trialMat{obj.best_toolbox.inputs.trial,obj.best_toolbox.inputs.colLabel.IA}{1,2}/100); 
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
                    end % handle the amplitude tracking
                end
                
                if(obj.bb.triggers_remaining == 0)
                    obj.bb.disarm;
                    while ~strcmpi(obj.EMGScope.Status,'finished'), end
                    while ~strcmpi(obj.IPScope.Status,'finished'), end
                    while ~strcmpi(obj.IEEGScope.Status,'finished'), end
                    exit_flag=2;
                end
            end
        end
        
        function EMGScopeBoot(obj,EMGDisplayPeriodPre,EMGDisplayPeriodPost)
            disp enteredEMGScopeboot
            NumSamples=(EMGDisplayPeriodPost+EMGDisplayPeriodPre)*5;
            NumPrePostSamples=EMGDisplayPeriodPre*5;
            obj.EMGScope = addscope(obj.bb.tg, 'host', 90);
            AuxSignalID = getsignalid(obj.bb.tg, 'UDP/raw_aux') + int32(0:8);
            MrkSignalID = getsignalid(obj.bb.tg, 'UDP/raw_mrk') + int32([0 1 2]);
            addsignal(obj.EMGScope, AuxSignalID);
            obj.EMGScope.NumSamples = NumSamples;
            obj.EMGScope.NumPrePostSamples = -NumPrePostSamples;
            obj.EMGScope.Decimation = 1;
            obj.EMGScope.TriggerMode = 'Signal';
            obj.EMGScope.TriggerSignal = getsignalid(obj.bb.tg, 'gen_running'); %Remove it in Official Usee
%             obj.EMGScope.TriggerSignal = MrkSignalID(3); %in Tuebingen setup the 2nd coloumn of signal was giving the return values, however in Mainz setup it was the third coloumn
            obj.EMGScope.TriggerLevel = 0.5;
            obj.EMGScope.TriggerSlope = 'Rising';
            obj.best_toolbox.FilterCoefficients.HumNoiseNotchFilter=designfilt('bandstopiir','FilterOrder',2,'HalfPowerFrequency1',39,'HalfPowerFrequency2',61,'DesignMethod','butter','SampleRate',NumSamples);
        end
        
        function IEEGScopeBoot(obj)
            %% Choosing 1 from 3x Oscillitory Models, Load Phase, PhasePlusMinus, Amplitude Low and Amplitude High
            switch obj.best_toolbox.inputs.FrequencyBand
                case 1 % Alpha
                    IPSignalID = getsignalid(obj.bb.tg, 'OSC/alpha/IEEG') + int32(0);
                    NumSamples=(obj.best_toolbox.inputs.EEGDisplayPeriodPost+obj.best_toolbox.inputs.EEGDisplayPeriodPre)*0.5;
                    NumPrePostSamples=obj.best_toolbox.inputs.EEGDisplayPeriodPre*0.5;
                    Decimation=100;
                case 2 % Theta
                    IPSignalID = getsignalid(obj.bb.tg, 'OSC/theta/IEEG') + int32(0);
                    NumSamples=(obj.best_toolbox.inputs.EEGDisplayPeriodPost+obj.best_toolbox.inputs.EEGDisplayPeriodPre)*0.25;
                    NumPrePostSamples=obj.best_toolbox.inputs.EEGDisplayPeriodPre*0.25;
                    Decimation=20;
                case 3 % Beta
                    IPSignalID = getsignalid(obj.bb.tg, 'OSC/beta/IEEG') + int32(0);
                    NumSamples=(obj.best_toolbox.inputs.EEGDisplayPeriodPost+obj.best_toolbox.inputs.EEGDisplayPeriodPre)*1;
                    NumPrePostSamples=obj.best_toolbox.inputs.EEGDisplayPeriodPre*1;
                    Decimation=1;
            end
                        MrkSignalID = getsignalid(obj.bb.tg, 'MRK/mrk_masked') + int32([0]);

%             MrkSignalID = getsignalid(obj.bb.tg, 'MRK/mrk_raw') + int32([0 1 2]);
            obj.IEEGScope = addscope(obj.bb.tg, 'host', 92);
            addsignal(obj.IEEGScope, IPSignalID);
            % If 100 samples are extracted there will be a data of 400ms for Theta, 200ms for Alpha and 100ms for Beta
            obj.IEEGScope.NumSamples = NumSamples;
            obj.IEEGScope.NumPrePostSamples = NumPrePostSamples;
            obj.IEEGScope.Decimation = Decimation;
            obj.IEEGScope.TriggerMode = 'Signal';
            obj.IEEGScope.TriggerSignal = getsignalid(obj.bb.tg, 'gen_running'); %Remove it in Official Usee
%             obj.IEEGScope.TriggerSignal = MrkSignalID; %in Tuebingen setup the 2nd coloumn of signal was giving the return values, however in Mainz setup it was the third coloumn
            obj.IEEGScope.TriggerLevel = 0.5;
            obj.IEEGScope.TriggerSlope = 'Rising';
            obj.best_toolbox.inputs.rawdata.IEEG.time=linspace(-1*(obj.best_toolbox.inputs.EEGDisplayPeriodPre),obj.best_toolbox.inputs.EEGDisplayPeriodPost,NumSamples);

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
                                    MrkSignalID = getsignalid(obj.bb.tg, 'MRK/mrk_masked') + int32([0]);

%             MrkSignalID = getsignalid(obj.bb.tg, 'MRK/mrk_raw') + int32([0 1 2]);
            obj.IPScope = addscope(obj.bb.tg, 'host', 91);
            addsignal(obj.IPScope, IPSignalID);
            % If 100 samples are extracted there will be a data of 400ms for Theta, 200ms for Alpha and 100ms for Beta
            obj.IPScope.NumSamples = 100;
            obj.IPScope.NumPrePostSamples = -99;
            obj.IPScope.Decimation = 1;
            obj.IPScope.TriggerMode = 'Signal';
            obj.IPScope.TriggerSignal = getsignalid(obj.bb.tg, 'gen_running'); %Remove it in Official Usee
%             obj.IPScope.TriggerSignal = MrkSignalID; %in Tuebingen setup the 2nd coloumn of signal was giving the return values, however in Mainz setup it was the third coloumn
            obj.IPScope.TriggerLevel = 0.5;
            obj.IPScope.TriggerSlope = 'Rising';
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
            trigger(obj.FileScope.sc(obj.FileScope.activeScope));
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
        
        function IAScopeStart(obj)
            %This has to be done inside armed loop therefore empty but just required as a Place holder for consistency of Architecture
        end
    end
end

