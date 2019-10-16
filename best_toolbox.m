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
        
        data;
        info;
        
        sim_mep;
        
    end
    
    methods
        
        function obj= best_toolbox ()
            
            
            load sim_mep.mat;
            obj.sim_mep=sim_mep';
            
            delete(instrfindall);
            
            obj.info.method=0;
            %iNITILIZATION FUNCTION COMMANDS CAN COME HERE AND THIS BEST
            %MAIN NAME CAN BE CHANGED TO BEST INITILIZE
            
            
            %%
            
            %             ----------------------------------
            %make another function for loading default values
            % common
            obj.inputs.stimuli=NaN;
            obj.inputs.iti=NaN;
            obj.inputs.isi=NaN;
            obj.inputs.trials=NaN;
            obj.inputs.stimunits=NaN;
            obj.inputs.motor_threshold=NaN;
            obj.inputs.mep_amthreshold=NaN;     %active motor (am) threshold in volts %set default
            obj.inputs.mt_method=NaN;           %motor thresholding (mt) method in volts %set default
            obj.inputs.mep_onset=0.015;           %mep post trigger onset in seconds %set default
            obj.inputs.mep_offset=0.050;          %mep post trigger offset in seconds %set default
            
            obj.inputs.sc_samples=NaN;
            obj.inputs.sc_prepostsamples=NaN;
            obj.inputs.sc_samplingrate=5000;
            obj.inputs.mt_trialstoavg=10;
            obj.inputs.stim_mode='MSO';
            
            
            
        end
        
        
        function best_mep(obj)
            obj.info.method=obj.info.method+1;
            obj.info.str=strcat('mep_',num2str(obj.info.method));
            obj.data.(obj.info.str).inputs=obj.inputs;
            % todo: obj.data.str.inputs should only save non NaN fields of
            obj.info.event.best_mep_amp=1;
            obj.info.event.best_mep_plot=1;
            obj.info.event.best_mt_pest=NaN;
            obj.info.event.best_mt_plot=NaN;
            obj.info.event.best_ioc_plot=NaN;
            
            obj.best_trialprep;
            obj.best_stimloop;
            
        end
        
        function best_motorhotspot(obj)
            obj.info.method=obj.info.method+1;
            obj.info.str=strcat('motorhotspot_',num2str(obj.info.method));
            obj.data.(obj.info.str).inputs=obj.inputs;
            % todo: obj.data.str.inputs should only save non NaN fields of
            obj.info.event.best_mep_amp=1;
            obj.info.event.best_mep_plot=1;
            %almost as same as best mep with an additional graph of p2p
        end
        
        function best_motorthreshold(obj)
            obj.info.method=obj.info.method+1;
            obj.info.str=strcat('motorthreshold_',num2str(obj.info.method));
            obj.data.(obj.info.str).inputs=obj.inputs;
            % todo: obj.data.str.inputs should only save non NaN fields of
            obj.info.event.best_mep_amp=1;
            obj.info.event.best_mep_plot=1;
            obj.info.event.best_mt_pest=1;
            obj.info.event.best_mt_plot=1;
            obj.info.event.best_ioc_plot=NaN;
            obj.best_trialprep;
            obj.best_mt_pest_boot;
            obj.best_stimloop;
            
            
        end
        
        
        function best_ioc(obj)
            obj.info.method=obj.info.method+1;
            obj.info.str=strcat('ioc_',num2str(obj.info.method));
            obj.data.(obj.info.str).inputs=obj.inputs;
            % todo: obj.data.str.inputs should only save non NaN fields of
            obj.info.event.best_mep_amp=1;
            obj.info.event.best_mep_plot=1;
            obj.info.event.best_mt_pest=NaN;
            obj.info.event.best_mt_plot=NaN;
            obj.info.event.best_ioc_plot=1;
            
            obj.best_trialprep;
            obj.best_stimloop;
            
        end
        
        
        function best_trialprep(obj)
            
            %%  1. made stimulation vector ;
            % todo2 assert an error here if the stim vector is not equal to trials vector
            
            if(obj.info.event.best_mt_pest==1)
                obj.info.total_trials=obj.data.(obj.info.str).inputs.trials;
                obj.data.(obj.info.str).outputs.trials(:,1)=zeros(obj.info.total_trials,1);
            else
                stimuli=repelem(obj.data.(obj.info.str).inputs.stimuli,obj.data.(obj.info.str).inputs.trials);
                stimuli=stimuli(randperm(length(stimuli)));
                obj.data.(obj.info.str).outputs.trials(:,1)=stimuli';
                obj.info.total_trials=length(stimuli');
                if(strcmp(obj.data.(obj.info.str).inputs.stim_mode,'MT'))
                        obj.data.(obj.info.str).outputs.trials(:,5)=obj.data.(obj.info.str).outputs.trials(:,1)*(obj.info.rmt/100); 
                end
                    
            end
            
            if (length(obj.inputs.trials==1))
                obj.info.ioc.trialsperSI=obj.inputs.trials/length(obj.inputs.stimuli);
            else
                obj.info.ioc.trialsperSI=max(obj.inputs.trials);
            end
            %% 2. iti vector (for timer func) and timing sequence (for dbsp) vector ;
            
            
            if (length(obj.inputs.iti)==2)
                jitter=(obj.data.(obj.info.str).inputs.iti(2)-obj.data.(obj.info.str).inputs.iti(1));
                iti=ones(1,obj.info.total_trials)*obj.data.(obj.info.str).inputs.iti(1);
                iti=iti+rand(1,length(iti))*jitter;
            elseif (length(obj.inputs.iti)==1)
                iti=ones(1,obj.info.total_trials)*(obj.data.(obj.info.str).inputs.iti(1));
            else
                error(' BEST Toolbox Error: Inter-Trial Interval (ITI) input vector must be a scalar e.g. 2 or a row vector with 2 elements e.g. [3 4]')
            end
            obj.data.(obj.info.str).outputs.trials(:,2)=(round(iti,3))';
            obj.data.(obj.info.str).outputs.trials(:,3)=(movsum(iti,[length(iti) 0]))';
            
            mep_plot_time_vector=1:obj.inputs.sc_samples;
            mep_plot_time_vector=mep_plot_time_vector./obj.inputs.sc_samplingrate;
            mep_plot_time_vector=mep_plot_time_vector*1000; % conversion from seconds to ms
            mep_plot_time_vector=mep_plot_time_vector+((obj.data.(obj.info.str).inputs.sc_prepostsamples)/(obj.data.(obj.info.str).inputs.sc_samplingrate)*1000);
            obj.info.timevector=mep_plot_time_vector;
            %             av=tv./5000
            %
            %             av=av*1000
            %             obj.info.av=av-30
            %
            
            obj.info.totaltime=((obj.data.(obj.info.str).inputs.sc_samples)/(obj.data.(obj.info.str).inputs.sc_samplingrate))*1000;
            obj.info.prestimulustime=((obj.data.(obj.info.str).inputs.sc_prepostsamples)/(obj.data.(obj.info.str).inputs.sc_samplingrate))*1000;
            %             obj.info.timevector=(obj.info.prestimulustime*1000):((obj.info.totaltime*1000)+(obj.info.prestimulustime*1000));
            
            
            % onset offset MEP Amps
             obj.info.mep_onset_calib=obj.inputs.mep_onset*5000; 
             obj.info.mep_offset_calib=obj.inputs.mep_offset*5000;

            if (obj.inputs.sc_prepostsamples<0)    
             obj.info.mep_onset_samp=abs(obj.inputs.sc_prepostsamples)+obj.info.mep_onset_calib;
             obj.info.mep_offset_samp=abs(obj.inputs.sc_prepostsamples)+obj.info.mep_offset_calib;
             
            elseif (obj.inputs.sc_prepostsamples>0)
                
             error('BEST Toolbox Error: PrePostSample should be negative in order to be able to get amplitude on required onset')   
                
            end
             
             
             obj.inputs.mep_offset=0.050;          %mep post trigger offset in seconds %set default
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
            % % %                         NumSamp=obj.inputs.sc_samples;
            % % %                         PrePostSamp=obj.inputs.sc_prepostsamples;
            % % %                         rtcls = dbsp('10.10.10.1',NumSamp,PrePostSamp);
            % % %                         clab = neurone_digitalout_clab_from_xml(xmlread('neuroneprotocol.xml')); %adapt this file name as per the inserted file name in the hardware handling module
            % % %
            
            
            %% set stimulation amp for the first trial using magic
            % use switch case to imply the mag vencture , mag stim and
            % rapid object
            %             magventureObject.setAmplitude(obj.data.(obj.info.str).outputs.trials((obj.info.trial+1),1));
            % % %             if(strcmp(obj.data.(obj.info.str).inputs.stim_mode,'MT'))
            % % %                     magventureObject.setAmplitude(obj.data.(obj.info.str).outputs.trials((obj.info.trial+1),5));
            % % %             else
            % % %                     magventureObject.setAmplitude(obj.data.(obj.info.str).outputs.trials((obj.info.trial+1),1));
            % % %             end
            tic
            %% make timer call back, then stop fcn call back and then the loop stuff and put events marker into it
            while obj.info.trial<=obj.info.total_trials-1
                obj.info.trial=obj.info.trial+1;
                tt=obj.info.trial
                obj.info.thistime(obj.info.trial)=toc
                
                % % %                                  rtcls.sendPulse;
                tic
                tic
                % % %                                  obj.data.(obj.info.str).outputs.rawdata(obj.info.trial,:)=rtcls.mep(1); % will have to pur the handle of right, left and APB or FDI muscle here, also there is a third muscle pinky muscle which is used sometime so add for that t00
                % % %                 % also have to create for customizing scope but that will go in
                % hardware seetings
                %                 obj.data.(obj.info.str).outputs.rawdata(obj.info.trial,:)=rand(1,1000);
                obj.data.(obj.info.str).outputs.rawdata(obj.info.trial,:)=rand*(obj.sim_mep)*(obj.data.(obj.info.str).outputs.trials((obj.info.trial),1));
                if (obj.info.event.best_mep_amp==1)
                    obj.best_mep_amp; end
                if (obj.info.event.best_mt_pest==1)
                    obj.best_mt_pest; end
                % % %                 if(strcmp(obj.data.(obj.info.str).inputs.stim_mode,'MT'))
                % % %                     magventureObject.setAmplitude(obj.data.(obj.info.str).outputs.trials((obj.info.trial+1),5));
                % % %                 else
                % % %                     magventureObject.setAmplitude(obj.data.(obj.info.str).outputs.trials((obj.info.trial+1),1));
                % % %                 end
                obj.info.trial_plotted=obj.info.trial_plotted+1;
                gg=obj.info.trial_plotted
                
                disp('plotted')
                if (obj.info.event.best_mep_plot==1)
                    obj.best_mep_plot; end
                
                if (obj.info.event.best_mt_plot==1)
                    obj.best_mt_plot; end
                %                 if (obj.info.event.best_mep_amp==1)
                %                     obj.best_mep_amp; end
                if(obj.info.event.best_ioc_plot==1)
                    obj.best_ioc_scatplot; end
                if (obj.info.trial_plotted==obj.info.total_trials)
                    
                    obj.best_mep_stats;
                    
                    if(obj.info.event.best_ioc_plot==1)
                        obj.best_ioc_fit;
                        
                        obj.best_ioc_plot;
                        
                    end
                    if(obj.info.event.best_mt_pest==1)
                        
                        obj.data.(obj.info.str).outputs.results.mt=ceil(mean(obj.data.(obj.info.str).outputs.trials((obj.info.total_trials-obj.inputs.mt_trialstoavg:obj.info.total_trials),1)));
                        obj.info.rmt=obj.data.(obj.info.str).outputs.results.mt;
                    end
                end
                
                time_to_subtract_iti=toc;
                time_to_wait= obj.data.(obj.info.str).outputs.trials(obj.info.trial,2)-time_to_subtract_iti;
                %  obj.best_wait(time_to_wait)
                pause(time_to_wait)
                
            end
           % save('C:\0. HARD DISK\BEST Toolbox\BEST-04.08\GUI','obj')
            
            
            
        end
        function best_mep_plot(obj)
            if (obj.info.trial_plotted==1)
                     obj.info.handles.mep_figure=figure('name','Live MEP Plot');
                     obj.info.handles.current_mep_plot=plot(obj.info.timevector,obj.data.(obj.info.str).outputs.rawdata(obj.info.trial_plotted,:),'Color',[1 0 0],'LineWidth',2);
hold on;
                     xlim([obj.info.timevector(1), obj.info.timevector(end)]);
                     %%
                     
                     mat1=obj.info.prestimulustime:20:(obj.info.totaltime+obj.info.prestimulustime)
                     mat2=[0 obj.inputs.mep_onset*1000 obj.inputs.mep_offset*1000 obj.info.timevector(end)]
                     mat=sort([mat1 mat2])
                     mat=unique(mat)
                     
% %                       mat1_xticks=(obj.info.prestimulustime:20:0)
% %                       mat2_xticks=0
% %                       mat3_xticks=20:20:obj.info.timevector(end)
% %                       mat4_xticks=obj.info.timevector(end)
                      
                      
%                       final_xticks_mat=[mat1_xticks mat2_xticks mat3_xticks mat4_xticks]
%                       final_xticks_m
                      
              %   xticks(obj.info.prestimulustime:20:(obj.info.totaltime+obj.info.prestimulustime));
                     xticks(mat);
                     ylim([-8000 8000]);
                        gridxy([(obj.inputs.mep_onset*1000):0.1:(obj.inputs.mep_offset*1000)],'Color',[0.97 0.97 0],'linewidth',1) ;
                        hold on;
     gridxy(0,'Color',[0.97 0.97 0],'linewidth',2) ;
  

 % Create xlabel
                xlabel('Time (ms)','FontSize',14,'FontName','Arial');
                % Create ylabel
                ylabel('EMG Potential (\mu V)','FontSize',14,'FontName','Arial');
                 l=legend(obj.info.handles.current_mep_plot,'Current MEP');

%                 l=legend(obj.info.handles.past_mep_plot, 'Previous MEPs','Mean Plot', 'Current MEP');
                set(l,'Orientation','horizontal','Location', 'southoutside','FontSize',12);
            elseif (obj.info.trial_plotted==2)
                
                figure(obj.info.handles.mep_figure);
              
                
                %                 obj.info.handles.past_mep_plot=plot(obj.info.timevector,obj.data.(obj.info.str).outputs.rawdata(obj.info.trial_plotted,:),'Color',[0.75 0.75 0.75]);
                %                 hold on;
                %                   obj.info.handles.mean_mep_plot=plot(mean(obj.data.(obj.info.str).outputs.rawdata),'color',[0,0,0],'LineWidth',1.5);
                % %                  obj.info.handles.mean_mep_plot=plot(NaN,NaN);
                % hold on;
                %                 obj.info.handles.current_mep_plot=plot(obj.info.timevector,obj.data.(obj.info.str).outputs.rawdata(obj.info.trial_plotted,:),'Color',[1 0 0],'LineWidth',2);
                %                 hold on;
                
                %    obj.info.handles.past_mep_plot=plot(obj.data.(obj.info.str).outputs.rawdata(obj.info.trial_plotted,:),'Color',[0.75 0.75 0.75]);
                %                 hold on;
                %                 obj.info.handles.mean_mep_plot=plot(mean(obj.data.(obj.info.str).outputs.rawdata),'color',[0,0,0],'LineWidth',1.5);
                %                 hold on;
                %                 obj.info.handles.current_mep_plot=plot(obj.data.(obj.info.str).outputs.rawdata(obj.info.trial_plotted,:),'Color',[1 0 0],'LineWidth',2);
                %                 hold on;
                
                 obj.info.handles.past_mep_plot=plot(obj.info.timevector,obj.data.(obj.info.str).outputs.rawdata(obj.info.trial_plotted,:),'Color',[0.75 0.75 0.75]);
                 hold on;
                 obj.info.handles.mean_mep_plot=plot(obj.info.timevector,mean(obj.data.(obj.info.str).outputs.rawdata),'color',[0,0,0],'LineWidth',1.5);
                 hold on;
                 delete(obj.info.handles.current_mep_plot);
                 obj.info.handles.current_mep_plot=plot(obj.info.timevector,obj.data.(obj.info.str).outputs.rawdata(obj.info.trial_plotted,:),'Color',[1 0 0],'LineWidth',2);
                 hold on;
                h_legend=[obj.info.handles.past_mep_plot; obj.info.handles.mean_mep_plot; obj.info.handles.current_mep_plot];
                l=legend(h_legend, 'Previous MEPs', 'Mean Plot', 'Current MEP');
                set(l,'Orientation','horizontal','Location', 'southoutside','FontSize',12);
                str_plottedTrials=['Trial Plotted: ',num2str(obj.info.trial_plotted),'/',num2str(obj.info.total_trials)];
                str_triggeredTrials=['Trial Triggered: ',num2str(obj.info.trial),'/',num2str(obj.info.total_trials)];
                str = {str_plottedTrials,str_triggeredTrials};
                obj.info.handles.annotated_trialsNo=text(80, -10000,str);
                
                
            else
                figure(obj.info.handles.mep_figure);
                str_plottedTrials=['Trial Plotted: ',num2str(obj.info.trial_plotted),'/',num2str(obj.info.total_trials)];
                str_triggeredTrials=['Trial Triggered: ',num2str(obj.info.trial),'/',num2str(obj.info.total_trials)];
                str = {str_plottedTrials,str_triggeredTrials};
                delete(obj.info.handles.annotated_trialsNo);
                obj.info.handles.annotated_trialsNo=text(80, -10000,str);
                %                  obj.info.handles.past_mep_previousplot=plot(obj.data.(obj.info.str).outputs.rawdata(obj.info.trial_plotted-1,:),'Color',[0.75 0.75 0.75]);
                %                 plot(obj.data.(obj.info.str).outputs.rawdata(obj.info.trial_plotted-1,:),'Color',[0.75 0.75 0.75]);
                
                
                obj.info.handles.prev_mep_plot=animatedline(obj.info.timevector,obj.data.(obj.info.str).outputs.rawdata(obj.info.trial_plotted-1,:),'color',[0.75 0.75 0.75]);
                obj.info.handles.prev_mep_plot.Annotation.LegendInformation.IconDisplayStyle = 'off';
                
                %                                 h = animatedline(1:1000,obj.data.(obj.info.str).outputs.rawdata(obj.info.trial_plotted-2,:));
                %                 h = animatedline(1:1000,obj.data.(obj.info.str).outputs.rawdata(obj.info.trial_plotted-3,:));
                %
                %                 addpoints(h,obj.data.(obj.info.str).outputs.rawdata(obj.info.trial_plotted-2,:));
                %                 drawnow;
                
                
                %
% %                 clearpoints(obj.info.handles.mean_mep_plot)
% %                 obj.info.handles.mean_mep_plot=animatedline(obj.info.timevector,mean(obj.data.(obj.info.str).outputs.rawdata),'color',[0,0,0],'LineWidth',1.5);
% % 
% %                 clearpoints(obj.info.handles.current_mep_plot)
% %                 obj.info.handles.current_mep_plot=animatedline(obj.info.timevector,obj.data.(obj.info.str).outputs.rawdata(obj.info.trial_plotted,:),'Color',[1 0 0],'LineWidth',2);
% % 
% %                 
                
                 set(obj.info.handles.mean_mep_plot,'YData',mean(obj.data.(obj.info.str).outputs.rawdata))
                 set(obj.info.handles.current_mep_plot,'YData',(obj.data.(obj.info.str).outputs.rawdata(obj.info.trial_plotted,:)))

                
            end
        end
        function best_mep_amp(obj)
            
            % give handle of post trigger offset and onset
            obj.data.(obj.info.str).outputs.trials(obj.info.trial,4)=abs(max(obj.data.(obj.info.str).outputs.rawdata(obj.info.trial,obj.info.mep_onset_samp:obj.info.mep_offset_samp)))+abs(min(obj.data.(obj.info.str).outputs.rawdata(obj.info.trial,obj.info.mep_onset_samp:obj.info.mep_offset_samp)));
            
            
            % epoch in the window
            % find max in that eopched
            % find min in that eopch
            % take abs of that epoch
            % add both to find p2p
            % add it to corrosponding trial
            
            
        end
        function best_mt_pest_boot(obj)
            
            % Custom cdf where 'm' is mean and '0.07*m' is predifined variance
            cdfFormula = @(m) normcdf(0:0.5:100,m,0.07*m);
            
            % emulated cdf
            realCdf = zeros(2,201);
            spot = 1;
            for i = 0:0.5:100
                realCdf(1,spot) = i;
                spot = spot + 1;
            end
            realCdf(2,:) = normcdf(0:0.5:100,40,0.07*40);
            
            %% Log likelihood func
            obj.info.mt.log = zeros(2,201);
            spot = 1;
            for i = 0:0.5:100
                obj.info.mt.log(1,spot) = i;
                spot = spot + 1;
            end
            %% Start with hit at 100% intensity and miss at 0% intensity
            spot = 1;
            for i = 0:0.5:100 % go through all possible intensities
                thisCdf = cdfFormula(i);
                % calculate log likelihood function
                obj.info.mt.log(2,spot) = log(thisCdf(101)) + log(1-thisCdf(61));
                spot = spot + 1;
            end
            
            %%
            
            %find max values, returns intensity (no indice problem)
            maxValues = obj.info.mt.log(1,find(obj.info.mt.log(2,:) == max(obj.info.mt.log(2,:))));
            
            % Middle Value from maxValues
            obj.info.mt.nextInt = (min(maxValues) + max(maxValues))/2;
            obj.data.(obj.info.str).outputs.trials(1,1)=obj.info.mt.nextInt;
            
        end
        
        
        function best_mt_pest(obj)
            
            
            
            %% MEP Measurment
            
            
            
            No_of_iterations=obj.info.total_trials;
            
            % % %             for N=1:No_of_iterations
            
            % MAGIC command for setting Intensity
            % % %                 rtcls.sendPulse(1); %RTCLS command for stimulating at that command
            % % %                 rtcls.MEP(1);       %RTCLS command for measuring raw data
            % % %                 obj=best_mep_P2Pamp(obj); %BEST command for calcualting P2P amps
            
            % Custom cdf where 'm' is mean and '0.07*m' is predifined variance
            cdfFormula = @(m) normcdf(0:0.5:100,m,0.07*m);
            factor=1;
            
            if (obj.info.trial>1)
                if obj.data.(obj.info.str).outputs.trials(obj.info.trial-1,4) > obj.data.(obj.info.str).inputs.motor_threshold
                    %disp('Hit')
                    evokedMEP = 1;
                else
                    %disp('Miss')
                    evokedMEP = 0;
                end
            else
                
                evokedMEP = 0;
                
            end
            
            
            %find max values
            maxValues = obj.info.mt.log(1,find(obj.info.mt.log(2,:) == max(obj.info.mt.log(2,:))));
            % Middle Value from maxValues
            obj.info.mt.nextInt = round((min(maxValues) + max(maxValues)) / 2);
            %nextInt = maxValues(round(length(maxValues)/2));
            
            % calculate updated log likelihood function
            spot = 1;
            for i = 0:0.5:100 % go through all possible intensities
                thisCdf = cdfFormula(i);
                if evokedMEP == 1 % hit!
                    obj.info.mt.log(2,spot) = obj.info.mt.log(2,spot) + factor*log(thisCdf(2*obj.info.mt.nextInt+1));
                elseif evokedMEP == 0 % miss!
                    obj.info.mt.log(2,spot) = obj.info.mt.log(2,spot) + factor*log(1-thisCdf(2*obj.info.mt.nextInt+1));
                end
                spot = spot + 1;
            end
            
            %display(sprintf('using next intensity: %.2f', obj.nextInt))
            
            obj.data.(obj.info.str).outputs.trials((obj.info.trial+1),1)=obj.info.mt.nextInt;
            %             if (obj.info.trial<obj.info.total_trials)
            %             obj.data.(obj.info.str).outputs.trials((obj.info.trial+1),1)=obj.info.mt.nextInt; end
            
        end
        
        function best_mt_plot(obj)
            if(obj.info.trial==1)
                obj.info.handles.mt_figure=figure('name','Motor Thresholding, MEP Amp Trace');
                
                obj.info.handles.mt_plot=plot(obj.data.(obj.info.str).outputs.trials(1,1));
                xlabel('Trial Number','FontSize',14,'FontName','Calibri');   %TODO: Put if loop of RMT or MSO
                
                % Create ylabel
                ylabel('Stimulation Intensities (%MSO)','FontSize',14,'FontName','Calibri');
                
                
                yticks(0:1:400);
                % x & y ticks and labels
                % will have to be referneced with GUI
                xticks(1:1:100);    % will have to be referneced with GUI
                
                % Create title
                title({'Threshold Hunting - Stimulation Intensities Trace'},'FontWeight','bold','FontSize',14,'FontName','Calibri');
                set(gcf, 'color', 'w')
            end
            figure(obj.info.handles.mt_figure);
            
            set(obj.info.handles.mt_plot,'YData',(obj.data.(obj.info.str).outputs.trials(2:obj.info.trial_plotted+1,1)))
            
            
        end
        
        function best_mep_stats(obj)
            
            % handle to put 0 in case of unequal trials vector
            % for this calculate the median of all elements seperately
            % then append the missing SI values and replace them by the
            % median
            % then the usual procedure downwards will be working
            
            
            [si,ia,idx] = unique(obj.data.(obj.info.str).outputs.trials(:,1),'stable');
            mep_median = accumarray(idx,obj.data.(obj.info.str).outputs.trials(:,4),[],@median);
            mep_mean = accumarray(idx,obj.data.(obj.info.str).outputs.trials(:,4),[],@mean);
            mep_std = accumarray(idx,obj.data.(obj.info.str).outputs.trials(:,4),[],@std);
            mep_min = accumarray(idx,obj.data.(obj.info.str).outputs.trials(:,4),[],@min);
            mep_max = accumarray(idx,obj.data.(obj.info.str).outputs.trials(:,4),[],@max);
            mep_var = accumarray(idx,obj.data.(obj.info.str).outputs.trials(:,4),[],@var);
            M=[si,mep_median,mep_mean,mep_std, mep_min, mep_max, mep_var];
            M1 = M(randperm(size(M,1)),:,:,:,:,:,:);
            obj.data.(obj.info.str).outputs.results.mep_stats(:,1)=M1(:,1); %Sampled SIs
            obj.data.(obj.info.str).outputs.results.mep_stats(:,2)=M1(:,2); %Sampled Medians MEPs
            obj.data.(obj.info.str).outputs.results.mep_stats(:,3)=M1(:,3); %Mean MEPs over trial
            obj.data.(obj.info.str).outputs.results.mep_stats(:,4)=M1(:,4); %Std MEPs
            obj.data.(obj.info.str).outputs.results.mep_stats(:,5)=M1(:,5); %Min of MEPs
            obj.data.(obj.info.str).outputs.results.mep_stats(:,6)=M1(:,6); %Max of MEPs
            obj.data.(obj.info.str).outputs.results.mep_stats(:,7)=M1(:,7); %Var of MEPs
            obj.info.SI=obj.data.(obj.info.str).outputs.results.mep_stats(:,1);
            obj.info.MEP=obj.data.(obj.info.str).outputs.results.mep_stats(:,2);
            
            obj.data.(obj.info.str).outputs.results.mep_stats(:,8)=(obj.data.(obj.info.str).outputs.results.mep_stats(:,4))/sqrt(obj.info.ioc.trialsperSI);    %TODO: Make it modular by replacing 15 to # trials per intensity object value
            obj.info.SEM=obj.data.(obj.info.str).outputs.results.mep_stats(:,8);
        end
        
        
        function best_ioc_fit(obj)
            obj.info.handles.ioc_plot_fig=figure('name',' MEP Dose-Response Curve');

            set(gcf,'Visible', 'off');
            [SIData, MEPData] = prepareCurveData(obj.data.(obj.info.str).outputs.results.mep_stats(:,1) ,obj.data.(obj.info.str).outputs.results.mep_stats(:,2));
            ft = fittype( 'MEPmax*SI^n/(SI^n+SI50^n)', 'independent', 'SI', 'dependent', 'MEP' );
            %% Optimization of fit paramters;
            
            opts = fitoptions( ft );
            opts.Display = 'Off';
            opts.Lower = [0 0 0 ];
            opts.StartPoint = [10 10 10];
            opts.Upper = [Inf Inf Inf];
            
            %% Fit sigmoid model to data
            
            [obj.info.ioc.fitresult,obj.info.ioc.gof] = fit( SIData, MEPData, ft, opts);
            %% Extract fitted curve points
            
            plot( obj.info.ioc.fitresult, SIData, MEPData);
            obj.info.handle.ioc_curve= get(gca,'Children');
            
        end
        
        function best_ioc_plot(obj)
%             figure(obj.info.handles.ioc_plot_fig)
%             set(gcf,'Visible', 'off');

            format short g
            %% Inflection point (ip) detection on fitted curve
            %             index_ip=find(abs(obj.curve(1).XData-obj.fitresult.SI50)<10^-1, 1, 'first');
            %              obj.ip_x=obj.curve(1).XData(index_ip);
            %             ip_y = obj.curve(1).YData(index_ip)
            
            [value_ip , index_ip] = min(abs(obj.info.handle.ioc_curve(1).XData-obj.info.ioc.fitresult.SI50));
            obj.info.ip_x = obj.info.handle.ioc_curve(1).XData(index_ip);
            ip_y = obj.info.handle.ioc_curve(1).YData(index_ip);
            
            %% Plateau (pt) detection on fitted curve
            %             index_pt=find(abs(obj.curve(1).YData-obj.fitresult.MEPmax)<10^1, 1, 'first');
            %             obj.pt_x=obj.curve(1).XData(index_pt);
            %             pt_y=obj.curve(1).YData(index_pt);
            %
            [value_pt , index_pt] = min(abs(obj.info.handle.ioc_curve(1).YData-(0.993*(obj.info.ioc.fitresult.MEPmax) ) ) );   %99.3 % of MEP max %TODO: Test it with longer plateu
            obj.info.pt_x=obj.info.handle.ioc_curve(1).XData(index_pt);
            pt_y=obj.info.handle.ioc_curve(1).YData(index_pt);
            
            %% Threshold (th) detection on fitted curve
             if(strcmp(obj.data.(obj.info.str).inputs.stim_mode,'MSO'))

            index_ip1=index_ip+50;
            ip1_x=obj.info.handle.ioc_curve(1).XData(index_ip1);
            ip1_y=obj.info.handle.ioc_curve(1).YData(index_ip1);
            % Calculating slope (m) using two-points equation
            m1=(ip1_y-ip_y)/(ip1_x-obj.info.ip_x)
            m=m1
            % Calculating threshold (th) using point-slope equation
            obj.info.th=obj.info.ip_x-(ip_y/m);
             end
            
            %% Creating plot
            %         figure(4)
            hold on;
            h = plot( obj.info.ioc.fitresult, obj.info.SI, obj.info.MEP);
            set(h(1), 'MarkerFaceColor',[0 0 0],'MarkerEdgeColor',[0 0 0],'Marker','square','LineStyle','none');
            
            % Plotting SEM on Curve points
            errorbar(obj.info.SI, obj.info.MEP ,obj.info.SEM, 'o');
            set(h(2),'LineWidth',2);
            
            % Create xlabel
            xlabel(' Stimulation Intensity','FontSize',14,'FontName','Calibri');   %TODO: Put if loop of RMT or MSO
            
            % Create ylabel
            ylabel('MEP Amplitude ( \mu V)','FontSize',14,'FontName','Calibri');
            
            
            
            % x & y ticks and labels
%             yticks(-1:0.5:10000);  % will have to be referneced with GUI
%             xticks(0:5:1000);    % will have to be referneced with GUI
            
            % Create title
            title({'Input Output Curve'},'FontWeight','bold','FontSize',14,'FontName','Calibri');
            set(gcf, 'color', 'w')
            
            
            SI_min_point = (round(min(obj.info.SI)/5)*5)-5; % Referncing the dotted lines wrt to lowest 5ths of SI_min
            % SI_min_point = 0;
            seet=-0.5;
            
            
            % Plotting Inflection point's horizontal & vertical dotted lines
            plot([obj.info.ip_x,SI_min_point],[ip_y,ip_y],'--','Color' , [0.75 0.75 0.75]);
            plot([obj.info.ip_x,obj.info.ip_x],[ip_y,seet],'--','Color' , [0.75 0.75 0.75]);
            legend_ip=plot(obj.info.ip_x,ip_y,'rs','MarkerSize',15);
            
            % Plotting Plateau's horizontal & vertical dotted lines
            plot([obj.info.pt_x,SI_min_point],[pt_y,pt_y],'--','Color' , [0.75 0.75 0.75]);
            plot([obj.info.pt_x,obj.info.pt_x],[pt_y,seet],'--','Color' , [0.75 0.75 0.75]);
            legend_pt=plot(obj.info.pt_x,pt_y,'rd','MarkerSize',15);
            
            % Plotting Threshold's horizontal & vertical dotted lines
            if(strcmp(obj.data.(obj.info.str).inputs.stim_mode,'MT'))
                %% Creating legends
            h_legend=[h(1); h(2); legend_ip;legend_pt];
            l=legend(h_legend, 'Amp(MEP) vs Stim. Inten', 'Sigmoid Fit', 'Inflection Point','Plateau');
            set(l,'Orientation','horizontal','Location', 'southoutside','FontSize',12);
            
            %% Creating Properties annotation box
            
            str_ip=['Inflection Point: ',num2str(obj.info.ip_x),' (%MT)',' , ',num2str(ip_y),' (\muV)'];
            str_pt=['Plateau: ',num2str(obj.info.pt_x),' (%MT)',' , ',num2str(pt_y),' (\muV)'];
            
            
            dim = [0.69 0.35 0 0];
            str = {str_ip,[],str_pt};
            annotation('textbox',dim,'String',str,'FitBoxToText','on','FontSize',12);
            else
                disp('error is here');
                plot([obj.info.th,SI_min_point],[0.05,0.05],'--','Color' , [0.75 0.75 0.75]);
            plot([obj.info.th,obj.info.th],[0.05,seet],'--','Color' , [0.75 0.75 0.75]);
            legend_th=plot(obj.info.th, 0.05,'r*','MarkerSize',15);
            
            
            
            %% Creating legends
            h_legend=[h(1); h(2); legend_ip;legend_pt;legend_th];
            l=legend(h_legend, 'Amp(MEP) vs Stim. Inten', 'Sigmoid Fit', 'Inflection Point','Plateau','Threshold');
            set(l,'Orientation','horizontal','Location', 'southoutside','FontSize',12);
            
            %% Creating Properties annotation box
            
            str_ip=['Inflection Point: ',num2str(obj.info.ip_x),' (%MSO)',' , ',num2str(ip_y),' (\muV)'];
            str_pt=['Plateau: ',num2str(obj.info.pt_x),' (%MSO)',' , ',num2str(pt_y),' (\muV)'];
            str_th=['Thershold: ',num2str(obj.info.th),' (%MSO)',' , ', '0.05',' (\muV)'];
            
            dim = [0.69 0.35 0 0];
            str = {str_ip,[],str_th,[],str_pt};
            annotation('textbox',dim,'String',str,'FitBoxToText','on','FontSize',12);
            end
            box on; drawnow;
            
            set(gcf,'Visible', 'on');
            
            
            
        end
        
        function best_ioc_scatplot(obj)
             if(obj.info.trial==1)
                obj.info.handles.ioc_scatplot_fig=figure('name','IOC - MEP Amp Scatter Plot');
                
                obj.info.handles.ioc_scatplot=plot(obj.data.(obj.info.str).outputs.trials(1,1),obj.data.(obj.info.str).outputs.trials(1,4),'o','MarkerSize',6);
                hold on;
                xlabel('Stimulation Intensities','FontSize',14,'FontName','Calibri');   %TODO: Put if loop of RMT or MSO
                
                % Create ylabel
                ylabel('MEP P2P Amplitude','FontSize',14,'FontName','Calibri');
                
                
               
                % x & y ticks and labels
                % will have to be referneced with GUI
                xticks(obj.data.(obj.info.str).inputs.stimuli);    % will have to be referneced with GUI
                
                % Create title
                title({'IOC - MEP Amp Scatter Plot'},'FontWeight','bold','FontSize',14,'FontName','Calibri');
                set(gcf, 'color', 'w')
            end
            figure(obj.info.handles.ioc_scatplot_fig);
            
obj.info.handles.ioc_scatplot=plot(obj.data.(obj.info.str).outputs.trials(obj.info.trial_plotted,1),obj.data.(obj.info.str).outputs.trials(obj.info.trial_plotted,4),'o','MarkerSize',10);
                hold on;            
%             set(obj.info.handles.ioc_scatplot,'XData',obj.data.(obj.info.str).outputs.trials(obj.info.trial_plotted,1),'YData',obj.data.(obj.info.str).outputs.trials(obj.info.trial_plotted,4));
%             hold on;
            
        end
        
        
        
    end
end

%% FURTHER STEPS
%1. best_hotspot
%2. best_threshold am, mt as well as others
%% then make gui
%% also inclide TMS fMRI stuff
%3. ioc
%4. pp functions (mep n ioc)
%5. multiple stimulators mep, threshold, ioc
%6. use the new flexi grid layout system for gui making and simulate it too
%7. rs EEG

%% things to do for training
%a. try to synchronize the trial triggered and trial plotted timing
%b. try to use the trial info timing vector for this