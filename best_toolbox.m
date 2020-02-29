classdef best_toolbox < handle
    
    % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
    % BEST Toolbox class
    % This class defines a main object for entire toolbox functions
    %
    % by Ing. Umair Hassan (umair.hassan@drz-mainz.de)
    %
    % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    properties
        
        sessions;
        inputs;
        info;
        sim_mep;
        backup;
        
        
        
    end
    
    properties (Hidden)
        bossbox
        magven
        magstim
        bistim
        rapid
        fieldtrip
        app;
        tc
        best_timer;
    end
    
    methods
        
        function obj= best_toolbox (app)
            %put app in the argument of this above func declreation
            load simMep.mat;
            obj.app=app;
            obj.sim_mep=simMep;
            
            delete(instrfindall);
            
            obj.info.method=0;
            %iNITILIZATION FUNCTION COMMANDS CAN COME HERE AND THIS BEST
            %MAIN NAME CAN BE CHANGED TO BEST INITILIZE
            
            
            %%
            
            %             ----------------------------------
            %make another function for loading default values
            % common
            obj.inputs.current_session='firstone';
            obj.inputs.current_measurement='mep_measurement';
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
            
            obj.inputs.FontSize=25;
            obj.inputs.ylim_min=-5000;
            obj.inputs.ylim_max=+5000;
            obj.inputs.stop_event=0;
            
            
            obj.info.event.hotspot=0;
            obj.info.handles.annotated_trialsNo=0;
            obj.info.event.pest_tc=NaN;
            obj.inputs.mt_starting_stim_inten=25;
            obj.info.event.best_mt_pest_tc=0;
            
            
            
        end
        function factorizeConditions(obj)
          % factorization would be done as per each measurement (or group of measurements) since the input fields and thus the conditioning variables differ
          char(obj.inputs.measure_str)
          switch char(obj.inputs.measure_str)
              case {'MEP Measurement','Motor Hotspot Search'}
                  
                 
                  
                  % making axesno cell array conditions
                  targetChannels_ax=1:1:(numel(obj.inputs.target_muscle));
                  displayChannels_ax=num2cell(targetChannels_ax(end)+1:1:targetChannels_ax(end)+(numel(obj.inputs.display_scopes)));
                  obj.app.pr.axesno=numel(targetChannels_ax)+numel(cell2mat(displayChannels_ax));
                  obj.app.pr.axesno
                  
                  % making measures cell array conditions
                  % in case of MEP this will work as the condition will be
                  % cellstr('MEP_Measurement') in the other case the
                  % condition will be a 1x2 cell array;
                  targetChannels_meas=cell(1,numel(obj.inputs.target_muscle));
                  targetChannels_meas(:)=cellstr('MEP_Measurement'); % infact thsi would be a variable obj.inputs.targetMeasure 
                  displayChannels_meas=cell(1,numel(obj.inputs.display_scopes));
                  displayChannels_meas(:)=cellstr('MEP_Measurement');
                  
                  % making stimmode 
                  
                  
                  % column labels
                  obj.inputs.colLabel.inputDevices=1;
                  obj.inputs.colLabel.outputDevices=2;
                  obj.inputs.colLabel.si=3;
                  obj.inputs.colLabel.iti=4;
                  obj.inputs.colLabel.chLab=5;
                  obj.inputs.colLabel.trials=9;
                  obj.inputs.colLabel.axesno=6;
                  obj.inputs.colLabel.measures=7;
                  obj.inputs.colLabel.stimMode=8;
                  
                  %just store the iti as a string e.g. '[iti1 iti2]' and
                  %then it can be evaluated for the randomized value
                  obj.inputs.totalConds=numel(obj.inputs.stimuli)*numel(obj.inputs.target_muscle)*numel(obj.inputs.iti);
                     idx_inputDevices=0;
                     idx_outputDevices=0;
                     idx_targetChannels=0;
                     idx_displayChannels=0;
                     idx_si=0;
                     idx_iti=0;    
                     idx_trials=0;
                     obj.inputs.condMat=cell(obj.inputs.totalConds,9);
                  for i=1:obj.inputs.totalConds
                     idx_inputDevices=idx_inputDevices+1;
                     idx_outputDevices=idx_outputDevices+1;
                     idx_si=idx_si+1;
                     idx_iti=idx_iti+1;
                     idx_displayChannels=idx_displayChannels+1;
                     idx_targetChannels=idx_targetChannels+1;
                     idx_trials=idx_trials+1; 
                     obj.inputs.condMat(i,obj.inputs.colLabel.inputDevices)=cellstr(obj.inputs.input_device(1,idx_inputDevices));
                     obj.inputs.condMat(i,obj.inputs.colLabel.outputDevices)={{cellstr(obj.inputs.output_device(1,idx_outputDevices))}};
                     obj.inputs.condMat(i,obj.inputs.colLabel.trials)=(obj.inputs.trials(1,idx_trials)); % may be a problem
                     obj.inputs.condMat(i,obj.inputs.colLabel.iti)=(obj.inputs.iti(1,idx_iti));
                     obj.inputs.condMat(i,obj.inputs.colLabel.si)={(obj.inputs.stimuli(1,idx_si))};
                     obj.inputs.condMat(i,obj.inputs.colLabel.chLab)={{char(cellstr(obj.inputs.target_muscle(1,idx_targetChannels))),obj.inputs.display_scopes{1,:}}};
                     obj.inputs.condMat(i,obj.inputs.colLabel.axesno)={{targetChannels_ax(1,idx_targetChannels),displayChannels_ax{1,:}}};
                     obj.inputs.condMat(i,obj.inputs.colLabel.stimMode)={{{'single_pulse'}}};
                     obj.inputs.condMat(i,obj.inputs.colLabel.measures)={{char(targetChannels_meas(1,idx_targetChannels)),displayChannels_meas{1,:}}};


                     if(idx_inputDevices>=numel(obj.inputs.input_device))
                         idx_inputDevices=0;
                     end
                     if(idx_outputDevices>=numel(obj.inputs.output_device))
                         idx_outputDevices=0;
                     end
                     if(idx_targetChannels>=numel(obj.inputs.target_muscle))
                         idx_targetChannels=0;
                     end
                     if(idx_displayChannels>=numel(obj.inputs.display_scopes))
                         idx_displayChannels=0;
                     end
                     if(idx_si>=numel(obj.inputs.stimuli))
                         idx_si=0;
                     end
                     if(idx_iti>=numel(obj.inputs.iti))
                         idx_iti=0;
                     end
                     if(idx_trials>=numel(obj.inputs.trials))
                         idx_trials=0;
                     end

                  end
              case 'Motor Threshold Hunting'
                  
                  obj.inputs.colLabel.inputDevices=1;
                  obj.inputs.colLabel.outputDevices=2;
                  obj.inputs.colLabel.si=3;
                  obj.inputs.colLabel.iti=4;
                  obj.inputs.colLabel.chLab=5;
                  obj.inputs.colLabel.trials=9;
                  obj.inputs.colLabel.axesno=6;
                  obj.inputs.colLabel.measures=7;
                  obj.inputs.colLabel.stimMode=8;
                  
                  targetChannels_meas=cell(1,numel(obj.inputs.target_muscle));
                  targetChannels_meas(:)={{'MEP_Measurement','Threshold Trace'}}; % infact thsi would be a variable obj.inputs.targetMeasure 
                  displayChannels_meas=cell(1,numel(obj.inputs.display_scopes));
                  displayChannels_meas(:)=cellstr('MEP_Measurement');
                  
                  ax_id=0;
                  for i=1:numel(obj.inputs.target_muscle)
                  targetChannels_ax{1,i}=num2cell(ax_id+1:1:ax_id+2); % infact thsi would be a variable obj.inputs.targetMeasure
%                   targetChannels{1,i}=num2cell(ax_id+1:1:ax_id+2);
                  targetChannels{1,i}={obj.inputs.target_muscle{1,i},obj.inputs.target_muscle{1,i}}
                                        ax_id=ax_id+2;
                                        
                  end
                  displayChannels_ax=num2cell(ax_id+1:1:ax_id+(numel(obj.inputs.display_scopes)));
                  obj.app.pr.axesno=numel(targetChannels_ax)+numel(displayChannels_ax);
                   %just store the iti as a string e.g. '[iti1 iti2]' and
                  %then it can be evaluated for the randomized value
                  obj.inputs.totalConds=numel(obj.inputs.stimuli)*numel(obj.inputs.target_muscle)*numel(obj.inputs.iti);
                     idx_inputDevices=0;
                     idx_outputDevices=0;
                     idx_targetChannels=0;
                     idx_displayChannels=0;
                     idx_si=0;
                     idx_iti=0;    
                     idx_trials=0;
                     obj.inputs.condMat=cell(obj.inputs.totalConds,9);
                  for i=1:obj.inputs.totalConds
                     idx_inputDevices=idx_inputDevices+1;
                     idx_outputDevices=idx_outputDevices+1;
                     idx_si=idx_si+1;
                     idx_iti=idx_iti+1;
                     idx_displayChannels=idx_displayChannels+1;
                     idx_targetChannels=idx_targetChannels+1;
                     idx_trials=idx_trials+1; 
                     obj.inputs.condMat(i,obj.inputs.colLabel.inputDevices)=cellstr(obj.inputs.input_device(1,idx_inputDevices));
                     obj.inputs.condMat(i,obj.inputs.colLabel.outputDevices)={cellstr(obj.inputs.output_device(1,idx_outputDevices))};
                     obj.inputs.condMat(i,obj.inputs.colLabel.trials)=(obj.inputs.trials(1,idx_trials)); % may be a problem
                     obj.inputs.condMat(i,obj.inputs.colLabel.iti)=(obj.inputs.iti(1,idx_iti));
                     obj.inputs.condMat(i,obj.inputs.colLabel.si)=(obj.inputs.stimuli(1,idx_si));
                     obj.inputs.condMat(i,obj.inputs.colLabel.chLab)={{targetChannels{1,idx_targetChannels}{1,:},obj.inputs.display_scopes{1,:}}};
                     obj.inputs.condMat(i,obj.inputs.colLabel.axesno)={{targetChannels_ax{1,idx_targetChannels},displayChannels_ax{1,:}}};
                     obj.inputs.condMat(i,obj.inputs.colLabel.measures)={{targetChannels_ax{1,idx_targetChannels}{1,:},displayChannels_ax{1,:}}};
                     obj.inputs.condMat(i,obj.inputs.colLabel.stimMode)={{targetChannels_meas{1,idx_targetChannels}{1,:},displayChannels_meas{1,:}}};


                     if(idx_inputDevices>=numel(obj.inputs.input_device))
                         idx_inputDevices=0;
                     end
                     if(idx_outputDevices>=numel(obj.inputs.output_device))
                         idx_outputDevices=0;
                     end
                     if(idx_targetChannels>=numel(obj.inputs.target_muscle))
                         idx_targetChannels=0;
                     end
                     if(idx_displayChannels>=numel(obj.inputs.display_scopes))
                         idx_displayChannels=0;
                     end
                     if(idx_si>=numel(obj.inputs.stimuli))
                         idx_si=0;
                     end
                     if(idx_iti>=numel(obj.inputs.iti))
                         idx_iti=0;
                     end
                     if(idx_trials>=numel(obj.inputs.trials))
                         idx_trials=0;
                     end

                  end
          end
          
        end
        function best_mep(obj)
            obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).inputs=obj.inputs;
            obj.factorizeConditions
            obj.planTrials
            obj.app.resultsPanel; 
            obj.boot_inputdevice;
            obj.boot_outputdevice;
            obj.bootTrial;
            for tt=1:obj.inputs.totalTrials
            obj.trigTrial;
            obj.readTrial;
            obj.plotTrial;
            obj.prepTrial;
            pause(obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.iti}-toc)
            end
        end
        function best_hotspot(obj)
            obj.factorizeConditions
            obj.planTrials
            obj.app.resultsPanel; 
            obj.boot_inputdevice;
            obj.boot_outputdevice;
            obj.bootTrial;
%             for tt=1:obj.inputs.totalTrials
%             obj.trigTrial;
%             obj.readTrial;
%             obj.plotTrial;
%             obj.prepTrial;
%             pause(obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.iti}-toc)
%             end
obj.stimLoop
        end
        function bootTrial(obj)
           obj.inputs.trial=0;
           obj.prepTrial;
        end
        
        function prepTrial(obj)
            
            obj.inputs.trial=obj.inputs.trial+1;
            
            switch char(obj.inputs.measure_str)
                case 'Motor Hotspot Search'
                    % no update of the intensity is required
                case 'Motor Threshold Hunting'
                    % if trialno 1 , read from the trial mat, otherwise ,
                    % go to the thresholding function and read from there
                otherwise
                    
                    for i=1:numel(obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.outputDevices})
                        switch obj.app.par.hardware_settings.(char(obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.outputDevices}{1,i})).slct_device
                            case 1 % pc controlled magven
                                % --------------------------------------------------------ANOTHER
                                % switch case for the stim mode will be implanted here
                                % later on
                                obj.magven.setAmplitude(obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.si}{1,i});
                            case 2 % pc controlled magstim
                                obj.boot_magstim;
                            case 3 % pc controlled bistim
                                obj.boot_bistim;
                            case 4 % pc controlled rapid
                                obj.boot_rapid;
                            case 5 % boss box controlled magven
                                obj.magven.setAmplitude(obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.si}{1,i});
                                
                            case 6% boss box controlled magstim
                                obj.boot_magstim;
                                obj.boot_bossbox;
                            case 7% boss box controlled bistim
                                obj.boot_bistim;
                                obj.boot_bossbox;
                            case 8% boss box controlled rapid
                                obj.boot_rapid;
                                obj.boot_bossbox;
                            case 9 %simulation
                                disp triggered
                                
                        end
                    end
            end
        end

        function trigTrial(obj)
            for i=1:numel(obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.outputDevices})
                switch obj.app.par.hardware_settings.(char(obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.outputDevices}{1,i})).slct_device
                    case 1 % pc controlled magven
                        switch obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.stimMode}{obj.inputs.trial,i}
                            case 'single_pulse'
                            case 'paired_pulse'
                            case 'burst'
                            case 'train'
                        end
                    case 2 % pc controlled magstim
                        obj.boot_magstim;
                    case 3 % pc controlled bistim
                        obj.boot_bistim;
                    case 4 % pc controlled rapid
                        obj.boot_rapid;
                    case 5 % boss box controlled magven
                        switch char(obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.stimMode}{1,i})
                            
                            case 'single_pulse'
                                obj.bossbox.sendPulse(str2double(obj.app.par.hardware_settings.(char(obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.outputDevices}{1,i})).bb_outputport));
                                tic;
                            case 'paired_pulse'
                            case 'burst'
                            case 'train'
                        end
                    case 6% boss box controlled magstim
                        obj.boot_magstim;
                        obj.boot_bossbox;
                    case 7% boss box controlled bistim
                        obj.boot_bistim;
                        obj.boot_bossbox;
                    case 8% boss box controlled rapid
                        obj.boot_rapid;
                        obj.boot_bossbox;
                    case 9 %simulation
                        disp triggeredTHISONE
                        tic;
                end
            end
        end
        
        function readTrial(obj)
            %device type
            %            then read all channels through it, basically a for loop
            disp enteredREAD
            switch obj.app.par.hardware_settings.(obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.inputDevices}).slct_device

                case 1 % boss box
                    for i=1:numel(obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.chLab})
