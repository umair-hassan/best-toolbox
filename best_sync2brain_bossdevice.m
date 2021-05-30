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
            setparam(obj.bb.tg, 'QLY', 'eeg_artifact_threshold', [1e6 1e6])
            MI=2;
            setparam(obj.bb.tg, 'QLY', 'inst_freq_max_instability', [1e6 1e6 1 1 1e6 1e6])
            setparam(obj.bb.tg, 'VIS/IF Stability', 'refline_2',100);
            try setparam(obj.bb.tg, 'AlphaPower/AlphaPowerWindow', 'Value',[8 14]); catch, end
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
                    MontageChannelsIndicies(1,numel(obj.best_toolbox.inputs.RealTimeChannelsMontage))=0;
                    for iMontageChannels=1:numel(obj.best_toolbox.inputs.RealTimeChannelsMontage)
                        MontageChannelsIndicies(iMontageChannels)=find(strcmp(obj.best_toolbox.app.par.hardware_settings.(InputDevice).NeurOneProtocolChannelLabels,obj.best_toolbox.inputs.RealTimeChannelsMontage{iMontageChannels}));
                    end
                    SpatialFilterWeights(MontageChannelsIndicies)=[1 -0.25 -0.25 -0.25 -0.25]'; %obj.best_toolbox.inputs.MontageWeights;
                end
                
                %% Setting Spatial Filter
                obj.bb.spatial_filter_weights=([SpatialFilterWeights SpatialFilterWeights]);
                
                %% Setting LowPas Filter Coefficients
                % For Future Use
                
                %% Setting BandPass Filter
                switch obj.best_toolbox.inputs.FrequencyBand
                    case 1 % Alpha
                       PeakFrequency=obj.best_toolbox.inputs.PeakFrequency;BandPassFilterOrder=100;
                       obj.bb.alpha.bpf_fir_coeffs  =get(design(fdesign.bandpass('n,fst1,fp1,fp2,fst2', BandPassFilterOrder, PeakFrequency-6, PeakFrequency-2, PeakFrequency+2, PeakFrequency+6, 500)), 'Numerator');
                    case 2 % Theta
                        PeakFrequency=obj.best_toolbox.inputs.PeakFrequency;BandPassFilterOrder=100;
                        obj.bb.theta.bpf_fir_coeffs  =get(design(fdesign.bandpass('n,fst1,fp1,fp2,fst2', BandPassFilterOrder, PeakFrequency-6, PeakFrequency-2, PeakFrequency+2, PeakFrequency+6, 500)), 'Numerator');                         
                    case 3 % Beta
                        PeakFrequency=obj.best_toolbox.inputs.PeakFrequency;BandPassFilterOrder=100;
                        obj.bb.beta.bpf_fir_coeffs  =get(design(fdesign.bandpass('n,fst1,fp1,fp2,fst2', BandPassFilterOrder, PeakFrequency-6, PeakFrequency-2, PeakFrequency+2, PeakFrequency+6, 500)), 'Numerator');                    
                end
            end
            %% Confirming Data Streaming
            %obj.isStreaming;
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
                    % 6 samples = 12 ms is the delay in the loop due to the low pass Nyquist filters
                    % the N20 will be 22 ms delayed and will have a 11
                    % samples delay
                    obj.bb.alpha.offset_samples = 11;
                    %here i have to add the offset and make sure the filter offset is corrected
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
            %% Starting
            if obj.best_toolbox.inputs.trial==1 && obj.best_toolbox.inputs.ReturnToTrialStatus==0
                    pause(1*60)
            end
            obj.bb.min_inter_trig_interval = 0;
            obj.bb.alpha.amplitude_min(1)=NaN;
            obj.bb.alpha.amplitude_max(1)=NaN;
            obj.bb.arm;
            exit_flag=0;
            if strcmp(obj.best_toolbox.inputs.trialMat{obj.best_toolbox.inputs.trial,obj.best_toolbox.inputs.colLabel.IAUnit},'Percentile')
                AmpMin=obj.best_toolbox.inputs.trialMat{obj.best_toolbox.inputs.trial,obj.best_toolbox.inputs.colLabel.IAPercentile}{1,1}/100;
                AmpMax=obj.best_toolbox.inputs.trialMat{obj.best_toolbox.inputs.trial,obj.best_toolbox.inputs.colLabel.IAPercentile}{1,2}/100;
            end
            while (exit_flag<1)
                disp TrialRestarted
                 if strcmp(obj.best_toolbox.inputs.trialMat{obj.best_toolbox.inputs.trial,obj.best_toolbox.inputs.colLabel.IAUnit},'Percentile')
                data=[];
                uint8_data=[];
                stop(obj.FileScope.sc);
                fsys = SimulinkRealTime.fileSystem(obj.bb.tg);
                fh = fopen(fsys, obj.FileScope.sc.FileName);
                data = fread(fsys, fh);
                fclose(fsys, fh);
                start(obj.FileScope.sc);
                uint8_data = uint8(data);
                FileScopeData = SimulinkRealTime.utils.getFileScopeData(uint8_data);
                obj.FileScope.IA(:,size(obj.FileScope.IA,2)+1:size(obj.FileScope.IA,2)+size(FileScopeData.data,1))=FileScopeData.data(:,[1 2 3])';
                %% Evaluate if its is nedded? For First Trial, discarding first second data
                %TODO: This will be handled by the pause before startig
                %file scope so these can be deleted now
