classdef bossdevice < handle
    %DBSP Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        tg % Real-Time target %TODO: make this private
        theta
        alpha
        beta
        scope_emg
    end
    properties (Dependent)
        spatial_filter_weights
        triggers_remaining
        generator_sequence
        min_inter_trig_interval
        calibration_mode
        armed
        generator_running
        sample_and_hold_period
        eeg_channels
        aux_channels
        num_eeg_channels
        num_aux_channels
        StreamFromFile
    end
    
    methods
        function obj = bossdevice()
            %% Checking Toolboxes
            obj.checkEnvironmentToolboxes
            %% Initializing Real-Time Network
            ip_address='10.10.10.1';
            try
                env = SimulinkRealTime.addTarget('bossdevice');
            catch
                env = SimulinkRealTime.getTargetSettings('bossdevice');
            end
            for settings = SimulinkRealTime.getTargetSettings('-all');
                if(strcmp(settings.Name, 'bossdevice')), continue, end
                if(strcmp(settings.TcpIpTargetAddress, ip_address)),
                    warning(['Removing target ' settings.Name ' with duplicate ip address ' ip_address])
                    SimulinkRealTime.removeTarget(settings.Name)
                end
            end
            env.TcpIpTargetAddress=ip_address;
            env.UsBSupport='off';
            env.TargetBoot = 'StandAlone';
            
            tg = SimulinkRealTime.target('bossdevice');
            %% Search for the right bossdevice.mldatx
            firmware_with_path = which('DBSP.mldatx', '-ALL');
            %error(numel(firmware_with_path)==1,'Multiple copies of firmware found in path');
            firmware_with_path = firmware_with_path{1};
            fprintf('Loading firmware from %s\n', firmware_with_path);
            getcd=cd;
            cd(firmware_with_path(1:end-12))
            pause(1);
            tg.load('DBSP');
%             cd(getcd); drawnow;
%             tg.load(firmware_with_path(1:end-7));
%             tg.load(firmware_with_path(1:end));
            start(tg);
            
            assert(isa(tg, 'SimulinkRealTime.target'), 'tg needs to be an SimulinkRealTime.target object')
            assert(strcmp(tg.Connected, 'Yes'), 'Target tg needs to be connected')
            assert(strcmp(tg.Application, 'DBSP'), 'Target tg needs to be loaded with DBSP firmware')
            assert(strcmp(tg.Status, 'running'), 'Target tg needs to be running')
            
            obj.tg = tg;
            obj.theta = bossdevice_oscillation(obj.tg, 'theta');
            obj.alpha = bossdevice_oscillation(obj.tg, 'alpha');
            obj.beta = bossdevice_oscillation(obj.tg, 'beta');
            
            %May be deprecated in model as well as here
            obj.calibration_mode = 'no';
            
            % set-up host scopes May be deprecated
            for id = [21] % we don't really need to worry about this unless the firmware has predefined host scopes with these ids
                if(find(obj.tg.Scopes == id))
                    warning(sprintf('Scope %i already exists, it will be removed and recreated.', id));
                    remscope(obj.tg, id);
                end
            end
            obj.scope_emg = addscope(obj.tg, 'host', 21);
            emg_signal_id = getsignalid(obj.tg, 'UDP/raw_aux') + int32([0 1]);
            
            addsignal(obj.scope_emg, emg_signal_id);
            
            obj.scope_emg.NumSamples = 500;
            obj.scope_emg.NumPrePostSamples = -250;
            obj.scope_emg.Decimation = 1;
            obj.scope_emg.TriggerMode = 'Signal';
            obj.scope_emg.TriggerSignal =  getsignalid(obj.tg, 'gen_running'); %getsignalid(obj.tg, 'GEN\Compare to Zero\Compare');
            obj.scope_emg.TriggerLevel = 0.5;
            obj.scope_emg.TriggerSlope = 'Rising';
            %% Redundent Untill Incorporated in Firmware
            obj.sample_and_hold_period=0;