%                         obj.inputs.rawData.(obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.chLab}).data(obj.inputs.trial,:)=obj.bossbox.exg_scope;
                        obj.inputs.rawData.(obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.chLab}{1,i}).data(obj.inputs.trial,:)=obj.sim_mep*rand;

                    end
                case 2 % fieldtrip
                    % http://www.fieldtriptoolbox.org/faq/how_should_i_get_started_with_the_fieldtrip_realtime_buffer/
                case 3 %Future: input box
                case 4  % simulated data
                    for i=1:numel(obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.chLab})
                        obj.inputs.rawData.(obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.chLab}{1,i}).data(obj.inputs.trial,:)=rand (1,obj.inputs.sc_samples);
                    end
                case 5 %Future: no input box is selected
            end
        end
        
        function plotTrial(obj)
            for i=1:numel(obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.chLab})
                obj.inputs.chLab_idx=i;
                switch (obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.measures}{1,i})
                    case 'MEP_Measurement'
                        % updating analytics panel
                        obj.app.pr.current_totaltrial_no.String=(obj.inputs.totalTrials);
                        obj.app.pr.current_trial.String=obj.inputs.trial;
                        obj.app.pr.current_si.String=obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.si}{1,1};
                        obj.app.pr.current_iti.String=obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.iti};
                        
                        if(obj.inputs.trial==obj.inputs.totalTrials)
                            obj.app.pr.next_totaltrial_no.String=obj.inputs.totalTrials;
                            obj.app.pr.next_trial.String='Completed';
                            obj.app.pr.next_si.String='Completed';
                            obj.app.pr.next_iti.String='Completed';
                        else
                            obj.app.pr.next_totaltrial_no.String=obj.inputs.totalTrials;
                            obj.app.pr.next_trial.String=obj.inputs.trial+1;
                            obj.app.pr.next_si.String=obj.inputs.trialMat{obj.inputs.trial+1,obj.inputs.colLabel.si}{1,1};
                            obj.app.pr.next_iti.String=obj.inputs.trialMat{obj.inputs.trial+1,obj.inputs.colLabel.iti};
                        end
                        
                        obj.mep_plot
                        
                    case 'Motor Threshold Hunting'
                    case 'IOC'
                    case 'Motor Hotspot Search'
                end
            end
        end
        
        function mep_plot(obj)
            %                         1. update analytics panel
            %                         2. update graph
            % 3. update local analytics
            
            ax=['ax' num2str(obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.axesno}{1,obj.inputs.chLab_idx})];
            axes(obj.app.pr.ax.(ax)), hold on,
            switch obj.inputs.trial
                case 1
%                     xlims
%                     xticks
%                     ylim
%                     yticks
%                     xlabel
%                     ylabel
%                     grid
ax
                    obj.info.plt.(ax).current=plot(obj.inputs.rawData.(obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.chLab}{1,obj.inputs.chLab_idx}).data(obj.inputs.trial,:),'Color',[1 0 0],'LineWidth',2);
                case 2
                    delete(obj.info.plt.(ax).current)
                    obj.info.plt.(ax).past=plot(obj.inputs.rawData.(obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.chLab}{1,obj.inputs.chLab_idx}).data(obj.inputs.trial-1,:),'Color',[0.75 0.75 0.75]);
                    obj.info.plt.(ax).mean=plot(mean(obj.inputs.rawData.(obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.chLab}{1,obj.inputs.chLab_idx}).data(:,:)),'color',[0,0,0],'LineWidth',1.5);
                    obj.info.plt.(ax).current=plot(obj.inputs.rawData.(obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.chLab}{1,obj.inputs.chLab_idx}).data(obj.inputs.trial,:),'Color',[1 0 0],'LineWidth',2);
                otherwise
                    delete(obj.info.plt.(ax).current)
                    delete(obj.info.plt.(ax).mean)
                    obj.info.plt.(ax).past=plot(obj.inputs.rawData.(obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.chLab}{1,obj.inputs.chLab_idx}).data(obj.inputs.trial-1,:),'Color',[0.75 0.75 0.75]);
                    obj.info.plt.(ax).mean=plot(mean(obj.inputs.rawData.(obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.chLab}{1,obj.inputs.chLab_idx}).data(:,:)),'color',[0,0,0],'LineWidth',1.5);
                    obj.info.plt.(ax).current=plot(obj.inputs.rawData.(obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.chLab}{1,obj.inputs.chLab_idx}).data(obj.inputs.trial,:),'Color',[1 0 0],'LineWidth',2);
            end
            
        end
        function planTrials(obj)
            %% preparing trialMat

            obj.inputs.totalConds
            for i=1:obj.inputs.totalConds
                cond_id(i,:)=ones(1,cell2mat(obj.inputs.condMat(i,obj.inputs.colLabel.trials)))*i;
            end
                [~,id]=sort(sum(cond_id,2),'descend');
                cond_id=cond_id(id,:);
                [~,n]=size(cond_id);
                randomVect_numel=0;
            for i=1:n
                randVect=cond_id(:,i);
                randVect=randVect(randperm(numel(randVect)));
                randomVect(randomVect_numel+1:randomVect_numel+numel(randVect),1)=randVect;
                randomVect_numel=numel(randomVect);
                
            end
            for i=1:numel(randomVect)
                obj.inputs.trialMat(i,:)=obj.inputs.condMat(randomVect(i,1),:);
            end
            %% preparing ITI 
            if(iscell(obj.inputs.iti{1,1}))
                [m,~]=size(obj.inputs.trialMat);
                for i=1:m
                    iti=obj.inputs.trialMat(i,obj.inputs.colLabel.iti);
                    obj.inputs.trialMat(i,obj.inputs.colLabel.iti)=num2cell(round((iti{1,1}{1,1}+(iti{1,1}{1,2}-iti{1,1}{1,1} ).* rand(1,1)),3));
                end
            end
            
            obj.inputs.totalTrials=m;

            %% preparing prepost stim time var
            obj.planTrials_scopePeriods;
%% preparing the axes development at start
% obj.pr.axesno=
        end
        function planTrials_scopePeriods(obj)
            switch obj.app.par.hardware_settings.(char(obj.inputs.input_device)).slct_device

                case 1 % boss box
                    % multiplying by 5 because the sampling rate is 5khz
                    % and the time is in milieseconds
                    obj.inputs.sc_samples=((obj.inputs.prestim_scope_plt)+(obj.inputs.poststim_scope_plt))*5;
                    obj.inputs.sc_prepostsamples=(obj.inputs.prestim_scope_plt)*(-5);

                case 2 % fieldtrip
                    % http://www.fieldtriptoolbox.org/faq/how_should_i_get_started_with_the_fieldtrip_realtime_buffer/
                case 3 %Future: input box
                case 4  % simulated data
                    obj.inputs.sc_samples=((obj.inputs.prestim_scope_plt)+(obj.inputs.poststim_scope_plt))*5;
                case 5 %Future: no input box is selected
            end
            
        end
        
        function stimLoop(obj)
            
            for tt=1:obj.inputs.totalTrials
                obj.trigTrial;
                obj.readTrial;
                obj.plotTrial;
                obj.prepTrial;
                %             pause(obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.iti}-toc)
                wait_period=obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.iti}-toc;
                wait_idx=3*floor(wait_period);
                for wait_id=1:wait_idx
                    pause(wait_period/wait_idx)
                    if(obj.inputs.stop_event==1)
                        break;
                    end
                end
                if(obj.inputs.stop_event==1)
                    disp('returned after the execution')
                    obj.inputs.stop_event=0;
                    break;
                end
            end
        end
        function timer_fcn(obj)
            disp enteredtimer
        end
        function planTrials_totalTrials(obj)
            %this has to be different for many measures therefore switch is
            %necessary
            switch char(obj.inputs.measure_str)
                case {'MEP_Measurement','IOC','Hotspot'} %correct: the name of switches
                    obj.inputs.totaTrials=sum(obj.inputs.trials)*numel(obj.inputs.stimuli);
            end
        end
        function planTrials_inputDevices(obj)
            obj.inputs.trialMat(1:obj.inputs.totaTrials,obj.inputs.columnLabel.inputDevices)=cellstr(obj.inputs.input_device);
        end
        function planTrials_outputDevices(obj)
            obj.inputs.trialMat(1:obj.inputs.totaTrials,obj.inputs.columnLabel.outputDevices)=cellstr(obj.inputs.output_device);
        end
        function planTrials_measures(obj)
            obj.inputs.trialMat(1:obj.inputs.totaTrials,obj.inputs.columnLabel.measures)=obj.inputs.measures;
        end
        function planTrials_displayChannels(obj)
