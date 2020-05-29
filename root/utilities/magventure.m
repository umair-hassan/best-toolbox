% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 3 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.

classdef magventure < handle 
    
   properties (SetAccess = private)
       port
       connected = 0; %Default value of connected set to 0 to make sure the user connects the port
   end
   methods 
       function self = magventure(PortID)
            % PortID <char> defines the serail port id on your computer
           
            %% Find All Available etISerial Ports On Your Computer
            
            FoundPorts = instrhwinfo('serial');
            ListOfComPorts = FoundPorts.AvailableSerialPorts;
            
            %% Check Input Validity:
            if nargin <1
                error('Not Enough Input Arguments');
            end
            if ~(ischar(PortID))
                error('The Serial Port ID Must Be a Character Array');
            end
            if ~any(strcmp(ListOfComPorts,PortID)) 
                error('Invalid Serial Com Port ID');
            end
            
            %% Identifing The Port
            P = serial(PortID);
            P.BaudRate = 38400;
            P.DataBits = 8;
            P.Parity = 'none';
            P.StopBits = 1;
            P.InputBufferSize = 19;
            P.OutputBufferSize = 512;
            
            self.port = P;

       end
   end
   methods
       
       %% Opening The Desired Port
       function [errorOrSuccess, deviceResponse] = connect(self)
           %% Check Input Validity
           if nargin <1
                    error('Not Enough Input Arguments');
           end

            %% Open The Port
                fopen(self.port);
                if ~(strcmp (self.port.Status,'closed'))
                    self.connected = 1;
                    errorOrSuccess = ~ self.connected;
                    deviceResponse = [];
                end
                
       end
   
       %% Closing The Desired Port
       function [errorOrSuccess, deviceResponse] = disconnect(self)
           %% Check Input Validity
           if nargin <1
                    error('Not Enough Input Arguments');
           end

            %% Close The Port
                fclose(self.port);
            if (strcmp (self.port.Status,'closed'))
               self.connected = 0;
               errorOrSuccess = self.connected;
               deviceResponse = [];
            end
                
       end 
   end
   methods
       
       %% 0.Getting Status From Device
       function [errorOrSuccess, deviceResponse] = getStatus(self)
            % Outputs:
            % deviceResponse: is the response that is sent back by the
            % device to the port indicating current information about the device
            % errorOrSuccess: is a boolean value indicating succecc = 0 or error = 1
            % in performing the desired task
        %% Reconnect the stimulator
            self.disconnect();
            self.connect();
            warning('In case of any problems, try reconnecting the device manually');
        %% Create Control Command
            commandLength = '01'; 
            commandID = '00';               
            commandBytes = commandID;
            
            getResponse = 1;
            [errorOrSuccess, deviceResponse] =  self.processCommand(commandLength,commandBytes,getResponse,13); 
           
       end
       
       %% 1.Setting The Amplitude In Standard Or Twin/Dual Modes
       function [errorOrSuccess, deviceResponse] = setAmplitude(self,desiredAmplitudes,varargin)
            % Inputs:
            % DesiredAmplitudes<double> must be a vector of length 1 indicating A amplitude in
            % percentage ; Or of length 2 in Dual/Twin Mode indicating A &
            % B amplitudes in percentage respectively
            % varargin<bool> refers to getResponse<bool> that can be True (1) or False (0)
            % indicating whether a response from device is required or not.
            % The default value is set to false.
            
            % Outputs:
            % deviceResponse: is the response that is sent back by the
            % device to the port indicating current information about the device
            % errorOrSuccess: is a boolean value indicating succecc = 0 or error = 1
            % in performing the desired task
            
            %% Check Input Validity:
     
            if nargin <2
                error('Not Enough Input Arguments');
             end
             if length(varargin)>1
                error('Too Many Input Arguments');
             end
             if nargin <3
                getResponse = false ; %Default value Set To 0
             else
                getResponse = varargin{1};
             end
            
             if (getResponse ~= 0 && getResponse ~= 1 )
                   error('getResponse Must Be A Boolean');
             end
             
             %% Reconnect the stimulator
             if getResponse ==1                  
                self.disconnect();
                self.connect();
                warning('In case of any problems, try reconnecting the device manually');
             end
             %%
            A_Amp =[];
            B_Amp =[];
            if (length(desiredAmplitudes)~= 1 && length(desiredAmplitudes)~= 2)
               error('Invalid Number of Inputs. Number of Inputs Must Be 1 or 2(Dual Mode) In This Control Type');
            end
            
            if (length(desiredAmplitudes)==1)
               A_Amp = desiredAmplitudes;
               if ~isnumeric(A_Amp) || rem(A_Amp,1)~=0 || A_Amp<0 || A_Amp>100
                    error('Amplitudes Must Be A Whole Numeric Percent value Between 0 and 100');
               end
          
            elseif (length(desiredAmplitudes)==2)
               A_Amp = desiredAmplitudes(1);
               B_Amp = desiredAmplitudes(2);
               if  ~isnumeric(A_Amp)|| rem(A_Amp,1)~=0 || A_Amp<0 || A_Amp>100
                    error('Amplitudes Must Be A Whole Numeric Percent value Between 0 and 100');
               end
               if ~ isnumeric(B_Amp) || rem(B_Amp,1)~=0 || B_Amp<0 || B_Amp>100
                    error('Amplitudes Must Be A Whole Numeric Percent value Between 0 and 100');
               end
           
            end
            
            
            %% Create Control Command
            
            if (isempty(B_Amp)) %Standard Mode
               commandLength = '02'; 
               commandID = '01';
               amp = dec2hex(A_Amp,2);
               commandBytes = [commandID;amp];
               
               [errorOrSuccess, deviceResponse] = self.processCommand(commandLength,commandBytes,getResponse,8); 
               
            else %Dual Mode
               commandLength = '03';
               commandID = '01';
               amp1 = dec2hex(A_Amp,2);
               amp2 = dec2hex(B_Amp,2);   
               commandBytes = [commandID;amp1;amp2];
        
               [errorOrSuccess, deviceResponse] =  self.processCommand(commandLength,commandBytes,getResponse,8); 
                
            end
            
                  
       end 
       
       %% 2.a Enabling The Desired Port
       function [errorOrSuccess, deviceResponse] = arm(self,varargin)
            % Inputs:
            % varargin<bool> refers to getResponse<bool> that can be True (1) or False (0)
            % indicating whether a response from device is required or not.
            % The default value is set to false.
            
            % Outputs:
            % deviceResponse: is the response that is sent back by the
            % device to the port indicating current information about the device
            % errorOrSuccess: is a boolean value indicating succecc = 0 or error = 1
            % in performing the desired task
            
                
               %% Check Input Validity
               if nargin <1
                    error('Not Enough Input Arguments');
               end
               if length(varargin)>1
                   error('Too Many Input Arguments');
               end
               if nargin <2
                  getResponse = false ; %Default value Set To 0
               else
                  getResponse = varargin{1};
               end
               if (getResponse ~= 0 && getResponse ~= 1 )
                   error('getResponse Must Be A Boolean');
               end
               
               %% Reconnect the stimulator
               if getResponse ==1                  
                    self.disconnect();
                    self.connect();
                    warning('In case of any problems, try reconnecting the device manually');
               end
               
            %% Create Control Command
               commandLength = '02'; 
               commandID = '02';
               value = '01';
               commandBytes = [commandID;value];
               
               [~, deviceResponse] =  self.processCommand(commandLength,commandBytes,getResponse,8);
                self.disconnect();
               [errorOrSuccess, ~] =  self.connect();
               warning('In case of any problems, try reconnecting the device manually');
       end
       
       
       %% 2.b Disabling The Desired Port
       function [errorOrSuccess, deviceResponse] = disarm(self,varargin)
            % Inputs:
            % varargin<bool> refers to getResponse<bool> that can be True (1) or False (0)
            % indicating whether a response from device is required or not.
            % The default value is set to false.
            
            % Outputs:
            % deviceResponse: is the response that is sent back by the
            % device to the port indicating current information about the device
            % errorOrSuccess: is a boolean value indicating succecc = 0 or error = 1
            % in performing the desired task
            
               %% Check Input Validity
               if nargin <1
                    error('Not Enough Input Arguments');
               end
               if length(varargin)>1
                   error('Too Many Input Arguments');
               end
               if nargin <2
                    getResponse = false ; %Default value Set To 0
               else
                    getResponse = varargin{1};
               end
               if (getResponse ~= 0 && getResponse ~= 1 )
                   error('getResponse Must Be A Boolean');
               end
              
            %% Create Control Command
               commandLength = '02'; 
               commandID = '02';
               value = '00';
               commandBytes = [commandID;value];
               
               [errorOrSuccess, deviceResponse] =  self.processCommand(commandLength,commandBytes,getResponse,8);
               
       end
       
       %% 3.Sending A Single Trig To The Specified Port
       function [errorOrSuccess, deviceResponse] = fire(self,varargin)
            % Inputs:
            % varargin<bool> refers to getResponse<bool> that can be True (1) or False (0)
            % indicating whether a response from device is required or not.
            % The default value is set to false.
            
            % Outputs:
            % deviceResponse: is the response that is sent back by the
            % device to the port indicating current information about the device
            % errorOrSuccess: is a boolean value indicating succecc = 0 or error = 1
            % in performing the desired task
            
               %% Check Input Validity
               if nargin <1
                    error('Not Enough Input Arguments');
               end
               if length(varargin)>1
                   error('Too Many Input Arguments');
               end
               if nargin <2
                    getResponse = false ; %Default value Set To 0
               else
                    getResponse = varargin{1};
               end
               if (getResponse ~= 0 && getResponse ~= 1 )
                   error('getResponse Must Be A Boolean');
               end
              
               %% Reconnect the stimulator
               if getResponse ==1                  
                    self.disconnect();
                    self.connect();
                    warning('In case of any problems, try reconnecting the device manually');
               end
           
            %% Create Control Command
               commandLength = '02'; 
               commandID = '03';
               value = '01';               
               commandBytes = [commandID;value];
               
               [errorOrSuccess, deviceResponse] =  self.processCommand(commandLength,commandBytes,getResponse,8); 

       end
       
       
       %% 4.Sending Train of Pulses To The Specified Port
       function [errorOrSuccess, deviceResponse] = sendTrain(self,varargin)
            % Inputs:
            % varargin<bool> refers to getResponse<bool> that can be True (1) or False (0)
            % indicating whether a response from device is required or not.
            % The default value is set to false.
            
            % Outputs:
            % deviceResponse: is the response that is sent back by the
            % device to the port indicating current information about the device
            % errorOrSuccess: is a boolean value indicating succecc = 0 or error = 1
            % in performing the desired task
            
                      
            %% Check Input Validity:
               if nargin <1
                    error('Not Enough Input Arguments');
               end
               if length(varargin)>1
                   error('Too Many Input Arguments');
               end
               if nargin <2
                    getResponse = false ; %Default value Set To 0
               else
                    getResponse = varargin{1};
               end
               if (getResponse ~= 0 && getResponse ~= 1 )
                   error('getResponse Must Be A Boolean');
               end
              
               %% Reconnect the stimulator
               if getResponse ==1                  
                    self.disconnect();
                    self.connect();
                    warning('In case of any problems, try reconnecting the device manually');
               end
        
            %% Create Control Command
               commandLength = '01'; 
               commandID = '04';               
               commandBytes = commandID;
               
               [errorOrSuccess, deviceResponse] =  self.processCommand(commandLength,commandBytes,getResponse,17); 
               
       end
       
       %% 5.Getting Status2 From Device
       function [errorOrSuccess, deviceResponse] = getStatus2(self)
            % Outputs:
            % deviceResponse: is the response that is sent back by the
            % device to the port indicating current information about the device
            % errorOrSuccess: is a boolean value indicating succecc = 0 or error = 1
            % in performing the desired task
            
        %% Reconnect the stimulat
            self.disconnect();
            self.connect();
            warning('In case of any problems, try reconnecting the device manually');

        %% Create Control Command
            commandLength = '01'; 
            commandID = '05';               
            commandBytes = commandID;
             
            getResponse = 1; 
            [errorOrSuccess, deviceResponse] =  self.processCommand(commandLength,commandBytes,getResponse,19); 
           
       end
       
       %% 6.Setting Train Parameters
       function [errorOrSuccess, deviceResponse] = setTrain(self,repRate,pulses,numberOfTrains,iti,varargin)
            % Inputs:
            % repRate <int>: represents the number of pulses per second
            % pulses <int>: represents the number of pulses in each train
            % numberOfTrains <int>: represents the total amount of trains
            % arriving in one sequencese
            % iti <int>: represents time interval between two trains in seconds, described 
            % as the time period between the last pulse in the first train to the first pulse in the next train.
            % varargin<bool>: refers to getResponse<bool> that can be True (1) or False (0)
            % indicating whether a response from device is required or not.
            % The default value is set to false.
            
            % Outputs:
            % deviceResponse: is the response that is sent back by the
            % device to the port indicating current information about the device
            % errorOrSuccess: is a boolean value indicating succecc = 0 or error = 1
            % in performing the desired task
            
           
            %% Check Input Validity:
            if nargin <5
                 error('Not Enough Input Arguments');
            end
            if length(varargin)>1
                error('Too Many Input Arguments');
            end
            if nargin <6
                    getResponse = false ; %Default value Set To 0
            else
                    getResponse = varargin{1};
            end
            if (getResponse ~= 0 && getResponse ~= 1 )
                   error('getResponse Must Be A Boolean');
            end
            
            %% Reconnect the stimulator
            if getResponse ==1                  
                self.disconnect();
                self.connect();
                warning('In case of any problems, try reconnecting the device manually');
            end
              
            if (length(repRate)~=1 || length(pulses)~=1 || length(numberOfTrains)~=1 || length(iti)~=1)
                error('All Train Parameters Must Be Of length 1');
            end
            if rem(repRate,1)~=0 || repRate<0
                error('The Repitition Rate Must Be A Whole Positive Integer');
            end
            repRateRange = [0.1:0.1:1 1:1:100];
            if ~ismember(repRate,repRateRange)
                error('repRate Out Of Bounds');
            end
            
            if rem(pulses,1)~=0 || pulses<0
                error('The Number of Pulses Must Be A Whole Positive Integer');
            end
            pulsesRange = [1:1:100 1000:100:2000];
            if ~ismember(pulses,pulsesRange)
                error('Pulses Out Of Bounds');
            end
            
            if rem(numberOfTrains,1)~=0 || numberOfTrains<0
                error('The Total Number of Trains Must Be A Whole Positive Integer');
            end
            numberOfTrainsRange = 1:1:500;
            if ~ismember(numberOfTrains,numberOfTrainsRange)
                error('numberOfTrains Out Of Bounds');
            end
            
            if ~(isnumeric(iti)) || iti<0
                error('The Inter Train Interval Must Be A Positive Number');
            end
            itiRange = 0.1:0.1:120;
            if ~ismember(iti,itiRange)
                error('iti Out Of Bounds');
            end
           
            
            %% Create Control Command
               commandLength = '09'; 
               commandID = '06';
               
               repRate = repRate*10; %Rep Rate is in tenth
               repRate = dec2hex(repRate,4); %'4' is because we want all hex numbers to appear in 4 digits
               repRate_L = repRate(3:4); %Extracting LSB part
               repRate_M = repRate(1:2); %Extracting MSB part
               
               pulses = dec2hex(pulses,4);
               pulses_L = pulses(3:4);
               pulses_M = pulses(1:2);
               
               numberOfTrains = dec2hex(numberOfTrains,4);
               numTrain_L = numberOfTrains(3:4);
               numTrain_M = numberOfTrains(1:2);
               
               iti = iti*10; %iti is in tenth
               iti = dec2hex(iti,4);
               iti_L = iti(3:4);
               iti_M = iti(1:2);
               
               commandBytes = [commandID;repRate_M;repRate_L;pulses_M;pulses_L;numTrain_M;numTrain_L;iti_M;iti_L];
               
               [errorOrSuccess, deviceResponse] =  self.processCommand(commandLength,commandBytes,getResponse,8);
               
               %% Check if device is on train page

       end
       
       
       %% 7.Setting Page
       function [errorOrSuccess, deviceResponse] = setPage(self,page,varargin)
            % Inputs:
            % page <char>: defines the page. Valid inputs in magventure:
            % 'Main','Train','Trig','Config','Protocol'
            % varargin<bool>: refers to getResponse<bool> that can be True (1) or False (0)
            % indicating whether a response from device is required or not.
            % The default value is set to false.
            
            % Outputs:
            % deviceResponse: is the response that is sent back by the
            % device to the port indicating current information about the device
            % errorOrSuccess: is a boolean value indicating succecc = 0 or error = 1
            % in performing the desired task

            %% Check Input Validity:
            if nargin <2
                 error('Not Enough Input Arguments');
            end
            if length(varargin)>1
                error('Too Many Input Arguments');
            end
            if nargin <3
                 getResponse = false ; %Default value Set To 0
            else
                getResponse = varargin{1};
            end
            if (getResponse ~= 0 && getResponse ~= 1 )
                   error('getResponse Must Be A Boolean');
            end
            
            %% Reconnect the stimulator
            if getResponse ==1                  
                self.disconnect();
                self.connect();
                warning('In case of any problems, try reconnecting the device manually');
            end
            
            if ~(ischar(page))
                error('The Page Name Which Shown On magventure Must Be a Character Array');
            end
            if ~(strcmp(page,'Main') || strcmp(page,'Train')|| strcmp(page,'Trig')|| strcmp(page,'Config')|| strcmp(page,'Protocol'))
                error('Invalid Page Name');
            end
           
            %% Configuring The Desired Page
            switch page
                case 'Main'
                    pageN = '01';
                case 'Train'
                    pageN = '02';
                case 'Trig'
                    pageN = '03';
                case 'Config'
                    pageN = '04';
                case 'Protocol'
                    pageN = '07';
            end
            %% Create Control Command
               commandLength = '03'; 
               commandID = '07'; 
               NAByte = '00';
               commandBytes = [commandID;pageN;NAByte];
               
               [errorOrSuccess, deviceResponse] =  self.processCommand(commandLength,commandBytes,getResponse,8);
               
       end
       
       
       %% 8.Setting Trig and Charge delay Parameters
       function [errorOrSuccess, deviceResponse] = setTrig_ChargeDelay(self,trigInDelay,trigOutDelay,chargeDelay,varargin)
            % Inputs:
            % trigInDelay <int>: allows setting a delay in milliseconds from the time
            % of arrival of an external trigger input to the time for the magnetic stimulation to be provided.
            % trigOutDelay <signed int>: allows setting a delay in milliseconds from 
            % the time of the magnetic stimulation to the time of the external trigger to be provided.
            % chargeDelay <int>: defines the time in milliseconds to make the device wait, before
            % recharging.
            % varargin<bool>: refers to getResponse<bool> that can be True (1) or False (0)
            % indicating whether a response from device is required or not.
            % The default value is set to false.
            
            % Outputs:
            % deviceResponse: is the response that is sent back by the
            % device to the port indicating current information about the device
            % errorOrSuccess: is a boolean value indicating succecc = 0 or error = 1
            % in performing the desired task
            
            
           
            %% Check Input Validity:
            if nargin <4
                 error('Not Enough Input Arguments');
            end
            if length(varargin)>1
                 error('Too Many Input Arguments');
            end
            if nargin <5
                 getResponse = false ; %Default value Set To 0
            else
                getResponse = varargin{1};
            end
            if (getResponse ~= 0 && getResponse ~= 1 )
                   error('getResponse Must Be A Boolean');
            end
            
        %% Reconnect the stimulator
            if getResponse ==1                  
                self.disconnect();
                self.connect();
                warning('In case of any problems, try reconnecting the device manually');
            end
        %%              
            if (length(trigInDelay)~=1 || length(trigOutDelay)~=1 || length(chargeDelay)~=1)
                error('All Trig & Charge Parameters Must Be Of length 1');
            end
            if  rem(trigInDelay,1)~=0 || trigInDelay<0
                error('The Delay For Input Trig Must Be A Whole Positive Integer');
            end
            if (trigInDelay>65535) %Must fit into a four digit hex number
                error('repRate Out Of Bounds');
            end
            if  rem(trigOutDelay,1)~=0
                error('The Delay For Output Trig Must Be A Whole Integer');
            end
            if (trigOutDelay>65535)
                error('trigOutDelay Out Of Bounds');
            end
            if  rem(chargeDelay,1)~=0 || chargeDelay<0
                error('The Charge Delay of Trains Must Be A Whole Positive Integer');
            end
            if (chargeDelay>65535)
                error('chargeDelay Out Of Bounds');
            end
           
            %% Create Control Command
               commandLength = '09'; 
               commandID = '08';
               
               trigInDelay = trigInDelay*10; %trigInDelay is in tenth
               trigInDelay = dec2hex(trigInDelay,4); %'4' is because we want all hex numbers to appear in 4 digits
               trigInDelay_L = trigInDelay(3:4); %Extracting LSB part
               trigInDelay_M = trigInDelay(1:2); %Extracting MSB part
               
               trigOutDelay = trigOutDelay*10; %trigOutDelay is in tenth
               if trigOutDelay>=0 %Output trig delay can be of negative sign
                   trigOutDelay = dec2hex(trigOutDelay,4);
                   trigOutDelay_L = trigOutDelay(3:4);
                   trigOutDelay_M = trigOutDelay(1:2);
               else %For negative output trig delay
                   unsignedvalue = -trigOutDelay;
                   Complement = hex2dec('FFFF') - unsignedvalue;
                   trigOutDelay = dec2hex(Complement+1);
                   trigOutDelay_L = trigOutDelay(3:4);
                   trigOutDelay_M = trigOutDelay(1:2);
               end
               
               chargeDelay = dec2hex(chargeDelay,4);
               chargeDelay_L = chargeDelay(3:4);
               chargeDelay_M = chargeDelay(1:2);
               
               NAByte1 = '00';
               NAByte2 = '00';
               
               
               commandBytes = [commandID;trigInDelay_M;trigInDelay_L;trigOutDelay_M;trigOutDelay_L;...
                   chargeDelay_M;chargeDelay_L;NAByte1;NAByte2];
               
               [errorOrSuccess, deviceResponse] =  self.processCommand(commandLength,commandBytes,getResponse,8);
               
       end
      
       
       
 %% 9.a.1 : Setting Mode
       function [errorOrSuccess, deviceResponse] = setMode(self, mode, currentDirection, burstPulses,...
               ipiValue, BARatioValue, varargin)
            % Inputs:
            % mode <char>: defines the desired working mode. Valid inputs in magventure:
            % 'Standard','Power','Twin','Dual'
            % currentDirection <char>: defines current direction of the device in the current status.
            % Valid inputs in magventure:'Normal','Reverse'
            % burstPulses <int>: Biphasic Burst index in the current status of the device which can 
            % be 2,3,4, or 5 pulses in each stimulation. 
            % ipiValue <int>: represents Inter Pulse Interval of the current status of the device 
            % which defines the duration between the beginning of the first pulse to the beginning of 
            % the second pulse.
            % BARatioValue <int>: when working in Twin Mode, the amplitude of the two pulses A and B are 
            % controlled in an adjustable ratio between 0.2-5.0. "Pulse B" is now adjusted to a selected 
            % percent ratio proportional to "Pulse A".
            % varargin<bool>: refers to getResponse<bool> that can be True (1) or False (0)
            % indicating whether a response from device is required or not.
            % The default value is set to false.
            
            % Outputs:
            % deviceResponse: is the response that is sent back by the
            % device to the port indicating current information about the device
            % errorOrSuccess: is a boolean value indicating succecc = 0 or error = 1
            % in performing the desired task
            
           
            %% Check Input Validity:
            if nargin <2
                 error('Not Enough Input Arguments');
            end
            if length(varargin)>1
                 error('Too Many Input Arguments');
            end
            if nargin <3
                 getResponse = false ; %Default value Set To 0
            else
                getResponse = varargin{1};
            end
            if (getResponse ~= 0 && getResponse ~= 1 )
                   error('getResponse Must Be A Boolean');
            end
           
            if ~(ischar(mode))
                error('The Mode Identifier in magventure Must Be a Character Array');
            end
            if ~(strcmp(mode,'Standard') || strcmp(mode,'Power')|| strcmp(mode,'Twin')|| strcmp(mode,'Dual'))
                error('Invalid Mode Identifier');
            end
            
            %% Configuring The Desired Mode
            switch mode
                case 'Standard'
                    modeN = '00';
                case 'Power'
                    modeN = '01';
                case 'Twin'
                    modeN = '02';
                case 'Dual'
                    modeN = '03';
            end
            
            %% Create Control Command
               commandLength = '0B'; 
               commandID = '09';
               setVal = '01';

               %% Creating Output
              [errorOrSuccess, rawInfo] = self.getStatusSetGet;
              if errorOrSuccess~=0
                 error('Could Not Retrieve Required Info From the Device');
              end
               
               model = rawInfo.Model; 
               waveform = rawInfo.Waveform;
               
               currentDir = currentDirection;
               
              switch burstPulses
                case 2
                    burstPulseIndex = '03';
                case 3
                    burstPulseIndex = '02';
                case 4
                    burstPulseIndex = '01';
                case 5
                    burstPulseIndex = '00';
              end
               
               ipi = dec2hex((ipiValue*10),4);
               ipi_M = ipi(1:2);
               ipi_L = ipi(3:4);
               BARatio = dec2hex((BARatioValue*100),4);
               BARatio_M = BARatio(1:2);
               BARatio_L = BARatio(3:4);
               
                %% Reconnect the stimulator 
                if getResponse
                 self.disconnect();
                 self.connect();
                 warning('In case of any problems, try reconnecting the device manually');
                end
               %%
            
               commandBytes = [commandID;setVal;model;modeN;currentDir;waveform;burstPulseIndex;ipi_M;ipi_L;...
                   BARatio_M;BARatio_L];
               
               [errorOrSuccess, deviceResponse] =  self.processCommand(commandLength,commandBytes,getResponse,14);
                   
       end
       %% 9.a.2 : Getting Mode 
        function [errorOrSuccess, deviceResponse] = getMode(self)
            
            % Outputs:
            % deviceResponse: is the response that is sent back by the
            % device to the port indicating current information about the device
            % errorOrSuccess: is a boolean value indicating succecc = 0 or error = 1
            % in performing the desired task
            
            %% Reconnect the stimulator                 
                self.disconnect();
                self.connect();
                warning('In case of any problems, try reconnecting the device manually');
            %%
            
            %% Check Input Validity:
            if nargin <1
                 error('Not Enough Input Arguments');
            end
           
            %% Create Control Command
            commandLength = '0B'; 
            commandID = '09';
            setVal = '00'; %For get commands
            model = '00';
            mode = '00';
            currentDir = '00';
            waveform = '00';
            burstPulses = '00';
            ipi_M = '00';
            ipi_L = '00';
            BARatio_M = '00';
            BARatio_L = '00';
            
            commandBytes = [commandID;setVal;model;mode;currentDir;waveform;burstPulses;ipi_M;ipi_L;...
                BARatio_M;BARatio_L];
            
            getResponse = true;
            [errorOrSuccess, deviceResponse] =  self.processCommand(commandLength,commandBytes,getResponse,14);
            
            deviceResponse = deviceResponse.Mode;
        end
        
        
       
       
       %% 9.b.1 : Setting Waveform
       function [errorOrSuccess, deviceResponse] = setWaveform(self,waveform,currentDirection,burstPulses,...
               ipiValue,BARatioValue,varargin)
   
            % Inputs:
            % waveform <char>: defines the desired waveform. Valid inputs in magventure:
            % 'Monophasic','Biphasic','HalfSine','BiphasicBurst'
            % currentDirection <char>: defines current direction of the device in the current status.
            % Valid inputs in magventure:'Normal','Reverse'
            % burstPulses <int>: Biphasic Burst index in the current status of the device which can 
            % be 2,3,4, or 5 pulses in each stimulation. 
            % ipiValue <int>: represents Inter Pulse Interval of the current status of the device 
            % which defines the duration between the beginning of the first pulse to the beginning of 
            % the second pulse.
            % BARatioValue <int>: when working in Twin Mode, the amplitude of the two pulses A and B are 
            % controlled in an adjustable ratio between 0.2-5.0. "Pulse B" is now adjusted to a selected 
            % percent ratio proportional to "Pulse A".
            % varargin<bool>: refers to getResponse<bool> that can be True (1) or False (0)
            % indicating whether a response from device is required or not.
            % The default value is set to false.
            
            % Outputs:
            % deviceResponse: is the response that is sent back by the
            % device to the port indicating current information about the device
            % errorOrSuccess: is a boolean value indicating succecc = 0 or error = 1
            % in performing the desired task
            
            
            %% Check Input Validity:
            if nargin <2
                 error('Not Enough Input Arguments');
            end
            if length(varargin)>1
                 error('Too Many Input Arguments');
            end
            if nargin <3
                 getResponse = false ; %Default value Set To 0
            else
                getResponse = varargin{1};
            end
            if (getResponse ~= 0 && getResponse ~= 1 )
                   error('getResponse Must Be A Boolean');
            end
           
            if ~(ischar(waveform))
                error('The Waveform Name in magventure Must Be a Character Array');
            end
            if ~(strcmp(waveform,'Monophasic') || strcmp(waveform,'Biphasic')|| strcmp(waveform,'HalfSine')|| strcmp(waveform,'BiphasicBurst'))
                error('Invalid Waveform');
            end
            
            %% Configuring The Desired Waveform
            switch waveform
                case 'Monophasic'
                    waveformN = '00';
                case 'Biphasic'
                    waveformN = '01';
                case 'HalfSine'
                    waveformN = '02';
                case 'BiphasicBurst'
                    waveformN = '03';
            end
            
            %% Create Control Command
               commandLength = '0B'; 
               commandID = '09';
               setVal = '01';
               
               %% Creating Output
              [errorOrSuccess, rawInfo] = self.getStatusSetGet;
              if errorOrSuccess~=0
                 error('Could Not Retrieve Required Info From the Device');
              end
               
               model = rawInfo.Model; 
               mode = rawInfo.Mode;               
               currentDir = currentDirection;
              switch burstPulses
                case 2
                    burstPulseIndex = '03';
                case 3
                    burstPulseIndex = '02';
                case 4
                    burstPulseIndex = '01';
                case 5
                    burstPulseIndex = '00';
              end
               ipi = dec2hex((ipiValue*10),4);
               ipi_M = ipi(1:2);
               ipi_L = ipi(3:4);
               BARatio = dec2hex((BARatioValue*100),4);
               BARatio_M = BARatio(1:2);
               BARatio_L = BARatio(3:4);
               
              
               
                %% Reconnect the stimulator 
                if getResponse
                 self.disconnect();
                 self.connect();
                 warning('In case of any problems, try reconnecting the device manually');
                end
               %%
            
               commandBytes = [commandID;setVal;model;mode;currentDir;waveformN;burstPulseIndex;ipi_M;ipi_L;BARatio_M;BARatio_L];
               
               [errorOrSuccess, deviceResponse] =  self.processCommand(commandLength,commandBytes,getResponse,14);
               
       end
       
       %% 9.b.2 : Getting Waveform
       function [errorOrSuccess, deviceResponse] = getWaveform(self)
            % Inputs:
            % waveform <char> defines the desired waveform. Valid inputs in magventure:
            % 'Monophasic','Biphasic','HalfSine','BiphasicBurst'
            % varargin<bool> refers to getResponse<bool> that can be True (1) or False (0)
            % indicating whether a response from device is required or not.
            % The default is set to false.
            
            % Outputs:
            % deviceResponse: is the response that is sent back by the
            % device to the port indicating current information about the device
            % errorOrSuccess: is a boolean value indicating succecc = 0 or error = 1
            % in performing the desired task
            
            
            %% Reconnect the stimulator                 
                self.disconnect();
                self.connect();
                warning('In case of any problems, try reconnecting the device manually');
            %%
            %% Check Input Validity:
            if nargin <1
                 error('Not Enough Input Arguments');
            end
           
            %% Create Control Command
            commandLength = '0B'; 
            commandID = '09';
            setVal = '00'; %For get commands
            model = '00';
            mode = '00';
            currentDir = '00';
            waveform = '00';
            burstPulses = '00';
            ipi_M = '00';
            ipi_L = '00';
            BARatio_M = '00';
            BARatio_L = '00';
            
            commandBytes = [commandID;setVal;model;mode;currentDir;waveform;burstPulses;ipi_M;ipi_L;...
                BARatio_M;BARatio_L];
            
            getResponse = true;
            [errorOrSuccess, deviceResponse] =  self.processCommand(commandLength,commandBytes,getResponse,14);
            
            deviceResponse = deviceResponse.Waveform;
        end
       
       
       %% 9.c.1 : Setting Current Direction
       function [errorOrSuccess, deviceResponse] = setCurrentDir(self,currentDir,burstPulses,...
               ipiValue, BARatioValue,varargin)
           
            % Inputs:
            % currentDir <char>: defines the desired current direction. Valid inputs in magventure:
            % 'Normal','Reverse'
            % burstPulses <int>: Biphasic Burst index in the current status of the device which can 
            % be 2,3,4, or 5 pulses in each stimulation. 
            % ipiValue <int>: represents Inter Pulse Interval of the current status of the device 
            % which defines the duration between the beginning of the first pulse to the beginning of 
            % the second pulse.
            % BARatioValue <int>: when working in Twin Mode, the amplitude of the two pulses A and B are 
            % controlled in an adjustable ratio between 0.2-5.0. "Pulse B" is now adjusted to a selected 
            % percent ratio proportional to "Pulse A".
            % varargin<bool>: refers to getResponse<bool> that can be True (1) or False (0)
            % indicating whether a response from device is required or not.
            % The default value is set to false.
            
            % Outputs:
            % deviceResponse: is the response that is sent back by the
            % device to the port indicating current information about the device
            % errorOrSuccess: is a boolean value indicating succecc = 0 or error = 1
            % in performing the desired task
            
           
            %% Check Input Validity:
            if nargin <2
                 error('Not Enough Input Arguments');
            end
            if length(varargin)>1
                 error('Too Many Input Arguments');
            end
            if nargin <3
                 getResponse = false ; %Default value Set To 0
            else
                getResponse = varargin{1};
            end
            if (getResponse ~= 0 && getResponse ~= 1 )
                   error('getResponse Must Be A Boolean');
            end
            
            if ~(ischar(currentDir))
                error('The Current Direction in magventure Must Be Defined By A Character Array');
            end
            if ~(strcmp(currentDir,'Normal') || strcmp(currentDir,'Reverse'))
                error('Invalid Current Direction');
            end
            
            %% Configuring The Desired Current Direction
            switch currentDir
                case 'Normal'
                    currentDirN = '00';
                case 'Reverse'
                    currentDirN = '01';
            end
            
            %% Create Control Command
               commandLength = '0B'; 
               commandID = '09';
               setVal = '01';
               
            %% Create Output
               [errorOrSuccess, rawInfo] = self.getStatusSetGet;
               if errorOrSuccess~=0
                 error('Could Not Retrieve Required Info From the Device');
               end
               model = rawInfo.Model; 
               mode = rawInfo.Mode;
               waveform = rawInfo.Waveform;
               
               switch burstPulses
                case 2
                    burstPulseIndex = '03';
                case 3
                    burstPulseIndex = '02';
                case 4
                    burstPulseIndex = '01';
                case 5
                    burstPulseIndex = '00';
               end
               ipi = dec2hex((ipiValue*10),4);
               ipi_M = ipi(1:2);
               ipi_L = ipi(3:4);
               BARatio = dec2hex((BARatioValue*100),4);
               BARatio_M = BARatio(1:2);
               BARatio_L = BARatio(3:4);   
              
               
                %% Reconnect the stimulator 
                if getResponse
                 self.disconnect();
                 self.connect();
                 warning('In case of any problems, try reconnecting the device manually');
                end
               %%
            
               commandBytes = [commandID;setVal;model;mode;currentDirN;waveform;burstPulseIndex;ipi_M;ipi_L;...
                   BARatio_M;BARatio_L];
               
               [errorOrSuccess, deviceResponse] =  self.processCommand(commandLength,commandBytes,getResponse,14);

       end
       %% 9.c.2 : Getting Current Direction
       function [errorOrSuccess, deviceResponse] = getCurrentDir(self)
            
            % Outputs:
            % deviceResponse: is the response that is sent back by the
            % device to the port indicating current information about the device
            % errorOrSuccess: is a boolean value indicating succecc = 0 or error = 1
            % in performing the desired task
            
            %% Reconnect the stimulator                 
                self.disconnect();
                self.connect();
                warning('In case of any problems, try reconnecting the device manually');
            %%
            
            %% Check Input Validity:
            if nargin <1
                 error('Not Enough Input Arguments');
            end
           
            %% Create Control Command
            commandLength = '0B'; 
            commandID = '09';
            setVal = '00'; %For get commands
            model = '00';
            mode = '00';
            currentDir = '00';
            waveform = '00';
            burstPulses = '00';
            ipi_M = '00';
            ipi_L = '00';
            BARatio_M = '00';
            BARatio_L = '00';
            
            commandBytes = [commandID;setVal;model;mode;currentDir;waveform;burstPulses;ipi_M;ipi_L;...
                BARatio_M;BARatio_L];
            
            getResponse = true;
            [errorOrSuccess, deviceResponse] =  self.processCommand(commandLength,commandBytes,getResponse,14);
            
            deviceResponse = deviceResponse.currentDirection;
       end
        
       %% 9.d.1 : Setting Burst Pulses 
       function [errorOrSuccess, deviceResponse] = setBurst(self,burstPulses,currentDirection,...
               ipiValue,BARatioValue,varargin)
            % Inputs:
            % burstPulse <int>: Biphasic Burst can be selected with 2,3,4, or 5 pulses in each stimulation. 
            % Valid inputs in magventure: 2,3,4,5
            % currentDirection <char>: defines current direction of the device in the current status.
            % Valid inputs in magventure:'Normal','Reverse'
            % ipiValue <int>: represents Inter Pulse Interval of the current status of the device 
            % which defines the duration between the beginning of the first pulse to the beginning of 
            % the second pulse.
            % BARatioValue <int>: when working in Twin Mode, the amplitude of the two pulses A and B are 
            % controlled in an adjustable ratio between 0.2-5.0. "Pulse B" is now adjusted to a selected 
            % percent ratio proportional to "Pulse A".
            % varargin<bool>: refers to getResponse<bool> that can be True (1) or False (0)
            % indicating whether a response from device is required or not.
            % The default value is set to false.
            
            % Outputs:
            % deviceResponse: is the response that is sent back by the
            % device to the port indicating current information about the device
            % errorOrSuccess: is a boolean value indicating succecc = 0 or error = 1
            % in performing the desired task
            
         
            %% Check Input Validity:
            if nargin <2
                 error('Not Enough Input Arguments');
            end
            if length(varargin)>1
                 error('Too Many Input Arguments');
            end
            if nargin <3
                 getResponse = false ; %Default value Set To 0
            else
                getResponse = varargin{1};
            end
            if (getResponse ~= 0 && getResponse ~= 1 )
                   error('getResponse Must Be A Boolean');
            end
         
            if ~(isnumeric(burstPulses))
                error('The Number Of Burst Pulses In Each Stimulation Must Be A Number');
            end
            if (burstPulses ~= 2 && burstPulses ~= 3 && burstPulses ~= 4 && burstPulses ~= 5)
                error('Invalid Number Of Burst Pulses');
            end
          
            %% Configuring The Desired Burst Pulses
            switch burstPulses
                case 2
                    burstPulseIndex = '03';
                case 3
                    burstPulseIndex = '02';
                case 4
                    burstPulseIndex = '01';
                case 5
                    burstPulseIndex = '00';
            end
            
            %% Create Control Command
               commandLength = '0B'; 
               commandID = '09';
               setVal = '01';
               
               
              %% Creating Output
              [errorOrSuccess, rawInfo] = self.getStatusSetGet;
              if errorOrSuccess~=0
                 error('Could Not Retrieve Required Info From the Device');
              end
               
               model = rawInfo.Model; 
               mode = rawInfo.Mode;
               waveform = rawInfo.Waveform;
               
               currentDir = currentDirection;
               ipi = dec2hex((ipiValue*10),4);
               ipi_M = ipi(1:2);
               ipi_L = ipi(3:4);
               BARatio = dec2hex((BARatioValue*100),4);
               BARatio_M = BARatio(1:2);
               BARatio_L = BARatio(3:4);
               
               %% Reconnect the stimulator 
               if getResponse
                 self.disconnect();
                 self.connect();
                 warning('In case of any problems, try reconnecting the device manually');
               end
               %%
            
               commandBytes = [commandID;setVal;model;mode;currentDir;waveform;burstPulseIndex;ipi_M;ipi_L;...
                   BARatio_M;BARatio_L];
               
               [errorOrSuccess, deviceResponse] =  self.processCommand(commandLength,commandBytes,getResponse,14);
               
       end
       %% 9.d.2 : Getting Burst Pulses 
   function [errorOrSuccess, deviceResponse] = getBurst(self)
            
            % Outputs:
            % deviceResponse: is the response that is sent back by the
            % device to the port indicating current information about the device
            % errorOrSuccess: is a boolean value indicating succecc = 0 or error = 1
            % in performing the desired task
            
            %% Reconnect the stimulator                 
                self.disconnect();
                self.connect();
                warning('In case of any problems, try reconnecting the device manually');
            %%
            
            %% Check Input Validity:
            if nargin <1
                 error('Not Enough Input Arguments');
            end
           
            %% Create Control Command
            commandLength = '0B'; 
            commandID = '09';
            setVal = '00'; %For get commands
            model = '00';
            mode = '00';
            currentDir = '00';
            waveform = '00';
            burstPulses = '00';
            ipi_M = '00';
            ipi_L = '00';
            BARatio_M = '00';
            BARatio_L = '00';
            
            commandBytes = [commandID;setVal;model;mode;currentDir;waveform;burstPulses;ipi_M;ipi_L;...
                BARatio_M;BARatio_L];
            
            getResponse = true;
            [errorOrSuccess, deviceResponse] =  self.processCommand(commandLength,commandBytes,getResponse,14);
            
            deviceResponse = deviceResponse.burstPulsesIndex;
       end
        
       
       
       %% 9.e.1 : Setting Interpulse Interval
       function [errorOrSuccess, deviceResponse] = setIPI(self,ipi,currentDirection, burstPulses,...
             BARatioValue,varargin)
            % Inputs:
            % ipi <int>: represents Inter Pulse Interval which defines the duration between 
            % the beginning of the first pulse to the beginning of the second pulse.
            % currentDirection <char>: defines current direction of the device in the current status.
            % Valid inputs in magventure:'Normal','Reverse'
            % burstPulses <int>: Biphasic Burst index in the current status of the device which can 
            % be 2,3,4, or 5 pulses in each stimulation. 
            % BARatioValue <int>: when working in Twin Mode, the amplitude of the two pulses A and B are 
            % controlled in an adjustable ratio between 0.2-5.0. "Pulse B" is now adjusted to a selected 
            % percent ratio proportional to "Pulse A".
            % varargin<bool>: refers to getResponse<bool> that can be True (1) or False (0)
            % indicating whether a response from device is required or not.
            % The default value is set to false.
            
            % Outputs:
            % deviceResponse: is the response that is sent back by the
            % device to the port indicating current information about the device
            % errorOrSuccess: is a boolean value indicating succecc = 0 or error = 1
            % in performing the desired task
  
            %% Check Input Validity:
            if nargin <2
                 error('Not Enough Input Arguments');
            end
            if length(varargin)>1
                 error('Too Many Input Arguments');
            end
            if nargin <3
                 getResponse = false ; %Default value Set To 0
            else
                getResponse = varargin{1};
            end
            if (getResponse ~= 0 && getResponse ~= 1 )
                   error('getResponse Must Be A Boolean');
            end
           
            if ~(isnumeric(ipi)) || ipi<0
                error('The ipi value Must Be A Positive Number');
            end
            ipiRange = [0.5:0.1:10 10:0.5:20 20:1:100 100:10:500 500:50:1000 1000:100:3000];
            if ~ismember(ipi,ipiRange)
                error('ipi Out Of Bounds');
            end
            
          
            %% Configuring The Desired ipi value
               ipi = ipi*10; %ipi is in tenth
               ipi = dec2hex(ipi,4); %'4' is because we want all hex numbers to appear in 4 digits
               ipi_L = ipi(3:4); %Extracting LSB part
               ipi_M = ipi(1:2); %Extracting MSB part
     
            %% Create Control Command
               commandLength = '0B'; 
               commandID = '09';
               setVal = '01';
               
                %% Creating Output
              [errorOrSuccess, rawInfo] = self.getStatusSetGet;
              if errorOrSuccess~=0
                 error('Could Not Retrieve Required Info From the Device');
              end
               
               model = rawInfo.Model; 
               mode = rawInfo.Mode;
               waveform = rawInfo.Waveform;
               
               currentDir = currentDirection;
               switch burstPulses
                  case 2
                    burstPulseIndex = '03';
                  case 3
                    burstPulseIndex = '02';
                  case 4
                    burstPulseIndex = '01';
                  case 5
                    burstPulseIndex = '00';
               end
               BARatio = dec2hex((BARatioValue*100),4);
               BARatio_M = BARatio(1:2);
               BARatio_L = BARatio(3:4);
               
               
               %% Reconnect the stimulator 
               if getResponse
                 self.disconnect();
                 self.connect();
                 warning('In case of any problems, try reconnecting the device manually');
               end
               %%
            
               commandBytes = [commandID;setVal;model;mode;currentDir;waveform;burstPulseIndex;ipi_M;ipi_L;...
                   BARatio_M;BARatio_L];
               
               [errorOrSuccess, deviceResponse] =  self.processCommand(commandLength,commandBytes,getResponse,14);
       end
       
       %% 9.e.2 : Getting Interpulse Interval
       function [errorOrSuccess, deviceResponse] = getIPI(self)
            
            % Outputs:
            % deviceResponse: is the response that is sent back by the
            % device to the port indicating current information about the device
            % errorOrSuccess: is a boolean value indicating succecc = 0 or error = 1
            % in performing the desired task
            
            %% Reconnect the stimulator                 
                self.disconnect();
                self.connect();
                warning('In case of any problems, try reconnecting the device manually');
            %%
            %% Check Input Validity:
            if nargin <1
                 error('Not Enough Input Arguments');
            end
           
            %% Create Control Command
            commandLength = '0B'; 
            commandID = '09';
            setVal = '00'; %For get commands
            model = '00';
            mode = '00';
            currentDir = '00';
            waveform = '00';
            burstPulses = '00';
            ipi_M = '00';
            ipi_L = '00';
            BARatio_M = '00';
            BARatio_L = '00';
            
            commandBytes = [commandID;setVal;model;mode;currentDir;waveform;burstPulses;ipi_M;ipi_L;...
                BARatio_M;BARatio_L];
            
            getResponse = true;
            [errorOrSuccess, deviceResponse] =  self.processCommand(commandLength,commandBytes,getResponse,14);
            
            deviceResponse = deviceResponse.ipivalue;
       end
       
       %% 9.f.1 : Setting B/A Ratio
       function [errorOrSuccess, deviceResponse] = setBARatio(self,BARatio,currentDirection, burstPulses,...
               ipiValue,varargin)
            % Inputs:
            % BARatio <int>: when working in Twin Mode, the amplitude of the two pulses A and B are controlled in an 
            % adjustable ratio between 0.2-5.0. "Pulse B" is now adjusting to a selected percent ratio 
            % proportional to "Pulse A"
            % currentDirection <char>: defines current direction of the device in the current status.
            % Valid inputs in magventure:'Normal','Reverse'
            % burstPulses <int>: Biphasic Burst index in the current status of the device which can 
            % be 2,3,4, or 5 pulses in each stimulation. 
            % ipiValue <int>: represents Inter Pulse Interval of the current status of the device 
            % which defines the duration between the beginning of the first pulse to the beginning of 
            % the second pulse.
            % varargin<bool>: refers to getResponse<bool> that can be True (1) or False (0)
            % indicating whether a response from device is required or not.
            % The default value is set to false.
            
            % Outputs:
            % deviceResponse: is the response that is sent back by the
            % device to the port indicating current information about the device
            % errorOrSuccess: is a boolean value indicating succecc = 0 or error = 1
            % in performing the desired task

            %% Check Input Validity:
            if nargin <2
                 error('Not Enough Input Arguments');
            end
            if length(varargin)>1
                 error('Too Many Input Arguments');
            end
            if nargin <3
                 getResponse = false ; %Default value Set To 0
            else
                getResponse = varargin{1};
            end
            if (getResponse ~= 0 && getResponse ~= 1 )
                   error('getResponse Must Be A Boolean');
            end
         
            if ~(isnumeric(BARatio)) || BARatio<0
                error('The B/A Ratio Must Be A Positive Number');
            end
            BARatioRange = 0.2:0.05:5;
            if ~ismember(BARatio,BARatioRange)
                error('B/A Ratio Out Of Bounds');
            end
            
            
            %% Configuring The Desired B/A Ratio
               BARatio = BARatio*100; %BARatio is in tenth
               BARatio = dec2hex(BARatio,4); %'4' is because we want all hex numbers to appear in 4 digits
               BARatio_L = BARatio(3:4); %Extracting LSB part
               BARatio_M = BARatio(1:2); %Extracting MSB part
     
            %% Create Control Command
               commandLength = '0B'; 
               commandID = '09';
               setVal = '01';
               
            %% Creating Output
               [errorOrSuccess, rawInfo] = self.getStatusSetGet;
               if errorOrSuccess~=0
                 error('Could Not Retrieve Required Info From the Device');
               end
               
               model = rawInfo.Model;
               mode = rawInfo.Mode;
               waveform = rawInfo.Waveform;
               
               currentDir = currentDirection;
               switch burstPulses
                 case 2
                    burstPulseIndex = '03';
                 case 3
                    burstPulseIndex = '02';
                 case 4
                    burstPulseIndex = '01';
                 case 5
                    burstPulseIndex = '00';
               end    
               ipi = dec2hex((ipiValue*10),4);
               ipi_M = ipi(1:2);
               ipi_L = ipi(3:4);
               
               %% Reconnect the stimulator 
               if getResponse
                 self.disconnect();
                 self.connect();
                 warning('In case of any problems, try reconnecting the device manually');
               end
               %%
            
               commandBytes = [commandID;setVal;model;mode;currentDir;waveform;burstPulseIndex;ipi_M;ipi_L;...
                   BARatio_M;BARatio_L];
               
               [errorOrSuccess, deviceResponse] =  self.processCommand(commandLength,commandBytes,getResponse,14);
               
       end       
       %% 9.f.2 : Getting B/A Ratio
        function [errorOrSuccess, deviceResponse] = getBARatio(self)
            
            % Outputs:
            % deviceResponse: is the response that is sent back by the
            % device to the port indicating current information about the device
            % errorOrSuccess: is a boolean value indicating succecc = 0 or error = 1
            % in performing the desired task
            
            
            %% Reconnect the stimulator                 
                self.disconnect();
                self.connect();
                warning('In case of any problems, try reconnecting the device manually');
            %%
            
            %% Check Input Validity:
            if nargin <1
                 error('Not Enough Input Arguments');
            end
           
            %% Create Control Command
            commandLength = '0B'; 
            commandID = '09';
            setVal = '00'; %For get commands
            model = '00';
            mode = '00';
            currentDir = '00';
            waveform = '00';
            burstPulses = '00';
            ipi_M = '00';
            ipi_L = '00';
            BARatio_M = '00';
            BARatio_L = '00';
            
            commandBytes = [commandID;setVal;model;mode;currentDir;waveform;burstPulses;ipi_M;ipi_L;...
                BARatio_M;BARatio_L];
            
            getResponse = true;
            [errorOrSuccess, deviceResponse] =  self.processCommand(commandLength,commandBytes,getResponse,14);
            
            deviceResponse = deviceResponse.BA_Ratio;
       end
       
   