%             obj.StreamFromFile=1;
            obj.calibration_mode = 'no';
            obj.armed = 'no';
            obj.theta.ignore; pause(0.1)
            obj.beta.ignore; pause(0.1)
            obj.alpha.ignore; pause(0.1)
        end
        
        function obj = stop(obj)
            %STOP stop any pulse generation
            %   disables event condition detector and pulse generator and
            %   diables calibration mode
            setparam(obj.tg, 'CTL', 'calibration_mode_enabled', 0)
            setparam(obj.tg, 'CTL', 'gen_enabled', 0)
            setparam(obj.tg, 'CTL', 'trg_enabled', 0)
            setparam(obj.tg, 'CTL', 'gen_timeout_trigger_enabled', 0)
            setparam(obj.tg, 'CTL', 'gen_manual_trigger', 0)
        end
        
        function obj = arm(obj)
            obj.armed = 'yes';
        end
        
        function obj = disarm(obj)
            obj.armed = 'no';
        end
        
        function spatial_filter_weights = get.spatial_filter_weights(obj)
            spatial_filter_weights = getparam(obj.tg, 'SPF', 'weights');
        end
        
        function obj = set.spatial_filter_weights(obj, weights)
            % check that the dimensions matches the number of channels
            assert(size(weights, 1) == obj.eeg_channels, 'number of rows in weights vector must equal number of EEG channels')
            num_rows = size(obj.spatial_filter_weights, 1);
            num_columns = size(obj.spatial_filter_weights, 2);
            % check if the number of columns does not exceed the number of parallell signals
            assert(size(weights, 2) <= num_columns, 'number of columns in weights vector cannot exceed number of signal dimensions')
            % add additional columns if necessary
            if size(weights, 2) < num_columns
                weights(1, num_columns) = 0; % fill with zeros
            end
            % expand rows to match dimensions if necessary
            if size(weights, 1) < num_rows
                weights(num_rows, 1) = 0; % fill with zeros
            end
            setparam(obj.tg, 'SPF', 'weights', weights)
        end
        
        % Think about whether we really need this function
        function set_spatial_filter_weights_by_index(obj, channel_index, w, signal_index)
            
            % check dimensions of channel_index and w assert numdim(channel_index) == 1, ... ?
            assert(size(w) == size(channel_index), 'channel indicies and weights must have the same length')
            assert(signal_index < 1 || signal_index > size(obj.spatial_filter_weights, 2), 'signal_index out of range')
            % (indices should be unique) let's not worry about this
            % indices should be whole numbers isintiger?
            assert(min(channel_index) < 1 || max(channel_index) > obj.eeg_channels, 'channel index out of range')
            
            weights = zeros(size(obj.spatial_filter_weights))
            weights(channel_index, signal_index) = w;
            
            obj.spatial_filter_weights = weights;
        end
        
        function triggers_remaining = get.triggers_remaining(obj)
            triggers_remaining = getsignal(obj.tg, 'TRG/Counter');
        end
        
        function obj = set.triggers_remaining(obj, triggers)
            setparam(obj.tg, 'CTL', 'trg_countdown_reset', 0)
            setparam(obj.tg, 'TRG', 'countdown_initialcount', triggers)
