function best_neurofus
clc; close all;
disp(' BEST Toolbox Version 0.2 | NeuroFUS System Planning');
pd=10;FontSize=12;
TransducerType=1;
AcousticFrequency='500.00';
ChannelPower='5.00';
ISPPA='30.00';
ISPTA='15.00';
PulseRepitionFrequency='10';PulseRepitionFrequencyUnits=1;
PulseDuration='43.7';PulseDurationUnits=1;
DutyCycle='43.7';
StimulusDuration='300';
ITI='7';
TransducerFocus='52.000';
Phase='0.0';

f = figure('Tag','BESTToolboxApplication_NeuroFUS Prototype 1','ToolBar','none','MenuBar','none','Name','BEST Toolbox','NumberTitle','off');
set(f,'Units','normalized', 'Position', [0.25 0.1 0.25 0.7]);
VBox=uix.VBox( 'Parent', f, 'Spacing', 5, 'Padding', 5  );

Header=uix.HBox('Parent',VBox,'Spacing', 15 ,'Padding',15 );
uicontrol( 'Style','text','Parent', Header,'String','NeuroFUS Parameters Planning','FontSize',14,'HorizontalAlignment','center','Units','normalized');

Header=uix.HBox('Parent',VBox,'Spacing', 5  ,'Padding',pd);
uicontrol( 'Style','text','Parent', Header,'String','Select Transducer:','FontSize',FontSize,'HorizontalAlignment','left','Units','normalized');
uicontrol( 'Style','popupmenu','Parent', Header ,'String',{'CTX-250-2 Channel','CTX-500-4 Channel'},'FontSize',FontSize,'Value',TransducerType,'HorizontalAlignment','center','Tag','TransducerType','Callback',@cb);
uicontrol( 'Style','text','Parent', Header,'String','','FontSize',FontSize,'HorizontalAlignment','left','Units','normalized');
set( Header, 'Widths', [200 -2 -1]);

Header=uix.HBox('Parent',VBox,'Spacing', 5 ,'Padding',pd );
uicontrol( 'Style','text','Parent', Header,'String','Acoustic Frequency (kHz):','FontSize',FontSize,'HorizontalAlignment','left','Units','normalized');
uicontrol( 'Style','edit','Parent', Header ,'String',AcousticFrequency,'FontSize',FontSize,'Tag','AcousticFrequency','Callback',@cb);
uicontrol( 'Style','text','Parent', Header,'String','','FontSize',FontSize,'HorizontalAlignment','left','Units','normalized');
set( Header, 'Widths', [200 -2 -1]);

Header=uix.HBox('Parent',VBox,'Spacing', 5 ,'Padding',pd );
uicontrol( 'Style','text','Parent', Header,'String','Channel Power (W/ch):','FontSize',FontSize,'HorizontalAlignment','left','Units','normalized');
uicontrol( 'Style','edit','Parent', Header ,'String',ChannelPower,'FontSize',FontSize,'Tag','ChannelPower','Callback',@cb);
uicontrol( 'Style','text','Parent', Header,'String','','FontSize',FontSize,'HorizontalAlignment','left','Units','normalized');
set( Header, 'Widths', [200 -2 -1]);

Header=uix.HBox('Parent',VBox,'Spacing', 5 ,'Padding',pd );
uicontrol( 'Style','text','Parent', Header,'String','ISPPA (W/Ch^2):','FontSize',FontSize,'HorizontalAlignment','left','Units','normalized');
uicontrol( 'Style','edit','Parent', Header ,'String',ISPPA,'FontSize',FontSize,'Tag','ISPPA','Callback',@cb);
uicontrol( 'Style','text','Parent', Header,'String','','FontSize',FontSize,'HorizontalAlignment','left','Units','normalized');
set( Header, 'Widths', [200 -2 -1]);

Header=uix.HBox('Parent',VBox,'Spacing', 5 ,'Padding',pd );
uicontrol( 'Style','text','Parent', Header,'String','ISPTA (W/Ch^2):','FontSize',FontSize,'HorizontalAlignment','left','Units','normalized');
uicontrol( 'Style','edit','Parent', Header ,'String',ISPTA,'FontSize',FontSize,'Tag','ISPTA','Callback',@cb);
uicontrol( 'Style','text','Parent', Header,'String','','FontSize',FontSize,'HorizontalAlignment','left','Units','normalized');
set( Header, 'Widths', [200 -2 -1]);

