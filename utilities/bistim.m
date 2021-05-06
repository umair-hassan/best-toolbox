% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 3 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.

classdef bistim < magstim & handle
    properties (SetAccess = private)
        highRes = 0; %Bistim High Resolution Time Setting Mode
    end
    
    methods
        function self = bistim(PortID)
            self = self@magstim(PortID);
        end
    end
    
    methods
        function [errorOrSuccess, deviceResponse] = setAmplitudeB(self, power, varargin)
            % Inputs:
            % power<double> : is the desired power amplitude for stimulator B 
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
            magstim.checkIntegerInput('Power', power, 0, 100);
            
            %% Create Control Command
            [errorOrSuccess, deviceResponse] = self.processCommand(['A' sprintf('%03s',num2str(power))], getResponse, 3);
        end
        
        function [errorOrSuccess, deviceResponse] = setPulseInterval(self, ipi, varargin)
            % Inputs:
            % ipi<double> : is the desired interpulse interval 
            % varargin<bool>: refers to getResponse<bool> that can be True (1) or False (0)
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
            if self.highRes % Device already set to highRes Mode
                magstim.checkNumericInput('IPI', ipi, 0, 99.9);
                ipi = round(ipi * 10);
            else % Assume not in highRes mode
                magstim.checkIntegerInput('IPI', ipi, 0, 999);
           end
            
            %% Create Control Command
            [errorOrSuccess, deviceResponse] = self.processCommand(['C' sprintf('%03s', num2str(ipi))], getResponse, 3);           
        end
        
        function [errorOrSuccess, deviceResponse] = highResolutionMode(self, enable, varargin)
            % Inputs:
            % enable<boolean> is a boolean that can be True(1) to
            % enable and False(0) to disable the High Resolution Time Setting Mode
            % varargin<bool> refers to getResponse<bool> that can be True (1) or False (0)
            % indicating whether a response from device is required or not.
            % The default value is set to false.
            
            % Outputs:
            % DeviceResponse: is the response that is sent back by the
            % device to the port indicating current information about the device
            % errorOrSuccess: is a boolean value indicating success = 0 or error = 1
            % in performing the desired task
            
            %% Check Input Validity
            narginchk(2, 3);
            getResponse = magstim.checkForResponseRequest(varargin);
            if ~ismember(enable, [0 1])
                error('enable Must Be A Boolean');
            end
           
            %% Create Control Command
            if enable %Enable
                commandString = 'Y@';
            else %Disable
                commandString = 'Z@';                               
            end
            [errorOrSuccess, deviceResponse] =  self.processCommand(commandString, getResponse, 3);
            if ~errorOrSuccess
                self.highRes = enable;
            end
        end
        
        function [errorOrSuccess, deviceResponse] = getParameters(self)  
            % Outputs:
            % DeviceResponse: is the response that is sent back by the
            % device to the port indicating current information about the device
            % errorOrSuccess: is a boolean value indicating success = 0 or error = 1
            % in performing the desired task

            %% Check Input Validity
            narginchk(1,1);

            %% Create Control Command
            [errorOrSuccess, deviceResponse] =  self.processCommand('J@', true, 12);
            if self.highRes
                deviceResponse.IPI = deviceResponse.IPI / 10;
            end
        end
    end
    
    methods (Access = 'protected')        
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
                info.PowerB = str2double(char(readData(5:7)));
                info.IPI    = str2double(char(readData(8:10)));
            elseif command == 'F'  %getTemperature
                info.CoilTemp1 = str2double(char(readData(2:4))) / 10;
                info.CoilTemp2 = str2double(char(readData(5:7))) / 10;
            end
        end
    end
end