%             obj.inputs.trialMat(1:obj.inputs.totaTrials,obj.inputs.columnLabel.measures)=
        end
        function planTrials_si(obj)
            switch char(obj.inputs.measure_str)
                case 'MEP_Measurement'
                    stimuli=[];
                    if(numel(obj.inputs.trials)==1)
                        
                        for i=1:(obj.inputs.trials)
                            stimuli = [stimuli, obj.inputs.stimuli(randperm(numel(obj.inputs.stimuli)))];
                        end
                        
                    else
                        stimuli=repelem(obj.inputs.stimuli,obj.inputs.trials);
                        stimuli=stimuli(randperm(length(stimuli)));
                        
                    end
                    obj.inputs.trialMat(:,obj.inputs.columnLabel.si)=stimuli';
                    obj.inputs.trialMat(:,obj.inputs.columnLabel.mt)=round(obj.inputs.trialMat(:,obj.inputs.columnLabel.si)*(obj.inputs.mt_mso/100));
                    
            end
            
        end
        function planTrials_iti(obj)
            if (length(obj.inputs.iti)==2)
                jitter=(obj.inputs.iti(2)-obj.inputs.iti(1));
                iti=ones(1,obj.inputs.totalTrials)*obj.inputs.iti(1);
                iti=iti+rand(1,length(iti))*jitter;
            elseif (length(obj.inputs.iti)==1)
                iti=ones(1,obj.inputs.totalTrials)*(obj.inputs.iti(1));
            else
                error(' BEST Toolbox Error: Inter-Trial Interval (ITI) input vector must be a scalar e.g. 2 or a row vector with 2 elements e.g. [3 4]')
            end
            obj.inputs.trialMat(:,obj.inputs.columnLabel.iti)=(round(iti,3))';
            obj.inputs.trialMat(:,obj.inputs.columnLabel.iti_movsum)=(movsum(iti,[length(iti) 0]))';
            
        end
        function boot_inputdevice(obj)
            switch obj.app.par.hardware_settings.(char(obj.inputs.input_device)).slct_device
                case 1 % boss box
                    % do nothing as mainly the output will automatically
                    % bot it
                case 2 % fieldtrip
                    % http://www.fieldtriptoolbox.org/faq/how_should_i_get_started_with_the_fieldtrip_realtime_buffer/
                case 3 %Future: input box
                case 4  %Future: no input box is selected 
            end
        end
        function boot_outputdevice(obj)
            delete(instrfindall);
            switch obj.app.par.hardware_settings.(char(obj.inputs.output_device)).slct_device
                case 1 % pc controlled magven
                    obj.boot_magven
                case 2 % pc controlled magstim
                    obj.boot_magstim;
                case 3 % pc controlled bistim
                    obj.boot_bistim;
                case 4 % pc controlled rapid
                    obj.boot_rapid;
                case 5 % boss box controlled magven
                    obj.boot_magven;
                    obj.boot_bossbox;
                case 6% boss box controlled magstim
                    obj.boot_magstim;
                    obj.boot_bossbox;
                case 7% boss box controlled bistim
                    obj.boot_bistim;
                    obj.boot_bossbox;
                case 8% boss box controlled rapid
                    obj.boot_rapid;
                    obj.boot_bossbox;
                case 9 %simulation
            end
        end
        function boot_magven(obj)
            obj.magven=magventure(obj.app.par.hardware_settings.(char(obj.inputs.output_device)).comport);
            obj.magven.connect;
            obj.magven.arm;
        end
        function boot_magstim(obj)
            obj.magstim=magstim(obj.app.par.hardware_settings.(obj.inputs.output_device).comport);
            obj.magstim.connect;
            obj.magstim.arm;
        end
        function boot_bistim(obj)
            obj.bistim=magstim(obj.app.par.hardware_settings.(obj.inputs.output_device).comport);
            obj.bistim.connect;
            obj.bistim.arm;
        end
        function boot_rapid(obj)
            obj.rapid=magstim(obj.app.par.hardware_settings.(obj.inputs.output_device).comport);
            obj.rapid.connect;
            obj.rapid.arm;
        end
        function boot_bossbox(obj)
            obj.bossbox=dbsp2('10.10.10.1');
        end
        function best_motorhotspot(obj)
            obj.info.method=obj.info.method+1;
            obj.info.str=strcat('motorhotspot_',num2str(obj.info.method));
            obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).inputs=obj.inputs;
            % todo: obj.data.str.inputs should only save non NaN fields of
            obj.info.event.best_mep_amp=1;
            obj.info.event.best_mep_plot=1;
            obj.info.event.best_mt_pest=NaN;
            obj.info.event.best_mt_plot=NaN;
            obj.info.event.best_ioc_plot=NaN;
            obj.info.event.hotspot=1;
            obj.info.event.best_mt_pest_tc=0;
            obj.info.event.pest_tc=0;
            obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.update_event=0;
            figHandle = findobj('Tag','umi1');
            panelhandle=findobj(figHandle,'Type','axes');
            obj.info.axes.mep=findobj( panelhandle,'Type','axes','Tag','mep');
            obj.best_trialprep;
            obj.best_stimloop;
        end
        function best_motorthreshold(obj)
            obj.info.method=obj.info.method+1;
            obj.info.str=strcat('motorthreshold_',num2str(obj.info.method));
            obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).inputs=obj.inputs;
            % todo: obj.data.str.inputs should only save non NaN fields of
            obj.info.event.best_mep_amp=1;
            obj.info.event.best_mep_plot=1;
            obj.info.event.best_mt_pest=1;
            obj.info.event.best_mt_plot=1;
            obj.info.event.best_ioc_plot=NaN;
            obj.info.event.pest_tc=0;
            obj.info.event.hotspot=0;
            obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.update_event=0;
            figHandle = findobj('Tag','umi1');
            panelhandle=findobj(figHandle,'Type','axes');
            obj.info.axes.mep=findobj( panelhandle,'Type','axes','Tag','mep');
            obj.info.axes.mt=findobj( panelhandle,'Type','axes','Tag','rmt');
            obj.best_trialprep;
            obj.best_mt_pest_boot;
            obj.best_stimloop;
            axes(obj.info.axes.mt);
            str_mt1='Motor Threshold (%MSO): ';
            str_mt2=num2str(obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).results.mt);
            str_mt=[str_mt1 str_mt2];
            y_lim=max(ylim)+1;
            x_lim=mean(xlim)-3;
            obj.info.handles.annotated_trialsNo=text(x_lim, y_lim,str_mt,'FontSize',obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).inputs.FontSize);
            
            
            
        end
        function best_ioc(obj)
            obj.info.method=obj.info.method+1;
            obj.info.str=strcat('ioc_',num2str(obj.info.method));
            obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).inputs=obj.inputs;
            % todo: obj.data.str.inputs should only save non NaN fields of
            obj.info.event.best_mep_amp=1;
            obj.info.event.best_mep_plot=1;
            obj.info.event.best_mt_pest=NaN;
            obj.info.event.best_mt_plot=NaN;
            obj.info.event.best_ioc_plot=1;
            obj.info.event.best_mt_pest_tc=0;
            obj.info.event.pest_tc=0;
            obj.info.event.hotspot=0;
            obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.update_event=0;
            
            
            figHandle = findobj('Tag','umi1')
            panelhandle=findobj(figHandle,'Type','axes')
            obj.info.axes.mep=findobj( panelhandle,'Type','axes','Tag','mep')
            obj.info.axes.ioc_first=findobj( panelhandle,'Type','axes','Tag','ioc')
            obj.info.axes.ioc_second=findobj( panelhandle,'Type','axes','Tag','ioc_fit')
            
            obj.best_trialprep;
            obj.best_stimloop;
            
        end
        function best_motorthreshold_pest_tc(obj)
            obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).inputs=obj.inputs;
            obj.info.event.pest_tc=1;
            obj.info.event.best_mep_amp=1;
            obj.info.event.best_mep_plot=1;
            obj.info.event.best_mt_pest=0;
            obj.info.event.best_mt_plot=1;
            obj.info.event.best_ioc_plot=NaN;
            obj.info.event.best_mt_pest_tc=1;
            obj.info.event.hotspot=0;
            
            obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.update_event=0;
            figHandle = findobj('Tag','umi1');
            panelhandle=findobj(figHandle,'Type','axes');
            obj.info.axes.mep=findobj( panelhandle,'Type','axes','Tag','mep');
            obj.info.axes.mt=findobj( panelhandle,'Type','axes','Tag','rmt');
            obj.best_trialprep;
            obj.best_mt_pest_tc_boot;
            obj.best_stimloop;
            axes(obj.info.axes.mt);
            str_mt1='Motor Threshold (%MSO): ';
            str_mt2=num2str(obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).results.mt);
            str_mt=[str_mt1 str_mt2];
            y_lim=max(ylim)+1;
            x_lim=mean(xlim)-3;
            disp('printing mt value');
            obj.info.handles.annotated_trialsNo=text(x_lim, y_lim,str_mt,'FontSize',obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).inputs.FontSize);
            
            
            
        end
        function best_trialprep(obj)
            %% scope extraction preperation
            obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.sc_ext_samples=((obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).inputs.prestim_scope_ext)+(obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).inputs.poststim_scope_ext))*5;
            obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.sc_ext_prepostsamples=(obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).inputs.prestim_scope_ext)*(-5);
            
            %% scope plotting preperation
            obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.sc_plot_last=(obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).inputs.poststim_scope_plt)*5;
            obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.sc_plot_first=(obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).inputs.prestim_scope_plt)*(5);
            obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.sc_plot_total=obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.sc_plot_last+obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.sc_plot_first;
            %% making time vector
            mep_plot_time_vector=1:obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.sc_plot_total
            mep_plot_time_vector=mep_plot_time_vector./obj.inputs.sc_samplingrate
            mep_plot_time_vector=mep_plot_time_vector*1000
            mep_plot_time_vector=mep_plot_time_vector+(((-1)*obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.sc_plot_first)/(obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).inputs.sc_samplingrate)*1000)
            obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.timevector=mep_plot_time_vector
            
            obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.sc_plot_first=((obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.sc_ext_prepostsamples)*-1)-obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.sc_plot_first;
            obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.sc_plot_last=((obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.sc_ext_prepostsamples)*-1)+obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.sc_plot_last;
            
            
            % % %             obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.timevector = linspace((-1)*obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).inputs.prestim_scope_plt,obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).inputs.poststim_scope_plt,obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.sc_plot_total+1);
            
            
            %%  1. made stimulation vector ;
            % todo2 assert an error here if the stim vector is not equal to trials vector
            if(obj.info.event.hotspot==1)
                obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).trials(1:obj.inputs.trials,1)=NaN;
                obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.total_trials=obj.inputs.trials;
            else
                
                if(obj.info.event.best_mt_pest==1 || obj.info.event.best_mt_pest_tc==1)
                    obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.total_trials=obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).inputs.trials;
                    obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).trials(:,1)=zeros(obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.total_trials,1);
                else
                    % % %                 stimuli=repelem(obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).inputs.stimuli,obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).inputs.trials);
                    % % %                 stimuli=stimuli(randperm(length(stimuli)));
                    % % %                 obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).trials(:,1)=stimuli';
                    % % %                 obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.total_trials=length(stimuli');
                    % % %
                    stimuli=[];
                    if(numel(obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).inputs.trials)==1)
                        
                        for i=1:(obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).inputs.trials)
                            stimuli = [stimuli, obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).inputs.stimuli(randperm(numel(obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).inputs.stimuli)))];
                        end
                        
                    else
                        stimuli=repelem(obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).inputs.stimuli,obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).inputs.trials);
                        stimuli=stimuli(randperm(length(stimuli)));
                        
                    end
                    obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).trials(:,1)=stimuli';
                    obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.total_trials=length(stimuli');
                    
                    
                    
                    
                    if(strcmp(obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).inputs.stim_mode,'MT'))
                        obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).trials(:,5)=round(obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).trials(:,1)*(obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).inputs.mt_mso/100));
                    end
                    
                end
            end
            
            if (length(obj.inputs.trials==1))
                obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.ioc.trialsperSI=obj.inputs.trials/length(obj.inputs.stimuli);
            else
                obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.ioc.trialsperSI=max(obj.inputs.trials);
            end
            %% 2. iti vector (for timer func) and timing sequence (for dbsp) vector ;
            
            
            if (length(obj.inputs.iti)==2)
                jitter=(obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).inputs.iti(2)-obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).inputs.iti(1));
                iti=ones(1,obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.total_trials)*obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).inputs.iti(1);
                iti=iti+rand(1,length(iti))*jitter;
            elseif (length(obj.inputs.iti)==1)
                iti=ones(1,obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.total_trials)*(obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).inputs.iti(1));
            else
                error(' BEST Toolbox Error: Inter-Trial Interval (ITI) input vector must be a scalar e.g. 2 or a row vector with 2 elements e.g. [3 4]')
            end
            obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).trials(:,2)=(round(iti,3))';
            obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).trials(:,3)=(movsum(iti,[length(iti) 0]))';
            
            %             mep_plot_time_vector=1:obj.inputs.sc_samples;
            %             mep_plot_time_vector=mep_plot_time_vector./obj.inputs.sc_samplingrate;
            %             mep_plot_time_vector=mep_plot_time_vector*1000; % conversion from seconds to ms
            %             mep_plot_time_vector=mep_plot_time_vector+((obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).inputs.sc_prepostsamples)/(obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).inputs.sc_samplingrate)*1000);
            %             obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.timevector=mep_plot_time_vector;
            
            
            % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %             obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.totaltime=((obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.sc_plot_total)/(obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).inputs.sc_samplingrate))*1000;
            % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %             obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.prestimulustime=((obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).inputs.sc_prepostsamples)/(obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).inputs.sc_samplingrate))*1000;
            %             obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.timevector=(obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.prestimulustime*1000):((obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.totaltime*1000)+(obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.prestimulustime*1000));
            
            
            % onset offset MEP Amps
            obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.mep_onset_calib=obj.inputs.mep_onset*5000;
            obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.mep_offset_calib=obj.inputs.mep_offset*5000;
            
            obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.mep_onset_samp=abs(obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.sc_ext_prepostsamples)+obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.mep_onset_calib;
            obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.mep_offset_samp=abs(obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.sc_ext_prepostsamples)+obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.mep_offset_calib;
            
            
            % %
            % %             if (obj.inputs.sc_prepostsamples<0)
            % %                 obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.mep_onset_samp=abs(obj.inputs.sc_prepostsamples)+obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.mep_onset_calib;
            % %                 obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.mep_offset_samp=abs(obj.inputs.sc_prepostsamples)+obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.mep_offset_calib;
            % %
            % %             elseif (obj.inputs.sc_prepostsamples>0)
            % %
            % %                 error('BEST Toolbox Error: PrePostSample should be negative in order to be able to get amplitude on required onset')
            % %
            % %             end
            
            
        end
        function best_trialprep_eegtms(obj)
            %phase_angle first coloumn
            phase_angle=[];
            if(numel(obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).inputs.trials)==1)
                
                for i=1:(obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).inputs.trials)
                    phase_angle = [phase_angle, obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).inputs.phase_angle(randperm(numel(obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).inputs.phase_angle)))];
                end
                
            else
                phase_angle=repelem(obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).inputs.phase_angle,obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).inputs.trials);
                phase_angle=phase_angle(randperm(length(phase_angle)));
                
            end
            obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).trials(:,1)=phase_angle';
            obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.total_trials=length(phase_angle');
            
            %phase tolerance second coloumn
            obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).trials(1:obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.total_trials,2)=obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).inputs.phase_tolerance;
            
            %iti third coloumn
            if (length(obj.inputs.iti)==2)
                jitter=(obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).inputs.iti(2)-obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).inputs.iti(1));
                iti=ones(1,obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.total_trials)*obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).inputs.iti(1);
                iti=iti+rand(1,length(iti))*jitter;
            elseif (length(obj.inputs.iti)==1)
                iti=ones(1,obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.total_trials)*(obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).inputs.iti(1));
            end
            obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).trials(:,3)=(round(iti,3))';
            
            % 4th coloumn: stim intensity
            % add the fleixbility such as each phase condition should have
            % all the stim intensity conditions and then the next phase
            % condition and then next too 
            stimuli=[];
            for i=1:(obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.total_trials)
                stimuli = [stimuli, obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).inputs.stimuli(randperm(numel(obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).inputs.stimuli)))];
            end
            stimuli=stimuli(1:obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.total_trials);
            obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).trials(:,4)=stimuli';
            
            
            % 6th col
            obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).trials(1:obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.total_trials,6)=obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).inputs.amp_low;
            obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).trials(1:obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.total_trials,7)=obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).inputs.amp_hi;
            obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).trials(1:obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.total_trials,8 )=obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).inputs.offset_samples;

            
            
            obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).time=linspace(-100,100,1000);
            % 5th coloum low amplitude 
            % 6th coloum upper amplitude
            % 7th coloum output device tag
            %8th coloumn input device tag
            
            % correct when there is a rand in the phaese make the phae
            % tolerance pi over there
            
            idx=find(obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).trials(1:obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.total_trials,1)==2)
            obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).trials(idx,1)=0;
                        obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).trials(idx,2)=pi;

        end
        function best_stimloop_eegtms(obj)
            rtcls = dbsp2('10.10.10.1');
            clab = neurone_digitalout_clab_from_xml(xmlread(obj.inputs.neurone_protocol));
            clab = clab(1:64); % remove EMG channels
            clab{65} = 'FCz';
            rtcls.spatial_filter_clab = clab;
            rtcls.calibration_mode = 'no';
            rtcls.armed = 'no';
            rtcls.sample_and_hold_period=0;
            obj.scope_eeg.NumSamples=0
            obj.scope_eeg.NumPrePostSamples=0
            set_spatial_filter(rtcls, obj.inputs.target_montage_channels, obj.inputs.target_montage_weights, 1)
            set_spatial_filter(rtcls, {}, [], 2)
            rtcls.theta.ignore, pause(0.1)
            rtcls.beta.ignore, pause(0.1)
            rtcls.alpha.ignore, pause(0.1)
            obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.trial=1;