%%%%%%%%%%%%
  
       function [errorOrSuccess, deviceResponse] = processCommand(self,commandLength,commandBytes,getResponse,bytesExpected)
                %% Check If Port Is Connected
                if (self.connected == 0) %Check if port connected
                    error ('You Need To First Connect The Port');
                end
                
                %% Creat The Final Command Line
                startByte = 'FE';
                endByte = 'FF';
                checkSum = magventure.calcCRC(commandBytes); %Calculate the cheksum
                if length(checkSum)==1 
                    checkSum = strcat('0',checkSum);
                end
                sentControlCommand = hex2dec([startByte;commandLength;commandBytes;checkSum;endByte]); %Create the command line
                
                %% Write On The Port
                fwrite(self.port,sentControlCommand); 

                %% Creating The Desired Output
                if getResponse == 1 
                     %% Wait for the response from the stimulator for 3 s                        
                        elapsedTime = 0.0;
                        tic;
                        while elapsedTime < 3
                                elapsedTime = toc;
                        end
 
                     %% Read the response from the stimulator if any
                        if self.port.BytesAvailable > 0
                           readData = fread(self.port,bytesExpected); 
                           if length(readData) < (bytesExpected)
                                errorOrSuccess = 2;
                                deviceResponse = 'Incomplete response from device.';
                           else
                                errorOrSuccess = 0;
                                [~,deviceResponse] = self.parseResponse(readData);
                           end
                        else
                               errorOrSuccess = 1;
                               deviceResponse = 'No response detected from device.';
                        end
                 
                                             
               elseif getResponse == 2   %% In the set commands
                     %% Wait for the response from the stimulator for 3 s                        
                        elapsedTime = 0.0;
                        tic;
                        while elapsedTime < 8
                                elapsedTime = toc;
                        end
  
                     %% Read the response from the stimulator if any
                       if self.port.BytesAvailable > 0
                           readData = fread(self.port,bytesExpected); 
                           if length(readData) < (bytesExpected)
                                errorOrSuccess = 2;
                                deviceResponse = 'Incomplete response from device.';
                           else
                                errorOrSuccess = 0;
                                [deviceResponse,~] = self.parseResponse(readData);
                           end
                 
                       else
                               errorOrSuccess = 1;
                               deviceResponse = 'No response detected from device.';
                        
                       end
                elseif getResponse == 3   %% In the set/get internal call 
                    %% Wait for the response from the stimulator for 3 s                        
                        elapsedTime = 0.0;
                        tic;
                        while elapsedTime < 3
                                elapsedTime = toc;
                        end
 
                     %% Read the response from the stimulator if any
                        if self.port.BytesAvailable > 0
                           readData = fread(self.port,bytesExpected); 
                           if length(readData) < (bytesExpected)
                                errorOrSuccess = 2;
                                deviceResponse = 'Incomplete response from device.';
                           else
                                errorOrSuccess = 0;
                                [deviceResponse,~] = self.parseResponse(readData);
                           end
                        else
                               errorOrSuccess = 1;
                               deviceResponse = 'No response detected from device.';
                        end
                 
                else % getResponse = 0
                        errorOrSuccess = 0;
                        deviceResponse ='No response from device required';
                end
                
                
       end
     
       function [rawInfo, info] = parseResponse(self,readData)
           rawInfo = [];
           if readData(3)== 0 || readData(3)== 5 %Status 
               fourthByte = dec2bin(readData(4),8);
               modeBits = bin2dec(fourthByte(7:8));
               switch modeBits
                   case 0
                       mode = 'Standard';
                   case 1
                       mode = 'Power';
                   case 2
                       mode = 'Twin';
                   case 3
                       mode = 'Dual';
               end
               waveformBits = bin2dec(fourthByte(5:6));
               switch waveformBits
                   case 0
                       waveform = 'Monophasic';
                   case 1
                       waveform = 'Biphasic';
                   case 2
                       waveform = 'Half Sine';
                   case 3
                       waveform = 'Biphasic Burst';
               end
               statusBit = bin2dec(fourthByte(4));
               switch statusBit
                   case 0
                       Status = 'Disabled';
                   case 1
                       Status = 'Enabled';
               end
               modelBits = bin2dec(fourthByte(1:3));
               switch modelBits
                   case 0
                       model = 'R30';
                   case 1
                       model = 'X100';
                   case 2
                       model = 'R30+Option';
                   case 3
                       model = 'X100+Option';
                   case 4
                       model = 'R30+Option+Mono';
                   case 5
                       model = 'MST';
               end
     
               serialNo = hex2dec([dec2hex(readData(5)) dec2hex(readData(6)) dec2hex(readData(7))]);
               
               temperature = readData(8);
               coilTypeNo = readData(9);
               AmplitudeA = readData(10);
               AmplitudeB = readData(11);
               
               if readData(3)== 0
               
               info = struct('Mode',mode,'Waveform',waveform,'Status',Status,'Model',model,...
                         'SerialNo',serialNo,'Temperature',temperature,'coilTypeNo',coilTypeNo,...
                         'amplitudePercentage_A',AmplitudeA,'amplitudePercentage_B',AmplitudeB);
                     
               rawInfo = struct('Model',dec2hex(modelBits,2),'Mode',dec2hex(modeBits,2),...
                         'Waveform',dec2hex(waveformBits,2));
           
               elseif readData(3)== 5
                  originalAmplitudeA = readData(12);
                  originalAmplitudeB = readData(13);
                  factorAmplitudeA = readData(14);
                  factorAmplitudeB = readData(15);
                  
                  pageByte = readData(16);
                  switch pageByte
                      case 1
                          page = 'Main';
                      case 2
                          page = 'Train';
                      case 3
                          page = 'Trig';
                      case 4
                          page = 'Config';
                      case 6
                          page = 'Download';
                      case 7
                          page = 'Protocol';
                      case 8
                          page = 'MEP';
                      case 13
                          page = 'Service';
                      case 15
                          page = 'Treatment';
                      case 16
                          page = 'Treat Select';
                  end
                   
                  if readData(16)
                      trainOrprotocol = 'Running';
                  else
                      trainOrprotocol = 'stopped';
                  end
                   info = struct('Mode',mode,'Waveform',waveform,'Status',Status,'Model',model,...
                         'Temperature',temperature,'coilTypeNo',coilTypeNo,...
                         'amplitudePercentage_A',AmplitudeA,'amplitudePercentage_B',AmplitudeB,...
                         'originalAmplitudePercentage_A',originalAmplitudeA,'originalAmplitudePercentage_B',...
                         originalAmplitudeB,'factorAmplitudePercentage_A',factorAmplitudeA,'factorAmplitudePercentage_B',...
                         factorAmplitudeB,'Page',page,'trainOrprotocolStatus',trainOrprotocol);
                   
               end
               
           elseif (readData(3)== 1 || readData(3)== 2 || readData(3)== 3 || readData(3)== 6 ||...
                   readData(3)== 7 || readData(3)== 8 )
               sixthByte = dec2bin(readData(6),8);
               modeBits = bin2dec(sixthByte(7:8));
               switch modeBits
                   case 0
                       mode = 'Standard';
                   case 1
                       mode = 'Power';
                   case 2
                       mode = 'Twin';
                   case 3
                       mode = 'Dual';
               end
               waveformBits = bin2dec(sixthByte(5:6));
               switch waveformBits
                   case 0
                       waveform = 'Monophasic';
                   case 1
                       waveform = 'Biphasic';
                   case 2
                       waveform = 'Half Sine';
                   case 3
                       waveform = 'Biphasic Burst';
               end
               statusBit = bin2dec(sixthByte(4));
               switch statusBit
                   case 0
                       Status = 'Disabled';
                   case 1
                       Status = 'Enabled';
               end
               modelBits = bin2dec(sixthByte(1:3));
               switch modelBits
                   case 0
                       model = 'R30';
                   case 1
                       model = 'X100';
                   case 2
                       model = 'R30+Option';
                   case 3
                       model = 'X100+Option';
                   case 4
                       model = 'R30+Option+Mono';
                   case 5
                       model = 'MST';
               end
               if readData(3)== 1 %Amplitude
                     AmplitudeA = readData(4);
                     AmplitudeB = readData(5);
                               
                     
                     info = struct('amplitudePercentage_A',AmplitudeA,'amplitudePercentage_B',AmplitudeB,...
                         'Mode',mode,'Waveform',waveform,'Status',Status,'Model',model);
            
            
               elseif readData(3)== 2 %di/dt
                     DiDtA = readData(4);
                     DiDtB = readData(5);
                     
                     
                     info = struct('didtPercentage_A',DiDtA,'didtPercentage_B',DiDtB,...
                         'Mode',mode,'Waveform',waveform,'Status',Status,'Model',model);
            
               
               elseif (readData(3)== 3 || readData(3)== 6)%Temperature or Original Amplitude
                    temperature = readData(4);
                    coilType = readData(5);
                    
                    
                    info = struct('Temperature',temperature,'coilTypeNo',coilType,...
                         'Mode',mode,'Waveform',waveform,'Status',Status,'Model',model);
                    
               elseif readData(3)== 7 %Amplitude Factor
                    factorAmplitudeA = readData(4);
                    factorAmplitudeB = readData(5);
                    
                    
                    info = struct('factorAmplitudePercentage_A',factorAmplitudeA,...
                        'factorAmplitudePercentage_B',factorAmplitudeB,'Mode',mode,...
                        'Waveform',waveform,'Status',Status,'Model',model);
                     
               elseif readData(3)== 8 %Page and Train/Protocol Runnig status
                   pageByte = readData(4);
                   switch pageByte
                       case 1
                           page = 'Main';
                       case 2
                           page = 'Train';
                       case 3
                           page = 'Trig';
                       case 4
                           page = 'Config';
                       case 6
                           page = 'Download';
                       case 7
                           page = 'Protocol';
                       case 8
                           page = 'MEP';
                       case 13
                           page = 'Service';
                       case 15
                           page = 'Treatment';
                       case 16
                           page = 'Treat Select';
                   end
                   
                   trainSequenceStatus = readData(5); 
                   switch trainSequenceStatus
                       case 0
                           trainSequence = 'Stopped';
                       case 1
                           trainSequence = 'Running';
                   end
                   
                   
                   info = struct('Page',page,...
                        'trainSequenceStatus',trainSequence,'Mode',mode,...
                        'Waveform',waveform,'Status',Status,'Model',model);
                   
               end
               
           elseif readData(3)== 4 %MEP Min Max data
               MEP_maxAmplitude = bin2dec([dec2bin(readData(4),8) dec2bin(readData(5),8) ...
                   dec2bin(readData(6),8) dec2bin(readData(7),8)]);
               MEP_minAmplitude = bin2dec([dec2bin(readData(8),8) dec2bin(readData(9),8) ...
                   dec2bin(readData(10),8) dec2bin(readData(11),8)]);
               MEP_maxTime = bin2dec([dec2bin(readData(12),8) dec2bin(readData(13),8) ...
                   dec2bin(readData(14),8) dec2bin(readData(15),8)]);
               
               
               info = struct('MEPmaxAmplitude_uV',MEP_maxAmplitude,...
                     'MEPminAmplitude_uV',MEP_minAmplitude,'MEPmaxTime_uS',MEP_maxTime);
                   
                         
           elseif readData(3)== 9 %Get Response
                modelByte = readData(5);
                modeByte = readData(6);
                currentDirByte = readData(7);
                waveformByte = readData(8);
                burstPulsesIndexByte = readData(9);
                ipiIndex_LSBByte = readData(10);
                ipiIndex_MSBByte = readData(11);
                BARatioIndexByte = readData(12);
                
                switch  modeByte
                    case 0
                        mode = 'Standard';
                    case 1
                        mode = 'Power';
                    case 2
                        mode = 'Twin';
                    case 3
                        mode = 'Dual';
                end
                
                switch currentDirByte
                    case 0
                        currentDir = 'Normal';
                    case 1
                        currentDir = 'Reverse';
                end
                
                switch  waveformByte
                    case 0
                        waveform = 'Monophasic';
                    case 1
                        waveform = 'Biphasic';
                    case 2
                        waveform = 'Half Sine';
                    case 3
                        waveform = 'Biphasic Burst';
                end
                
                 switch  burstPulsesIndexByte
                    case 0
                        burstPulsesIndex = 5;
                    case 1
                        burstPulsesIndex = 4;
                    case 2
                        burstPulsesIndex = 3;
                    case 3
                        burstPulsesIndex = 2;
                 end
                 
                 ipiIndex = hex2dec([dec2hex(ipiIndex_MSBByte) dec2hex(ipiIndex_LSBByte)]);
                 if strcmp(mode,'Twin') || strcmp(mode,'Dual')
                     if (0<=ipiIndex && ipiIndex <= 20)
                         ipi = 3000 - ipiIndex*100;
                     elseif (20< ipiIndex && ipiIndex <= 30)
                         ipi = 1000 - (ipiIndex - 20)*50;
                     elseif (30< ipiIndex && ipiIndex <= 70)
                         ipi = 500 - (ipiIndex - 30)*10;
                     elseif (70< ipiIndex && ipiIndex <=150)
                         ipi = 100 - (ipiIndex - 70);
                     elseif (150< ipiIndex && ipiIndex <= 170)
                         ipi = 20 - (ipiIndex - 150)*0.5;
                     elseif (170< ipiIndex && ipiIndex < 260)
                         ipi = 10 - (ipiIndex - 170)*0.1;
                     elseif ipiIndex==260
                         ipi = 1;
                     end
                     ipi_flag = 1;
                     
                 elseif strcmp(waveform,'Biphasic Burst') 
                     if (0<=ipiIndex && ipiIndex <= 80)
                         ipi = 100 - ipiIndex;
                     elseif (80< ipiIndex && ipiIndex <= 100)
                         ipi = 20 - (ipiIndex - 80)*0.5;
                     elseif (100< ipiIndex && ipiIndex <= 195)
                         ipi = 10 - (ipiIndex - 100)*0.1;
                     
                     end
                     ipi_flag = 1;
                                          
                 else
                     ipi ='';
                     ipi_L = ''; %null value
                     ipi_M = '';
                     ipi_flag = 0;
                 end
                 
                 BARatio = 5 - BARatioIndexByte* 0.05;
                 
                 ipiReal = ipi;
                 BARatioReal = BARatio;
                 %% Extracting Raw info For Set Commands
                 
                 if (ipi_flag)
                    ipi = ipi*10; %ipi is in tenth
                    ipi = dec2hex(ipi,4); %'4' is because we want all hex numbers to appear in 4 digits
                    ipi_L = ipi(3:4); %Extracting LSB part
                    ipi_M = ipi(1:2); %Extracting MSB part
                 end
                 
                 BARatio = BARatio*100; %BARatio is in tenth
                 BARatio = dec2hex(BARatio,4); %'4' is because we want all hex numbers to appear in 4 digits
                 BARatio_L = BARatio(3:4); %Extracting LSB part
                 BARatio_M = BARatio(1:2); %Extracting MSB part
                 
                 rawInfo = struct('Model',dec2hex(modelByte,2),'Mode',dec2hex(modeByte,2),'currentDirection',...
                     dec2hex(currentDirByte,2),'Waveform',dec2hex(waveformByte,2),'burstPulsesIndex',...
                     dec2hex(burstPulsesIndexByte,2),'ipiValue_MSB',ipi_M,'ipiValue_LSB',ipi_L,'BARatio_MSB',...
                     BARatio_M,'BARatio_LSB',BARatio_L);
                 
                 %% Extracting Interpreted info For Get Commands
                 info = struct('Mode',mode,'currentDirection',currentDir,'Waveform',waveform,...
                         'burstPulsesIndex',burstPulsesIndex,'ipivalue',ipiReal,'BA_Ratio',BARatioReal);
      
           end
                            
       end
       
       
      %% Gets all current raw information from device for set commands
         function rawInfo = getInfo(self)
             
            %% Reconnect the stimulator                 
                self.disconnect();
                self.connect();
                warning('In case of any problems, try reconnecting the device manually');
            %%
            length = '0B'; 
            commandID = '09';
            setVal = '00'; %For get commands
            model = '00';
            mode = '00';
            currentDir = '00';
            waveform = '00';
            burstPulses = '00';
            ipi_M = '00';
            ipi_L = '00';
            BARatio_M = '00';
            BARatio_L = '00';
            
            commandBytes = [commandID;setVal;model;mode;currentDir;waveform;burstPulses;ipi_M;ipi_L;...
                BARatio_M;BARatio_L];
            
            getResponse = 2;
            [~,rawInfo] =  self.processCommand(length,commandBytes,getResponse,14);
            
            
         end
         
         %% Get info from device in set/get commands
         function [errorOrSuccess, deviceResponse] = getStatusSetGet(self)
            % Outputs:
            % deviceResponse: is the response that is sent back by the
            % device to the port indicating current information about the device
            % errorOrSuccess: is a boolean value indicating succecc = 0 or error = 1
            % in performing the desired task
        %% Reconnect the stimulator
            self.disconnect();
            self.connect();
            warning('In case of any problems, try reconnecting the device manually');
        %% Create Control Command
            commandLength = '01'; 
            commandID = '00';               
            commandBytes = commandID;
            
            getResponse = 3;
            [errorOrSuccess, deviceResponse] =  self.processCommand(commandLength,commandBytes,getResponse,13); 
           
       end
