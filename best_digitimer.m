classdef best_digitimer <handle    
    properties
        best_toolbox
        manual
        arduino
    end
    
    methods
        function obj = best_digitimer(best_toolbox)
            obj.best_toolbox=best_toolbox;
        end
        
        function setManualAmplitude(obj,Intensity,Stimulator)
            String1=['Set the Intensity of stimulator ''' Stimulator ''' to '''];
            String2=[num2str(Intensity) ''' mA, then hit the button.'];
            f=figure('Name','Digitimer | BEST Toolbox','numbertitle', 'off','ToolBar', 'none','MenuBar', 'none','WindowStyle', 'modal','Units', 'normal', 'Position', [0.30 0.5 .60 .20],'Resize','off','KeyPressFcn',@(~,~)Done);
            uicontrol( 'Style','text','Parent', f,'String',String1,'FontSize',30,'HorizontalAlignment','center','Units','normalized','Position',[0.05 0.5 1 0.4]);
            uicontrol( 'Style','text','Parent', f,'String',String2,'FontSize',30,'HorizontalAlignment','center','Units','normalized','Position',[0.05 0.25 1 0.4]);
            drawnow;
            tts(['Set the Intensity of stimulator ''' Stimulator ''' to ''' num2str(Intensity)]);
            waitfor(f)
            function Done
                disp clicked!!
                delete(f)
            end
            function CloseReqFcn
            end
        end
        
        function setAutomaticAmplitude(obj,Intensity)
        end
        
    end
end