Header=uix.HBox('Parent',VBox,'Spacing', 5 ,'Padding',pd );
uicontrol( 'Style','text','Parent', Header,'String','Pulse Repition Frequency:','FontSize',FontSize,'HorizontalAlignment','left','Units','normalized');
uicontrol( 'Style','edit','Parent', Header ,'String',PulseRepitionFrequency,'FontSize',FontSize,'Tag','PulseRepitionFrequency','Callback',@cb);
uicontrol( 'Style','popupmenu','Parent', Header ,'String',{'Hz'},'FontSize',FontSize,'Value',PulseRepitionFrequencyUnits,'Tag','PulseRepitionFrequencyUnits','Callback',@cb);
set( Header, 'Widths', [200 -2 -1]);

Header=uix.HBox('Parent',VBox,'Spacing', 5 ,'Padding',pd );
uicontrol( 'Style','text','Parent', Header,'String','Pulse Duration:','FontSize',FontSize,'HorizontalAlignment','left','Units','normalized');
uicontrol( 'Style','edit','Parent', Header ,'String',PulseDuration,'FontSize',FontSize,'Tag','PulseDuration','Callback',@cb);
uicontrol( 'Style','popupmenu','Parent', Header ,'String',{'ms'},'FontSize',FontSize,'Value',PulseDurationUnits','Tag','PulseDurationUnits','Callback',@cb);
set( Header, 'Widths', [200 -2 -1]);

Header=uix.HBox('Parent',VBox,'Spacing', 5 ,'Padding',pd );
uicontrol( 'Style','text','Parent', Header,'String','Duty Cycle (%):','FontSize',FontSize,'HorizontalAlignment','left','Units','normalized');
uicontrol( 'Style','edit','Parent', Header ,'String',DutyCycle,'FontSize',FontSize,'Tag','DutyCycle','Callback',@cb);
uicontrol( 'Style','text','Parent', Header,'String','','FontSize',FontSize,'HorizontalAlignment','left','Units','normalized','Callback',@cb);
set( Header, 'Widths', [200 -2 -1]);

Header=uix.HBox('Parent',VBox,'Spacing', 5 ,'Padding',pd );
uicontrol( 'Style','text','Parent', Header,'String','Stimulus Duration (ms):','FontSize',FontSize,'HorizontalAlignment','left','Units','normalized');
uicontrol( 'Style','edit','Parent', Header ,'String',StimulusDuration,'FontSize',FontSize,'Tag','StimulusDuration','Callback',@cb);
uicontrol( 'Style','text','Parent', Header,'String','','FontSize',FontSize,'HorizontalAlignment','left','Units','normalized');
set( Header, 'Widths', [200 -2 -1]);

Header=uix.HBox('Parent',VBox,'Spacing', 5 ,'Padding',pd );
uicontrol( 'Style','text','Parent', Header,'String','Inter Trial Interval (s):','FontSize',FontSize,'HorizontalAlignment','left','Units','normalized');
uicontrol( 'Style','edit','Parent', Header ,'String',ITI,'FontSize',FontSize,'Tag','ITI','Callback',@cb);
uicontrol( 'Style','text','Parent', Header,'String','','FontSize',FontSize,'HorizontalAlignment','left','Units','normalized');
set( Header, 'Widths', [200 -2 -1]);

Header=uix.HBox('Parent',VBox,'Spacing', 5 ,'Padding',pd );
uicontrol( 'Style','text','Parent', Header,'String','Transducer Focus (mm):','FontSize',FontSize,'HorizontalAlignment','left','Units','normalized');
uicontrol( 'Style','edit','Parent', Header ,'String',TransducerFocus,'FontSize',FontSize,'Tag','TransducerFocus','Callback',@cb);
uicontrol( 'Style','text','Parent', Header,'String','','FontSize',FontSize,'HorizontalAlignment','left','Units','normalized');
set( Header, 'Widths', [200 -2 -1]);

Header=uix.HBox('Parent',VBox,'Spacing', 5  ,'Padding',pd);
uicontrol( 'Style','text','Parent', Header,'String','Phase (degrees):','FontSize',FontSize,'HorizontalAlignment','left','Units','normalized');
uicontrol( 'Style','edit','Parent', Header ,'String',Phase,'FontSize',FontSize,'Tag','Phase','Callback',@cb);
uicontrol( 'Style','text','Parent', Header,'String','','FontSize',FontSize,'HorizontalAlignment','left','Units','normalized');
set( Header, 'Widths', [200 -2 -1]);

    function cb(src,~)
        switch src.Tag
            case 'TransducerType'
            case 'AcousticFrequency'
            case 'ChannelPower'
                CP=str2num(src.String);
                if CP>30, error('Channel Power cannot be more than 30'); src.String='15';end
                
                pd=findobj('type', 'uicontrol', 'tag', 'PulseDuration');
                PD=str2num(pd.String);
                PD=PD/1000;
                
                prf=findobj('type', 'uicontrol', 'tag', 'PulseRepitionFrequency');
                PRF=str2num(prf.String);
                
                isppa=findobj('type', 'uicontrol', 'tag', 'ISPPA');
                
                ispta=findobj('type', 'uicontrol', 'tag', 'ISPTA');
                
                RMSPressure=CP*(0.67/30);
                ISPPANew=sqrt(RMSPressure)/0.015;
                PIINew=ISPPANew*PD;
                ISPTANew=PIINew*PRF;
                
                isppa.String=num2str(ISPPANew);
                ispta.String=num2str(ISPTANew);
                
            case 'ISPPA'
                ISPPANew=str2num(src.String);
                if ISPPANew>30, error('ISPPA cannot be more than 30'); src.String='15';end
                
                ispta=findobj('type', 'uicontrol', 'tag', 'ISPTA');
                ISPTANew=str2num(ispta.String);
                
                prf=findobj('type', 'uicontrol', 'tag', 'PulseRepitionFrequency');
                PRF=str2num(prf.String);
                
                PD=(ISPTANew/(ISPPANew*PRF));
                pd=findobj('type', 'uicontrol', 'tag', 'PulseDuration');
                pd.String=num2str(PD);
                
            case 'ISPTA'
                ISPTANew=str2num(src.String);
                if ISPTANew>30, error('ISPTA cannot be more than 30'); src.String='15';end
                
                isppa=findobj('type', 'uicontrol', 'tag', 'ISPPA');
                ISPPANew=str2num(isppa.String);
                
                pd=findobj('type', 'uicontrol', 'tag', 'PulseDuration');
                PD=str2num(pd.String);
                PD=PD/1000;
                
                PRF=(ISPTANew/(ISPPANew*PD));
                
                prf=findobj('type', 'uicontrol', 'tag', 'PulseRepitionFrequency');
                prf.String=num2str(PRF);
                
            case 'PulseRepitionFrequency'
                PRF=str2num(src.String);
                pd=findobj('type', 'uicontrol', 'tag', 'PulseDuration');
                PD=str2num(pd.String);
                dc=findobj('type', 'uicontrol', 'tag', 'DutyCycle');
                PRFinSEC=1/PRF;
                PDinSEC=PD/1000;
                DC=(100*PDinSEC)/PRFinSEC;
                dc.String=num2str(DC);
            case 'PulseRepitionFrequencyUnits'
            case 'PulseDuration'
                PD=str2num(src.String);
                prf=findobj('type', 'uicontrol', 'tag', 'PulseRepitionFrequency');
                PRF=str2num(prf.String);
                dc=findobj('type', 'uicontrol', 'tag', 'DutyCycle');
                PRFinSEC=1/PRF;
                PDinSEC=PD/1000;
                DC=(100*PDinSEC)/PRFinSEC;
                dc.String=num2str(DC);
            case 'PulseDurationUnits'
            case 'DutyCycle'
                DC=str2num(src.String);
                prf=findobj('type', 'uicontrol', 'tag', 'PulseRepitionFrequency');
                pd=findobj('type', 'uicontrol', 'tag', 'PulseDuration');
                PD=str2num(pd.String);
                PDinSEC=PD/1000;
                PRFinSEC=(100*PDinSEC)/DC;
                prf.String=num2str(1/PRFinSEC);
            case 'StimulusDuration'
            case 'ITI'
            case 'TransducerFocus'
            case 'Phase'         
        end
        
    end
end