%             pause(0.1)
            setparam(obj.tg, 'CTL', 'trg_countdown_reset', 1)
        end
        
        function sequence = get.generator_sequence(obj)
            sequence = getparam(obj.tg, 'GEN', 'sequence_time_port_marker');
        end
        
        function obj = set.generator_sequence(obj, sequence)
            setparam(obj.tg, 'GEN', 'sequence_time_port_marker', sequence);
        end
        
        function interval = get.min_inter_trig_interval(obj)
            interval = getparam(obj.tg, 'TRG', 'min_inter_trig_interval');
        end
        
        function obj = set.min_inter_trig_interval(obj, interval)
            setparam(obj.tg, 'TRG', 'min_inter_trig_interval', interval);
        end
        
        function duration = get.sample_and_hold_period(obj)
            duration = getparam(obj.tg, 'UDP', 'sample_and_hold_period');
        end
        
        function obj = set.sample_and_hold_period(obj, duration)
            setparam(obj.tg, 'UDP', 'sample_and_hold_period', duration);
        end
        
        function eeg_channels = get.eeg_channels(obj)
            eeg_channels = getparam(obj.tg, 'UDP', 'eeg_channels');
        end
        
        function obj = set.eeg_channels(obj, interval)
            setparam(obj.tg, 'UDP', 'eeg_channels', interval);
        end
        
        function num_eeg_channels = get.num_eeg_channels(obj)
            num_eeg_channels = getparam(obj.tg, 'UDP', 'eeg_channels');
        end
        
        function obj = set.num_eeg_channels(obj, interval)
            setparam(obj.tg, 'UDP', 'eeg_channels', interval);
        end
        
        function aux_channels = get.aux_channels(obj)
            aux_channels = getparam(obj.tg, 'UDP', 'aux_channels');
        end
        
        function obj = set.aux_channels(obj, duration)
            setparam(obj.tg, 'UDP', 'aux_channels', duration);
        end
        
        function num_aux_channels = get.num_aux_channels(obj)
            num_aux_channels = getparam(obj.tg, 'UDP', 'aux_channels');
        end
        
        function obj = set.num_aux_channels(obj, duration)
            setparam(obj.tg, 'UDP', 'aux_channels', duration);
        end
        
        % May be deprecated in future
        function calibration_mode_string = get.calibration_mode(obj)
            switch getparam(obj.tg, 'CTL', 'calibration_mode_enabled')
                case 0
                    calibration_mode_string = 'no';
                case 1
                    calibration_mode_string = 'yes';
                otherwise
                    error('calibration_mode_enabled parameter is neither 0 nor 1')
            end
        end
        
        function obj = set.calibration_mode(obj, calibration_mode_string)
            switch calibration_mode_string
                case 'yes'
                    setparam(obj.tg, 'CTL', 'calibration_mode_enabled', 1);
                case 'no'
                    setparam(obj.tg, 'CTL', 'calibration_mode_enabled', 0);
                otherwise
                    error('calibration_mode must be either ''yes'' or ''no''');
            end
        end
        
        function obj = set.armed(obj, armed)
            switch armed
                case 'yes'
                    assert(strcmp(obj.calibration_mode, 'no'), 'Cannot arm target when in calibration mode')
                    assert(strcmp(obj.generator_running, 'no'), 'Cannot arm target while generator is running')
%                     stop(obj.scope_emg); % not sure this is necessary
%                     start(obj.scope_emg);
                    setparam(obj.tg, 'CTL', 'gen_enabled', 1)
                    setparam(obj.tg, 'CTL', 'trg_enabled', 1)
                case 'no'
                    setparam(obj.tg, 'CTL', 'trg_enabled', 0)
                otherwise
                    error('armed must be either ''yes'' or ''no''');
            end
        end
        
        function armed = get.armed(obj)
            armed = 'no';
            if (getparam(obj.tg, 'CTL', 'calibration_mode_enabled') == 0 && ...
                    getparam(obj.tg, 'CTL', 'gen_enabled') == 1 && ...
                    getparam(obj.tg, 'CTL', 'trg_enabled') == 1)
                armed = 'yes';
            end
        end
        
        function generator_running = get.generator_running(obj)
            generator_running = 'no';
            if (getsignal(obj.tg, 'gen_running'))
                generator_running = 'yes';
            end
        end
        
        function configure_time_port_marker(obj, sequence)
            assert(size(sequence, 1) <= size(obj.generator_sequence, 1), 'sequence exceeds maximum number of rows')
            assert(size(sequence, 2) <= 3, 'sequence cannot have more than 3 columns')
            if size(sequence, 2) == 1
                sequence = [sequence ones(size(sequence))];
            end
            if size(sequence, 1) < size(obj.generator_sequence, 1),
                sequence(size(obj.generator_sequence, 1), 3) = 0; % fill with zeros
            end
            obj.generator_sequence = sequence;
        end
        
        function manualTrigger(obj)
