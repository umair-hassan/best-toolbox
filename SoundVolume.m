function volume = SoundVolume(volume)
%SoundVolume set/get the system speaker sound volume
%
%   SoundVolume sets or gets the computer's system speaker sound volume
%
%   Syntax:
%      volume = SoundVolume(volume);
%
%   SoundVolume(volume) sets the system speaker sound volume. The volume
%   value should be numeric, between 0.0 (=muted) and 1.0 (=max).
%
%   volume = SoundVolume gets the current speaker sound volume (0.0-1.0).
%
%   volume = SoundVolume(volume) sets the system speaker sound volume and
%   returns the previous volume value (from before setting the new value).
%
%   Warning:
%     This code heavily relies on Java. It works on Matlab 7+
%
%   Bugs and suggestions:
%     Please send to Yair Altman (altmany at gmail dot com)
%
%   Change log:
%     2009-Oct-15: First version posted on MathWorks File Exchange: <a href="http://www.mathworks.com/matlabcentral/fileexchange/authors/27420">http://www.mathworks.com/matlabcentral/fileexchange/authors/27420</a>
%     2009-Nov-03: Fixed some edge-cases - D. Nguyen
%     2014-May-09: Fix for Windows 7
%
%   See also:
%     <a href="http://UndocumentedMatlab.com">http://UndocumentedMatlab.com</a>, <a href="http://java.sun.com/docs/books/tutorial/sound">http://java.sun.com/docs/books/tutorial/sound</a>
% License to use and modify this code is granted freely without warranty to all, as long as the original author is
% referenced and attributed as such. The original author maintains the right to be solely associated with this work.
% Programmed and Copyright by Yair M. Altman: altmany(at)gmail.com
% $Revision: 1.3 $  $Date: 2014/05/09 18:43:38 $
    % Check for available Java/AWT (not sure if Swing is really needed so let's just check AWT)
    if ~usejava('awt')
        error('YMA:SoundVolume:noJava','SoundVolume only works on Matlab envs that run on java');
    end
    % Args check
    if nargin && (~isnumeric(volume) || length(volume)~=1 || volume<0 || volume>1)
        error('YMA:SoundVolume:badVolume','Volume value must be a scalar number between 0.0 and 1.0')
    end
    % Loop over all the system's MixerInfo objects to find the speaker port
    % Note: we should have used line=AudioSystem.getLine(Port.Info.SPEAKER) directly, as in http://forums.sun.com/thread.jspa?messageID=10736264#10736264
    % ^^^^  but unfortunately Matlab prevents using Java Interfaces and/or classnames containing a period
    import javax.sound.sampled.*
    mixerInfos = AudioSystem.getMixerInfo;
    foundFlag = 0;
    for mixerIdx = 1 : length(mixerInfos)
        if foundFlag,  break;  end
        % ports = AudioSystem.getMixer(mixerInfos(mixerIdx)).getTargetLineInfo;  % => not allowed in Matlab for some reason (bug)
        ports = getTargetLineInfo(AudioSystem.getMixer(mixerInfos(mixerIdx)));
        for portIdx = 1 : length(ports)
            port = ports(portIdx);
            try
                portName = port.getName;  % better
            catch   
                portName = port.toString; % sub-optimal
            end
            if ~isempty(strfind(lower(char(portName)),'speaker'))
                foundFlag = 1;
                break;
            end
        end
    end
    if ~foundFlag
        error('YMA:SoundVolume:noSpeakerPort','Speaker port not found');
    end
    
    % Get and open the speaker port's Line object
    line = AudioSystem.getLine(port);
    line.open();
    % Loop over all the Line's controls to find the Volume control
    % Note: we should have used ctrl=line.getControl(FloatControl.Type.VOLUME) directly, as in http://forums.sun.com/thread.jspa?messageID=10736264#10736264
    % ^^^^  but unfortunately Matlab prevents using Java Interfaces and/or classnames containing a period
    ctrls = line.getControls;
    foundFlag = 0;
    for ctrlIdx = 1 : length(ctrls)
        ctrl = ctrls(ctrlIdx);
        ctrlType = ctrls(ctrlIdx).getType;
        try
            ctrlType = char(ctrlType);
        catch  
            % Solves some edge-cases - D. Nguyen
            ctrlType = char(ctrlType.toString);
        end
        if ~isempty(strfind(lower(ctrlType),'volume'))
            foundFlag = 1;
            break;
        end
    end
    if ~foundFlag
        error('YMA:SoundVolume:noVolumeControl','Speaker volume control not found');
    end
    
    % Get or set the volume value according to the user request
    oldValue = ctrl.getValue;
    if nargin
        ctrl.setValue(volume);
    end
    if nargout
        volume = oldValue;
    end
    
%end  % SoundVolume