end    
   
   methods (Static)
         function checkSum = calcCRC(polyIn) % CRC8 (Dallas/Maxim) checksum using the polynomial X8 + X5 + X4 + 1
           
                polytoCheck = [];
                for i=1:size(polyIn,1) % Use of 'fliplr' to have the LSB first
                     polytoCheck = [polytoCheck fliplr(str2num(dec2bin(hex2dec(polyIn(i,:)),8)')')];
                end
                
                genPoly=[1 0 0 1 1 0 0 0 1]; % Dallas/Maxim generator polynomial
                polytoCheck=[polytoCheck 0 0 0 0 0 0 0 0]; %Append zeroes
            
                counter = length(genPoly);
                reg = polytoCheck(1:counter); %Initialize
            
                for j =(counter+1):length(polytoCheck)
                     if reg(1)==1;
                         reg = xor(reg,genPoly); %xor PolytoCheck with GenPoly
                     end
                     reg = [reg(2:end) polytoCheck(j)]; % Shift one place along and bring next digit down
                end

                if reg(1)==1;
                    reg = xor(reg,genPoly); %xor PolytoCheck with GenPoly
                end

                reg = fliplr(reg); %To have LSB first
                checkSum = dec2hex(bin2dec(num2str(reg(1:8))));
         end
             
    
   end
   
   
   
   
end
