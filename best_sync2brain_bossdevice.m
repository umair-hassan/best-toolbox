classdef best_sync2brain_bossdevice <handle

    
    properties
        bb %bossbox API object
        best_toolbox
        EMGScope
        IEEGScope
        IAScope
        IPScope
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
                clab=obj.best_toolbox.app.par.hardware_settings.(outputdevice).NeurOneProtocolChannelLabels;
                clab = clab(1:64); % remove AUX Channels 
                clab{65} = 'FCz';
                obj.bb.spatial_filter_clab = clab;

                
                %% Setting Spatial Filter
                % set a spatial filter to C3 hjorth
                set_spatial_filter(obj.bb, obj.best_toolbox.inputs.MontageChannels, obj.best_toolbox.inputs.MontageWeights, 1)
%                 set_spatial_filter(obj.bb, {'C3', 'FC1', 'FC5', 'CP1', 'CP5'}, [1 -0.25 -0.25 -0.25 -0.25], 1)
                set_spatial_filter(obj.bb, {}, [], 2)
                

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
            %% Choosing 1 from 3x Oscillitory Models
            switch obj.best_toolbox.inputs.FrequencyBand
                case 1 % Alpha
%                     obj.best_toolbox.inputs.trialMat{obj.best_toolbox.inputs.trial,obj.best_toolbox.inputs.colLabel.tpm}
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
            % calculation of IA and setting of those parameters would also be done here
            %
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
            obj;
            obj.bb;
            
            obj.bb.arm;
            obj.bb.armed ;
            exit_flag=0;
            tic
            while (exit_flag<1)
                 if(obj.bb.triggers_remaining == 0)
                     toc
                     obj.bb.disarm;
                     while ~strcmpi(obj.EMGScope.Status,'finished'), end
                     exit_flag=2;
                 end
            end
%             obj.bb.arm;
            
        end
        
        function EMGScopeBoot(obj,EMGDisplayPeriodPre,EMGDisplayPeriodPost)
            disp enteredEMGScopeboot
            NumSamples=(EMGDisplayPeriodPost+EMGDisplayPeriodPre)*5;
            NumPrePostSamples=EMGDisplayPeriodPre*5;
            obj.EMGScope = addscope(obj.bb.tg, 'host', 90);
            AuxSignalID = getsignalid(obj.bb.tg, 'aux_raw') + int32(0:8);
            MrkSignalID = getsignalid(obj.bb.tg, 'mrk_raw') + int32([0 1 2]);
            addsignal(obj.EMGScope, AuxSignalID);
            obj.EMGScope.NumSamples = NumSamples;
            obj.EMGScope.NumPrePostSamples = -NumPrePostSamples;
            obj.EMGScope.Decimation = 1;
            obj.EMGScope.TriggerMode = 'Signal';
            obj.EMGScope.TriggerSignal = getsignalid(obj.bb.tg, 'gen_running'); %Remove it in Official Usee
%             obj.EMGScope.TriggerSignal = MrkSignalID(3); %in Tuebingen setup the 2nd coloumn of signal was giving the return values, however in Mainz setup it was the third coloumn
            obj.EMGScope.TriggerLevel = 0.5;
            obj.EMGScope.TriggerSlope = 'Rising';
        end
        
        function IEEGScopeBoot(obj,EEGDisplayPeriodPre,EEGDisplayPeriodPost)
        end
        
        function IPScopeBoot(obj)
        end
        
        function IAScopeBoot(obj)
            % could be a free running scope
        end
        
        function EMGScopeStart(obj)
            start(obj.EMGScope);
%             pause(0.1); % give the scope time to pre-aquire
            while ~strcmpi(obj.EMGScope.Status,'Ready for being Triggered'), end
%             assert(strcmp(obj.EMGScope.Status, 'Ready for being Triggered'));
        end
        
        function IEEGScopeStart(obj)
        end
        
        function IPScopeStart(obj)
        end
        
        function IAScopeStart(obj)
        end
    end
end

