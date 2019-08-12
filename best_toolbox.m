classdef best_toolbox < handle
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
        
        
        
    end
    
    methods
        
        function obj= best_toolbox ()
            
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
            obj.inputs.mep_amthreshold=NaN;     %active motor (am) threshold
            obj.inputs.mt_method=NaN;           %motor thresholding (mt) method
            
            
            
        end
        
        
        function best_mep(obj)
            obj.info.method=obj.info.method+1;
            obj.info.str=strcat('mep_',num2str(obj.info.method));
            obj.data.(obj.info.str).inputs=obj.inputs;
            % todo: obj.data.str.inputs should only save non NaN fields of
            
            obj.info.event.best_mep_read=1;
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
            %% initiliaze MAGIC
            % rapid and magstim caluses have to be added up here too and its handling will have to be formulated
            %             delete(instrfindall);
            %             magventureObject = magventure('COM4'); %0808a
            %             magventureObject.connect;
            %             magventureObject.arm
            
            %% initiliaze DBSP
            rtcls = dbsp('10.10.10.1');
            clab = neurone_digitalout_clab_from_xml(xmlread('neuroneprotocol.xml')); %adapt this file name as per the inserted file name in the hardware handling module
            
            % % % % %             if(obj.info.event.mt==1)
            % % % % %                 obj.mt_initialize;
            % % % % %             end
            
            %% set stimulation amp for the first trial using magic
            % use switch case to imply the mag vencture , mag stim and
            % rapid object
            %             magventureObject.setAmplitude(obj.data.(obj.info.str).outputs.trials((obj.info.trial+1),1));
            
            %% make timer call back, then stop fcn call back and then the loop stuff and put events marker into it
            
            function best_timerfcn(tobj,event,obj,rtcls)
                obj.info.trial=obj.info.trial+1;
                rtcls.sendPulse;
                obj.data.(obj.info.str).outputs.rawdata(obj.info.trial,:)=rtcls.mep(1); % will have to pur the handle of right, left and APB or FDI muscle here, also there is a third muscle pinky muscle which is used sometime so add for that t00
                % also have to create for customizing scope but that will go in
                % hardware seetings
                
                
                
                
                
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
                else
                    start(tobj);
                end
            end
            
            
            t=timer('StartDelay', 0.1,'TasksToExecute', 1,'ExecutionMode', 'fixedRate');
            
            t.TimerFcn={@best_timerfcn,obj,rtcls};
            t.StopFcn={@best_timer_stopfcn,obj};
            start(t)
            tic
            
           pause(4)
            for trials=1:length(obj.data.(obj.info.str).outputs.trials(:,1))
                
%                 pause(5)
                
%                 obj.info.timeB(obj.info.trial,:)=toc;
               
                plot(obj.data.(obj.info.str).outputs.rawdata(obj.info.trial,:))
%                 tic
                hold on;
            end
        end
        
        
        % % % %         function mt_initialize(obj)
        % % % %             %% copy n paste n edit as per se
        % % % %         end
        
       
        
        
    end
end

%% FURTHER STEPS
%1. make a simulation of mep scope using the random number generator (rand func of the matlab)

%2. test it for the timing vector and see if it stills gives 6 somthing mainly seconds
%3. use the new flexi grid layout system for gui making and simulate it too

