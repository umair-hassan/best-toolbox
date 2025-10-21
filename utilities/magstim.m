% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 3 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.

classdef magstim < handle
    properties %(SetAccess = private)
        portID;
        port =[];
        connected = 0; %Default value of connected set to 0 to make sure the user connects the port
        communicationTimer = [];
        armedStatus = 0;
    end
    
    methods 
        function self = magstim(PortID)
            % PortID <char> defines the serail port id on your computer
           
            %% Find All Available Serial Ports On Your Computer
            foundPorts = instrhwinfo('serial');
            listOfComPorts = foundPorts.AvailableSerialPorts;
            
            %% Check Input Validity:
            narginchk(1, 1);
            if ~ischar(PortID) || (~isstring(PortID) && (numel(PortID) == 1))
                error('The serial port ID must be a character or string array.');
            end
            if ~any(strcmp(listOfComPorts, PortID))
                error('Serial com port ID not found.');
            end
            
            self.portID = PortID;
        end
       
        %% Opening The Desired Port
        function [errorOrSuccess, deviceResponse] = connect(self)
            %% Check Input Validity
            narginchk(1, 1);
            % Create the port if doesn't already exist. We do this here
            % because if we disconnect we want to be able to re-connect
            % using the same object
            if isempty(self.port)
                self.port            = serial(self.portID);
                self.port.BaudRate   = 9600;
                self.port.DataBits   = 8;
                self.port.Parity     = 'none';
                self.port.StopBits   = 1;
                self.port.Terminator = '';
                self.port.Timeout    = 0.3;
            end
            
            %% Open The Port
            if strcmp(self.port.Status, 'open')
                errorOrSuccess = 0;
                deviceResponse = 'Already connected to Magstim.';
                return
            else
                fopen(self.port);
            end
            %% Try and Connect
            [errorOrSuccess, deviceResponse] = self.remoteControl(true, true);
            if errorOrSuccess > 0
                % Couldn't connect, so call disconnect to delete the
                % connection. This will allow us to try again
                self.disconnect()
                error('Could not connect to the magstim.');
            else
                self.connected = 1;
            end
        end
   
        %% Closing The Desired Port
        function [errorOrSuccess, deviceResponse] = disconnect(self)
        %% Check Input Validity
            narginchk(1, 1);
            %% Close The Port
            if ~isempty(self.port) && strcmp(self.port.Status, 'open')
                % If connected, disarm and tell magstim we're relinquishing control
                if self.connected
                    [~, deviceResponse]= self.remoteControl(false, true);
                end
                fclose(self.port);
            end
            % Delete and erase the port connection
            delete(self.port);
            self.port = [];
            self.connected = 0;
            errorOrSuccess = 0;
        end
        
        function [errorOrSuccess, deviceResponse] = setAmplitudeA(self, power, varargin)
            % Inputs:
            % power<double> : is the desired power amplitude for stimulator A
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
            magstim.checkIntegerInput('Power', power, 0, 100);

            %% Create Control Command
            [errorOrSuccess, deviceResponse] = self.processCommand(['@' sprintf('%03s',num2str(power))], getResponse, 3);
            end
        
        function [errorOrSuccess, deviceResponse] = arm(self, varargin)
            % Inputs:
            % varargin<bool> refers to getResponse<bool> that can be True (1) or False (0)
            % indicating whether a response from device is required or not.
            % The default value is set to false.

            % Outputs:
            % DeviceResponse: is the response that is sent back by the
            % device to the port indicating current information about the device
            % errorOrSuccess: is a boolean value indicating success = 0 or error = 1
            % in performing the desired task
            
            if self.armedStatus
                warning('Device is already armed.');
            else
                %% Check Input Validity:
                narginchk(1, 2);
                getResponse = magstim.checkForResponseRequest(varargin);

                %% Create Control Command
                [errorOrSuccess, deviceResponse] =  self.processCommand('EB', getResponse, 3);
                if ~errorOrSuccess
                    self.armedStatus = 1;
                end
            end
        end
        
        function [errorOrSuccess, deviceResponse] = disarm(self, varargin)
            % Inputs:
            % varargin<bool> refers to getResponse<bool> that can be True (1) or False (0)
            % indicating whether a response from device is required or not.
            % The default value is set to false.

            % Outputs:
            % DeviceResponse: is the response that is sent back by the
            % device to the port indicating current information about the device
            % errorOrSuccess: is a boolean value indicating success = 0 or error = 1
            % in performing the desired task

            %% Check Input Validity:
            narginchk(1, 2);
            getResponse = magstim.checkForResponseRequest(varargin);

            %% Create Control Command
            [errorOrSuccess, deviceResponse] =  self.processCommand('EA' ,getResponse, 3);
            if ~errorOrSuccess
                self.armedStatus = 0;
            end
        end
        
        function [errorOrSuccess, deviceResponse] = fire(self, varargin)
            % Inputs:
            % varargin<bool> refers to getResponse<bool> that can be True (1) or False (0)
            % indicating whether a response from device is required or not.
            % The default value is set to false.

            % Outputs:
            % DeviceResponse: is the response that is sent back by the
            % device to the port indicating current information about the device
            % errorOrSuccess: is a boolean value indicating success = 0 or error = 1
            % in performing the desired task

            %% Check Input Validity
            narginchk(1, 2);
            getResponse = magstim.checkForResponseRequest(varargin);

            %% Create Control Command       
            [errorOrSuccess, deviceResponse] =  self.processCommand('EH', getResponse, 3);
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
                commandString = 'Q@';
            else %Disable
                commandString = 'R@';
                % Attempt to disarm the stimulator
                self.disarm();
            end
            
            [errorOrSuccess, deviceResponse] =  self.processCommand(commandString, getResponse, 3);
            if ~errorOrSuccess
                self.connected = enable;
                if enable
                    self.enableCommunicationTimer()
                else
                    self.disableCommunicationTimer()
                end
            end
        end
        
        function [errorOrSuccess, deviceResponse] = getParameters(self)  
            % Outputs:
            % DeviceResponse: is the response that is sent back by the
            % device to the port indicating current information about the device
            % errorOrSuccess: is a boolean value indicating success = 0 or error = 1
            % in performing the desired task

            %% Check Input Validity
            narginchk(1, 1);

            %% Create Control Command
            [errorOrSuccess, deviceResponse] =  self.processCommand('J@', true, 12);
        end
        
        function [errorOrSuccess, DeviceResponse] = getTemperature(self)  
            % Outputs:
            % DeviceResponse: is the response that is sent back by the
            % device to the port indicating current information about the device
            % errorOrSuccess: is a boolean value indicating success = 0 or error = 1
            % in performing the desired task
            
            %% Check Input Validity
            narginchk(1, 1);
            
            %% Create Control Command
            [errorOrSuccess, DeviceResponse] =  self.processCommand('F@', true, 9);
        end
        
        function poke(self, loud)
        	% Inputs:
            % loud<bool>: determines whether or not to send (True=1) or
            % not send (False=0) an enable remote control command while
            % poking
            
            %% Check Input Validity
            narginchk(1, 2);
            if nargin > 1
                if ~ismember(loud,[0 1])
                    error('enable parameter must be Boolean.');
                elseif loud
                    self.remoteControl(1,0)
                end
            end
            stop(self.communicationTimer) 
            start(self.communicationTimer)
        end
        
        function pause(self, delay)
            % Inputs:
            % delay <double>: determines the duration of time for which 
            % matlab is paused while maintaining communication via serial COM port
            narginchk(2, 2);
            magstim.checkIntegerInput('Delay', delay, 0, Inf);
            
            nextHundredth = 0;
            tic; 
            elapsed = 0.0;
            while elapsed <= delay
                elapsed = toc;
                if ceil(elapsed / 0.1) > nextHundredth 
                    % ceil instead of floor guarantees execution on first iteration and thus also for pauses < 0.1 s            
                    self.remoteControl(1, 0);
                    nextHundredth = nextHundredth + 1;
                end
            end
        end
    end
    
    methods (Access = 'protected')
        %%
        function maintainCommunication(self)
        	fprintf(self.port, 'Q@n');    
            fread(self.port, 3);
        end
        
        function enableCommunicationTimer(self)
            if isempty(self.communicationTimer)
                self.communicationTimer = timer;
                set(self.communicationTimer, 'ExecutionMode', 'fixedRate');
                set(self.communicationTimer, 'TimerFcn', @(~,~)self.maintainCommunication);
                set(self.communicationTimer, 'StartDelay', 0.5);
                set(self.communicationTimer, 'Period', 0.5);
            end
            % Start the timer
            if (strcmp(self.communicationTimer.Running, 'off')) 
                start(self.communicationTimer); 
            end
        end
        
        function disableCommunicationTimer(self)
            if ~isempty(self.communicationTimer)
                if strcmp(get(self.communicationTimer,'Running'),'on')
                    stop(self.communicationTimer);
                end
                delete(self.communicationTimer);
                self.communicationTimer = [];
            end   
        end
        
        function [errorOrSuccess, deviceResponse] = processCommand(self, commandString, getResponse, bytesExpected)
            %% Check If Port Is Connected
            % Or is a command does not require remote control
            if (self.connected == 0) && ~ismember(commandString(1),['Q','R','J','F','\']) && ~strcmp(commandString, 'EA')
                error ('You need to connect to the Magstim before sending commands.');
            end
            % Stop the timer (if we've already started it) and clear the port
            if ~isempty(self.communicationTimer)
                stop(self.communicationTimer)
            end
            flushinput(self.port)
                
            %% Send the command string
            fprintf(self.port, [commandString magstim.calcCRC(commandString)]); 

            % Read the first character in the response from the stimulator
            commandAcknowledge = char(fread(self.port, 1));
            if isempty(commandAcknowledge)
                errorOrSuccess = 1;
                deviceResponse = 'No response detected from device.';
            elseif strcmp(commandAcknowledge,'?')
                errorOrSuccess = 2;
                deviceResponse = 'Invalid command.';
            elseif strcmp(commandAcknowledge,'N')
                readData = '';
                while true
                    characterIn = char(fread(self.port, 1));
                    if characterIn == 0
                        readData = [readData characterIn char(fread(self.port, 1))];
                        break
                    else
                        readData = [readData characterIn];
                    end
                end
                errorOrSuccess = 0;
                deviceResponse = self.parseResponse(commandAcknowledge, readData);
            else 
                readData = char(fread(self.port, bytesExpected - 1));
                if strcmp(readData(1),'?')
                    errorOrSuccess = 3;
                    deviceResponse = 'Supplied data value not acceptable.';
                elseif strcmp(readData(1),'S')
                    errorOrSuccess = 4;
                    deviceResponse = 'Command conflicts with current device settings.';
                elseif length(readData) < (bytesExpected - 1)
                    errorOrSuccess = 5;
                    deviceResponse = 'Incomplete response from device.';
                elseif readData(end) ~= magstim.calcCRC([commandAcknowledge readData(1:end-1)'])
                    errorOrSuccess = 6;
                    deviceResponse = 'CRC does not match message contents.';
                else
                    % Creating Output
                    errorOrSuccess = 0;
                    deviceResponse = self.parseResponse(commandAcknowledge, readData);
                    self.armedStatus = deviceResponse.InstrumentStatus.Armed || deviceResponse.InstrumentStatus.Ready;
                    if ~getResponse
                        deviceResponse = [];
                    end
                end   
            end
            % Only restart the timer if we're: 1) connected to the magstim,
            % 2) the timer exists, and 3) we're not disabling remote control
            if self.connected && ~isempty(self.communicationTimer) && ~strcmp(commandString(1), 'R')
                start(self.communicationTimer)  
            end
        end
        
        %%
        function info = parseResponse(~, command, readData)
            %% Getting Instrument Status (always returned)
            statusCode = bitget(double(readData(1)),1:8);
            info = struct('InstrumentStatus',struct('Standby',             statusCode(1),...
                                                    'Armed',               statusCode(2),...
                                                    'Ready',               statusCode(3),...
                                                    'CoilPresent',         statusCode(4),...
                                                    'ReplaceCoil',         statusCode(5),...
                                                    'ErrorPresent',        statusCode(6),...
                                                    'ErrorType',           statusCode(7),...
                                                    'RemoteControlStatus', statusCode(8)));
                 
            %% Getting All Information
            %Get commands
            if command == 'J' %getParameters
                info.PowerA = str2double(char(readData(2:4)));
            elseif command == 'F'  %getTemperature
                info.CoilTemp1 = str2double(char(readData(2:4))) / 10;
                info.CoilTemp2 = str2double(char(readData(5:7))) / 10;
            end
        end
    end
    
    methods (Static)
        %% CRC checksum calculation
        function checkSum = calcCRC(commandString)
            % Sum command string, truncate to 8 bits, invert, and then
            % return as character array
            checkSum = char(bitcmp(bitand(sum(double(commandString)),255),'uint8'));
        end
        
        %% Parse varargin (i.e., getResponse) inputs to magstim methods
        function getResponse = checkForResponseRequest(getResponseParameter)
            % If getResponse argument is given, check that it is either 0 or 1, otherwise set to false (0)
            if isempty(getResponseParameter)
                getResponse = false;
            else
                getResponse = getResponseParameter{1};
                if ~ismember(getResponse, [0 1])
                    error('getResponse parameter must be Boolean.');
                end
            end
        end
        %% Check whether argument is a valid numeric value
        function checkNumericInput(inputString, inputParameter, minValue, maxValue)
            if ~isnumeric(inputParameter) || length(inputParameter) > 1
                error('Invalid %s. Must be a single numeric value.', inputString)
            end
            if (inputParameter < minValue || inputParameter > maxValue)
                if isinf(maxValue)
                    rangeString = sprintf(' greater than %s.', num2str(minValue));
                else
                    rangeString = sprintf(' between %s and %s.', num2str(minValue), num2str(maxValue));
                end
                error('%s must have a value %s', inputString, rangeString);
            end
            if mod(inputParameter, 0.1)
                error('%s can have at most one decimal value.',inputString);
            end
        end
        %% Check whether argument is a valid integer value
        function checkIntegerInput(inputString, inputParameter, minValue, maxValue)
            magstim.checkNumericInput(inputString, inputParameter, minValue, maxValue)
            if mod(inputParameter, 1)
                error('Invalid %s value. Must be a single integer.', inputString)
            end         
        end
    end    
end
