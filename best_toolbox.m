%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% BEST Main class
% This class defines a main object for entire toolbox functions
%
% by Ing. Umair Hassan (umair.hassan@drz-mainz.de)
% last edited 2019/02/15 by UH
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


classdef best_toolbox < handle
    
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
%%
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
            
        end
        
        function best_trialprep(obj)
            
%             1. make stimulation vector ; 
% todo2 assert an error here if the stim vector is not equal to trials
% vector
            
                stimuli=repelem(obj.data.(obj.info.str).inputs.stimuli,obj.data.(obj.info.str).inputs.trials);
                stimuli=stimuli(randperm(length(stimuli)));
                obj.data.(obj.info.str).outputs(:,1)=stimuli';
               
            % 2. iti vector (for timer func) and timing sequence (for dbsp) vector ;

            jitter=(obj.data.(obj.info.str).inputs.iti(2)-obj.data.(obj.info.str).inputs.iti(1));
            iti=ones(1,length(stimuli))*obj.data.(obj.info.str).inputs.iti(1);
            iti=iti+rand(1,length(iti))*jitter;
            obj.data.(obj.info.str).outputs(:,2)=iti';
            obj.data.(obj.info.str).outputs(:,3)=(movsum(iti,[length(iti) 0]))';
            
          
            
            % 4. start making stim loop and further from here on wards for
            % tomorrow
            
            
            
           
           
            
            
            
        end
            
        
    end
end

