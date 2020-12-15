function BEST
%% Introduction
%% Handle Previously Opened Application
PreviousSession=findobj('Tag','BESTToolboxApplication');
if ~isempty(PreviousSession)
    answer = questdlg('A new BEST Toolbox Application session was just called, do you want to proceed to a new session by closing current one? Note that this session will be saved and cleared if so.','BEST Toolbox','No','Yes, Open New','No');
    switch answer
        case 'Yes, Open New'
            evalin( 'base', 'best_toolbox=best_application;' )
        case 'No'
            return
    end
else
    %% Creating Application
    evalin( 'base', 'best_toolbox=best_application;' )
end