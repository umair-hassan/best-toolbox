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
            String=['Set the Intensity of stimulator ''' Stimulator ''' to ''' num2str(Intensity) ''' mA, then click "Done" button.'];
            f=figure('Name','Digitimer | BEST Toolbox','numbertitle', 'off','ToolBar', 'none','MenuBar', 'none','WindowStyle', 'modal','Units', 'normal', 'Position', [0.5 0.5 .35 .05],'Resize','off','CloseRequestFcn',@(~,~)CloseReqFcn);
            uicontrol( 'Style','text','Parent', f,'String',String,'FontSize',12,'HorizontalAlignment','center','Units','normalized','Position',[0.05 0.5 1 0.4]);
            uicontrol( 'Style','pushbutton','Parent', f,'String','Done','FontSize',11,'HorizontalAlignment','center','Units','normalized','Position',[0.4 0.05 0.2 0.4],'Callback',@(~,~)Done);
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

