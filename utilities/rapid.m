% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 3 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.

classdef rapid < magstim & handle
    properties (SetAccess = private)
    	enhancedPowerModeStatus = 0; %Enhanced Power Setting Mode
        rapidType = [];
        unlockCode = [];
        version = [];
        controlCommand = '';
        controlBytes = [];
    end
    
    properties (Constant)
        energyPowerTable = [  0.0,   0.0,   0.1,   0.2,   0.4,   0.6,   0.9,   1.2,   1.6,   2.0,...
                              2.5,   3.0,   3.6,   4.3,   4.9,   5.7,   6.4,   7.3,   8.2,   9.1,...
                             10.1,  11.1,  12.2,  13.3,  14.5,  15.7,  17.0,  18.4,  19.7,  21.2,...
                             22.7,  24.2,  25.8,  27.4,  29.1,  30.8,  32.6,  34.5,  36.4,  38.3,...
                             40.3,  42.3,  44.4,  46.6,  48.8,  51.0,  53.3,  55.6,  58.0,  60.5,...
                             63.0,  65.5,  68.1,  70.7,  73.4,  76.2,  79.0,  81.8,  84.7,  87.7,...
                             90.7,  93.7,  96.8, 100.0, 103.2, 106.4, 109.7, 113.0, 116.4, 119.9,...
                            123.4, 126.9, 130.5, 134.2, 137.9, 141.7, 145.5, 149.3, 153.2, 157.2,...
                            161.2, 165.2, 169.3, 173.5, 177.7, 181.9, 186.3, 190.6, 195.0, 199.5,...
                            204.0, 208.5, 213.1, 217.8, 222.5, 227.3, 232.1, 236.9, 241.9, 246.8, 252]; 
    end
    
    methods
    	function self = rapid(PortID, rapidType, varargin)
            narginchk(1, 3)
            if nargin < 2
                rapidType = 'rapid';
            elseif ~ismember(lower(rapidType),['rapid','super','superplus'])
                error('rapidType Must Be ''Rapid'', ''Super'', or ''SuperPlus''.')
            end
            self = self@magstim(PortID);
            self.rapidType = lower(rapidType);
            if nargin > 2
                self.unlockCode = varargin{1};
            end
        end 
        
        function [errorOrSuccess, deviceResponse] = setAmplitudeA(self, power, varargin)
            % Inputs:
            % power<double> : is the desired power amplitude for stimulator A
            % varargin<bool> refers to getResponse<bool> that can be True (1) or False (0)
            % indicating whether a response from device is required or not.
            % The default value is set to false.

            % Outputs:
            % deviceResponse: is the response that is sent back by the
            % device to the port indicating current information about the device
            % errorOrSuccess: is a boolean value indicating success = 0 or error = 1
            % in performing the desired task

            %% Check Input Validity:
            narginchk(2, 3);
            getResponse = magstim.checkForResponseRequest(varargin);
            if self.enhancedPowerModeStatus
                maxPower = 110;
            else
                maxPower = 100;
            end
            magstim.checkIntegerInput('Power', power, 0, maxPower);

            %% Create Control Command           
            [errorOrSuccess, deviceResponse] = self.processCommand(['@' sprintf('%03s', num2str(power))], getResponse, 3);
        end

        function [errorOrSuccess, deviceResponse] = setTrain(self, trainParameters , varargin)

            % Inputs:           
            % trainParameters<double struct>: is a numeric struct with three fields
            % indicating the desired 'frequency', 'nPulses', 'duration'. In each call of the
            % function, only two of the three parameters can be set, leaving the third field null ([]). 
            % varargin<bool>: refers to getResponse<bool> that can be True (1) or False (0)
            % indicating whether a response from device is required or not.
            % The default value is set to false.

            % Outputs:
            % deviceResponse: is the response that is sent back by the
            % device to the port indicating current information about the device
            % errorOrSuccess: is a boolean value indicating success = 0 or error = 1
            % in performing the desired task
			min_nPulses = 1;
			min_duration = 0.1;
			min_frequency = 0.1;
			max_frequency = 100;
            if self.version{1} >= 9
                max_nPulses = 6000;
                max_duration = 100;
                duration_padding = '%04s';
                nPulses_padding = '%05s';
            else
                max_nPulses = 1000;
                max_duration = 10;
                duration_padding = '%03s';
                nPulses_padding = '%04s';
            end
            
            %% Check Input Validity:
            narginchk(2, 3);
            getResponse = magstim.checkForResponseRequest(varargin);
            if ~isempty(trainParameters.frequency)
                magstim.checkNumericInput('Frequency', trainParameters.frequency, min_frequency, max_frequency);
            end
            if ~isempty(trainParameters.nPulses)
                magstim.checkIntegerInput('NPulses', trainParameters.nPulses, min_nPulses, max_nPulses);
            end
            if ~isempty(trainParameters.duration)
                magstim.checkNumericInput('Duration', trainParameters.duration, min_duration, max_duration);
            end

            if numel([trainParameters.frequency trainParameters.nPulses trainParameters.duration]) ~= 2
                error('Please provide exactly 2 numerical inputs to the trainParameters structure. The remaining input must be left as an empty vector [].')
            end

            if isempty(trainParameters.duration)
                trainParameters.duration = round((trainParameters.nPulses / trainParameters.frequency), 1);
                if (trainParameters.duration < min_duration) || (trainParameters.duration > max_duration)
                    error('Derived duration of %s seconds from provided nPulses (%s pulses) and frequency (%s Hz). This is outside the allowed range of %s to %s seconds.',...
                          num2str(trainParameters.duration), num2str(trainParameters.nPulses), num2str(trainParameters.frequency), num2str(min_duration), num2str(max_duration));
                end
            elseif isempty(trainParameters.nPulses)
                trainParameters.nPulses = floor(trainParameters.duration * trainParameters.frequency);
                if (trainParameters.nPulses < min_nPulses) || (trainParameters.nPulses > max_nPulses)
                    error('Derived nPulses of %s pulses from provided duration (%s seconds) and frequency (%s Hz). This is outside the allowed range of %s to %s pulses.',...
                          num2str(trainParameters.nPulses), num2str(trainParameters.duration), num2str(trainParameters.frequency), num2str(min_nPulses), num2str(max_nPulses));
                end                
            elseif isempty(trainParameters.frequency)
                trainParameters.frequency = round((trainParameters.nPulses / trainParameters.duration), 1);
                if (trainParameters.frequency < min_frequency) || (trainParameters.frequency > max_frequency)
                    error('Derived frequency of %s Hz from provided duration (%s seconds) and nPulses (%s pulses). This is outside the allowed range of %s to %s Hz.',...
                          num2str(trainParameters.frequency), num2str(trainParameters.duration), num2str(trainParameters.nPulses), num2str(min_frequency), num2str(max_frequency));
                end 
            end
            
            %if trainParameters.frequency > 60
            %    warning('Maximum stimulation frequency is 60 Hz for 115V areas.');
            %end
            
            [errorOrSuccess, deviceResponse] = self.getParameters();
            if ~errorOrSuccess
                ePulse = rapid.energyPowerTable(deviceResponse.PowerA + 1);
                if trainParameters.duration > (63000 / (ePulse * trainParameters.frequency))
                    error('Duration exceeds maximum on time.');
                end
            else
                error('Could not acquire current power to assess maximum on time.');
            end

            %% Create Control Command
            %1. Frequency
            trainParameters.frequency = round(trainParameters.frequency * 10);
            self.processCommand(['B' sprintf('%04s', num2str(trainParameters.frequency))], getResponse, 4);

            %2. Duration
            trainParameters.duration = round(trainParameters.duration * 10);
            self.processCommand(['[' sprintf(duration_padding, num2str(trainParameters.duration))], getResponse, 4);

            %3. Number Of Pulses
            [errorOrSuccess, deviceResponse] = self.processCommand(['D' sprintf(nPulses_padding, num2str(trainParameters.nPulses))], getResponse, 4);                              
        end

        function [errorOrSuccess, deviceResponse] = enhancedPowerMode(self, enable, varargin)
            % Inputs:
            % enable<boolean> is a boolean that can be True(1) to
            % enable and False(0) to disable the enhanced power mode
            % varargin<bool> refers to getResponse<bool> that can be True (1) or False (0)
            % indicating whether a response from device is required or not.
            % The default value is set to false.

            % Outputs:
            % deviceResponse: is the response that is sent back by the
            % device to the port indicating current information about the device
            % errorOrSuccess: is a boolean value indicating success = 0 or error = 1
            % in performing the desired task

            %% Check Input Validity:
            narginchk(2, 3);
            getResponse = magstim.checkForResponseRequest(varargin);
            if ~ismember(enable, [0 1])
                error('enable parameter must be Boolean.');
            end

            %% Create Control Command 
            if enable %Enable
                commandString = '^@';
            else %Disable
                commandString = '_@';
            end

            [errorOrSuccess, deviceResponse] =  self.processCommand(commandString, getResponse, 4);
            if ~errorOrSuccess
                self.enhancedPowerModeStatus = enable;
            end
        end

        function [errorOrSuccess, deviceResponse] = ignoreCoilSafetyInterlock(self, varargin)
            % Inputs:
            % varargin<bool> refers to getResponse<bool> that can be True (1) or False (0)
            % indicating whether a response from device is required or not.
            % The default value is set to false.

            % Outputs:
            % deviceResponse: is the response that is sent back by the
            % device to the port indicating current information about the device
            % errorOrSuccess: is a boolean value indicating success = 0 or error = 1
            % in performing the desired task

            %% Check Input Validity:
            narginchk(1, 2);
            getResponse = magstim.checkForResponseRequest(varargin);

            %% Create Control Command 
            [errorOrSuccess, deviceResponse] =  self.processCommand('b@', getResponse, 3);
        end


        function [errorOrSuccess, deviceResponse] = rTMSMode(self, enable, varargin)
            % Inputs:
            % enable<boolean> is a boolean that can be True(1) to
            % enable and False(0) to disable the switching between single-pulse and repetitive mode
            % varargin<bool> refers to getResponse<bool> that can be True (1) or False (0)
            % indicating whether a response from device is required or not.
            % The default value is set to false.

            % Outputs:
            % DeviceResponse: is the response that is sent back by the
            % device to the port indicating current information about the device
            % errorOrSuccess: is a boolean value indicating success = 0 or error = 1
            % in performing the desired task

            %% Check Input Validity:
            narginchk(2, 3);
            getResponse = magstim.checkForResponseRequest(varargin);
            if ~ismember(enable, [0 1])
                error('enable parameter must be Boolean.');
            end

            %% Create Control Command
            if self.version{1} >= 9
                padding = '%04s';
            else
                padding = '%03s';
            end
            if enable
                [errorOrSuccess, deviceResponse] = self.processCommand(['[' sprintf(padding,'10')], getResponse, 4);
            else
                [errorOrSuccess, deviceResponse] = self.processCommand(['[' sprintf(padding,'00')], getResponse, 4);
            end

        end

        function [errorOrSuccess, deviceResponse] = getParameters(self)  
            % Outputs:
            % deviceResponse: is the response that is sent back by the
            % device to the port indicating current information about the device
            % errorOrSuccess: is a boolean value indicating success = 0 or error = 1
            % in performing the desired task

            %% Check Input Validity
            narginchk(1, 1);

            %% Create Control Command 
            if self.version{1} >= 9
                returnBytes = 24;
            elseif self.version{1} >= 7
                returnBytes = 22;
            else
                returnBytes = 21;
            end
            [errorOrSuccess, deviceResponse] =  self.processCommand('\@', true, returnBytes);
        end

        %% Get Version
        function [errorOrSuccess, deviceResponse] = getDeviceVersion(self)
        %% Create Control Command
            if isempty(self.version)
                [errorOrSuccess, deviceResponse] = self.processCommand('ND', true);
            else
                errorOrSuccess = 0;
                deviceResponse = self.version;
            end
        end

        function [errorOrSuccess, deviceResponse] = remoteControl(self, enable, varargin)
            % Inputs:
            % enable<boolean> is a boolean that can be True(1) to
            % enable and False(0) to disable the device
            % varargin<bool> refers to getResponse<bool> that can be True (1) or False (0)
            % indicating whether a response from device is required or not.
            % The default value is set to false.

            % Outputs:
            % deviceResponse: is the response that is sent back by the
            % device to the port indicating current information about the device
            % errorOrSuccess: is a boolean value indicating success = 0 or error = 1
            % in performing the desired task

            %% Check Input Validity
            narginchk(2, 3);
            getResponse = magstim.checkForResponseRequest(varargin);
            if ~ismember(enable, [0 1])
                error('enable parameter must be Boolean.');
            end

            %% Create Control Command
            if enable %Enable
                if ~isempty(self.unlockCode)
                    commandString = ['Q' self.unlockCode];
                else
                    commandString = 'Q@';
                end
            else %Disable
                commandString = 'R@';
                % Attempt to disarm the stimulator
                self.disarm();
            end

            % Keep a record of if we're connecting for the first time
            alreadyConnected = self.connected;
            [errorOrSuccess, deviceResponse] =  self.processCommand(commandString, getResponse, 3);
            if ~errorOrSuccess
                self.connected = enable;
                if enable
                    % If we're not already connected, that means we're
                    % tring to connect for the first time. So check for
                    % what software version the magstim has installed.
                    if ~alreadyConnected
                        [errorCode, magstimVersion] = self.getDeviceVersion();
                        if errorCode
                            errorOrSuccess = errorCode;
                            deviceResponse = magstimVersion;
                            return
                        else
                            self.version = magstimVersion;
                        end
                    end
                    if self.version{1} >= 9
                        self.controlBytes = 6;
                        self.controlCommand = 'x@G';
                    else
                        self.controlBytes = 3;
                        self.controlCommand = 'Q@n';
                    end
                    self.enableCommunicationTimer()
                else
                    self.disableCommunicationTimer()
                end
            end
        end

        %% Get System Status
        function [errorOrSuccess, deviceResponse] = getSystemStatus(self)
            %% Check Input Validity
            narginchk(1, 1);
            %% Create Control Command
            if self.version{1} >= 9
                [errorOrSuccess, deviceResponse] =  self.processCommand('x@', true, 6);
            else
                errorOrSuccess = 7;
                deviceResponse = 'This command is unavailable with your device version.';
            end
        end        

        %% Get Error Code
        function [errorOrSuccess, deviceResponse] = getErrorCode(self)
            %% Check Input Validity
            narginchk(1, 1);
            %% Create Control Command
            [errorOrSuccess, deviceResponse] = self.processCommand('I@', true, 6);
        end

        %% Set Charge Delay
        function [errorOrSuccess, deviceResponse] = setChargeDelay(self, chargeDelay, varargin)
            % Inputs:         
            % chargeDelay<double> is the desired duration of the charge delay
            % varargin<bool> refers to getResponse<bool> that can be True (1) or False (0)
            % indicating whether a response from device is required or not.
            % The default value is set to false.

            % Outputs:
            % deviceResponse: is the response that is sent back by the
            % device to the port indicating current information about the device
            % errorOrSuccess: is a boolean value indicating success = 0 or error = 1
            % in performing the desired task
            %% Check Input Validity:
            narginchk(2, 3);
            getResponse = magstim.checkForResponseRequest(varargin);
            magstim.checkIntegerInput('Charge Delay', chargeDelay, 0, Inf);           
            %% Create Control Command
            if self.version{1} >= 9
                if chargeDelay < 0
                    error('Minimum chargeDelay is 0 ms.');
                end
                if self.version{1} >= 10
                    if chargeDelay > 10000
                        error('Maximum chargeDelay is 10000 ms.');
                    end
                    padding = '%05s';
		    returnBytes = 6;
                else
                    if chargeDelay > 2000
                        error('Maximum chargeDelay is 2000 ms.');
                    end
                    padding = '%04s';
		    returnBytes = 4;
                end
                [errorOrSuccess, deviceResponse] = self.processCommand(['n' sprintf(padding,num2str(chargeDelay))], getResponse, returnBytes);
            else
                errorOrSuccess = 7;
                deviceResponse = 'This command is unavailable with your device version.';
            end
        end 

        %% Get Charge Delay
        function [errorOrSuccess, deviceResponse] = getChargeDelay(self)
            %% Check Input Validity
            narginchk(1, 1);          
            %% Create Control Command
            if self.version{1} >= 9
                if self.version{1} >= 10
                    returnBytes = 8;
                else
                    returnBytes = 7;
                end
                [errorOrSuccess, deviceResponse] =  self.processCommand('o@', true, returnBytes);
            else
                errorOrSuccess = 7;
                deviceResponse = 'This command is unavailable with your device version.';
            end
        end
    end
    
    methods (Access = 'protected')
        function maintainCommunication(self)
        	fprintf(self.port, self.controlCommand);    
            fread(self.port, self.controlBytes);
        end

        %%
        function info = parseResponse(self, command, readData)
            %% Asking For Version?
            if command == 'N'
                % Get valid parts of returned numbers
                info = cellfun(@(x) str2double(x), regexp(readData,'\d*','Match'),'UniformOutput',false);
            else
                %% Getting Instrument Status (always returned unless asking for version)
                statusCode = bitget(double(readData(1)),1:8);
                info = struct('InstrumentStatus',struct('Standby',             statusCode(1),...
                                                        'Armed',               statusCode(2),...
                                                        'Ready',               statusCode(3),...
                                                        'CoilPresent',         statusCode(4),...
                                                        'ReplaceCoil',         statusCode(5),...
                                                        'ErrorPresent',        statusCode(6),...
                                                        'ErrorType',           statusCode(7),...
                                                        'RemoteControlStatus', statusCode(8)));
                %% Is Rapid Status Returned With This Command?
                if ismember(command,['\', '[', 'D', 'B', '^', '_', 'x', 'n'])
                    statusCode = bitget(double(readData(2)),1:8);
                    info.RapidStatus = struct('EnhancedPowerMode',     statusCode(1),...
                                              'Train',                 statusCode(2),...
                                              'Wait',                  statusCode(3),...
                                              'SinglePulseMode',       statusCode(4),...
                                              'HVPSUConnected',        statusCode(5),...
                                              'CoilReady',             statusCode(6),...
                                              'ThetaPSUDetected',      statusCode(7),...
                                              'ModifiedCoilAlgorithm', statusCode(8));
                end
                %% Get Remaining Information
                %Get commands
                if command == '\' %getParameters
                    info.PowerA    = str2double(char(readData(3:5)));
                    info.Frequency = str2double(char(readData(6:9))) / 10;
                    if self.version{1} >= 9
                        info.NPulses  = str2double(char(readData(10:14)));
                        info.Duration = str2double(char(readData(15:18))) / 10;
                        info.WaitTime = str2double(char(readData(19:22))) / 10;
                    elseif self.version{1} >= 7
                        info.NPulses  = str2double(char(readData(10:13)));
                        info.Duration = str2double(char(readData(14:16))) / 10;
                        info.WaitTime = str2double(char(readData(17:20))) / 10;
                    else
                        info.NPulses  = str2double(char(readData(10:13)));
                        info.Duration = str2double(char(readData(14:16))) / 10;
                        info.WaitTime = str2double(char(readData(17:19))) / 10;
                    end
                elseif command == 'F'  %getTemperature
                    info.CoilTemp1 = str2double(char(readData(2:4))) / 10;
                    info.CoilTemp2 = str2double(char(readData(5:7))) / 10;
                elseif command == 'I'  %getErrorCode
                    info.ErrorCode = char(readData(2:4));
                elseif command == 'x' || ((command == 'n') && (self.version{1} >= 10))  %getSystemStatus or setChargeDelay
                    statusCode = bitget(double(readData(4)),1:8);
                    info.SystemStatus = struct('Plus1ModuleDetected',      statusCode(1),...
                                               'SpecialTriggerModeActive', statusCode(2),...
                                               'ChargeDelaySet',           statusCode(3));
                elseif command == 'o'  %getChargeDelay
                    if self.version{1} >= 10
                        info.ChargeDelay = str2double(char(readData(2:6)));
                    else
                        info.ChargeDelay = str2double(char(readData(2:5)));
                    end
                end
            end
        end
    end
    
    methods (Static)
        %% Calculate Minimum Wait Time 
        function [errorOrSuccess, deviceResponse] = calcMinWaitTime(power, frequency, nPulses)
            ePulse = rapid.energyPowerTable(power + 1);
            deviceResponse = (nPulses * ((frequency * ePulse) - 1050)) / (1050 * frequency); 
            if deviceResponse < 0.5
                warning('Your input parameters result in a minimum wait time less tha 500ms.');
                warning('The Rapid will enforce a 500ms minimum wait time and does not allow train parameters to be changed during this time.');
                deviceResponse = 0.5;
            end
            errorOrSuccess = 0;
        end
    end
end