%             f=figure
            while (obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.trial <= obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.total_trials)
                
                if(strcmp(rtcls.armed, 'no'))
                    start(rtcls.scope_eeg)
                    pause(0.05)
                    rtcls.triggers_remaining = 1;
                    rtcls.beta.phase_target(1) = obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).trials(obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.trial,1);
                    rtcls.beta.phase_plusminus(1) = obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).trials(obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.trial,2);
%                     rtcls.configure_time_port_marker([obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).trials(obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.trial,3), 1, 0])
                    rtcls.configure_time_port_marker([0, 1, 0])
                    
rtcls.min_inter_trig_interval = obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).trials(obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.trial,3);
                    %                     rtcls.alpha.amplitude_min(1)= obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).trials(obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.trial,6);
%                     rtcls.alpha.amplitude_max(1)= obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).trials(obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.trial,7);
%                     rtcls.alpha.offset_samples= obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).trials(obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.trial,8);

                    pause(0.1)
                    rtcls.arm;
                end
                
                % trigger has been executed, move to the next condition
                if(rtcls.triggers_remaining == 0)
%                     rtcls.sendPulse
                    rtcls.disarm;
                     %% plotting time locked avg
tic
% % % % % % % % % % Fs = 500;
 obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).rawdata(obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.trial,:)= rtcls.mep';
%                             switch obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).trials(obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.trial,1)
%                                 case 0
%                                     obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).rawdata(obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.trial,:)= rtcls.mep(1);
% %                                     obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).rawdata(obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.trial,:)= [sin([1:Fs]/Fs*5*2*pi)'] + (0.50)*randn(Fs,1);
%                                 case pi
%                                     obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).rawdata(obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.trial,:)=rtcls.mep(1);
% 
% %                                     obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).rawdata(obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.trial,:)=[sin([1:Fs]/Fs*5*2*pi+pi)'] + (0.50)*randn(Fs,1);
%                             end
                D = designfilt('bandpassfir', 'FilterOrder', round(500/5), 'CutoffFrequency1', 45, 'CutoffFrequency2', 55, 'SampleRate', 1000);
                data= obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).rawdata(obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.trial,1:500)';
                obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).trials(obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.trial,5) = phastimate(data, D, 40, 65, 64)
%                 figure
%                 plot(mean(obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).rawdata))

                %% plotting phase histogram
%                 switch obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).trials(obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.trial,1)
%                     case 0
%                         obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).trials(obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.trial,5)=0
%                     case pi
%                         obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).trials(obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.trial,5)=pi
%                 end

                obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.trial
                positive_indices= find(obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).trials(1:obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.trial,1)==pi)
                negative_indices= find(obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).trials(1:obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.trial,1)==0)
                positives=obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).trials(positive_indices,5)
                negatives=obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).trials(negative_indices,5)
                axes(obj.app.pr.eegtms.axes2)
                obj.app.pr.eegtms.axes2.FontSize=15
                hold on
                cla
                                if( obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.trial>4)
%                                     gridxy(150,'Color',[0.97 0.97 0],'linewidth',2) ;
                                    hold on
                                    plot(obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).time,mean(obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).rawdata(positive_indices,:)),'LineWidth',2,'Color','red')
%                                     plot(mean(obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).rawdata(positive_indices,:)),'LineWidth',2,'Color','red')
                                    
hold on
                                   
ylim auto
                                    xlabel('Time (ms)','FontSize',12);
                                    xticks([-75 0 75])
                                    xlim([-75 75])
                                     gridxy(0,'Color',[0.45 0.45 0.45],'linewidth',2) ;
                                    
                % Create ylabel
                ylabel('Voltage (\mu V)','FontSize',12);
                                    hold on
                                    plot(obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).time,mean(obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).rawdata(negative_indices,:)),'LineWidth',2,'Color','green')
%                                     plot(mean(obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).rawdata(negative_indices,:)),'LineWidth',2,'Color','green')

