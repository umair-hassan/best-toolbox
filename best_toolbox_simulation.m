classdef best_toolbox_simulation < handle
    %%
    % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
    % BEST Toolbox class
    % This class defines a main object for entire toolbox functions
    %
    % by Ing. Umair Hassan (umair.hassan@drz-mainz.de)
    %
    % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%
    properties
        
        inputs; % 17.07 all inputs (arguments from the hl func and prepared trials from prepare trials functions goes here indexed wrt to method
        method; % all the history of methods run during this session goes here
        data;
        info;
        deleteA
        deleteB
        deleteC
        best_mep_measurement;
        best_mep_hotspot;
        best_mep_liveplot;
        best_mep_p2pamp;
        best_hotspot_plot;
        best_thresholding_pest; %thresholding inputs goes here
        best_threshold_mepplot;
        best_mep_descriptives;
        best_ioc_fitting;
        best_ioc_plot;
        best_ioc_outliers;
        curve;      % fitted curve (x,y) points goes here
        fitresult;  % results of fitted equation parameters goes here
        gof;        % results of fit goodnes rsquare, rmse etc goes here
        SI;         % stimulation intensities object values
        MEP;        % mep's object values
        SEM;        % standard error of mean (sem) object values
        ip_x;       % Inflection Point
        pt_x;       % Plateau
        th;         % Threshold
        MEP_clean;  % Outliers removed raw MEP values
        SI_clean;   % Corrosponding outliers removed raw SI values for MEPs
        MEP_Descriptives;
        trial;
        p;
        N;
        L;
        nextInt;
        SIcopy
        RMT;
        sim_mep;
        
        
        
    end
    
    methods
        
        function obj= best_toolbox_simulation ()
            
            load sim_mep.mat;
            obj.sim_mep=sim_mep';
            delete(instrfindall);
            obj.best_ioc_fitting.event=0;
            obj.best_mep_measurement.event=0;
            obj.best_mep_hotspot.event=0;
            obj.best_mep_liveplot.event=0;
            obj.best_mep_p2pamp.event=0;
            obj.best_hotspot_plot.event=0;
            obj.best_thresholding_pest.event=0;
            obj.best_threshold_mepplot.event=0;
            obj.best_mep_descriptives.event=0;
            obj.best_ioc_plot.event=0;
            obj.best_ioc_outliers.event=0;
            obj.best_mep_measurement.inA=1;
            obj.best_mep_measurement.id=0;
            obj.N=0;
            obj.best_mep_measurement.k1=0; %k1 is MEP, K2 is hotspot, k3 is threshold, k4 is IOC
            obj.best_mep_measurement.k2=0;
            obj.best_mep_measurement.k3=0;
            obj.best_mep_measurement.k4=0;
            
            obj.info.method=0;
            %iNITILIZATION FUNCTION COMMANDS CAN COME HERE AND THIS BEST
            %MAIN NAME CAN BE CHANGED TO BEST INITILIZE
            
            
            %%
            %
            %
            %
            %
            %
            %
            
            %             ----------------------------------
            %make another function for loading default values
            %
            
            %
            
            % common
            obj.inputs.stimuli=NaN;
            obj.inputs.iti=NaN;
            obj.inputs.isi=NaN;
            obj.inputs.trials=NaN;
            obj.inputs.stimunits=NaN;
            obj.inputs.mep_rmthreshold=NaN;
            obj.inputs.mep_amthreshold=NaN;     %active motor (am) threshold in volts %set default
            obj.inputs.mt_method=NaN;           %motor thresholding (mt) method in volts %set default
            obj.inputs.mep_onset=0.015;           %mep post trigger onset in seconds %set default
            obj.inputs.mep_offset=0.050;          %mep post trigger offset in seconds %set default
            
            
            
        end
        
        
        function best_mep(obj)
            obj.info.method=obj.info.method+1;
            obj.info.str=strcat('mep_',num2str(obj.info.method));
            obj.data.(obj.info.str).inputs=obj.inputs;
            % todo: obj.data.str.inputs should only save non NaN fields of
            obj.info.event.best_mep_amp=1;
            obj.info.event.best_mep_plot=1;
            obj.best_trialprep
            obj.best_stimloop
            
        end
        
        function best_trialprep(obj)
            
            %%  1. made stimulation vector ;
            % todo2 assert an error here if the stim vector is not equal to trials vector
            
            stimuli=repelem(obj.data.(obj.info.str).inputs.stimuli,obj.data.(obj.info.str).inputs.trials);
            stimuli=stimuli(randperm(length(stimuli)));
            obj.data.(obj.info.str).outputs.trials(:,1)=stimuli';
            
            %% 2. iti vector (for timer func) and timing sequence (for dbsp) vector ;
            
            jitter=(obj.data.(obj.info.str).inputs.iti(2)-obj.data.(obj.info.str).inputs.iti(1));
            iti=ones(1,length(stimuli))*obj.data.(obj.info.str).inputs.iti(1);
            iti=iti+rand(1,length(iti))*jitter;
            obj.data.(obj.info.str).outputs.trials(:,2)=(round(iti,3))';
            obj.data.(obj.info.str).outputs.trials(:,3)=(movsum(iti,[length(iti) 0]))';
            
        end
        
        function best_stimloop(obj)
            obj.info.trial=0;
            obj.info.trial_plotted=0;
            %% initiliaze MAGIC
            % rapid and magstim caluses have to be added up here too and its handling will have to be formulated
            %             delete(instrfindall);
            %             magventureObject = magventure('COM4'); %0808a
            %             magventureObject.connect;
            %             magventureObject.arm
            
            %% initiliaze DBSP
            %             rtcls = dbsp('10.10.10.1');
            %             clab = neurone_digitalout_clab_from_xml(xmlread('neuroneprotocol.xml')); %adapt this file name as per the inserted file name in the hardware handling module
            %
            % % % % %             if(obj.info.event.mt==1)
            % % % % %                 obj.mt_initialize;
            % % % % %             end
            
            %% set stimulation amp for the first trial using magic
            % use switch case to imply the mag vencture , mag stim and
            % rapid object
            %             magventureObject.setAmplitude(obj.data.(obj.info.str).outputs.trials((obj.info.trial+1),1));
            
            %% make timer call back, then stop fcn call back and then the loop stuff and put events marker into it
            
            %% timer callback
            function best_timerfcn(tobj,event,obj)
                obj.info.trial=obj.info.trial+1;
                tt=obj.info.trial
                %                 rtcls.sendPulse;
                %                 obj.data.(obj.info.str).outputs.rawdata(obj.info.trial,:)=rtcls.mep(1); % will have to pur the handle of right, left and APB or FDI muscle here, also there is a third muscle pinky muscle which is used sometime so add for that t00
                % also have to create for customizing scope but that will go in
                % hardware seetings
%                 obj.data.(obj.info.str).outputs.rawdata(obj.info.trial,:)=rand(1,1000);
                 obj.data.(obj.info.str).outputs.rawdata(obj.info.trial,:)=(obj.sim_mep)*(obj.data.(obj.info.str).outputs.trials((obj.info.trial),1));
                
                
                
                
                % % % % % % % %             obj.data.(obj.info.str).outputs.results
                % % % % % % % %             obj.data.(obj.info.str).outputs.rawdata
                % % % % % % % %             obj.data.(obj.info.str).outputs.trials
            end
            
         
            function best_timer_stopfcn(tobj,event,obj) % also give arg in magven for magstim and rapid
               
                obj.info.timeA(obj.info.trial,:)=toc;
                tic;
                %             magventureObject.setAmplitude(obj.data.(obj.info.str).outputs.trials((obj.info.trial+1),1));
                tobj.StartDelay=(obj.data.(obj.info.str).outputs.trials((obj.info.trial),2));
                if (obj.info.trial==length(obj.data.(obj.info.str).outputs.trials(:,2)))
                    stop(tobj);
                    disp('end');
                else
                    start(tobj);
                    if(obj.info.trial==1)
                        start(g);
                    end
                end
            end
            

            function best_gtimerfcn(gobj,event,obj)
                obj.info.trial_plotted=obj.info.trial_plotted+1;
                gg=obj.info.trial_plotted
                
                
                %add all the events handles here
                if (obj.info.event.best_mep_plot==1)
                    obj.best_mep_plot; end
                if (obj.info.event.best_mep_amp==1)
                    obj.best_mep_amp; end
                
                
            end
          
            t=timer('StartDelay', 0.1,'TasksToExecute', 1,'ExecutionMode', 'fixedRate');
            g=timer('StartDelay', 4,'Period',4,'TasksToExecute',length(obj.data.(obj.info.str).outputs.trials(:,1)),'ExecutionMode', 'fixedRate');
            t.TimerFcn={@best_timerfcn,obj};
            t.StopFcn={@best_timer_stopfcn,obj};
            
            g.TimerFcn={@best_gtimerfcn,obj};
            g.BusyMode       = 'queue';
            start(t)
            tic
            
 
        end
        function best_mep_plot(obj)
            figure(1)
            if (obj.info.trial_plotted>1) 
                if(obj.info.trial_plotted>2)
                delete(obj.info.handles.mean_mep_plot);
                end
                delete(obj.info.handles.current_mep_plot)
%                 set(obj.info.handles.current_mep_plot,'color',[0.75 0.75 0.75]);
                obj.info.handles.past_mep_plot=plot(obj.data.(obj.info.str).outputs.rawdata(obj.info.trial_plotted-1,:),'Color',[0.75 0.75 0.75]);
                hold on;
                obj.info.handles.mean_mep_plot=plot(mean(obj.data.(obj.info.str).outputs.rawdata),'color',[0,0,0],'LineWidth',1.5);
                hold on;
                
                
            end
            % plotting current trial
            obj.info.handles.current_mep_plot=plot(obj.data.(obj.info.str).outputs.rawdata(obj.info.trial_plotted,:),'Color',[1 0 0],'LineWidth',2);
            hold on;
            if (obj.info.trial_plotted>1)
                h_legend=[obj.info.handles.past_mep_plot; obj.info.handles.mean_mep_plot; obj.info.handles.current_mep_plot];
                l=legend(h_legend, 'Previous MEPs', 'Mean Plot', 'Current MEP');
                set(l,'Orientation','horizontal','Location', 'southoutside','FontSize',12);
            end
             
            
            
        end
        function best_mep_amp(obj)
            
            % give handle of post trigger offset and onset
            obj.data.(obj.info.str).outputs.trials(obj.info.trial_plotted,4)=abs(max(obj.data.(obj.info.str).outputs.rawdata(obj.info.trial_plotted,201:800)))+abs(min(obj.data.(obj.info.str).outputs.rawdata(obj.info.trial_plotted,201:800)));
            
            
            % epoch in the window
            % find max in that eopched 
            % find min in that eopch
            % take abs of that epoch
            % add both to find p2p
            % add it to corrosponding trial
            
            
        end
        
        %% function best_mep_descriptives(obj)
        
    end
end

%% FURTHER STEPS
%1. best_hotspot
%2. best_threshold am, mt as well as others
%3. ioc
%4. pp functions (mep n ioc)
%5. multiple stimulators mep, threshold, ioc 
%6. use the new flexi grid layout system for gui making and simulate it too
%7. rs EEG

