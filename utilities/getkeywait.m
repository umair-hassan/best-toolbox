function [CH, RT] = getkeywait(P)
% GETKEYWAIT - get a key within a time limit
%   CH = GETKEYWAIT(P) waits for a keypress for a maximum of P seconds. P
%   should be a positive number. CH is a double representing the key
%   pressed key as an ascii number, including backspace (8), space (32),
%   enter (13), etc. If a non-ascii key (Ctrl, Alt, etc.) is pressed, CH
%   will be NaN.  If no key is pressed within P seconds, -1 is returned,
%   and if something went wrong during excution 0 is returned.
%   Without argument, GETKEYWAIT waits until a key is pressed.
%
%   [CH, RT] = GETKEYWAIT(..) returns the response time in seconds in RT.
%
%
%   Example:
%       disp('Press a key within 5 seconds') ;
%       [CH, DT] = getkeywait(5)
%
%   See also INPUT, GINPUT, WAITBAR, MSGBOX
%            GETKEY (File Exchange)
% version 3.0 (feb 2019)
% author : Jos van der Geest
% email  : samelinoa@gmail.com
% History
% 1.0 (2005) creation
% 2.0 (apr 2009) - expanded error check on input argument, changed return
% values when a non-ascii was pressed (now NaN), or when something went
% wrong (now 0); added comments ; slight change in coding
% 2.1 (jan 2012) - modified a few properties, included check is figure
%                  still exists (after comment on GETKEY on FEX by Andrew).
% 3.0 (feb 2019) - modernised ; without argument now waits until keypress ;
%                  added response time as output argument
% check input argument
t00 = tic ; 
narginchk(0,1) ;
if nargin == 0
    P = -1 ;
elseif numel(P)~=1 || ~isnumeric(P) || ~isfinite(P) || P <= 0
    error('Argument should be a positive scalar.') ;
end
if P > 0
    % set up the timer
    tt = timer ;
    tt.timerfcn = 'uiresume' ;
    tt.startdelay = P ;
end
% Set up the figure
% May be the position property should be individually tweaked to avoid visibility
callstr = 'set(gcbf, ''Userdata'', double(get(gcbf,''Currentcharacter''))) ; uiresume ' ;
fh = figure(...
    'name', 'Press a key', ...
    'keypressfcn', callstr, ...
    'windowstyle', 'modal', ...
    'numbertitle', 'off', ...
    'position', [0 0  1 1], ... % really small in the corner
    'userdata', -1) ;
% start the timer, if needed
if P > 0
    % adjust the timer start delay
    tt.startdelay = max(0.001, round(P - toc(t00),3)) ;
    start(tt) ;
end
try
    % Wait for something to happen or the timer to run out    
    uiwait ;
    RT = toc(t00) ; % response time since start of this function
    CH = get(fh, 'userdata') ;
    if isempty(CH) % a non-ascii key was pressed, return a NaN
        CH = NaN ;
    end 
catch
    % something went wrong, return zero.
    CH = 0 ;
    RT = NaN ;
end
% clean up the timer ...
if P > 0
    stop(tt) ;
    delete(tt) ;
end
% ... and figure
if ishandle(fh)
    delete(fh) ;
end