%                                     xticks([-100 0 100])
%                                     xlim([-100 100])
                                end
                axes(obj.app.pr.eegtms.axes1)
                 obj.app.pr.eegtms.axes1.FontSize=15
                hold on
                cla
                obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.trial
                t=positives'-1.58
                polarhistogram(t,36,'FaceColor','red','BinEdges',deg2rad(5:10:355))
                hold on
                positives=[];
                positive_indices=[];
                tt=negatives'-1.58
                polarhistogram(tt,36,'FaceColor','green','BinEdges',deg2rad(5:10:355))
                negatives=[];
                negative_indices=[];
                obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.trial
                                    obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.trial = obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.trial + 1;

                toc
                end
                


                        %plot scope here
                % estimate phase here
                % plot phase here
                
                
                
            end
            disp ended
        end
        
        function best_stimloop(obj)
            
            % % % % % % % % % % % % % % % % % % % % % % % % % % % %             try
            obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.trial=0;
            obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.trial_plotted=0;
            
            if(obj.info.event.hotspot~=1)
                %% initiliaze MAGIC
                % rapid and magstim caluses have to be added up here too and its handling will have to be formulated
                            delete(instrfindall);
                            magventureObject = magventure('COM3'); %0808a
                            magventureObject.connect;
                            magventureObject.arm
            end
            
            %% initiliaze DBSP
            NumSamp=  obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.sc_ext_samples;
            PrePostSamp=obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.sc_ext_prepostsamples;
                        rtcls = dbsp('10.10.10.1',NumSamp,PrePostSamp);
                        clab = neurone_digitalout_clab_from_xml(xmlread('neuroneprotocol.xml')); %adapt this file name as per the inserted file name in the hardware handling module
                        % % %
            
            
            %% set stimulation amp for the first trial using magic
            % use switch case to imply the mag vencture , mag stim and
            % rapid object
            %             magventureObject.setAmplitude(obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).trials((obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.trial+1),1));
            if(obj.info.event.hotspot~=1)
                            if(strcmp(obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).inputs.stim_mode,'MT'))
                                if(obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.trial==obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.total_trials)
                                else
                                    magventureObject.setAmplitude(obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).trials((obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.trial+1),5));
                                end
                            else
                                if(obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.trial==obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.total_trials)
                                else
                                    magventureObject.setAmplitude(obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).trials((obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.trial+1),1));
                                end
                            end
            end
            tic
            %% make timer call back, then stop fcn call back and then the loop stuff and put events marker into it
            while obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.trial<=obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.total_trials-1
                if(obj.inputs.stop_event==1)
                    disp('returned before execution');
                    obj.inputs.stop_event=0;
                    break;
                end
                obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.trial=obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.trial+1;
                tt=obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.trial
                obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.thistime(obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.trial)=toc
                
                                rtcls.sendPulse;
                
                tic
                tic
                                obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).rawdata(obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.trial,:)=rtcls.mep(1); % will have to pur the handle of right, left and APB or FDI muscle here, also there is a third muscle pinky muscle which is used sometime so add for that t00
                
                %% SIM MEP Simulation starts here
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %                 if(obj.info.event.hotspot~=1)
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %                     obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).rawdata(obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.trial,:)=rand*(obj.sim_mep(1,1:NumSamp))*(obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).trials((obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.trial),1));
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %                 else
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %                     obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).rawdata(obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.trial,:)=rand*(obj.sim_mep(1,1:NumSamp));
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %                     
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %                 end
                if (obj.info.event.best_mep_amp==1)
                    obj.best_mep_amp; end
                if (obj.info.event.best_mt_pest==1)
                    obj.best_mt_pest; end
                
                if (obj.info.event.best_mt_pest_tc==1)
                    obj.best_mt_pest_tc; end
                if(obj.info.event.hotspot~=1)
                                    if(strcmp(obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).inputs.stim_mode,'MT'))
                                        if(obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.trial==obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.total_trials)
                                        else
                                            magventureObject.setAmplitude(obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).trials((obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.trial+1),5));
                                        end
                                    else
                                        if(obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.trial==obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.total_trials)
                                        else
                                            magventureObject.setAmplitude(obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).trials((obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.trial+1),1));
                                        end
                                    end
                end
                obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.trial_plotted=obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.trial_plotted+1;
                gg=obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.trial_plotted
                
                disp('plotted')
                if (obj.info.event.best_mep_plot==1)
                    obj.best_mep_plot;
                end
                
                if (obj.info.event.best_mt_plot==1)
                    obj.best_mt_plot; end
                %                 if (obj.info.event.best_mep_amp==1)
                %                     obj.best_mep_amp; end
                if(obj.info.event.best_ioc_plot==1)
                    obj.best_ioc_scatplot; end
                tic
                obj.save_data_runtime
                toc
                disp('data saved')
                
                if (obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.trial_plotted==obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.total_trials)
                    break;
                    
                end
                
                if(obj.inputs.stop_event==1)
                    disp('returned after the execution')
                    obj.inputs.stop_event=0;
                    break;
                end
                time_to_subtract_iti=toc;
                time_to_wait= obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).trials(obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.trial,2)-time_to_subtract_iti;
                %                                   obj.best_wait(time_to_wait)
                
                %  trick for executing stop in between pause time interval is to just divide pause into like 6 or 10
                %  intervals and then put the stop check statement everywhere
                pause(time_to_wait/6)
                
                if(obj.inputs.stop_event==1)
                    disp('returned after the execution and pause')
                    obj.inputs.stop_event=0;
                    break;
                end
                
                pause(time_to_wait/6)
                
                if(obj.inputs.stop_event==1)
                    disp('returned after the execution and pause')
                    obj.inputs.stop_event=0;
                    break;
                end
                
                pause(time_to_wait/6)
                
                if(obj.inputs.stop_event==1)
                    disp('returned after the execution and pause')
                    obj.inputs.stop_event=0;
                    break;
                end
                
                pause(time_to_wait/6)
                
                if(obj.inputs.stop_event==1)
                    disp('returned after the execution and pause')
                    obj.inputs.stop_event=0;
                    break;
                end
                
                pause(time_to_wait/6)
                
                if(obj.inputs.stop_event==1)
                    disp('returned after the execution and pause')
                    obj.inputs.stop_event=0;
                    break;
                end
                
                pause(time_to_wait/6)
                
                if(obj.inputs.stop_event==1)
                    disp('returned after the execution and pause')
                    obj.inputs.stop_event=0;
                    break;
                end
                
            end
            % save('C:\0. HARD DISK\BEST Toolbox\BEST-04.08\GUI','obj')
            
            % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %             catch
            % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %                  save best_toolbox_backup
            % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %             end
            obj.best_mep_stats;
            
            if(obj.info.event.best_ioc_plot==1)
                obj.best_ioc_fit;
                
                obj.best_ioc_plot;
                
            end
            if(obj.info.event.best_mt_pest==1)
                
                obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).results.mt=ceil(mean(obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).trials((obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.total_trials-(obj.inputs.mt_trialstoavg-1):obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.total_trials),1)));
                obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.rmt=obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).results.mt;
            end
            
             if(obj.info.event.pest_tc==1)
                
                if(obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.trial_plotted~=obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.total_trials)
                    total_trials=obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.trial_plotted;
                    obj.inputs.mt_trialstoavg
                    obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.trial_plotted
                    if(obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.trial_plotted<obj.inputs.mt_trialstoavg)
                    obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).results.mt=ceil(mean(obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).trials(:,1)));
                    else
                        obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).results.mt=ceil(mean(obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).trials((total_trials-(obj.inputs.mt_trialstoavg-1):total_trials),1)));

                    end
                    obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.rmt=obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).results.mt;
                    total_trials=[]
                else
                    
                    
                    obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).results.mt=ceil(mean(obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).trials((obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.total_trials-(obj.inputs.mt_trialstoavg-1):obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.total_trials),1)));
                    obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.rmt=obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).results.mt;
                    obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).results.mt
                    obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.total_trials
                    obj.inputs.mt_trialstoavg
                    obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).trials((obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.total_trials-(obj.inputs.mt_trialstoavg-1):obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.total_trials),1)
                end
                
            end
            
        end
        function save_data_runtime(obj)
            varr_runtime.sessions=obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement);
            varr_runtime.inputs=obj.inputs;
            varr_runtime.info=obj.info;
            varr_runtime.info.axes=[];
            best_toolbox_runtime_backup=varr_runtime;
            %             matfilstr=[obj.info.save_str '_matfile.mat']
            save(obj.info.save_str_runtime,'best_toolbox_runtime_backup');
        end
        function best_mep_plot(obj)
            %              figHandle = findobj('Tag','umi1')
            %             ap=findobj( figHandle,'Type','axes')
            
            
            
            axes(obj.info.axes.mep)
            
            set(obj.info.axes.mep,'FontSize',obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).inputs.FontSize)
            
            %  set(gca,'FontSize',obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).inputs.FontSize)
            
            %             ap.Units='normalized'
            %             ap.OuterPosition= [0 0 1 1]
            %             ap.Position= [925 164.3143 400 528.6857]
            
            if (obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.trial_plotted>1)
                
                
                delete(obj.info.handles.annotated_trialsNo);
            end
            str_plottedTrials=['Current Trial/Total Trials: ',num2str(obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.trial_plotted),'/',num2str(obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.total_trials)];
            
            
            
            if (obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.trial_plotted==1)
                % % %
                obj.info.str_amp1='MEP Amp (mv) (Latest | Avg): ';
                % % %             str_plottedTrials=['Current Trial/Total Trials: ',num2str(obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.trial_plotted),'/',num2str(obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.total_trials)];
                % % %             obj.info.handles.annotated_trialsNo=text(0, obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).inputs.ylim_max+1000,str_plottedTrials,'FontSize',25);
                % % %
                % % %
                
                
                obj.info.handles.current_mep_plot=plot(obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.timevector,obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).rawdata(obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.trial_plotted,obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.sc_plot_first+1:obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.sc_plot_last),'Color',[1 0 0],'LineWidth',2);
                hold on;
                ylim([obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).inputs.ylim_min obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).inputs.ylim_max])
                xlim([obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.timevector(1), obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.timevector(end)]);
                % % %                 mat1=obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.prestimulustime:20:(obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.totaltime+obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.prestimulustime)
                % % %                 mat2=[0 obj.inputs.mep_onset*1000 obj.inputs.mep_offset*1000 obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.timevector(end)]
                % % %                 mat=unique(sort([mat1 mat2]))
                % % % %                 mat=unique(mat)
                % % %                 xticks(mat);
                % % %                gridxy([(obj.inputs.mep_onset*1000):5:(obj.inputs.mep_offset*1000)],'Color',[0.97 0.97 0],'linewidth',10) ;
                % % %                 gridxy(0,'Color',[0.97 0.97 0],'linewidth',2) ;
                %    gridxy([(obj.inputs.mep_onset*1000),(obj.inputs.mep_offset*1000)],'Color',[0.97 0.97 0],'linewidth',10) ;
                mat1=obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).inputs.prestim_scope_plt*(-1):10:obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).inputs.poststim_scope_plt
                
                
                mat2=[0 obj.inputs.mep_onset*1000 obj.inputs.mep_offset*1000 obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.timevector(end)]
                mat=unique(sort([mat1 mat2]))
                %                 mat=unique(mat)
                xticks(mat);
                obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.handle_gridxy=gridxy([0 (obj.inputs.mep_onset*1000):0.25:(obj.inputs.mep_offset*1000)],'Color',[219/255 246/255 255/255],'linewidth',1) ;
                if(obj.info.event.best_mt_pest==1 || obj.info.event.pest_tc==1)
                    obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.handle_gridxy_mt_lines=gridxy([],[-obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).inputs.motor_threshold*1000 obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).inputs.motor_threshold*1000],'Color',[0.45 0.45 0.45],'linewidth',1,'LineStyle','--') ;
                    uistack(obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.handle_gridxy_mt_lines,'top');
                    uistack(obj.info.handles.current_mep_plot,'top')
                    
                end
                %23.10
                %  xticks(obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.prestimulustime:20:(obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.totaltime+obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.prestimulustime));
                y_ticks_mep=linspace(obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).inputs.ylim_min,obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).inputs.ylim_max,5)
                yticks(y_ticks_mep);
                %                 yticks(obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).inputs.ylim_min:2000:obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).inputs.ylim_max)
                % obj.info.axes.mep.FontSize=obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).inputs.FontSize;
                
                % legend(obj.info.handles.current_mep_plot,'Current MEP');
                
                % Create xlabel
                xlabel('Time (ms)','FontSize',obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).inputs.FontSize,'FontName','Arial');
                % Create ylabel
                ylabel('EMG Potential (\mu V)','FontSize',obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).inputs.FontSize,'FontName','Arial');
                
                % l=legend(obj.info.handles.current_mep_plot,'Current MEP','Orientation','horizontal','Position',[2000 6 200 200]);
                
                
                
                
                % set(l,'Orientation','horizontal','Location', 'southoutside','FontSize',12);
                disp('this was done');
                obj.info.handles.annotated_trialsNo=text(0, obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).inputs.ylim_max+((obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).inputs.ylim_max)*(0.10)),str_plottedTrials,'FontSize',obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).inputs.FontSize);
                
            elseif (obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.trial_plotted==2)
                
                % % %                 delete(obj.info.handles.annotated_trialsNo);
                % % %                 str_plottedTrials=['Current Trial/Total Trials: ',num2str(obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.trial_plotted),'/',num2str(obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.total_trials)];
                % % %                 obj.info.handles.annotated_trialsNo=text(obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).inputs.stimuli(end)-20, obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).inputs.ylim_max+1000,str_plottedTrials);
                % % %                         obj.info.handles.annotated_trialsNo=text(0, obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).inputs.ylim_max+1000,str_plottedTrials,'FontSize',25);
                
                
                
                ylim([obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).inputs.ylim_min obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).inputs.ylim_max])
                xlim([obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.timevector(1), obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.timevector(end)]);
                
                
                %xticks(obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.prestimulustime:20:(obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.totaltime+obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.prestimulustime));
                % %                 yticks(obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).inputs.ylim_min:2000:obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).inputs.ylim_max)
                y_ticks_mep=linspace(obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).inputs.ylim_min,obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).inputs.ylim_max,5)
                yticks(y_ticks_mep);
                
                %                 obj.info.handles.past_mep_plot=plot(obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.timevector,obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).rawdata(obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.trial_plotted,:),'Color',[0.75 0.75 0.75]);
                %                 hold on;
                %                   obj.info.handles.mean_mep_plot=plot(mean(obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).rawdata),'color',[0,0,0],'LineWidth',1.5);
                % %                  obj.info.handles.mean_mep_plot=plot(NaN,NaN);
                % hold on;
                %                 obj.info.handles.current_mep_plot=plot(obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.timevector,obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).rawdata(obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.trial_plotted,:),'Color',[1 0 0],'LineWidth',2);
                %                 hold on;
                
                %    obj.info.handles.past_mep_plot=plot(obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).rawdata(obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.trial_plotted,:),'Color',[0.75 0.75 0.75]);
                %                 hold on;
                %                 obj.info.handles.mean_mep_plot=plot(mean(obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).rawdata),'color',[0,0,0],'LineWidth',1.5);
                %                 hold on;
                %                 obj.info.handles.current_mep_plot=plot(obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).rawdata(obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.trial_plotted,:),'Color',[1 0 0],'LineWidth',2);
                %                 hold on;
                
                obj.info.handles.past_mep_plot=plot(obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.timevector,obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).rawdata(obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.trial_plotted-1,obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.sc_plot_first+1:obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.sc_plot_last),'Color',[0.75 0.75 0.75]);
                hold on;
                obj.info.handles.mean_mep_plot=plot(obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.timevector,mean(obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).rawdata(:,obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.sc_plot_first+1:obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.sc_plot_last)),'color',[0,0,0],'LineWidth',1.5);
                hold on;
                delete(obj.info.handles.current_mep_plot);
                obj.info.handles.current_mep_plot=plot(obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.timevector,obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).rawdata(obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.trial_plotted,obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.sc_plot_first+1:obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.sc_plot_last),'Color',[1 0 0],'LineWidth',2);
                hold on;
                %  h_legend=[obj.info.handles.past_mep_plot; obj.info.handles.mean_mep_plot; obj.info.handles.current_mep_plot];
                % l=legend(h_legend, 'Previous MEPs', 'Mean Plot', 'Current MEP','FontSize',14,'Position',[1300 0.6 0.1 0.2]);
                %set(l,'Orientation','horizontal','Location', 'southoutside','FontSize',12);
                %                 str_plottedTrials=['Trial Plotted: ',num2str(obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.trial_plotted),'/',num2str(obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.total_trials)];
                %                 str_triggeredTrials=['Trial Triggered: ',num2str(obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.trial),'/',num2str(obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.total_trials)];
                %                 str = {str_plottedTrials,str_triggeredTrials};
                %                 obj.info.handles.annotated_trialsNo=text(80, -10000,str);
                
                obj.info.handles.annotated_trialsNo=text(0, obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).inputs.ylim_max+((obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).inputs.ylim_max)*(0.10)),str_plottedTrials,'FontSize',obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).inputs.FontSize);
                if(obj.info.event.best_mt_pest==1 || obj.info.event.pest_tc==1)
                    uistack(obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.handle_gridxy_mt_lines,'top');
                end
                uistack(obj.info.handles.mean_mep_plot,'top')
                uistack(obj.info.handles.current_mep_plot,'top')
            else
                
                % % %                 delete(obj.info.handles.annotated_trialsNo);
                % % %                 str_plottedTrials=['Current Trial/Total Trials: ',num2str(obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.trial_plotted),'/',num2str(obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.total_trials)];
                % % %                 obj.info.handles.annotated_trialsNo=text(obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).inputs.stimuli(end)-20, obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).inputs.ylim_max+1000,str_plottedTrials);
                % % %
                ylim([obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).inputs.ylim_min obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).inputs.ylim_max])
                xlim([obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.timevector(1), obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.timevector(end)]);
                % % %
                
                
                
                
                %xticks(obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.prestimulustime:20:(obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.totaltime+obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.prestimulustime));
                % % %                 yticks(obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).inputs.ylim_min:2000:obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).inputs.ylim_max)
                y_ticks_mep=linspace(obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).inputs.ylim_min,obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).inputs.ylim_max,5)
                yticks(y_ticks_mep);
                % figure(obj.info.handles.mep_figure);
                %                 str_plottedTrials=['Trial Plotted: ',num2str(obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.trial_plotted),'/',num2str(obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.total_trials)];
                %                 str_triggeredTrials=['Trial Triggered: ',num2str(obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.trial),'/',num2str(obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.total_trials)];
                %                 str = {str_plottedTrials,str_triggeredTrials};
                %                 delete(obj.info.handles.annotated_trialsNo);
                %                 obj.info.handles.annotated_trialsNo=text(80, -10000,str);
                %                  obj.info.handles.past_mep_previousplot=plot(obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).rawdata(obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.trial_plotted-1,:),'Color',[0.75 0.75 0.75]);
                %                 plot(obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).rawdata(obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.trial_plotted-1,:),'Color',[0.75 0.75 0.75]);
                
                
                obj.info.handles.prev_mep_plot=animatedline(obj.info.axes.mep,obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.timevector,obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).rawdata(obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.trial_plotted-1,obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.sc_plot_first+1:obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.sc_plot_last),'color',[0.75 0.75 0.75]);
                obj.info.handles.prev_mep_plot.Annotation.LegendInformation.IconDisplayStyle = 'off';
                
                %                                 h = animatedline(1:1000,obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).rawdata(obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.trial_plotted-2,:));
                %                 h = animatedline(1:1000,obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).rawdata(obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.trial_plotted-3,:));
                %
                %                 addpoints(h,obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).rawdata(obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.trial_plotted-2,:));
                %                 drawnow;
                
                
                %
                % %                 clearpoints(obj.info.handles.mean_mep_plot)
                % %                 obj.info.handles.mean_mep_plot=animatedline(obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.timevector,mean(obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).rawdata),'color',[0,0,0],'LineWidth',1.5);
                % %
                % %                 clearpoints(obj.info.handles.current_mep_plot)
                % %                 obj.info.handles.current_mep_plot=animatedline(obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.timevector,obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).rawdata(obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.trial_plotted,:),'Color',[1 0 0],'LineWidth',2);
                % %
                % %
                %
                %                 set(obj.info.handles.mean_mep_plot,'YData',mean(obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).rawdata(:,obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.sc_plot_first:obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.sc_plot_last)))
                %                 set(obj.info.handles.current_mep_plot,'YData',(obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).rawdata(obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.trial_plotted,obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.sc_plot_first:obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.sc_plot_last)))
                
                delete(obj.info.handles.mean_mep_plot);
                
                if(obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).inputs.plot_reset_pressed==1)
                    obj.info.handles.mean_mep_plot=plot(obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.timevector,mean(obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).rawdata(obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).inputs.plot_reset_idx:obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.trial,obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.sc_plot_first+1:obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.sc_plot_last)),'color',[0,0,0],'LineWidth',1.5);
                else
                    obj.info.handles.mean_mep_plot=plot(obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.timevector,mean(obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).rawdata(:,obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.sc_plot_first+1:obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.sc_plot_last)),'color',[0,0,0],'LineWidth',1.5);
                end
                hold on;
                delete(obj.info.handles.current_mep_plot);
                obj.info.handles.current_mep_plot=plot(obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.timevector,obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).rawdata(obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.trial_plotted,obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.sc_plot_first+1:obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.sc_plot_last),'Color',[1 0 0],'LineWidth',2);
                hold on;
                
                
                if(obj.info.event.best_mt_pest==1 || obj.info.event.pest_tc==1)
                    uistack(obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.handle_gridxy_mt_lines,'top');
                end
                uistack(obj.info.handles.mean_mep_plot,'top')
                uistack(obj.info.handles.current_mep_plot,'top')
                obj.info.handles.annotated_trialsNo=text(0, obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).inputs.ylim_max+((obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).inputs.ylim_max)*(0.10)),str_plottedTrials,'FontSize',obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).inputs.FontSize);
                
                
            end
            
            if(obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.update_event==1)
                delete(obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.handle_gridxy);
                mat1=obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).inputs.prestim_scope_plt*(-1):10:obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).inputs.poststim_scope_plt;
                mat2=[0 obj.inputs.mep_onset*1000 obj.inputs.mep_offset*1000 obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.timevector(end)];
                mat=unique(sort([mat1 mat2]));
                mat=unique(mat);
                xticks(mat);
                obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.handle_gridxy=gridxy([0 (obj.inputs.mep_onset*1000):0.25:(obj.inputs.mep_offset*1000)],'Color',[219/255 246/255 255/255],'linewidth',1) ;
                obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.update_event=0;
            end
            
            format short;
            if (obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).inputs.reset_pressed==0)
                
                if (obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.trial<=obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).inputs.trials_for_mean_annotation)
                    n1=obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.trial;
                    
                    str_amp2=num2str(  ((obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).trials(n1,4))/1000));
                    
                    str_amp4=num2str(((mean  (obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).trials(1:n1,4)))/1000));
                    str_amp_final=[obj.info.str_amp1 str_amp2 ' | ' str_amp4];
                    if(obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.trial>1)
                        delete(obj.info.handles.annotated_mep);
                    end
                    obj.info.handles.annotated_mep=text(0, obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).inputs.ylim_max+(obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).inputs.ylim_max*(0.05)),str_amp_final,'FontSize',obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).inputs.FontSize);
                else
                    delete(obj.info.handles.annotated_mep);
                    n1=obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.trial;
                    n2=obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).inputs.trials_for_mean_annotation;
                    str_amp2=num2str(  ((obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).trials(n1,4))/1000));
                    str_amp4=num2str(((mean  (obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).trials(n1-n2:n1,4)))/1000));
                    str_amp_final=[obj.info.str_amp1 str_amp2 ' | ' str_amp4];
                    obj.info.handles.annotated_mep=text(0, obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).inputs.ylim_max+(obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).inputs.ylim_max*(0.05)),str_amp_final,'FontSize',obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).inputs.FontSize);
                end
            elseif   (obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).inputs.reset_pressed==1)
                obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).inputs.reset_pressed_counter=obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).inputs.reset_pressed_counter+1;
                if(obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).inputs.reset_pressed_counter<=obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).inputs.trials_for_mean_annotation)
                    if(obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).inputs.reset_pressed_counter==1)
                        delete(obj.info.handles.annotated_mep);
                        n1=obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.trial;
                        str_amp2=num2str(  ((obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).trials(n1,4))/1000));
                        str_amp4=num2str(((  (obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).trials(n1,4)))/1000));
                        str_amp_final=[obj.info.str_amp1 str_amp2 ' | ' str_amp4];
                        obj.info.handles.annotated_mep=text(0, obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).inputs.ylim_max+(obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).inputs.ylim_max*(0.05)),str_amp_final,'FontSize',obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).inputs.FontSize);
                    else
                        delete(obj.info.handles.annotated_mep);
                        n1=obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.trial;
                        n3=obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).inputs.reset_pressed_counter;
                        str_amp2=num2str(  ((obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).trials(n1,4))/1000));
                        str_amp4=num2str(((mean  (obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).trials(n1-n3:n1,4)))/1000));
                        str_amp_final=[obj.info.str_amp1 str_amp2 ' | ' str_amp4];
                        obj.info.handles.annotated_mep=text(0, obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).inputs.ylim_max+(obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).inputs.ylim_max*(0.05)),str_amp_final,'FontSize',obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).inputs.FontSize);
                    end
                    
                else
                    obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).inputs.reset_pressed=0;
                    delete(obj.info.handles.annotated_mep);
                    n1=obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.trial;
                    n3=obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).inputs.reset_pressed_counter;
                    str_amp2=num2str(  ((obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).trials(n1,4))/1000));
                    str_amp4=num2str(((mean  (obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).trials(n1-n3:n1,4)))/1000));
                    str_amp_final=[obj.info.str_amp1 str_amp2 ' | ' str_amp4];
                    obj.info.handles.annotated_mep=text(0, obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).inputs.ylim_max+(obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).inputs.ylim_max*(0.05)),str_amp_final,'FontSize',obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).inputs.FontSize);
                    
                end
            end
            
            
            
            % % % % % % %             if(obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.trial==1)
            % % % % % % %                 n1=obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.trial;
            % % % % % % %
            % % % % % % %                 str_amp2=num2str(  ((obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).trials(n1,4))/1000));
            % % % % % % %
            % % % % % % %                 str_amp4=num2str(((mean  (obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).trials(n1,4)))/1000));
            % % % % % % %                 str_amp_final=[obj.info.str_amp1 str_amp2 ' | ' str_amp4];
            % % % % % % %                 obj.info.handles.annotated_mep=text(0, obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).inputs.ylim_max+(obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).inputs.ylim_max*(0.05)),str_amp_final,'FontSize',obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).inputs.FontSize);
            % % % % % % %
            % % % % % % %             elseif(obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.trial==2)
            % % % % % % %                 delete( obj.info.handles.annotated_mep)
            % % % % % % %                 n1=obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.trial;
            % % % % % % %                 str_amp2=num2str(  ((obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).trials(n1,4))/1000));
            % % % % % % %                 str_amp4=num2str(((mean  (obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).trials(n1-1:n1,4)))/1000));
            % % % % % % %                 str_amp_final=[obj.info.str_amp1 str_amp2 ' | ' str_amp4];
            % % % % % % %                 obj.info.handles.annotated_mep=text(0, obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).inputs.ylim_max+(obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).inputs.ylim_max*(0.05)),str_amp_final,'FontSize',obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).inputs.FontSize);
            % % % % % % %
            % % % % % % %             elseif(obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.trial==3)
            % % % % % % %                 delete( obj.info.handles.annotated_mep)
            % % % % % % %                 n1=obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.trial;
            % % % % % % %                 str_amp2=num2str(  ((obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).trials(n1,4))/1000));
            % % % % % % %                 str_amp4=num2str(((mean  (obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).trials(n1-2:n1,4)))/1000));
            % % % % % % %                 str_amp_final=[obj.info.str_amp1 str_amp2 ' | ' str_amp4];
            % % % % % % %                 obj.info.handles.annotated_mep=text(0, obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).inputs.ylim_max+(obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).inputs.ylim_max*(0.05)),str_amp_final,'FontSize',obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).inputs.FontSize);
            % % % % % % %
            % % % % % % %             elseif(obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.trial==4)
            % % % % % % %                 delete( obj.info.handles.annotated_mep)
            % % % % % % %                 n1=obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.trial;
            % % % % % % %                 str_amp2=num2str(  ((obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).trials(n1,4))/1000));
            % % % % % % %                 str_amp4=num2str(((mean  (obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).trials(n1-3:n1,4)))/1000));
            % % % % % % %                 str_amp_final=[obj.info.str_amp1 str_amp2 ' | ' str_amp4];
            % % % % % % %                 obj.info.handles.annotated_mep=text(0, obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).inputs.ylim_max+(obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).inputs.ylim_max*(0.05)),str_amp_final,'FontSize',obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).inputs.FontSize);
            % % % % % % %
            % % % % % % %             else
            % % % % % % %                 delete( obj.info.handles.annotated_mep)
            % % % % % % %                 n1=obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.trial;
            % % % % % % %                 str_amp2=num2str(  ((obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).trials(n1,4))/1000));
            % % % % % % %                 str_amp4=num2str(((mean  (obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).trials(n1-4:n1,4)))/1000));
            % % % % % % %                 str_amp_final=[obj.info.str_amp1 str_amp2 ' | ' str_amp4];
            % % % % % % %                 obj.info.handles.annotated_mep=text(0, obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).inputs.ylim_max+(obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).inputs.ylim_max*(0.05)),str_amp_final,'FontSize',obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).inputs.FontSize);
            % % % % % % %             end
            
            
        end
        function best_mep_amp(obj)
            
            % give handle of post trigger offset and onset
            obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).trials(obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.trial,4)=(max(obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).rawdata(obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.trial,obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.mep_onset_samp:obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.mep_offset_samp)))-(min(obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).rawdata(obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.trial,obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.mep_onset_samp:obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.mep_offset_samp)));
            
            
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
            obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.mt.log = zeros(2,201);
            spot = 1;
            for i = 0:0.5:100
                obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.mt.log(1,spot) = i;
                spot = spot + 1;
            end
            %% Start with hit at 100% intensity and miss at 0% intensity
            spot = 1;
            for i = 0:0.5:100 % go through all possible intensities
                thisCdf = cdfFormula(i);
                % calculate log likelihood function
                obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.mt.log(2,spot) = log(thisCdf(101)) + log(1-thisCdf(61));
                spot = spot + 1;
            end
            
            %%
            
            %find max values, returns intensity (no indice problem)
            maxValues = obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.mt.log(1,find(obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.mt.log(2,:) == max(obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.mt.log(2,:))));
            
            % Middle Value from maxValues
            obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.mt.nextInt = (min(maxValues) + max(maxValues))/2;
            obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).trials(1,1)=obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.mt.nextInt;
            
        end
        function best_mt_pest_tc_boot(obj)
            obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).trials(1,1)=obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).inputs.mt_starting_stim_inten;
        end
        function best_mt_pest(obj)
            
            
            
            %% MEP Measurment
            
            
            
            No_of_iterations=obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.total_trials;
            
            % % %             for N=1:No_of_iterations
            
            % MAGIC command for setting Intensity
            % % %                 rtcls.sendPulse(1); %RTCLS command for stimulating at that command
            % % %                 rtcls.MEP(1);       %RTCLS command for measuring raw data
            % % %                 obj=best_mep_P2Pamp(obj); %BEST command for calcualting P2P amps
            
            % Custom cdf where 'm' is mean and '0.07*m' is predifined variance
            cdfFormula = @(m) normcdf(0:0.5:100,m,0.07*m);
            factor=1;
            
            if (obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.trial>1)
                if obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).trials(obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.trial-1,4) > (obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).inputs.motor_threshold*(1000))
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
            maxValues = obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.mt.log(1,find(obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.mt.log(2,:) == max(obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.mt.log(2,:))));
            % Middle Value from maxValues
            obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.mt.nextInt = round((min(maxValues) + max(maxValues)) / 2);
            %nextInt = maxValues(round(length(maxValues)/2));
            
            % calculate updated log likelihood function
            spot = 1;
            for i = 0:0.5:100 % go through all possible intensities
                thisCdf = cdfFormula(i);
                if evokedMEP == 1 % hit!
                    obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.mt.log(2,spot) = obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.mt.log(2,spot) + factor*log(thisCdf(2*obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.mt.nextInt+1));
                elseif evokedMEP == 0 % miss!
                    obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.mt.log(2,spot) = obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.mt.log(2,spot) + factor*log(1-thisCdf(2*obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.mt.nextInt+1));
                end
                spot = spot + 1;
            end
            
            %display(sprintf('using next intensity: %.2f', obj.nextInt))
            
            obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).trials((obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.trial+1),1)=obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.mt.nextInt;
            %             if (obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.trial<obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.total_trials)
            %             obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).trials((obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.trial+1),1)=obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.mt.nextInt; end
            
        end
        function best_mt_pest_tc(obj)
            if((obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.trial==1))
                experimental_condition = [];
                experimental_condition{1}.name = 'random';
                experimental_condition{1}.phase_target = 0;
                experimental_condition{1}.phase_plusminus = pi;
                experimental_condition{1}.marker = 3;
                experimental_condition{1}.random_delay_range = 0.1;
                experimental_condition{1}.port = 1;
                obj.tc.stimvalue = [obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).inputs.mt_starting_stim_inten 1.0 1.00];
                obj.tc.stepsize = [1 1 1];
                obj.tc.minstep =  1;
                obj.tc.maxstep =  8;
                obj.tc.minvalue = 10;
                obj.tc.maxvalue = 90;
                obj.tc.responses = {[] [] []};
                obj.tc.stimvalues = {[] [] []};  %storage for post-hoc review
                obj.tc.stepsizes = {[] [] []};   %storage for post-hoc review
                
                obj.tc.lastdouble = [0,0,0];
                obj.tc.lastreverse = [0,0,0];
                
                
                
            end
            StimDevice=1;
            stimtype = 1;
            experimental_condition{1}.port = 1;
            
            condition = experimental_condition{1};
            
            
            obj.tc.stimvalues{StimDevice} = [obj.tc.stimvalues{StimDevice}, round(obj.tc.stimvalue(StimDevice),2)];
            obj.tc.stepsizes{StimDevice} = [obj.tc.stepsizes{StimDevice}, round(obj.tc.stepsize(StimDevice),2)];
            
