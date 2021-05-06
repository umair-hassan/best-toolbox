function wav = tts(txt,voice,pace,fs)
%TTS text to speech.
%   TTS (TXT) synthesizes speech from string TXT, and speaks it. The audio
%   format is mono, 16 bit, 16k Hz by default.
%   
%   WAV = TTS(TXT) does not vocalize but output to the variable WAV.
%
%   TTS(TXT,VOICE) uses the specific voice. Use TTS('','List') to see a
%   list of availble voices. Default is the first voice.
%
%   TTS(...,PACE) set the pace of speech to PACE. PACE ranges from 
%   -10 (slowest) to 10 (fastest). Default 0.
%
%   TTS(...,FS) set the sampling rate of the speech to FS kHz. FS must be
%   one of the following: 8000, 11025, 12000, 16000, 22050, 24000, 32000,
%       44100, 48000. Default 16.
%   
%   This function requires the Microsoft Win32 Speech API (SAPI).
%
%   Examples:
%       % Speak the text;
%       tts('I can speak.');
%       % List availble voices;
%       tts('I can speak.','List');
%       % Do not speak out, store the speech in a variable;
%       w = tts('I can speak.',[],-4,44100);
%       wavplay(w,44100);
%
%   See also WAVREAD, WAVWRITE, WAVPLAY.
% Written by Siyi Deng; 12-21-2007;
if ~ispc, error('Microsoft Win32 SAPI is required.'); end
if ~ischar(txt), error('First input must be string.'); end
SV = actxserver('SAPI.SpVoice');
TK = invoke(SV,'GetVoices');
if nargin > 1
    % Select voice;
    for k = 0:TK.Count-1
        if strcmpi(voice,TK.Item(k).GetDescription)
            SV.Voice = TK.Item(k);
            break;
        elseif strcmpi(voice,'list')
            disp(TK.Item(k).GetDescription);
        end
    end
    % Set pace;
    if nargin > 2
        if isempty(pace), pace = 0; end
        if abs(pace) > 10, pace = sign(pace)*10; end        
        SV.Rate = pace;
    end
end
if nargin < 4 || ~ismember(fs,[8000,11025,12000,16000,22050,24000,32000,...
        44100,48000]), fs = 16000; end
if nargout > 0
   % Output variable;
   MS = actxserver('SAPI.SpMemoryStream');
   MS.Format.Type = sprintf('SAFT%dkHz16BitMono',fix(fs/1000));
   SV.AudioOutputStream = MS;  
end
invoke(SV,'Speak',txt);
if nargout > 0
    % Convert uint8 to double precision;
    wav = reshape(double(invoke(MS,'GetData')),2,[])';
    wav = (wav(:,2)*256+wav(:,1))/32768;
    wav(wav >= 1) = wav(wav >= 1)-2;
    delete(MS);
    clear MS;
end
delete(SV); 
clear SV TK;
pause(0.2);
end % TTS;