%             obj.scope_emg.Status
%             stop(obj.scope_emg); % not sure this is necessary
%             pause(0.01)
%             start(obj.scope_emg);
%             pause(0.05)
            setparam(obj.tg, 'CTL', 'trg_enabled', 0)
%             pause(0.5)
            setparam(obj.tg, 'CTL', 'gen_enabled', 1)
%             assert(strcmp(obj.scope_emg.Status, 'Ready for being Triggered'), 'host scope did not reach status ''Ready for being Triggered''');
%             pause(0.1)
            setparam(obj.tg, 'CTL', 'gen_manual_trigger', 1)
%             pause(0.1)
            setparam(obj.tg, 'CTL', 'gen_manual_trigger', 0)
        end
        
        function sendPulse(obj, varargin)
            
            if nargin > 1
                port = varargin{1};
            else
                port = 1;
            end
            
            marker = port;
            
            sequence_time_port_marker = getparam(obj.tg, 'GEN', 'sequence_time_port_marker');
            sequence_time_port_marker = zeros(size(sequence_time_port_marker));
            sequence_time_port_marker(1,:) = [0 port marker]; % 0 seconds after the trigger, trigger port 1 and send marker 1
            
            setparam(obj.tg, 'CTL', 'calibration_mode_enabled', 0)
            setparam(obj.tg, 'CTL', 'gen_enabled', 0)
            setparam(obj.tg, 'CTL', 'trg_enabled', 0)
            setparam(obj.tg, 'CTL', 'gen_timeout_trigger_enabled', 0)
            setparam(obj.tg, 'CTL', 'gen_manual_trigger', 0)
            pause(0.1)
            setparam(obj.tg, 'GEN', 'sequence_time_port_marker', sequence_time_port_marker)
            obj.manualTrigger;
            
        end
        
        function data = mep(obj, varargin)
            
            if nargin > 1
                emgChannel = varargin{1};
            else
                emgChannel = 1;
            end
            
            data = [];
            while strcmp(obj.scope_emg.Status, 'Acquiring'), pause(0.01), end
            if ~strcmp(obj.scope_emg.Status, 'Finished'), warning(['Scope has no data, status is: ' obj.scope_emg.Status]), return, end
            
            data = obj.scope_emg.Data(:, emgChannel);
            
        end
        
        function checkEnvironmentToolboxes(obj)
            MandatoryToolboxes={'MATLAB','Simulink Real-Time'};
            verlist=ver;
            [InstalledToolboxes{1:length(verlist)}] = deal(verlist.Name);
            for iToolbox=1:numel(MandatoryToolboxes)
                ErrorToolboxes(iToolbox)= all(ismember(MandatoryToolboxes{1,iToolbox},InstalledToolboxes));
            end
            
        end
        
        function streamfile(obj,Data)
            obj.StreamFromFile=1;
            % convert it into single
            Data2Stream=Data;
            sz=size(Data2Stream);
            AppendData2Stream(1:128-sz(1),1:sz(2))=0;
            Data2Stream=[Data2Stream ; AppendData2Stream];
            SimulinkRealTime.utils.bytes2file('synthetaticdata.dat', Data2Stream)
            stop(obj.tg)
            SimulinkRealTime.copyFileToTarget(obj.tg,'synthetaticdata.dat')
            start(obj.tg)
        end
        
        function streaming = get.StreamFromFile(obj)
            streaming = getparam(obj.tg, 'Streaming/StreamFromFile','Value');
        end
        
        function obj = set.StreamFromFile(obj, streaming)
            setparam(obj.tg,'Streaming/StreamFromFile','Value',streaming);
        end
        
        function isFileStreaming(obj)
            % to be populated in future release
        end
        
        
    end
end