% % % % % % % % % % % % % % % % % % % % % % % % %             obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).trials(obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.trial,4)=input('enter mep amp  ');
            
            
            if obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).trials(obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.trial,4) > (obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).inputs.motor_threshold*(1000))
                %disp('Hit')
                answer = 1;
            else
                %disp('Miss')
                answer = 0;
            end
            
            obj.tc.responses{StimDevice} = [obj.tc.responses{StimDevice}, answer];
            
            
            if length(obj.tc.responses{StimDevice}) == 1
                if answer == 1
                    obj.tc.stepsize(StimDevice) =  -obj.tc.stepsize(StimDevice);
                end
            elseif length(obj.tc.responses{StimDevice}) == 2
                if obj.tc.responses{StimDevice}(end) ~= obj.tc.responses{StimDevice}(end-1)
                    obj.tc.stepsize(StimDevice) = -obj.tc.stepsize(StimDevice)/2;
                    fprintf(' Step Reversed and Halved\n')
                    obj.tc.lastreverse(StimDevice) = length(obj.tc.responses{StimDevice});
                end
                
            elseif length(obj.tc.responses{StimDevice})  == 3
                if obj.tc.responses{StimDevice}(end) ~= obj.tc.responses{StimDevice}(end-1)
                    obj.tc.stepsize(StimDevice) = -obj.tc.stepsize(StimDevice)/2;
                    fprintf(' Step Reversed and Halved\n')
                    obj.tc.lastreverse(StimDevice) = length(obj.tc.responses{StimDevice});
                elseif obj.tc.responses{StimDevice}(end) == obj.tc.responses{StimDevice}(end-1) && obj.tc.responses{StimDevice}(end) == obj.tc.responses{StimDevice}(end-2)
                    obj.tc.stepsize(StimDevice) = obj.tc.stepsize(StimDevice)*2;
                    fprintf(' Step Size Doubled\n')
                    obj.tc.lastdouble(StimDevice) = length(obj.tc.responses{StimDevice});
                end
                
            elseif length(obj.tc.responses{StimDevice}) > 3
                if obj.tc.responses{StimDevice}(end) ~= obj.tc.responses{StimDevice}(end-1)
                    %             rule 1
                    obj.tc.stepsize(StimDevice) = -obj.tc.stepsize(StimDevice)/2;
                    fprintf(' Step Reversed and Halved\n')
                    obj.tc.lastreverse(StimDevice) = length(obj.tc.responses{StimDevice});
                    %             rule 2 doesnt  need any specific dealing
                    %             rule 4
                elseif obj.tc.responses{StimDevice}(end) == obj.tc.responses{StimDevice}(end-2) && obj.tc.responses{StimDevice}(end) == obj.tc.responses{StimDevice}(end-3)
                    obj.tc.stepsize(StimDevice) = obj.tc.stepsize(StimDevice)*2;
                    fprintf(' Step Size Doubled\n')
                    obj.tc.lastdouble(StimDevice) = length(obj.tc.responses{StimDevice});
                    %             rule 3
                elseif obj.tc.responses{StimDevice}(end) == obj.tc.responses{StimDevice}(end-1) && obj.tc.responses{StimDevice}(end) == obj.tc.responses{StimDevice}(end-2) && obj.tc.lastdouble(StimDevice) ~= obj.tc.lastreverse(StimDevice)-1
                    obj.tc.stepsize(StimDevice) = obj.tc.stepsize(StimDevice)*2;
                    fprintf(' Step Size Doubled\n')
                    obj.tc.lastdouble(StimDevice) = length(obj.tc.responses{StimDevice});
                end
                
            end
            
            if abs(obj.tc.stepsize(StimDevice)) < obj.tc.minstep
                if obj.tc.stepsize(StimDevice) < 0
                    obj.tc.stepsize(StimDevice) = -obj.tc.minstep;
                else
                    obj.tc.stepsize(StimDevice) = obj.tc.minstep;
                end
            end
            
            obj.tc.stimvalue(StimDevice) = obj.tc.stimvalue(StimDevice) + obj.tc.stepsize(StimDevice);
            
            if obj.tc.stimvalue(StimDevice) < obj.tc.minvalue
                obj.tc.stimvalue(StimDevice) = obj.tc.minvalue;
                disp('Minimum value reached.')
            end
            
            if obj.tc.stimvalue(StimDevice) > obj.tc.maxvalue
                obj.tc.stimvalue(StimDevice) = obj.tc.maxvalue;
                disp('Max value reached.')
            end
            
            obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).trials((obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.trial+1),1)=obj.tc.stimvalue(StimDevice);
            
            
            
        end
        function best_mt_plot(obj)
            axes(obj.info.axes.mt)
            %             obj.info.axes.mt.FontSize=obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).inputs.FontSize
            
            if(obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.trial==1)
                %  obj.info.handles.mt_figure=figure('name','Motor Thresholding, MEP Amp Trace');
                disp('entered first loop')
                obj.info.handles.mt_plot=plot(obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).trials(1:2,1),'Parent',obj.info.axes.mt,'LineWidth',2);
                %       obj.info.handles.mt_plot=plot(obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).trials(1,1));
                
                xlabel('Trial Number','FontSize',obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).inputs.FontSize);   %TODO: Put if loop of RMT or MSO
                
                % Create ylabel
                ylabel('Stimulation Intensities (%MSO)','FontSize',obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).inputs.FontSize);
                
                
                yticks(0:1:400);
                % x & y ticks and labels
                % will have to be referneced with GUI
                xticks(1:2:100);    % will have to be referneced with GUI
                
                % Create title
                %                 title({'Threshold Hunting - Stimulation Intensities Trace'},'FontWeight','bold','FontSize',obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).inputs.FontSize,'FontName','Calibri');
                set(gcf, 'color', 'w')
            else
                if(obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.trial_plotted==obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.total_trials)
                    obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).trials(end,:)=[];
                else
                    % obj.info.handles.mt_plot=plot(obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).trials(1:obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.trial_plotted+1,1),'Parent',obj.info.axes.mt,'LineWidth',2);
                    set(obj.info.handles.mt_plot,'YData',(obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).trials(1:obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.trial_plotted+1,1)))
                    
                end
            end
            
        end
        function best_mep_stats(obj)
            
            % handle to put 0 in case of unequal trials vector
            % for this calculate the median of all elements seperately
            % then append the missing SI values and replace them by the
            % median
            % then the usual procedure downwards will be working
            
            
            [si,ia,idx] = unique(obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).trials(:,1),'stable');
            mep_median = accumarray(idx,obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).trials(:,4),[],@median);
            mep_mean = accumarray(idx,obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).trials(:,4),[],@mean);
            mep_std = accumarray(idx,obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).trials(:,4),[],@std);
            mep_min = accumarray(idx,obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).trials(:,4),[],@min);
            mep_max = accumarray(idx,obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).trials(:,4),[],@max);
            mep_var = accumarray(idx,obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).trials(:,4),[],@var);
            M=[si,mep_median,mep_mean,mep_std, mep_min, mep_max, mep_var];
            M1 = M(randperm(size(M,1)),:,:,:,:,:,:);
            obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).results.mep_stats(:,1)=M1(:,1); %Sampled SIs
            obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).results.mep_stats(:,2)=M1(:,2); %Sampled Medians MEPs
            obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).results.mep_stats(:,3)=M1(:,3); %Mean MEPs over trial
            obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).results.mep_stats(:,4)=M1(:,4); %Std MEPs
            obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).results.mep_stats(:,5)=M1(:,5); %Min of MEPs
            obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).results.mep_stats(:,6)=M1(:,6); %Max of MEPs
            obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).results.mep_stats(:,7)=M1(:,7); %Var of MEPs
            obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.SI=obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).results.mep_stats(:,1);
            obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.MEP=obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).results.mep_stats(:,2);
            
            obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).results.mep_stats(:,8)=(obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).results.mep_stats(:,4))/sqrt(numel(obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).results.mep_stats(:,4)));    %TODO: Make it modular by replacing 15 to # trials per intensity object value
            obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.SEM=obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).results.mep_stats(:,8);
        end
        function best_ioc_fit(obj)
            %obj.info.handles.ioc_plot_fig=figure('name',' MEP Dose-Response Curve');
            axes(obj.info.axes.ioc_second)
            %  set(gcf,'Visible', 'off');
            [SIData, MEPData] = prepareCurveData(obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).results.mep_stats(:,1) ,obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).results.mep_stats(:,2));
            ft = fittype( 'MEPmax*SI^n/(SI^n+SI50^n)', 'independent', 'SI', 'dependent', 'MEP' );
            %             ft = best_fittype( 'MEPmax*SI^n/(SI^n+SI50^n)', 'independent', 'SI', 'dependent', 'MEP' );
            
            %% Optimization of fit paramters;
            
            opts = fitoptions( ft );
            opts.Display = 'Off';
            opts.Lower = [0 0 0 ];
            opts.StartPoint = [10 10 10];
            opts.Upper = [Inf Inf Inf];
            
            %% Fit sigmoid model to data
            
            [obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.ioc.fitresult,obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.ioc.gof] = fit( SIData, MEPData, ft, opts);
            %% Extract fitted curve points
            
            plot( obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.ioc.fitresult, SIData, MEPData);
            
            obj.info.handle.ioc_curve= get(gca,'Children');
            x1lim=xlim
            y1lim=ylim
            
            
            
            bg = gca; legend(bg,'off');
            
        end
        function best_ioc_plot(obj)
            %             figure(obj.info.handles.ioc_plot_fig)
            %             set(gcf,'Visible', 'off');
            
            format short g
            %% Inflection point (ip) detection on fitted curve
            %             index_ip=find(abs(obj.curve(1).XData-obj.fitresult.SI50)<10^-1, 1, 'first');
            %              obj.ip_x=obj.curve(1).XData(index_ip);
            %             ip_y = obj.curve(1).YData(index_ip)
            
            [value_ip , index_ip] = min(abs(obj.info.handle.ioc_curve(1).XData-obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.ioc.fitresult.SI50));
            obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.ip_x = obj.info.handle.ioc_curve(1).XData(index_ip);
            ip_y = obj.info.handle.ioc_curve(1).YData(index_ip);
            
            %% Plateau (pt) detection on fitted curve
            %             index_pt=find(abs(obj.curve(1).YData-obj.fitresult.MEPmax)<10^1, 1, 'first');
            %             obj.pt_x=obj.curve(1).XData(index_pt);
            %             pt_y=obj.curve(1).YData(index_pt);
            %
            [value_pt , index_pt] = min(abs(obj.info.handle.ioc_curve(1).YData-(0.993*(obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.ioc.fitresult.MEPmax) ) ) );   %99.3 % of MEP max %TODO: Test it with longer plateu
            obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.pt_x=obj.info.handle.ioc_curve(1).XData(index_pt);
            pt_y=obj.info.handle.ioc_curve(1).YData(index_pt);
            
            %% Threshold (th) detection on fitted curve
            %             if(strcmp(obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).inputs.stim_mode,'MSO'))
            %
            %                     index_ip1=index_ip+2;
            %                 ip1_x=obj.info.handle.ioc_curve(1).XData(index_ip1);
            %                 ip1_y=obj.info.handle.ioc_curve(1).YData(index_ip1);
            %                 % Calculating slope (m) using two-points equation
            %                 m1=(ip1_y-ip_y)/(ip1_x-obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.ip_x)
            %                 m=m1
            %                 % Calculating threshold (th) using point-slope equation
            %                 obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.th=obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.ip_x-(ip_y/m);
            %             end
            
            [value_th , index_th] = min(abs(obj.info.handle.ioc_curve(1).YData-50 ) );   % change the 50 to be adaptive to what threshold in mV or microV is given
            obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.th=obj.info.handle.ioc_curve(1).XData(index_th);
            
            
            
            
            %% Creating plot
            %         figure(4)
            hold on;
            h = plot( obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.ioc.fitresult, obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.SI, obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.MEP);
            set(h(1), 'MarkerFaceColor',[0 0 0],'MarkerEdgeColor',[0 0 0],'Marker','square','LineStyle','none');
            
            % Plotting SEM on Curve points
            errorbar(obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.SI, obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.MEP ,obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.SEM, 'o');
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
            
            
            SI_min_point = (round(min(obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.SI)/5)*5)-5; % Referncing the dotted lines wrt to lowest 5ths of SI_min
            % SI_min_point = 0;
            seet=-0.5;
            ylim_ioc=-500;
            
            
            % Plotting Inflection point's horizontal & vertical dotted lines
            % %             plot([obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.ip_x,SI_min_point],[ip_y,ip_y],'--','Color' , [0.75 0.75 0.75]);
            % %             plot([obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.ip_x,obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.ip_x],[ip_y,seet],'--','Color' , [0.75 0.75 0.75]);
            % %             legend_ip=plot(obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.ip_x,ip_y,'rs','MarkerSize',15);
            
            plot([obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.ip_x,min(xlim)],[ip_y,ip_y],'--','Color' , [0.75 0.75 0.75]);
            plot([obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.ip_x,obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.ip_x],[ip_y,ylim_ioc],'--','Color' , [0.75 0.75 0.75]);
            legend_ip=plot(obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.ip_x,ip_y,'rs','MarkerSize',15);
            
            
            % Plotting Plateau's horizontal & vertical dotted lines
            plot([obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.pt_x,min(xlim)],[pt_y,pt_y],'--','Color' , [0.75 0.75 0.75]); %xline
            plot([obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.pt_x,obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.pt_x],[pt_y,ylim_ioc],'--','Color' , [0.75 0.75 0.75]);
            legend_pt=plot(obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.pt_x,pt_y,'rd','MarkerSize',15);
            
            % Plotting Threshold's horizontal & vertical dotted lines
            if(strcmp(obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).inputs.stim_mode,'MT'))
                %% Creating legends
                h_legend=[h(1); h(2); legend_ip;legend_pt];
                %l=legend(h_legend, 'Amp(MEP) vs Stim. Inten', 'Sigmoid Fit', 'Inflection Point','Plateau');
                %set(l,'Orientation','horizontal','Location', 'southoutside','FontSize',12);
                
                %% Creating Properties annotation box
                
                str_ip=['Inflection Point: ',num2str(obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.ip_x),' (%MT)',' , ',num2str(ip_y),' (\muV)'];
                str_pt=['Plateau: ',num2str(obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.pt_x),' (%MT)',' , ',num2str(pt_y),' (\muV)'];
                
                
                dim = [0.69 0.35 0 0];
                str = {str_ip,[],str_pt};
                annotation('textbox',dim,'String',str,'FitBoxToText','on','FontSize',12);
            else
                disp('error is here');
                plot([obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.th,min(xlim)],[0.05,0.05],'--','Color' , [0.75 0.75 0.75]);
                plot([obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.th,obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.th],[0.05,ylim_ioc],'--','Color' , [0.75 0.75 0.75]);
                legend_th=plot(obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.th, 0.05,'r*','MarkerSize',15);
                
                
                
                %% Creating legends
                h_legend=[h(1); h(2); legend_ip;legend_pt;legend_th];
                %l=legend(h_legend, 'Amp(MEP) vs Stim. Inten', 'Sigmoid Fit', 'Inflection Point','Plateau','Threshold');
                %set(l,'Orientation','horizontal','Location', 'southoutside','FontSize',12);
                
                %% Creating Properties annotation box
                
                str_ip=['Inflection Point: ',num2str(obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.ip_x),' (%MSO)',' , ',num2str(ip_y),' (\muV)'];
                str_pt=['Plateau: ',num2str(obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.pt_x),' (%MSO)',' , ',num2str(pt_y),' (\muV)'];
                str_th=['Thershold: ',num2str(obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.th),' (%MSO)',' , ', '0.05',' (\muV)'];
                
                dim = [0 0 0.5 0.5];
                str = {str_ip,[],str_th,[],str_pt};
                %                 annotation('textbox',dim,'String',str,'FitBoxToText','on','FontSize',12,'units','normalized');
                
            end
            xlim
            ylim([-500 Inf])
            xticks
            yticks
            store2=get(gca,'YTick')
            xticklabels
            yticklabels
            xlim([min(obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.SI)-5 max(obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.SI)+5]);
            % %             store2=get(gca,'YTick')
            %             xlim([min(xlim) (max(xlim)+5)])
            %             y_limm=ylim
            %             yt=yticks
            %             xt=xticks
            %             xl=xlim
            text((max(xlim)-30), -200,str,'FontSize',12);
            
            bt = gca; legend(bt,'off');
            box on; drawnow;
            
            % %             code for copying the axes from one fig to another fig
            
            % % % % % % %              f1 = figure('Units','normalized', 'Position', [0 0 0.8 0.8]); % Open a new figure with handle f1
            % % % % % % % s = copyobj(obj.info.axes.ioc_second,f1)
            
            % set(gcf,'Visible', 'on');
            
            
            
            
        end
        function best_ioc_scatplot(obj)
            axes(obj.info.axes.ioc_first)
            ylim auto
            set(obj.info.axes.ioc_first,'FontSize',obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).inputs.FontSize)
            % x & y ticks and labels
            % will have to be referneced with GUI
            %  xticks(obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).inputs.stimuli);    % will have to be referneced with GUI
            
            
            
            
            if(obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.trial==1)
                %   obj.info.handles.ioc_scatplot_fig=figure('name','IOC - MEP Amp Scatter Plot');
                
                obj.info.handles.ioc_scatplot=plot(obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).trials(1,1),obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).trials(1,4),'o','Color','r','MarkerSize',8,'MarkerFaceColor','r');
                hold on;
                xlabel('Stimulation Intensities','FontSize',obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).inputs.FontSize);   %TODO: Put if loop of RMT or MSO
                
                % Create ylabel
                ylabel('MEP P2P Amplitude (\muV)','FontSize',obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).inputs.FontSize);
                low=obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).inputs.stimuli(1)-10
                up=obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).inputs.stimuli(end)+10
                temp_str=unique(sort([obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).inputs.stimuli obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).inputs.stimuli(1)-10 obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).inputs.stimuli(end)+10]))
                
                xlim([low up]);
                xticks(temp_str)
                
                
                %                 xticks(temp_str);
                % Create title
                % title({'IOC - MEP Amp Scatter Plot'},'FontWeight','bold','FontSize',14,'FontName','Calibri');
                set(gcf, 'color', 'w')
            end
            % figure(obj.info.handles.ioc_scatplot_fig);
            if (obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.trial>1)
                set(obj.info.handles.ioc_scatplot,'Color',[0.45 0.45 0.45],'MarkerSize',8,'MarkerFaceColor',[0.45 0.45 0.45])
            end
            obj.info.handles.ioc_scatplot=plot(obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).trials(obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.trial_plotted,1),obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).trials(obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.trial_plotted,4),'o','MarkerSize',8,'Color','r','MarkerFaceColor','r');
            
            hold on;
            %             set(obj.info.handles.ioc_scatplot,'XData',obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).trials(obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.trial_plotted,1),'YData',obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).trials(obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.trial_plotted,4));
            %             hold on;
            uistack(obj.info.handles.ioc_scatplot,'top')
        end
        function best_wait(obj,varargin)
            tic;
            disp('entered')
            while(obj.inputs.NN>0)
                obj.inputs.NN=obj.inputs.NN+1
                if(toc>=varargin{1})
                    break
                end
                
                if(obj.inputs.stop_event==1)
                    disp('entered stoppped')
                    
                    obj.inputs.stop_event=0;
                    break
                end
            end
            return
            disp('returned')
            % reuturn, type return here as it would take this entire function out of the entire
            % execution mode and thats how it becomes the auto wait func
        end
        function best_posthoc_mep_plot(obj)
            axes(obj.info.axes.mep)
            set(obj.info.axes.mep,'FontSize',obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).inputs.FontSize)
            
            
            obj.info.handles.current_mep_plot_ph=plot(obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.timevector,obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).rawdata(obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.trial_plotted,obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.sc_plot_first+1:obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.sc_plot_last),'Color',[1 0 0],'LineWidth',2);
            hold on;
            obj.info.handles.past_mep_plot_ph=plot(obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.timevector,obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).rawdata(:,obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.sc_plot_first+1:obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.sc_plot_last),'Color',[0.75 0.75 0.75]);
            hold on;
            obj.info.handles.mean_mep_plot_ph=plot(obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.timevector,mean(obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).rawdata(:,obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.sc_plot_first+1:obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.sc_plot_last)),'color',[0,0,0],'LineWidth',1.5);
            
            str_plottedTrials=['Current Trial/Total Trials: ',num2str(obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.trial_plotted),'/',num2str(obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.total_trials)];
            
            obj.info.str_amp1='MEP Amp (mv) (Latest | Avg): ';
            
            ylim([obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).inputs.ylim_min obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).inputs.ylim_max])
            xlim([obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.timevector(1), obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.timevector(end)]);
            
            mat1=obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).inputs.prestim_scope_plt*(-1):10:obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).inputs.poststim_scope_plt
            
            
            mat2=[0 obj.inputs.mep_onset*1000 obj.inputs.mep_offset*1000 obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.timevector(end)]
            mat=unique(sort([mat1 mat2]))
            %                 mat=unique(mat)
            xticks(mat);
            try
                if(obj.info.event.mep_plot_ph==1)
                    obj.info.event.mep_plot_ph=0;
                    obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.handle_gridxy_mt_lines=gridxy([],[-obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).inputs.motor_threshold*1000 obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).inputs.motor_threshold*1000],'Color',[0.45 0.45 0.45],'linewidth',1,'LineStyle','--') ;
                end
            catch
            end
            obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.handle_gridxy=gridxy([0 (obj.inputs.mep_onset*1000):0.25:(obj.inputs.mep_offset*1000)],'Color',[219/255 246/255 255/255],'linewidth',1) ;
            
            y_ticks_mep=linspace(obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).inputs.ylim_min,obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).inputs.ylim_max,5)
            yticks(y_ticks_mep);
            xlabel('Time (ms)','FontSize',obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).inputs.FontSize,'FontName','Arial');
            % Create ylabel
            ylabel('EMG Potential (\mu V)','FontSize',obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).inputs.FontSize,'FontName','Arial');
            
            obj.info.handles.annotated_trialsNo=text(0, obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).inputs.ylim_max+((obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).inputs.ylim_max)*(0.10)),str_plottedTrials,'FontSize',obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).inputs.FontSize);
            
            
            mat1=obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).inputs.prestim_scope_plt*(-1):10:obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).inputs.poststim_scope_plt;
            mat2=[0 obj.inputs.mep_onset*1000 obj.inputs.mep_offset*1000 obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.timevector(end)];
            mat=unique(sort([mat1 mat2]));
            mat=unique(mat);
            xticks(mat);
            
            obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.handle_gridxy=gridxy([0 (obj.inputs.mep_onset*1000):0.25:(obj.inputs.mep_offset*1000)],'Color',[219/255 246/255 255/255],'linewidth',1) ;
            
            obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.update_event=0;
            
            n1=obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.trial;
            % %
            % n3=obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).inputs.reset_pressed_counter;
            %  error
            n3=5;
            str_amp2=num2str(  ((obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).trials(n1,4))/1000));
            if(n1>n3)
                str_amp4=num2str(((mean  (obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).trials(n1-n3:n1,4)))/1000));
            else
                str_amp4=num2str(((mean  (obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).trials(n1-(n3-3):n1,4)))/1000));
                
            end
            str_amp_final=[obj.info.str_amp1 str_amp2 ' | ' str_amp4];
            obj.info.handles.annotated_mep=text(0, obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).inputs.ylim_max+(obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).inputs.ylim_max*(0.05)),str_amp_final,'FontSize',obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).inputs.FontSize);
            
            
            
            
            
            obj.info.handles.past_mep_plot_ph=plot(obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.timevector,obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).rawdata(:,obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.sc_plot_first+1:obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.sc_plot_last),'Color',[0.75 0.75 0.75]);
            hold on;
            obj.info.handles.mean_mep_plot_ph=plot(obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.timevector,mean(obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).rawdata(:,obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.sc_plot_first+1:obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.sc_plot_last)),'color',[0,0,0],'LineWidth',1.5);
            hold on;
            obj.info.handles.current_mep_plot_ph=plot(obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.timevector,obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).rawdata(obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.trial_plotted,obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.sc_plot_first+1:obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.sc_plot_last),'Color',[1 0 0],'LineWidth',2);
            
        end
        function best_posthoc_mt_plot(obj)
            axes(obj.info.axes.mt)
            set(obj.info.axes.mt,'FontSize',obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).inputs.FontSize);
            obj.info.handles.mt_plot=plot(obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).trials(:,1),'LineWidth',2);
            xlabel('Trial Number','FontSize',obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).inputs.FontSize);   %TODO: Put if loop of RMT or MSO
            ylabel('Stimulation Intensities (%MSO)','FontSize',obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).inputs.FontSize);
            yticks(0:1:400);
            % x & y ticks and labels
            % will have to be referneced with GUI
            xticks(1:2:100);    % will have to be referneced with GUI
            set(gcf, 'color', 'w')
        end
        function best_posthoc_ioc_scatplot(obj)
            axes(obj.info.axes.ioc_first)
            set(obj.info.axes.ioc_first,'FontSize',obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).inputs.FontSize)
            obj.info.handles.ioc_scatplot=plot(obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).trials(1:end-1,1),obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).trials(1:end-1,4),'o','MarkerSize',8,'Color',[0.45 0.45 0.45],'MarkerFaceColor',[0.45 0.45 0.45]);
            hold on;
            obj.info.handles.ioc_scatplot=plot(obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).trials(end,1),obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).trials(end,4),'o','MarkerSize',8,'Color','r','MarkerFaceColor','r');
            hold on;
            set(gcf, 'color', 'w')
            xlabel('Stimulation Intensities','FontSize',obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).inputs.FontSize);   %TODO: Put if loop of RMT or MSO
            ylabel('MEP P2P Amplitude (\muV)','FontSize',obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).inputs.FontSize);
            low=obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).inputs.stimuli(1)-10
            up=obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).inputs.stimuli(end)+10
            temp_str=unique(sort([obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).inputs.stimuli obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).inputs.stimuli(1)-10 obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).inputs.stimuli(end)+10]));
            xlim([low up]);
            xticks(temp_str)
            
        end
        function best_mep_posthoc(obj)
            figHandle = findobj('Tag','umi1');
            panelhandle=findobj(figHandle,'Type','axes');
            obj.info.axes.mep=findobj( panelhandle,'Type','axes','Tag','mep');
            obj.best_posthoc_mep_plot;
            obj.info.axes.mep
        end
        function best_mt_posthoc(obj)
            figHandle = findobj('Tag','umi1');
            panelhandle=findobj(figHandle,'Type','axes');
            obj.info.axes.mep=findobj( panelhandle,'Type','axes','Tag','mep');
            obj.info.axes.mt=findobj( panelhandle,'Type','axes','Tag','rmt');
            obj.info.event.mep_plot_ph=1;
            obj.best_posthoc_mep_plot;
            obj.best_posthoc_mt_plot;
            axes(obj.info.axes.mt);
            str_mt1='Motor Threshold (%MSO): ';
            str_mt2=num2str(obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).results.mt);
            str_mt=[str_mt1 str_mt2];
            y_lim=max(ylim)+1;
            x_lim=mean(xlim)-3;
            obj.info.handles.annotated_trialsNo=text(x_lim, y_lim,str_mt,'FontSize',obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).inputs.FontSize);
            
            
        end
        function best_hotspot_posthoc(obj)
            figHandle = findobj('Tag','umi1');
            panelhandle=findobj(figHandle,'Type','axes');
            obj.info.axes.mep=findobj( panelhandle,'Type','axes','Tag','mep');
            obj.best_posthoc_mep_plot;
        end
        function best_ioc_posthoc(obj)
            figHandle = findobj('Tag','umi1');
            panelhandle=findobj(figHandle,'Type','axes');
            obj.info.axes.mep=findobj( panelhandle,'Type','axes','Tag','mep');
            obj.info.axes.ioc_first=findobj( panelhandle,'Type','axes','Tag','ioc');
            obj.info.axes.ioc_second=findobj( panelhandle,'Type','axes','Tag','ioc_fit');
            
            obj.best_posthoc_mep_plot;
            obj.best_posthoc_ioc_scatplot;
            obj.best_ioc_fit;
            obj.best_ioc_plot;
            
            
        end
        function best_eegtms(obj)
            obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).inputs=obj.inputs;
            obj.best_trialprep_eegtms;
            obj.best_stimloop_eegtms;
        end
        %% new functions
        function best_boot_inputdevice(obj)
            %input device marker for boss box=1
            %input device marker for fieldtrip buffer=2
            %it is assumed that there will always be one input device
            obj.bossbox=[];
            obj.ftbuffer=[];
            if(obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).trials(:,2)==1)
                obj.bossbox=dbsp('10.10.10.1');
                %add the reference of a particularly attached neurone
                %protofol file here in the lower line
                % ask about the reference channel in neurone input channel
                % box
                clab = neurone_digitalout_clab_from_xml(xmlread(obj.inputs.neurone_protocol));
                clab = clab(1:64); % remove EMG channels
                clab{65} = 'FCz';
                obj.bossbox.spatial_filter_clab = clab;
                obj.bossbox.sample_and_hold_period=0;
            elseif(obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).trials(:,2)==2)
            end
            
        end
        function boot_bb(obj)
            obj.bossbox=dbsp2('10.10.10.1');

            
        end
        
        
          
    end
end
