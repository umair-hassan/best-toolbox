function frontthetaapp (strct,tg)
clc; close all;
disp(' bossdevice Fronttheta App runned');

%% initialization
NumberOfRows=size(strct,2);

if NumberOfRows<1, error('The configuration strcture input argument is not appropriately prepared'); end
if NumberOfRows>15, error('The input parameters exceeds maximum limit of 15 parameters, reduce the structure to 15 or less parameters'); end
% try
    %title
    %row 0 is labels
    % row 1 corrosponds to actual row
    %%
%     NumberOfRows=3
    pd=10;FontSize=13;
    f = figure('Tag','bossdevice Parameters App','ToolBar','none','MenuBar','none','Name','bossdevice Parameters App','NumberTitle','off');
    set(f,'Units','normalized', 'Position', [0.1 0.1 0.7 (NumberOfRows+2)*0.05]);
    VBox=uix.VBox( 'Parent', f, 'Spacing', 5, 'Padding', 5  );
    Header=uix.HBox('Parent',VBox,'Spacing', 15 ,'Padding',10 );
    uicontrol( 'Style','text','Parent', Header,'String','bossdevice Parameters App','FontSize',14,'HorizontalAlignment','center','Units','normalized');
    
    Header=uix.HBox('Parent',VBox,'Spacing', 5  ,'Padding',pd);
    uicontrol( 'Style','text','Parent', Header ,'String','Parameter','FontSize',FontSize,'HorizontalAlignment','center');
    uicontrol( 'Style','text','Parent', Header,'String','','FontSize',FontSize,'HorizontalAlignment','center','Units','normalized');
    uicontrol( 'Style','text','Parent', Header ,'String','Current Value','FontSize',FontSize,'HorizontalAlignment','center');
    uicontrol( 'Style','text','Parent', Header,'String','','FontSize',FontSize,'HorizontalAlignment','center','Units','normalized');
    uicontrol( 'Style','text','Parent', Header,'String','New Value','FontSize',FontSize,'HorizontalAlignment','center','Units','normalized');
    uicontrol( 'Style','text','Parent', Header,'String','','FontSize',FontSize,'HorizontalAlignment','center','Units','normalized');
    uicontrol( 'Style','text','Parent', Header,'String','Update','FontSize',FontSize,'HorizontalAlignment','center','Units','normalized');
    uicontrol( 'Style','text','Parent', Header,'String','','FontSize',FontSize,'HorizontalAlignment','center','Units','normalized');
    set( Header, 'Widths', [-1.5 -0.5 -1 -0.5 -1 -0.5 -0.5 -0.5]);
    for i=1:NumberOfRows
        value=['value' num2str(i)];
        Header=uix.HBox('Parent',VBox,'Spacing', 5  ,'Padding',pd);
        uicontrol( 'Style','text','Parent', Header ,'String',strct(i).label,'FontSize',FontSize,'HorizontalAlignment','left');
        uicontrol( 'Style','text','Parent', Header,'String','','FontSize',FontSize,'HorizontalAlignment','left','Units','normalized');
        currentvaluebox.(value)=uicontrol( 'Style','edit','Parent', Header ,'String','','FontSize',FontSize,'HorizontalAlignment','center','Enable','off');
        uicontrol( 'Style','text','Parent', Header,'String','','FontSize',FontSize,'HorizontalAlignment','left','Units','normalized');
        if strcmp(strct(i).type,'signal')
            setvaluebox.(value)=uicontrol( 'Style','edit','Parent', Header,'String','','FontSize',FontSize,'HorizontalAlignment','center','Enable','off','Units','normalized');
            uicontrol( 'Style','text','Parent', Header,'String','','FontSize',FontSize,'HorizontalAlignment','left','Units','normalized');
            uicontrol( 'Style','pushbutton','Parent', Header,'String','update','FontSize',FontSize,'HorizontalAlignment','left','Enable','off','Units','normalized');
        elseif strcmp(strct(i).type,'parameter')
            setvaluebox.(value)=uicontrol( 'Style','edit','Parent', Header,'String','','FontSize',FontSize,'HorizontalAlignment','center','Units','normalized');
            uicontrol( 'Style','text','Parent', Header,'String','','FontSize',FontSize,'HorizontalAlignment','left','Units','normalized');
            uicontrol( 'Style','pushbutton','Parent', Header,'String','update','FontSize',FontSize,'HorizontalAlignment','left','Tag',num2str(i),'Units','normalized','callback',@cb);
        end
        
        uicontrol( 'Style','text','Parent', Header,'String','','FontSize',FontSize,'HorizontalAlignment','left','Units','normalized');
        set( Header, 'Widths', [-1.5 -0.5 -1 -0.5 -1 -0.5 -0.5 -0.5]);
    end
    
    %%
% catch
%     error('The configuration strcture input argument is not appropriately prepared');
% end

    function cb(src,~)
        setvalue=[];
        %src.Tag
        childstrct=['value' src.Tag];
        setvalue=str2num(setvaluebox.(childstrct).String);
        %strct(str2double(src.Tag)).path
        %strct(str2double(src.Tag)).parametername
        setparam(tg,strct(str2num(src.Tag)).path,strct(str2num(src.Tag)).parametername,setvalue)
        currentvaluebox.(childstrct).String=num2str(getparam(tg,strct(str2num(src.Tag)).path,strct(str2num(src.Tag)).parametername));
    end
end

% 
% close all;clc;clear;
% 
% str(1).type='parameter';
% str(1).label='Min ITI';
% str(1).path='TRG';
% str(1).parametername='min_inter_trig_interval';

% % str(2).type='parameter';
% % str(2).label='EMG Noise thershold';
% % str(2).path='QLY';
% % str(2).parametername='eeg_artifact_threshold';