%                 if obj.best_toolbox.inputs.trial==1
%                     obj.FileScope.IA=obj.FileScope.IA(:,10*5000:end);
%                 end
               
                %% Removing -50 ms to +950 ms data
               idx=find(obj.FileScope.IA(3,:)>0);
                if numel(idx>0)
                    idx=setdiff(idx,idx((find(diff(idx)==1)+1))); %Checking if there are two consecutive samples high, then taking only first of them
                    for i=1:numel(idx)
                        IdxNew(i,:)=idx(i)-250:1:idx(i)+4749;
                    end
                    IdxNew=reshape(IdxNew',1,[]);
                    AllIndex=1:1:size(obj.FileScope.IA,2);
                    AllIndex=setdiff(AllIndex,IdxNew);
                    obj.FileScope.IA=obj.FileScope.IA(:,AllIndex);
                end
                %% Taking Clean Amplitude
                obj.FileScope.IA=obj.FileScope.IA(:, obj.FileScope.IA(2,:) == 1);
                try obj.FileScope.IA=obj.FileScope.IA(:,end-obj.best_toolbox.inputs.AmplitudeAssignmentPeriod*60*5000:end); catch, end
                
%                 AmplitudeClean=obj.FileScope.IA(1, obj.FileScope.IA(2,:) == 1);
%                 try AmplitudeClean=AmplitudeClean(1,end-obj.best_toolbox.inputs.AmplitudeAssignmentPeriod*60*5000:end); catch, end
                
                AmplitudeClean=obj.FileScope.IA(1, :);
                try AmplitudeClean=AmplitudeClean(1,end-obj.best_toolbox.inputs.AmplitudeAssignmentPeriod*60*5000:end); catch, end
                AmplitudeSorted = sort(AmplitudeClean);
                plot(obj.FileScope.hAmplitudeDistributionAxes, AmplitudeSorted)

                % calculate percentiles
                switch obj.best_toolbox.inputs.trialMat{obj.best_toolbox.inputs.trial,obj.best_toolbox.inputs.colLabel.IAUnit}
                    case 'Percentile'
                        obj.FileScope.amp_lower= quantile(AmplitudeClean, obj.best_toolbox.inputs.trialMat{obj.best_toolbox.inputs.trial,obj.best_toolbox.inputs.colLabel.IAPercentile}{1,1}/100);
                        obj.FileScope.amp_upper = quantile(AmplitudeClean, obj.best_toolbox.inputs.trialMat{obj.best_toolbox.inputs.trial,obj.best_toolbox.inputs.colLabel.IAPercentile}{1,2}/100);
                        obj.best_toolbox.inputs.trialMat{obj.best_toolbox.inputs.trial,obj.best_toolbox.inputs.colLabel.IA}{1,1}= obj.FileScope.amp_lower;
                        obj.best_toolbox.inputs.trialMat{obj.best_toolbox.inputs.trial,obj.best_toolbox.inputs.colLabel.IA}{1,2} = obj.FileScope.amp_upper;
                    case 'uV'
                        obj.FileScope.amp_lower=  obj.best_toolbox.inputs.trialMat{obj.best_toolbox.inputs.trial,obj.best_toolbox.inputs.colLabel.IA}{1,1};
                        obj.FileScope.amp_upper =  obj.best_toolbox.inputs.trialMat{obj.best_toolbox.inputs.trial,obj.best_toolbox.inputs.colLabel.IA}{1,2};
                end
                
                hold(obj.FileScope.hAmplitudeDistributionAxes, 'on')
                plot(obj.FileScope.hAmplitudeDistributionAxes, [1 length(AmplitudeClean)], [obj.FileScope.amp_lower obj.FileScope.amp_upper; obj.FileScope.amp_lower obj.FileScope.amp_upper]);
                hold(obj.FileScope.hAmplitudeDistributionAxes, 'off')
                    
                if length(AmplitudeClean) > 1
                    xlim(obj.FileScope.hAmplitudeDistributionAxes, [1 length(AmplitudeClean)]);
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
                setparam(obj.bb.tg, 'VIS/Amplitude', 'refline_1',obj.best_toolbox.inputs.trialMat{obj.best_toolbox.inputs.trial,obj.best_toolbox.inputs.colLabel.IA}{1,1})
                setparam(obj.bb.tg, 'VIS/Amplitude', 'refline_2', obj.best_toolbox.inputs.trialMat{obj.best_toolbox.inputs.trial,obj.best_toolbox.inputs.colLabel.IA}{1,2})
                title(obj.FileScope.hAmplitudeDistributionAxes, ['Amplitude(Min Max): [', num2str(obj.FileScope.amp_lower) '  ' num2str(obj.FileScope.amp_upper) ']']);
                 end
                %% Arming
%                 if(strcmp(obj.bb.armed, 'no'))
%                     obj.bb.arm;
%                 end
                %% Disarming
                if obj.best_toolbox.inputs.trial>=2 && (toc(obj.best_toolbox.info.TimerAA)>4.5)
                    obj.bb.disarm;
                    obj.bb.triggers_remaining = 1;
                    obj.bb.configure_time_port_marker([0 1 20]);
                    obj.bb.manualTrigger;
                    obj.bb.triggers_remaining = 1;
                    exit_flag=2;
                    obj.best_toolbox.info.ReturnToTrial=true;
                    obj.best_toolbox.inputs.ReturnToTrialStatus=1;
                    obj.best_toolbox.inputs.ReturnToTrialNumber=obj.best_toolbox.inputs.trial;
                end
                if(obj.bb.triggers_remaining == 0)
                    obj.bb.generator_sequence(1:2,:)  
                    obj.bb.disarm;
                    exit_flag=2;
                    obj.best_toolbox.inputs.trialMat{obj.best_toolbox.inputs.trial,23}={obj.FileScope.sc1.Data(1,:)};
                    start(obj.FileScope.sc1);
                    
                    try obj.best_toolbox.inputs.trialMat{obj.best_toolbox.inputs.trial,23}={obj.FileScope.sc1.Data(:,1)};
                    start(obj.FileScope.sc1); catch, end
                end
                
                
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
            obj.EMGScope.TriggerSignal = MrkSignalID; % 04-Jun-2020 20:00:50
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
            NumPrePostSamples=round(obj.best_toolbox.inputs.EEGDisplayPeriodPre*(-5));
            Decimation=1;
            obj.IEEGScope = addscope(obj.bb.tg, 'host', 92);
            addsignal(obj.IEEGScope, IPSignalID);
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
                        obj.IPScope.TriggerSignal = MrkSignalID;
            obj.IPScope.TriggerLevel = 0.5;
            obj.IPScope.TriggerSlope = 'Rising';
            %% Starting Scope
            obj.IPScopeStart;
        end
        
        function IAScopeBoot(obj)
            %% Configuring File Scope
            obj.FileScope.IA=[];
            obj.FileScope.sc = addscope(obj.bb.tg, 'file', 100);
            addsignal(obj.FileScope.sc, [getsignalid(obj.bb.tg, 'OSC/alpha/IA'),getsignalid(obj.bb.tg, 'QLY/Logical Operator2'), getsignalid(obj.bb.tg, 'MRK/mrk_masked')]); 
            obj.FileScope.sc.FileName = 'IAFileScope.dat';
            obj.FileScope.sc.AutoRestart='on';
            pause(15); %Taking 15 second pause so that EEG can be stablized well before starting buffer
            start(obj.FileScope.sc);
            

            obj.FileScope.sc1 = addscope(obj.bb.tg, 'host', 101);
            addsignal(obj.FileScope.sc1, getsignalid(obj.bb.tg, 'AlphaPower/scale to per Hz') + int32(0:1023));
            obj.FileScope.sc1.NumSamples=2;
            %obj.FileScope.sc1.NumPrePostSamples=1;
            obj.FileScope.sc1.TriggerMode = 'Signal';
            obj.FileScope.sc1.TriggerSignal = getsignalid(obj.bb.tg, 'gen_running'); %Remove it in Official Use
            obj.FileScope.sc1.TriggerLevel = 0.5;
            obj.FileScope.sc1.TriggerSlope = 'Rising';
            start(obj.FileScope.sc1);
%             obj.FileScope.sc1 = addscope(obj.bb.tg, 'host', 101);
%             addsignal(obj.FileScope.sc1, getsignalid(obj.bb.tg, 'OSC/alpha/IA'));
%             obj.FileScope.sc1.NumSamples=250;
%             obj.FileScope.sc1.NumPrePostSamples=-249;
%             obj.FileScope.sc1.Decimation=10;
%             obj.FileScope.sc1.TriggerMode = 'Signal';
%             obj.FileScope.sc1.TriggerSignal = getsignalid(obj.bb.tg, 'gen_running'); %Remove it in Official Use
%             obj.FileScope.sc1.TriggerLevel = 0.5;
%             obj.FileScope.sc1.TriggerSlope = 'Rising';
%             start(obj.FileScope.sc1);
            
            %% Commented
%             %% Configuring Real-Time Scopes for Amplitude Tracking
%             AMP_TRACING_SCOPES_IDS = [93 94];
%             
%             % remove any pre-existing scopes with these ids
%             for id = AMP_TRACING_SCOPES_IDS
%                 if(find(obj.bb.tg.Scopes == id))
%                     remscope(obj.bb.tg, id);
%                 end
%             end
%             switch obj.best_toolbox.inputs.FrequencyBand
%                 case 1 % Alpha
%                     obj.FileScope.sig_id_amp = getsignalid(obj.bb.tg, 'OSC/alpha/IA'); %amplitude
%                     obj.FileScope.sig_id_qly = getsignalid(obj.bb.tg, 'QLY/Logical Operator2'); %eeg_is_clean
%                     
%                     obj.FileScope.sc = addscope(obj.bb.tg, 'host', AMP_TRACING_SCOPES_IDS);
%                     addsignal(obj.FileScope.sc, [obj.FileScope.sig_id_amp obj.FileScope.sig_id_qly]);
%                     
%                     obj.FileScope.sc(1).NumSamples = 500;
%                     obj.FileScope.sc(1).Decimation = 10;
%                     obj.FileScope.sc(1).TriggerSample = -1;
%                     
%                     obj.FileScope.sc(2).NumSamples = 500;
%                     obj.FileScope.sc(2).Decimation = 10;
%                     obj.FileScope.sc(2).TriggerSample = -1;
%                     
%                     obj.FileScope.sc(1).TriggerMode = 'Scope';
%                     obj.FileScope.sc(1).TriggerScope = AMP_TRACING_SCOPES_IDS(2);
%                     
%                     obj.FileScope.sc(2).TriggerMode = 'Scope';
%                     obj.FileScope.sc(2).TriggerScope = AMP_TRACING_SCOPES_IDS(1);
%                 case 2 % Theta
%                     obj.FileScope.sig_id_amp = getsignalid(obj.bb.tg, 'OSC/theta/IA'); %amplitude
%                     obj.FileScope.sig_id_qly = getsignalid(obj.bb.tg, 'QLY/Logical Operator2'); %eeg_is_clean
%                     
%                     obj.FileScope.sc = addscope(obj.bb.tg, 'host', AMP_TRACING_SCOPES_IDS);
%                     addsignal(sc, [obj.FileScope.sig_id_amp obj.FileScope.sig_id_qly]);
%                     
%                     obj.FileScope.sc(1).NumSamples = 250;
%                     obj.FileScope.sc(1).Decimation = 20;
%                     obj.FileScope.sc(1).TriggerSample = -1;
%                     
%                     obj.FileScope.sc(2).NumSamples = 250;
%                     obj.FileScope.sc(2).Decimation = 20;
%                     obj.FileScope.sc(2).TriggerSample = -1;
%                     
%                     obj.FileScope.sc(1).TriggerMode = 'Scope';
%                     obj.FileScope.sc(1).TriggerScope = AMP_TRACING_SCOPES_IDS(2);
%                     
%                     obj.FileScope.sc(2).TriggerMode = 'Scope';
%                     obj.FileScope.sc(2).TriggerScope = AMP_TRACING_SCOPES_IDS(1);
%                 case 3 % Beta
%                     obj.FileScope.sig_id_amp = getsignalid(obj.bb.tg, 'OSC/beta/IA'); %amplitude
%                     obj.FileScope.sig_id_qly = getsignalid(obj.bb.tg, 'QLY/Logical Operator2'); %eeg_is_clean
%                     
%                     obj.FileScope.sc = addscope(obj.bb.tg, 'host', AMP_TRACING_SCOPES_IDS);
%                     addsignal(sc, [obj.FileScope.sig_id_amp obj.FileScope.sig_id_qly]);
%                     
%                     obj.FileScope.sc(1).NumSamples = 1000;
%                     obj.FileScope.sc(1).Decimation = 5;
%                     obj.FileScope.sc(1).TriggerSample = -1;
%                     
%                     obj.FileScope.sc(2).NumSamples = 1000;
%                     obj.FileScope.sc(2).Decimation = 5;
%                     obj.FileScope.sc(2).TriggerSample = -1;
%                     
%                     obj.FileScope.sc(1).TriggerMode = 'Scope';
%                     obj.FileScope.sc(1).TriggerScope = AMP_TRACING_SCOPES_IDS(2);
%                     
%                     obj.FileScope.sc(2).TriggerMode = 'Scope';
%                     obj.FileScope.sc(2).TriggerScope = AMP_TRACING_SCOPES_IDS(1);
%             end
%             
%             obj.FileScope.sig_id_amp = getsignalid(obj.bb.tg, 'OSC/alpha/IA'); %amplitude
%             obj.FileScope.sig_id_qly = getsignalid(obj.bb.tg, 'QLY/Logical Operator2'); %eeg_is_clean
            
%             obj.FileScope.IA_Buffer = addscope(obj.bb.tg, 'host', 100);
%             addsignal(obj.FileScope.IA_Buffer, [obj.FileScope.sig_id_amp obj.FileScope.sig_id_qly]);
%             
%             obj.FileScope.IA_Buffer.NumSamples = 5000;
%             obj.FileScope.IA_Buffer.NumPrePostSamples = -4999;
%             obj.FileScope.IA_Buffer.TriggerSample = -1;
% %             obj.FileScope.sc(1).TriggerMode = 'Scope';
%             
%             
%             start(obj.FileScope.sc);
%             start(obj.FileScope.IA_Buffer);
%             obj.FileScope.BufferDataSize=0;
%             pause(2)
%             
%             
%             
%             obj.FileScope.tmr = timer;
%             obj.FileScope.tmr.StartFcn = @(~,~)obj.tStart;
%             obj.FileScope.tmr.TimerFcn = @(~,~)obj.tFunc;
%             obj.FileScope.tmr.Period = 1;
%             obj.FileScope.tmr.StartDelay=0;
%             obj.FileScope.tmr.TasksToExecute = 1;
%             obj.FileScope.tmr.ExecutionMode = 'fixedSpacing';
%             %start(obj.FileScope.tmr)
            
            %% Commented Removed
            
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
            % ArgIn EEGDisplayPeriodPre is ms (positive num)
            % ArgIn EEGDisplayPeriodPost is ms (positive num)
            NumSamples=round((EEGDisplayPeriodPost+EEGDisplayPeriodPre)*5); %Maximum Limit is of 1020000 Samples imposed by Simulink Real Time
            NumPrePostSamples=round(EEGDisplayPeriodPre*(-5));
            obj.EEGScope = addscope(obj.bb.tg, 'host', 95);
            AuxSignalID = getsignalid(obj.bb.tg, 'UDP/raw_eeg') + int32(0:obj.bb.eeg_channels-1);
            MrkSignalID = getsignalid(obj.bb.tg, 'MRK/mrk_masked');
            addsignal(obj.EEGScope, AuxSignalID);
            obj.EEGScope.NumSamples = NumSamples;
            obj.EEGScope.NumPrePostSamples = NumPrePostSamples;
            obj.EEGScope.Decimation = 1;
            obj.EEGScope.TriggerMode = 'Signal';
            obj.EEGScope.TriggerSignal = getsignalid(obj.bb.tg, 'gen_running'); %Remove it in Future Release
            obj.EEGScope.TriggerSignal = MrkSignalID;
            obj.EEGScope.TriggerLevel = 0.5;
            obj.EEGScope.TriggerSlope = 'Rising';
            %% Starting Scope
            obj.EEGScopeStart;
        end
        
        function EMGScopeStart(obj)
            start(obj.EMGScope);
            %             pause(0.1); % give the scope time to pre-aquire
% %             while ~strcmpi(obj.EMGScope.Status,'Ready for being Triggered'), end
            %             assert(strcmp(obj.EMGScope.Status, 'Ready for being Triggered'));
        end
        
        function IEEGScopeStart(obj)
            start(obj.IEEGScope);
% %             while ~strcmpi(obj.IEEGScope.Status,'Ready for being Triggered'), end
        end
        
        function IPScopeStart(obj)
            start(obj.IPScope);
% %             while ~strcmpi(obj.IPScope.Status,'Ready for being Triggered'), end
        end
        
        function EEGScopeStart(obj)
            start(obj.EEGScope);
            while ~strcmpi(obj.EEGScope.Status,'Ready for being Triggered'), disp('EEG Scope is started'); drawnow, end
        end
        
        function IAScopeStart(obj)
            %This has to be done inside armed loop therefore empty but just required as a Place holder for consistency of Architecture and may be used in future
        end
        function [Time, Data] = EMGScopeRead(obj,Channel)
            while ~strcmpi(obj.EMGScope.Status,'finished'), drawnow, if obj.best_toolbox.inputs.stop_event==1, break, end ,end
            Data=obj.EMGScope.Data(:,Channel)';
            Time=(obj.EMGScope.Time-obj.EMGScope.Time(1)+(obj.EMGScope.Time(2)-obj.EMGScope.Time(1)))';
            Time=(Time*1000)+obj.best_toolbox.inputs.EMGDisplayPeriodPre*(-1);
            if(obj.best_toolbox.inputs.EMGDisplayPeriodPre>0)
                cfg=[];
                ftdata.label={'ch1'};
                ftdata.fsample=5000;
                ftdata.trial{1}=Data;
                ftdata.time{1}=Time/1000;
                cfg.demean='yes';
                cfg.hpfilter      = 'yes'; % high-pass in order to get rid of low-freq trends
                cfg.hpfiltord     = 3;
                cfg.hpfreq        = 1;
                %                 cfg.lpfilter      = 'yes'; % low-pass in order to get rid of high-freq noise
                %                 cfg.lpfiltord     = 3;
                %                 cfg.lpfreq        = 249; % 249 when combining with a linenoise bandstop filter
                %                 cfg.bsfilter      = 'yes'; % band-stop filter, to take out 50 Hz and its harmonics
                %                 cfg.bsfiltord     = 3;
                %                 cfg.bsfreq        = [49 51; 99 101; 149 151; 199 201]; % EU line noise
                % cfg.detrend='yes'; % It does not help in improving, however introduces weired drifts therefore deprication is recommended in Future Release
                cfg.baselinewindow=[(obj.best_toolbox.inputs.EMGDisplayPeriodPre*(-1)+1)/1000 -25/1000]; %[EMGDisplayPeriodPre_ms to -10ms]
                ProcessedData=ft_preprocessing(cfg, ftdata);
                %% Here the Line Noise Filtering is Performed Using a Template
                if obj.best_toolbox.inputs.NoiseFilter50Hz==1
                    ats.Trial           = ProcessedData.trial{1};
                    ats.Time            = ProcessedData.time{1};
                    ats.Trial_1_20      = ats.Trial(1,1:100); %Extracting 1st 50 Hz Cycle
                    ats.Trial_21_40     = ats.Trial(1,101:200); %Extracting 2nd 50 Hz Cycle
                    ats.Trial_mean      = (ats.Trial_1_20+ats.Trial_21_40)/2; %Averaging Both Cycle to Generalize Tempalte
                    ats.Trial_Template  = repmat(ats.Trial_mean,1,2*ceil(size(ats.Trial,2)/20));
                    ats.Trial_Tempalte  = ats.Trial_Template(1,1:size(ats.Trial,2)); %Making the dimensions of Template Compatible with Trial
                    ats.Trial_corrected = ats.Trial-ats.Trial_Tempalte; %Subtracting Tempalte
                    Data                = ats.Trial_corrected;
                    Time                = ProcessedData.time{1};
                elseif obj.best_toolbox.inputs.NoiseFilter50Hz==0
                    Data = ProcessedData.trial{1};
                    Time = ProcessedData.time{1}*1000;
                end
            end
        end
        function Data = IPScopeRead(obj)
            while ~strcmpi(obj.IPScope.Status,'finished'), drawnow, if obj.best_toolbox.inputs.stop_event==1, break, end ,end
            Data=obj.IPScope.Data(end,1);
            obj.IPScopeStart;
        end
        function Data = IEEGScopeRead(obj)
            while ~strcmpi(obj.IEEGScope.Status,'finished'), drawnow, if obj.best_toolbox.inputs.stop_event==1, break, end ,end
            Data=obj.IEEGScope.Data(:,1)';
            Time=(obj.IEEGScope.Time-obj.IEEGScope.Time(1)+(obj.IEEGScope.Time(2)-obj.IEEGScope.Time(1)))';
            Time=(Time*1000)+obj.best_toolbox.inputs.EEGDisplayPeriodPre*(-1);
            if(obj.best_toolbox.inputs.EEGDisplayPeriodPre>0)
                cfg=[];
                ftdata.label={'ch1'};
                ftdata.fsample=5000;
                ftdata.trial{1}=Data;
                ftdata.time{1}=Time/1000;
                cfg.demean='yes';
                %                 cfg.hpfilter      = 'yes'; % high-pass in order to get rid of low-freq trends
                %                 cfg.hpfiltord     = 3;
                %                 cfg.hpfreq        = 1;
                %cfg.detrend='yes'; % It does not help in improving, however introduces weired drifts therefore deprication is recommended in Future Release
                cfg.baselinewindow=[(obj.best_toolbox.inputs.EEGDisplayPeriodPre*(-1)+1)/1000 -50/1000]; %obj.best_toolbox.inputs.EEGDisplayPeriodPre*(-1)/1000 -10 %[EMGDisplayPeriodPre_ms to -10ms]
                ProcessedData=ft_preprocessing(cfg, ftdata);
                Data=ProcessedData.trial{1};
                obj.best_toolbox.inputs.rawData.IEEG.time=ProcessedData.time{1}*1000;
            end
            obj.IEEGScopeStart;
        end
        function [Time, Data]=EEGScopeRead(obj)
            Time=[]; Data=[];
            obj.EEGScope.Status,  trigger(obj.EEGScope); obj.EEGScope.Status,
            while ~strcmpi(obj.EEGScope.Status,'finished') ,drawnow, if obj.best_toolbox.inputs.stop_event==1, break, end ,end
            if obj.best_toolbox.inputs.stop_event==1, return, end
            Data=obj.EEGScope.Data';
            Time=(obj.EEGScope.Time-obj.EEGScope.Time(1)+(obj.EEGScope.Time(2)-obj.EEGScope.Time(1)))';
            switch obj.best_toolbox.inputs.Protocol
                case 'ERP Measurement Protocol'
                    %% Converting Trial's Data Into FieldTrip Format Data for PreProcessing
                    Time=(Time*1000)+obj.best_toolbox.inputs.EEGExtractionPeriod(1);
                    %% Creating RawEEGData
                    InputDevice      = obj.best_toolbox.inputs.trialMat{obj.best_toolbox.inputs.trial,obj.best_toolbox.inputs.colLabel.inputDevices};
                    EEGChannelsIndex = find(strcmp(obj.best_toolbox.app.par.hardware_settings.(InputDevice).NeurOneProtocolChannelSignalTypes,'EEG'));
                    EEGChanelsLabels = obj.best_toolbox.app.par.hardware_settings.(InputDevice).NeurOneProtocolChannelLabels(EEGChannelsIndex);
                    FieldTripData             = struct;
                    FieldTripData.label       = EEGChanelsLabels';
                    FieldTripData.trial {1}   = Data;
                    FieldTripData.time  {1}   = Time/1000;
                    %% PreProcessing RawEEGData for this Trial
                    cfg=[];
                    cfg.detrend='yes';                    
                    if obj.best_toolbox.inputs.EEGExtractionPeriod(1)<=-10
                        cfg.demean='yes';
                        cfg.baselinewindow=[obj.best_toolbox.inputs.EEGExtractionPeriod(1)+1/1000 -10/1000]; 
                    end
                    if ~isempty(obj.best_toolbox.inputs.HighPassFrequency)
                        cfg.hpfilter      = 'yes'; 
                        cfg.hpfiltord     = obj.best_toolbox.inputs.HighPassFilterOrder;
                        cfg.hpfreq        = obj.best_toolbox.inputs.HighPassFrequency;
                    end
                    if ~isempty(obj.best_toolbox.inputs.BandStopFrequency)
                        cfg.bsfilter      = 'yes'; 
                        cfg.bsfiltord     = obj.best_toolbox.inputs.BandStopFilterOrder;
                        cfg.bsfreq        = obj.best_toolbox.inputs.BandStopFrequency;
                    end
                    if ~isempty(obj.best_toolbox.inputs.ReferenceChannels)
                        cfg.reref         = 'yes'; 
                        cfg.refchannel    = obj.best_toolbox.inputs.ReferenceChannels;
                    end
                    PreProcessedData = ft_preprocessing(cfg,FieldTripData);
                    %% now save this PreProcessData
                    obj.best_toolbox.inputs.rawdata.RawEEGData.label=PreProcessedData.label;
                    obj.best_toolbox.inputs.rawdata.RawEEGData.time{obj.best_toolbox.inputs.trial}=PreProcessedData.time{1};
                    obj.best_toolbox.inputs.rawdata.RawEEGData.trial{obj.best_toolbox.inputs.trial}=PreProcessedData.trial{1};
                    obj.best_toolbox.inputs.rawdata.RawEEGTime=Time;
% %                     for MontageChannelNo=1:numel(obj.best_toolbox.inputs.MontageChannels)
% %                         MontageChannel{MontageChannelNo}=erase(char(join(obj.best_toolbox.inputs.MontageChannels{MontageChannelNo})),' ');
% %                     end
                    %% Applying Montage on Preprocessed Data, Creating Montage Channels
                    SelectedData={};
                    for channel=1:numel(obj.best_toolbox.inputs.MontageChannels)
                        SelectedData{channel}=obj.best_toolbox.inputs.MontageChannels{channel};
                        if iscell(obj.best_toolbox.inputs.MontageChannels{channel})
                            cfg=[];
                            cfg.labelold  =obj.best_toolbox.inputs.MontageChannels{channel};
                            cfg.labelnew  ={erase(char(join(obj.best_toolbox.inputs.MontageChannels{channel})),' ')};
                            cfg.tra       =cell2mat(obj.best_toolbox.inputs.MontageWeights{channel});
                            Montage=ft_apply_montage(PreProcessedData,cfg);
                            obj.best_toolbox.inputs.rawdata.(char(cfg.labelnew)).data(obj.best_toolbox.inputs.trial,:)=Montage.trial{1};
                        else
                            id=strcmp(obj.best_toolbox.app.par.hardware_settings.(InputDevice).NeurOneProtocolChannelLabels,obj.best_toolbox.inputs.MontageChannels{channel});
                            obj.best_toolbox.inputs.rawdata.(obj.best_toolbox.inputs.MontageChannels{channel}).data(obj.best_toolbox.inputs.trial,:)=Data(id,:);
                        end
                    end
            end
%             if ~strcmpi(obj.best_toolbox.inputs.Protocol,'rs EEG Measurement Protocol')
%                 Time=(Time*1000)+obj.best_toolbox.inputs.EEGExtractionPeriod(1);
%                 if(obj.best_toolbox.inputs.EEGDisplayPeriodPre>0)
%                     cfg             = [];
%                     ftdata.label    = {'ch1'};
%                     InputDevice     = obj.best_toolbox.inputs.condMat{1,obj.best_toolbox.inputs.colLabel.inputDevices};
%                     ftdata.trial{1} = [Data(find(strcmp(obj.best_toolbox.app.par.hardware_settings.(InputDevice).NeurOneProtocolChannelLabels,obj.best_toolbox.inputs.MontageChannels{1})),:)];
%                     ftdata.time{1}  = [Time];
%                     cfg.demean='yes';
%                     %                     cfg.reref         = 'yes'; % band-stop filter, to take out 50 Hz and its harmonics
%                     %                     cfg.refchannel    = {'ch2'};
%                     %                 cfg.detrend='yes'; % It does not help in improving, however introduces weired drifts therefore deprication is recommended in Future Release
%                     cfg.baselinewindow=[obj.best_toolbox.inputs.EEGDisplayPeriodPre*(-1)/1000 -10]; %obj.best_toolbox.inputs.EEGDisplayPeriodPre*(-1)/1000 -10 %[EMGDisplayPeriodPre_ms to -10ms]
%                     ProcessedData=ft_preprocessing(cfg, ftdata);
%                     Data=ProcessedData.trial{1};
%                     Data=Data(1,:);
%                     Time=ProcessedData.time{1};
%                     obj.best_toolbox.inputs.rawData.IEEG.time=ProcessedData.time{1};
%                     %                     cfg=[];
%                     %                     ftdata.label={'ch1';'ch2'};
%                     %                     InputDevice=obj.best_toolbox.inputs.condMat{1,obj.best_toolbox.inputs.colLabel.inputDevices};
%                     %                     ftdata.trial{1}=[Data(find(strcmp(obj.best_toolbox.app.par.hardware_settings.(InputDevice).NeurOneProtocolChannelLabels,obj.best_toolbox.inputs.MontageChannels{1})),:);Data(find(strcmp(obj.best_toolbox.app.par.hardware_settings.(InputDevice).NeurOneProtocolChannelLabels,obj.best_toolbox.inputs.ReferenceChannels)),:)];
%                     %                     ftdata.time{1}=[Time];
%                     %                     cfg.demean='yes';
%                     %                     cfg.reref         = 'yes'; % band-stop filter, to take out 50 Hz and its harmonics
%                     %                     cfg.refchannel    = {'ch2'};
%                     %                     %                 cfg.detrend='yes'; % It does not help in improving, however introduces weired drifts therefore deprication is recommended in Future Release
%                     %                     cfg.baselinewindow=[obj.best_toolbox.inputs.EEGDisplayPeriodPre*(-1)/1000 -10]; %obj.best_toolbox.inputs.EEGDisplayPeriodPre*(-1)/1000 -10 %[EMGDisplayPeriodPre_ms to -10ms]
%                     %                     ProcessedData=ft_preprocessing(cfg, ftdata);
%                     %                     Data=ProcessedData.trial{1};
%                     %                     Data=Data(1,:);
%                     %                     Time=ProcessedData.time{1};
%                     %                     obj.best_toolbox.inputs.rawData.IEEG.time=ProcessedData.time{1};
%                 end
%             end
            
            obj.EEGScopeStart;
        end
        function [Time, Data]=EEGFieldTripScopeRead(obj)
            while ~strcmpi(obj.EEGScope.Status,'finished'), drawnow, if obj.best_toolbox.inputs.stop_event==1, break, end ,end
            Data=obj.EEGScope.Data(:,:)';
            Time=(obj.EEGScope.Time-obj.EEGScope.Time(1)+(obj.EEGScope.Time(2)-obj.EEGScope.Time(1)))';
            Time=(Time*1000)+obj.best_toolbox.inputs.EEGExtractionPeriod(1); 
            %% Interpolating Data to remove pulse artefact
            %use sample and hold period of bossdevice
            %% end of interpolation
            obj.EEGScopeStart;
        end
        
        function EEGScopeTrigger(obj)
            trigger(obj.EEGScope);
        end
        
        function stop(obj)
            obj.bb.stop;
            try stop([obj.EMGScope obj.IEEGScope obj.IAScope obj.IPScope obj. EEGScope]); catch, end
        end
        function isStreaming(obj)
            %% 96, 97 Scope Checking
            if obj.bb.aux_channels>0
                NumSamples=round((10+10)*5); % 20 ms total
                NumPrePostSamples=round(10*5); %10ms prepost
                EMGScopeStreaming = addscope(obj.bb.tg, 'host', 97);
                AuxSignalID = getsignalid(obj.bb.tg, 'UDP/raw_aux') + int32(0:7);
                addsignal(EMGScopeStreaming, AuxSignalID);
                EMGScopeStreaming.NumSamples = NumSamples;
                EMGScopeStreaming.NumPrePostSamples = -NumPrePostSamples;
                EMGScopeStreaming.Decimation = 1;
                EMGScopeStreaming.TriggerMode = 'Signal';
                EMGScopeStreaming.TriggerSignal = getsignalid(obj.bb.tg, 'gen_running');
                EMGScopeStreaming.TriggerLevel = 0.5;
                EMGScopeStreaming.TriggerSlope = 'Rising';
                start(EMGScopeStreaming);
                while ~strcmpi(EMGScopeStreaming.Status,'Ready for being Triggered'), end
                trigger(EMGScopeStreaming);
                while ~strcmpi(EMGScopeStreaming.Status,'finished'),end
                isAuxStreaming=any(mean(EMGScopeStreaming.Data(:,1:obj.bb.aux_channels))~=0);
                if isAuxStreaming==false
                     obj.best_toolbox.app.info.ErrorMessage='The EMG Channels listed in the running BEST Toolbox Protocol are not streaming, try again after streaming correct channels.';
                     error(obj.best_toolbox.app.info.ErrorMessage);
                end
            end
            if obj.bb.eeg_channels>0
                NumSamples=round((10+10)*5); % 20 ms total
                NumPrePostSamples=round(10*5); %10ms prepost
                EEGScopeStreaming = addscope(obj.bb.tg, 'host', 96);
                AuxSignalID = getsignalid(obj.bb.tg, 'UDP/raw_eeg') + int32(0:obj.bb.eeg_channels-1);
                addsignal(EEGScopeStreaming, AuxSignalID);
                EEGScopeStreaming.NumSamples = NumSamples;
                EEGScopeStreaming.NumPrePostSamples = -NumPrePostSamples;
                EEGScopeStreaming.Decimation = 1;
                EEGScopeStreaming.TriggerMode = 'Signal';
                EEGScopeStreaming.TriggerSignal = getsignalid(obj.bb.tg, 'gen_running'); 
                EEGScopeStreaming.TriggerLevel = 0.5;
                EEGScopeStreaming.TriggerSlope = 'Rising';
                start(EEGScopeStreaming);
                while ~strcmpi(EEGScopeStreaming.Status,'Ready for being Triggered'), end
                trigger(EEGScopeStreaming);
                while ~strcmpi(EEGScopeStreaming.Status,'finished'),end
                isEEGStreaming=any(mean(EEGScopeStreaming.Data(:,1:obj.bb.eeg_channels))~=0);
                if isEEGStreaming==false
                     obj.best_toolbox.app.info.ErrorMessage='The EEG Channels listed in the running BEST Toolbox Protocol are not streaming, try again after streaming correct channels.';
                     error(obj.best_toolbox.app.info.ErrorMessage);
                end
            end
        end
        
        function tStart(obj)
            trigger(obj.FileScope.IA_Buffer);
            disp('**************************');
        end
        
        function tFunc(obj)
            obj.FileScope.BufferDataSize=obj.FileScope.BufferDataSize+1;
            obj.FileScope.BufferData{obj.FileScope.BufferDataSize}=obj.FileScope.IA_Buffer.Data;
            start(obj.FileScope.IA_Buffer);
            stop(obj.FileScope.tmr);
            start(obj.FileScope.tmr);
        end
    end
end

