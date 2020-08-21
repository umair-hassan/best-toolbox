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
        bossbox;
        
        
    end
    
    properties (Hidden)
        
        magven
        magStim
        bistim
        rapid
        digitimer
        fieldtrip
        app;
        tc
        best_timer;
        FilterCoefficients;
        handles;
        BESTData
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
            obj.inputs.ylimMin=-500;
            obj.inputs.ylimMax=+500;
            obj.inputs.stop_event=0;
            
            
            obj.info.event.hotspot=0;
            obj.info.handles.annotated_trialsNo=0;
            obj.info.event.pest_tc=NaN;
            obj.inputs.mt_starting_stim_inten=25;
            obj.info.event.best_mt_pest_tc=0;
        end
        function factorizeConditions(obj)
            %% Deleting Previous best_toolbox class
            obj.inputs=[];
            obj.bossbox=[];
            obj.magven=[];
            obj.magStim=[];
            obj.digitimer=[];
            obj.fieldtrip=[];
            obj.app.pr=[];
            %% Preparing Parameters to Inputs
            cb_Pars2Inputs
            %% Evaluating Linked Lists
%             cb_EvaluateLinkedLists
            %% Evaluating Selected Protocol
            switch obj.inputs.Protocol
                case 'MEP Hotspot Search Protocol'
                    %% Adjusting New Arhictecture to Old Architecture
                    obj.inputs.MEPOnset=obj.inputs.MEPSearchWindow(1);
                    obj.inputs.MEPOffset=obj.inputs.MEPSearchWindow(2);
                    obj.inputs.EMGDisplayPeriodPre=obj.inputs.EMGExtractionPeriod(1)*(-1);
                    obj.inputs.EMGDisplayPeriodPost=obj.inputs.EMGExtractionPeriod(2);
                    obj.inputs.prestim_scope_plt=obj.inputs.EMGDisplayPeriodPre;
                    obj.inputs.poststim_scope_plt=obj.inputs.EMGDisplayPeriodPost;
                    obj.inputs.mep_onset=obj.inputs.MEPOnset;
                    obj.inputs.mep_offset=obj.inputs.MEPOffset;
                    obj.inputs.input_device=obj.app.pi.hotspot.InputDevice.String(obj.inputs.InputDevice); %TODO: the drc or mep on the 4th structure is not a good solution!
                    obj.inputs.output_device=obj.app.pi.hotspot.OutputDevice.String(obj.inputs.OutputDevice);
                    obj.inputs.stim_mode='MSO';
                    obj.inputs.measure_str='Motor Hotspot Search';
                    obj.inputs.ylimMin=obj.inputs.EMGDisplayYLimMin;
                    obj.inputs.ylimMax=obj.inputs.EMGDisplayYLimMax;
                    obj.inputs.stop_event=0;
                    obj.inputs.ylimMin=-3000;
                    obj.inputs.ylimMax=+3000;
                    obj.inputs.TrialNoForMean=1;
                    obj.inputs.BrainState=1;
                    %% Creating Column Labels
                    obj.inputs.colLabel.inputDevices=1;
                    obj.inputs.colLabel.outputDevices=2;
                    obj.inputs.colLabel.si=3;
                    obj.inputs.colLabel.iti=4;
                    obj.inputs.colLabel.chLab=5;
                    obj.inputs.colLabel.trials=9;
                    obj.inputs.colLabel.axesno=6;
                    obj.inputs.colLabel.measures=7;
                    obj.inputs.colLabel.stimMode=8;
                    obj.inputs.colLabel.tpm=10;
                    obj.inputs.colLabel.chType=11;
                    obj.inputs.colLabel.chId=12;
                    %% Creating Channel Type and Channel ID
                    switch obj.app.par.hardware_settings.(char(obj.inputs.input_device)).slct_device
                        case 1 %boss box
                            ChannelType=[repmat({'EMG'},1,numel(obj.inputs.EMGDisplayChannels))];
                            ChannelID=num2cell(1:numel(ChannelType));
                            obj.inputs.ChannelsTypeUnique=ChannelType;
                            for ChannelType2=1:numel(obj.inputs.EMGDisplayChannels)
                                ChannelID{ChannelType2}=find(strcmp(obj.app.par.hardware_settings.(char(obj.inputs.input_device)).NeurOneProtocolChannelLabels,obj.inputs.EMGDisplayChannels{ChannelType2}));
                            end
                            DisplayChannelType=ChannelType;
                            DisplayChannelID=ChannelID;
                            obj.inputs.ChannelsTypeUnique=DisplayChannelType;
                        case 2 % fieldtrip real time buffer
                    end
                    %% Creating Channel Measures, Axes No
                    DisplayChannelsMeasures=cell(1,numel(obj.inputs.EMGDisplayChannels));
                    DisplayChannelsMeasures(:)=cellstr('MEP_Measurement');
                    DisplayChannelsAxesNo=num2cell(1:numel(obj.inputs.EMGDisplayChannels));
                    obj.app.pr.ax_measures=DisplayChannelsMeasures;
                    obj.app.pr.axesno=numel(obj.inputs.EMGDisplayChannels);
                    obj.app.pr.ax_ChannelLabels=obj.inputs.EMGDisplayChannels;
                    obj.inputs.Figures=cell(1,obj.app.pr.axesno);
                    %% Creating Stimulation Conditions
                    for c=1:numel(fieldnames(obj.inputs.condsAll))
                        obj.inputs.condMat{c,obj.inputs.colLabel.trials}=obj.inputs.TrialsPerCondition;
                        obj.inputs.condMat{c,obj.inputs.colLabel.iti}=obj.inputs.ITI;
                        obj.inputs.condMat{c,obj.inputs.colLabel.inputDevices}=char(obj.app.pi.hotspot.InputDevice.String(obj.inputs.InputDevice));
                        obj.inputs.condMat{c,obj.inputs.colLabel.chLab}=obj.inputs.EMGDisplayChannels;
                        obj.inputs.condMat{c,obj.inputs.colLabel.measures}=DisplayChannelsMeasures;
                        obj.inputs.condMat{c,obj.inputs.colLabel.axesno}=DisplayChannelsAxesNo;
                        obj.inputs.condMat{c,obj.inputs.colLabel.chType}=DisplayChannelType;
                        obj.inputs.condMat{c,obj.inputs.colLabel.chId}=DisplayChannelID;
                        conds=fieldnames(obj.inputs.condsAll);
                        for stno=1:(max(size(fieldnames(obj.inputs.condsAll.(conds{c,1}))))-1)
                            st=['st' num2str(stno)];
                            if(obj.inputs.condsAll.(conds{c,1}).(st).stim_mode=='single_pulse')
                                obj.inputs.condsAll.(conds{c,1}).(st).si_pckt{1,2}=0;
                                obj.inputs.condsAll.(conds{c,1}).(st).si_pckt{1,3}=0;
                            end
                            if obj.inputs.condsAll.(conds{c,1}).(st).si_units==1
                                obj.inputs.condsAll.(conds{c,1}).(st).si_pckt{1,4}=obj.inputs.condsAll.(conds{c,1}).(st).si_pckt{1,1};
                            elseif obj.inputs.condsAll.(conds{c,1}).(st).si_units==0 && ~isempty(str2num(obj.inputs.condsAll.(conds{c,1}).(st).threshold)) && str2num(obj.inputs.condsAll.(conds{c,1}).(st).threshold)>0
                                obj.inputs.condsAll.(conds{c,1}).(st).si_pckt{1,4}=round((obj.inputs.condsAll.(conds{c,1}).(st).si_pckt{1,1}*(str2num(obj.inputs.condsAll.(conds{c,1}).(st).threshold)))/100);
                            end
                            condSi{1,stno}=obj.inputs.condsAll.(conds{c,1}).(st).si_pckt;
                            condstimMode{1,stno}= obj.inputs.condsAll.(conds{c,1}).(st).stim_mode;
                            obj.inputs.condsAll.(conds{c,1}).(st).stim_device
                            condoutputDevice{1,stno}=char(obj.inputs.output_device);
                            for i=1:numel(obj.inputs.condsAll.(conds{c,1}).(st).stim_timing)
                                condstimTimingStrings{1,i}=num2str(obj.inputs.condsAll.(conds{c,1}).(st).stim_timing{1,i});
                            end
                            condstimTiming{1,stno}=condstimTimingStrings;
                        end
                        obj.inputs.condMat(c,obj.inputs.colLabel.si)={condSi};
                        obj.inputs.condMat(c,obj.inputs.colLabel.outputDevices)={condoutputDevice};
                        obj.inputs.condMat(c,obj.inputs.colLabel.stimMode)={condstimMode};
                        %                         condstimTiming=condstimTiming{1,1};
                        %                         condstimTiming={{cellfun(@num2str, condstimTiming{1,1}(1,1:end))}};
                        %                                                 condstimTiming={{arrayfun(@num2str, condstimTiming{1,1}(1,1:end))}};
                        
                        %                         condstimTiming=cellstr(condstimTiming);
                        for timing=1:numel(condstimTiming)
                            for jj=1:numel(condstimTiming{1,timing})
                                condstimTiming{2,timing}{1,jj}=condoutputDevice{1,timing};
                            end
                        end
                        condstimTiming_new{1}=horzcat(condstimTiming{1,:});
                        condstimTiming_new{2}=horzcat(condstimTiming{2,:});
                        [condstimTiming_new_sorted{1},sorted_idx]=sort(condstimTiming_new{1});
                        
                        %                                  [condstimTiming_new_sorted{1},sorted_idx]=sort(cellfun(@str2num, condstimTiming_new{1}));
                        %                                  condstimTiming_new_sorted{1}=cellfun(@num2str, num2cell(condstimTiming_new_sorted{1}));
                        
                        
                        
                        condstimTiming_new_sorted{2}=condstimTiming_new{1,2}(sorted_idx);
                        %                                  condstimTiming_new_sorted{1}=cellfun(@num2str, num2cell(condstimTiming_new_sorted{1}));
                        
                        for stimno_tpm=1:numel(condstimTiming_new_sorted{2})
                            port_vector{stimno_tpm}=obj.app.par.hardware_settings.(char(condstimTiming_new_sorted{2}{1,stimno_tpm})).bb_outputport;
                        end
                        condstimTiming_new_sorted{2}=port_vector;
                        tpmVect=[condstimTiming_new_sorted{1};condstimTiming_new_sorted{2}];
                        [tpmVect_unique,ia,ic]=unique(tpmVect(1,:));
                        a_counts = accumarray(ic,1);
                        for binportloop=1:numel(tpmVect_unique)
                            buffer{1,binportloop}={(cell2mat(tpmVect(2,ia(binportloop):ia(binportloop)-1+a_counts(binportloop))))};
                            binaryZ='0000';
                            num=cell2mat(buffer{1,binportloop});
                            for binaryID=1:numel(num)
                                binaryZ(str2num(num(binaryID)))='1';
                            end
                            buffer{1,binportloop}=bin2dec(flip(binaryZ));
                            markers{1,binportloop}=0;
                        end
                        markers{1,1}=c;
                        condstimTiming_new_sorted=[num2cell((cellfun(@str2num, tpmVect_unique(1,1:end))));buffer;markers];
                        condstimTiming_new_sorted=cell2mat(condstimTiming_new_sorted)
                        [condstimTiming_new_sorted(1,:),sorted_idx]=sort(condstimTiming_new_sorted(1,:))
                        condstimTiming_new_sorted(1,:)=condstimTiming_new_sorted(1,:)/1000;
                        condstimTiming_new_sorted(2,:)=condstimTiming_new_sorted(2,sorted_idx)
                        
                        obj.inputs.condMat(c,obj.inputs.colLabel.tpm)={num2cell(condstimTiming_new_sorted)};
                        condSi=[];
                        condoutputDevice=[];
                        condstimMode=[];
                        condstimTiming=[];
                        buffer=[];
                        tpmVect_unique=[];
                        a_counts =[];
                        ia=[];
                        ic=[];
                        port_vector=[];
                        num=[];
                        condstimTiming_new=[];
                        condstimTiming_new_sorted=[];
                        sorted_idx=[];
                        markers=[];
                        condstimTimingStrings=[];
                    end
                case 'MEP Measurement Protocol'
                    switch obj.inputs.BrainState
                        case 1 %Independent
                            %% Adjusting New Arhictecture to Old Architecture
                            obj.inputs.MEPOnset=obj.inputs.MEPSearchWindow(1);
                            obj.inputs.MEPOffset=obj.inputs.MEPSearchWindow(2);
                            obj.inputs.EMGDisplayPeriodPre=obj.inputs.EMGExtractionPeriod(1)*(-1);
                            obj.inputs.EMGDisplayPeriodPost=obj.inputs.EMGExtractionPeriod(2);
                            obj.inputs.prestim_scope_plt=obj.inputs.EMGDisplayPeriodPre;
                            obj.inputs.poststim_scope_plt=obj.inputs.EMGDisplayPeriodPost;
                            obj.inputs.mep_onset=obj.inputs.MEPOnset;
                            obj.inputs.mep_offset=obj.inputs.MEPOffset;
                            obj.inputs.input_device=obj.app.pi.mep.InputDevice.String(obj.inputs.InputDevice); %TODO: the drc or mep on the 4th structure is not a good solution!
                            obj.inputs.output_device=obj.inputs.condsAll.cond1.st1.stim_device;
                            obj.inputs.stim_mode='MSO';
                            obj.inputs.measure_str='MEP Measurement';
                            obj.inputs.ylimMin=obj.inputs.EMGDisplayYLimMin;
                            obj.inputs.ylimMax=obj.inputs.EMGDisplayYLimMax;
                            obj.inputs.stop_event=0;
                            obj.inputs.ylimMin=-3000;
                            obj.inputs.ylimMax=+3000;
                            obj.inputs.TrialNoForMean=1;
                            obj.inputs.mt_starting_stim_inten=obj.inputs.condsAll.cond1.st1.si_pckt{1,1};
                            %% Creating Column Labels
                            obj.inputs.colLabel.inputDevices=1;
                            obj.inputs.colLabel.outputDevices=2;
                            obj.inputs.colLabel.si=3;
                            obj.inputs.colLabel.iti=4;
                            obj.inputs.colLabel.chLab=5;
                            obj.inputs.colLabel.trials=9;
                            obj.inputs.colLabel.axesno=6;
                            obj.inputs.colLabel.measures=7;
                            obj.inputs.colLabel.stimMode=8;
                            obj.inputs.colLabel.tpm=10;
                            obj.inputs.colLabel.chType=11;
                            obj.inputs.colLabel.chId=12;
                            obj.inputs.colLabel.ConditionMarker=13;
                            switch obj.app.par.hardware_settings.(char(obj.inputs.input_device)).slct_device
                                case 1 %boss box
                                    ChannelType=[repmat({'EMG'},1,numel(obj.inputs.EMGDisplayChannels)),{'StatusTable'}]; %dirctly inside the loop
                                    ChannelID=num2cell(1:numel(ChannelType)); %TODO: make this more systematic and extract from channel labels of neurone or acs protocol
                                    obj.inputs.ChannelsTypeUnique=ChannelType;
                                    for ChannelType2=1:numel(obj.inputs.EMGDisplayChannels)
                                        ChannelID{ChannelType2}=find(strcmp(obj.app.par.hardware_settings.(char(obj.inputs.input_device)).NeurOneProtocolChannelLabels,obj.inputs.EMGDisplayChannels{ChannelType2}));
                                    end
                                    DisplayChannelType=ChannelType;
                                    DisplayChannelID=ChannelID;
                                    obj.inputs.ChannelsTypeUnique=DisplayChannelType;
                                case 2 % fieldtrip real time buffer
                            end
                            
                            DisplayChannelsMeasures=cell(1,numel(obj.inputs.EMGDisplayChannels));
                            DisplayChannelsMeasures(:)=cellstr('MEP_Measurement'); DisplayChannelsMeasures(numel(DisplayChannelsMeasures)+1)={'StatusTable'};
                            DisplayChannelsAxesNo=num2cell(1:numel(obj.inputs.EMGDisplayChannels)+1);
                            obj.app.pr.ax_measures=DisplayChannelsMeasures;
                            obj.app.pr.axesno=numel(obj.inputs.EMGDisplayChannels)+1;
                            obj.app.pr.ax_ChannelLabels=[obj.inputs.EMGDisplayChannels {'StatusTable'}] ;
                            %% Creating Stimulation Conditions
                            for c=1:numel(fieldnames(obj.inputs.condsAll))
                                obj.inputs.condMat{c,obj.inputs.colLabel.trials}=obj.inputs.TrialsPerCondition;
                                obj.inputs.condMat{c,obj.inputs.colLabel.iti}=obj.inputs.ITI;
                                obj.inputs.condMat{c,obj.inputs.colLabel.inputDevices}=char(obj.app.pi.mep.InputDevice.String(obj.inputs.InputDevice));
                                obj.inputs.condMat{c,obj.inputs.colLabel.chLab}=[obj.inputs.EMGDisplayChannels,{'StatusTable'}];
                                obj.inputs.condMat{c,obj.inputs.colLabel.measures}=DisplayChannelsMeasures;
                                obj.inputs.condMat{c,obj.inputs.colLabel.axesno}=DisplayChannelsAxesNo;
                                obj.inputs.condMat{c,obj.inputs.colLabel.chType}=DisplayChannelType;
                                obj.inputs.condMat{c,obj.inputs.colLabel.chId}=DisplayChannelID;
                                obj.inputs.condMat{c,obj.inputs.colLabel.ConditionMarker}=c;
                                conds=fieldnames(obj.inputs.condsAll);
                                for stno=1:(max(size(fieldnames(obj.inputs.condsAll.(conds{c,1}))))-1)
                                    st=['st' num2str(stno)];
                                    if(obj.inputs.condsAll.(conds{c,1}).(st).stim_mode=='single_pulse')
                                        obj.inputs.condsAll.(conds{c,1}).(st).si_pckt{1,2}=0;
                                        obj.inputs.condsAll.(conds{c,1}).(st).si_pckt{1,3}=0;
                                    end
                                    if obj.inputs.condsAll.(conds{c,1}).(st).si_units==1
                                        obj.inputs.condsAll.(conds{c,1}).(st).si_pckt{1,4}=obj.inputs.condsAll.(conds{c,1}).(st).si_pckt{1,1};
                                    elseif obj.inputs.condsAll.(conds{c,1}).(st).si_units==0 && ~isempty(str2num(obj.inputs.condsAll.(conds{c,1}).(st).threshold)) && str2num(obj.inputs.condsAll.(conds{c,1}).(st).threshold)>0
                                        obj.inputs.condsAll.(conds{c,1}).(st).si_pckt{1,4}=round((obj.inputs.condsAll.(conds{c,1}).(st).si_pckt{1,1}*(str2num(obj.inputs.condsAll.(conds{c,1}).(st).threshold)))/100);
                                    end
                                    condSi{1,stno}=obj.inputs.condsAll.(conds{c,1}).(st).si_pckt;
                                    condstimMode{1,stno}= obj.inputs.condsAll.(conds{c,1}).(st).stim_mode;
                                    obj.inputs.condsAll.(conds{c,1}).(st).stim_device
                                    condoutputDevice{1,stno}=obj.inputs.condsAll.(conds{c,1}).(st).stim_device;
                                    for i=1:numel(obj.inputs.condsAll.(conds{c,1}).(st).stim_timing)
                                        condstimTimingStrings{1,i}=num2str(obj.inputs.condsAll.(conds{c,1}).(st).stim_timing{1,i});
                                    end
                                    condstimTiming{1,stno}=condstimTimingStrings;
                                end
                                obj.inputs.condMat(c,obj.inputs.colLabel.si)={condSi};
                                obj.inputs.condMat(c,obj.inputs.colLabel.outputDevices)={condoutputDevice};
                                obj.inputs.condMat(c,obj.inputs.colLabel.stimMode)={condstimMode};
                                %                         condstimTiming=condstimTiming{1,1};
                                %                         condstimTiming={{cellfun(@num2str, condstimTiming{1,1}(1,1:end))}};
                                %                                                 condstimTiming={{arrayfun(@num2str, condstimTiming{1,1}(1,1:end))}};
                                
                                %                         condstimTiming=cellstr(condstimTiming);
                                for timing=1:numel(condstimTiming)
                                    for jj=1:numel(condstimTiming{1,timing})
                                        condstimTiming{2,timing}{1,jj}=condoutputDevice{1,timing};
                                    end
                                end
                                condstimTiming_new{1}=horzcat(condstimTiming{1,:});
                                condstimTiming_new{2}=horzcat(condstimTiming{2,:});
                                [condstimTiming_new_sorted{1},sorted_idx]=sort(condstimTiming_new{1});
                                
                                %                                  [condstimTiming_new_sorted{1},sorted_idx]=sort(cellfun(@str2num, condstimTiming_new{1}));
                                %                                  condstimTiming_new_sorted{1}=cellfun(@num2str, num2cell(condstimTiming_new_sorted{1}));
                                
                                
                                
                                condstimTiming_new_sorted{2}=condstimTiming_new{1,2}(sorted_idx);
                                %                                  condstimTiming_new_sorted{1}=cellfun(@num2str, num2cell(condstimTiming_new_sorted{1}));
                                
                                for stimno_tpm=1:numel(condstimTiming_new_sorted{2})
                                    port_vector{stimno_tpm}=obj.app.par.hardware_settings.(char(condstimTiming_new_sorted{2}{1,stimno_tpm})).bb_outputport;
                                end
                                condstimTiming_new_sorted{2}=port_vector;
                                tpmVect=[condstimTiming_new_sorted{1};condstimTiming_new_sorted{2}];
                                [tpmVect_unique,ia,ic]=unique(tpmVect(1,:));
                                a_counts = accumarray(ic,1);
                                for binportloop=1:numel(tpmVect_unique)
                                    buffer{1,binportloop}={(cell2mat(tpmVect(2,ia(binportloop):ia(binportloop)-1+a_counts(binportloop))))};
                                    binaryZ='0000';
                                    num=cell2mat(buffer{1,binportloop});
                                    for binaryID=1:numel(num)
                                        binaryZ(str2num(num(binaryID)))='1';
                                    end
                                    buffer{1,binportloop}=bin2dec(flip(binaryZ));
                                    markers{1,binportloop}=0;
                                end
                                markers{1,1}=c;
                                condstimTiming_new_sorted=[num2cell((cellfun(@str2num, tpmVect_unique(1,1:end))));buffer;markers];
                                condstimTiming_new_sorted=cell2mat(condstimTiming_new_sorted)
                                [condstimTiming_new_sorted(1,:),sorted_idx]=sort(condstimTiming_new_sorted(1,:))
                                condstimTiming_new_sorted(1,:)=condstimTiming_new_sorted(1,:)/1000;
                                condstimTiming_new_sorted(2,:)=condstimTiming_new_sorted(2,sorted_idx)
                                
                                obj.inputs.condMat(c,obj.inputs.colLabel.tpm)={num2cell(condstimTiming_new_sorted)};
                                condSi=[];
                                condoutputDevice=[];
                                condstimMode=[];
                                condstimTiming=[];
                                buffer=[];
                                tpmVect_unique=[];
                                a_counts =[];
                                ia=[];
                                ic=[];
                                port_vector=[];
                                num=[];
                                condstimTiming_new=[];
                                condstimTiming_new_sorted=[];
                                sorted_idx=[];
                                markers=[];
                                condstimTimingStrings=[];
                            end
                        case 2 %Dependent
                            %% Adjusting New Arhictecture to Old Architecture
                            obj.inputs.MEPOnset=obj.inputs.MEPSearchWindow(1);
                            obj.inputs.MEPOffset=obj.inputs.MEPSearchWindow(2);
                            obj.inputs.EMGDisplayPeriodPre=obj.inputs.EMGExtractionPeriod(1)*(-1);
                            obj.inputs.EMGDisplayPeriodPost=obj.inputs.EMGExtractionPeriod(2);
                            obj.inputs.EEGDisplayPeriodPre=obj.inputs.EEGExtractionPeriod(1)*(-1);
                            obj.inputs.EEGDisplayPeriodPost=obj.inputs.EEGExtractionPeriod(2);
                            obj.inputs.MontageChannels=obj.inputs.RealTimeChannelsMontage;
                            obj.inputs.MontageWeights=obj.inputs.RealTimeChannelsWeights;
                            obj.inputs.prestim_scope_plt=obj.inputs.EMGDisplayPeriodPre;
                            obj.inputs.poststim_scope_plt=obj.inputs.EMGDisplayPeriodPost;
                            obj.inputs.mep_onset=obj.inputs.MEPOnset;
                            obj.inputs.mep_offset=obj.inputs.MEPOffset;
                            obj.inputs.input_device=obj.app.pi.mep.InputDevice.String(obj.inputs.InputDevice); %TODO: the drc or mep on the 4th structure is not a good solution!
                            obj.inputs.output_device=obj.inputs.condsAll.cond1.st1.stim_device;
                            obj.inputs.stim_mode='MSO';
                            obj.inputs.measure_str='MEP Measurement';
                            obj.inputs.ylimMin=obj.inputs.EMGDisplayYLimMin;
                            obj.inputs.ylimMax=obj.inputs.EMGDisplayYLimMax;
                            obj.inputs.stop_event=0;
                            obj.inputs.ylimMin=-3000;
                            obj.inputs.ylimMax=+3000;
                            obj.inputs.TrialNoForMean=1;
                            obj.inputs.mt_starting_stim_inten=obj.inputs.condsAll.cond1.st1.si_pckt{1,1};
                            %% Creating Column Labels
                            obj.inputs.colLabel.inputDevices=1;
                            obj.inputs.colLabel.outputDevices=2;
                            obj.inputs.colLabel.si=3;
                            obj.inputs.colLabel.iti=4;
                            obj.inputs.colLabel.chLab=5;
                            obj.inputs.colLabel.trials=9;
                            obj.inputs.colLabel.axesno=6;
                            obj.inputs.colLabel.measures=7;
                            obj.inputs.colLabel.stimMode=8;
                            obj.inputs.colLabel.tpm=10;
                            obj.inputs.colLabel.chType=11;
                            obj.inputs.colLabel.chId=12;
                            obj.inputs.colLabel.phase=13;
                            obj.inputs.colLabel.IA=14;
                            if obj.inputs.AmplitudeUnits==1
                                obj.inputs.colLabel.IAPercentile=15;
                            end
                            %% Creating ChannelType and ChannelID
                            switch obj.app.par.hardware_settings.(char(obj.inputs.input_device)).slct_device
                                case 1 %boss box
                                    ChannelType=[{'IP'},{'IEEG'},repmat({'EMG'},1,numel(obj.inputs.EMGDisplayChannels)),{'IA'},{'IADistribution'},{'StatusTable'}];
                                    ChannelID=num2cell(1:numel(ChannelType));
                                    for ChannelType2=1:numel(obj.inputs.EMGDisplayChannels)
                                        ChannelID{2+ChannelType2}=find(strcmp(obj.app.par.hardware_settings.(char(obj.inputs.input_device)).NeurOneProtocolChannelLabels,obj.inputs.EMGDisplayChannels{ChannelType2}));
                                    end
                                    DisplayChannelType=ChannelType;
                                    DisplayChannelID=ChannelID;
                                    obj.inputs.ChannelsTypeUnique=ChannelType;
                                case 2 % fieldtrip real time buffer
                                    errordlg('Brain State Dependent Protocol are only supported with sync2brain BOSS Device.','BEST Toolbox');
                            end
                            %% Creating DisplayChannels Measures, AxesNo, Channel Labels Buffers
                            DisplayChannelsMeasures=cell(1,numel(obj.inputs.EMGDisplayChannels));
                            DisplayChannelsMeasures(:)=cellstr('MEP_Measurement');
                            
                            ChannelLabels={'OsscillationPhase','OsscillationEEG',obj.inputs.EMGDisplayChannels{1,:},'OsscillationAmplitude','AmplitudeDistribution','StatusTable'};
                            ChannelMeasures={'PhaseHistogram','TriggerLockedEEG',DisplayChannelsMeasures{1,:},'RunningAmplitude','AmplitudeDistribution','StatusTable'};
                            
                            DisplayChannelsAxesNo=num2cell(1:numel(ChannelMeasures));
                            obj.app.pr.ax_measures=ChannelMeasures;
                            obj.app.pr.axesno=numel(ChannelMeasures);
                            obj.app.pr.ax_ChannelLabels=ChannelLabels;
                            %% Creating Stimulation Conditons
                            for c=1:numel(fieldnames(obj.inputs.condsAll))
                                obj.inputs.condMat{c,obj.inputs.colLabel.trials}=obj.inputs.TrialsPerCondition;
                                obj.inputs.condMat{c,obj.inputs.colLabel.iti}=obj.inputs.ITI;
                                obj.inputs.condMat{c,obj.inputs.colLabel.inputDevices}=char(obj.app.pi.mep.InputDevice.String(obj.inputs.InputDevice));
                                obj.inputs.condMat{c,obj.inputs.colLabel.chLab}=ChannelLabels;
                                obj.inputs.condMat{c,obj.inputs.colLabel.measures}=ChannelMeasures;
                                obj.inputs.condMat{c,obj.inputs.colLabel.axesno}=DisplayChannelsAxesNo;
                                obj.inputs.condMat{c,obj.inputs.colLabel.chType}=DisplayChannelType;
                                obj.inputs.condMat{c,obj.inputs.colLabel.chId}=DisplayChannelID;
                                
                                
                                conds=fieldnames(obj.inputs.condsAll);
                                for stno=1:(max(size(fieldnames(obj.inputs.condsAll.(conds{c,1}))))-1)
                                    st=['st' num2str(stno)];
                                    if(obj.inputs.condsAll.(conds{c,1}).(st).stim_mode=='single_pulse')
                                        obj.inputs.condsAll.(conds{c,1}).(st).si_pckt{1,2}=0;
                                        obj.inputs.condsAll.(conds{c,1}).(st).si_pckt{1,3}=0;
                                    end
                                    if obj.inputs.condsAll.(conds{c,1}).(st).si_units==1
                                        obj.inputs.condsAll.(conds{c,1}).(st).si_pckt{1,4}=obj.inputs.condsAll.(conds{c,1}).(st).si_pckt{1,1};
                                    elseif obj.inputs.condsAll.(conds{c,1}).(st).si_units==0 && ~isempty(str2num(obj.inputs.condsAll.(conds{c,1}).(st).threshold)) && str2num(obj.inputs.condsAll.(conds{c,1}).(st).threshold)>0
                                        obj.inputs.condsAll.(conds{c,1}).(st).si_pckt{1,4}=round((obj.inputs.condsAll.(conds{c,1}).(st).si_pckt{1,1}*(str2num(obj.inputs.condsAll.(conds{c,1}).(st).threshold)))/100);
                                    end
                                    condSi{1,stno}=obj.inputs.condsAll.(conds{c,1}).(st).si_pckt;
                                    condstimMode{1,stno}= obj.inputs.condsAll.(conds{c,1}).(st).stim_mode;
                                    obj.inputs.condsAll.(conds{c,1}).(st).stim_device
                                    condoutputDevice{1,stno}=obj.inputs.condsAll.(conds{c,1}).(st).stim_device;
                                    for i=1:numel(obj.inputs.condsAll.(conds{c,1}).(st).stim_timing)
                                        condstimTimingStrings{1,i}=num2str(obj.inputs.condsAll.(conds{c,1}).(st).stim_timing{1,i});
                                    end
                                    condstimTiming{1,stno}=condstimTimingStrings;
                                end
                                obj.inputs.condMat(c,obj.inputs.colLabel.si)={condSi};
                                obj.inputs.condMat(c,obj.inputs.colLabel.outputDevices)={condoutputDevice};
                                obj.inputs.condMat(c,obj.inputs.colLabel.stimMode)={condstimMode};
                                %                         condstimTiming=condstimTiming{1,1};
                                %                         condstimTiming={{cellfun(@num2str, condstimTiming{1,1}(1,1:end))}};
                                %                                                 condstimTiming={{arrayfun(@num2str, condstimTiming{1,1}(1,1:end))}};
                                
                                %                         condstimTiming=cellstr(condstimTiming);
                                for timing=1:numel(condstimTiming)
                                    for jj=1:numel(condstimTiming{1,timing})
                                        condstimTiming{2,timing}{1,jj}=condoutputDevice{1,timing};
                                    end
                                end
                                condstimTiming_new{1}=horzcat(condstimTiming{1,:});
                                condstimTiming_new{2}=horzcat(condstimTiming{2,:});
                                [condstimTiming_new_sorted{1},sorted_idx]=sort(condstimTiming_new{1});
                                
                                %                                  [condstimTiming_new_sorted{1},sorted_idx]=sort(cellfun(@str2num, condstimTiming_new{1}));
                                %                                  condstimTiming_new_sorted{1}=cellfun(@num2str, num2cell(condstimTiming_new_sorted{1}));
                                
                                
                                
                                condstimTiming_new_sorted{2}=condstimTiming_new{1,2}(sorted_idx);
                                %                                  condstimTiming_new_sorted{1}=cellfun(@num2str, num2cell(condstimTiming_new_sorted{1}));
                                
                                for stimno_tpm=1:numel(condstimTiming_new_sorted{2})
                                    port_vector{stimno_tpm}=obj.app.par.hardware_settings.(char(condstimTiming_new_sorted{2}{1,stimno_tpm})).bb_outputport;
                                end
                                condstimTiming_new_sorted{2}=port_vector;
                                tpmVect=[condstimTiming_new_sorted{1};condstimTiming_new_sorted{2}];
                                [tpmVect_unique,ia,ic]=unique(tpmVect(1,:));
                                a_counts = accumarray(ic,1);
                                for binportloop=1:numel(tpmVect_unique)
                                    buffer{1,binportloop}={(cell2mat(tpmVect(2,ia(binportloop):ia(binportloop)-1+a_counts(binportloop))))};
                                    binaryZ='0000';
                                    num=cell2mat(buffer{1,binportloop});
                                    for binaryID=1:numel(num)
                                        binaryZ(str2num(num(binaryID)))='1';
                                    end
                                    buffer{1,binportloop}=bin2dec(flip(binaryZ));
                                    markers{1,binportloop}=0;
                                end
                                markers{1,1}=c;
                                condstimTiming_new_sorted=[num2cell((cellfun(@str2num, tpmVect_unique(1,1:end))));buffer;markers];
                                condstimTiming_new_sorted=cell2mat(condstimTiming_new_sorted)
                                [condstimTiming_new_sorted(1,:),sorted_idx]=sort(condstimTiming_new_sorted(1,:))
                                condstimTiming_new_sorted(1,:)=condstimTiming_new_sorted(1,:)/1000;
                                condstimTiming_new_sorted(2,:)=condstimTiming_new_sorted(2,sorted_idx)
                                
                                obj.inputs.condMat(c,obj.inputs.colLabel.tpm)={num2cell(condstimTiming_new_sorted)};
                                condSi=[];
                                condoutputDevice=[];
                                condstimMode=[];
                                condstimTiming=[];
                                buffer=[];
                                tpmVect_unique=[];
                                a_counts =[];
                                ia=[];
                                ic=[];
                                port_vector=[];
                                num=[];
                                condstimTiming_new=[];
                                condstimTiming_new_sorted=[];
                                sorted_idx=[];
                                markers=[];
                                condstimTimingStrings=[];
                            end
                            %% Creating Phase Conditions
                            PhaseConditionVector=cell(1,numel(obj.inputs.Phase));
                            for iPhases=1:numel(obj.inputs.Phase)
                                switch obj.inputs.Phase(iPhases)
                                    case 0 %+Ve Peak
                                        PhaseConditionVector{iPhases}={0,obj.inputs.PhaseTolerance};
                                    case pi %-Ve Trough
                                        PhaseConditionVector{iPhases}={pi,obj.inputs.PhaseTolerance};
                                    case -pi/2 %Rising Flank
                                        PhaseConditionVector{iPhases}={-pi/2,obj.inputs.PhaseTolerance};
                                    case pi/2 %Falling Flank
                                        PhaseConditionVector{iPhases}={pi/2,obj.inputs.PhaseTolerance};
                                    otherwise % NaN Value and Random Phase
                                        PhaseConditionVector{iPhases}={0,pi};
                                end
                            end
                            %% Crossing Phase and Amplitude Conditions with Stimulation Conditions
                            idx_stimulationconditions=0;
                            idx_totalstimulationconditions=numel(obj.inputs.condMat(:,1));
                            if numel(obj.inputs.AmplitudeThreshold)/2==numel(obj.inputs.Phase) || numel(obj.inputs.AmplitudeThreshold)/2==1
                                idx_phaseconditions=1;
                                TotalCrossedOverConditions=(numel(obj.inputs.Phase))*(numel(obj.inputs.condMat(:,1)));
                                for iTotalCrossedOverConditions=1:TotalCrossedOverConditions
                                    idx_stimulationconditions=idx_stimulationconditions+1;
                                    obj.inputs.condMat(iTotalCrossedOverConditions,1:12)=obj.inputs.condMat(idx_stimulationconditions,1:12);
                                    obj.inputs.condMat(iTotalCrossedOverConditions,obj.inputs.colLabel.phase)=PhaseConditionVector(idx_phaseconditions);
                                    if numel(obj.inputs.AmplitudeThreshold)/2==numel(obj.inputs.Phase)
                                        obj.inputs.condMat(iTotalCrossedOverConditions,obj.inputs.colLabel.IA)={{obj.inputs.AmplitudeThreshold(idx_phaseconditions,1),obj.inputs.AmplitudeThreshold(idx_phaseconditions,2)}};
                                        if obj.inputs.AmplitudeUnits==1
                                            obj.inputs.condMat(iTotalCrossedOverConditions,obj.inputs.colLabel.IAPercentile)={{obj.inputs.AmplitudeThreshold(idx_phaseconditions,1),obj.inputs.AmplitudeThreshold(idx_phaseconditions,2)}}; end
                                    elseif numel(obj.inputs.AmplitudeThreshold)/2==1
                                        obj.inputs.condMat(iTotalCrossedOverConditions,obj.inputs.colLabel.IA)={{obj.inputs.AmplitudeThreshold(1,1),obj.inputs.AmplitudeThreshold(1,2)}};
                                        if obj.inputs.AmplitudeUnits==1
                                            obj.inputs.condMat(iTotalCrossedOverConditions,obj.inputs.colLabel.IAPercentile)={{obj.inputs.AmplitudeThreshold(1,1),obj.inputs.AmplitudeThreshold(1,2)}}; end
                                    end
                                    if(idx_stimulationconditions>=idx_totalstimulationconditions)
                                        idx_stimulationconditions=0;
                                        idx_phaseconditions=idx_phaseconditions+1;
                                        if(idx_phaseconditions>numel(PhaseConditionVector))
                                            idx_phaseconditions=1; end
                                    end
                                end
                            elseif numel(obj.inputs.AmplitudeThreshold)/2>numel(obj.inputs.Phase) && numel(obj.inputs.Phase)==1
                                idx_amplitudeconditions=1;
                                TotalCrossedOverConditions=(numel(obj.inputs.AmplitudeThreshold)/2)*(numel(obj.inputs.condMat(:,1)));
                                for iTotalCrossedOverConditions=1:TotalCrossedOverConditions
                                    idx_stimulationconditions=idx_stimulationconditions+1;
                                    obj.inputs.condMat(iTotalCrossedOverConditions,1:12)=obj.inputs.condMat(idx_stimulationconditions,1:12);
                                    obj.inputs.condMat(iTotalCrossedOverConditions,obj.inputs.colLabel.IA)={{obj.inputs.AmplitudeThreshold(idx_amplitudeconditions,1),obj.inputs.AmplitudeThreshold(idx_amplitudeconditions,2)}};
                                    obj.inputs.condMat(iTotalCrossedOverConditions,obj.inputs.colLabel.phase)=PhaseConditionVector(1);
                                    if obj.inputs.AmplitudeUnits==1
                                        obj.inputs.condMat(iTotalCrossedOverConditions,obj.inputs.colLabel.IAPercentile)={{obj.inputs.AmplitudeThreshold(idx_amplitudeconditions,1),obj.inputs.AmplitudeThreshold(idx_amplitudeconditions,2)}}; end
                                    if(idx_stimulationconditions>=idx_totalstimulationconditions)
                                        idx_stimulationconditions=0;
                                        idx_amplitudeconditions=idx_amplitudeconditions+1;
                                        if(idx_amplitudeconditions>numel(obj.inputs.AmplitudeThreshold)/2)
                                            idx_amplitudeconditions=1; end
                                    end
                                end
                            end
                    end
                case 'MEP Dose Response Curve Protocol'
                    switch obj.inputs.BrainState
                        case 1 %Independent
                            %% Adjusting New Arhictecture to Old Architecture
                            obj.inputs.MEPOnset=obj.inputs.MEPSearchWindow(1);
                            obj.inputs.MEPOffset=obj.inputs.MEPSearchWindow(2);
                            obj.inputs.EMGDisplayPeriodPre=obj.inputs.EMGExtractionPeriod(1)*(-1);
                            obj.inputs.EMGDisplayPeriodPost=obj.inputs.EMGExtractionPeriod(2);
                            obj.inputs.prestim_scope_plt=obj.inputs.EMGDisplayPeriodPre;
                            obj.inputs.poststim_scope_plt=obj.inputs.EMGDisplayPeriodPost;
                            obj.inputs.mep_onset=obj.inputs.MEPOnset;
                            obj.inputs.mep_offset=obj.inputs.MEPOffset;
                            obj.inputs.input_device=obj.app.pi.drc.InputDevice.String(obj.inputs.InputDevice); %TODO: the drc or mep on the 4th structure is not a good solution!
                            obj.inputs.output_device=obj.inputs.condsAll.cond1.st1.stim_device;
                            obj.inputs.stim_mode='MSO';
                            obj.inputs.measure_str='MEP Measurement';
                            obj.inputs.ylimMin=obj.inputs.EMGDisplayYLimMin;
                            obj.inputs.ylimMax=obj.inputs.EMGDisplayYLimMax;
                            obj.inputs.stop_event=0;
                            obj.inputs.ylimMin=-3000;
                            obj.inputs.ylimMax=+3000;
                            obj.inputs.TrialNoForMean=1;
                            obj.inputs.mt_starting_stim_inten=obj.inputs.condsAll.cond1.st1.si_pckt{1,1};
                            obj.inputs.TSOnlyMean=NaN;
                            %% Creating Column Labels
                            obj.inputs.colLabel.inputDevices=1;
                            obj.inputs.colLabel.outputDevices=2;
                            obj.inputs.colLabel.si=3;
                            obj.inputs.colLabel.iti=4;
                            obj.inputs.colLabel.chLab=5;
                            obj.inputs.colLabel.trials=9;
                            obj.inputs.colLabel.axesno=6;
                            obj.inputs.colLabel.measures=7;
                            obj.inputs.colLabel.stimMode=8;
                            obj.inputs.colLabel.tpm=10;
                            obj.inputs.colLabel.chType=11;
                            obj.inputs.colLabel.chId=12;
                            obj.inputs.colLabel.stimcdMrk=13;
                            obj.inputs.colLabel.cdMrk=14;
                            %% Creating Channel Measures, AxesNo, Labels
                            ChannelLabels=[repelem(obj.inputs.EMGTargetChannels,3),obj.inputs.EMGDisplayChannels,{'StatusTable'}]; %this can go directly inside the cond object in the loop
                            ChannelMeasures=[repmat({'MEP_Measurement','MEP Scatter Plot','MEP IOC Fit'},1,numel(obj.inputs.EMGTargetChannels)),repmat({'MEP_Measurement'},1,numel(obj.inputs.EMGDisplayChannels)),{'StatusTable'}]; %dirctly inside the loop
                            ChannelAxesNo=num2cell(1:numel(ChannelLabels));
                            obj.app.pr.ax_measures=ChannelMeasures;
                            obj.app.pr.axesno=numel(ChannelAxesNo);
                            obj.app.pr.ax_ChannelLabels=ChannelLabels;
                            %% Creating Channel Type, Channel Index
                            switch obj.app.par.hardware_settings.(char(obj.inputs.input_device)).slct_device
                                case 1 %boss box
                                    ChannelType=[repmat({'EMG'},1,3*numel(obj.inputs.EMGTargetChannels)),repmat({'EMG'},1,numel(obj.inputs.EMGDisplayChannels)),{'StatusTable'}]; %dirctly inside the loop
                                    ChannelID=num2cell(1:numel(ChannelType)); %TODO: make this more systematic and extract from channel labels of neurone or acs protocol
                                    for ChannelType1=1:numel(obj.inputs.EMGTargetChannels)
                                        ChannelID{3*ChannelType1-2}=find(strcmp(obj.app.par.hardware_settings.(char(obj.inputs.input_device)).NeurOneProtocolChannelLabels,obj.inputs.EMGTargetChannels{ChannelType1}));
                                    end
                                    for ChannelType2=1:numel(obj.inputs.EMGDisplayChannels)
                                        ChannelID{numel(obj.inputs.EMGTargetChannels)+ChannelType2}=find(strcmp(obj.app.par.hardware_settings.(char(obj.inputs.input_device)).NeurOneProtocolChannelLabels,obj.inputs.EMGDisplayChannels{ChannelType2}));
                                    end
                                    obj.inputs.ChannelsTypeUnique=ChannelType;
                                case 2 % fieldtrip real time buffer
                            end
                            %% Creating Stimulation Conditions
                            for c=1:numel(fieldnames(obj.inputs.condsAll))
                                obj.inputs.condMat{c,obj.inputs.colLabel.trials}=obj.inputs.TrialsPerCondition;
                                obj.inputs.condMat{c,obj.inputs.colLabel.iti}=obj.inputs.ITI;
                                obj.inputs.condMat{c,obj.inputs.colLabel.inputDevices}=char(obj.app.pi.drc.InputDevice.String(obj.inputs.InputDevice));
                                obj.inputs.condMat{c,obj.inputs.colLabel.chLab}=ChannelLabels;
                                obj.inputs.condMat{c,obj.inputs.colLabel.measures}=ChannelMeasures;
                                obj.inputs.condMat{c,obj.inputs.colLabel.axesno}=ChannelAxesNo;
                                obj.inputs.condMat{c,obj.inputs.colLabel.chType}=ChannelType;
                                obj.inputs.condMat{c,obj.inputs.colLabel.chId}=ChannelID;
                                obj.inputs.condMat{c,obj.inputs.colLabel.stimcdMrk}=c;
                                conds=fieldnames(obj.inputs.condsAll);
                                for stno=1:(max(size(fieldnames(obj.inputs.condsAll.(conds{c,1}))))-1)
                                    st=['st' num2str(stno)];
                                    if(obj.inputs.condsAll.(conds{c,1}).(st).stim_mode=='single_pulse')
                                        obj.inputs.condsAll.(conds{c,1}).(st).si_pckt{1,2}=0;
                                        obj.inputs.condsAll.(conds{c,1}).(st).si_pckt{1,3}=0;
                                    end
                                    if obj.inputs.condsAll.(conds{c,1}).(st).si_units==1
                                        obj.inputs.condsAll.(conds{c,1}).(st).si_pckt{1,4}=obj.inputs.condsAll.(conds{c,1}).(st).si_pckt{1,1};
                                    elseif obj.inputs.condsAll.(conds{c,1}).(st).si_units==0 && ~isempty(str2num(obj.inputs.condsAll.(conds{c,1}).(st).threshold)) && str2num(obj.inputs.condsAll.(conds{c,1}).(st).threshold)>0
                                        obj.inputs.condsAll.(conds{c,1}).(st).si_pckt{1,4}=round((obj.inputs.condsAll.(conds{c,1}).(st).si_pckt{1,1}*(str2num(obj.inputs.condsAll.(conds{c,1}).(st).threshold)))/100);
                                    end
                                    condSi{1,stno}=obj.inputs.condsAll.(conds{c,1}).(st).si_pckt;
                                    condstimMode{1,stno}= obj.inputs.condsAll.(conds{c,1}).(st).stim_mode;
                                    obj.inputs.condsAll.(conds{c,1}).(st).stim_device
                                    condoutputDevice{1,stno}=obj.inputs.condsAll.(conds{c,1}).(st).stim_device;
                                    for i=1:numel(obj.inputs.condsAll.(conds{c,1}).(st).stim_timing)
                                        condstimTimingStrings{1,i}=num2str(obj.inputs.condsAll.(conds{c,1}).(st).stim_timing{1,i});
                                    end
                                    condstimTiming{1,stno}=condstimTimingStrings;
                                end
                                obj.inputs.condMat(c,obj.inputs.colLabel.si)={condSi};
                                obj.inputs.condMat(c,obj.inputs.colLabel.outputDevices)={condoutputDevice};
                                obj.inputs.condMat(c,obj.inputs.colLabel.stimMode)={condstimMode};
                                %                         condstimTiming=condstimTiming{1,1};
                                %                         condstimTiming={{cellfun(@num2str, condstimTiming{1,1}(1,1:end))}};
                                %                                                 condstimTiming={{arrayfun(@num2str, condstimTiming{1,1}(1,1:end))}};
                                
                                %                         condstimTiming=cellstr(condstimTiming);
                                for timing=1:numel(condstimTiming)
                                    for jj=1:numel(condstimTiming{1,timing})
                                        condstimTiming{2,timing}{1,jj}=condoutputDevice{1,timing};
                                    end
                                end
                                condstimTiming_new{1}=horzcat(condstimTiming{1,:});
                                condstimTiming_new{2}=horzcat(condstimTiming{2,:});
                                [condstimTiming_new_sorted{1},sorted_idx]=sort(condstimTiming_new{1});
                                
                                %                                  [condstimTiming_new_sorted{1},sorted_idx]=sort(cellfun(@str2num, condstimTiming_new{1}));
                                %                                  condstimTiming_new_sorted{1}=cellfun(@num2str, num2cell(condstimTiming_new_sorted{1}));
                                
                                
                                
                                condstimTiming_new_sorted{2}=condstimTiming_new{1,2}(sorted_idx);
                                %                                  condstimTiming_new_sorted{1}=cellfun(@num2str, num2cell(condstimTiming_new_sorted{1}));
                                
                                for stimno_tpm=1:numel(condstimTiming_new_sorted{2})
                                    port_vector{stimno_tpm}=obj.app.par.hardware_settings.(char(condstimTiming_new_sorted{2}{1,stimno_tpm})).bb_outputport;
                                end
                                condstimTiming_new_sorted{2}=port_vector;
                                tpmVect=[condstimTiming_new_sorted{1};condstimTiming_new_sorted{2}];
                                [tpmVect_unique,ia,ic]=unique(tpmVect(1,:));
                                a_counts = accumarray(ic,1);
                                for binportloop=1:numel(tpmVect_unique)
                                    buffer{1,binportloop}={(cell2mat(tpmVect(2,ia(binportloop):ia(binportloop)-1+a_counts(binportloop))))};
                                    binaryZ='0000';
                                    num=cell2mat(buffer{1,binportloop});
                                    for binaryID=1:numel(num)
                                        binaryZ(str2num(num(binaryID)))='1';
                                    end
                                    buffer{1,binportloop}=bin2dec(flip(binaryZ));
                                    markers{1,binportloop}=0;
                                end
                                markers{1,1}=c;
                                condstimTiming_new_sorted=[num2cell((cellfun(@str2num, tpmVect_unique(1,1:end))));buffer;markers];
                                condstimTiming_new_sorted=cell2mat(condstimTiming_new_sorted)
                                [condstimTiming_new_sorted(1,:),sorted_idx]=sort(condstimTiming_new_sorted(1,:))
                                condstimTiming_new_sorted(1,:)=condstimTiming_new_sorted(1,:)/1000;
                                condstimTiming_new_sorted(2,:)=condstimTiming_new_sorted(2,sorted_idx)
                                
                                obj.inputs.condMat(c,obj.inputs.colLabel.tpm)={num2cell(condstimTiming_new_sorted)};
                                condSi=[];
                                condoutputDevice=[];
                                condstimMode=[];
                                condstimTiming=[];
                                buffer=[];
                                tpmVect_unique=[];
                                a_counts =[];
                                ia=[];
                                ic=[];
                                port_vector=[];
                                num=[];
                                condstimTiming_new=[];
                                condstimTiming_new_sorted=[];
                                sorted_idx=[];
                                markers=[];
                                condstimTimingStrings=[];
                            end
                        case 2 %Dependent
                            %% Adjusting New Arhictecture to Old Architecture
                            obj.inputs.MEPOnset=obj.inputs.MEPSearchWindow(1);
                            obj.inputs.MEPOffset=obj.inputs.MEPSearchWindow(2);
                            obj.inputs.EMGDisplayPeriodPre=obj.inputs.EMGExtractionPeriod(1)*(-1);
                            obj.inputs.EMGDisplayPeriodPost=obj.inputs.EMGExtractionPeriod(2);
                            obj.inputs.EEGDisplayPeriodPre=obj.inputs.EEGExtractionPeriod(1)*(-1);
                            obj.inputs.EEGDisplayPeriodPost=obj.inputs.EEGExtractionPeriod(2);
                            obj.inputs.MontageChannels=obj.inputs.RealTimeChannelsMontage;
                            obj.inputs.MontageWeights=obj.inputs.RealTimeChannelsWeights;
                            obj.inputs.prestim_scope_plt=obj.inputs.EMGDisplayPeriodPre;
                            obj.inputs.poststim_scope_plt=obj.inputs.EMGDisplayPeriodPost;
                            obj.inputs.mep_onset=obj.inputs.MEPOnset;
                            obj.inputs.mep_offset=obj.inputs.MEPOffset;
                            obj.inputs.input_device=obj.app.pi.drc.InputDevice.String(obj.inputs.InputDevice); %TODO: the drc or mep on the 4th structure is not a good solution!
                            obj.inputs.output_device=obj.inputs.condsAll.cond1.st1.stim_device;
                            obj.inputs.stim_mode='MSO';
                            obj.inputs.measure_str='MEP Measurement';
                            obj.inputs.ylimMin=obj.inputs.EMGDisplayYLimMin;
                            obj.inputs.ylimMax=obj.inputs.EMGDisplayYLimMax;
                            obj.inputs.stop_event=0;
                            obj.inputs.ylimMin=-3000;
                            obj.inputs.ylimMax=+3000;
                            obj.inputs.TrialNoForMean=1;
                            obj.inputs.mt_starting_stim_inten=obj.inputs.condsAll.cond1.st1.si_pckt{1,1};
                            obj.inputs.TSOnlyMean=NaN;
                            %% Creating Column Labels
                            obj.inputs.colLabel.inputDevices=1;
                            obj.inputs.colLabel.outputDevices=2;
                            obj.inputs.colLabel.si=3;
                            obj.inputs.colLabel.iti=4;
                            obj.inputs.colLabel.chLab=5;
                            obj.inputs.colLabel.trials=9;
                            obj.inputs.colLabel.axesno=6;
                            obj.inputs.colLabel.measures=7;
                            obj.inputs.colLabel.stimMode=8;
                            obj.inputs.colLabel.tpm=10;
                            obj.inputs.colLabel.chType=11;
                            obj.inputs.colLabel.chId=12;
                            obj.inputs.colLabel.phase=15;
                            obj.inputs.colLabel.IA=16;
                            obj.inputs.colLabel.stimcdMrk=13;
                            obj.inputs.colLabel.cdMrk=14;
                            if obj.inputs.AmplitudeUnits==1
                                obj.inputs.colLabel.IAPercentile=17;
                            end
                            %% Creating Channel Measures, AxesNo, Labels
                            ChannelLabels=[{'OsscillationPhase'},{'OsscillationEEG'},repelem(obj.inputs.EMGTargetChannels,3),obj.inputs.EMGDisplayChannels,{'OsscillationAmplitude'},{'AmplitudeDistribution'},{'StatusTable'}]; %[repelem(obj.inputs.EMGTargetChannels,3),obj.inputs.EMGDisplayChannels];
                            ChannelMeasures=[{'PhaseHistogram'},{'TriggerLockedEEG'},repmat({'MEP_Measurement','MEP Scatter Plot','MEP IOC Fit'},1,numel(obj.inputs.EMGTargetChannels)),repmat({'MEP_Measurement'},1,numel(obj.inputs.EMGDisplayChannels)),{'RunningAmplitude'},{'AmplitudeDistribution'},{'StatusTable'}];
                            ChannelAxesNo=num2cell(1:numel(ChannelLabels));
                            obj.app.pr.ax_measures=ChannelMeasures;
                            obj.app.pr.axesno=numel(ChannelAxesNo);
                            obj.app.pr.ax_ChannelLabels=ChannelLabels;
                            %% Creating Channel Type, Channel Index
                            switch obj.app.par.hardware_settings.(char(obj.inputs.input_device)).slct_device
                                case 1 %boss box
                                    ChannelType=[{'IP'},{'IEEG'},repmat({'EMG'},1,3*numel(obj.inputs.EMGTargetChannels)),repmat({'EMG'},1,numel(obj.inputs.EMGDisplayChannels)),{'IA'},{'IADistribution'},{'StatusTable'}];
                                    ChannelID=num2cell(1:numel(ChannelType));
                                    for ChannelType1=1:numel(obj.inputs.EMGTargetChannels)
                                        ChannelID{2+(3*ChannelType1-2)}=find(strcmp(obj.app.par.hardware_settings.(char(obj.inputs.input_device)).NeurOneProtocolChannelLabels,obj.inputs.EMGTargetChannels{ChannelType1}));
                                    end
                                    for ChannelType2=1:numel(obj.inputs.EMGDisplayChannels)
                                        ChannelID{2+(3*numel(obj.inputs.EMGTargetChannels))+ChannelType2}=find(strcmp(obj.app.par.hardware_settings.(char(obj.inputs.input_device)).NeurOneProtocolChannelLabels,obj.inputs.EMGDisplayChannels{ChannelType2}));
                                    end
                                    obj.inputs.ChannelsTypeUnique=ChannelType;
                                case 2 % fieldtrip real time buffer
                            end
                            %% Creating Stimulation Conditions
                            for c=1:numel(fieldnames(obj.inputs.condsAll))
                                obj.inputs.condMat{c,obj.inputs.colLabel.trials}=obj.inputs.TrialsPerCondition;
                                obj.inputs.condMat{c,obj.inputs.colLabel.iti}=obj.inputs.ITI;
                                obj.inputs.condMat{c,obj.inputs.colLabel.inputDevices}=char(obj.app.pi.drc.InputDevice.String(obj.inputs.InputDevice));
                                obj.inputs.condMat{c,obj.inputs.colLabel.chLab}=ChannelLabels;
                                obj.inputs.condMat{c,obj.inputs.colLabel.measures}=ChannelMeasures;
                                obj.inputs.condMat{c,obj.inputs.colLabel.axesno}=ChannelAxesNo;
                                obj.inputs.condMat{c,obj.inputs.colLabel.chType}=ChannelType;
                                obj.inputs.condMat{c,obj.inputs.colLabel.chId}=ChannelID;
                                obj.inputs.condMat{c,obj.inputs.colLabel.stimcdMrk}=c;
                                conds=fieldnames(obj.inputs.condsAll);
                                for stno=1:(max(size(fieldnames(obj.inputs.condsAll.(conds{c,1}))))-1)
                                    st=['st' num2str(stno)];
                                    if(obj.inputs.condsAll.(conds{c,1}).(st).stim_mode=='single_pulse')
                                        obj.inputs.condsAll.(conds{c,1}).(st).si_pckt{1,2}=0;
                                        obj.inputs.condsAll.(conds{c,1}).(st).si_pckt{1,3}=0;
                                    end
                                    if obj.inputs.condsAll.(conds{c,1}).(st).si_units==1
                                        obj.inputs.condsAll.(conds{c,1}).(st).si_pckt{1,4}=obj.inputs.condsAll.(conds{c,1}).(st).si_pckt{1,1};
                                    elseif obj.inputs.condsAll.(conds{c,1}).(st).si_units==0 && ~isempty(str2num(obj.inputs.condsAll.(conds{c,1}).(st).threshold)) && str2num(obj.inputs.condsAll.(conds{c,1}).(st).threshold)>0
                                        obj.inputs.condsAll.(conds{c,1}).(st).si_pckt{1,4}=round((obj.inputs.condsAll.(conds{c,1}).(st).si_pckt{1,1}*(str2num(obj.inputs.condsAll.(conds{c,1}).(st).threshold)))/100);
                                    end
                                    condSi{1,stno}=obj.inputs.condsAll.(conds{c,1}).(st).si_pckt;
                                    condstimMode{1,stno}= obj.inputs.condsAll.(conds{c,1}).(st).stim_mode;
                                    obj.inputs.condsAll.(conds{c,1}).(st).stim_device
                                    condoutputDevice{1,stno}=obj.inputs.condsAll.(conds{c,1}).(st).stim_device;
                                    for i=1:numel(obj.inputs.condsAll.(conds{c,1}).(st).stim_timing)
                                        condstimTimingStrings{1,i}=num2str(obj.inputs.condsAll.(conds{c,1}).(st).stim_timing{1,i});
                                    end
                                    condstimTiming{1,stno}=condstimTimingStrings;
                                end
                                obj.inputs.condMat(c,obj.inputs.colLabel.si)={condSi};
                                obj.inputs.condMat(c,obj.inputs.colLabel.outputDevices)={condoutputDevice};
                                obj.inputs.condMat(c,obj.inputs.colLabel.stimMode)={condstimMode};
                                %                         condstimTiming=condstimTiming{1,1};
                                %                         condstimTiming={{cellfun(@num2str, condstimTiming{1,1}(1,1:end))}};
                                %                                                 condstimTiming={{arrayfun(@num2str, condstimTiming{1,1}(1,1:end))}};
                                
                                %                         condstimTiming=cellstr(condstimTiming);
                                for timing=1:numel(condstimTiming)
                                    for jj=1:numel(condstimTiming{1,timing})
                                        condstimTiming{2,timing}{1,jj}=condoutputDevice{1,timing};
                                    end
                                end
                                condstimTiming_new{1}=horzcat(condstimTiming{1,:});
                                condstimTiming_new{2}=horzcat(condstimTiming{2,:});
                                [condstimTiming_new_sorted{1},sorted_idx]=sort(condstimTiming_new{1});
                                
                                %                                  [condstimTiming_new_sorted{1},sorted_idx]=sort(cellfun(@str2num, condstimTiming_new{1}));
                                %                                  condstimTiming_new_sorted{1}=cellfun(@num2str, num2cell(condstimTiming_new_sorted{1}));
                                
                                
                                
                                condstimTiming_new_sorted{2}=condstimTiming_new{1,2}(sorted_idx);
                                %                                  condstimTiming_new_sorted{1}=cellfun(@num2str, num2cell(condstimTiming_new_sorted{1}));
                                
                                for stimno_tpm=1:numel(condstimTiming_new_sorted{2})
                                    port_vector{stimno_tpm}=obj.app.par.hardware_settings.(char(condstimTiming_new_sorted{2}{1,stimno_tpm})).bb_outputport;
                                end
                                condstimTiming_new_sorted{2}=port_vector;
                                tpmVect=[condstimTiming_new_sorted{1};condstimTiming_new_sorted{2}];
                                [tpmVect_unique,ia,ic]=unique(tpmVect(1,:));
                                a_counts = accumarray(ic,1);
                                for binportloop=1:numel(tpmVect_unique)
                                    buffer{1,binportloop}={(cell2mat(tpmVect(2,ia(binportloop):ia(binportloop)-1+a_counts(binportloop))))};
                                    binaryZ='0000';
                                    num=cell2mat(buffer{1,binportloop});
                                    for binaryID=1:numel(num)
                                        binaryZ(str2num(num(binaryID)))='1';
                                    end
                                    buffer{1,binportloop}=bin2dec(flip(binaryZ));
                                    markers{1,binportloop}=0;
                                end
                                markers{1,1}=c;
                                condstimTiming_new_sorted=[num2cell((cellfun(@str2num, tpmVect_unique(1,1:end))));buffer;markers];
                                condstimTiming_new_sorted=cell2mat(condstimTiming_new_sorted)
                                [condstimTiming_new_sorted(1,:),sorted_idx]=sort(condstimTiming_new_sorted(1,:))
                                condstimTiming_new_sorted(1,:)=condstimTiming_new_sorted(1,:)/1000;
                                condstimTiming_new_sorted(2,:)=condstimTiming_new_sorted(2,sorted_idx)
                                
                                obj.inputs.condMat(c,obj.inputs.colLabel.tpm)={num2cell(condstimTiming_new_sorted)};
                                condSi=[];
                                condoutputDevice=[];
                                condstimMode=[];
                                condstimTiming=[];
                                buffer=[];
                                tpmVect_unique=[];
                                a_counts =[];
                                ia=[];
                                ic=[];
                                port_vector=[];
                                num=[];
                                condstimTiming_new=[];
                                condstimTiming_new_sorted=[];
                                sorted_idx=[];
                                markers=[];
                                condstimTimingStrings=[];
                            end
                    end
                case 'Motor Threshold Hunting Protocol'
                    switch obj.inputs.BrainState
                        case 1 %Independent
                            %% Adjusting New Arhictecture to Old Architecture
                            obj.inputs.MEPOnset=obj.inputs.MEPSearchWindow(1);
                            obj.inputs.MEPOffset=obj.inputs.MEPSearchWindow(2);
                            obj.inputs.EMGDisplayPeriodPre=obj.inputs.EMGExtractionPeriod(1)*(-1);
                            obj.inputs.EMGDisplayPeriodPost=obj.inputs.EMGExtractionPeriod(2);
                            obj.inputs.prestim_scope_plt=obj.inputs.EMGDisplayPeriodPre;
                            obj.inputs.poststim_scope_plt=obj.inputs.EMGDisplayPeriodPost;
                            obj.inputs.mep_onset=obj.inputs.MEPOnset;
                            obj.inputs.mep_offset=obj.inputs.MEPOffset;
                            obj.inputs.input_device=obj.app.pi.mth.InputDevice.String(obj.inputs.InputDevice); %TODO: the drc or mep on the 4th structure is not a good solution!
                            obj.inputs.output_device=obj.inputs.condsAll.cond1.st1.stim_device;
                            obj.inputs.stim_mode='MSO';
                            obj.inputs.measure_str='Motor Threshold Hunting Protocol';
                            obj.inputs.ylimMin=obj.inputs.EMGDisplayYLimMin;
                            obj.inputs.ylimMax=obj.inputs.EMGDisplayYLimMax;
                            obj.inputs.stop_event=0;
                            obj.inputs.ylimMin=-60;
                            obj.inputs.ylimMax=+60;
                            obj.inputs.TrialNoForMean=1;
                            obj.inputs.mt_starting_stim_inten=obj.inputs.condsAll.cond1.st1.si_pckt{1,1};
                            obj.inputs.Handles.ThresholdData=struct;
                            %% Creating Column Labels
                            obj.inputs.colLabel.inputDevices=1;
                            obj.inputs.colLabel.outputDevices=2;
                            obj.inputs.colLabel.si=3;
                            obj.inputs.colLabel.iti=4;
                            obj.inputs.colLabel.chLab=5;
                            obj.inputs.colLabel.trials=9;
                            obj.inputs.colLabel.axesno=6;
                            obj.inputs.colLabel.measures=7;
                            obj.inputs.colLabel.stimMode=8;
                            obj.inputs.colLabel.tpm=10;
                            obj.inputs.colLabel.chType=11;
                            obj.inputs.colLabel.chId=12;
                            obj.inputs.colLabel.mepamp=13;
                            obj.inputs.colLabel.threshold=14;
                            obj.inputs.colLabel.marker=15;
                            %% Creating Channel Measures, AxesNo, Labels
                            conds=fieldnames(obj.inputs.condsAll);
                            %                             ChannelLabls=[repelem(obj.inputs.EMGTargetChannels,3),obj.inputs.EMGDisplayChannels]; %this can go directly inside the cond object in the loop
                            ChannelMeasures=[repmat({'MEP_Measurement','Motor Threshold Hunting'},1,numel(conds)),repmat({'MEP_Measurement'},1,numel(obj.inputs.EMGDisplayChannels)),{'StatusTable'}]; %dirctly inside the loop
                            % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %                             ChannelAxesNo=num2cell(1:numel(ChannelLabels));
                            DisplayChannelAxesNo=num2cell(numel(conds)*2+1:numel(ChannelMeasures));
                            obj.app.pr.ax_measures=ChannelMeasures;
                            obj.app.pr.axesno=numel(ChannelMeasures);
                            obj.inputs.Figures=cell(1,obj.app.pr.axesno);
                            %                             obj.app.pr.ax_ChannelLabels=ChannelMeasures; write in the end and remove from here
                            %% Creating Channel Type, Channel Index
                            switch obj.app.par.hardware_settings.(char(obj.inputs.input_device)).slct_device
                                case 1 %boss box NeurOne
                                    ChannelType=[repmat({'EMG','None'},1,numel(conds)),repmat({'EMG'},1,numel(obj.inputs.EMGDisplayChannels)),{'StatusTable'}]; %dirctly inside the loop
                                    ChannelID=num2cell(1:numel(ChannelType)); %TODO: make this more systematic and extract from channel labels of neurone or acs protocol
                                    obj.inputs.ChannelsTypeUnique=ChannelType;
                                    for ChannelType1=1:numel(conds)
                                        obj.inputs.condsAll.(conds{ChannelType1,1}).targetChannel;
                                        ChannelID{2*ChannelType1-1}=find(strcmp(obj.app.par.hardware_settings.(char(obj.inputs.input_device)).NeurOneProtocolChannelLabels,obj.inputs.condsAll.(conds{ChannelType1,1}).targetChannel));
                                    end
                                    for ChannelType2=1:numel(obj.inputs.EMGDisplayChannels)
                                        ChannelID{2*numel(conds)+ChannelType2}=find(strcmp(obj.app.par.hardware_settings.(char(obj.inputs.input_device)).NeurOneProtocolChannelLabels,obj.inputs.EMGDisplayChannels{ChannelType2}));
                                    end
                                case 2 % fieldtrip real time buffer
                            end
                            %% Creating Stimulation Conditions
                            for c=1:numel(fieldnames(obj.inputs.condsAll))
                                obj.inputs.condMat{c,obj.inputs.colLabel.trials}=obj.inputs.TrialsPerCondition;
                                obj.inputs.condMat{c,obj.inputs.colLabel.iti}=obj.inputs.ITI;
                                obj.inputs.condMat{c,obj.inputs.colLabel.inputDevices}=char(obj.app.pi.mth.InputDevice.String(obj.inputs.InputDevice));
                                TargetChannel=obj.inputs.condsAll.(conds{c,1}).targetChannel;
                                obj.inputs.results.(TargetChannel{1}).MotorThreshold=obj.inputs.MotorThreshold;
                                obj.inputs.results.(TargetChannel{1}).NoOfLastTrialsToAverage=obj.inputs.NoOfTrialsToAverage;
                                obj.app.pr.ax_ChannelLabels{c*2-1}=TargetChannel{1};
                                obj.app.pr.ax_ChannelLabels{c*2}=TargetChannel{1};
                                obj.inputs.condMat{c,obj.inputs.colLabel.chLab}=[repelem(TargetChannel,2),obj.inputs.EMGDisplayChannels,{'StatusTable'}];
                                obj.inputs.condMat{c,obj.inputs.colLabel.measures}=[{'MEP_Measurement'},{'Threshold Trace'},repmat({'MEP_Measurement'},1,numel(obj.inputs.EMGDisplayChannels)),{'StatusTable'}];
                                obj.inputs.condMat{c,obj.inputs.colLabel.axesno}=[{c*2-1},{c*2},DisplayChannelAxesNo];
                                obj.inputs.condMat{c,obj.inputs.colLabel.chType}=[ChannelType(c*2-1),ChannelType(c*2),ChannelType(end-numel(obj.inputs.EMGDisplayChannels):end)];%{'EMG','None',repmat('EMG',1,numel(obj.inputs.EMGDisplayChannels)),'StatusTable'};
                                obj.inputs.condMat{c,obj.inputs.colLabel.chId}=[ChannelID(c*2-1),ChannelID(c*2),ChannelID(end-numel(obj.inputs.EMGDisplayChannels):end)]; %% TODO: update it later with the originigal channel index
                                obj.inputs.condMat{c,obj.inputs.colLabel.marker}=c;
                                obj.inputs.condMat{c,obj.inputs.colLabel.threshold}=obj.inputs.condsAll.(conds{c,1}).st1.threshold_level;
                                for stno=1:(max(size(fieldnames(obj.inputs.condsAll.(conds{c,1}))))-6)
                                    st=['st' num2str(stno)];
                                    if(obj.inputs.condsAll.(conds{c,1}).(st).stim_mode=='single_pulse')
                                        obj.inputs.condsAll.(conds{c,1}).(st).si_pckt{1,2}=0;
                                        obj.inputs.condsAll.(conds{c,1}).(st).si_pckt{1,3}=0;
                                    end
                                    if obj.inputs.condsAll.(conds{c,1}).(st).si_units==1
                                        obj.inputs.condsAll.(conds{c,1}).(st).si_pckt{1,4}=obj.inputs.condsAll.(conds{c,1}).(st).si_pckt{1,1};
                                    elseif obj.inputs.condsAll.(conds{c,1}).(st).si_units==0 && ~isempty(str2num(obj.inputs.condsAll.(conds{c,1}).(st).threshold)) && str2num(obj.inputs.condsAll.(conds{c,1}).(st).threshold)>0
                                        obj.inputs.condsAll.(conds{c,1}).(st).si_pckt{1,4}=round((obj.inputs.condsAll.(conds{c,1}).(st).si_pckt{1,1}*(str2num(obj.inputs.condsAll.(conds{c,1}).(st).threshold)))/100);
                                    end
                                    condSi{1,stno}=obj.inputs.condsAll.(conds{c,1}).(st).si_pckt;
                                    condstimMode{1,stno}= obj.inputs.condsAll.(conds{c,1}).(st).stim_mode;
                                    obj.inputs.condsAll.(conds{c,1}).(st).stim_device
                                    condoutputDevice{1,stno}=obj.inputs.condsAll.(conds{c,1}).(st).stim_device;
                                    for i=1:numel(obj.inputs.condsAll.(conds{c,1}).(st).stim_timing)
                                        condstimTimingStrings{1,i}=num2str(obj.inputs.condsAll.(conds{c,1}).(st).stim_timing{1,i});
                                    end
                                    condstimTiming{1,stno}=condstimTimingStrings;
                                end
                                obj.inputs.condMat(c,obj.inputs.colLabel.si)={condSi};
                                obj.inputs.condMat(c,obj.inputs.colLabel.outputDevices)={condoutputDevice};
                                obj.inputs.condMat(c,obj.inputs.colLabel.stimMode)={condstimMode};
                                %                         condstimTiming=condstimTiming{1,1};
                                %                         condstimTiming={{cellfun(@num2str, condstimTiming{1,1}(1,1:end))}};
                                %                                                 condstimTiming={{arrayfun(@num2str, condstimTiming{1,1}(1,1:end))}};
                                
                                %                         condstimTiming=cellstr(condstimTiming);
                                for timing=1:numel(condstimTiming)
                                    for jj=1:numel(condstimTiming{1,timing})
                                        condstimTiming{2,timing}{1,jj}=condoutputDevice{1,timing};
                                    end
                                end
                                condstimTiming_new{1}=horzcat(condstimTiming{1,:});
                                condstimTiming_new{2}=horzcat(condstimTiming{2,:});
                                [condstimTiming_new_sorted{1},sorted_idx]=sort(condstimTiming_new{1});
                                
                                %                                  [condstimTiming_new_sorted{1},sorted_idx]=sort(cellfun(@str2num, condstimTiming_new{1}));
                                %                                  condstimTiming_new_sorted{1}=cellfun(@num2str, num2cell(condstimTiming_new_sorted{1}));
                                
                                
                                
                                condstimTiming_new_sorted{2}=condstimTiming_new{1,2}(sorted_idx);
                                %                                  condstimTiming_new_sorted{1}=cellfun(@num2str, num2cell(condstimTiming_new_sorted{1}));
                                
                                for stimno_tpm=1:numel(condstimTiming_new_sorted{2})
                                    port_vector{stimno_tpm}=obj.app.par.hardware_settings.(char(condstimTiming_new_sorted{2}{1,stimno_tpm})).bb_outputport;
                                end
                                condstimTiming_new_sorted{2}=port_vector;
                                tpmVect=[condstimTiming_new_sorted{1};condstimTiming_new_sorted{2}];
                                [tpmVect_unique,ia,ic]=unique(tpmVect(1,:));
                                a_counts = accumarray(ic,1);
                                for binportloop=1:numel(tpmVect_unique)
                                    buffer{1,binportloop}={(cell2mat(tpmVect(2,ia(binportloop):ia(binportloop)-1+a_counts(binportloop))))};
                                    binaryZ='0000';
                                    num=cell2mat(buffer{1,binportloop});
                                    for binaryID=1:numel(num)
                                        binaryZ(str2num(num(binaryID)))='1';
                                    end
                                    buffer{1,binportloop}=bin2dec(flip(binaryZ));
                                    markers{1,binportloop}=0;
                                end
                                markers{1,1}=c;
                                condstimTiming_new_sorted=[num2cell((cellfun(@str2num, tpmVect_unique(1,1:end))));buffer;markers];
                                condstimTiming_new_sorted=cell2mat(condstimTiming_new_sorted)
                                [condstimTiming_new_sorted(1,:),sorted_idx]=sort(condstimTiming_new_sorted(1,:))
                                condstimTiming_new_sorted(1,:)=condstimTiming_new_sorted(1,:)/1000;
                                condstimTiming_new_sorted(2,:)=condstimTiming_new_sorted(2,sorted_idx)
                                
                                obj.inputs.condMat(c,obj.inputs.colLabel.tpm)={num2cell(condstimTiming_new_sorted)};
                                condSi=[];
                                condoutputDevice=[];
                                condstimMode=[];
                                condstimTiming=[];
                                buffer=[];
                                tpmVect_unique=[];
                                a_counts =[];
                                ia=[];
                                ic=[];
                                port_vector=[];
                                num=[];
                                condstimTiming_new=[];
                                condstimTiming_new_sorted=[];
                                sorted_idx=[];
                                markers=[];
                                condstimTimingStrings=[];
                                obj.app.pr.ax_ChannelLabels=[obj.app.pr.ax_ChannelLabels,obj.inputs.EMGDisplayChannels,{'StatusTable'}];
                            end
                        case 2 %Dependent
                            %% Adjusting New Arhictecture to Old Architecture
                            obj.inputs.MEPOnset=obj.inputs.MEPSearchWindow(1);
                            obj.inputs.MEPOffset=obj.inputs.MEPSearchWindow(2);
                            obj.inputs.EMGDisplayPeriodPre=obj.inputs.EMGExtractionPeriod(1)*(-1);
                            obj.inputs.EMGDisplayPeriodPost=obj.inputs.EMGExtractionPeriod(2);
                            obj.inputs.EEGDisplayPeriodPre=obj.inputs.EEGExtractionPeriod(1)*(-1);
                            obj.inputs.EEGDisplayPeriodPost=obj.inputs.EEGExtractionPeriod(2);
                            obj.inputs.MontageChannels=obj.inputs.RealTimeChannelsMontage;
                            obj.inputs.MontageWeights=obj.inputs.RealTimeChannelsWeights;
                            obj.inputs.prestim_scope_plt=obj.inputs.EMGDisplayPeriodPre;
                            obj.inputs.poststim_scope_plt=obj.inputs.EMGDisplayPeriodPost;
                            obj.inputs.mep_onset=obj.inputs.MEPOnset;
                            obj.inputs.mep_offset=obj.inputs.MEPOffset;
                            obj.inputs.input_device=obj.app.pi.mth.InputDevice.String(obj.inputs.InputDevice); %TODO: the drc or mep on the 4th structure is not a good solution!
                            obj.inputs.output_device=obj.inputs.condsAll.cond1.st1.stim_device;
                            obj.inputs.stim_mode='MSO';
                            obj.inputs.measure_str='Motor Threshold Hunting Protocol';
                            obj.inputs.ylimMin=obj.inputs.EMGDisplayYLimMin;
                            obj.inputs.ylimMax=obj.inputs.EMGDisplayYLimMax;
                            obj.inputs.stop_event=0;
                            obj.inputs.ylimMin=-60;
                            obj.inputs.ylimMax=+60;
                            obj.inputs.TrialNoForMean=1;
                            obj.inputs.mt_starting_stim_inten=obj.inputs.condsAll.cond1.st1.si_pckt{1,1};
                            obj.inputs.Handles.ThresholdData=struct;
                            %% Creating Column Labels
                            obj.inputs.colLabel.inputDevices=1;
                            obj.inputs.colLabel.outputDevices=2;
                            obj.inputs.colLabel.si=3;
                            obj.inputs.colLabel.iti=4;
                            obj.inputs.colLabel.chLab=5;
                            obj.inputs.colLabel.trials=9;
                            obj.inputs.colLabel.axesno=6;
                            obj.inputs.colLabel.measures=7;
                            obj.inputs.colLabel.stimMode=8;
                            obj.inputs.colLabel.tpm=10;
                            obj.inputs.colLabel.chType=11;
                            obj.inputs.colLabel.chId=12;
                            obj.inputs.colLabel.phase=15;
                            obj.inputs.colLabel.IA=16;
                            obj.inputs.colLabel.threshold=13;
                            obj.inputs.colLabel.marker=14;
                            if obj.inputs.AmplitudeUnits==1
                                obj.inputs.colLabel.IAPercentile=17;
                            end
                            %% Creating Channel Measures, AxesNo, Labels
                            conds=fieldnames(obj.inputs.condsAll);
                            %                             ChannelLabls=[repelem(obj.inputs.EMGTargetChannels,3),obj.inputs.EMGDisplayChannels]; %this can go directly inside the cond object in the loop
                            ChannelMeasures=[{'PhaseHistogram'},{'TriggerLockedEEG'},repmat({'MEP_Measurement','Motor Threshold Hunting'},1,numel(conds)),repmat({'MEP_Measurement'},1,numel(obj.inputs.EMGDisplayChannels)),{'RunningAmplitude'},{'AmplitudeDistribution'},{'StatusTable'}];
                            % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %                             ChannelAxesNo=num2cell(1:numel(ChannelLabels));
                            DisplayChannelAxesNo=num2cell(2+numel(conds)*2+1:numel(ChannelMeasures));
                            obj.app.pr.ax_measures=ChannelMeasures;
                            obj.app.pr.axesno=numel(ChannelMeasures);
                            obj.inputs.Figures=cell(1,obj.app.pr.axesno);
                            %                             obj.app.pr.ax_ChannelLabels=ChannelMeasures; write in the end and remove from here
                            %% Creating Channel Type, Channel Index
                            switch obj.app.par.hardware_settings.(char(obj.inputs.input_device)).slct_device
                                case 1 %boss box NeurOne
                                    ChannelType=[{'IP'},{'IEEG'},repmat({'EMG','None'},1,numel(conds)),repmat({'EMG'},1,numel(obj.inputs.EMGDisplayChannels)),{'IA'},{'IADistribution'},{'StatusTable'}]; %dirctly inside the loop
                                    ChannelID=num2cell(1:numel(ChannelType)); %TODO: make this more systematic and extract from channel labels of neurone or acs protocol
                                    obj.inputs.ChannelsTypeUnique=ChannelType;
                                    for ChannelType1=1:numel(conds)
                                        obj.inputs.condsAll.(conds{ChannelType1,1}).targetChannel;
                                        ChannelID{2+2*ChannelType1-1}=find(strcmp(obj.app.par.hardware_settings.(char(obj.inputs.input_device)).NeurOneProtocolChannelLabels,obj.inputs.condsAll.(conds{ChannelType1,1}).targetChannel));
                                    end
                                    for ChannelType2=1:numel(obj.inputs.EMGDisplayChannels)
                                        obj.inputs.condsAll.(conds{ChannelType2,1}).targetChannel;
                                        ChannelID{2+2*numel(conds)+ChannelType2}=find(strcmp(obj.app.par.hardware_settings.(char(obj.inputs.input_device)).NeurOneProtocolChannelLabels,obj.inputs.EMGDisplayChannels{ChannelType2}));
                                    end
                                case 2 % fieldtrip real time buffer
                            end
                            %% Creating Stimulation Conditions
                            for c=1:numel(fieldnames(obj.inputs.condsAll))
                                obj.inputs.condMat{c,obj.inputs.colLabel.trials}=obj.inputs.TrialsPerCondition;
                                obj.inputs.condMat{c,obj.inputs.colLabel.iti}=obj.inputs.ITI;
                                obj.inputs.condMat{c,obj.inputs.colLabel.inputDevices}=char(obj.app.pi.mth.InputDevice.String(obj.inputs.InputDevice));
                                TargetChannel=obj.inputs.condsAll.(conds{c,1}).targetChannel;
                                obj.inputs.results.(TargetChannel{1}).MotorThreshold=obj.inputs.MotorThreshold;
                                obj.inputs.results.(TargetChannel{1}).NoOfLastTrialsToAverage=obj.inputs.NoOfTrialsToAverage;
                                obj.app.pr.ax_ChannelLabels{c*2-1}=TargetChannel{1};
                                obj.app.pr.ax_ChannelLabels{c*2}=TargetChannel{1};
                                obj.inputs.condMat{c,obj.inputs.colLabel.chLab}=[{'OsscillationPhase'},{'OsscillationEEG'},repelem(TargetChannel,2),obj.inputs.EMGDisplayChannels,{'OsscillationAmplitude'},{'AmplitudeDistribution'},{'StatusTable'}];
                                obj.inputs.condMat{c,obj.inputs.colLabel.measures}=[{'PhaseHistogram'},{'TriggerLockedEEG'},{'MEP_Measurement'},{'Threshold Trace'},repmat({'MEP_Measurement'},1,numel(obj.inputs.EMGDisplayChannels)),{'OsscillationAmplitude'},{'AmplitudeDistribution'},{'StatusTable'}];
                                obj.inputs.condMat{c,obj.inputs.colLabel.axesno}=[1,2,{2+(c*2-1)},{2+(c*2)},DisplayChannelAxesNo];
                                obj.inputs.condMat{c,obj.inputs.colLabel.chType}=[{'IP'},{'IEEG'},ChannelType(2+(c*2-1)),ChannelType(2+(c*2)),ChannelType(end-numel(obj.inputs.EMGDisplayChannels)-2:end)];%{'EMG','None',repmat('EMG',1,numel(obj.inputs.EMGDisplayChannels)),'StatusTable'};
                                obj.inputs.condMat{c,obj.inputs.colLabel.chId}=[{1,1},ChannelID(2+(c*2-1)),ChannelID(2+(c*2)),ChannelID(end-numel(obj.inputs.EMGDisplayChannels)-2:end)]; %% TODO: update it later with the originigal channel index
                                obj.inputs.condMat{c,obj.inputs.colLabel.marker}=c;
                                obj.inputs.condMat{c,obj.inputs.colLabel.threshold}=obj.inputs.condsAll.(conds{c,1}).st1.threshold_level;
                                for stno=1:(max(size(fieldnames(obj.inputs.condsAll.(conds{c,1}))))-1)
                                    st=['st' num2str(stno)];
                                    if(obj.inputs.condsAll.(conds{c,1}).(st).stim_mode=='single_pulse')
                                        obj.inputs.condsAll.(conds{c,1}).(st).si_pckt{1,2}=0;
                                        obj.inputs.condsAll.(conds{c,1}).(st).si_pckt{1,3}=0;
                                    end
                                    if obj.inputs.condsAll.(conds{c,1}).(st).si_units==1
                                        obj.inputs.condsAll.(conds{c,1}).(st).si_pckt{1,4}=obj.inputs.condsAll.(conds{c,1}).(st).si_pckt{1,1};
                                    elseif obj.inputs.condsAll.(conds{c,1}).(st).si_units==0 && ~isempty(str2num(obj.inputs.condsAll.(conds{c,1}).(st).threshold)) && str2num(obj.inputs.condsAll.(conds{c,1}).(st).threshold)>0
                                        obj.inputs.condsAll.(conds{c,1}).(st).si_pckt{1,4}=round((obj.inputs.condsAll.(conds{c,1}).(st).si_pckt{1,1}*(str2num(obj.inputs.condsAll.(conds{c,1}).(st).threshold)))/100);
                                    end
                                    condSi{1,stno}=obj.inputs.condsAll.(conds{c,1}).(st).si_pckt;
                                    condstimMode{1,stno}= obj.inputs.condsAll.(conds{c,1}).(st).stim_mode;
                                    obj.inputs.condsAll.(conds{c,1}).(st).stim_device
                                    condoutputDevice{1,stno}=obj.inputs.condsAll.(conds{c,1}).(st).stim_device;
                                    for i=1:numel(obj.inputs.condsAll.(conds{c,1}).(st).stim_timing)
                                        condstimTimingStrings{1,i}=num2str(obj.inputs.condsAll.(conds{c,1}).(st).stim_timing{1,i});
                                    end
                                    condstimTiming{1,stno}=condstimTimingStrings;
                                end
                                obj.inputs.condMat(c,obj.inputs.colLabel.si)={condSi};
                                obj.inputs.condMat(c,obj.inputs.colLabel.outputDevices)={condoutputDevice};
                                obj.inputs.condMat(c,obj.inputs.colLabel.stimMode)={condstimMode};
                                %                         condstimTiming=condstimTiming{1,1};
                                %                         condstimTiming={{cellfun(@num2str, condstimTiming{1,1}(1,1:end))}};
                                %                                                 condstimTiming={{arrayfun(@num2str, condstimTiming{1,1}(1,1:end))}};
                                
                                %                         condstimTiming=cellstr(condstimTiming);
                                for timing=1:numel(condstimTiming)
                                    for jj=1:numel(condstimTiming{1,timing})
                                        condstimTiming{2,timing}{1,jj}=condoutputDevice{1,timing};
                                    end
                                end
                                condstimTiming_new{1}=horzcat(condstimTiming{1,:});
                                condstimTiming_new{2}=horzcat(condstimTiming{2,:});
                                [condstimTiming_new_sorted{1},sorted_idx]=sort(condstimTiming_new{1});
                                
                                %                                  [condstimTiming_new_sorted{1},sorted_idx]=sort(cellfun(@str2num, condstimTiming_new{1}));
                                %                                  condstimTiming_new_sorted{1}=cellfun(@num2str, num2cell(condstimTiming_new_sorted{1}));
                                
                                
                                
                                condstimTiming_new_sorted{2}=condstimTiming_new{1,2}(sorted_idx);
                                %                                  condstimTiming_new_sorted{1}=cellfun(@num2str, num2cell(condstimTiming_new_sorted{1}));
                                
                                for stimno_tpm=1:numel(condstimTiming_new_sorted{2})
                                    port_vector{stimno_tpm}=obj.app.par.hardware_settings.(char(condstimTiming_new_sorted{2}{1,stimno_tpm})).bb_outputport;
                                end
                                condstimTiming_new_sorted{2}=port_vector;
                                tpmVect=[condstimTiming_new_sorted{1};condstimTiming_new_sorted{2}];
                                [tpmVect_unique,ia,ic]=unique(tpmVect(1,:));
                                a_counts = accumarray(ic,1);
                                for binportloop=1:numel(tpmVect_unique)
                                    buffer{1,binportloop}={(cell2mat(tpmVect(2,ia(binportloop):ia(binportloop)-1+a_counts(binportloop))))};
                                    binaryZ='0000';
                                    num=cell2mat(buffer{1,binportloop});
                                    for binaryID=1:numel(num)
                                        binaryZ(str2num(num(binaryID)))='1';
                                    end
                                    buffer{1,binportloop}=bin2dec(flip(binaryZ));
                                    markers{1,binportloop}=0;
                                end
                                markers{1,1}=c;
                                condstimTiming_new_sorted=[num2cell((cellfun(@str2num, tpmVect_unique(1,1:end))));buffer;markers];
                                condstimTiming_new_sorted=cell2mat(condstimTiming_new_sorted)
                                [condstimTiming_new_sorted(1,:),sorted_idx]=sort(condstimTiming_new_sorted(1,:))
                                condstimTiming_new_sorted(1,:)=condstimTiming_new_sorted(1,:)/1000;
                                condstimTiming_new_sorted(2,:)=condstimTiming_new_sorted(2,sorted_idx)
                                
                                obj.inputs.condMat(c,obj.inputs.colLabel.tpm)={num2cell(condstimTiming_new_sorted)};
                                condSi=[];
                                condoutputDevice=[];
                                condstimMode=[];
                                condstimTiming=[];
                                buffer=[];
                                tpmVect_unique=[];
                                a_counts =[];
                                ia=[];
                                ic=[];
                                port_vector=[];
                                num=[];
                                condstimTiming_new=[];
                                condstimTiming_new_sorted=[];
                                sorted_idx=[];
                                markers=[];
                                condstimTimingStrings=[];
                                obj.app.pr.ax_ChannelLabels=[{'OsscillationPhase'},{'OsscillationEEG'},obj.app.pr.ax_ChannelLabels,obj.inputs.EMGDisplayChannels,{'OsscillationAmplitude'},{'AmplitudeDistribution'},{'StatusTable'}];
                            end
                    end
                case 'Psychometric Threshold Hunting Protocol'
                    switch obj.inputs.BrainState
                        case 1 %Independent
                            %% Adjusting New Arhictecture to Old Architecture
                            obj.inputs.input_device=obj.app.pi.psychmth.InputDevice.String(obj.inputs.InputDevice); %TODO: the drc or mep on the 4th structure is not a good solution!
                            obj.inputs.output_device=obj.inputs.condsAll.cond1.st1.stim_device;
                            obj.inputs.stim_mode='MSO';
                            obj.inputs.measure_str='Psychometric Threshold Hunting Protocol';
                            obj.inputs.stop_event=0;
                            obj.inputs.mt_starting_stim_inten=obj.inputs.condsAll.cond1.st1.si_pckt{1,1};
                            obj.inputs.Handles.ThresholdData=struct;
                            %% Creating Column Labels
                            obj.inputs.colLabel.inputDevices=1;
                            obj.inputs.colLabel.outputDevices=2;
                            obj.inputs.colLabel.si=3;
                            obj.inputs.colLabel.iti=4;
                            obj.inputs.colLabel.chLab=5;
                            obj.inputs.colLabel.trials=9;
                            obj.inputs.colLabel.axesno=6;
                            obj.inputs.colLabel.measures=7;
                            obj.inputs.colLabel.stimMode=8;
                            obj.inputs.colLabel.tpm=10;
                            obj.inputs.colLabel.chType=11;
                            obj.inputs.colLabel.chId=12;
                            obj.inputs.colLabel.mepamp=13;
                            obj.inputs.colLabel.threshold=14;
                            obj.inputs.colLabel.marker=15;
                            %% Creating Channel Measures, AxesNo, Labels
                            conds=fieldnames(obj.inputs.condsAll);
                            ChannelMeasures=[repmat({'Sensory Threshold Hunting'},1,numel(conds)),{'StatusTable'}];
                            obj.app.pr.ax_measures=ChannelMeasures;
                            obj.app.pr.axesno=numel(ChannelMeasures);
                            obj.app.pr.ax_ChannelLabels(obj.app.pr.axesno)={'StatusTable'};
                            obj.inputs.Figures=cell(1,obj.app.pr.axesno);
                            %% Creating Stimulation Conditions
                            for c=1:numel(fieldnames(obj.inputs.condsAll))
                                obj.inputs.condMat{c,obj.inputs.colLabel.trials}=obj.inputs.TrialsPerCondition;
                                obj.inputs.condMat{c,obj.inputs.colLabel.iti}=obj.inputs.ITI;
                                obj.inputs.condMat{c,obj.inputs.colLabel.inputDevices}=char(obj.app.pi.psychmth.InputDevice.String(obj.inputs.InputDevice));
                                TargetChannel=obj.inputs.condsAll.(conds{c,1}).targetChannel;
                                obj.inputs.results.(TargetChannel{1}).PsychometricThreshold=obj.inputs.PsychometricThreshold;
                                obj.inputs.results.(TargetChannel{1}).NoOfLastTrialsToAverage=obj.inputs.NoOfTrialsToAverage;
                                obj.app.pr.ax_ChannelLabels(c)=TargetChannel;
                                obj.inputs.condMat{c,obj.inputs.colLabel.chLab}=[TargetChannel,{'StatusTable'}];
                                obj.inputs.condMat{c,obj.inputs.colLabel.measures}={'Psychometric Threshold Trace','StatusTable'};
                                obj.inputs.condMat{c,obj.inputs.colLabel.axesno}=[{c},{obj.app.pr.axesno}];
                                obj.inputs.condMat{c,obj.inputs.colLabel.chType}={'Psychometric','StatusTable'};
                                obj.inputs.condMat{c,obj.inputs.colLabel.chId}=num2cell(1); %% TODO: update it later with the originigal channel index
                                obj.inputs.condMat{c,obj.inputs.colLabel.marker}=c;
                                obj.inputs.condMat{c,obj.inputs.colLabel.threshold}=1;
                                for stno=1:(max(size(fieldnames(obj.inputs.condsAll.(conds{c,1}))))-1)
                                    st=['st' num2str(stno)];
                                    if(obj.inputs.condsAll.(conds{c,1}).(st).stim_mode=='single_pulse')
                                        obj.inputs.condsAll.(conds{c,1}).(st).si_pckt{1,2}=0;
                                        obj.inputs.condsAll.(conds{c,1}).(st).si_pckt{1,3}=0;
                                    end
                                    if obj.inputs.condsAll.(conds{c,1}).(st).si_units==1
                                        obj.inputs.condsAll.(conds{c,1}).(st).si_pckt{1,4}=obj.inputs.condsAll.(conds{c,1}).(st).si_pckt{1,1};
                                    elseif obj.inputs.condsAll.(conds{c,1}).(st).si_units==0 && ~isempty(str2num(obj.inputs.condsAll.(conds{c,1}).(st).threshold)) && str2num(obj.inputs.condsAll.(conds{c,1}).(st).threshold)>0
                                        obj.inputs.condsAll.(conds{c,1}).(st).si_pckt{1,4}=round((obj.inputs.condsAll.(conds{c,1}).(st).si_pckt{1,1}*(str2num(obj.inputs.condsAll.(conds{c,1}).(st).threshold)))/100);
                                    end
                                    condSi{1,stno}=obj.inputs.condsAll.(conds{c,1}).(st).si_pckt;
                                    condstimMode{1,stno}= obj.inputs.condsAll.(conds{c,1}).(st).stim_mode;
                                    obj.inputs.condsAll.(conds{c,1}).(st).stim_device
                                    condoutputDevice{1,stno}=obj.inputs.condsAll.(conds{c,1}).(st).stim_device;
                                    for i=1:numel(obj.inputs.condsAll.(conds{c,1}).(st).stim_timing)
                                        condstimTimingStrings{1,i}=num2str(obj.inputs.condsAll.(conds{c,1}).(st).stim_timing{1,i});
                                    end
                                    condstimTiming{1,stno}=condstimTimingStrings;
                                end
                                obj.inputs.condMat(c,obj.inputs.colLabel.si)={condSi};
                                obj.inputs.condMat(c,obj.inputs.colLabel.outputDevices)={condoutputDevice};
                                obj.inputs.condMat(c,obj.inputs.colLabel.stimMode)={condstimMode};
                                %                         condstimTiming=condstimTiming{1,1};
                                %                         condstimTiming={{cellfun(@num2str, condstimTiming{1,1}(1,1:end))}};
                                %                                                 condstimTiming={{arrayfun(@num2str, condstimTiming{1,1}(1,1:end))}};
                                
                                %                         condstimTiming=cellstr(condstimTiming);
                                for timing=1:numel(condstimTiming)
                                    for jj=1:numel(condstimTiming{1,timing})
                                        condstimTiming{2,timing}{1,jj}=condoutputDevice{1,timing};
                                    end
                                end
                                condstimTiming_new{1}=horzcat(condstimTiming{1,:});
                                condstimTiming_new{2}=horzcat(condstimTiming{2,:});
                                [condstimTiming_new_sorted{1},sorted_idx]=sort(condstimTiming_new{1});
                                
                                %                                  [condstimTiming_new_sorted{1},sorted_idx]=sort(cellfun(@str2num, condstimTiming_new{1}));
                                %                                  condstimTiming_new_sorted{1}=cellfun(@num2str, num2cell(condstimTiming_new_sorted{1}));
                                
                                
                                
                                condstimTiming_new_sorted{2}=condstimTiming_new{1,2}(sorted_idx);
                                %                                  condstimTiming_new_sorted{1}=cellfun(@num2str, num2cell(condstimTiming_new_sorted{1}));
                                
                                for stimno_tpm=1:numel(condstimTiming_new_sorted{2})
                                    port_vector{stimno_tpm}=obj.app.par.hardware_settings.(char(condstimTiming_new_sorted{2}{1,stimno_tpm})).bb_outputport;
                                end
                                condstimTiming_new_sorted{2}=port_vector;
                                tpmVect=[condstimTiming_new_sorted{1};condstimTiming_new_sorted{2}];
                                [tpmVect_unique,ia,ic]=unique(tpmVect(1,:));
                                a_counts = accumarray(ic,1);
                                for binportloop=1:numel(tpmVect_unique)
                                    buffer{1,binportloop}={(cell2mat(tpmVect(2,ia(binportloop):ia(binportloop)-1+a_counts(binportloop))))};
                                    binaryZ='0000';
                                    num=cell2mat(buffer{1,binportloop});
                                    for binaryID=1:numel(num)
                                        binaryZ(str2num(num(binaryID)))='1';
                                    end
                                    buffer{1,binportloop}=bin2dec(flip(binaryZ));
                                    markers{1,binportloop}=0;
                                end
                                markers{1,1}=c;
                                condstimTiming_new_sorted=[num2cell((cellfun(@str2num, tpmVect_unique(1,1:end))));buffer;markers];
                                condstimTiming_new_sorted=cell2mat(condstimTiming_new_sorted)
                                [condstimTiming_new_sorted(1,:),sorted_idx]=sort(condstimTiming_new_sorted(1,:))
                                condstimTiming_new_sorted(1,:)=condstimTiming_new_sorted(1,:)/1000;
                                condstimTiming_new_sorted(2,:)=condstimTiming_new_sorted(2,sorted_idx)
                                
                                obj.inputs.condMat(c,obj.inputs.colLabel.tpm)={num2cell(condstimTiming_new_sorted)};
                                condSi=[];
                                condoutputDevice=[];
                                condstimMode=[];
                                condstimTiming=[];
                                buffer=[];
                                tpmVect_unique=[];
                                a_counts =[];
                                ia=[];
                                ic=[];
                                port_vector=[];
                                num=[];
                                condstimTiming_new=[];
                                condstimTiming_new_sorted=[];
                                sorted_idx=[];
                                markers=[];
                                condstimTimingStrings=[];
                            end
                        case 2 %Dependent
                            %% Adjusting New Arhictecture to Old Architecture
                            obj.inputs.EEGDisplayPeriodPre=obj.inputs.EEGExtractionPeriod(1)*(-1);
                            obj.inputs.EEGDisplayPeriodPost=obj.inputs.EEGExtractionPeriod(2);
                            obj.inputs.MontageChannels=obj.inputs.RealTimeChannelsMontage;
                            obj.inputs.MontageWeights=obj.inputs.RealTimeChannelsWeights;
                            obj.inputs.input_device=obj.app.pi.psychmth.InputDevice.String(obj.inputs.InputDevice);
                            obj.inputs.output_device=obj.inputs.condsAll.cond1.st1.stim_device;
                            obj.inputs.stim_mode='MSO';
                            obj.inputs.measure_str='Psychometric Threshold Hunting Protocol';
                            obj.inputs.stop_event=0;
                            obj.inputs.mt_starting_stim_inten=obj.inputs.condsAll.cond1.st1.si_pckt{1,1};
                            obj.inputs.Handles.ThresholdData=struct;
                            %% Creating Column Labels
                            obj.inputs.colLabel.inputDevices=1;
                            obj.inputs.colLabel.outputDevices=2;
                            obj.inputs.colLabel.si=3;
                            obj.inputs.colLabel.iti=4;
                            obj.inputs.colLabel.chLab=5;
                            obj.inputs.colLabel.trials=9;
                            obj.inputs.colLabel.axesno=6;
                            obj.inputs.colLabel.measures=7;
                            obj.inputs.colLabel.stimMode=8;
                            obj.inputs.colLabel.tpm=10;
                            obj.inputs.colLabel.chType=11;
                            obj.inputs.colLabel.chId=12;
                            obj.inputs.colLabel.phase=15;
                            obj.inputs.colLabel.IA=16;
                            obj.inputs.colLabel.threshold=13;
                            obj.inputs.colLabel.marker=14;
                            if obj.inputs.AmplitudeUnits==1
                                obj.inputs.colLabel.IAPercentile=17;
                            end
                            %% Creating Channel Measures, AxesNo, Labels
                            conds=fieldnames(obj.inputs.condsAll);
                            %                             ChannelLabels=[{'OsscillationPhase'},{'OsscillationEEG'},repmat({'Psychometric Threshold Hunting'},1,numel(conds)),obj.inputs.EMGDisplayChannels,{'OsscillationAmplitude'},{'AmplitudeDistribution'}]; %[repelem(obj.inputs.EMGTargetChannels,3),obj.inputs.EMGDisplayChannels]; %this can go directly inside the cond object in the loop
                            ChannelMeasures=[{'PhaseHistogram'},{'TriggerLockedEEG'},repmat({'Sensory Threshold Hunting'},1,numel(conds)),{'RunningAmplitude'},{'AmplitudeDistribution'},{'StatusTable'}];
                            %                             ChannelAxesNo=num2cell(1:numel(ChannelLabels));
                            obj.app.pr.ax_measures=ChannelMeasures;
                            obj.app.pr.axesno=numel(ChannelMeasures);
                            axesno=num2cell(1:numel(ChannelMeasures));
                            %                             obj.app.pr.ax_ChannelLabels=ChannelLabels;
                            %% Creating Channel Type, Channel Index
                            switch obj.app.par.hardware_settings.(char(obj.inputs.input_device)).slct_device
                                case {1,6} %boss box or keyboard mouse
                                    ChannelType=[{'IP'},{'IEEG'},repmat({'Psyhcometric'},1,numel(conds)),{'IA'},{'IADistribution'},{'StatusTable'}];
                                    ChannelID=[{1},{1},num2cell(1:numel(conds)),{1},{1},{1}]; %TODO: make this more systematic and extract from channel labels of neurone or acs protocol
                                    obj.inputs.ChannelsTypeUnique=ChannelType;
                                case 2 % fieldtrip real time buffer
                            end
                            %% Creating Stimulation Conditions
                            for c=1:numel(fieldnames(obj.inputs.condsAll))
                                obj.inputs.condMat{c,obj.inputs.colLabel.trials}=obj.inputs.TrialsPerCondition;
                                obj.inputs.condMat{c,obj.inputs.colLabel.iti}=obj.inputs.ITI;
                                obj.inputs.condMat{c,obj.inputs.colLabel.inputDevices}=char(obj.app.pi.psychmth.InputDevice.String(obj.inputs.InputDevice));
                                TargetChannel=obj.inputs.condsAll.(conds{c,1}).targetChannel;
                                obj.inputs.results.(TargetChannel{1}).PsychometricThreshold=obj.inputs.PsychometricThreshold;
                                obj.inputs.results.(TargetChannel{1}).NoOfLastTrialsToAverage=obj.inputs.NoOfTrialsToAverage;
                                ChannelLabels{c}=TargetChannel;
                                obj.inputs.condMat{c,obj.inputs.colLabel.chLab}=[{'OsscillationPhase'},{'OsscillationEEG'},cellstr(TargetChannel),{'OsscillationAmplitude'},{'AmplitudeDistribution'},{'StatusTable'}];
                                obj.inputs.condMat{c,obj.inputs.colLabel.measures}=[{'PhaseHistogram'},{'TriggerLockedEEG'},{'Psychometric Threshold Trace'},{'RunningAmplitude'},{'AmplitudeDistribution'},{'StatusTable'}];
                                obj.inputs.condMat{c,obj.inputs.colLabel.axesno}={1,2,axesno{c+2},axesno{end-2},axesno{end-1},axesno{end}};
                                obj.inputs.condMat{c,obj.inputs.colLabel.chType}=[{'IP'},{'IEEG'},{'Psyhcometric'},{'IA'},{'IADistribution'},{'StatusTable'}];
                                obj.inputs.condMat{c,obj.inputs.colLabel.chId}={ChannelID{1},ChannelID{2},ChannelID{c+2},1,1,1};
                                obj.inputs.condMat{c,obj.inputs.colLabel.marker}=c;
                                obj.inputs.condMat{c,obj.inputs.colLabel.threshold}=1;
                                conds=fieldnames(obj.inputs.condsAll);
                                for stno=1:(max(size(fieldnames(obj.inputs.condsAll.(conds{c,1}))))-1)
                                    st=['st' num2str(stno)];
                                    if(obj.inputs.condsAll.(conds{c,1}).(st).stim_mode=='single_pulse')
                                        obj.inputs.condsAll.(conds{c,1}).(st).si_pckt{1,2}=0;
                                        obj.inputs.condsAll.(conds{c,1}).(st).si_pckt{1,3}=0;
                                    end
                                    if obj.inputs.condsAll.(conds{c,1}).(st).si_units==1
                                        obj.inputs.condsAll.(conds{c,1}).(st).si_pckt{1,4}=obj.inputs.condsAll.(conds{c,1}).(st).si_pckt{1,1};
                                    elseif obj.inputs.condsAll.(conds{c,1}).(st).si_units==0 && ~isempty(str2num(obj.inputs.condsAll.(conds{c,1}).(st).threshold)) && str2num(obj.inputs.condsAll.(conds{c,1}).(st).threshold)>0
                                        obj.inputs.condsAll.(conds{c,1}).(st).si_pckt{1,4}=round((obj.inputs.condsAll.(conds{c,1}).(st).si_pckt{1,1}*(str2num(obj.inputs.condsAll.(conds{c,1}).(st).threshold)))/100);
                                    end
                                    condSi{1,stno}=obj.inputs.condsAll.(conds{c,1}).(st).si_pckt;
                                    condstimMode{1,stno}= obj.inputs.condsAll.(conds{c,1}).(st).stim_mode;
                                    obj.inputs.condsAll.(conds{c,1}).(st).stim_device
                                    condoutputDevice{1,stno}=obj.inputs.condsAll.(conds{c,1}).(st).stim_device;
                                    for i=1:numel(obj.inputs.condsAll.(conds{c,1}).(st).stim_timing)
                                        condstimTimingStrings{1,i}=num2str(obj.inputs.condsAll.(conds{c,1}).(st).stim_timing{1,i});
                                    end
                                    condstimTiming{1,stno}=condstimTimingStrings;
                                end
                                obj.inputs.condMat(c,obj.inputs.colLabel.si)={condSi};
                                obj.inputs.condMat(c,obj.inputs.colLabel.outputDevices)={condoutputDevice};
                                obj.inputs.condMat(c,obj.inputs.colLabel.stimMode)={condstimMode};
                                %                         condstimTiming=condstimTiming{1,1};
                                %                         condstimTiming={{cellfun(@num2str, condstimTiming{1,1}(1,1:end))}};
                                %                                                 condstimTiming={{arrayfun(@num2str, condstimTiming{1,1}(1,1:end))}};
                                
                                %                         condstimTiming=cellstr(condstimTiming);
                                for timing=1:numel(condstimTiming)
                                    for jj=1:numel(condstimTiming{1,timing})
                                        condstimTiming{2,timing}{1,jj}=condoutputDevice{1,timing};
                                    end
                                end
                                condstimTiming_new{1}=horzcat(condstimTiming{1,:});
                                condstimTiming_new{2}=horzcat(condstimTiming{2,:});
                                [condstimTiming_new_sorted{1},sorted_idx]=sort(condstimTiming_new{1});
                                
                                %                                  [condstimTiming_new_sorted{1},sorted_idx]=sort(cellfun(@str2num, condstimTiming_new{1}));
                                %                                  condstimTiming_new_sorted{1}=cellfun(@num2str, num2cell(condstimTiming_new_sorted{1}));
                                
                                
                                
                                condstimTiming_new_sorted{2}=condstimTiming_new{1,2}(sorted_idx);
                                %                                  condstimTiming_new_sorted{1}=cellfun(@num2str, num2cell(condstimTiming_new_sorted{1}));
                                
                                for stimno_tpm=1:numel(condstimTiming_new_sorted{2})
                                    port_vector{stimno_tpm}=obj.app.par.hardware_settings.(char(condstimTiming_new_sorted{2}{1,stimno_tpm})).bb_outputport;
                                end
                                condstimTiming_new_sorted{2}=port_vector;
                                tpmVect=[condstimTiming_new_sorted{1};condstimTiming_new_sorted{2}];
                                [tpmVect_unique,ia,ic]=unique(tpmVect(1,:));
                                a_counts = accumarray(ic,1);
                                for binportloop=1:numel(tpmVect_unique)
                                    buffer{1,binportloop}={(cell2mat(tpmVect(2,ia(binportloop):ia(binportloop)-1+a_counts(binportloop))))};
                                    binaryZ='0000';
                                    num=cell2mat(buffer{1,binportloop});
                                    for binaryID=1:numel(num)
                                        binaryZ(str2num(num(binaryID)))='1';
                                    end
                                    buffer{1,binportloop}=bin2dec(flip(binaryZ));
                                    markers{1,binportloop}=0;
                                end
                                markers{1,1}=c;
                                condstimTiming_new_sorted=[num2cell((cellfun(@str2num, tpmVect_unique(1,1:end))));buffer;markers];
                                condstimTiming_new_sorted=cell2mat(condstimTiming_new_sorted);
                                [condstimTiming_new_sorted(1,:),sorted_idx]=sort(condstimTiming_new_sorted(1,:));
                                condstimTiming_new_sorted(1,:)=condstimTiming_new_sorted(1,:)/1000;
                                condstimTiming_new_sorted(2,:)=condstimTiming_new_sorted(2,sorted_idx);
                                
                                obj.inputs.condMat(c,obj.inputs.colLabel.tpm)={num2cell(condstimTiming_new_sorted)};
                                condSi=[];
                                condoutputDevice=[];
                                condstimMode=[];
                                condstimTiming=[];
                                buffer=[];
                                tpmVect_unique=[];
                                a_counts =[];
                                ia=[];
                                ic=[];
                                port_vector=[];
                                num=[];
                                condstimTiming_new=[];
                                condstimTiming_new_sorted=[];
                                sorted_idx=[];
                                markers=[];
                                condstimTimingStrings=[];
                            end
                            obj.app.pr.ax_ChannelLabels=[{'OsscillationPhase'},{'OsscillationEEG'},ChannelLabels{:},{'OsscillationAmplitude'},{'AmplitudeDistribution'},{'StatusTable'}];
                    end
                case 'rTMS Intervention Protocol'
                    switch obj.inputs.BrainState
                        case 1 %Independent
                            %% Adjusting New Arhictecture to Old Architecture
                            obj.inputs.output_device=obj.inputs.condsAll.cond1.st1.stim_device;
                            obj.inputs.input_device={'Utility'};
                            obj.inputs.stim_mode='MSO';
                            obj.inputs.measure_str='MEP Measurement';
                            obj.inputs.stop_event=0;
                            %% Creating Column Labels
                            obj.inputs.colLabel.inputDevices=1;
                            obj.inputs.colLabel.outputDevices=2;
                            obj.inputs.colLabel.si=3;
                            obj.inputs.colLabel.iti=4;
                            obj.inputs.colLabel.chLab=5;
                            obj.inputs.colLabel.trials=9;
                            obj.inputs.colLabel.axesno=6;
                            obj.inputs.colLabel.measures=7;
                            obj.inputs.colLabel.stimMode=8;
                            obj.inputs.colLabel.tpm=10;
                            obj.inputs.colLabel.chType=11;
                            obj.inputs.colLabel.chId=12;
                            obj.inputs.ChannelsTypeUnique={'StatusTable'};
                            obj.app.pr.ax_measures={'StatusTable'};
                            obj.app.pr.axesno=1;
                            obj.app.pr.ax_ChannelLabels={'StatusTable'};
                            %% Creating Stimulation Conditions
                            for c=1:numel(fieldnames(obj.inputs.condsAll))
                                obj.inputs.condMat{c,obj.inputs.colLabel.trials}=obj.inputs.TrialsPerCondition;
                                obj.inputs.condMat{c,obj.inputs.colLabel.iti}=obj.inputs.ITI;
                                obj.inputs.condMat{c,obj.inputs.colLabel.inputDevices}='Utility';
                                obj.inputs.condMat{c,obj.inputs.colLabel.chLab}={'StatusTable'};
                                obj.inputs.condMat{c,obj.inputs.colLabel.measures}={'StatusTable'};
                                obj.inputs.condMat{c,obj.inputs.colLabel.axesno}={1};
                                obj.inputs.condMat{c,obj.inputs.colLabel.chType}={'StatusTable'};
                                obj.inputs.condMat{c,obj.inputs.colLabel.chId}={1};
                                
                                
                                conds=fieldnames(obj.inputs.condsAll);
                                for stno=1:(max(size(fieldnames(obj.inputs.condsAll.(conds{c,1}))))-1)
                                    st=['st' num2str(stno)];
                                    condSi{1,stno}=obj.inputs.condsAll.(conds{c,1}).(st).si_pckt;
                                    condstimMode{1,stno}= obj.inputs.condsAll.(conds{c,1}).(st).stim_mode;
                                    obj.inputs.condsAll.(conds{c,1}).(st).stim_device
                                    condoutputDevice{1,stno}=obj.inputs.condsAll.(conds{c,1}).(st).stim_device;
                                    for i=1:numel(obj.inputs.condsAll.(conds{c,1}).(st).stim_timing)
                                        condstimTimingStrings{1,i}=num2str(obj.inputs.condsAll.(conds{c,1}).(st).stim_timing{1,i});
                                    end
                                    condstimTiming{1,stno}=condstimTimingStrings;
                                end
                                obj.inputs.condMat(c,obj.inputs.colLabel.si)={condSi};
                                obj.inputs.condMat(c,obj.inputs.colLabel.outputDevices)={condoutputDevice};
                                obj.inputs.condMat(c,obj.inputs.colLabel.stimMode)={condstimMode};
                                %                         condstimTiming=condstimTiming{1,1};
                                %                         condstimTiming={{cellfun(@num2str, condstimTiming{1,1}(1,1:end))}};
                                %                                                 condstimTiming={{arrayfun(@num2str, condstimTiming{1,1}(1,1:end))}};
                                
                                %                         condstimTiming=cellstr(condstimTiming);
                                for timing=1:numel(condstimTiming)
                                    for jj=1:numel(condstimTiming{1,timing})
                                        condstimTiming{2,timing}{1,jj}=condoutputDevice{1,timing};
                                    end
                                end
                                condstimTiming_new{1}=horzcat(condstimTiming{1,:});
                                condstimTiming_new{2}=horzcat(condstimTiming{2,:});
                                [condstimTiming_new_sorted{1},sorted_idx]=sort(condstimTiming_new{1});
                                
                                %                                  [condstimTiming_new_sorted{1},sorted_idx]=sort(cellfun(@str2num, condstimTiming_new{1}));
                                %                                  condstimTiming_new_sorted{1}=cellfun(@num2str, num2cell(condstimTiming_new_sorted{1}));
                                
                                
                                
                                condstimTiming_new_sorted{2}=condstimTiming_new{1,2}(sorted_idx);
                                %                                  condstimTiming_new_sorted{1}=cellfun(@num2str, num2cell(condstimTiming_new_sorted{1}));
                                
                                for stimno_tpm=1:numel(condstimTiming_new_sorted{2})
                                    port_vector{stimno_tpm}=obj.app.par.hardware_settings.(char(condstimTiming_new_sorted{2}{1,stimno_tpm})).bb_outputport;
                                end
                                condstimTiming_new_sorted{2}=port_vector;
                                tpmVect=[condstimTiming_new_sorted{1};condstimTiming_new_sorted{2}];
                                [tpmVect_unique,ia,ic]=unique(tpmVect(1,:));
                                a_counts = accumarray(ic,1);
                                for binportloop=1:numel(tpmVect_unique)
                                    buffer{1,binportloop}={(cell2mat(tpmVect(2,ia(binportloop):ia(binportloop)-1+a_counts(binportloop))))};
                                    binaryZ='0000';
                                    num=cell2mat(buffer{1,binportloop});
                                    for binaryID=1:numel(num)
                                        binaryZ(str2num(num(binaryID)))='1';
                                    end
                                    buffer{1,binportloop}=bin2dec(flip(binaryZ));
                                    markers{1,binportloop}=0;
                                end
                                markers{1,1}=c;
                                condstimTiming_new_sorted=[num2cell((cellfun(@str2num, tpmVect_unique(1,1:end))));buffer;markers];
                                condstimTiming_new_sorted=cell2mat(condstimTiming_new_sorted)
                                [condstimTiming_new_sorted(1,:),sorted_idx]=sort(condstimTiming_new_sorted(1,:))
                                condstimTiming_new_sorted(1,:)=condstimTiming_new_sorted(1,:)/1000;
                                condstimTiming_new_sorted(2,:)=condstimTiming_new_sorted(2,sorted_idx)
                                
                                obj.inputs.condMat(c,obj.inputs.colLabel.tpm)={num2cell(condstimTiming_new_sorted)};
                                condSi=[];
                                condoutputDevice=[];
                                condstimMode=[];
                                condstimTiming=[];
                                buffer=[];
                                tpmVect_unique=[];
                                a_counts =[];
                                ia=[];
                                ic=[];
                                port_vector=[];
                                num=[];
                                condstimTiming_new=[];
                                condstimTiming_new_sorted=[];
                                sorted_idx=[];
                                markers=[];
                                condstimTimingStrings=[];
                            end
                        case 2 %Dependent
                            %% Adjusting New Arhictecture to Old Architecture
                            obj.inputs.output_device=obj.inputs.condsAll.cond1.st1.stim_device;
                            obj.inputs.input_device=obj.app.pi.rtms.InputDevice.String(obj.inputs.InputDevice);
                            obj.inputs.stim_mode='MSO';
                            obj.inputs.measure_str='MEP Measurement';
                            obj.inputs.stop_event=0;
                            % These below have to be adjusted in Future Release
                            obj.inputs.prestim_scope_plt=50;
                            obj.inputs.poststim_scope_plt=150;
                            obj.inputs.mep_onset=15;
                            obj.inputs.mep_offset=50;
                            %% Creating Column Labels
                            obj.inputs.colLabel.inputDevices=1;
                            obj.inputs.colLabel.outputDevices=2;
                            obj.inputs.colLabel.si=3;
                            obj.inputs.colLabel.iti=4;
                            obj.inputs.colLabel.chLab=5;
                            obj.inputs.colLabel.trials=9;
                            obj.inputs.colLabel.axesno=6;
                            obj.inputs.colLabel.measures=7;
                            obj.inputs.colLabel.stimMode=8;
                            obj.inputs.colLabel.tpm=10;
                            obj.inputs.colLabel.chType=11;
                            obj.inputs.colLabel.chId=12;
                            obj.inputs.colLabel.phase=13;
                            obj.inputs.colLabel.IA=14;
                            if obj.inputs.AmplitudeUnits==1
                                obj.inputs.colLabel.IAPercentile=15;
                            end
                            obj.inputs.ChannelsTypeUnique={'StatusTable'};
                            obj.app.pr.ax_measures={'StatusTable'};
                            obj.app.pr.axesno=1;
                            obj.app.pr.ax_ChannelLabels={'StatusTable'};
                            %% Creating Stimulation Conditions
                            for c=1:numel(fieldnames(obj.inputs.condsAll))
                                obj.inputs.condMat{c,obj.inputs.colLabel.trials}=obj.inputs.TrialsPerCondition;
                                obj.inputs.condMat{c,obj.inputs.colLabel.iti}=obj.inputs.ITI;
                                obj.inputs.condMat{c,obj.inputs.colLabel.inputDevices}=char(obj.app.pi.rtms.InputDevice.String(obj.inputs.InputDevice));
                                obj.inputs.condMat{c,obj.inputs.colLabel.chLab}={'StatusTable'};
                                obj.inputs.condMat{c,obj.inputs.colLabel.measures}={'StatusTable'};
                                obj.inputs.condMat{c,obj.inputs.colLabel.axesno}={1};
                                obj.inputs.condMat{c,obj.inputs.colLabel.chType}={'StatusTable'};
                                obj.inputs.condMat{c,obj.inputs.colLabel.chId}={1};
                                
                                conds=fieldnames(obj.inputs.condsAll);
                                for stno=1:(max(size(fieldnames(obj.inputs.condsAll.(conds{c,1}))))-1)
                                    st=['st' num2str(stno)];
                                    condSi{1,stno}=obj.inputs.condsAll.(conds{c,1}).(st).si_pckt;
                                    condstimMode{1,stno}= obj.inputs.condsAll.(conds{c,1}).(st).stim_mode;
                                    obj.inputs.condsAll.(conds{c,1}).(st).stim_device
                                    condoutputDevice{1,stno}=obj.inputs.condsAll.(conds{c,1}).(st).stim_device;
                                    for i=1:numel(obj.inputs.condsAll.(conds{c,1}).(st).stim_timing)
                                        condstimTimingStrings{1,i}=num2str(obj.inputs.condsAll.(conds{c,1}).(st).stim_timing{1,i});
                                    end
                                    condstimTiming{1,stno}=condstimTimingStrings;
                                end
                                obj.inputs.condMat(c,obj.inputs.colLabel.si)={condSi};
                                obj.inputs.condMat(c,obj.inputs.colLabel.outputDevices)={condoutputDevice};
                                obj.inputs.condMat(c,obj.inputs.colLabel.stimMode)={condstimMode};
                                %                         condstimTiming=condstimTiming{1,1};
                                %                         condstimTiming={{cellfun(@num2str, condstimTiming{1,1}(1,1:end))}};
                                %                                                 condstimTiming={{arrayfun(@num2str, condstimTiming{1,1}(1,1:end))}};
                                
                                %                         condstimTiming=cellstr(condstimTiming);
                                for timing=1:numel(condstimTiming)
                                    for jj=1:numel(condstimTiming{1,timing})
                                        condstimTiming{2,timing}{1,jj}=condoutputDevice{1,timing};
                                    end
                                end
                                condstimTiming_new{1}=horzcat(condstimTiming{1,:});
                                condstimTiming_new{2}=horzcat(condstimTiming{2,:});
                                [condstimTiming_new_sorted{1},sorted_idx]=sort(condstimTiming_new{1});
                                
                                %                                  [condstimTiming_new_sorted{1},sorted_idx]=sort(cellfun(@str2num, condstimTiming_new{1}));
                                %                                  condstimTiming_new_sorted{1}=cellfun(@num2str, num2cell(condstimTiming_new_sorted{1}));
                                
                                
                                
                                condstimTiming_new_sorted{2}=condstimTiming_new{1,2}(sorted_idx);
                                %                                  condstimTiming_new_sorted{1}=cellfun(@num2str, num2cell(condstimTiming_new_sorted{1}));
                                
                                for stimno_tpm=1:numel(condstimTiming_new_sorted{2})
                                    port_vector{stimno_tpm}=obj.app.par.hardware_settings.(char(condstimTiming_new_sorted{2}{1,stimno_tpm})).bb_outputport;
                                end
                                condstimTiming_new_sorted{2}=port_vector;
                                tpmVect=[condstimTiming_new_sorted{1};condstimTiming_new_sorted{2}];
                                [tpmVect_unique,ia,ic]=unique(tpmVect(1,:));
                                a_counts = accumarray(ic,1);
                                for binportloop=1:numel(tpmVect_unique)
                                    buffer{1,binportloop}={(cell2mat(tpmVect(2,ia(binportloop):ia(binportloop)-1+a_counts(binportloop))))};
                                    binaryZ='0000';
                                    num=cell2mat(buffer{1,binportloop});
                                    for binaryID=1:numel(num)
                                        binaryZ(str2num(num(binaryID)))='1';
                                    end
                                    buffer{1,binportloop}=bin2dec(flip(binaryZ));
                                    markers{1,binportloop}=0;
                                end
                                markers{1,1}=c;
                                condstimTiming_new_sorted=[num2cell((cellfun(@str2num, tpmVect_unique(1,1:end))));buffer;markers];
                                condstimTiming_new_sorted=cell2mat(condstimTiming_new_sorted)
                                [condstimTiming_new_sorted(1,:),sorted_idx]=sort(condstimTiming_new_sorted(1,:))
                                condstimTiming_new_sorted(1,:)=condstimTiming_new_sorted(1,:)/1000;
                                condstimTiming_new_sorted(2,:)=condstimTiming_new_sorted(2,sorted_idx)
                                
                                obj.inputs.condMat(c,obj.inputs.colLabel.tpm)={num2cell(condstimTiming_new_sorted)};
                                condSi=[];
                                condoutputDevice=[];
                                condstimMode=[];
                                condstimTiming=[];
                                buffer=[];
                                tpmVect_unique=[];
                                a_counts =[];
                                ia=[];
                                ic=[];
                                port_vector=[];
                                num=[];
                                condstimTiming_new=[];
                                condstimTiming_new_sorted=[];
                                sorted_idx=[];
                                markers=[];
                                condstimTimingStrings=[];
                            end
                    end
                case 'rs EEG Measurement Protocol'
                    switch obj.inputs.SpectralAnalysis
                        case 1 %IRASA
                            obj.app.pr.ax_measures=repmat({'rsEEGMeasurement'},1,4*(numel(obj.inputs.MontageChannels)));
                            obj.app.pr.axesno=numel(obj.app.pr.ax_measures);
                            for i=1:numel(obj.inputs.MontageChannels)
                                FractalOriginalChannelLabel=['Fractal & Original Power Spectrum - '];
                                OscillationChannelLabel=['Oscillation Power Spectrum - ' ];
                                PercentageChangeChannelLabel=['Oscillation/Fractal Change - ' ];
                                dBChannelLabel=['Oscillation/Fractal dB - ' ];
                                obj.app.pr.ax_ChannelLabels_0(4*i-3)={FractalOriginalChannelLabel};
                                obj.app.pr.ax_ChannelLabels_0(4*i-2)={OscillationChannelLabel};
                                obj.app.pr.ax_ChannelLabels_0(4*i-1)={PercentageChangeChannelLabel};
                                obj.app.pr.ax_ChannelLabels_0(4*i)={dBChannelLabel};
                                obj.app.pr.ax_ChannelLabels(4*i-3)= {erase(char(join(obj.inputs.MontageChannels{i})),' ')};
                                obj.app.pr.ax_ChannelLabels(4*i-2)={erase(char(join(obj.inputs.MontageChannels{i})),' ')};
                                obj.app.pr.ax_ChannelLabels(4*i-1)={erase(char(join(obj.inputs.MontageChannels{i})),' ')};
                                obj.app.pr.ax_ChannelLabels(4*i)={erase(char(join(obj.inputs.MontageChannels{i})),' ')};
                            end
                            obj.inputs.ChannelsTypeUnique={'EEG'};
                            obj.inputs.input_device=char(obj.app.pi.rseeg.InputDevice.String(obj.inputs.InputDevice));
                            obj.inputs.colLabel.inputDevices=1;
                            obj.inputs.colLabel.iti=2;
                            obj.inputs.condMat{1,obj.inputs.colLabel.inputDevices}=char(obj.app.pi.rseeg.InputDevice.String(obj.inputs.InputDevice));
                            obj.inputs.condMat{1,obj.inputs.colLabel.iti}=NaN;
                            obj.inputs.trialMat={};
                            obj.inputs.Figures={};
                        case 2 %FFT
                            obj.app.pr.ax_measures=repmat({'rsEEGMeasurement'},1,(numel(obj.inputs.MontageChannels)));
                            obj.app.pr.axesno=numel(obj.app.pr.ax_measures);
                            for i=1:numel(obj.inputs.MontageChannels)
                                ChannelLabel=['Power Spectrum - '];
                                obj.app.pr.ax_ChannelLabels_0(i)={ChannelLabel};
                                obj.app.pr.ax_ChannelLabels(i)={erase(char(join(obj.inputs.MontageChannels{i})),' ')};
                            end
                            obj.inputs.ChannelsTypeUnique={'EEG'};
                            obj.inputs.input_device=char(obj.app.pi.rseeg.InputDevice.String(obj.inputs.InputDevice));
                            obj.inputs.colLabel.inputDevices=1;
                            obj.inputs.colLabel.iti=2;
                            obj.inputs.condMat{1,obj.inputs.colLabel.inputDevices}=char(obj.app.pi.rseeg.InputDevice.String(obj.inputs.InputDevice));
                            obj.inputs.condMat{1,obj.inputs.colLabel.iti}=NaN;
                            obj.inputs.trialMat={};
                            obj.inputs.Figures={};
                    end
                case 'TEP Hotspot Search Protocol'
                    %% Adjusting New Arhictecture to Old Architecture
                    obj.inputs.input_device=char(obj.app.pi.tephs.InputDevice.String(obj.inputs.InputDevice)); %TODO: the drc or mep on the 4th structure is not a good solution!
                    obj.inputs.output_device=obj.app.pi.tephs.OutputDevice.String(obj.inputs.OutputDevice);
                    obj.inputs.stim_mode='MSO';
                    obj.inputs.measure_str='Motor Hotspot Search';
                    obj.inputs.stop_event=0;
                    obj.inputs.ylimMin=-3000;
                    obj.inputs.ylimMax=+3000;
                    obj.inputs.TrialNoForMean=1;
                    %% Creating Column Labels
                    obj.inputs.colLabel.inputDevices=1;
                    obj.inputs.colLabel.outputDevices=2;
                    obj.inputs.colLabel.si=3;
                    obj.inputs.colLabel.iti=4;
                    obj.inputs.colLabel.chLab=5;
                    obj.inputs.colLabel.trials=9;
                    obj.inputs.colLabel.axesno=6;
                    obj.inputs.colLabel.measures=7;
                    obj.inputs.colLabel.stimMode=8;
                    obj.inputs.colLabel.tpm=10;
                    obj.inputs.colLabel.chType=11;
                    obj.inputs.colLabel.chId=12;
                    %% Creating Channel Type and Channel ID
                    switch obj.app.par.hardware_settings.(char(obj.inputs.input_device)).slct_device
                        case 1 %boss box
                            
                            DisplayChannelType=cell(1,1);
                            DisplayChannelType(:)=cellstr('EEG');
                            DisplayChannelID=num2cell(1:1);
                            obj.inputs.ChannelsTypeUnique=DisplayChannelType;
                            
                        case 2 % fieldtrip real time buffer
                    end
                    %% Creating Channel Measures, Axes No
                    obj.app.pr.ax_measures={'TEP Measurement','TEP Measurement','TEP Measurement','TEP Measurement','StatusTable'};
                    obj.app.pr.axesno=5;
                    obj.app.pr.ax_ChannelLabels={'Vertical Plot',obj.inputs.TargetChannels,'TopoplotER','MultiplotER','StatusTable'};
                    obj.inputs.Figures=cell(1,obj.app.pr.axesno);
                    %% Creating Configuration
                    if(obj.inputs.EEGDisplayPeriod(1)<0)
                        obj.inputs.Configuration.detrend='yes';
                        obj.inputs.Configuration.demean='yes';
                        obj.inputs.Configuration.baselinewindow=[obj.inputs.EEGDisplayPeriod(1)/1000 0];
                    end
                    if ~isempty(obj.inputs.ReferenceChannels)
                        obj.inputs.Configuration.reref='yes';
                        obj.inputs.Configuration.refchannel=obj.inputs.ReferenceChannels;
                    end
                    %% Creating Stimulation Conditions
                    for c=1:numel(fieldnames(obj.inputs.condsAll))
                        obj.inputs.condMat{c,obj.inputs.colLabel.trials}=obj.inputs.TrialsPerCondition;
                        obj.inputs.condMat{c,obj.inputs.colLabel.iti}=obj.inputs.ITI;
                        obj.inputs.condMat{c,obj.inputs.colLabel.inputDevices}=char(obj.app.pi.tephs.InputDevice.String(obj.inputs.InputDevice));
                        obj.inputs.condMat{c,obj.inputs.colLabel.chLab}={'TEP','TEP','TEP','TEP','StatusTable'};
                        obj.inputs.condMat{c,obj.inputs.colLabel.measures}={'TEP Measurement Vertical Plot','TEP Measurement Single Plot','TEP Measurement Topo Plot','TEP Measurement Multi Plot','StatusTable'};
                        obj.inputs.condMat{c,obj.inputs.colLabel.axesno}={1,2,3,4,5};
                        obj.inputs.condMat{c,obj.inputs.colLabel.chType}={'EEG','EEG','EEG','EEG','StatusTable'};
                        obj.inputs.condMat{c,obj.inputs.colLabel.chId}={1,1,1,1,1};
                        conds=fieldnames(obj.inputs.condsAll);
                        for stno=1:(max(size(fieldnames(obj.inputs.condsAll.(conds{c,1}))))-1)
                            st=['st' num2str(stno)];
                            condSi{1,stno}=obj.inputs.condsAll.(conds{c,1}).(st).si_pckt;
                            condstimMode{1,stno}= obj.inputs.condsAll.(conds{c,1}).(st).stim_mode;
                            obj.inputs.condsAll.(conds{c,1}).(st).stim_device
                            condoutputDevice{1,stno}=char(obj.inputs.output_device);
                            for i=1:numel(obj.inputs.condsAll.(conds{c,1}).(st).stim_timing)
                                condstimTimingStrings{1,i}=num2str(obj.inputs.condsAll.(conds{c,1}).(st).stim_timing{1,i});
                            end
                            condstimTiming{1,stno}=condstimTimingStrings;
                        end
                        obj.inputs.condMat(c,obj.inputs.colLabel.si)={condSi};
                        obj.inputs.condMat(c,obj.inputs.colLabel.outputDevices)={condoutputDevice};
                        obj.inputs.condMat(c,obj.inputs.colLabel.stimMode)={condstimMode};
                        %                         condstimTiming=condstimTiming{1,1};
                        %                         condstimTiming={{cellfun(@num2str, condstimTiming{1,1}(1,1:end))}};
                        %                                                 condstimTiming={{arrayfun(@num2str, condstimTiming{1,1}(1,1:end))}};
                        
                        %                         condstimTiming=cellstr(condstimTiming);
                        for timing=1:numel(condstimTiming)
                            for jj=1:numel(condstimTiming{1,timing})
                                condstimTiming{2,timing}{1,jj}=condoutputDevice{1,timing};
                            end
                        end
                        condstimTiming_new{1}=horzcat(condstimTiming{1,:});
                        condstimTiming_new{2}=horzcat(condstimTiming{2,:});
                        [condstimTiming_new_sorted{1},sorted_idx]=sort(condstimTiming_new{1});
                        
                        %                                  [condstimTiming_new_sorted{1},sorted_idx]=sort(cellfun(@str2num, condstimTiming_new{1}));
                        %                                  condstimTiming_new_sorted{1}=cellfun(@num2str, num2cell(condstimTiming_new_sorted{1}));
                        
                        
                        
                        condstimTiming_new_sorted{2}=condstimTiming_new{1,2}(sorted_idx);
                        %                                  condstimTiming_new_sorted{1}=cellfun(@num2str, num2cell(condstimTiming_new_sorted{1}));
                        
                        for stimno_tpm=1:numel(condstimTiming_new_sorted{2})
                            port_vector{stimno_tpm}=obj.app.par.hardware_settings.(char(condstimTiming_new_sorted{2}{1,stimno_tpm})).bb_outputport;
                        end
                        condstimTiming_new_sorted{2}=port_vector;
                        tpmVect=[condstimTiming_new_sorted{1};condstimTiming_new_sorted{2}];
                        [tpmVect_unique,ia,ic]=unique(tpmVect(1,:));
                        a_counts = accumarray(ic,1);
                        for binportloop=1:numel(tpmVect_unique)
                            buffer{1,binportloop}={(cell2mat(tpmVect(2,ia(binportloop):ia(binportloop)-1+a_counts(binportloop))))};
                            binaryZ='0000';
                            num=cell2mat(buffer{1,binportloop});
                            for binaryID=1:numel(num)
                                binaryZ(str2num(num(binaryID)))='1';
                            end
                            buffer{1,binportloop}=bin2dec(flip(binaryZ));
                            markers{1,binportloop}=0;
                        end
                        markers{1,1}=c;
                        condstimTiming_new_sorted=[num2cell((cellfun(@str2num, tpmVect_unique(1,1:end))));buffer;markers];
                        condstimTiming_new_sorted=cell2mat(condstimTiming_new_sorted)
                        [condstimTiming_new_sorted(1,:),sorted_idx]=sort(condstimTiming_new_sorted(1,:))
                        condstimTiming_new_sorted(1,:)=condstimTiming_new_sorted(1,:)/1000;
                        condstimTiming_new_sorted(2,:)=condstimTiming_new_sorted(2,sorted_idx)
                        
                        obj.inputs.condMat(c,obj.inputs.colLabel.tpm)={num2cell(condstimTiming_new_sorted)};
                        condSi=[];
                        condoutputDevice=[];
                        condstimMode=[];
                        condstimTiming=[];
                        buffer=[];
                        tpmVect_unique=[];
                        a_counts =[];
                        ia=[];
                        ic=[];
                        port_vector=[];
                        num=[];
                        condstimTiming_new=[];
                        condstimTiming_new_sorted=[];
                        sorted_idx=[];
                        markers=[];
                        condstimTimingStrings=[];
                    end
                case 'ERP Measurement Protocol'
                    %% Adjusting New Arhictecture to Old Architecture
                    obj.inputs.input_device=char(obj.app.pi.erp.InputDevice.String(obj.inputs.InputDevice)); %TODO: the drc or mep on the 4th structure is not a good solution!
                    obj.inputs.output_device=obj.inputs.condsAll.cond1.st1.stim_device;
                    obj.inputs.SEPOnset=obj.inputs.SEPSearchWindow(1);
                    obj.inputs.SEPOffset=obj.inputs.SEPSearchWindow(2);
                    obj.inputs.EEGDisplayPeriodPre=obj.inputs.EEGExtractionPeriod(1)*(-1);
                    obj.inputs.EEGDisplayPeriodPost=obj.inputs.EEGExtractionPeriod(2);
                    obj.inputs.stim_mode='MSO';
                    obj.inputs.measure_str='ERP Measurement Protocol';
                    obj.inputs.stop_event=0;
                    obj.inputs.ylimMin=-3000;
                    obj.inputs.ylimMax=+3000;
                    obj.inputs.TrialNoForMean=1;
                    %% Creating Column Labels
                    obj.inputs.colLabel.inputDevices=1;
                    obj.inputs.colLabel.outputDevices=2;
                    obj.inputs.colLabel.si=3;
                    obj.inputs.colLabel.iti=4;
                    obj.inputs.colLabel.chLab=5;
                    obj.inputs.colLabel.trials=9;
                    obj.inputs.colLabel.axesno=6;
                    obj.inputs.colLabel.measures=7;
                    obj.inputs.colLabel.stimMode=8;
                    obj.inputs.colLabel.tpm=10;
                    obj.inputs.colLabel.chType=11;
                    obj.inputs.colLabel.chId=12;
                    %% Creating Channel Type and Channel ID
                    switch obj.app.par.hardware_settings.(char(obj.inputs.input_device)).slct_device
                        case 1 %boss box
                            
                            DisplayChannelType=cell(1,1);
                            DisplayChannelType(:)=cellstr('EEG');
                            DisplayChannelID=num2cell(1:1);
                            obj.inputs.ChannelsTypeUnique=DisplayChannelType;
                            
                        case 2 % fieldtrip real time buffer
                    end
                    %% Creating Channel Measures, Axes No
%                     obj.app.pr.ax_measures={'TEP Measurement','TEP Measurement','TEP Measurement','StatusTable'};
%                     obj.app.pr.axesno=4;
%                     obj.app.pr.ax_ChannelLabels={obj.inputs.MontageChannels,'TopoplotER','MultiplotER','StatusTable'};
                    obj.app.pr.ax_measures={'TEP Measurement','StatusTable'};
                    obj.app.pr.axesno=2;
                    obj.app.pr.ax_ChannelLabels=[obj.inputs.MontageChannels,{'StatusTable'}];
                    obj.inputs.Figures=cell(1,obj.app.pr.axesno);
                    %% Creating Stimulation Conditions
                    for c=1:numel(fieldnames(obj.inputs.condsAll))
                        obj.inputs.condMat{c,obj.inputs.colLabel.trials}=obj.inputs.TrialsPerCondition;
                        obj.inputs.condMat{c,obj.inputs.colLabel.iti}=obj.inputs.ITI;
                        obj.inputs.condMat{c,obj.inputs.colLabel.inputDevices}=char(obj.app.pi.erp.InputDevice.String(obj.inputs.InputDevice));
%                         obj.inputs.condMat{c,obj.inputs.colLabel.chLab}={'TEP','TEP','TEP','StatusTable'};
%                         obj.inputs.condMat{c,obj.inputs.colLabel.measures}={'TEP Measurement Single Plot','TEP Measurement Topo Plot','TEP Measurement Multi Plot','StatusTable'};
%                         obj.inputs.condMat{c,obj.inputs.colLabel.axesno}={1,2,3,4};
%                         obj.inputs.condMat{c,obj.inputs.colLabel.chType}={'EEG','EEG','EEG','StatusTable'};
%                         obj.inputs.condMat{c,obj.inputs.colLabel.chId}={1,1,1,1};
                        obj.inputs.condMat{c,obj.inputs.colLabel.chLab}={'TEP','StatusTable'};
                        obj.inputs.condMat{c,obj.inputs.colLabel.measures}={'TEP Measurement Single Plot','StatusTable'};
                        obj.inputs.condMat{c,obj.inputs.colLabel.axesno}={1,2};
                        obj.inputs.condMat{c,obj.inputs.colLabel.chType}={'EEG','StatusTable'};
                        obj.inputs.condMat{c,obj.inputs.colLabel.chId}={1,1};
                        conds=fieldnames(obj.inputs.condsAll);
                        for stno=1:(max(size(fieldnames(obj.inputs.condsAll.(conds{c,1}))))-1)
                            st=['st' num2str(stno)];
                            if(obj.inputs.condsAll.(conds{c,1}).(st).stim_mode=='single_pulse')
                                obj.inputs.condsAll.(conds{c,1}).(st).si_pckt{1,2}=0;
                                obj.inputs.condsAll.(conds{c,1}).(st).si_pckt{1,3}=0;
                            end
                            if obj.inputs.condsAll.(conds{c,1}).(st).si_units==1
                                obj.inputs.condsAll.(conds{c,1}).(st).si_pckt{1,4}=obj.inputs.condsAll.(conds{c,1}).(st).si_pckt{1,1};
                            elseif obj.inputs.condsAll.(conds{c,1}).(st).si_units==0 && ~isempty(str2num(obj.inputs.condsAll.(conds{c,1}).(st).threshold)) && str2num(obj.inputs.condsAll.(conds{c,1}).(st).threshold)>0
                                obj.inputs.condsAll.(conds{c,1}).(st).si_pckt{1,4}=round((obj.inputs.condsAll.(conds{c,1}).(st).si_pckt{1,1}*(str2num(obj.inputs.condsAll.(conds{c,1}).(st).threshold)))/100);
                            end
                            condSi{1,stno}=obj.inputs.condsAll.(conds{c,1}).(st).si_pckt;
                            condstimMode{1,stno}= obj.inputs.condsAll.(conds{c,1}).(st).stim_mode;
                            obj.inputs.condsAll.(conds{c,1}).(st).stim_device
                            condoutputDevice{1,stno}=obj.inputs.condsAll.(conds{c,1}).(st).stim_device;
                            for i=1:numel(obj.inputs.condsAll.(conds{c,1}).(st).stim_timing)
                                condstimTimingStrings{1,i}=num2str(obj.inputs.condsAll.(conds{c,1}).(st).stim_timing{1,i});
                            end
                            condstimTiming{1,stno}=condstimTimingStrings;
                        end
                        obj.inputs.condMat(c,obj.inputs.colLabel.si)={condSi};
                        obj.inputs.condMat(c,obj.inputs.colLabel.outputDevices)={condoutputDevice};
                        obj.inputs.condMat(c,obj.inputs.colLabel.stimMode)={condstimMode};
                        %                         condstimTiming=condstimTiming{1,1};
                        %                         condstimTiming={{cellfun(@num2str, condstimTiming{1,1}(1,1:end))}};
                        %                                                 condstimTiming={{arrayfun(@num2str, condstimTiming{1,1}(1,1:end))}};
                        
                        %                         condstimTiming=cellstr(condstimTiming);
                        for timing=1:numel(condstimTiming)
                            for jj=1:numel(condstimTiming{1,timing})
                                condstimTiming{2,timing}{1,jj}=condoutputDevice{1,timing};
                            end
                        end
                        condstimTiming_new{1}=horzcat(condstimTiming{1,:});
                        condstimTiming_new{2}=horzcat(condstimTiming{2,:});
                        [condstimTiming_new_sorted{1},sorted_idx]=sort(condstimTiming_new{1});
                        
                        %                                  [condstimTiming_new_sorted{1},sorted_idx]=sort(cellfun(@str2num, condstimTiming_new{1}));
                        %                                  condstimTiming_new_sorted{1}=cellfun(@num2str, num2cell(condstimTiming_new_sorted{1}));
                        
                        
                        
                        condstimTiming_new_sorted{2}=condstimTiming_new{1,2}(sorted_idx);
                        %                                  condstimTiming_new_sorted{1}=cellfun(@num2str, num2cell(condstimTiming_new_sorted{1}));
                        
                        for stimno_tpm=1:numel(condstimTiming_new_sorted{2})
                            port_vector{stimno_tpm}=obj.app.par.hardware_settings.(char(condstimTiming_new_sorted{2}{1,stimno_tpm})).bb_outputport;
                        end
                        condstimTiming_new_sorted{2}=port_vector;
                        tpmVect=[condstimTiming_new_sorted{1};condstimTiming_new_sorted{2}];
                        [tpmVect_unique,ia,ic]=unique(tpmVect(1,:));
                        a_counts = accumarray(ic,1);
                        for binportloop=1:numel(tpmVect_unique)
                            buffer{1,binportloop}={(cell2mat(tpmVect(2,ia(binportloop):ia(binportloop)-1+a_counts(binportloop))))};
                            binaryZ='0000';
                            num=cell2mat(buffer{1,binportloop});
                            for binaryID=1:numel(num)
                                binaryZ(str2num(num(binaryID)))='1';
                            end
                            buffer{1,binportloop}=bin2dec(flip(binaryZ));
                            markers{1,binportloop}=0;
                        end
                        markers{1,1}=c;
                        condstimTiming_new_sorted=[num2cell((cellfun(@str2num, tpmVect_unique(1,1:end))));buffer;markers];
                        condstimTiming_new_sorted=cell2mat(condstimTiming_new_sorted)
                        [condstimTiming_new_sorted(1,:),sorted_idx]=sort(condstimTiming_new_sorted(1,:))
                        condstimTiming_new_sorted(1,:)=condstimTiming_new_sorted(1,:)/1000;
                        condstimTiming_new_sorted(2,:)=condstimTiming_new_sorted(2,sorted_idx)
                        
                        obj.inputs.condMat(c,obj.inputs.colLabel.tpm)={num2cell(condstimTiming_new_sorted)};
                        condSi=[];
                        condoutputDevice=[];
                        condstimMode=[];
                        condstimTiming=[];
                        buffer=[];
                        tpmVect_unique=[];
                        a_counts =[];
                        ia=[];
                        ic=[];
                        port_vector=[];
                        num=[];
                        condstimTiming_new=[];
                        condstimTiming_new_sorted=[];
                        sorted_idx=[];
                        markers=[];
                        condstimTimingStrings=[];
                    end
            end
            %% Crossing Phase & Amplitude Condition with condMat
            if isfield(obj.inputs,'BrainState')
                if obj.inputs.BrainState==2
                    %% Creating Phase Conditions
                    PhaseConditionVector=cell(1,numel(obj.inputs.Phase));
                    for iPhases=1:numel(obj.inputs.Phase)
                        switch obj.inputs.Phase(iPhases)
                            case 0 %+Ve Peak
                                PhaseConditionVector{iPhases}={0,obj.inputs.PhaseTolerance};
                            case pi %-Ve Trough
                                PhaseConditionVector{iPhases}={pi,obj.inputs.PhaseTolerance};
                            case -pi/2 %Rising Flank
                                PhaseConditionVector{iPhases}={-pi/2,obj.inputs.PhaseTolerance};
                            case pi/2 %Falling Flank
                                PhaseConditionVector{iPhases}={pi/2,obj.inputs.PhaseTolerance};
                            otherwise % NaN Value and Random Phase
                                PhaseConditionVector{iPhases}={0,pi};
                        end
                    end
                    %% Crossing Phase and Amplitude Conditions with Stimulation Conditions
                    idx_stimulationconditions=0;
                    idx_totalstimulationconditions=numel(obj.inputs.condMat(:,1));
                    if numel(obj.inputs.AmplitudeThreshold)/2==numel(obj.inputs.Phase) || numel(obj.inputs.AmplitudeThreshold)/2==1
                        idx_phaseconditions=1;
                        TotalCrossedOverConditions=(numel(obj.inputs.Phase))*(numel(obj.inputs.condMat(:,1)));
                        for iTotalCrossedOverConditions=1:TotalCrossedOverConditions
                            idx_stimulationconditions=idx_stimulationconditions+1;
                            obj.inputs.condMat(iTotalCrossedOverConditions,1:12)=obj.inputs.condMat(idx_stimulationconditions,1:12);
                            obj.inputs.condMat(iTotalCrossedOverConditions,obj.inputs.colLabel.phase)=PhaseConditionVector(idx_phaseconditions);
                            if numel(obj.inputs.AmplitudeThreshold)/2==numel(obj.inputs.Phase)
                                obj.inputs.condMat(iTotalCrossedOverConditions,obj.inputs.colLabel.IA)={{obj.inputs.AmplitudeThreshold(idx_phaseconditions,1),obj.inputs.AmplitudeThreshold(idx_phaseconditions,2)}};
                                if obj.inputs.AmplitudeUnits==1
                                    obj.inputs.condMat(iTotalCrossedOverConditions,obj.inputs.colLabel.IAPercentile)={{obj.inputs.AmplitudeThreshold(idx_phaseconditions,1),obj.inputs.AmplitudeThreshold(idx_phaseconditions,2)}}; end
                            elseif numel(obj.inputs.AmplitudeThreshold)/2==1
                                obj.inputs.condMat(iTotalCrossedOverConditions,obj.inputs.colLabel.IA)={{obj.inputs.AmplitudeThreshold(1,1),obj.inputs.AmplitudeThreshold(1,2)}};
                                if obj.inputs.AmplitudeUnits==1
                                    obj.inputs.condMat(iTotalCrossedOverConditions,obj.inputs.colLabel.IAPercentile)={{obj.inputs.AmplitudeThreshold(1,1),obj.inputs.AmplitudeThreshold(1,2)}}; end
                            end
                            if(idx_stimulationconditions>=idx_totalstimulationconditions)
                                idx_stimulationconditions=0;
                                idx_phaseconditions=idx_phaseconditions+1;
                                if(idx_phaseconditions>numel(PhaseConditionVector))
                                    idx_phaseconditions=1; end
                            end
                        end
                    elseif numel(obj.inputs.AmplitudeThreshold)/2>numel(obj.inputs.Phase) && numel(obj.inputs.Phase)==1
                        idx_amplitudeconditions=1;
                        TotalCrossedOverConditions=(numel(obj.inputs.AmplitudeThreshold)/2)*(numel(obj.inputs.condMat(:,1)));
                        for iTotalCrossedOverConditions=1:TotalCrossedOverConditions
                            idx_stimulationconditions=idx_stimulationconditions+1;
                            obj.inputs.condMat(iTotalCrossedOverConditions,1:12)=obj.inputs.condMat(idx_stimulationconditions,1:12);
                            obj.inputs.condMat(iTotalCrossedOverConditions,obj.inputs.colLabel.IA)={{obj.inputs.AmplitudeThreshold(idx_amplitudeconditions,1),obj.inputs.AmplitudeThreshold(idx_amplitudeconditions,2)}};
                            obj.inputs.condMat(iTotalCrossedOverConditions,obj.inputs.colLabel.phase)=PhaseConditionVector(1);
                            if obj.inputs.AmplitudeUnits==1
                                obj.inputs.condMat(iTotalCrossedOverConditions,obj.inputs.colLabel.IAPercentile)={{obj.inputs.AmplitudeThreshold(idx_amplitudeconditions,1),obj.inputs.AmplitudeThreshold(idx_amplitudeconditions,2)}}; end
                            if(idx_stimulationconditions>=idx_totalstimulationconditions)
                                idx_stimulationconditions=0;
                                idx_amplitudeconditions=idx_amplitudeconditions+1;
                                if(idx_amplitudeconditions>numel(obj.inputs.AmplitudeThreshold)/2)
                                    idx_amplitudeconditions=1; end
                            end
                        end
                    end
                end
            end
            %% Crossing ITI Condition with condMat
            if isfield(obj.inputs,'condMat')
                if iscell(obj.inputs.condMat{1,obj.inputs.colLabel.iti})
                    condMat={};
                    i=0;
                    ITI=obj.inputs.condMat{1,obj.inputs.colLabel.iti};
                    for iCond=1:numel(obj.inputs.condMat(:,1))
                        for iITI=1:numel(ITI)
                            i=i+1;
                            condMat(i,:)=obj.inputs.condMat(iCond,:);
                            condMat{i,obj.inputs.colLabel.iti}=ITI{1,iITI};
                        end
                    end
                    obj.inputs.condMat=condMat;
                end
                obj.inputs.totalConds=numel(obj.inputs.condMat(:,1));
            end
            %% Conversion from Pars2Inputs
            function cb_Pars2Inputs
                obj.inputs=obj.app.par.(obj.app.info.event.current_session).(obj.app.info.event.current_measure_fullstr);
                InputsFieldNames=fieldnames(obj.inputs);
                for iInputs=1:numel(InputsFieldNames)
                    if (isa(obj.inputs.(InputsFieldNames{iInputs}),'char'))
                        if (strcmp(InputsFieldNames{iInputs},'ReferenceChannels')) || (strcmp(InputsFieldNames{iInputs},'ITI')) || (strcmp(InputsFieldNames{iInputs},'EMGDisplayChannels')) || (strcmp(InputsFieldNames{iInputs},'EMGTargetChannels')) || (strcmp(InputsFieldNames{iInputs},'Phase')) || (strcmp(InputsFieldNames{iInputs},'PhaseTolerance')) || (strcmp(InputsFieldNames{iInputs},'MontageChannels')) || (strcmp(InputsFieldNames{iInputs},'AmplitudeThreshold'))|| (strcmp(InputsFieldNames{iInputs},'TargetChannels')) || (strcmp(InputsFieldNames{iInputs},'EEGDisplayPeriod')) ...
                                || (strcmp(InputsFieldNames{iInputs},'RealTimeChannelsMontage')) || (strcmp(InputsFieldNames{iInputs},'MontageWeights')) || (strcmp(InputsFieldNames{iInputs},'RecordingReference'))
                            if (isempty(obj.inputs.(InputsFieldNames{iInputs})))
                                disp donothing
                            else
                                try
                                    obj.inputs.(InputsFieldNames{iInputs})=eval(obj.inputs.(InputsFieldNames{iInputs}));
                                catch
                                    obj.inputs.(InputsFieldNames{iInputs})=str2num(obj.inputs.(InputsFieldNames{iInputs}));
                                end
                            end
                        elseif strcmp(InputsFieldNames{iInputs},'RealTimeChannelWeights') || strcmp(InputsFieldNames{iInputs},'RealTimeChannelsWeights') || strcmp(InputsFieldNames{iInputs},'ResponseFunctionNumerator') || strcmp(InputsFieldNames{iInputs},'ResponseFunctionDenominator') ...
                                || strcmp(InputsFieldNames{iInputs},'TargetFrequencyRange')  || strcmp(InputsFieldNames{iInputs},'BandStopFrequency') || strcmp(InputsFieldNames{iInputs},'EMGXLimit') || strcmp(InputsFieldNames{iInputs},'EEGXLimit') ...
                                || strcmp(InputsFieldNames{iInputs},'MEPSearchWindow') || strcmp(InputsFieldNames{iInputs},'EMGExtractionPeriod')  || strcmp(InputsFieldNames{iInputs},'EEGExtractionPeriod') || strcmp(InputsFieldNames{iInputs},'EEGYLimit')...
                                || strcmp(InputsFieldNames{iInputs},'SEPSearchWindow')
                            obj.inputs.(InputsFieldNames{iInputs})=str2num(obj.inputs.(InputsFieldNames{iInputs}));
                        else
                            obj.inputs.(InputsFieldNames{iInputs})=str2double(obj.inputs.(InputsFieldNames{iInputs}));
                        end
                    elseif(isa(obj.inputs.(InputsFieldNames{iInputs}),'cell'))
                        obj.inputs.(InputsFieldNames{iInputs})=obj.inputs.(InputsFieldNames{iInputs}){1,1};
                    end
                end
                %                 obj.inputs.prestim_scope_plt=obj.inputs.EMGDisplayPeriodPre;
                %                 obj.inputs.poststim_scope_plt=obj.inputs.EMGDisplayPeriodPost;
                %                 obj.inputs.mep_onset=obj.inputs.MEPOnset;
                %                 obj.inputs.mep_offset=obj.inputs.MEPOffset;
                %                 obj.inputs.input_device=obj.app.pi.mep.InputDevice.String(obj.inputs.InputDevice); %TODO: the drc or mep on the 4th structure is not a good solution!
                %                 obj.inputs.output_device=obj.inputs.condsAll.cond1.st1.stim_device;
                obj.inputs.stim_mode='MSO';
                obj.inputs.measure_str='MEP Measurement';
                %                 obj.inputs.ylimMin=obj.inputs.EMGDisplayYLimMin;
                %                 obj.inputs.ylimMax=obj.inputs.EMGDisplayYLimMax;
                obj.inputs.stop_event=0;
                obj.inputs.ylimMin=-3000;
                obj.inputs.ylimMax=+3000;
                obj.inputs.TrialNoForMean=1;
                %                 obj.inputs.mt_starting_stim_inten=obj.inputs.condsAll.cond1.st1.si_pckt{1,1};
                
                
            end
            %% Common Settings for All Functions
            try
                obj.inputs.NoiseFilter50Hz=obj.app.par.GlobalSettings.NoiseFilter50Hz;
            catch
                obj.inputs.NoiseFilter50Hz=0;
            end
            %% Callbacks
            function cb_EvaluateLinkedLists
                %% Intensity, Paired-CS Intensity, Timing Onset, ISI 
                for icond=1:obj.inputs.condsAll
                    condStr=['cond' num2str(icond)];
                    for s=1:(length(fieldnames(obj.inputs.condsAll.(condStr)))-6)
                        st=['st' num2str(s)];
                        %% Transforming SI Packets to 4,5, 6 index
                        obj.inputs.condsAll.(condStr).(st).si_pckt{4}=obj.inputs.condsAll.(condStr).(st).si_pckt{1}; %Intensity
                        obj.inputs.condsAll.(condStr).(st).si_pckt{5}=obj.inputs.condsAll.(condStr).(st).si_pckt{2}; %Paired-CS Intensity
                        obj.inputs.condsAll.(condStr).(st).si_pckt{6}=obj.inputs.condsAll.(condStr).(st).si_pckt{3}; %ISI
                        %% Checking Intensity Units
                        switch obj.inputs.condsAll.(condStr).(st).IntensityUnit
                            case {'%MT','%ST'}
                                %checking if the corrospondonding threshold is exicstant or not
                                if isempty(str2num(obj.inputs.condsAll.(condStr).(st).threshold))
                                    errordlg('The "Threshold" cannot be found to set "Intensity Units".','BEST Toolbox');
                                else
                                    obj.inputs.condsAll.(condStr).(st).si_pckt{4}=str2num(obj.inputs.condsAll.(condStr).(st).threshold)*obj.inputs.condsAll.(condStr).(st).si_pckt{1}*0.01; %Multiplying the Threshold with the Intensity to apply Transformation
                                end
                            case {'%MSO coupled','%MT coupled','mA coupled','%ST coupled'}
                                try
                                    Session=obj.inputs.condsAll.(condStr).(st).CoupleIntensityUnits.Session;
                                    Protocol=obj.inputs.condsAll.(condStr).(st).CoupleIntensityUnits.Session.Protocol;
                                    Parameter=obj.inputs.condsAll.(condStr).(st).CoupleIntensityUnits.Session.Parameter;
                                    Channel=obj.inputs.condsAll.(condStr).(st).CoupleIntensityUnits.Session.Channel;
                                    switch Parameter
                                        case 'Motor Threshold'
                                            try
                                                Threshold=obj.sessions.(Session).(Protocol).Results.(Channel).MotorThreshold; %get the motor threshold;
                                                obj.inputs.condsAll.(condStr).(st).threshold=num2str(Threshold);
                                                obj.inputs.condsAll.(condStr).(st).si_pckt{4}=str2num(obj.inputs.condsAll.(condStr).(st).threshold)*obj.inputs.condsAll.(condStr).(st).si_pckt{1}*0.01; %Multiplying the Threshold with the Intensity to apply Transformation
                                                % set the adjusted value on the 4th packet in si_packet and repeat it for all
                                            catch
                                                errordlg('The "Motor Threshold" coupled to import from previous Measurement cannot be found in "Linked List".','BEST Toolbox');
                                            end
                                        case 'Sensory Threshold'
                                            try
                                                Threshold=obj.sessions.(Session).(Protocol).Results.(Channel).PsychometricThreshold;
                                                obj.inputs.condsAll.(condStr).(st).threshold=num2str(Threshold);
                                                obj.inputs.condsAll.(condStr).(st).si_pckt{4}=str2num(obj.inputs.condsAll.(condStr).(st).threshold)*obj.inputs.condsAll.(condStr).(st).si_pckt{1}*0.01; %Multiplying the Threshold with the Intensity to apply Transformation
                                            catch
                                                errordlg('The "Sensory Threshold" coupled to import from previous Measurement cannot be found in "Linked List".','BEST Toolbox');
                                            end
                                        case 'Inflection Point'
                                            try
                                                IP=obj.sessions.(Session).(Protocol).Results.InflectionPoint_SI_BaseUnits;
                                                obj.inputs.condsAll.(condStr).(st).threshold=num2str(IP);
                                                obj.inputs.condsAll.(condStr).(st).si_pckt{4}=str2num(obj.inputs.condsAll.(condStr).(st).threshold)*obj.inputs.condsAll.(condStr).(st).si_pckt{1}*0.01; %Multiplying the IP with the Intensity to apply Transformation
                                            catch
                                                errordlg('The "Inflection Point" coupled to import from previous Measurement cannot be found in "Linked List".','BEST Toolbox');
                                            end
                                        case 'Inhibition'
                                            try
                                                Ib=obj.sessions.(Session).(Protocol).Results.Inhibition_SI_BaseUnits;
                                                obj.inputs.condsAll.(condStr).(st).threshold=num2str(Ib);
                                                obj.inputs.condsAll.(condStr).(st).si_pckt{4}=str2num(obj.inputs.condsAll.(condStr).(st).threshold)*obj.inputs.condsAll.(condStr).(st).si_pckt{1}*0.01; %Multiplying the Ib with the Intensity to apply Transformation
                                            catch
                                                errordlg('The "Inhibition" coupled to import from previous Measurement cannot be found in "Linked List".','BEST Toolbox');
                                            end
                                        case 'Facilitation'
                                            try
                                                Fc=obj.sessions.(Session).(Protocol).Results.Facilitation_SI_BaseUnits;
                                                obj.inputs.condsAll.(condStr).(st).threshold=num2str(Fc);
                                                obj.inputs.condsAll.(condStr).(st).si_pckt{4}=str2num(obj.inputs.condsAll.(condStr).(st).threshold)*obj.inputs.condsAll.(condStr).(st).si_pckt{1}*0.01; %Multiplying the Fc with the Intensity to apply Transformation
                                            catch
                                                errordlg('The "Facilitation" coupled to import from previous Measurement cannot be found in "Linked List".','BEST Toolbox');
                                            end
                                        case 'Plateau'
                                            try
                                                Pt=obj.sessions.(Session).(Protocol).Results.Plateau_SI_BaseUnits;
                                                obj.inputs.condsAll.(condStr).(st).threshold=num2str(Pt);
                                                obj.inputs.condsAll.(condStr).(st).si_pckt{4}=str2num(obj.inputs.condsAll.(condStr).(st).threshold)*obj.inputs.condsAll.(condStr).(st).si_pckt{1}*0.01; %Multiplying the Pt with the Intensity to apply Transformation
                                            catch
                                                errordlg('The "Plateau" coupled to import from previous Measurement cannot be found in "Linked List".','BEST Toolbox');
                                            end
                                    end
                                catch
                                    errordlg('The "Intensities Coupled Units" to import from previous Measurement cannot be found in "Linked List".','BEST Toolbox');
                                end
                        end
                        %% Checking Timing Onset Units
                        for iStimTiming=1:numel(obj.inputs.condsAll.(condStr).(st).stim_timing)
                            if strcmp(obj.inputs.condsAll.(condStr).(st).stim_timing_units{iStimTiming},'Import from Protocol')
                                try
                                    Pulse=['pulse' num2str(iStimTiming)'];
                                    Session=obj.inputs.condsAll.(condStr).(st).ImportERPLatency.(Pulse).Session;
                                    Protocol=obj.inputs.condsAll.(condStr).(st).ImportERPLatency.(Pulse).Protocol;
                                    Channel=obj.inputs.condsAll.(condStr).(st).ImportERPLatency.(Pulse).Channel;
                                    obj.inputs.condsAll.(condStr).(st).stim_timing{iStimTiming}=obj.sessions.(Session).(Protocol).results.ERPLatency.(Channel);
                                    obj.app.par.(obj.app.info.event.current_session).(obj.app.info.event.current_measure_fullstr).condsAll.(condStr).(st).stim_timing{iStimTiming}=obj.sessions.(Session).(Protocol).results.ERPLatency.(Channel);
                                catch
                                    errordlg('The "ERP Latency" to import from previous "ERP Measurement" cannot be found in "Linked List".','BEST Toolbox');
                                end
                            end
                        end
                        %% Checking Paired-CS Units
                        %% Checking ISI Units
                    end
                end
                %% Peak Frequency
                if obj.inputs.BrainState==2
                    if obj.inputs.ImportPeakFrequencyFromProtocols==2
                        try
                            Session=obj.inputs.ImportPeakFrequency.Session;
                            Protocol=obj.inputs.ImportPeakFrequency.Protocol;
                            Channel=obj.inputs.ImportPeakFrequency.Channel;
                            obj.inputs.PeakFrequency=obj.sessions.(Session).(Protocol).results.PeakFrequency.(Channel);
                            obj.app.par.(obj.app.info.event.current_session).(obj.app.info.event.current_measure_fullstr).PeakFrequency=num2str(obj.inputs.PeakFrequency);
                        catch
                            errordlg('The Peak Frequency to import from previous rsEEG Measurement Protocol cannot be found in "Linked List".','BEST Toolbox');
                        end
                    end
                end
            end
        end
        function factorizeConditionsExtended(obj)
            %% Deleting Previous best_toolbox class
            obj.inputs=[];
            obj.bossbox=[];
            obj.magven=[];
            obj.magStim=[];
            obj.digitimer=[];
            obj.fieldtrip=[];
            obj.app.pr=[];
            %% Preparing Parameters to Inputs
            cb_Pars2Inputs
            %% Evaluating Linked Lists
            cb_EvaluateLinkedLists
            %% Evaluating Selected Protocol
            switch obj.inputs.Protocol
                case 'MEP Measurement Protocol'
                    switch obj.inputs.BrainState
                        case 1 % BS Independent
                            %% Adjusting New Arhictecture to Old Architecture
                            obj.inputs.MEPOnset=obj.inputs.MEPSearchWindow(1);
                            obj.inputs.MEPOffset=obj.inputs.MEPSearchWindow(2);
                            obj.inputs.EMGDisplayPeriodPre=obj.inputs.EMGExtractionPeriod(1)*(-1);
                            obj.inputs.EMGDisplayPeriodPost=obj.inputs.EMGExtractionPeriod(2);
                            obj.inputs.prestim_scope_plt=obj.inputs.EMGDisplayPeriodPre;
                            obj.inputs.poststim_scope_plt=obj.inputs.EMGDisplayPeriodPost;
                            obj.inputs.mep_onset=obj.inputs.MEPOnset;
                            obj.inputs.mep_offset=obj.inputs.MEPOffset;
                            obj.inputs.input_device=obj.app.pi.mep.InputDevice.String(obj.inputs.InputDevice); %TODO: the drc or mep on the 4th structure is not a good solution!
                            obj.inputs.output_device=obj.inputs.condsAll.cond1.st1.stim_device;
                            obj.inputs.stim_mode='MSO';
                            obj.inputs.measure_str='MEP Measurement';
                            obj.inputs.ylimMin=obj.inputs.EMGDisplayYLimMin;
                            obj.inputs.ylimMax=obj.inputs.EMGDisplayYLimMax;
                            obj.inputs.stop_event=0;
                            obj.inputs.ylimMin=-3000;
                            obj.inputs.ylimMax=+3000;
                            obj.inputs.TrialNoForMean=1;
                            obj.inputs.mt_starting_stim_inten=obj.inputs.condsAll.cond1.st1.si_pckt{1,1};
                            %% Creating Column Labels
                            obj.inputs.colLabel.inputDevices=1;
                            obj.inputs.colLabel.outputDevices=2;
                            obj.inputs.colLabel.si=3;
                            obj.inputs.colLabel.iti=4;
                            obj.inputs.colLabel.chLab=5;
                            obj.inputs.colLabel.trials=9;
                            obj.inputs.colLabel.axesno=6;
                            obj.inputs.colLabel.measures=7;
                            obj.inputs.colLabel.stimMode=8;
                            obj.inputs.colLabel.tpm=10;
                            obj.inputs.colLabel.chType=11;
                            obj.inputs.colLabel.chId=12;
                            obj.inputs.colLabel.ConditionMarker=13;
                            conds=fieldnames(obj.inputs.condsAll);
                            %% Creating Channel Types, Axes No, Channel IDs
                            DisplayChannelCounter=0;
                            for c=1:numel(fieldnames(obj.inputs.condsAll))
                                obj.inputs.condsAllFactorsInfo.(conds{c,1}).TargetChannelNumbers=numel(obj.inputs.condsAll.(conds{c,1}).targetChannel);
                                obj.inputs.condsAllFactorsInfo.(conds{c,1}).chType=repmat({'EMG'},1,numel(obj.inputs.condsAll.(conds{c,1}).targetChannel));
                                for itc=1:numel(obj.inputs.condsAll.(conds{c,1}).targetChannel)
                                    obj.inputs.condsAllFactorsInfo.(conds{c,1}).chId{itc}=find(strcmp(obj.app.par.hardware_settings.(char(obj.inputs.input_device)).NeurOneProtocolChannelLabels,obj.inputs.condsAll.(conds{c,1}).targetChannel{itc}));
                                    obj.inputs.condsAllFactorsInfo.(conds{c,1}).axesno{itc}=DisplayChannelCounter+itc;
                                    ax_AxesAnnotation{1,obj.inputs.condsAllFactorsInfo.(conds{c,1}).axesno{itc}}{1,1}=['Condition:' num2str(c)];
                                    ax_AxesAnnotation{1,obj.inputs.condsAllFactorsInfo.(conds{c,1}).axesno{itc}}{2,1}=['Channel: ' obj.inputs.condsAll.(conds{c,1}).targetChannel{itc}];
                                    ax_AxesAnnotation{1,obj.inputs.condsAllFactorsInfo.(conds{c,1}).axesno{itc}}{3,1}=['ITI(s): ' num2str(obj.inputs.condsAll.(conds{c,1}).ITI)];
                                    % % ax_AxesAnnotation{1,obj.inputs.condsAllFactorsInfo.(conds{c,1}).axesno{itc}}{4,1}=['Stim. Pars'] %For Future Release 
                                end
                                DisplayChannelCounter=DisplayChannelCounter+obj.inputs.condsAllFactorsInfo.(conds{c,1}).TargetChannelNumbers;
                            end
                            if isempty(obj.inputs.EMGDisplayChannels)
                                EMGDisplayChannelschID=[];
                                EMGDisplayChannelsAxesNo=num2cell(DisplayChannelCounter+1);%StatusTable
                            else
                                for dc=1:numel(obj.inputs.EMGDisplayChannels)
                                    EMGDisplayChannelschID{dc}=find(strcmp(obj.app.par.hardware_settings.(char(obj.inputs.input_device)).NeurOneProtocolChannelLabels,obj.inputs.EMGDisplayChannels{dc}));
                                    ax_AxesAnnotation{1,DisplayChannelCounter+dc}{1,1}=['Condition:' 'All'];
                                    ax_AxesAnnotation{1,DisplayChannelCounter+dc}{2,1}=['Channel: ' obj.inputs.EMGDisplayChannels{dc}];
                                    % % ax_AxesAnnotation{1,DisplayChannelCounter+dc}{3,1}=['Stim. Pars'] %For Future Release 
                                end
                                EMGDisplayChannelsAxesNo=num2cell(DisplayChannelCounter+1:1:DisplayChannelCounter+numel(obj.inputs.EMGDisplayChannels)+1); %DisplayChannels +Status Table
                            end
                            %% Creating Experimental Conditions
                            for c=1:numel(fieldnames(obj.inputs.condsAll))
                                %% Input Device
                                obj.inputs.condMat{c,obj.inputs.colLabel.inputDevices}=char(obj.app.pi.mep.InputDevice.String(obj.inputs.InputDevice));
                                %% TrialsPer Condition
                                obj.inputs.condMat{c,obj.inputs.colLabel.trials}=obj.inputs.condsAll.(conds{c,1}).TrialsPerCondition;
                                %% ITI
                                obj.inputs.condMat{c,obj.inputs.colLabel.iti}=obj.inputs.condsAll.(conds{c,1}).ITI;
                                %% Channel Label, Measure, Axes No, Channel Type, Channel ID for Plots
                                obj.inputs.condMat{c,obj.inputs.colLabel.chLab}=[obj.inputs.condsAll.(conds{c,1}).targetChannel,obj.inputs.EMGDisplayChannels,{'StatusTable'}];
                                obj.inputs.condMat{c,obj.inputs.colLabel.measures}=[repmat({'MEP_Measurement_Conditional'},1,numel(obj.inputs.condsAll.(conds{c,1}).targetChannel)),repmat({'MEP_Measurement'},1,numel(obj.inputs.EMGDisplayChannels)),{'StatusTable'}];
                                obj.inputs.condMat{c,obj.inputs.colLabel.axesno}=[obj.inputs.condsAllFactorsInfo.(conds{c,1}).axesno,EMGDisplayChannelsAxesNo];
                                obj.inputs.condMat{c,obj.inputs.colLabel.chType}=[obj.inputs.condsAllFactorsInfo.(conds{c,1}).chType,repmat({'EMG'},1,numel(obj.inputs.EMGDisplayChannels)),{'StatusTable'}];
                                obj.inputs.condMat{c,obj.inputs.colLabel.chId}=[obj.inputs.condsAllFactorsInfo.(conds{c,1}).chId,EMGDisplayChannelschID,{1}];
                                obj.inputs.condMat{c,obj.inputs.colLabel.ConditionMarker}=c;
                                ax_measures{c}=repmat({'MEP_Measurement'},1,numel(obj.inputs.condsAll.(conds{c,1}).targetChannel));
                                ax_ChannelLabels{c}=obj.inputs.condsAll.(conds{c,1}).targetChannel;
                                
                                %% Stimulator Specific Parameters
                                for stno=1:(max(size(fieldnames(obj.inputs.condsAll.(conds{c,1}))))-6)
                                    st=['st' num2str(stno)];
                                    condSi{1,stno}=obj.inputs.condsAll.(conds{c,1}).(st).si_pckt;
                                    condstimMode{1,stno}= obj.inputs.condsAll.(conds{c,1}).(st).stim_mode;
                                    condoutputDevice{1,stno}=obj.inputs.condsAll.(conds{c,1}).(st).stim_device;
                                    for i=1:numel(obj.inputs.condsAll.(conds{c,1}).(st).stim_timing)
                                        condstimTimingStrings{1,i}=num2str(obj.inputs.condsAll.(conds{c,1}).(st).stim_timing{1,i});
                                    end
                                    condstimTiming{1,stno}=condstimTimingStrings;
                                end
                                obj.inputs.condMat(c,obj.inputs.colLabel.si)={condSi};
                                obj.inputs.condMat(c,obj.inputs.colLabel.outputDevices)={condoutputDevice};
                                obj.inputs.condMat(c,obj.inputs.colLabel.stimMode)={condstimMode};
                                for timing=1:numel(condstimTiming)
                                    for jj=1:numel(condstimTiming{1,timing})
                                        condstimTiming{2,timing}{1,jj}=condoutputDevice{1,timing};
                                    end
                                end
                                condstimTiming_new{1}=horzcat(condstimTiming{1,:});
                                condstimTiming_new{2}=horzcat(condstimTiming{2,:});
                                [condstimTiming_new_sorted{1},sorted_idx]=sort(condstimTiming_new{1});
                                condstimTiming_new_sorted{2}=condstimTiming_new{1,2}(sorted_idx);
                                for stimno_tpm=1:numel(condstimTiming_new_sorted{2})
                                    port_vector{stimno_tpm}=obj.app.par.hardware_settings.(char(condstimTiming_new_sorted{2}{1,stimno_tpm})).bb_outputport;
                                end
                                condstimTiming_new_sorted{2}=port_vector;
                                tpmVect=[condstimTiming_new_sorted{1};condstimTiming_new_sorted{2}];
                                [tpmVect_unique,ia,ic]=unique(tpmVect(1,:));
                                a_counts = accumarray(ic,1);
                                for binportloop=1:numel(tpmVect_unique)
                                    buffer{1,binportloop}={(cell2mat(tpmVect(2,ia(binportloop):ia(binportloop)-1+a_counts(binportloop))))};
                                    binaryZ='0000';
                                    num=cell2mat(buffer{1,binportloop});
                                    for binaryID=1:numel(num)
                                        binaryZ(str2num(num(binaryID)))='1';
                                    end
                                    buffer{1,binportloop}=bin2dec(flip(binaryZ));
                                    markers{1,binportloop}=0;
                                end
                                markers{1,1}=c;
                                condstimTiming_new_sorted=[num2cell((cellfun(@str2num, tpmVect_unique(1,1:end))));buffer;markers];
                                condstimTiming_new_sorted=cell2mat(condstimTiming_new_sorted)
                                [condstimTiming_new_sorted(1,:),sorted_idx]=sort(condstimTiming_new_sorted(1,:))
                                condstimTiming_new_sorted(1,:)=condstimTiming_new_sorted(1,:)/1000;
                                condstimTiming_new_sorted(2,:)=condstimTiming_new_sorted(2,sorted_idx)
                                
                                obj.inputs.condMat(c,obj.inputs.colLabel.tpm)={num2cell(condstimTiming_new_sorted)};
                                condSi=[]; condoutputDevice=[]; condstimMode=[];condstimTiming=[];buffer=[];tpmVect_unique=[];a_counts =[];ia=[];ic=[];port_vector=[];
                                num=[];condstimTiming_new=[];condstimTiming_new_sorted=[];sorted_idx=[];markers=[];condstimTimingStrings=[];
                            end
                            %% Preparing Results Panels
                            obj.app.pr.ax_measures=[horzcat(ax_measures{:}),repmat({'MEP_Measurement'},1,numel(obj.inputs.EMGDisplayChannels)),{'StatusTable'}];
                            obj.app.pr.axesno=DisplayChannelCounter+numel(obj.inputs.EMGDisplayChannels)+1;
                            obj.app.pr.ax_ChannelLabels=[horzcat(ax_ChannelLabels{:}),obj.inputs.EMGDisplayChannels, {'StatusTable'}] ;
                            obj.app.pr.ax_AxesAnnotation=ax_AxesAnnotation;
                        case 2 % BS Dependent
                            %% Adjusting New Arhictecture to Old Architecture
                            obj.inputs.MEPOnset=obj.inputs.MEPSearchWindow(1);
                            obj.inputs.MEPOffset=obj.inputs.MEPSearchWindow(2);
                            obj.inputs.EMGDisplayPeriodPre=obj.inputs.EMGExtractionPeriod(1)*(-1);
                            obj.inputs.EMGDisplayPeriodPost=obj.inputs.EMGExtractionPeriod(2);
                            obj.inputs.prestim_scope_plt=obj.inputs.EMGDisplayPeriodPre;
                            obj.inputs.poststim_scope_plt=obj.inputs.EMGDisplayPeriodPost;
                            obj.inputs.mep_onset=obj.inputs.MEPOnset;
                            obj.inputs.mep_offset=obj.inputs.MEPOffset;
                            obj.inputs.input_device=obj.app.pi.mep.InputDevice.String(obj.inputs.InputDevice); %TODO: the drc or mep on the 4th structure is not a good solution!
                            obj.inputs.output_device=obj.inputs.condsAll.cond1.st1.stim_device;
                            obj.inputs.stim_mode='MSO';
                            obj.inputs.measure_str='MEP Measurement';
                            obj.inputs.ylimMin=obj.inputs.EMGDisplayYLimMin;
                            obj.inputs.ylimMax=obj.inputs.EMGDisplayYLimMax;
                            obj.inputs.stop_event=0;
                            obj.inputs.ylimMin=-3000;
                            obj.inputs.ylimMax=+3000;
                            obj.inputs.TrialNoForMean=1;
                            obj.inputs.mt_starting_stim_inten=obj.inputs.condsAll.cond1.st1.si_pckt{1,1};
                            %% Creating Column Labels
                            obj.inputs.colLabel.inputDevices=1;
                            obj.inputs.colLabel.outputDevices=2;
                            obj.inputs.colLabel.si=3;
                            obj.inputs.colLabel.iti=4;
                            obj.inputs.colLabel.chLab=5;
                            obj.inputs.colLabel.trials=9;
                            obj.inputs.colLabel.axesno=6;
                            obj.inputs.colLabel.measures=7;
                            obj.inputs.colLabel.stimMode=8;
                            obj.inputs.colLabel.tpm=10;
                            obj.inputs.colLabel.chType=11;
                            obj.inputs.colLabel.chId=12;
                            obj.inputs.colLabel.phase=13;
                            obj.inputs.colLabel.IA=14;
                            obj.inputs.colLabel.IAPercentile=15;
                            obj.inputs.colLabel.IAInput=16;
                            obj.inputs.colLabel.IAUnit=17;
                            obj.inputs.colLabel.ConditionMarker=18;
                            
                            conds=fieldnames(obj.inputs.condsAll);
                            %% Creating Channel Types, Axes No, Channel IDs
                            DisplayChannelCounter=2;
                            for c=1:numel(fieldnames(obj.inputs.condsAll))
                                obj.inputs.condsAllFactorsInfo.(conds{c,1}).TargetChannelNumbers=numel(obj.inputs.condsAll.(conds{c,1}).targetChannel);
                                obj.inputs.condsAllFactorsInfo.(conds{c,1}).chType=repmat({'EMG'},1,numel(obj.inputs.condsAll.(conds{c,1}).targetChannel));
                                for itc=1:numel(obj.inputs.condsAll.(conds{c,1}).targetChannel)
                                    obj.inputs.condsAllFactorsInfo.(conds{c,1}).chId{itc}=find(strcmp(obj.app.par.hardware_settings.(char(obj.inputs.input_device)).NeurOneProtocolChannelLabels,obj.inputs.condsAll.(conds{c,1}).targetChannel{itc}));
                                    obj.inputs.condsAllFactorsInfo.(conds{c,1}).axesno{itc}=DisplayChannelCounter+itc;
                                    ax_AxesAnnotation{1,obj.inputs.condsAllFactorsInfo.(conds{c,1}).axesno{itc}}{1,1}=['Condition:' num2str(c)];
                                    ax_AxesAnnotation{1,obj.inputs.condsAllFactorsInfo.(conds{c,1}).axesno{itc}}{2,1}=['Channel: ' obj.inputs.condsAll.(conds{c,1}).targetChannel{itc}];
                                    ax_AxesAnnotation{1,obj.inputs.condsAllFactorsInfo.(conds{c,1}).axesno{itc}}{3,1}=['Phase: ' obj.inputs.condsAll.(conds{c,1}).Phase];
                                    ax_AxesAnnotation{1,obj.inputs.condsAllFactorsInfo.(conds{c,1}).axesno{itc}}{4,1}=['Amp. Threshold:' obj.inputs.condsAll.(conds{c,1}).AmplitudeThreshold];
                                    % % ax_AxesAnnotation{1,obj.inputs.condsAllFactorsInfo.(conds{c,1}).axesno{itc}}{4,1}=['Stim. Pars'] %For Future Release 
                                end
                                DisplayChannelCounter=DisplayChannelCounter+obj.inputs.condsAllFactorsInfo.(conds{c,1}).TargetChannelNumbers;
                            end
                            if isempty(obj.inputs.EMGDisplayChannels)
                                EMGDisplayChannelschID=[];
                                EMGDisplayChannelsAxesNo=num2cell(DisplayChannelCounter+1:DisplayChannelCounter+2+1);%Amplitude Thresholds + Amplitude Distriution+StatusTable
                            else
                                for dc=1:numel(obj.inputs.EMGDisplayChannels)
                                    EMGDisplayChannelschID{dc}=find(strcmp(obj.app.par.hardware_settings.(char(obj.inputs.input_device)).NeurOneProtocolChannelLabels,obj.inputs.EMGDisplayChannels{dc}));
                                    ax_AxesAnnotation{1,DisplayChannelCounter+dc}{1,1}=['Condition:' 'All'];
                                    ax_AxesAnnotation{1,DisplayChannelCounter+dc}{2,1}=['Channel: ' obj.inputs.EMGDisplayChannels{dc}];
                                end
                                EMGDisplayChannelsAxesNo=num2cell(DisplayChannelCounter+1:1:DisplayChannelCounter+numel(obj.inputs.EMGDisplayChannels)+2+1); %DisplayChannels +Amplitude Thresholds + Amplitude Distriution + Status Table
                            end
                            %% Creating Experimental Conditions
                            for c=1:numel(fieldnames(obj.inputs.condsAll))
                                %% Input Device
                                obj.inputs.condMat{c,obj.inputs.colLabel.inputDevices}=char(obj.app.pi.mep.InputDevice.String(obj.inputs.InputDevice));
                                %% TrialsPer Condition
                                obj.inputs.condMat{c,obj.inputs.colLabel.trials}=obj.inputs.condsAll.(conds{c,1}).TrialsPerCondition;
                                %% ITI
                                obj.inputs.condMat{c,obj.inputs.colLabel.iti}=obj.inputs.condsAll.(conds{c,1}).ITI;
                                %% Phase
                                switch obj.inputs.condsAll.(conds{c,1}).Phase
                                    case 'Peak' %+Ve Peak
                                        obj.inputs.condMat{c,obj.inputs.colLabel.phase}={0,obj.inputs.PhaseTolerance};
                                    case 'Trough' %-Ve Trough
                                        obj.inputs.condMat{c,obj.inputs.colLabel.phase}={pi,obj.inputs.PhaseTolerance};
                                    case 'RisingFlank' %Rising Flank
                                        obj.inputs.condMat{c,obj.inputs.colLabel.phase}={-pi/2,obj.inputs.PhaseTolerance};
                                    case 'FallingFlank' %Falling Flank
                                        obj.inputs.condMat{c,obj.inputs.colLabel.phase}={pi/2,obj.inputs.PhaseTolerance};
                                    case 'Random' % NaN Value and Random Phase
                                        obj.inputs.condMat{c,obj.inputs.colLabel.phase}={0,pi};
                                end
                                %% Amplitude Threshold 
                                switch obj.inputs.condsAll.(conds{c,1}).AmplitudeUnits
                                    case 'Percentile' %Percentile
                                        obj.inputs.condMat{c,obj.inputs.colLabel.IA}={str2num(obj.inputs.condsAll.(conds{c,1}).AmplitudeThreshold)};
                                        obj.inputs.condMat{c,obj.inputs.colLabel.IAPercentile}={str2num(obj.inputs.condsAll.(conds{c,1}).AmplitudeThreshold)};
                                        obj.inputs.condMat{c,obj.inputs.colLabel.IAInput}={str2num(obj.inputs.condsAll.(conds{c,1}).AmplitudeThreshold)};
                                        obj.inputs.condMat{c,obj.inputs.colLabel.IAUnit}='Percentile';
                                    case 'Absolute (micro volts)' %Absolute uV
                                        obj.inputs.condMat{c,obj.inputs.colLabel.IA}={str2num(obj.inputs.condsAll.(conds{c,1}).AmplitudeThreshold)};
                                        obj.inputs.condMat{c,obj.inputs.colLabel.IAInput}={str2num(obj.inputs.condsAll.(conds{c,1}).AmplitudeThreshold)};
                                        obj.inputs.condMat{c,obj.inputs.colLabel.IAUnit}='uV';
                                end
                                %% Channel Label, Measure, Axes No, Channel Type, Channel ID for Plots
                                obj.inputs.condMat{c,obj.inputs.colLabel.chLab}=[{'OsscillationPhase','OsscillationEEG'},obj.inputs.condsAll.(conds{c,1}).targetChannel,obj.inputs.EMGDisplayChannels,{'OsscillationAmplitude','AmplitudeDistribution','StatusTable'}];
                                obj.inputs.condMat{c,obj.inputs.colLabel.measures}=[{'PhaseHistogram','TriggerLockedEEG'},repmat({'MEP_Measurement_Conditional'},1,numel(obj.inputs.condsAll.(conds{c,1}).targetChannel)),repmat({'MEP_Measurement'},1,numel(obj.inputs.EMGDisplayChannels)),{'RunningAmplitude','AmplitudeDistribution','StatusTable'}];
                                obj.inputs.condMat{c,obj.inputs.colLabel.axesno}=[{1,2},obj.inputs.condsAllFactorsInfo.(conds{c,1}).axesno,EMGDisplayChannelsAxesNo];
                                obj.inputs.condMat{c,obj.inputs.colLabel.chType}=[{'IP'},{'IEEG'},obj.inputs.condsAllFactorsInfo.(conds{c,1}).chType,repmat({'EMG'},1,numel(obj.inputs.EMGDisplayChannels)),{'IA'},{'IADistribution'},{'StatusTable'}];
                                obj.inputs.condMat{c,obj.inputs.colLabel.chId}=[{1,1}, obj.inputs.condsAllFactorsInfo.(conds{c,1}).chId,EMGDisplayChannelschID,{1,1,1}];
                                obj.inputs.condMat{c,obj.inputs.colLabel.ConditionMarker}=c;
                                ax_measures{c}=repmat({'MEP_Measurement'},1,numel(obj.inputs.condsAll.(conds{c,1}).targetChannel));
                                ax_ChannelLabels{c}=obj.inputs.condsAll.(conds{c,1}).targetChannel;
                                
                                %% Stimulator Specific Parameters
                                for stno=1:(max(size(fieldnames(obj.inputs.condsAll.(conds{c,1}))))-6)
                                    st=['st' num2str(stno)];
                                    condSi{1,stno}=obj.inputs.condsAll.(conds{c,1}).(st).si_pckt;
                                    condstimMode{1,stno}= obj.inputs.condsAll.(conds{c,1}).(st).stim_mode;
                                    condoutputDevice{1,stno}=obj.inputs.condsAll.(conds{c,1}).(st).stim_device;
                                    for i=1:numel(obj.inputs.condsAll.(conds{c,1}).(st).stim_timing)
                                        condstimTimingStrings{1,i}=num2str(obj.inputs.condsAll.(conds{c,1}).(st).stim_timing{1,i});
                                    end
                                    condstimTiming{1,stno}=condstimTimingStrings;
                                end
                                obj.inputs.condMat(c,obj.inputs.colLabel.si)={condSi};
                                obj.inputs.condMat(c,obj.inputs.colLabel.outputDevices)={condoutputDevice};
                                obj.inputs.condMat(c,obj.inputs.colLabel.stimMode)={condstimMode};
                                for timing=1:numel(condstimTiming)
                                    for jj=1:numel(condstimTiming{1,timing})
                                        condstimTiming{2,timing}{1,jj}=condoutputDevice{1,timing};
                                    end
                                end
                                condstimTiming_new{1}=horzcat(condstimTiming{1,:});
                                condstimTiming_new{2}=horzcat(condstimTiming{2,:});
                                [condstimTiming_new_sorted{1},sorted_idx]=sort(condstimTiming_new{1});
                                condstimTiming_new_sorted{2}=condstimTiming_new{1,2}(sorted_idx);
                                for stimno_tpm=1:numel(condstimTiming_new_sorted{2})
                                    port_vector{stimno_tpm}=obj.app.par.hardware_settings.(char(condstimTiming_new_sorted{2}{1,stimno_tpm})).bb_outputport;
                                end
                                condstimTiming_new_sorted{2}=port_vector;
                                tpmVect=[condstimTiming_new_sorted{1};condstimTiming_new_sorted{2}];
                                [tpmVect_unique,ia,ic]=unique(tpmVect(1,:));
                                a_counts = accumarray(ic,1);
                                for binportloop=1:numel(tpmVect_unique)
                                    buffer{1,binportloop}={(cell2mat(tpmVect(2,ia(binportloop):ia(binportloop)-1+a_counts(binportloop))))};
                                    binaryZ='0000';
                                    num=cell2mat(buffer{1,binportloop});
                                    for binaryID=1:numel(num)
                                        binaryZ(str2num(num(binaryID)))='1';
                                    end
                                    buffer{1,binportloop}=bin2dec(flip(binaryZ));
                                    markers{1,binportloop}=0;
                                end
                                markers{1,1}=c;
                                condstimTiming_new_sorted=[num2cell((cellfun(@str2num, tpmVect_unique(1,1:end))));buffer;markers];
                                condstimTiming_new_sorted=cell2mat(condstimTiming_new_sorted)
                                [condstimTiming_new_sorted(1,:),sorted_idx]=sort(condstimTiming_new_sorted(1,:))
                                condstimTiming_new_sorted(1,:)=condstimTiming_new_sorted(1,:)/1000;
                                condstimTiming_new_sorted(2,:)=condstimTiming_new_sorted(2,sorted_idx)
                                
                                obj.inputs.condMat(c,obj.inputs.colLabel.tpm)={num2cell(condstimTiming_new_sorted)};
                                condSi=[]; condoutputDevice=[]; condstimMode=[];condstimTiming=[];buffer=[];tpmVect_unique=[];a_counts =[];ia=[];ic=[];port_vector=[];
                                num=[];condstimTiming_new=[];condstimTiming_new_sorted=[];sorted_idx=[];markers=[];condstimTimingStrings=[];
                            end
                            %% Preparing Results Panels
                            obj.app.pr.ax_measures=[{'PhaseHistogram','TriggerLockedEEG'},horzcat(ax_measures{:}),repmat({'MEP_Measurement'},1,numel(obj.inputs.EMGDisplayChannels)),{'RunningAmplitude','AmplitudeDistribution','StatusTable'}];
                            obj.app.pr.axesno=DisplayChannelCounter+numel(obj.inputs.EMGDisplayChannels)+2+1;
                            obj.app.pr.ax_ChannelLabels=[{'OsscillationPhase','OsscillationEEG'},horzcat(ax_ChannelLabels{:}),obj.inputs.EMGDisplayChannels, {'OsscillationAmplitude','AmplitudeDistribution','StatusTable'}] ;
                            obj.app.pr.ax_AxesAnnotation=ax_AxesAnnotation;
                    end
            end
            %% Conversion from Pars2Inputs
            function cb_Pars2Inputs
                obj.inputs=obj.app.par.(obj.app.info.event.current_session).(obj.app.info.event.current_measure_fullstr);
                InputsFieldNames=fieldnames(obj.inputs);
                for iInputs=1:numel(InputsFieldNames)
                    if (isa(obj.inputs.(InputsFieldNames{iInputs}),'char'))
                        if (strcmp(InputsFieldNames{iInputs},'ReferenceChannels')) || (strcmp(InputsFieldNames{iInputs},'ITI')) || (strcmp(InputsFieldNames{iInputs},'EMGDisplayChannels')) || (strcmp(InputsFieldNames{iInputs},'EMGTargetChannels')) || (strcmp(InputsFieldNames{iInputs},'Phase')) || (strcmp(InputsFieldNames{iInputs},'PhaseTolerance')) || (strcmp(InputsFieldNames{iInputs},'MontageChannels')) || (strcmp(InputsFieldNames{iInputs},'AmplitudeThreshold'))|| (strcmp(InputsFieldNames{iInputs},'TargetChannels')) || (strcmp(InputsFieldNames{iInputs},'EEGDisplayPeriod')) ...
                                || (strcmp(InputsFieldNames{iInputs},'RealTimeChannelsMontage')) || (strcmp(InputsFieldNames{iInputs},'MontageWeights')) || (strcmp(InputsFieldNames{iInputs},'RecordingReference'))
                            if (isempty(obj.inputs.(InputsFieldNames{iInputs})))
                                disp donothing
                            else
                                try
                                    obj.inputs.(InputsFieldNames{iInputs})=eval(obj.inputs.(InputsFieldNames{iInputs}));
                                catch
                                    obj.inputs.(InputsFieldNames{iInputs})=str2num(obj.inputs.(InputsFieldNames{iInputs}));
                                end
                            end
                        elseif strcmp(InputsFieldNames{iInputs},'RealTimeChannelWeights') || strcmp(InputsFieldNames{iInputs},'RealTimeChannelsWeights') || strcmp(InputsFieldNames{iInputs},'ResponseFunctionNumerator') || strcmp(InputsFieldNames{iInputs},'ResponseFunctionDenominator') ...
                                || strcmp(InputsFieldNames{iInputs},'TargetFrequencyRange')  || strcmp(InputsFieldNames{iInputs},'BandStopFrequency') || strcmp(InputsFieldNames{iInputs},'EMGXLimit') || strcmp(InputsFieldNames{iInputs},'EEGXLimit') ...
                                || strcmp(InputsFieldNames{iInputs},'MEPSearchWindow') || strcmp(InputsFieldNames{iInputs},'EMGExtractionPeriod')  || strcmp(InputsFieldNames{iInputs},'EEGExtractionPeriod') || strcmp(InputsFieldNames{iInputs},'EEGYLimit')...
                                || strcmp(InputsFieldNames{iInputs},'SEPSearchWindow')
                            obj.inputs.(InputsFieldNames{iInputs})=str2num(obj.inputs.(InputsFieldNames{iInputs}));
                        else
                            obj.inputs.(InputsFieldNames{iInputs})=str2double(obj.inputs.(InputsFieldNames{iInputs}));
                        end
                    elseif(isa(obj.inputs.(InputsFieldNames{iInputs}),'cell'))
                        obj.inputs.(InputsFieldNames{iInputs})=obj.inputs.(InputsFieldNames{iInputs}){1,1};
                    end
                end
                %                 obj.inputs.prestim_scope_plt=obj.inputs.EMGDisplayPeriodPre;
                %                 obj.inputs.poststim_scope_plt=obj.inputs.EMGDisplayPeriodPost;
                %                 obj.inputs.mep_onset=obj.inputs.MEPOnset;
                %                 obj.inputs.mep_offset=obj.inputs.MEPOffset;
                %                 obj.inputs.input_device=obj.app.pi.mep.InputDevice.String(obj.inputs.InputDevice); %TODO: the drc or mep on the 4th structure is not a good solution!
                %                 obj.inputs.output_device=obj.inputs.condsAll.cond1.st1.stim_device;
                obj.inputs.stim_mode='MSO';
                obj.inputs.measure_str='MEP Measurement';
                %                 obj.inputs.ylimMin=obj.inputs.EMGDisplayYLimMin;
                %                 obj.inputs.ylimMax=obj.inputs.EMGDisplayYLimMax;
                obj.inputs.stop_event=0;
                obj.inputs.ylimMin=-3000;
                obj.inputs.ylimMax=+3000;
                obj.inputs.TrialNoForMean=1;
                %                 obj.inputs.mt_starting_stim_inten=obj.inputs.condsAll.cond1.st1.si_pckt{1,1};
                
                
            end
            %% Common Settings for All Functions
            try
                obj.inputs.NoiseFilter50Hz=obj.app.par.GlobalSettings.NoiseFilter50Hz;
            catch
                obj.inputs.NoiseFilter50Hz=0;
            end
            %% Callbacks
            function cb_EvaluateLinkedLists
                %% Intensity, Paired-CS Intensity, Timing Onset, ISI 
                for icond=1:length(fieldnames(obj.inputs.condsAll))
                    condStr=['cond' num2str(icond)];
                    for s=1:(length(fieldnames(obj.inputs.condsAll.(condStr)))-6)
                        st=['st' num2str(s)];
                         %% Transforming SI Packets to 4,5, 6 index
                        obj.inputs.condsAll.(condStr).(st).si_pckt{4}=obj.inputs.condsAll.(condStr).(st).si_pckt{1}; %Intensity
                        obj.inputs.condsAll.(condStr).(st).si_pckt{5}=obj.inputs.condsAll.(condStr).(st).si_pckt{2}; %Paired-CS Intensity
                        obj.inputs.condsAll.(condStr).(st).si_pckt{6}=obj.inputs.condsAll.(condStr).(st).si_pckt{3}; %ISI
                        %% Checking Intensity Units
                        switch obj.inputs.condsAll.(condStr).(st).IntensityUnit
                            case {'%MT','%ST'}
                                %checking if the corrospondonding threshold is exicstant or not
                                if isempty(str2num(obj.inputs.condsAll.(condStr).(st).threshold))
                                    errordlg('The "Threshold" cannot be found to set "Intensity Units".','BEST Toolbox');
                                else
                                    obj.inputs.condsAll.(condStr).(st).si_pckt{4}=str2num(obj.inputs.condsAll.(condStr).(st).threshold)*obj.inputs.condsAll.(condStr).(st).si_pckt{1}*0.01; %Multiplying the Threshold with the Intensity to apply Transformation
                                end
                            case {'%MSO coupled','%MT coupled','mA coupled','%ST coupled'}
                                try
                                    Session=obj.inputs.condsAll.(condStr).(st).CoupleIntensityUnits.Session;
                                    Protocol=obj.inputs.condsAll.(condStr).(st).CoupleIntensityUnits.Session.Protocol;
                                    Parameter=obj.inputs.condsAll.(condStr).(st).CoupleIntensityUnits.Session.Parameter;
                                    Channel=obj.inputs.condsAll.(condStr).(st).CoupleIntensityUnits.Session.Channel;
                                    switch Parameter
                                        case 'Motor Threshold'
                                            try
                                                Threshold=obj.sessions.(Session).(Protocol).Results.(Channel).MotorThreshold; %get the motor threshold;
                                                obj.inputs.condsAll.(condStr).(st).threshold=num2str(Threshold);
                                                obj.inputs.condsAll.(condStr).(st).si_pckt{4}=str2num(obj.inputs.condsAll.(condStr).(st).threshold)*obj.inputs.condsAll.(condStr).(st).si_pckt{1}*0.01; %Multiplying the Threshold with the Intensity to apply Transformation
                                                % set the adjusted value on the 4th packet in si_packet and repeat it for all
                                            catch
                                                errordlg('The "Motor Threshold" coupled to import from previous Measurement cannot be found in "Linked List".','BEST Toolbox');
                                            end
                                        case 'Sensory Threshold'
                                            try
                                                Threshold=obj.sessions.(Session).(Protocol).Results.(Channel).PsychometricThreshold;
                                                obj.inputs.condsAll.(condStr).(st).threshold=num2str(Threshold);
                                                obj.inputs.condsAll.(condStr).(st).si_pckt{4}=str2num(obj.inputs.condsAll.(condStr).(st).threshold)*obj.inputs.condsAll.(condStr).(st).si_pckt{1}*0.01; %Multiplying the Threshold with the Intensity to apply Transformation
                                            catch
                                                errordlg('The "Sensory Threshold" coupled to import from previous Measurement cannot be found in "Linked List".','BEST Toolbox');
                                            end
                                        case 'Inflection Point'
                                            try
                                                IP=obj.sessions.(Session).(Protocol).Results.InflectionPoint_SI_BaseUnits;
                                                obj.inputs.condsAll.(condStr).(st).threshold=num2str(IP);
                                                obj.inputs.condsAll.(condStr).(st).si_pckt{4}=str2num(obj.inputs.condsAll.(condStr).(st).threshold)*obj.inputs.condsAll.(condStr).(st).si_pckt{1}*0.01; %Multiplying the IP with the Intensity to apply Transformation
                                            catch
                                                errordlg('The "Inflection Point" coupled to import from previous Measurement cannot be found in "Linked List".','BEST Toolbox');
                                            end
                                        case 'Inhibition'
                                            try
                                                Ib=obj.sessions.(Session).(Protocol).Results.Inhibition_SI_BaseUnits;
                                                obj.inputs.condsAll.(condStr).(st).threshold=num2str(Ib);
                                                obj.inputs.condsAll.(condStr).(st).si_pckt{4}=str2num(obj.inputs.condsAll.(condStr).(st).threshold)*obj.inputs.condsAll.(condStr).(st).si_pckt{1}*0.01; %Multiplying the Ib with the Intensity to apply Transformation
                                            catch
                                                errordlg('The "Inhibition" coupled to import from previous Measurement cannot be found in "Linked List".','BEST Toolbox');
                                            end
                                        case 'Facilitation'
                                            try
                                                Fc=obj.sessions.(Session).(Protocol).Results.Facilitation_SI_BaseUnits;
                                                obj.inputs.condsAll.(condStr).(st).threshold=num2str(Fc);
                                                obj.inputs.condsAll.(condStr).(st).si_pckt{4}=str2num(obj.inputs.condsAll.(condStr).(st).threshold)*obj.inputs.condsAll.(condStr).(st).si_pckt{1}*0.01; %Multiplying the Fc with the Intensity to apply Transformation
                                            catch
                                                errordlg('The "Facilitation" coupled to import from previous Measurement cannot be found in "Linked List".','BEST Toolbox');
                                            end
                                        case 'Plateau'
                                            try
                                                Pt=obj.sessions.(Session).(Protocol).Results.Plateau_SI_BaseUnits;
                                                obj.inputs.condsAll.(condStr).(st).threshold=num2str(Pt);
                                                obj.inputs.condsAll.(condStr).(st).si_pckt{4}=str2num(obj.inputs.condsAll.(condStr).(st).threshold)*obj.inputs.condsAll.(condStr).(st).si_pckt{1}*0.01; %Multiplying the Pt with the Intensity to apply Transformation
                                            catch
                                                errordlg('The "Plateau" coupled to import from previous Measurement cannot be found in "Linked List".','BEST Toolbox');
                                            end
                                    end
                                catch
                                    errordlg('The "Intensities Coupled Units" to import from previous Measurement cannot be found in "Linked List".','BEST Toolbox');
                                end
                        end
                        %% Checking Timing Onset Units
                        for iStimTiming=1:numel(obj.inputs.condsAll.(condStr).(st).stim_timing)
                            if strcmp(obj.inputs.condsAll.(condStr).(st).stim_timing_units{iStimTiming},'Import from Protocol')
                                try
                                    Pulse=['pulse' num2str(iStimTiming)'];
                                    Session=obj.inputs.condsAll.(condStr).(st).ImportERPLatency.(Pulse).Session;
                                    Protocol=obj.inputs.condsAll.(condStr).(st).ImportERPLatency.(Pulse).Protocol;
                                    Channel=obj.inputs.condsAll.(condStr).(st).ImportERPLatency.(Pulse).Channel;
                                    obj.inputs.condsAll.(condStr).(st).stim_timing{iStimTiming}=obj.sessions.(Session).(Protocol).results.ERPLatency.(Channel);
                                    obj.app.par.(obj.app.info.event.current_session).(obj.app.info.event.current_measure_fullstr).condsAll.(condStr).(st).stim_timing{iStimTiming}=obj.sessions.(Session).(Protocol).results.ERPLatency.(Channel);
                                catch
                                    errordlg('The "ERP Latency" to import from previous "ERP Measurement" cannot be found in "Linked List".','BEST Toolbox');
                                end
                            end
                        end
                        %% Checking Paired-CS Units
                        %% Checking ISI Units
                    end
                end
                %% Peak Frequency
                if obj.inputs.BrainState==2
                    try
                        if obj.inputs.ImportPeakFrequencyFromProtocols==2
                            try
                                Session=obj.inputs.ImportPeakFrequency.Session;
                                Protocol=obj.inputs.ImportPeakFrequency.Protocol;
                                Channel=obj.inputs.ImportPeakFrequency.Channel;
                                obj.inputs.PeakFrequency=obj.sessions.(Session).(Protocol).results.PeakFrequency.(Channel);
                                obj.app.par.(obj.app.info.event.current_session).(obj.app.info.event.current_measure_fullstr).PeakFrequency=num2str(obj.inputs.PeakFrequency);
                            catch
                                errordlg('The Peak Frequency to import from previous rsEEG Measurement Protocol cannot be found in "Linked List".','BEST Toolbox');
                            end
                        end
                    catch
                    end
                end
            end
            obj.inputs.totalConds=numel(obj.inputs.condMat(:,1));
        end
        
        
        function planTrials(obj)
            %% preparing trialMat
            
            obj.inputs.totalConds
            obj.inputs.colLabel.trials
            %% issue here that has to be updated
            cell2mat(obj.inputs.condMat(1,obj.inputs.colLabel.trials))
            for i=1:obj.inputs.totalConds
                cell2mat(obj.inputs.condMat(i,obj.inputs.colLabel.trials))
                cond_id(i,:)=ones(1,cell2mat(obj.inputs.condMat(i,obj.inputs.colLabel.trials)))*i; %previous this was different
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
            [m,~]=size(obj.inputs.trialMat);
            for i=1:m
                %% if a vector is given use that
            if ~isscalar(obj.inputs.trialMat{i,obj.inputs.colLabel.iti}) && numel(obj.inputs.trialMat{i,obj.inputs.colLabel.iti})==2
                    iti=obj.inputs.trialMat{i,obj.inputs.colLabel.iti};
                    obj.inputs.trialMat(i,obj.inputs.colLabel.iti)=num2cell(round((iti(1)+(iti(2)-iti(1) ).* rand(1,1)),3));
            end
            end
            
            obj.inputs.totalTrials=numel(obj.inputs.trialMat(:,1));
            
            %% preparing prepost stim time var and timeVector
            obj.planTrials_scopePeriods;
            %% preparing the timevector for meps
            %                 case {'MEP_Measurement','Motor Hotspot Search','Motor Threshold Hunting','MEP IOC'}
            %                     switch obj.app.par.hardware_settings.(char(obj.inputs.input_device)).slct_device
            %                         case 1 % boss box
            %                             mep_plot_time_vector=1:obj.inputs.sc_plot_total
            %                             mep_plot_time_vector=mep_plot_time_vector*5 %because sampling rate is 5khz and time to be in ms
            %                             obj.inputs.timeVect=mep_plot_time_vector+(((-1)*obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.sc_plot_first)/(obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).inputs.sc_samplingrate)*1000)
            %                         case 2 % fieldtrip
            %                             % http://www.fieldtriptoolbox.org/faq/how_should_i_get_started_with_the_fieldtrip_realtime_buffer/
            %                         case 3 %Future: input box
            %                         case 4  %s
            %                     end
            %
            %                 otherwise
            %             end
            %% Only for testing purpose #324324
            %             a=1;
            %             trial=load('trialMat_test.mat');
            %             trial_data=load('trial_test.mat');
            %             obj.inputs.trialMat=trial.trialMat;
            %             obj.inputs.umair=trial_data.trial_test;
            
        end
        function planTrialsExtended(obj)
            %% preparing trialMat
            for i=1:obj.inputs.totalConds
                cell2mat(obj.inputs.condMat(i,obj.inputs.colLabel.trials))
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
            if isvector(obj.inputs.condMat{1,obj.inputs.colLabel.iti}) && numel(obj.inputs.condMat{1,obj.inputs.colLabel.iti})==2
                [m,~]=size(obj.inputs.trialMat);
                for i=1:m
                    iti=obj.inputs.trialMat{i,obj.inputs.colLabel.iti};
                    obj.inputs.trialMat(i,obj.inputs.colLabel.iti)=num2cell(round((iti(1)+(iti(2)-iti(1) ).* rand(1,1)),3));
                end
            end
            
            obj.inputs.totalTrials=numel(obj.inputs.trialMat(:,1));
            
            %% preparing prepost stim time var and timeVector
            obj.planTrials_scopePeriods;
            %% preparing the timevector for meps
            %                 case {'MEP_Measurement','Motor Hotspot Search','Motor Threshold Hunting','MEP IOC'}
            %                     switch obj.app.par.hardware_settings.(char(obj.inputs.input_device)).slct_device
            %                         case 1 % boss box
            %                             mep_plot_time_vector=1:obj.inputs.sc_plot_total
            %                             mep_plot_time_vector=mep_plot_time_vector*5 %because sampling rate is 5khz and time to be in ms
            %                             obj.inputs.timeVect=mep_plot_time_vector+(((-1)*obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).info.sc_plot_first)/(obj.sessions.(obj.inputs.current_session).(obj.inputs.current_measurement).inputs.sc_samplingrate)*1000)
            %                         case 2 % fieldtrip
            %                             % http://www.fieldtriptoolbox.org/faq/how_should_i_get_started_with_the_fieldtrip_realtime_buffer/
            %                         case 3 %Future: input box
            %                         case 4  %s
            %                     end
            %
            %                 otherwise
            %             end
            %% Only for testing purpose #324324
            %             a=1;
            %             trial=load('trialMat_test.mat');
            %             trial_data=load('trial_test.mat');
            %             obj.inputs.trialMat=trial.trialMat;
            %             obj.inputs.umair=trial_data.trial_test;
            
        end
        function boot_inputdevice(obj)
            % 18-Mar-2020 11:01:08
            switch obj.app.par.hardware_settings.(char(obj.inputs.input_device)).slct_device
                case 1 % boss box
                    % do nothing as mainly the output will automatically
                    % bot it
                    %find unique values of the chType
                    %these unique values are also identifiers of the scope
                    %initialize all those scopes
                    UniqueChannelType=unique(obj.inputs.ChannelsTypeUnique);
                    for i=1:numel(UniqueChannelType)
                        switch UniqueChannelType{1,i}
                            case 'EMG'
                                obj.bossbox.EMGScopeBoot(obj.inputs.EMGDisplayPeriodPre,obj.inputs.EMGDisplayPeriodPost)
                                obj.boot_fieldtrip;
                            case 'IEEG'
                                obj.bossbox.IEEGScopeBoot
                            case 'IP'
                                obj.bossbox.IPScopeBoot
                            case 'IA'
                                obj.bossbox.IAScopeBoot
                            case 'EEG'
                                obj.bossbox.EEGScopeBoot(obj.inputs.EEGDisplayPeriodPre,obj.inputs.EEGDisplayPeriodPost);
                                obj.boot_fieldtrip;
                        end
                    end
                case 2 % fieldtrip
                    % http://www.fieldtriptoolbox.org/faq/how_should_i_get_started_with_the_fieldtrip_realtime_buffer/
                case 3 %Future: input box
                case 4  %Future: no input box is selected
                case 5 %Keyboard and Mouse
                    % No specific booting is required
                case 6 %NeurOne, Keyboard and Mouse
                    if obj.inputs.BrainState==2
                        if isempty(obj.bossbox), obj.boot_bossbox; end
                        UniqueChannelType=unique(obj.inputs.ChannelsTypeUnique);
                        for i=1:numel(UniqueChannelType)
                            switch UniqueChannelType{1,i}
                                case 'EMG' %Future Release: This can be depricated
                                    obj.bossbox.EMGScopeBoot(obj.inputs.EMGDisplayPeriodPre,obj.inputs.EMGDisplayPeriodPost)
                                case 'IEEG'
                                    obj.bossbox.IEEGScopeBoot
                                case 'IP'
                                    obj.bossbox.IPScopeBoot
                                case 'IA'
                                    obj.bossbox.IAScopeBoot
                            end
                        end
                    end
            end
        end
        function boot_outputdevice(obj)
            % 18-Mar-2020 11:01:08
            device=0;
            delete(instrfindall);
            for allDevices=1:obj.inputs.totalConds
                for alldevices=1:numel(obj.inputs.condMat{allDevices,obj.inputs.colLabel.outputDevices})
                    device=device+1;
                    allOutputDevices{device}=char(obj.inputs.condMat{allDevices,obj.inputs.colLabel.outputDevices}{1,alldevices});
                end
            end
            uniqueOutputDevices=unique(allOutputDevices);
            for i=1:numel(uniqueOutputDevices)
                switch obj.app.par.hardware_settings.(uniqueOutputDevices{i}).slct_device
                    case 1 % pc controlled magven
                        if isempty(obj.magven), obj.boot_magven; end
                    case 2 % pc controlled magstim
                        if isempty(obj.magStim), obj.boot_magstim;end
                    case 3 % pc controlled bistim
                        if isempty(obj.bistim), obj.boot_bistim; end
                    case 4 % pc controlled rapid
                        if isempty(obj.rapid), obj.boot_rapid; end
                    case 5 % boss box controlled magven
                        obj.inputs.output_device={uniqueOutputDevices{i}};
                        if isempty(obj.magven), obj.boot_magven; end
                        if isempty(obj.bossbox), obj.boot_bossbox; end
                    case 6% boss box controlled magstim
                        if isempty(obj.magven), obj.boot_magstim; end
                        if isempty(obj.bossbox), obj.boot_bossbox; end
                    case 7% boss box controlled bistim
                        if isempty(obj.magven), obj.boot_bistim; end
                        if isempty(obj.bossbox), obj.boot_bossbox; end
                    case 8% boss box controlled rapid
                        if isempty(obj.magven), obj.boot_rapid; end
                        if isempty(obj.bossbox), obj.boot_bossbox; end
                    case 9 %digitimer
                        obj.boot_digitimer(uniqueOutputDevices{i});
                        if obj.app.par.hardware_settings.(uniqueOutputDevices{i}).TriggerControl==1
                            if isempty(obj.bossbox), obj.boot_bossbox; end
                        end
                end
            end
        end
        function bootTrial(obj)
            obj.inputs.trial=0;
            obj.prepTrial;
        end
        function trigTrial(obj)
            
            switch obj.app.par.hardware_settings.(char(obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.outputDevices}{1,1})).slct_device
                case 1 % pc controlled magven
                case 2 % pc controlled magstim
                case 3 % pc controlled bistim
                case 4 % pc controlled rapid
                case {5,6,7,8} %bossbox controlled stimulator
                    switch obj.inputs.BrainState
                        case 1
                            obj.bossbox.multiPulse(obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.tpm});
                            %                             obj.bossbox.EEGScopeTrigger;
                            tic;
                        case 2
                            obj.bossbox.armPulse;
                            obj.bossbox.bb.triggers_remaining
                            tic;
                    end
                case 9 %% digitimer
                    switch obj.app.par.hardware_settings.(char(obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.outputDevices}{1,1})).TriggerControl
                        case 1 %bossdevice
                            switch obj.inputs.BrainState
                                case 1
                                    obj.bossbox.multiPulse(obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.tpm});
                                    tic;
                                case 2
                                    obj.bossbox.armPulse;
                                    tic;
                            end
                        case 2 %COM
                        case 3 %LPT
                        case 4 %Arduino % Just temporary
                            obj.bossbox.multiPulse([{0, obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.si}{1,1}{1,3}/1000};{2,1};{0,1} ]);
                        case 5 %Raspi
                        case 6 %Manual
                    end
                    
                case 10%simulation
                    disp simulatedTRIGGER
            end
        end
        function readTrial(obj)
            %device type
            %            then read all channels through it, basically a for loop
            disp enteredREAD
            switch obj.app.par.hardware_settings.(obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.inputDevices}).slct_device
                
                case 1 % boss box
                    unique_chLab=obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.chLab};
                    for i=1:numel(unique_chLab)
                        switch obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.chType}{1,i}
                            case 'IP'
                                obj.inputs.rawData.(unique_chLab{1,i}).data(obj.inputs.trial,1)=obj.bossbox.IPScopeRead;
                            case 'IEEG'
                                %                                 obj.inputs.rawData.(unique_chLab{1,i}).data(obj.inputs.trial,:)=obj.bossbox.IEEGScope.Data(:,1)';
                                %                                 obj.inputs.rawData.(unique_chLab{1,i}).data(obj.inputs.trial,:)=obj.best_DeMeanEEG(obj.bossbox.IEEGScope.Data(:,1)');
                                obj.inputs.rawData.(unique_chLab{1,i}).data(obj.inputs.trial,:)=obj.bossbox.IEEGScopeRead;
                                % obj.inputs.rawData.(unique_chLab{1,i}).time(obj.inputs.trial,:)=obj.bossbox.IEEGScope.Time(:,1)'; May Be Deprecated
                            case 'EMG'
                                EMGChannelIndex=find(strcmp(obj.app.par.hardware_settings.(obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.inputDevices}).NeurOneProtocolChannelLabels,unique_chLab{1,i}));
                                EMGChannelIndex=EMGChannelIndex-obj.bossbox.bb.eeg_channels;
                                [obj.inputs.rawData.(unique_chLab{1,i}).time(obj.inputs.trial,:), obj.inputs.rawData.(unique_chLab{1,i}).data(obj.inputs.trial,:)]=obj.bossbox.EMGScopeRead(EMGChannelIndex);
                                % 04-Jun-2020 19:58:28 Comment below two lines
                                %                                 obj.inputs.rawData.(unique_chLab{1,i}).data(obj.inputs.trial,:)=obj.best_VisualizationFilter([obj.sim_mep(1,700:1000), obj.sim_mep(1,1:699)]*1000*obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.si}{1,1}{1,1}*(randi([1 3])*0.10));
                                %                                 obj.inputs.rawData.(unique_chLab{1,i}).time(obj.inputs.trial,:)=obj.best_VisualizationFilter([obj.sim_mep(1,700:1000), obj.sim_mep(1,1:699)]*1000*obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.si}{1,1}{1,1}*(randi([1 3])*0.10));
                                %                                 obj.inputs.rawData.(unique_chLab{1,i}).data(obj.inputs.trial,:)=obj.best_VisualizationFilter([obj.sim_mep(1,700:1000), obj.sim_mep(1,1:699)]*1000*(randi([1 3])*0.10));
                                %                                 obj.inputs.rawData.(unique_chLab{1,i}).time(obj.inputs.trial,:)=obj.best_VisualizationFilter([obj.sim_mep(1,700:1000), obj.sim_mep(1,1:699)]*1000*(randi([1 3])*0.10));
                                % obj.inputs.rawData.(unique_chLab{1,i}).data(obj.inputs.trial,:)=obj.inputs.umair(obj.inputs.trial,:); % 04-Jun-2020 21:12:26
                                % obj.inputs.rawData.(unique_chLab{1,i}).time(obj.inputs.trial,:)=obj.inputs.umair(obj.inputs.trial,:);
                                % obj.inputs.rawData.(unique_chLab{1,i}).time(obj.inputs.trial,:)=obj.best_VisualizationFilter([obj.sim_mep(1,700:1000), obj.sim_mep(1,1:699)]*1000*(randi([1 3])*0.10));
                                %obj.bossbox.EMGScope;
                                %check=obj.bossbox.EMGScope.Data(:,1)';
                                %obj.inputs.rawData.(unique_chLab{1,i}).data(obj.inputs.trial,:)=[obj.bossbox.EMGScope.Data(:,1)]';
                                %obj.inputs.rawData.(unique_chLab{1,i}).data(obj.inputs.trial,:)=obj.best_VisualizationFilter([obj.bossbox.EMGScope.Data(:,1)]');
                                % NewUseThis obj.inputs.rawData.(unique_chLab{1,i}).data(obj.inputs.trial,:)=obj.best_VisualizationFilter(obj.bossbox.EMGScopeRead(obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.chID}{1,i}))   %%[obj.bossbox.EMGScope.Data(:,1)]');
                            case 'EEG'
%                                 [obj.inputs.rawData.time{obj.inputs.trial} , obj.inputs.rawData.data{obj.inputs.trial}]=obj.bossbox.EEGScopeRead;
try % 22-Jul-2020 07:30:33
    [~, obj.inputs.rawData.(unique_chLab{1,i}).data(obj.inputs.trial,:)]=obj.bossbox.EEGScopeRead;
catch
    
end
%                                 obj.fieldtrip.best2ftdata(obj.inputs.rawData,obj.inputs.trial,obj.inputs.input_device);
%                                 obj.fieldtrip.preprocess(obj.inputs.Configuration, obj.inputs.rawData.ftdata,obj.inputs.trial)
                        end
                    end
                case 2 % fieldtrip
                    % http://www.fieldtriptoolbox.org/faq/how_should_i_get_started_with_the_fieldtrip_realtime_buffer/
                case 3 %Future: input box
                case 4  % simulated data
                    for i=1:numel(obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.chLab})
                        obj.inputs.rawData.(obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.chLab}{1,i}).data(obj.inputs.trial,:)=(rand (1,obj.inputs.sc_samples))+5000000;
                    end
                case 5 % Keyboard and Mouse
                    obj.inputs.rawData.(obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.chLab}{1,1}).data(obj.inputs.trial,1)=obj.responseKeyboardAndMouse;
                case 6 % NeurOne Keyboard and Mouse
                    unique_chLab=unique(obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.chLab},'stable');
                    for i=1:numel(unique_chLab)
                        switch obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.chType}{1,i}
                            case 'IP'
                                obj.inputs.rawData.(unique_chLab{1,i}).data(obj.inputs.trial,1)=obj.bossbox.IPScopeRead;
                            case 'IEEG'
                                obj.inputs.rawData.(unique_chLab{1,i}).data(obj.inputs.trial,:)=obj.best_VisualizationFilter(obj.bossbox.IEEGScopeRead);
                            case 'EMG'
                                % %                                 obj.inputs.rawData.(unique_chLab{1,i}).data(obj.inputs.trial,:)=obj.best_VisualizationFilter([obj.sim_mep(1,700:1000), obj.sim_mep(1,1:699)]*1000*obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.si}{1,1}{1,1}*(randi([1 3])*0.10));
                                obj.inputs.rawData.(unique_chLab{1,i}).data(obj.inputs.trial,:)=obj.best_VisualizationFilter([obj.sim_mep(1,700:1000), obj.sim_mep(1,1:699)]*1000*(randi([1 3])*0.10));
                                obj.bossbox.EMGScope;
                                check=obj.bossbox.EMGScope.Data(:,1)';
                                % NewUseThis obj.inputs.rawData.(unique_chLab{1,i}).data(obj.inputs.trial,:)=obj.best_VisualizationFilter(obj.bossbox.EMGScopeRead(obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.chID}{1,i}))   %%[obj.bossbox.EMGScope.Data(:,1)]');
                            case 'EEG'
                            case 'Psyhcometric'
                                obj.inputs.rawData.(unique_chLab{1,i}).data(obj.inputs.trial,1)=obj.responseKeyboardAndMouse;
                        end
                    end
            end
            %% Start Scopes If needed
            switch obj.app.par.hardware_settings.(obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.inputDevices}).slct_device
                case 1 % boss box
                    unique_chLab=obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.chLab};
                    for i=1:numel(unique_chLab)
                        switch obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.chType}{1,i}
                            case 'IP'
                                
                            case 'IEEG'
                                
                            case 'EMG'
                                obj.bossbox.EMGScopeStart;
                            case 'EEG'
                        end
                    end
                case 2 % fieldtrip
                    % http://www.fieldtriptoolbox.org/faq/how_should_i_get_started_with_the_fieldtrip_realtime_buffer/
                case 3 %Future: input box
                case 4  % simulated data
                case 5 % Keyboard and Mouse
                case 6 % NeurOne Keyboard and Mouse
                    unique_chLab=obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.chLab};
                    for i=1:numel(unique_chLab)
                        switch obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.chType}{1,i}
                            case 'IP'
                                
                            case 'IEEG'
                                
                            case 'EMG'
                                obj.bossbox.EMGScopeStart;
                            case 'EEG'
                        end
                    end
            end
        end
        function processTrial(obj)
        end
        function plotTrial(obj)
            for i=1:numel(obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.chLab})
                disp entered--------------------------------------------------------====================
                
                obj.inputs.chLab_idx=i;
                (obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.measures}{1,i})
                switch (obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.measures}{1,i})
                    case 'MEP_Measurement'
                        if strcmpi(obj.inputs.Protocol,'MEP Dose Response Curve Protocol')
                            obj.mep_plot_conditionwise;
                        else
                            obj.mep_plot
                        end
                    case 'MEP_Measurement_Conditional'
                        obj.mep_plot_Extended;
                    case 'Threshold Trace'
                        switch obj.inputs.ThresholdMethod
                            case 1
                                obj.mep_threshold;
                            case 2
                                obj.mep_threshold_MLE;
                        end
                        obj.mep_threshold_trace_plot;
                    case 'IOC'
                    case 'Motor Hotspot Search'
                    case 'MEP Scatter Plot'
                        obj.mep_scat_plot;
                    case 'MEP IOC Fit'
                        obj.ioc_fit_plot;
                    case 'PhaseHistogram'
                        obj.PlotPhaseHistogram;
                    case 'TriggerLockedEEG'
                        obj.PlotTriggerLockedEEG;
                    case 'Psychometric Threshold Trace'
                        switch obj.inputs.ThresholdMethod
                            case 1
                                obj.psych_threshold;
                            case 2
                                obj.psych_threshold_MLE;
                        end
                        obj.psych_threshold_trace_plot;
                    case 'TEP Measurement Vertical Plot'
                        obj.TEPMeasurementVerticalPlot;
                    case 'TEP Measurement Single Plot'
%                         obj.TEPMeasurementSinglePlot;
                        obj.ERPTriggerLockedEEG;
                    case 'TEP Measurement Topo Plot'
                        obj.TEPMeasurementTopoPlot;
                    case 'TEP Measurement Multi Plot'
                        obj.TEPMeasurementMultiPlot;
                    case 'StatusTable'
                        obj.StatusTable;
                end
                AxesNum=obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.axesno}{1,obj.inputs.chLab_idx};
                AxesField=['ax' num2str(obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.axesno}{1,obj.inputs.chLab_idx})];
                CopiedAxes=copy(obj.app.pr.ax.(AxesField));
                CopiedAxes.Parent=[]; pause(0.1)
                obj.inputs.Figures{AxesNum}=CopiedAxes;
            end
        end
        function prepTrial(obj)
            if(obj.inputs.trial<obj.inputs.totalTrials)
                obj.inputs.trial=obj.inputs.trial+1;
                
                switch char(obj.inputs.measure_str)
                    case 'Motor Hotspot Search'
                        % no intensity update is required so do nothing
                        %  aaj ye neche valay sary eik sath comments bhi delete ker do aur dekh
                        %  lena k sahi chal rha he ya nahi
                        %                     case 'Motor Threshold Hunting'
                        %                         % if trialno 1 , read from the trial mat, otherwise ,
                        %                         % go to the thresholding function and read from there
                        % %                         obj.mep_threshold;
                        %                         % since the plotting is before the preparing, the
                        %                         % trials are handled
                        %                         for i=1:numel(obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.outputDevices})
                        %                             switch obj.app.par.hardware_settings.(char(obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.outputDevices}{1,i})).slct_device
                        %                                 case 1 % pc controlled magven
                        %                                     % --------------------------------------------------------ANOTHER
                        %                                     % switch case for the stim mode will be implanted here
                        %                                     % later on
                        %                                     obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.si}{1,i}
                        %                                     obj.magven.setAmplitude(obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.si}{1,i});
                        %                                 case 2 % pc controlled magstim
                        %                                     obj.boot_magstim;
                        %                                 case 3 % pc controlled bistim
                        %                                     obj.boot_bistim;
                        %                                 case 4 % pc controlled rapid
                        %                                     obj.boot_rapid;
                        %                                 case 5 % boss box controlled magven
                        %                                     obj.magven.setAmplitude(obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.si}{1,i});
                        %
                        %                                 case 6% boss box controlled magstim
                        %                                     obj.boot_magstim;
                        %                                     obj.boot_bossbox;
                        %                                 case 7% boss box controlled bistim
                        %                                     obj.boot_bistim;
                        %                                     obj.boot_bossbox;
                        %                                 case 8% boss box controlled rapid
                        %                                     obj.boot_rapid;
                        %                                     obj.boot_bossbox;
                        %                                 case 9 %simulation
                        %                                     disp triggered
                        %                                     obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.si}{1,i}
                        %                             end
                        %                         end
                    otherwise
                        
                        for i=1:numel(obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.outputDevices})
                            switch obj.app.par.hardware_settings.(char(obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.outputDevices}{1,i})).slct_device
                                case {1,5} % pc or bb controlled magven
                                    obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.stimMode}{1,i}
                                    switch char(obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.stimMode}{1,i})
                                        case 'single_pulse'
                                            obj.magven.arm;
                                            obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.si}{1,i}
                                            obj.magven.setAmplitude(obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.si}{1,i}{1,4});
                                        case 'paired_pulse'
                                            obj.magven.arm;
                                            obj.magven.setAmplitude(obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.si}{1,i}{1,4});
                                            obj.magven.setMode('Twin','Normal', 2, obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.si}{1,i}{1,3}, obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.si}{1,i}{1,4}/obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.si}{1,i}{1,2});
                                            disp PAIREDpulseENTERED
                                        case 'train'
                                            obj.magven.arm;
                                            obj.magven.setAmplitude(obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.si}{1,i}{1,4});
                                            obj.magven.setTrain(obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.si}{1,i}{1,2},obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.si}{1,i}{1,3},1,0.1);
                                            disp trainENTERED
                                    end
                                case {2,6} % pc or bb controlled magstim
                                    switch char(obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.stimMode})
                                        case 'single_pulse'
                                            obj.magven.setAmplitude(obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.si}{1,i});
                                        case 'paired_pulse'
                                        case 'train'
                                    end
                                case {3,7} % pc or bb controlled bistim
                                    switch char(obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.stimMode})
                                        case 'single_pulse'
                                            obj.magven.setAmplitude(obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.si}{1,i});
                                        case 'paired_pulse'
                                        case 'train'
                                    end
                                case {4,8} % pc or bb controlled rapid
                                    switch char(obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.stimMode})
                                        case 'single_pulse'
                                            obj.magven.setAmplitude(obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.si}{1,i});
                                        case 'paired_pulse'
                                        case 'train'
                                    end
                                case 9 %digitimer
                                    switch obj.app.par.hardware_settings.(char(obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.outputDevices}{1,i})).IntensityControl
                                        case 1 % Manual
                                            OutputDevice=char(obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.outputDevices}{1,i});
                                            obj.digitimer.(OutputDevice).setManualAmplitude(obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.si}{1,i}{1,4},OutputDevice);
                                        case 2 % Arduino
                                            OutputDevice=char(obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.outputDevices}{1,i});
                                            ST=3*13;
                                            obj.digitimer.(OutputDevice).setManualAmplitude(obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.si}{1,i}{1,2}*ST*0.01,OutputDevice);
                                    end
                                case 10 %simulation
                                    switch char(obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.stimMode}{1,i})
                                        case 'single_pulse'
                                            disp single_pulse_prepared
                                        case 'paired_pulse'
                                            disp paired_pulse_prepared
                                        case 'train'
                                            disp train_prepared
                                    end
                            end
                        end
                end
            end
        end
        function stimLoop(obj)
            for tt=1:obj.inputs.totalTrials
                tic
                obj.trigTrial;
                obj.readTrial;
                obj.plotTrial;
                tic
                obj.saveRuntime;
                toc
                pause(1)
                obj.prepTrial;
                wait_period=obj.inputs.trialMat{obj.inputs.trial-1,obj.inputs.colLabel.iti}-toc;
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
                toc
                disp('................................................');
            end
        end
        function save(obj)
            obj.app.cb_menu_save;
        end
        function saveRuntime(obj)
            tic
            switch obj.inputs.Protocol
                case 'MEP Hotspot Search Protocol'
                    label=obj.BESTData.label;
                    for i=1:size(label,1)
                        trial(i,:)=single(obj.inputs.rawData.(label{i}).data(obj.inputs.trial,:));
                        time(i,:)=obj.inputs.rawData.(label{i}).time(obj.inputs.trial,:);
                    end
                    obj.BESTData.trial(1,obj.inputs.trial)={trial};
                    obj.BESTData.time(1,obj.inputs.trial)={time};
                    obj.BESTData.results=obj.inputs.results;
                    % Write MEP Amplitude in trialinfo
                case 'MEP Measurement Protocol'
                    switch obj.inputs.BrainState
                        case 1 %Independent
                            label=obj.BESTData.label;
                            for i=1:size(label,1)
                                trial(i,:)=single(obj.inputs.rawData.(label{i}).data(obj.inputs.trial,:));
                                time(i,:)=obj.inputs.rawData.(label{i}).time(obj.inputs.trial,:);
                            end
                            obj.BESTData.trial(1,obj.inputs.trial)={trial};
                            obj.BESTData.time(1,obj.inputs.trial)={time};
                            obj.BESTData.results=obj.inputs.results;
                            % Write MEP Amplitude in trialinfo
                        case 2 %Dependent
                            label=obj.BESTData.label;
                            EEGDataSize=1:size(obj.inputs.rawData.OsscillationEEG.data,2);
                            trial(1,EEGDataSize)=single(obj.inputs.rawData.OsscillationEEG.data(obj.inputs.trial,:));
                            time(1,EEGDataSize)=obj.inputs.rawData.IEEG.time;
                            for i=2:size(label,1)
                                EMGDataSize=1:size(obj.inputs.rawData.(label{i}).data,2);
                                trial(i,EMGDataSize)=single(obj.inputs.rawData.(label{i}).data(obj.inputs.trial,:));
                                time(i,EMGDataSize)=obj.inputs.rawData.(label{i}).time(obj.inputs.trial,:);
                            end
                            obj.BESTData.trial(1,obj.inputs.trial)={trial};
                            obj.BESTData.time(1,obj.inputs.trial)={time};
                            obj.BESTData.results=obj.inputs.results;
                            % Write MEP Amplitude in trialinfo
                    end
                case 'MEP Dose Response Curve Protocol'
                    switch obj.inputs.BrainState
                        case 1 %Independent
                            label=obj.BESTData.label;
                            for i=1:size(label,1)
                                trial(i,:)=single(obj.inputs.rawData.(label{i}).data(obj.inputs.trial,:));
                                time(i,:)=obj.inputs.rawData.(label{i}).time(obj.inputs.trial,:);
                            end
                            obj.BESTData.trial(1,obj.inputs.trial)={trial};
                            obj.BESTData.time(1,obj.inputs.trial)={time};
                            obj.BESTData.results=obj.inputs.results;
                            % Write MEP Amplitude in trialinfo
                        case 2 %Dependent
                            label=obj.BESTData.label;
                            EEGDataSize=1:size(obj.inputs.rawData.OsscillationEEG.data,2);
                            trial(1,EEGDataSize)=single(obj.inputs.rawData.OsscillationEEG.data(obj.inputs.trial,:));
                            time(1,EEGDataSize)=obj.inputs.rawData.IEEG.time;
                            for i=2:size(label,1)
                                EMGDataSize=1:size(obj.inputs.rawData.(label{i}).data,2);
                                trial(i,EMGDataSize)=single(obj.inputs.rawData.(label{i}).data(obj.inputs.trial,:));
                                time(i,EMGDataSize)=obj.inputs.rawData.(label{i}).time(obj.inputs.trial,:);
                            end
                            obj.BESTData.trial(1,obj.inputs.trial)={trial};
                            obj.BESTData.time(1,obj.inputs.trial)={time};
                            obj.BESTData.results=obj.inputs.results;
                            % Write MEP Amplitude in trialinfo
                    end
                case 'Motor Threshold Hunting Protocol'
                    switch obj.inputs.BrainState
                        case 1 %Independent
                            label=obj.BESTData.label;
                            for i=1:size(label,1)
                                trial(i,:)=single(obj.inputs.rawData.(label{i}).data(obj.inputs.trial,:));
                                time(i,:)=obj.inputs.rawData.(label{i}).time(obj.inputs.trial,:);
                            end
                            obj.BESTData.trial(1,obj.inputs.trial)={trial};
                            obj.BESTData.time(1,obj.inputs.trial)={time};
                            obj.BESTData.results=obj.inputs.results;
                        case 2 %Dependent
                            label=obj.BESTData.label;
                            EEGDataSize=1:size(obj.inputs.rawData.OsscillationEEG.data,2);
                            trial(1,EEGDataSize)=single(obj.inputs.rawData.OsscillationEEG.data(obj.inputs.trial,:));
                            time(1,EEGDataSize)=obj.inputs.rawData.IEEG.time;
                            for i=2:size(label,1)
                                EMGDataSize=1:size(obj.inputs.rawData.(label{i}).data,2);
                                trial(i,EMGDataSize)=single(obj.inputs.rawData.(label{i}).data(obj.inputs.trial,:));
                                time(i,EMGDataSize)=obj.inputs.rawData.(label{i}).time(obj.inputs.trial,:);
                            end
                            obj.BESTData.trial(1,obj.inputs.trial)={trial};
                            obj.BESTData.time(1,obj.inputs.trial)={time};
                            obj.BESTData.results=obj.inputs.results;
                            % Write MEP Amplitude in trialinfo
                    end
                case 'Psychometric Threshold Hunting Protocol'
                    switch obj.inputs.BrainState
                        case 1 %Independent
                        case 2 %Dependent
                    end
                case 'rs EEG Measurement Protocol'
            end
            obj.sessions.(obj.app.info.event.current_session).(obj.app.info.event.current_measure_fullstr).ConditionsMatrix=obj.inputs.condMat;
            % obj.sessions.(obj.app.info.event.current_session).(obj.app.info.event.current_measure_fullstr).TrialsMatrix=obj.inputs.trialMat; % 04-Jun-2020 20:35:39
            obj.sessions.(obj.app.info.event.current_session).(obj.app.info.event.current_measure_fullstr).Figures=obj.inputs.Figures;
            try obj.sessions.(obj.app.info.event.current_session).(obj.app.info.event.current_measure_fullstr).Results=obj.inputs.results; catch, end %Known Error when run on PsychMTH
            toc
        end
        function TmrFcn(obj)
            pause(0.1)
            tic
            disp entered___________________TimerFCN__________
            BESTToolboxAutosave=obj.inputs;
            BESTToolboxAutosave.Test=rand(1e4,1e4);
            BESTToolboxAutosave.TestB= BESTToolboxAutosave.Test;
            BESTToolboxAutosave.TestC= BESTToolboxAutosave.Test;
            BESTToolboxAutosave.TestD= BESTToolboxAutosave.Test;
            BESTToolboxAutosave.TestE= BESTToolboxAutosave.Test;
            save(obj.info.save_str_runtime,'BESTToolboxAutosave','-v7.3');
            disp [[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[DONWWITHTIMER
            toc
        end
        function prepSaving(obj)
            %% Creating MatFile Name and File on a directory
            exp_name=obj.app.pmd.exp_title.editfield.String; exp_name(exp_name == ' ') = '_';
            subj_code=obj.app.pmd.sub_code.editfield.String; subj_code(subj_code == ' ') = '_';
            session=obj.app.info.event.current_session; session(session == '_') = '';
            measure=obj.app.info.event.current_measure_fullstr; measure(measure == '_') = '';
            Date=datestr(now,'yyyy-mm-dd HH:MM:SS'); Date(Date == ' ') = '_'; Date(Date == '-') = ''; Date(Date == ':') = '';
            FileName=['BESTData_' exp_name '_' subj_code '_' session '_' measure '_' Date '.mat'];
            % FilePath=cd;
            FullFileName=fullfile(obj.app.par.GlobalSettings.DataBaseDirectory,exp_name,subj_code,session,FileName);
            if ~exist(fullfile(obj.app.par.GlobalSettings.DataBaseDirectory,exp_name,subj_code,session), 'dir')
                mkdir(fullfile(obj.app.par.GlobalSettings.DataBaseDirectory,exp_name,subj_code,session));
            end
            obj.BESTData=matfile(FullFileName,'Writable',true);
            %% Writing General Variables
            obj.BESTData.pars=obj.app.par.(obj.app.info.event.current_session).(obj.app.info.event.current_measure_fullstr);
            obj.BESTData.experiment_name=exp_name;
            obj.BESTData.subject_name=subj_code;
            obj.BESTData.session_name=session;
            obj.BESTData.protocol_name=measure;
            %% Writing Protocol Specific Initial Variables
            switch obj.inputs.Protocol
                case 'MEP Hotspot Search Protocol'
                    %labels, fsample, chantype, chanunits, trialinfo collabels,
                    obj.BESTData.condition_matrix=obj.inputs.condMat;
                    obj.BESTData.trial_matrix=obj.inputs.trialMat;
                    obj.BESTData.fsample=5000;
                    obj.BESTData.label=obj.inputs.EMGDisplayChannels';
                    obj.BESTData.chantype=repmat({'emg'},numel(obj.inputs.EMGDisplayChannels),1);
                    obj.BESTData.chanunits=repmat({'uV'},numel(obj.inputs.EMGDisplayChannels),1);
                    obj.BESTData.timeunits='ms';
                    obj.BESTData.trilainfo_label={'TSIntensity (%MSO)','ITI(s)'};
                    switch obj.inputs.ProtocolMode
                        case 1 %Automatic
                            TS=vertcat(obj.inputs.trialMat{:,3}); TS=vertcat(TS{:,1}); TS=vertcat(TS{:,1});
                            obj.BESTData.trialinfo(1:numel(TS),1)=TS;
                            obj.BESTData.trialinfo(1:numel(vertcat(obj.inputs.trialMat{:,4})),2)=vertcat(obj.inputs.trialMat{:,4});
                        case 2 %Manual
                            obj.BESTData.trialinfo(1,1)=NaN;
                            obj.BESTData.trialinfo(1,2)=NaN;
                    end
                case 'MEP Measurement Protocol'
                    switch obj.inputs.BrainState
                        case 1 %Independent
                            obj.BESTData.condition_matrix=obj.inputs.condMat;
                            obj.BESTData.trial_matrix=obj.inputs.trialMat;
                            obj.BESTData.fsample=5000;
                            obj.BESTData.label=obj.inputs.EMGDisplayChannels';
                            obj.BESTData.timeunits='ms';
                            obj.BESTData.chantype=repmat({'emg'},numel(obj.inputs.EMGDisplayChannels),1);
                            obj.BESTData.chanunits=repmat({'uV'},numel(obj.inputs.EMGDisplayChannels),1);
                            obj.BESTData.trilainfo_label={'TSIntensity (%MSO)','ITI(s)'};
                            TS=vertcat(obj.inputs.trialMat{:,3}); TS=vertcat(TS{:,1}); TS=vertcat(TS{:,1});
                            obj.BESTData.trialinfo(1:numel(TS),1)=TS;
                            obj.BESTData.trialinfo(1:numel(vertcat(obj.inputs.trialMat{:,4})),2)=vertcat(obj.inputs.trialMat{:,4});
                        case 2 %Dependent
                            obj.BESTData.condition_matrix=obj.inputs.condMat;
                            obj.BESTData.trial_matrix=obj.inputs.trialMat;
                            obj.BESTData.fsample=5000;
                            obj.BESTData.timeunits='ms';
                            label{1}=erase(char(join(obj.inputs.RealTimeChannelsMontage)),' ');
                            obj.BESTData.label=[label{1}; obj.inputs.EMGDisplayChannels'];
                            obj.BESTData.chantype=[{'eeg'}; repmat({'emg'},numel(obj.inputs.EMGDisplayChannels),1)];
                            obj.BESTData.chanunits=repmat({'uV'},numel(obj.inputs.EMGDisplayChannels)+1,1);
                            obj.BESTData.trilainfo_label={'TSIntensity (%MSO)','ITI(s)','Target Phase(radians)','Phase Tolerance (radians)','Target Min Amplitude (uV)','Target Max Amplitude (uV)'};
                            TS=vertcat(obj.inputs.trialMat{:,3}); TS=vertcat(TS{:,1}); TS=vertcat(TS{:,1});
                            obj.BESTData.trialinfo(1:obj.inputs.totalTrials,1)=TS;
                            obj.BESTData.trialinfo(1:obj.inputs.totalTrials,2)=vertcat(obj.inputs.trialMat{:,4});
                            Phase=cell2mat(vertcat(obj.inputs.trialMat{:,obj.inputs.colLabel.phase}));
                            Amplitude=cell2mat(vertcat(obj.inputs.trialMat{:,obj.inputs.colLabel.IA}));
                            obj.BESTData.trialinfo(1:obj.inputs.totalTrials,3)=Phase(:,1);
                            obj.BESTData.trialinfo(1:obj.inputs.totalTrials,4)=Phase(:,2);
                            obj.BESTData.trialinfo(1:obj.inputs.totalTrials,5)=Amplitude(:,1);
                            obj.BESTData.trialinfo(1:obj.inputs.totalTrials,6)=Amplitude(:,2);
                    end
                case 'MEP Dose Response Curve Protocol'
                    switch obj.inputs.BrainState
                        case 1 %Independent
                            obj.BESTData.condition_matrix=obj.inputs.condMat;
                            obj.BESTData.trial_matrix=obj.inputs.trialMat;
                            obj.BESTData.fsample=5000;
                            obj.BESTData.label=[obj.inputs.EMGTargetChannels'; obj.inputs.EMGDisplayChannels'];
                            obj.BESTData.timeunits='ms';
                            obj.BESTData.chantype=repmat({'emg'},numel(obj.inputs.EMGTargetChannels)+numel(obj.inputs.EMGDisplayChannels),1);
                            obj.BESTData.chanunits=repmat({'uV'},numel(obj.inputs.EMGTargetChannels)+numel(obj.inputs.EMGDisplayChannels),1);
                            obj.BESTData.trilainfo_label={'TSIntensity (%MSO)','ITI(s)'};
                            TS=vertcat(obj.inputs.trialMat{:,3}); TS=vertcat(TS{:,1}); TS=vertcat(TS{:,1});
                            obj.BESTData.trialinfo(1:numel(TS),1)=TS;
                            obj.BESTData.trialinfo(1:numel(vertcat(obj.inputs.trialMat{:,4})),2)=vertcat(obj.inputs.trialMat{:,4});
                        case 2 %Dependent
                            obj.BESTData.condition_matrix=obj.inputs.condMat;
                            obj.BESTData.trial_matrix=obj.inputs.trialMat;
                            obj.BESTData.fsample=5000;
                            obj.BESTData.timeunits='ms';
                            label{1}=erase(char(join(obj.inputs.RealTimeChannelsMontage)),' ');
                            obj.BESTData.label=[obj.inputs.EMGTargetChannels'; obj.inputs.EMGDisplayChannels'];
                            obj.BESTData.chantype=[{'eeg'}; repmat({'emg'},numel(obj.inputs.EMGTargetChannels)+numel(obj.inputs.EMGDisplayChannels),1)];
                            obj.BESTData.chanunits=repmat({'uV'},numel(obj.inputs.EMGTargetChannels)+numel(obj.inputs.EMGDisplayChannels)+1,1);
                            obj.BESTData.trilainfo_label={'TSIntensity (%MSO)','ITI(s)','Target Phase(radians)','Phase Tolerance (radians)','Target Min Amplitude (uV)','Target Max Amplitude (uV)'};
                            TS=vertcat(obj.inputs.trialMat{:,3}); TS=vertcat(TS{:,1}); TS=vertcat(TS{:,1});
                            obj.BESTData.trialinfo(1:obj.inputs.totalTrials,1)=TS;
                            obj.BESTData.trialinfo(1:obj.inputs.totalTrials,2)=vertcat(obj.inputs.trialMat{:,4});
                            Phase=cell2mat(vertcat(obj.inputs.trialMat{:,obj.inputs.colLabel.phase}));
                            Amplitude=cell2mat(vertcat(obj.inputs.trialMat{:,obj.inputs.colLabel.IA}));
                            obj.BESTData.trialinfo(1:obj.inputs.totalTrials,3)=Phase(:,1);
                            obj.BESTData.trialinfo(1:obj.inputs.totalTrials,4)=Phase(:,2);
                            obj.BESTData.trialinfo(1:obj.inputs.totalTrials,5)=Amplitude(:,1);
                            obj.BESTData.trialinfo(1:obj.inputs.totalTrials,6)=Amplitude(:,2);
                    end
                case 'Motor Threshold Hunting Protocol'
                    switch obj.inputs.BrainState
                        case 1 %Independent
                            conds=fieldnames(obj.inputs.condsAll);
                            for icdts=1:numel(conds)
                                EMGTargetChannels(icdts)=obj.inputs.condsAll.(conds{icdts,1}).targetChannel;
                            end
                            obj.BESTData.condition_matrix=obj.inputs.condMat;
                            obj.BESTData.trial_matrix=obj.inputs.trialMat;
                            obj.BESTData.fsample=5000;
                            obj.BESTData.label=[EMGTargetChannels'; obj.inputs.EMGDisplayChannels'];
                            obj.BESTData.timeunits='ms';
                            obj.BESTData.chantype=repmat({'emg'},numel(EMGTargetChannels)+numel(obj.inputs.EMGDisplayChannels),1);
                            obj.BESTData.chanunits=repmat({'uV'},numel(EMGTargetChannels)+numel(obj.inputs.EMGDisplayChannels),1);
                            obj.BESTData.trilainfo_label={'TSIntensity (%MSO)','ITI(s)'};
                            TS=vertcat(obj.inputs.trialMat{:,3}); TS=vertcat(TS{:,1}); TS=vertcat(TS{:,1});
                            obj.BESTData.trialinfo(1:numel(TS),1)=TS;
                            obj.BESTData.trialinfo(1:numel(vertcat(obj.inputs.trialMat{:,4})),2)=vertcat(obj.inputs.trialMat{:,4});
                        case 2 %Dependent
                            conds=fieldnames(obj.inputs.condsAll);
                            for icdts=1:numel(conds)
                                EMGTargetChannels(icdts)=obj.inputs.condsAll.(conds{icdts,1}).targetChannel;
                            end
                            obj.inputs.EMGTargetChannels=EMGTargetChannels;
                            obj.BESTData.condition_matrix=obj.inputs.condMat;
                            obj.BESTData.trial_matrix=obj.inputs.trialMat;
                            obj.BESTData.fsample=5000;
                            obj.BESTData.timeunits='ms';
                            label{1}=erase(char(join(obj.inputs.RealTimeChannelsMontage)),' ');
                            obj.BESTData.label=[obj.inputs.EMGTargetChannels'; obj.inputs.EMGDisplayChannels'];
                            obj.BESTData.chantype=[{'eeg'}; repmat({'emg'},numel(obj.inputs.EMGTargetChannels)+numel(obj.inputs.EMGDisplayChannels),1)];
                            obj.BESTData.chanunits=repmat({'uV'},numel(obj.inputs.EMGTargetChannels)+numel(obj.inputs.EMGDisplayChannels)+1,1);
                            obj.BESTData.trilainfo_label={'TSIntensity (%MSO)','ITI(s)','Target Phase(radians)','Phase Tolerance (radians)','Target Min Amplitude (uV)','Target Max Amplitude (uV)'};
                            TS=vertcat(obj.inputs.trialMat{:,3}); TS=vertcat(TS{:,1}); TS=vertcat(TS{:,1});
                            obj.BESTData.trialinfo(1:obj.inputs.totalTrials,1)=TS;
                            obj.BESTData.trialinfo(1:obj.inputs.totalTrials,2)=vertcat(obj.inputs.trialMat{:,4});
                            Phase=cell2mat(vertcat(obj.inputs.trialMat{:,obj.inputs.colLabel.phase}));
                            Amplitude=cell2mat(vertcat(obj.inputs.trialMat{:,obj.inputs.colLabel.IA}));
                            obj.BESTData.trialinfo(1:obj.inputs.totalTrials,3)=Phase(:,1);
                            obj.BESTData.trialinfo(1:obj.inputs.totalTrials,4)=Phase(:,2);
                            obj.BESTData.trialinfo(1:obj.inputs.totalTrials,5)=Amplitude(:,1);
                            obj.BESTData.trialinfo(1:obj.inputs.totalTrials,6)=Amplitude(:,2);
                    end
                case 'Psychometric Threshold Hunting Protocol'
                    switch obj.inputs.BrainState
                        case 1 %Independent
                        case 2 %Dependent
                    end
                case 'rs EEG Measurement Protocol'
                    obj.BESTData.fsample=5000;
                    obj.BESTData.label=obj.inputs.results.RawEEGData.label;
                    obj.BESTData.chantype=repmat({'eeg'},numel(obj.inputs.results.RawEEGData.label),1);
                    obj.BESTData.chanunits=repmat({'uV'},numel(obj.inputs.results.RawEEGData.label),1);
                    obj.BESTData.timeunits='ms';
                    obj.BESTData.trial=obj.inputs.results.RawEEGData.trial;
                    obj.BESTData.time=obj.inputs.results.RawEEGData.time;
                    results=rmfield(obj.inputs.results,'RawEEGData');
                    obj.BESTData.results=results;
            end
        end
        function saveFigures(obj)
            exp_name=obj.app.pmd.exp_title.editfield.String; exp_name(exp_name == ' ') = '_';
            subj_code=obj.app.pmd.sub_code.editfield.String; subj_code(subj_code == ' ') = '_';
            session=obj.app.info.event.current_session; session(session == '_') = '';
            measure=obj.app.info.event.current_measure_fullstr; measure(measure == '_') = '';
            FigureFileName1=erase(obj.info.matfilstr,'.mat');
            for iaxes=1:obj.app.pr.axesno
                if ~strcmp(obj.app.pr.ax_ChannelLabels{1,iaxes},'StatusTable')
                    FigureFileName=[FigureFileName1 '_' obj.app.pr.ax_measures{1,iaxes} '_' obj.app.pr.ax_ChannelLabels{1,iaxes}];
                    FullFileName=fullfile(obj.app.par.GlobalSettings.DataBaseDirectory,exp_name,subj_code,session,measure,FigureFileName);
                    if ~exist(fullfile(obj.app.par.GlobalSettings.DataBaseDirectory,exp_name,subj_code,session,measure), 'dir')
                        mkdir(fullfile(obj.app.par.GlobalSettings.DataBaseDirectory,exp_name,subj_code,session,measure));
                    end
                    ax=['ax' num2str(iaxes)];
                    Figure=figure('Visible','off','CreateFcn','set(gcf,''Visible'',''on'')','Name',FigureFileName,'NumberTitle','off');
                    copyobj(obj.app.pr.ax.(ax),Figure)
                    set( gca, 'Units', 'normalized', 'Position', [0.2 0.2 0.7 0.7] );
                    saveas(Figure,FullFileName,'fig');
                    close(Figure)
                end
            end
        end
        function completed(obj)
            questdlg('This Protocol has been Completed or Stopped, click Okay to continue.','Status','Okay','Okay');
            obj.app.pmd.RunStopButton.String='Stop';
            obj.app.RunStopButton
        end
        function rseegInProcess(obj,Action)
            if strcmpi(Action,'open')
                obj.inputs.Handles.InProcessFigure=figure('Name','BEST Toolbox','numbertitle', 'off','ToolBar', 'none','MenuBar', 'none','WindowStyle', 'normal','Units', 'normal', 'Position', [0.5 0.5 .4 .05]);
                uicontrol( 'Style','text','Parent', obj.inputs.Handles.InProcessFigure,'String','BEST Toolbox is processing EEG Data, please observe MATLAB command line for further details.','FontSize',11,'HorizontalAlignment','center','Units','normalized','Position',[0.05 0.5 1 0.4]);
            elseif strcmpi (Action,'close')
                close (obj.inputs.Handles.InProcessFigure)
            end
        end
        
        function best_mep(obj)
            obj.save;
            obj.factorizeConditionsExtended %obj.factorizeConditions
            obj.planTrials
            obj.app.resultsPanel;
            obj.boot_outputdevice;
            obj.boot_inputdevice;
            obj.prepSaving;
            obj.bootTrial;
            obj.stimLoop;
            obj.save;
            obj.saveFigures;
            obj.completed;
        end
        function best_hotspot(obj)
            obj.save;
            obj.factorizeConditions;
            obj.planTrials;
            obj.app.resultsPanel;
            obj.boot_outputdevice;
            obj.boot_inputdevice;
            obj.prepSaving;
            obj.bootTrial;
            obj.stimLoop;
            obj.save;
            obj.saveFigures;
            obj.completed;
        end
        function best_hotspot_manual(obj)
            obj.save;
            obj.factorizeConditions;
            obj.planTrials;
            obj.app.resultsPanel;
            obj.boot_outputdevice;
            obj.boot_inputdevice;
            obj.prepSaving;
            obj.bootTrial;
            stimLoop;
            obj.save;
            obj.saveFigures;
            obj.completed;
            function stimLoop
                while true
                    while strcmpi(obj.bossbox.EMGScope.Status,'finished')
                        obj.readTrial;
                        obj.plotTrial;
                        obj.saveRuntime;
                        obj.prepTrial;
                    end
                    if(obj.inputs.stop_event==1) || obj.inputs.trial==obj.inputs.totalTrials
                        disp('BEST Toolbox Manual Hotspot Search has been stopped')
                        obj.inputs.stop_event=0;
                        break;
                    end
                    drawnow
                end
            end
        end
        function best_drc(obj)
            obj.save;
            obj.factorizeConditions
            obj.planTrials
            obj.app.resultsPanel;
            obj.boot_outputdevice;
            obj.boot_inputdevice;
            obj.prepSaving;
            obj.bootTrial;
            obj.stimLoop;
            obj.save;
            obj.saveFigures;
            obj.completed;
%% all the upper will be uncommented when prepared completely
%             obj.save;
%             obj.factorizeConditions
%             obj.planTrials
%             obj.app.resultsPanel;
%             obj.boot_outputdevice;
%             obj.boot_inputdevice;
%             obj.prepSaving;
%             obj.bootTrial;
%             obj.drc_bs2
%             obj.save;
%             obj.saveFigures;
%             obj.completed;
        end
        function best_mth(obj)
            obj.save;
            obj.factorizeConditions
            obj.planTrials
            obj.app.resultsPanel;
            obj.boot_outputdevice;
            obj.boot_inputdevice;
            obj.prepSaving;
            obj.bootTrial;
            obj.stimLoop;
            obj.save;
            obj.saveFigures;
            obj.completed;
        end
        function best_psychmth (obj)
            obj.save;
            obj.factorizeConditions
            obj.planTrials
            obj.app.resultsPanel;
            obj.boot_outputdevice;
            obj.boot_inputdevice;
            obj.prepSaving;
            obj.bootTrial;
            obj.stimLoop;
            obj.save;
            obj.saveFigures;
            obj.completed;
        end
        function h5(obj)
            tic;
            saved=struct;
            saved.par=obj.app.par;
            saved.inputs=obj.inputs;
            %           saveh5(saved,'saved.best_toolbox'); %% Complete but slow on cells
            %           struct2h5('savedNWE.h5', '/savedNWE', saved); %Not much useful as required new name of file everytime and loading is alse a bit problemtic
            
        end
        function best_rseeg(obj)
            obj.factorizeConditions;
            obj.app.resultsPanel;
            obj.rseegInProcess('open');
            obj.boot_bossbox;
            obj.boot_fieldtrip;
            obj.save;
            obj.bossbox.EEGScopeBoot(0,obj.inputs.EEGAcquisitionPeriod*60*1000);
            obj.bossbox.EEGScopeStart; obj.bossbox.EEGScopeTrigger;
            [obj.inputs.rawData.EEG.Time , obj.inputs.rawData.EEG.Data]=obj.bossbox.EEGScopeRead;
            switch obj.inputs.SpectralAnalysis
                case 1 %IRASA
                    obj.fieldtrip.irasa(obj.inputs.rawData.EEG,obj.inputs.input_device);
                case 2 %FFT
                    obj.fieldtrip.fft(obj.inputs.rawData.EEG,obj.inputs.input_device);
            end
            obj.rseegInProcess('close');
            obj.prepSaving;
            obj.saveFigures;
            obj.completed;
        end
        function best_rtms(obj)
            obj.save;
            obj.factorizeConditions
            obj.planTrials
            obj.app.resultsPanel;
            obj.boot_outputdevice;
            obj.boot_inputdevice;
            if obj.inputs.BrainState==2, obj.bossbox.IAScopeBoot; end % This is bascially an Anomoly which can be generalized in Future Releases
            obj.bootTrial;
            obj.stimLoop;
            obj.prepSaving;
            obj.save;
            obj.saveFigures;
            obj.completed;
        end
        function best_tephs(obj)
            obj.save;
            obj.factorizeConditions;
            obj.planTrials;
            obj.app.resultsPanel;
            obj.boot_outputdevice;
            obj.boot_inputdevice;
            obj.bootTrial;
            obj.stimLoop;
            obj.prepSaving;
            obj.save;
            obj.saveFigures;
            obj.completed;
        end
        function best_erp(obj)
            obj.save;
            obj.factorizeConditions;
            obj.planTrials;
            obj.app.resultsPanel;
            obj.boot_outputdevice;
            obj.boot_inputdevice;
            obj.bootTrial;
            obj.stimLoop;
            obj.save;
            obj.saveFigures;
            obj.completed;
        end
        function best_compile(obj)
            obj.save;
            obj.factorizeConditions;
            obj.planTrials;
            obj.app.resultsPanel;
            obj.boot_outputdevice;
            obj.boot_inputdevice;
        end
        function best_multimodal(obj)
            obj.factorizeConditions
            obj.planTrials
            obj.app.resultsPanel;
            obj.boot_inputdevice;
            obj.boot_outputdevice;
            obj.bootTrial;
            obj.stimLoop
        end
        
        function mep_plot_OLD_May_Be_Depricated(obj)
            
            
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
                    obj.info.plt.(ax).current=plot(obj.inputs.timeVect,obj.inputs.rawData.(obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.chLab}{1,obj.inputs.chLab_idx}).data(obj.inputs.trial,:),'Color',[1 0 0],'LineWidth',2);
                    xlim([obj.inputs.timeVect(1), obj.inputs.timeVect(end)]);
                    mat1=obj.inputs.prestim_scope_plt*(-1):20:obj.inputs.poststim_scope_plt;
                    mat2=[0 obj.inputs.mep_onset*1000 obj.inputs.mep_offset*1000 obj.inputs.timeVect(end)];
                    mat=unique(sort([mat1 mat2]));
                    xticks(mat);
                    xlabel('Time (ms)');
                    
                    ylim([obj.inputs.ylimMin obj.inputs.ylimMax]);
                    mat3=linspace(obj.inputs.ylimMin,obj.inputs.ylimMax,5);
                    mat4=unique(sort([0 mat3]));
                    yticks(mat4);
                    ylabel('EMG Potential (\mu V)');
                    % %                     obj.info.plt.(ax).current.UserData.VerticalGridXY
                    % %                     obj.info.handle_gridxy=gridxy([0 (obj.inputs.mep_onset):0.25:(obj.inputs.mep_offset)],'Color',[219/255 246/255 255/255],'linewidth',4) ;
                    
                    gridxy([0 (obj.inputs.mep_onset):0.25:(obj.inputs.mep_offset)],'Color',[219/255 246/255 255/255],'linewidth',4) ;
                    obj.info.handle_gridxy_mt_lines=gridxy([],[-0.05*1000 0.05*1000],'Color',[0.45 0.45 0.45],'linewidth',1,'LineStyle','--') ;
                    uistack(obj.info.handle_gridxy_mt_lines,'top');
                case 2
                    delete(obj.info.plt.(ax).current)
                    obj.info.plt.(ax).past=plot(obj.inputs.timeVect,obj.inputs.rawData.(obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.chLab}{1,obj.inputs.chLab_idx}).data(obj.inputs.trial-1,:),'Color',[0.75 0.75 0.75]);
                    obj.info.plt.(ax).mean=plot(obj.inputs.timeVect,mean(obj.inputs.rawData.(obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.chLab}{1,obj.inputs.chLab_idx}).data(:,:)),'color',[0,0,0],'LineWidth',1.5);
                    obj.info.plt.(ax).current=plot(obj.inputs.timeVect,obj.inputs.rawData.(obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.chLab}{1,obj.inputs.chLab_idx}).data(obj.inputs.trial,:),'Color',[1 0 0],'LineWidth',2);
                    obj.info.plt.(ax).mean.UserData.TrialNoForMean=1;
                otherwise
                    obj.info.plt.(ax).past=plot(obj.inputs.timeVect,obj.inputs.rawData.(obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.chLab}{1,obj.inputs.chLab_idx}).data(obj.inputs.trial-1,:),'Color',[0.75 0.75 0.75]);
                    obj.info.plt.(ax).mean.YData=mean(obj.inputs.rawData.(obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.chLab}{1,obj.inputs.chLab_idx}).data(obj.info.plt.(ax).mean.UserData.TrialNoForMean:end,:));
                    obj.info.plt.(ax).current.YData=obj.inputs.rawData.(obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.chLab}{1,obj.inputs.chLab_idx}).data(obj.inputs.trial,:);
                    uistack(obj.info.plt.(ax).current,'top');
                    %                     legend(obj.app.pr.ax.(ax),'a','b','c','Location','southoutside','ornt','horizontal','bkgd','boxoff')
                    LegendGrouping=[obj.info.plt.(ax).past; obj.info.plt.(ax).mean; obj.info.plt.(ax).current];
                    legend(LegendGrouping, 'Previous', 'Mean', 'Latest','Location','southoutside','Orientation','horizontal');
                    
                    %                      legend(LegendGrouping, 'Previous MEPs', 'Mean Plot', 'Latest MEP','FontSize',11,'Location','southoutside','Orientation','horizontal');
                    % %                     delete(obj.info.plt.(ax).current)
                    % %                     delete(obj.info.plt.(ax).mean)
                    % %                     obj.info.plt.(ax).mean=plot(obj.inputs.timeVect,mean(obj.inputs.rawData.(obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.chLab}{1,obj.inputs.chLab_idx}).data(obj.info.plt.(ax).mean.UserData.TrialNoForMean:end,:)),'color',[0,0,0],'LineWidth',1.5);
                    % %                     obj.info.plt.(ax).current=plot(obj.inputs.timeVect,obj.inputs.rawData.(obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.chLab}{1,obj.inputs.chLab_idx}).data(obj.inputs.trial,:),'Color',[1 0 0],'LineWidth',2);
            end
            obj.mep_amp;
            %% Update the Current MEP Amp & Mean MEP Amp Stauts on Axes
            CurrentMEPAmp=round((obj.inputs.results.(obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.chLab}{1,obj.inputs.chLab_idx}).MEPAmplitude(obj.inputs.trial,1))/1000);
            if obj.inputs.trial==1
                MeanMEPAmp=CurrentMEPAmp;
            elseif obj.inputs.trial==2
                MeanMEPAmp=round(mean(obj.inputs.results.(obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.chLab}{1,obj.inputs.chLab_idx}).MEPAmplitude(:,1))/1000);
            else
                MeanMEPAmp=round(mean(obj.inputs.results.(obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.chLab}{1,obj.inputs.chLab_idx}).MEPAmplitude(obj.info.plt.(ax).mean.UserData.TrialNoForMean:end,1))/1000);
            end
            textMEPAmpStatus={['Latest MEP Amp (mV):' num2str(CurrentMEPAmp)],['Mean MEP Amp (mV):' num2str(MeanMEPAmp)]};
            if isfield(obj.app.pr.ax.(ax).UserData,'status')
                obj.app.pr.ax.(ax).UserData.status.String=textMEPAmpStatus;
            else
                obj.app.pr.ax.(ax).UserData.status=text(obj.app.pr.ax.(ax),1,1,textMEPAmpStatus,'units','normalized','HorizontalAlignment','right','VerticalAlignment','cap','color',[0.45 0.45 0.45]);
            end
            %             obj.app.pr.current_mep.(ax).String=obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.mepamp};
            %             obj.app.pr.mean_mep.(ax).String=obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.mepamp};
            %             ylim auto
            
        end
        function mep_plot(obj)
            ax=['ax' num2str(obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.axesno}{1,obj.inputs.chLab_idx})];
            axes(obj.app.pr.ax.(ax)), hold on,
            obj.mep_amp;
            CurrentMEPAmp=round((obj.inputs.results.(obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.chLab}{1,obj.inputs.chLab_idx}).MEPAmplitude(obj.inputs.trial,1))/1000,3);
            if ~isfield(obj.inputs.Handles,ax)%.(ax),'current')
                obj.inputs.Handles.(ax).current=plot(obj.inputs.timeVect,obj.inputs.rawData.(obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.chLab}{1,obj.inputs.chLab_idx}).data(obj.inputs.trial,:),'Color',[1 0 0],'LineWidth',2);
                %For Past Backup: xlim([obj.inputs.timeVect(1), obj.inputs.timeVect(end)]);
                xlim([obj.inputs.EMGXLimit(1), obj.inputs.EMGXLimit(2)]);
                mat1=linspace(obj.inputs.EMGXLimit(1),obj.inputs.EMGXLimit(2),10);% obj.inputs.prestim_scope_plt*(-1):20:obj.inputs.poststim_scope_plt;
                mat2=[0 obj.inputs.mep_onset*1000 obj.inputs.mep_offset*1000 obj.inputs.EMGXLimit(2)];
                mat=unique(sort([mat1 mat2]));
                xticks(mat);
                xtickformat('%.0f');
                xlabel('Time (ms)');
                ylim([obj.inputs.ylimMin obj.inputs.ylimMax]);
                mat3=linspace(obj.inputs.ylimMin,obj.inputs.ylimMax,5);
                mat4=unique(sort([0 mat3]));
                yticks(mat4);
                ylabel('EMG Potential (\mu V)');
                obj.app.pr.ax.(ax).UserData.GridLines=gridxy([0 (obj.inputs.mep_onset):0.25:(obj.inputs.mep_offset)],'Color',[219/255 246/255 255/255],'linewidth',4) ;
                obj.info.handle_gridxy_mt_lines=gridxy([],[-0.05*1000 0.05*1000],'Color',[0.45 0.45 0.45],'linewidth',1,'LineStyle','--') ;
                obj.app.pr.ax.(ax).UserData.GridLines.Annotation.LegendInformation.IconDisplayStyle = 'off';
                obj.info.handle_gridxy_mt_lines.Annotation.LegendInformation.IconDisplayStyle = 'off';
                uistack(obj.info.handle_gridxy_mt_lines,'top');
                MeanMEPAmp=CurrentMEPAmp;
            elseif isfield(obj.inputs.Handles.(ax),'past')
                obj.inputs.Handles.(ax).past=plot(obj.inputs.timeVect,obj.inputs.rawData.(obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.chLab}{1,obj.inputs.chLab_idx}).data(obj.inputs.trial-1,:),'Color',[0.75 0.75 0.75]);
                obj.inputs.Handles.(ax).mean.YData=mean(obj.inputs.rawData.(obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.chLab}{1,obj.inputs.chLab_idx}).data(obj.inputs.Handles.(ax).mean.UserData.TrialNoForMean:end,:));
                obj.inputs.Handles.(ax).current.YData=obj.inputs.rawData.(obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.chLab}{1,obj.inputs.chLab_idx}).data(obj.inputs.trial,:);
                uistack(obj.inputs.Handles.(ax).current,'top');
                LegendGrouping=[obj.inputs.Handles.(ax).past; obj.inputs.Handles.(ax).mean; obj.inputs.Handles.(ax).current];
                legend(LegendGrouping, 'Previous', 'Mean', 'Latest','Location','southoutside','Orientation','horizontal');
                MeanMEPAmp=round(mean(obj.inputs.results.(obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.chLab}{1,obj.inputs.chLab_idx}).MEPAmplitude(obj.inputs.Handles.(ax).mean.UserData.TrialNoForMean:end,1))/1000,3);
            else
                delete(obj.inputs.Handles.(ax).current)
                obj.inputs.Handles.(ax).past=plot(obj.inputs.timeVect,obj.inputs.rawData.(obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.chLab}{1,obj.inputs.chLab_idx}).data(obj.inputs.trial-1,:),'Color',[0.75 0.75 0.75]);
                obj.inputs.Handles.(ax).mean=plot(obj.inputs.timeVect,mean(obj.inputs.rawData.(obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.chLab}{1,obj.inputs.chLab_idx}).data(:,:)),'color',[0,0,0],'LineWidth',1.5);
                obj.inputs.Handles.(ax).current=plot(obj.inputs.timeVect,obj.inputs.rawData.(obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.chLab}{1,obj.inputs.chLab_idx}).data(obj.inputs.trial,:),'Color',[1 0 0],'LineWidth',2);
                obj.inputs.Handles.(ax).mean.UserData.TrialNoForMean=1;
                MeanMEPAmp=round(mean(obj.inputs.results.(obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.chLab}{1,obj.inputs.chLab_idx}).MEPAmplitude(:,1))/1000,3);
            end
            %% Update the Current MEP Amp & Mean MEP Amp Stauts on Axes
            textMEPAmpStatus={['Latest MEP Amp (mV):' num2str(CurrentMEPAmp)],['Mean MEP Amp (mV):' num2str(MeanMEPAmp)]};
            if isfield(obj.app.pr.ax.(ax).UserData,'status')
                obj.app.pr.ax.(ax).UserData.status.String=textMEPAmpStatus;
            else
                obj.app.pr.ax.(ax).UserData.status=text(obj.app.pr.ax.(ax),1,1,textMEPAmpStatus,'units','normalized','HorizontalAlignment','right','VerticalAlignment','cap','color',[0.45 0.45 0.45]);
            end
        end
        function mep_plot_conditionwise(obj)
            ax=['ax' num2str(obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.axesno}{1,obj.inputs.chLab_idx})];
            axes(obj.app.pr.ax.(ax)), hold on,
            ThisChannelName=obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.chLab}{1,obj.inputs.chLab_idx};
            %% Preparing Condition wrt to Dose Function
            switch obj.inputs.DoseFunction
                case {1,2,3}
                    cd=['cd' num2str(obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.stimcdMrk})];
                case 4
                    cd=['cd' num2str(obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.iti})];
                otherwise
                    error('BEST Toolbox: MEP Plot Function does not any have Dose Function to decide about plot condition.')
            end
            if ~(isfield(obj.inputs.Handles,cd))
                switch obj.inputs.DoseFunction
                    case 1 %TS
                        DisplayName=['TS:' num2str(obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.si}{1,1}{1,1})];
                        obj.app.pr.ax.(ax).UserData.ColorsIndex=obj.app.pr.ax.(ax).UserData.ColorsIndex+1;
                    case 2 %CS
                        if obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.si}{1,1}{1,2}~=0
                            DisplayName=['CS:' num2str(obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.si}{1,1}{1,2})];
                        else
                            DisplayName=['TS:' num2str(obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.si}{1,1}{1,1})];
                        end
                        obj.app.pr.ax.(ax).UserData.ColorsIndex=obj.app.pr.ax.(ax).UserData.ColorsIndex+1;
                    case 3 %ISI
                        if obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.si}{1,1}{1,3}~=0
                            DisplayName=['ISI:' num2str(obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.si}{1,1}{1,3})];
                        else
                            DisplayName=['TS:' num2str(obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.si}{1,1}{1,1})];
                        end
                        obj.app.pr.ax.(ax).UserData.ColorsIndex=obj.app.pr.ax.(ax).UserData.ColorsIndex+1;
                    case 4 %ITI
                        DisplayName=['ITI:' num2str(obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.iti})];
                        obj.app.pr.ax.(ax).UserData.ColorsIndex=obj.app.pr.ax.(ax).UserData.ColorsIndex+1;
                end
            end
            %% Plot Latest Trial
            if ~(isfield(obj.inputs.Handles,'LatestMEP'))
                obj.inputs.Handles.LatestMEP=plot(obj.inputs.timeVect,obj.inputs.rawData.(ThisChannelName).data(obj.inputs.trial,:),'LineStyle','-.','Color','k','LineWidth',1.5,'DisplayName','Latest','Parent',obj.app.pr.ax.(ax));
                legend('Location','southoutside','Orientation','horizontal'); hold on;
            else
                obj.inputs.Handles.LatestMEP.YData=obj.inputs.rawData.(ThisChannelName).data(obj.inputs.trial,:);
                drawnow;
            end
            %% Plot Mean respectively prepared condition
            if ~(isfield(obj.inputs.Handles,cd))
                obj.inputs.Handles.(cd)=plot(obj.inputs.timeVect,obj.inputs.rawData.(ThisChannelName).data(obj.inputs.trial,:),'Color',obj.app.pr.ax.(ax).UserData.Colors(obj.app.pr.ax.(ax).UserData.ColorsIndex,:),'LineWidth',2,'DisplayName',DisplayName,'Parent',obj.app.pr.ax.(ax));
                obj.inputs.Handles.(cd).UserData(1,1)=obj.inputs.trial;
                legend('Location','southoutside','Orientation','horizontal'); hold on;
                
            else
                obj.inputs.Handles.(cd).UserData(1,1+numel(obj.inputs.Handles.(cd).UserData))=obj.inputs.trial;
                obj.inputs.Handles.(cd).YData=mean(obj.inputs.rawData.(ThisChannelName).data(obj.inputs.Handles.(cd).UserData,:));
                drawnow;
            end
            %% Plotting Zero and Search Window GirdLine on 1st Trial only
            if obj.inputs.trial==1
                ZeroLine=gridxy([0 (obj.inputs.mep_onset):0.25:(obj.inputs.mep_offset)],'Color',[219/255 246/255 255/255],'linewidth',4,'Parent',obj.app.pr.ax.(ax)) ;
                ZeroLine.Annotation.LegendInformation.IconDisplayStyle = 'off';
                xlim([obj.inputs.EMGXLimit(1), obj.inputs.EMGXLimit(2)]);
                mat1=obj.inputs.prestim_scope_plt*(-1):20:obj.inputs.poststim_scope_plt;
                mat2=[0 obj.inputs.mep_onset*1000 obj.inputs.mep_offset*1000 obj.inputs.timeVect(end)];
                mat=unique(sort([mat1 mat2]));
                xticks(mat);
                xlabel('Time (ms)');
                ylim([obj.inputs.ylimMin obj.inputs.ylimMax]);
                mat3=linspace(obj.inputs.ylimMin,obj.inputs.ylimMax,5);
                mat4=unique(sort([0 mat3]));
                yticks(mat4);
                ylabel('EMG Potential (\mu V)');
            end
            %% Trigger MEPP2P Amplitude Calculation
            obj.mep_amp;
            uistack(obj.inputs.Handles.LatestMEP,'top')
        end
        function mep_plot_Extended(obj)
            ax=['ax' num2str(obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.axesno}{1,obj.inputs.chLab_idx})];
            axes(obj.app.pr.ax.(ax)), hold on,
            obj.mep_amp;
            CurrentMEPAmp=round((obj.inputs.results.(obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.chLab}{1,obj.inputs.chLab_idx}).MEPAmplitude(obj.inputs.trial,1))/1000,3);
            if ~isfield(obj.inputs.Handles,ax)
                obj.inputs.Handles.(ax).current=plot(obj.inputs.timeVect,obj.inputs.rawData.(obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.chLab}{1,obj.inputs.chLab_idx}).data(obj.inputs.trial,:),'Color',[1 0 0],'LineWidth',2);
                xlim([obj.inputs.EMGXLimit(1), obj.inputs.EMGXLimit(2)]);
                mat1=linspace(obj.inputs.EMGXLimit(1),obj.inputs.EMGXLimit(2),10);
                mat2=[0 obj.inputs.mep_onset*1000 obj.inputs.mep_offset*1000 obj.inputs.EMGXLimit(2)];
                mat=unique(sort([mat1 mat2]));
                xticks(mat);xtickformat('%.0f');xlabel('Time (ms)');
                ylim([obj.inputs.ylimMin obj.inputs.ylimMax]);mat3=linspace(obj.inputs.ylimMin,obj.inputs.ylimMax,5);mat4=unique(sort([0 mat3]));
                yticks(mat4);ylabel('EMG Potential (\mu V)');
                obj.app.pr.ax.(ax).UserData.GridLines=gridxy([0 (obj.inputs.mep_onset):0.25:(obj.inputs.mep_offset)],'Color',[219/255 246/255 255/255],'linewidth',4) ;
                obj.info.handle_gridxy_mt_lines=gridxy([],[-0.05*1000 0.05*1000],'Color',[0.45 0.45 0.45],'linewidth',1,'LineStyle','--') ;
                obj.app.pr.ax.(ax).UserData.GridLines.Annotation.LegendInformation.IconDisplayStyle = 'off';
                obj.info.handle_gridxy_mt_lines.Annotation.LegendInformation.IconDisplayStyle = 'off';
                uistack(obj.info.handle_gridxy_mt_lines,'top');
                MeanMEPAmp=CurrentMEPAmp;
            elseif isfield(obj.inputs.Handles.(ax),'past')
                IndexOfTrialsTillNow=find(vertcat(obj.inputs.trialMat{1:obj.inputs.trial,obj.inputs.colLabel.ConditionMarker})==obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.ConditionMarker}); 
                obj.inputs.Handles.(ax).past=plot(obj.inputs.timeVect,obj.inputs.rawData.(obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.chLab}{1,obj.inputs.chLab_idx}).data(IndexOfTrialsTillNow(1:end-1),:),'Color',[0.75 0.75 0.75]);
                obj.inputs.Handles.(ax).mean.YData=mean(obj.inputs.rawData.(obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.chLab}{1,obj.inputs.chLab_idx}).data(IndexOfTrialsTillNow(obj.inputs.Handles.(ax).mean.UserData.TrialNoForMean:end),:));
                obj.inputs.Handles.(ax).current.YData=obj.inputs.rawData.(obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.chLab}{1,obj.inputs.chLab_idx}).data(obj.inputs.trial,:);
                uistack(obj.inputs.Handles.(ax).current,'top');
                LegendGrouping=[obj.inputs.Handles.(ax).past; obj.inputs.Handles.(ax).mean; obj.inputs.Handles.(ax).current];
                legend(LegendGrouping, 'Previous', 'Mean', 'Latest','Location','southoutside','Orientation','horizontal');
                MeanMEPAmp=round(mean(obj.inputs.results.(obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.chLab}{1,obj.inputs.chLab_idx}).MEPAmplitude(IndexOfTrialsTillNow(obj.inputs.Handles.(ax).mean.UserData.TrialNoForMean:end,1)))/1000,3);
            else
                delete(obj.inputs.Handles.(ax).current)
                IndexOfTrialsTillNow=find(vertcat(obj.inputs.trialMat{1:obj.inputs.trial,obj.inputs.colLabel.ConditionMarker})==obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.ConditionMarker}); 
                obj.inputs.Handles.(ax).past=plot(obj.inputs.timeVect,obj.inputs.rawData.(obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.chLab}{1,obj.inputs.chLab_idx}).data(IndexOfTrialsTillNow(1:end-1),:),'Color',[0.75 0.75 0.75]);
                obj.inputs.Handles.(ax).mean=plot(obj.inputs.timeVect,mean(obj.inputs.rawData.(obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.chLab}{1,obj.inputs.chLab_idx}).data(IndexOfTrialsTillNow,:)),'color',[0,0,0],'LineWidth',1.5);
                obj.inputs.Handles.(ax).current=plot(obj.inputs.timeVect,obj.inputs.rawData.(obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.chLab}{1,obj.inputs.chLab_idx}).data(obj.inputs.trial,:),'Color',[1 0 0],'LineWidth',2);
                obj.inputs.Handles.(ax).mean.UserData.TrialNoForMean=1;
                MeanMEPAmp=round(mean(obj.inputs.results.(obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.chLab}{1,obj.inputs.chLab_idx}).MEPAmplitude(IndexOfTrialsTillNow,1))/1000,3);
            end
            %% Update the Current MEP Amp & Mean MEP Amp Stauts on Axes
            textMEPAmpStatus={['Latest MEP Amp (mV):' num2str(CurrentMEPAmp)],['Mean MEP Amp (mV):' num2str(MeanMEPAmp)]};
            if isfield(obj.app.pr.ax.(ax).UserData,'status')
                obj.app.pr.ax.(ax).UserData.status.String=textMEPAmpStatus;
            else
                obj.app.pr.ax.(ax).UserData.status=text(obj.app.pr.ax.(ax),1,1,textMEPAmpStatus,'units','normalized','HorizontalAlignment','right','VerticalAlignment','cap','color',[0.45 0.45 0.45]);
            end
        end
        function mep_amp(obj)
            maxx=max(obj.inputs.rawData.(obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.chLab}{1,obj.inputs.chLab_idx}).data(obj.inputs.trial,obj.inputs.mep_onset_samples:obj.inputs.mep_offset_samples));
            minn=min(obj.inputs.rawData.(obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.chLab}{1,obj.inputs.chLab_idx}).data(obj.inputs.trial,obj.inputs.mep_onset_samples:obj.inputs.mep_offset_samples));
            obj.inputs.results.(obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.chLab}{1,obj.inputs.chLab_idx}).MEPAmplitude(obj.inputs.trial,1)=abs(maxx)+abs(minn);
            % the purpose of below line is a mere simulation
            %             obj.inputs.results.(obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.chLab}{1,obj.inputs.chLab_idx}).MEPAmplitude(obj.inputs.trial,1)=obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.stimcdMrk};
            %% Calculating Ratios NEW METHOD
            if strcmpi(obj.inputs.Protocol,'MEP Dose Response Curve Protocol')
                if obj.inputs.ResponseFunctionNumerator~=obj.inputs.ResponseFunctionDenominator
                    obj.inputs.results.(obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.chLab}{1,obj.inputs.chLab_idx}).MEPAmplitudeRatios(obj.inputs.trial,1)=obj.inputs.results.(obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.chLab}{1,obj.inputs.chLab_idx}).MEPAmplitude(obj.inputs.trial,1);
                    obj.inputs.results.(obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.chLab}{1,obj.inputs.chLab_idx}).MEPAmplitudeRatios(obj.inputs.trial,2)=obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.si}{1,1}{1,1};
                    obj.inputs.results.(obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.chLab}{1,obj.inputs.chLab_idx}).MEPAmplitudeRatios(obj.inputs.trial,3)=obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.si}{1,1}{1,2};
                    obj.inputs.results.(obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.chLab}{1,obj.inputs.chLab_idx}).MEPAmplitudeRatios(obj.inputs.trial,4)=obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.si}{1,1}{1,3};
                    obj.inputs.results.(obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.chLab}{1,obj.inputs.chLab_idx}).MEPAmplitudeRatios(obj.inputs.trial,5)=obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.iti};
                    if numel(obj.inputs.ResponseFunctionDenominator)==1
                        if any(ismember(obj.inputs.ResponseFunctionDenominator,obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.stimcdMrk}))
                            obj.inputs.results.(obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.chLab}{1,obj.inputs.chLab_idx}).MEPAmplitudeRatios(obj.inputs.trial,1:5)=0;
                            TSOnlyConditions=find(vertcat(obj.inputs.trialMat{1:obj.inputs.trial,obj.inputs.colLabel.stimcdMrk})==obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.stimcdMrk});
                            obj.inputs.TSOnlyMean=mean(obj.inputs.results.(obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.chLab}{1,obj.inputs.chLab_idx}).MEPAmplitude(TSOnlyConditions,1));
                            obj.inputs.results.(obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.chLab}{1,obj.inputs.chLab_idx}).MEPAmplitudeRatiosNew=0;
                            %                         obj.inputs.TSOnlyMean=obj.inputs.trial;
                        else
                            obj.inputs.results.(obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.chLab}{1,obj.inputs.chLab_idx}).MEPAmplitudeRatiosNew=100*(((obj.inputs.results.(obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.chLab}{1,obj.inputs.chLab_idx}).MEPAmplitudeRatios(:,1))-(obj.inputs.TSOnlyMean))/obj.inputs.TSOnlyMean);
                        end
                    elseif numel(obj.inputs.ResponseFunctionDenominator)>1
                        if any(ismember(obj.inputs.ResponseFunctionDenominator,obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.stimcdMrk}))
                            obj.inputs.results.(obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.chLab}{1,obj.inputs.chLab_idx}).MEPAmplitudeRatios(obj.inputs.trial,1:5)=0;
                            obj.inputs.results.(obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.chLab}{1,obj.inputs.chLab_idx}).MEPAmplitudeRatiosNew(obj.inputs.trial,1)=0;
                            numeratoridx=find(ismember(obj.inputs.ResponseFunctionDenominator,obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.stimcdMrk})==1);
                            meancd=['TSOnlyMean' num2str(obj.inputs.ResponseFunctionNumerator(numeratoridx))];
                            TSOnlyConditions=find(vertcat(obj.inputs.trialMat{1:obj.inputs.trial,obj.inputs.colLabel.stimcdMrk})==obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.stimcdMrk});
                            obj.inputs.(meancd)=mean(obj.inputs.results.(obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.chLab}{1,obj.inputs.chLab_idx}).MEPAmplitude(TSOnlyConditions,1));
                            cdtoupdate=meancd;
                            TSCSConditions=find(vertcat(obj.inputs.trialMat{1:obj.inputs.trial,obj.inputs.colLabel.stimcdMrk})==obj.inputs.ResponseFunctionNumerator(numeratoridx));
                        else
                            cdtoupdate=['TSOnlyMean' num2str(obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.stimcdMrk})];
                            TSCSConditions=obj.inputs.trial;
                        end
                        try
                            obj.inputs.results.(obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.chLab}{1,obj.inputs.chLab_idx}).MEPAmplitudeRatiosNew(TSCSConditions,1)=100*((obj.inputs.results.(obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.chLab}{1,obj.inputs.chLab_idx}).MEPAmplitudeRatios(TSCSConditions,1))/obj.inputs.(cdtoupdate));
                        catch
                            obj.inputs.results.(obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.chLab}{1,obj.inputs.chLab_idx}).MEPAmplitudeRatiosNew(obj.inputs.trial,1)=NaN;
                        end
                    end
                end
            end
        end
        function mep_scat_plot(obj)
            ax=['ax' num2str(obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.axesno}{1,obj.inputs.chLab_idx})];
            axes(obj.app.pr.ax.(ax)), hold on, ylim auto
            if  numel(obj.inputs.ResponseFunctionNumerator) ==1 && numel(obj.inputs.ResponseFunctionDenominator) ==1 && any(obj.inputs.ResponseFunctionNumerator==obj.inputs.ResponseFunctionDenominator)
                %% Preparing xvalue on the basis of Dose Function
                switch obj.inputs.DoseFunction
                    case 1 % TS
                        xvalue=obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.si}{1,1}{1,1};
                        if obj.inputs.trial==1
                            xlabelstring='TS Intensity';
                            ylabelstring='MEP P2P Amplitude (\muV)';
                            si(1,1)=0;
                            for iSI=1:obj.inputs.totalTrials %Previously this was so, now changed1:numel([obj.inputs.trialMat{:,obj.inputs.colLabel.si}]')
                                si(iSI,1)=obj.inputs.trialMat{iSI,obj.inputs.colLabel.si}{1,1}{1,1};
                            end
                            si=unique(si,'stable');
                            xlimvector=[min(si)-(min(si)*.10) max(si)+(max(si)*.10)];
                            xtickvector=unique(sort([si']));
                        end
                    case 2 % CS
                        xvalue=obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.si}{1,1}{1,2};
                        if obj.inputs.trial==1
                            xlabelstring='CS Intensity';
                            ylabelstring='MEP P2P Amplitude (\muV)';
                            si(1,1)=0;
                            for iSI=1:numel([obj.inputs.trialMat{:,obj.inputs.colLabel.si}]')
                                si(iSI,1)=obj.inputs.trialMat{iSI,obj.inputs.colLabel.si}{1,1}{1,2};
                            end
                            si=unique(si,'stable');
                            xlimvector=[min(si)-(min(si)*10) max(si)+(max(si)*10)];
                            xtickvector=unique(sort([si']));
                        end
                    case 3 % ISI
                        xvalue=obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.si}{1,1}{1,3};
                        if obj.inputs.trial==1
                            xlabelstring='ISI (ms)';
                            ylabelstring='MEP P2P Amplitude (\muV)';
                            si(1,1)=0;
                            for iSI=1:numel([obj.inputs.trialMat{:,obj.inputs.colLabel.si}]')
                                si(iSI,1)=obj.inputs.trialMat{iSI,obj.inputs.colLabel.si}{1,1}{1,3};
                            end
                            si=unique(si,'stable');
                            xlimvector=[min(si)-(min(si)*.10) max(si)+(max(si)*.10)];
                            xtickvector=unique(sort([si']));
                        end
                    case 4 % ITI
                        xvalue=obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.iti};
                        if obj.inputs.trial==1
                            xlabelstring='ITI (ms)';
                            ylabelstring='MEP P2P Amplitude (\muV)';
                            si(1,1)=0;
                            for iSI=1:numel([obj.inputs.trialMat{:,obj.inputs.colLabel.iti}]')
                                si(iSI,1)=obj.inputs.trialMat{iSI,obj.inputs.colLabel.iti};
                            end
                            si=unique(si,'stable');
                            xlimvector=[min(si)-(min(si)*.10) max(si)+(max(si)*.10)];
                            xtickvector=unique(sort([si']));
                        end
                end
                %% Preparing yvalue
                yvalue=obj.inputs.results.(obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.chLab}{1,obj.inputs.chLab_idx}).MEPAmplitude(obj.inputs.trial,1);
                %% Plotting
                switch obj.inputs.trial
                    case 1
                        obj.info.plt.(ax).ioc_scatplot=plot(xvalue,yvalue,'o','Color','r','MarkerSize',8,'MarkerFaceColor','r');
                        hold on;
                        xlabel(xlabelstring); ylabel(ylabelstring); xlim(xlimvector); xticks(xtickvector);
                    otherwise
                        set(obj.info.plt.(ax).ioc_scatplot,'Color',[0.45 0.45 0.45],'MarkerSize',8,'MarkerFaceColor',[0.45 0.45 0.45])
                end
                obj.info.plt.(ax).ioc_scatplot=plot(xvalue,yvalue,'o','MarkerSize',8,'Color','r','MarkerFaceColor','r'); hold on; uistack(obj.info.plt.(ax).ioc_scatplot,'top')
            elseif numel(obj.inputs.ResponseFunctionNumerator)>1
                %% Preparing xvalue on the basis of Dose Function
                switch obj.inputs.DoseFunction
                    case 1 % TS
                        xvalue=nonzeros(obj.inputs.results.(obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.chLab}{1,obj.inputs.chLab_idx}).MEPAmplitudeRatios(:,2));
                        if obj.inputs.trial==1
                            xlabelstring='TS Intensity';
                            ylabelstring='MEP Amp. ( \muV )';
                            xlimvalue=vertcat(obj.inputs.trialMat{:,obj.inputs.colLabel.si});
                            xlimvalue=vertcat(xlimvalue{:}); xlimvalue=cell2mat(xlimvalue); xlimvalue=xlimvalue(:,1);
                            stimcdMrkvalue=vertcat(obj.inputs.trialMat{:,obj.inputs.colLabel.stimcdMrk});
                            for iDenominators=1:numel(obj.inputs.ResponseFunctionDenominator)
                                indextodelete=find(stimcdMrkvalue==obj.inputs.ResponseFunctionDenominator(iDenominators));
                                xlimvalue(indextodelete)=0;
                            end
                            xlimvalue=nonzeros(xlimvalue);
                            xlimvalue=unique(xlimvalue,'stable');
                            xlimvector=[min(xlimvalue)-(min(xlimvalue)*.10) max(xlimvalue)+(max(xlimvalue)*.10)];
                            xtickvector=unique(sort([xlimvalue']));
                        end
                    case 2 % CS
                        xvalue=nonzeros(obj.inputs.results.(obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.chLab}{1,obj.inputs.chLab_idx}).MEPAmplitudeRatios(:,3));
                        if obj.inputs.trial==1
                            xlabelstring='CS Intensity';
                            ylabelstring='MEP Amp. ( \muV )';
                            xlimvalue=vertcat(obj.inputs.trialMat{:,obj.inputs.colLabel.si});
                            xlimvalue=vertcat(xlimvalue{:}); xlimvalue=cell2mat(xlimvalue); xlimvalue=xlimvalue(:,2);
                            stimcdMrkvalue=vertcat(obj.inputs.trialMat{:,obj.inputs.colLabel.stimcdMrk});
                            for iDenominators=1:numel(obj.inputs.ResponseFunctionDenominator)
                                indextodelete=find(stimcdMrkvalue==obj.inputs.ResponseFunctionDenominator(iDenominators));
                                xlimvalue(indextodelete)=0;
                            end
                            xlimvalue=nonzeros(xlimvalue);
                            xlimvalue=unique(xlimvalue,'stable');
                            xlimvector=[min(xlimvalue)-(min(xlimvalue)*.10) max(xlimvalue)+(max(xlimvalue)*.10)];
                            xtickvector=unique(sort([xlimvalue']));
                        end
                    case 3 % ISI
                        xvalue=nonzeros(obj.inputs.results.(obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.chLab}{1,obj.inputs.chLab_idx}).MEPAmplitudeRatios(:,4));
                        if obj.inputs.trial==1
                            xlabelstring='ISI (ms)';
                            ylabelstring='MEP Amp. (\muV )';
                            xlimvalue=vertcat(obj.inputs.trialMat{:,obj.inputs.colLabel.si});
                            xlimvalue=vertcat(xlimvalue{:}); xlimvalue=cell2mat(xlimvalue); xlimvalue=xlimvalue(:,3);
                            stimcdMrkvalue=vertcat(obj.inputs.trialMat{:,obj.inputs.colLabel.stimcdMrk});
                            for iDenominators=1:numel(obj.inputs.ResponseFunctionDenominator)
                                indextodelete=find(stimcdMrkvalue==obj.inputs.ResponseFunctionDenominator(iDenominators));
                                xlimvalue(indextodelete)=0;
                            end
                            xlimvalue=nonzeros(xlimvalue);
                            xlimvalue=unique(xlimvalue,'stable');
                            xlimvector=[min(xlimvalue)-(min(xlimvalue)*.10) max(xlimvalue)+(max(xlimvalue)*.10)];
                            xtickvector=unique(sort([xlimvalue']));
                        end
                    case 4 % ITI
                        xvalue=nonzeros(obj.inputs.results.(obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.chLab}{1,obj.inputs.chLab_idx}).MEPAmplitudeRatios(:,5));
                        if obj.inputs.trial==1
                            xlabelstring='ITI (ms)';
                            ylabelstring='MEP Amp. ( \muV )';
                            xlimvalue=vertcat(obj.inputs.trialMat{:,obj.inputs.colLabel.iti});
                            stimcdMrkvalue=vertcat(obj.inputs.trialMat{:,obj.inputs.colLabel.stimcdMrk});
                            for iDenominators=1:numel(obj.inputs.ResponseFunctionDenominator)
                                indextodelete=find(stimcdMrkvalue==obj.inputs.ResponseFunctionDenominator(iDenominators));
                                xlimvalue(indextodelete)=0;
                            end
                            xlimvalue=nonzeros(xlimvalue);
                            xlimvalue=unique(xlimvalue,'stable');
                            xlimvector=[min(xlimvalue)-(min(xlimvalue)*.10) max(xlimvalue)+(max(xlimvalue)*.10)];
                            xtickvector=unique(sort([xlimvalue']));
                        end
                end
                %% Preparing yvalue
                yvalue=nonzeros(obj.inputs.results.(obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.chLab}{1,obj.inputs.chLab_idx}).MEPAmplitudeRatios(:,1));
                %% Plotting
                %                 if obj.inputs.trial==1
                %                     obj.info.plt.(ax).ioc_scatplot=plot(xvalue,yvalue,'o','Color',[0.45 0.45 0.45],'MarkerSize',8,'MarkerFaceColor',[0.45 0.45 0.45]);
                %                     xlabel(xlabelstring); ylabel(ylabelstring); xlim(xlimvector); xticks(xtickvector); hold on;
                %                 else
                %                     obj.info.plt.(ax).ioc_scatplot=plot(xvalue(end),yvalue(end),'o','Color',[0.45 0.45 0.45],'MarkerSize',8,'MarkerFaceColor',[0.45 0.45 0.45]);
                %                     obj.info.plt.(ax).ioc_scatplot.XData=xvalue; obj.info.plt.(ax).ioc_scatplot.YData=yvalue;
                %                 end
                switch obj.inputs.trial
                    case 1
                        obj.info.plt.(ax).ioc_scatplot=plot(xvalue,yvalue,'o','Color','r','MarkerSize',8,'MarkerFaceColor','r'); hold on;
                        xlabel(xlabelstring); ylabel(ylabelstring); xlim(xlimvector); xticks(xtickvector);
                    otherwise
                        set(obj.info.plt.(ax).ioc_scatplot,'Color',[0.45 0.45 0.45],'MarkerSize',8,'MarkerFaceColor',[0.45 0.45 0.45])
                end
                try obj.info.plt.(ax).ioc_scatplot=plot(xvalue(end),yvalue(end),'o','MarkerSize',8,'Color','r','MarkerFaceColor','r'); hold on; uistack(obj.info.plt.(ax).ioc_scatplot,'top'); catch; end
            end
        end
        function mep_stats(obj)
            %             ax=['ax' num2str(obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.axesno}{1,obj.inputs.chLab_idx})];
            %             obj.inputs.rawData.(ax).mep_stats=0;
            si=[];
            for iSI=1:numel([obj.inputs.trialMat{:,obj.inputs.colLabel.si}]')
                si(iSI,1)=obj.inputs.trialMat{iSI,obj.inputs.colLabel.si}{1,1}{1,1};
            end
            %             si=cell2mat(vertcat(obj.inputs.trialMat{:,obj.inputs.colLabel.si}{1,1}));
            mepamp=obj.inputs.results.(obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.chLab}{1,obj.inputs.chLab_idx}).MEPAmplitude(:,1);
            %             mepamp=(vertcat(obj.inputs.trialMat{:,obj.inputs.colLabel.mepamp}));
            
            [si,~,idx] = unique(si,'stable');
            mep_median = accumarray(idx,mepamp,[],@median);
            mep_mean = accumarray(idx,mepamp,[],@mean);
            mep_std = accumarray(idx,mepamp,[],@std);
            mep_min = accumarray(idx,mepamp,[],@min);
            mep_max = accumarray(idx,mepamp,[],@max);
            mep_var = accumarray(idx,mepamp,[],@var);
            M=[si,mep_median,mep_mean,mep_std, mep_min, mep_max, mep_var];
            M1 = M(randperm(size(M,1)),:,:,:,:,:,:);
            
            
            obj.inputs.rawData.(obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.chLab}{1,obj.inputs.chLab_idx}).mep_stats(:,1)=M1(:,1); %Sampled SIs
            obj.inputs.rawData.(obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.chLab}{1,obj.inputs.chLab_idx}).mep_stats(:,2)=M1(:,2); %Sampled Medians MEPs
            obj.inputs.rawData.(obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.chLab}{1,obj.inputs.chLab_idx}).mep_stats(:,3)=M1(:,3); %Mean MEPs over trial
            obj.inputs.rawData.(obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.chLab}{1,obj.inputs.chLab_idx}).mep_stats(:,4)=M1(:,4); %Std MEPs
            obj.inputs.rawData.(obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.chLab}{1,obj.inputs.chLab_idx}).mep_stats(:,5)=M1(:,5); %Min of MEPs
            obj.inputs.rawData.(obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.chLab}{1,obj.inputs.chLab_idx}).mep_stats(:,6)=M1(:,6); %Max of MEPs
            obj.inputs.rawData.(obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.chLab}{1,obj.inputs.chLab_idx}).mep_stats(:,7)=M1(:,7); %Var of MEPs
            obj.inputs.SI=obj.inputs.rawData.(obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.chLab}{1,obj.inputs.chLab_idx}).mep_stats(:,1);
            obj.inputs.MEP=obj.inputs.rawData.(obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.chLab}{1,obj.inputs.chLab_idx}).mep_stats(:,2);
            
            obj.inputs.rawData.(obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.chLab}{1,obj.inputs.chLab_idx}).mep_stats(:,8)=(obj.inputs.rawData.(obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.chLab}{1,obj.inputs.chLab_idx}).mep_stats(:,4))/sqrt(numel(obj.inputs.rawData.(obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.chLab}{1,obj.inputs.chLab_idx}).mep_stats(:,4)));    %TODO: Make it modular by replacing 15 to # trials per intensity object value
            obj.inputs.SEM=obj.inputs.rawData.(obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.chLab}{1,obj.inputs.chLab_idx}).mep_stats(:,8);
            
        end
        function ioc_fit_plot(obj)
            if(obj.inputs.trial==obj.inputs.totalTrials)
                if obj.inputs.DoseFunction==1 && numel(obj.inputs.ResponseFunctionNumerator) ==1 && numel(obj.inputs.ResponseFunctionDenominator) ==1 && any(obj.inputs.ResponseFunctionNumerator==obj.inputs.ResponseFunctionDenominator)
                    %% Simplest Response Function Case
                    obj.mep_stats;
                    ax=['ax' num2str(obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.axesno}{1,obj.inputs.chLab_idx})];
                    axes(obj.app.pr.ax.(ax)), hold on,
                    try
                        [SIData, MEPData] = prepareCurveData(obj.inputs.rawData.(obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.chLab}{1,obj.inputs.chLab_idx}).mep_stats(:,1) ,obj.inputs.rawData.(obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.chLab}{1,obj.inputs.chLab_idx}).mep_stats(:,2));
                        ft = fittype( 'MEPmax*SI^n/(SI^n+SI50^n)', 'independent', 'SI', 'dependent', 'MEP' );
                        %             ft = best_fittype( 'MEPmax*SI^n/(SI^n+SI50^n)', 'independent', 'SI', 'dependent', 'MEP' );
                        
                        %% Optimization of fit paramters;
                        
                        opts = fitoptions( ft );
                        opts.Display = 'Off';
                        opts.Lower = [0 0 0 ];
                        opts.StartPoint = [10 10 10];
                        opts.Upper = [Inf Inf Inf];
                        
                        %% Fit sigmoid model to data
                        %                 MEPData=[1; 2; 3; 4; 5; 6]
                        [obj.info.ioc.fitresult,obj.info.ioc.gof] = fit( SIData, MEPData, ft, opts);
                        %% Extract fitted curve points
                        
                        plot( obj.info.ioc.fitresult, SIData, MEPData);
                        
                        obj.info.handle.ioc_curve= get(gca,'Children');
                        x1lim=xlim;
                        y1lim=ylim;
                        bg = gca; legend(bg,'off');
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
                        %             if(strcmp(obj.inputs.stim_mode,'MSO'))
                        %
                        %                     index_ip1=index_ip+2;
                        %                 ip1_x=obj.info.handle.ioc_curve(1).XData(index_ip1);
                        %                 ip1_y=obj.info.handle.ioc_curve(1).YData(index_ip1);
                        %                 % Calculating slope (m) using two-points equation
                        %                 m1=(ip1_y-ip_y)/(ip1_x-obj.info.ip_x)
                        %                 m=m1
                        %                 % Calculating threshold (th) using point-slope equation
                        %                 obj.info.th=obj.info.ip_x-(ip_y/m);
                        %             end
                        
                        [~ , index_th] = min(abs(obj.info.handle.ioc_curve(1).YData-50 ) );
                        obj.info.th=obj.info.handle.ioc_curve(1).XData(index_th);
                        hold on;
                        h = plot( obj.info.ioc.fitresult, obj.inputs.SI, obj.inputs.MEP);
                        set(h(1), 'MarkerFaceColor',[0 0 0],'MarkerEdgeColor',[0 0 0],'Marker','square','LineStyle','none');
                        % Plotting SEM on Curve points
                        errorbar(obj.inputs.SI, obj.inputs.MEP ,obj.inputs.SEM, 'o');
                        set(h(2),'LineWidth',2);
                        xlim([min(obj.inputs.SI)-5 max(obj.inputs.SI)+5]);
                    catch
                        try
                           ioc_fit_using_SMLToolbox
                        catch
                        SIData=obj.inputs.rawData.(obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.chLab}{1,obj.inputs.chLab_idx}).mep_stats(:,1);
                        MEPData=obj.inputs.rawData.(obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.chLab}{1,obj.inputs.chLab_idx}).mep_stats(:,2);
                        SEMData=obj.inputs.rawData.(obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.chLab}{1,obj.inputs.chLab_idx}).mep_stats(:,8);
                        m(1,1)=0;
                        for i=1:numel(MEPData)-1
                            m(i)=(MEPData(i+1)-MEPData(i))/(SIData(i+1)-SIData(i)); %m is standard variable used for slope
                        end
                        SIfit = min(SIData):.01:max(SIData);
                        MEPfit = pchip(SIData,MEPData,SIfit);
                        %% Estimating Inflection Points
                        [~ ,sortedidx]= sort(m(:),'descend');
                        obj.info.ip_x=mean(SIData(sortedidx(1):sortedidx(1)+1));
                        ip_y=mean(MEPData(sortedidx(1):sortedidx(1)+1));
                        %% Estimating Plateu Points
                        [~ ,index_pt] = min(abs(MEPfit-(0.993*(max(MEPfit)) ) ) );   %99.3 % of MEP max
                        obj.info.pt_x=SIfit(index_pt);
                        pt_y=MEPfit(index_pt);
                        %% Estimating Threshold Points
                        [~ ,index_th] = min(abs(MEPfit-50));
                        obj.info.th=SIfit(index_th);
                        hold on;
                        h = plot(SIfit, MEPfit,'LineWidth',2,'Color','r');
                        errorbar(SIData, MEPData ,SEMData, 'o');
                        xlim([min(SIfit)-5 max(SIfit)+5]);
                        end
                    end
                    %% Creating plot
                    xlabel('Stimulation Intensity');
                    ylabel('MEP Amplitude ( \mu V)');
                    
                    set(gcf, 'color', 'w')
                    
                    SI_min_point = (round(min(obj.inputs.SI)/5)*5)-5; % Referncing the dotted lines wrt to lowest 5ths of SI_min
                    % SI_min_point = 0;
                    seet=-0.5;
                    ylim_ioc=-500;
                    
                    plot([obj.info.ip_x,min(xlim)],[ip_y,ip_y],'--','Color' , [0.75 0.75 0.75]);
                    plot([obj.info.ip_x,obj.info.ip_x],[ip_y,ylim_ioc],'--','Color' , [0.75 0.75 0.75]);
                    legend_ip=plot(obj.info.ip_x,ip_y,'rs','MarkerSize',15);
                    
                    
                    % Plotting Plateau's horizontal & vertical dotted lines
                    plot([obj.info.pt_x,min(xlim)],[pt_y,pt_y],'--','Color' , [0.75 0.75 0.75]); %xline
                    plot([obj.info.pt_x,obj.info.pt_x],[pt_y,ylim_ioc],'--','Color' , [0.75 0.75 0.75]);
                    legend_pt=plot(obj.info.pt_x,pt_y,'rd','MarkerSize',15);
                    
                    
                    plot([obj.info.th,min(xlim)],[50,50],'--','Color' , [0.75 0.75 0.75]);
                    plot([obj.info.th,obj.info.th],[50,ylim_ioc],'--','Color' , [0.75 0.75 0.75]);
                    legend_th=plot(obj.info.th, 50,'r*','MarkerSize',15);
                    %% Creating legends
                    h_legend=[h(1); legend_ip;legend_pt;legend_th];
                    l=legend(h_legend, 'Dose-Response Curve', 'Inflection Point','Plateau','Threshold');
                    set(l,'Orientation','horizontal','Location', 'southoutside','FontSize',12);
                    %% Creating Properties annotation box
                    
                    str_ip=['Inflection Point: ',num2str(obj.info.ip_x),' (%MSO)',' , ',num2str(ip_y),' (\muV)'];
                    str_pt=['Plateau: ',num2str(obj.info.pt_x),' (%MSO)',' , ',num2str(pt_y),' (\muV)'];
                    str_th=['Thershold: ',num2str(obj.info.th),' (%MSO)',' , ', '0.05',' (\muV)'];
                    
                    dim = [0 0 0.5 0.5];
                    str = {str_ip,[],str_th,[],str_pt};
                    ylim([-500 Inf])
                    %% Test String of IP, PT and TH
                    obj.app.pr.ip_mso.(ax).String=obj.info.ip_x;
                    obj.app.pr.ip_muv.(ax).String=ip_y;  % here it is in uV
                    obj.app.pr.pt_mso.(ax).String=obj.info.pt_x;
                    obj.app.pr.pt_muv.(ax).String=pt_y;  % here ti is in uV
                    obj.app.pr.th_mso.(ax).String=obj.info.th;
                    obj.app.pr.th_muv.(ax).String=0.05;
                    ResultsAnnotation={['Inflection Point(mV):' num2str(ip_y/1000)],['Inflection Point(intensity):' num2str(obj.info.ip_x)],['Plateau (mV):' num2str(pt_y/1000)],['Plateau (intensity):' num2str(obj.info.pt_x)],['Thershold (intensity):' num2str(obj.info.th)]};
                    obj.app.pr.ax.(ax).UserData.status=text(obj.app.pr.ax.(ax),1,1,ResultsAnnotation,'units','normalized','HorizontalAlignment','right','VerticalAlignment','cap','color',[0.45 0.45 0.45]);
                    box off; drawnow;
                    %% Saving Inflection Point, Plateau and Threshold x and y values in the Struct
                    obj.inputs.(obj.app.info.event.current_session).(obj.app.info.event.current_measure_fullstr).Results.InflectionPoint_SI=obj.info.ip_x;
                    obj.inputs.(obj.app.info.event.current_session).(obj.app.info.event.current_measure_fullstr).Results.InflectionPoint_uV=ip_y;
                    obj.inputs.(obj.app.info.event.current_session).(obj.app.info.event.current_measure_fullstr).Results.Plateau_SI=obj.info.pt_x;
                    obj.inputs.(obj.app.info.event.current_session).(obj.app.info.event.current_measure_fullstr).Results.Plateau_uV=pt_y;
                    obj.inputs.(obj.app.info.event.current_session).(obj.app.info.event.current_measure_fullstr).Results.Threshold_SI=obj.info.th;
                    for icond=1:obj.inputs.condsAll
                        condStr=['cond' num2str(icond)];
                        for s=1:(length(fieldnames(obj.inputs.condsAll.(condStr)))-6)
                            st=['st' num2str(s)];
                            switch obj.inputs.DoseFunction
                                case 1 %Test
                                    if strcmp( obj.inputs.condsAll.(condStr).(st).StimulationType,'Test')
                                        obj.inputs.(obj.app.info.event.current_session).(obj.app.info.event.current_measure_fullstr).Results.Threshold_SI_BaseUnits=obj.info.th*0.01*str2double(obj.inputs.condsAll.(condStr).(st).threshold);
                                        obj.inputs.(obj.app.info.event.current_session).(obj.app.info.event.current_measure_fullstr).Results.InflectionPoint_SI_BaseUnits=obj.info.ip_x*0.01*str2double(obj.inputs.condsAll.(condStr).(st).threshold);
                                        obj.inputs.(obj.app.info.event.current_session).(obj.app.info.event.current_measure_fullstr).Results.Plateau_SI_BaseUnits=obj.info.pt_x*0.01*str2double(obj.inputs.condsAll.(condStr).(st).threshold);
                                    end
                                case 2 %Condition
                                    if strcmp( obj.inputs.condsAll.(condStr).(st).StimulationType,'Condition')
                                        obj.inputs.(obj.app.info.event.current_session).(obj.app.info.event.current_measure_fullstr).Results.Threshold_SI_BaseUnits=obj.info.th*0.01*str2double(obj.inputs.condsAll.(condStr).(st).threshold);
                                        obj.inputs.(obj.app.info.event.current_session).(obj.app.info.event.current_measure_fullstr).Results.InflectionPoint_SI_BaseUnits=obj.info.ip_x*0.01*str2double(obj.inputs.condsAll.(condStr).(st).threshold);
                                        obj.inputs.(obj.app.info.event.current_session).(obj.app.info.event.current_measure_fullstr).Results.Plateau_SI_BaseUnits=obj.info.pt_x*0.01*str2double(obj.inputs.condsAll.(condStr).(st).threshold);
                                    end
                            end
                        end
                    end
           
                elseif numel(obj.inputs.ResponseFunctionNumerator)>1
                    %%  Complicated Response Function case
                    ax=['ax' num2str(obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.axesno}{1,obj.inputs.chLab_idx})];
                    axes(obj.app.pr.ax.(ax)), hold on,
                    xdata=nonzeros(obj.inputs.results.(obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.chLab}{1,obj.inputs.chLab_idx}).MEPAmplitudeRatios(:,3)); % 
                    xzeros=find((obj.inputs.results.(obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.chLab}{1,obj.inputs.chLab_idx}).MEPAmplitudeRatios(:,3))==0);
                    TSAloneCond=mean(obj.inputs.results.(obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.chLab}{1,obj.inputs.chLab_idx}).MEPAmplitude(xzeros,1));
                    
                    ydata=nonzeros(obj.inputs.results.(obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.chLab}{1,obj.inputs.chLab_idx}).MEPAmplitudeRatios(:,1));
                    ydata=((ydata-TSAloneCond)/TSAloneCond)*100;
                    [xdataunique,~,idx] = unique(xdata);
                    mep_median = accumarray(idx,ydata,[],@median);
                    M=[xdataunique,mep_median];
                    obj.inputs.rawData.(obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.chLab}{1,obj.inputs.chLab_idx}).mep_stats(:,1)=M(:,1); %Sampled Dose Function
                    obj.inputs.rawData.(obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.chLab}{1,obj.inputs.chLab_idx}).mep_stats(:,2)=M(:,2); %Sampled Response Function
                    obj.inputs.DoseFunctionValues=obj.inputs.rawData.(obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.chLab}{1,obj.inputs.chLab_idx}).mep_stats(:,1);
                    obj.inputs.ResponseFunctionValues=obj.inputs.rawData.(obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.chLab}{1,obj.inputs.chLab_idx}).mep_stats(:,2);
                    plot(obj.inputs.DoseFunctionValues,obj.inputs.ResponseFunctionValues,'DisplayName','Dose Response Curve','color','g','LineWidth',2);
                    %% Preparing Graphical Legend Enteries
                    switch obj.inputs.DoseFunction
                        case 1 % TS
                            xlabelstring='TS Intensity';
                            ylabelstring='MEP Amp. ( % Control )';
                            xlimvalue=vertcat(obj.inputs.trialMat{:,obj.inputs.colLabel.si});
                            xlimvalue=vertcat(xlimvalue{:}); xlimvalue=cell2mat(xlimvalue); xlimvalue=xlimvalue(:,1);
                            stimcdMrkvalue=vertcat(obj.inputs.trialMat{:,obj.inputs.colLabel.stimcdMrk});
                            for iDenominators=1:numel(obj.inputs.ResponseFunctionDenominator)
                                indextodelete=find(stimcdMrkvalue==obj.inputs.ResponseFunctionDenominator(iDenominators));
                                xlimvalue(indextodelete)=0;
                            end
                            xlimvalue=nonzeros(xlimvalue);
                            xlimvalue=unique(xlimvalue,'stable');
                            xlimvector=[min(xlimvalue)-(min(xlimvalue)*.10) max(xlimvalue)+(max(xlimvalue)*.10)];
                            xtickvector=unique(sort([xlimvalue']));
                        case 2 % CS
                            xlabelstring='CS Intensity';
                            ylabelstring='MEP Amp. ( % Control )';
                            xlimvalue=vertcat(obj.inputs.trialMat{:,obj.inputs.colLabel.si});
                            xlimvalue=vertcat(xlimvalue{:}); xlimvalue=cell2mat(xlimvalue); xlimvalue=xlimvalue(:,2);
                            stimcdMrkvalue=vertcat(obj.inputs.trialMat{:,obj.inputs.colLabel.stimcdMrk});
                            for iDenominators=1:numel(obj.inputs.ResponseFunctionDenominator)
                                indextodelete=find(stimcdMrkvalue==obj.inputs.ResponseFunctionDenominator(iDenominators));
                                xlimvalue(indextodelete)=0;
                            end
                            xlimvalue=nonzeros(xlimvalue);
                            xlimvalue=unique(xlimvalue,'stable');
                            xlimvector=[min(xlimvalue)-(min(xlimvalue)*.10) max(xlimvalue)+(max(xlimvalue)*.10)];
                            xtickvector=unique(sort([xlimvalue']));
                        case 3 % ISI
                            xlabelstring='ISI (ms)';
                            ylabelstring='MEP Amp. ( % Control )';
                            xlimvalue=vertcat(obj.inputs.trialMat{:,obj.inputs.colLabel.si});
                            xlimvalue=vertcat(xlimvalue{:}); xlimvalue=cell2mat(xlimvalue); xlimvalue=xlimvalue(:,3);
                            stimcdMrkvalue=vertcat(obj.inputs.trialMat{:,obj.inputs.colLabel.stimcdMrk});
                            for iDenominators=1:numel(obj.inputs.ResponseFunctionDenominator)
                                indextodelete=find(stimcdMrkvalue==obj.inputs.ResponseFunctionDenominator(iDenominators));
                                xlimvalue(indextodelete)=0;
                            end
                            xlimvalue=nonzeros(xlimvalue);
                            xlimvalue=unique(xlimvalue,'stable');
                            xlimvector=[min(xlimvalue)-(min(xlimvalue)*.10) max(xlimvalue)+(max(xlimvalue)*.10)];
                            xtickvector=unique(sort([xlimvalue']));
                        case 4 % ITI
                            xlabelstring='ITI (ms)';
                            ylabelstring='MEP Amp. ( % Control )';
                            xlimvalue=vertcat(obj.inputs.trialMat{:,obj.inputs.colLabel.iti});
                            stimcdMrkvalue=vertcat(obj.inputs.trialMat{:,obj.inputs.colLabel.stimcdMrk});
                            for iDenominators=1:numel(obj.inputs.ResponseFunctionDenominator)
                                indextodelete=find(stimcdMrkvalue==obj.inputs.ResponseFunctionDenominator(iDenominators));
                                xlimvalue(indextodelete)=0;
                            end
                            xlimvalue=nonzeros(xlimvalue);
                            xlimvalue=unique(xlimvalue,'stable');
                            xlimvector=[min(xlimvalue)-(min(xlimvalue)*.10) max(xlimvalue)+(max(xlimvalue)*.10)];
                            xtickvector=unique(sort([xlimvalue']));
                    end
                    xlabel(xlabelstring); ylabel(ylabelstring); xlim(xlimvector); xticks(xtickvector);
                    %% Computing Inhibition & Facilitation
                    Inhibition=min(obj.inputs.ResponseFunctionValues)/2;
                    Facilitation=max(obj.inputs.ResponseFunctionValues)/2;
                    for i=1:numel(obj.inputs.ResponseFunctionValues)-1
                        ResponseFunctionValues{i}=linspace(obj.inputs.ResponseFunctionValues(i),obj.inputs.ResponseFunctionValues(i+1),1e3);
                        DoseFunctionValues{i}=linspace(obj.inputs.DoseFunctionValues(i),obj.inputs.DoseFunctionValues(i+1),1e3);
                    end
                    ResponseFunctionValues = [ResponseFunctionValues{:}]; DoseFunctionValues = [DoseFunctionValues{:}];
                    [~,idx]=min(abs(ResponseFunctionValues-Inhibition));
                    Inhibition_Intensity=round(DoseFunctionValues(idx));
                    [~,idx]=min(abs(ResponseFunctionValues-Facilitation));
                    Facilitation_Intensity=round(DoseFunctionValues(idx));
                    %% Annotating Inhibition and Facilitation
                    ResultsAnnotation={['Inhibition (50%):' num2str(Inhibition)],['Inhibition(intensity):' num2str(Inhibition_Intensity)],['Facilitation (50%):' num2str(Facilitation)],['Facilitation (intensity):' num2str(Facilitation_Intensity)]};
                    obj.app.pr.ax.(ax).UserData.status=text(obj.app.pr.ax.(ax),1,1,ResultsAnnotation,'units','normalized','HorizontalAlignment','right','VerticalAlignment','cap','color',[0.45 0.45 0.45]);
                    gridxy(Inhibition_Intensity,Inhibition,'DisplayName','Inhibition','color','b'), hold on
                    gridxy(Facilitation_Intensity,Facilitation,'DisplayName','Facilitation','color','r')
                    legend('Location','southoutside','Orientation','horizontal')
                    %% Saving Inhibition and Facilitation in the Struct
                    obj.inputs.(obj.app.info.event.current_session).(obj.app.info.event.current_measure_fullstr).Results.Inhibition_SI=Inhibition_Intensity;
                    obj.inputs.(obj.app.info.event.current_session).(obj.app.info.event.current_measure_fullstr).Results.Inhibition_50percent=Inhibition;
                    obj.inputs.(obj.app.info.event.current_session).(obj.app.info.event.current_measure_fullstr).Results.Facilitation_SI=Facilitation_Intensity; 
                    obj.inputs.(obj.app.info.event.current_session).(obj.app.info.event.current_measure_fullstr).Results.Facilitation_50percent=Facilitation;
                    for icond=1:obj.inputs.condsAll
                        condStr=['cond' num2str(icond)];
                        for s=1:(length(fieldnames(obj.inputs.condsAll.(condStr)))-6)
                            st=['st' num2str(s)];
                            switch obj.inputs.DoseFunction
                                case 1 %Test
                                    if strcmp( obj.inputs.condsAll.(condStr).(st).StimulationType,'Test')
                                        obj.inputs.(obj.app.info.event.current_session).(obj.app.info.event.current_measure_fullstr).Results.Inhibition_SI_BaseUnits=Inhibition_Intensity*0.01*str2double(obj.inputs.condsAll.(condStr).(st).threshold); %Such as %MSO or mA
                                        obj.inputs.(obj.app.info.event.current_session).(obj.app.info.event.current_measure_fullstr).Results.Facilitation_SI_BaseUnits=Facilitation_Intensity*0.01*str2double(obj.inputs.condsAll.(condStr).(st).threshold);
                                    end
                                case 2 %Condition
                                    if strcmp( obj.inputs.condsAll.(condStr).(st).StimulationType,'Condition')
                                        obj.inputs.(obj.app.info.event.current_session).(obj.app.info.event.current_measure_fullstr).Results.Inhibition_SI_BaseUnits=Inhibition_Intensity*0.01*str2double(obj.inputs.condsAll.(condStr).(st).threshold); %Such as %MSO or mA
                                        obj.inputs.(obj.app.info.event.current_session).(obj.app.info.event.current_measure_fullstr).Results.Facilitation_SI_BaseUnits=Facilitation_Intensity*0.01*str2double(obj.inputs.condsAll.(condStr).(st).threshold);
                                    end
                            end
                        end
                    end
                end
            end
            function ioc_fit_using_SMLToolbox
                SIData=obj.inputs.rawData.(obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.chLab}{1,obj.inputs.chLab_idx}).mep_stats(:,1);
                MEPData=obj.inputs.rawData.(obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.chLab}{1,obj.inputs.chLab_idx}).mep_stats(:,2);
                SEMData=obj.inputs.rawData.(obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.chLab}{1,obj.inputs.chLab_idx}).mep_stats(:,8);
                [SIfit,MEPfit,FitData]=sigm_fit(SIData,MEPData,[],[],0);
                %% Estimating Inflection Points
                obj.info.ip_x = FitData(3); [~,MEPIPyIndex]=min(abs(SIfit-FitData(3)));
                ip_y = MEPfit(MEPIPyIndex);
                %% Estimating Plateu Points
                obj.info.pt_x=FitData(2); [~,MEPIPyIndex]=min(abs(SIfit-(0.97*(FitData(2)))));
                pt_y=MEPfit(MEPIPyIndex);                
                %% Estimating Threshold Points
                [~ ,index_th] = min(abs(MEPfit-50));
                obj.info.th=SIfit(index_th);
                hold on;
                h = plot(SIfit, MEPfit,'LineWidth',2,'Color','r');
                errorbar(SIData, MEPData ,SEMData, 'o');
                xlim([min(SIfit)-5 max(SIfit)+5]);
            end
            
        end
        function boot_threshold(obj)
            obj.inputs.trialMat{1,obj.inputs.colLabel.si}{1,1}=obj.inputs.mt_starting_stim_inten;
        end
        function mep_threshold(obj)
            %             if first trial, read from starting intensity
            %                 otherwise read from the evokness and write to the
            %                 intensity function
            AllConditionsFirstTrial=1:obj.inputs.totalConds;
            mrk=['mrk' num2str(obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.marker})];
            if((obj.inputs.trial<=max(AllConditionsFirstTrial)))
                experimental_condition = [];
                experimental_condition{1}.name = 'random';
                experimental_condition{1}.phase_target = 0;
                experimental_condition{1}.phase_plusminus = pi;
                experimental_condition{1}.marker = 3;
                experimental_condition{1}.random_delay_range = 0.1;
                experimental_condition{1}.port = 1;
                obj.tc.(mrk).stimvalue = [obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.si}{1,1}{1,4} 1.0 1.00];
                switch obj.app.par.hardware_settings.(char(obj.inputs.condsAll.cond1.st1.stim_device)).slct_device
                    case 9
                        obj.tc.(mrk).stepsize = [0.4 0.4 0.4];
                        obj.tc.(mrk).minstep =  0.01;
                        obj.tc.(mrk).maxstep =  1.00;
                        obj.tc.(mrk).minvalue = 0.20;
                        obj.tc.(mrk).maxvalue = 99.9;
                    otherwise
                        obj.tc.(mrk).stepsize = [1 1 1];
                        obj.tc.(mrk).minstep =  1;
                        obj.tc.(mrk).maxstep =  8;
                        obj.tc.(mrk).minvalue = 1;
                        obj.tc.(mrk).maxvalue = 99;
                end
                obj.tc.(mrk).responses = {[] [] []};
                obj.tc.(mrk).stimvalues = {[] [] []};  %storage for post-hoc review
                obj.tc.(mrk).stepsizes = {[] [] []};   %storage for post-hoc review
                obj.tc.(mrk).lastdouble = [0,0,0];
                obj.tc.(mrk).lastreverse = [0,0,0];
            end
            StimDevice=1;
            stimtype = 1;
            experimental_condition{1}.port = 1;
            
            condition = experimental_condition{1};
            
            
            obj.tc.(mrk).stimvalues{StimDevice} = [obj.tc.(mrk).stimvalues{StimDevice}, round(obj.tc.(mrk).stimvalue(StimDevice),2)];
            obj.tc.(mrk).stepsizes{StimDevice} = [obj.tc.(mrk).stepsizes{StimDevice}, round(obj.tc.(mrk).stepsize(StimDevice),2)];
            
            %             obj.inputs.results.(obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.chLab}{1,obj.inputs.chLab_idx}).MEPAmplitude(obj.inputs.trial,1)=input('enter mep amp  ');
            
            MEPP2PAmpNonZeroIndex=find(obj.inputs.results.(obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.chLab}{1,obj.inputs.chLab_idx}).MEPAmplitude,1,'last');
            MEPP2PAmp=obj.inputs.results.(obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.chLab}{1,obj.inputs.chLab_idx}).MEPAmplitude(MEPP2PAmpNonZeroIndex);
            if MEPP2PAmp >= (obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.threshold}*(1000))
                disp('Hit')
                answer = 1;
            else
                disp('Miss')
                answer = 0;
            end
            
            obj.tc.(mrk).responses{StimDevice} = [obj.tc.(mrk).responses{StimDevice}, answer];
            
            
            if length(obj.tc.(mrk).responses{StimDevice}) == 1
                if answer == 1
                    obj.tc.(mrk).stepsize(StimDevice) =  -obj.tc.(mrk).stepsize(StimDevice);
                end
            elseif length(obj.tc.(mrk).responses{StimDevice}) == 2
                if obj.tc.(mrk).responses{StimDevice}(end) ~= obj.tc.(mrk).responses{StimDevice}(end-1)
                    obj.tc.(mrk).stepsize(StimDevice) = -obj.tc.(mrk).stepsize(StimDevice)/2;
                    fprintf(' Step Reversed and Halved\n')
                    obj.tc.(mrk).lastreverse(StimDevice) = length(obj.tc.(mrk).responses{StimDevice});
                end
                
            elseif length(obj.tc.(mrk).responses{StimDevice})  == 3
                if obj.tc.(mrk).responses{StimDevice}(end) ~= obj.tc.(mrk).responses{StimDevice}(end-1)
                    obj.tc.(mrk).stepsize(StimDevice) = -obj.tc.(mrk).stepsize(StimDevice)/2;
                    fprintf(' Step Reversed and Halved\n')
                    obj.tc.(mrk).lastreverse(StimDevice) = length(obj.tc.(mrk).responses{StimDevice});
                elseif obj.tc.(mrk).responses{StimDevice}(end) == obj.tc.(mrk).responses{StimDevice}(end-1) && obj.tc.(mrk).responses{StimDevice}(end) == obj.tc.(mrk).responses{StimDevice}(end-2)
                    obj.tc.(mrk).stepsize(StimDevice) = obj.tc.(mrk).stepsize(StimDevice)*2;
                    fprintf(' Step Size Doubled\n')
                    obj.tc.(mrk).lastdouble(StimDevice) = length(obj.tc.(mrk).responses{StimDevice});
                end
                
            elseif length(obj.tc.(mrk).responses{StimDevice}) > 3
                if obj.tc.(mrk).responses{StimDevice}(end) ~= obj.tc.(mrk).responses{StimDevice}(end-1)
                    %             rule 1
                    obj.tc.(mrk).stepsize(StimDevice) = -obj.tc.(mrk).stepsize(StimDevice)/2;
                    fprintf(' Step Reversed and Halved\n')
                    obj.tc.(mrk).lastreverse(StimDevice) = length(obj.tc.(mrk).responses{StimDevice});
                    %             rule 2 doesnt  need any specific dealing
                    %             rule 4
                elseif obj.tc.(mrk).responses{StimDevice}(end) == obj.tc.(mrk).responses{StimDevice}(end-2) && obj.tc.(mrk).responses{StimDevice}(end) == obj.tc.(mrk).responses{StimDevice}(end-3)
                    obj.tc.(mrk).stepsize(StimDevice) = obj.tc.(mrk).stepsize(StimDevice)*2;
                    fprintf(' Step Size Doubled\n')
                    obj.tc.(mrk).lastdouble(StimDevice) = length(obj.tc.(mrk).responses{StimDevice});
                    %             rule 3
                elseif obj.tc.(mrk).responses{StimDevice}(end) == obj.tc.(mrk).responses{StimDevice}(end-1) && obj.tc.(mrk).responses{StimDevice}(end) == obj.tc.(mrk).responses{StimDevice}(end-2) && obj.tc.(mrk).lastdouble(StimDevice) ~= obj.tc.(mrk).lastreverse(StimDevice)-1
                    obj.tc.(mrk).stepsize(StimDevice) = obj.tc.(mrk).stepsize(StimDevice)*2;
                    fprintf(' Step Size Doubled\n')
                    obj.tc.(mrk).lastdouble(StimDevice) = length(obj.tc.(mrk).responses{StimDevice});
                end
                
            end
            
            if abs(obj.tc.(mrk).stepsize(StimDevice)) < obj.tc.(mrk).minstep
                if obj.tc.(mrk).stepsize(StimDevice) < 0
                    obj.tc.(mrk).stepsize(StimDevice) = -obj.tc.(mrk).minstep;
                else
                    obj.tc.(mrk).stepsize(StimDevice) = obj.tc.(mrk).minstep;
                end
            end
            
            obj.tc.(mrk).stimvalue(StimDevice) = obj.tc.(mrk).stimvalue(StimDevice) + obj.tc.(mrk).stepsize(StimDevice);
            
            if obj.tc.(mrk).stimvalue(StimDevice) < obj.tc.(mrk).minvalue
                obj.tc.(mrk).stimvalue(StimDevice) = obj.tc.(mrk).minvalue;
                disp('Minimum value reached.')
            end
            
            if obj.tc.(mrk).stimvalue(StimDevice) > obj.tc.(mrk).maxvalue
                obj.tc.(mrk).stimvalue(StimDevice) = obj.tc.(mrk).maxvalue;
                disp('Max value reached.')
            end
            
            ConditionMarker=obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.marker};
            TrialsNoForThisMarker=find(vertcat(obj.inputs.trialMat{1:end,obj.inputs.colLabel.marker})==ConditionMarker);
            TrialToUpdate=find(TrialsNoForThisMarker>obj.inputs.trial);
            if ~isempty(TrialToUpdate)
                TrialToUpdate=TrialsNoForThisMarker(TrialToUpdate(1));
                obj.inputs.trialMat{TrialToUpdate,obj.inputs.colLabel.si}{1,1}{1,1}=obj.tc.(mrk).stimvalue(StimDevice);
                obj.inputs.trialMat{TrialToUpdate,obj.inputs.colLabel.si}{1,1}{1,4}=obj.tc.(mrk).stimvalue(StimDevice);
            end
        end
        function mep_threshold_MLE(obj)
            mrk=['mrk' num2str(obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.marker})];
            
            if ~isfield(obj.inputs.Handles.ThresholdData,mrk)
                [~,obj.inputs.Handles.ThresholdData.(mrk).L]=MT_initialize_likelihood_mth(obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.si}{1,1}{1,4});
            end
            MEPP2PAmpNonZeroIndex=find(obj.inputs.results.(obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.chLab}{1,obj.inputs.chLab_idx}).MEPAmplitude,1,'last');
            MEPP2PAmp=obj.inputs.results.(obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.chLab}{1,obj.inputs.chLab_idx}).MEPAmplitude(MEPP2PAmpNonZeroIndex);
            % MEPP2PAmp=input('enter mep amp  ');
            [nextInt,obj.inputs.Handles.ThresholdData.(mrk).L]=MT_update_likelihood_mth(MEPP2PAmp,obj.inputs.Handles.ThresholdData.(mrk).L);
            ConditionMarker=obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.marker};
            TrialsNoForThisMarker=find(vertcat(obj.inputs.trialMat{1:end,obj.inputs.colLabel.marker})==ConditionMarker);
            TrialToUpdate=find(TrialsNoForThisMarker>obj.inputs.trial);
            if ~isempty(TrialToUpdate)
                TrialToUpdate=TrialsNoForThisMarker(TrialToUpdate(1));
                obj.inputs.trialMat{TrialToUpdate,obj.inputs.colLabel.si}{1,1}{1,1}=nextInt;
                obj.inputs.trialMat{TrialToUpdate,obj.inputs.colLabel.si}{1,1}{1,4}=nextInt;
            end
            function [nextInt, L] = MT_initialize_likelihood_mth(startInt)
                
                % Custom cdf where 'm' is mean and '0.07*m' is predifined variance
                cdfFormula = @(m) normcdf(0:0.5:100,m,0.07*m);
                
                % this is the cdf I am trying to emulate
                realCdf = zeros(2,201);
                spot = 1;
                for i = 0:0.5:100
                    realCdf(1,spot) = i;
                    spot = spot + 1;
                end
                if startInt<10
                    startInt=10;
                end
                central=startInt;
                first=(2*central+1)-20;
                last=(2*central+1)+20;
                
                realCdf(2,:) = normcdf(0:0.5:100,central,0.07*central);
                
                %% Log likelihood function
                L = zeros(2,201);
                spot = 1;
                for i = 0:0.5:100
                    L(1,spot) = i;
                    spot = spot + 1;
                end
                %% Start with hit at 100% intensity and miss at 0% intensity
                spot = 1;
                for i = 0:0.5:100 % go through all possible intensities
                    thisCdf = cdfFormula(i);
                    % calculate log likelihood function
                    L(2,spot) = log(thisCdf(last)) + log(1-thisCdf(first));
                    spot = spot + 1;
                end
                
                %%
                
                %find max values, returns intensity (no indice problem)
                maxValues = L(1,find(L(2,:) == max(L(2,:))));
                
                % Middle Value from maxValues
                nextInt = round((min(maxValues) + max(maxValues))/2);
                % nextInt=sprintf('%.1f', nextInt)
                
                
            end
            function [nextInt, L] = MT_update_likelihood_mth(MEP, L)
                
                % Custom cdf where 'm' is mean and '0.07*m' is predifined variance
                cdfFormula = @(m) normcdf(0:0.5:100,m,0.07*m);
                
                
                if MEP >= (obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.threshold}*(1000))
                    disp('Hit')
                    evokedMEP = 1;
                else
                    disp('Miss')
                    evokedMEP = 0;
                    
                end
                
                %find max values
                maxValues = L(1,find(L(2,:) == max(L(2,:))));
                % Middle Value from maxValues
                nextInt = round((min(maxValues) + max(maxValues))/2);
                
                
                % calculate updated log likelihood function
                spot = 1;
                for i = 0:0.5:100 % go through all possible intensities
                    thisCdf = cdfFormula(i);
                    central=nextInt*2+1;
                    
                    if evokedMEP == 1 % hit!
                        L(2,spot) = L(2,spot) + 1*log(thisCdf(central));
                    elseif evokedMEP == 0 % miss!
                        L(2,spot) = L(2,spot) + 1*log(1-thisCdf(central));
                    end
                    spot = spot + 1;
                end
                %find max values
                maxValues = L(1,find(L(2,:) == max(L(2,:))));
                % Middle Value from maxValues
                nextInt = round((min(maxValues) + max(maxValues))/2);
                %nextInt = maxValues(round(length(maxValues)/2));
                %display(sprintf('using next intensity: %.2f', nextInt))
            end
        end
        function psych_threshold(obj)
            %             if first trial, read from starting intensity
            %                 otherwise read from the evokness and write to the
            %                 intensity function
            AllConditionsFirstTrial=1:obj.inputs.totalConds;
            mrk=['mrk' num2str(obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.marker})];
            if((obj.inputs.trial<=max(AllConditionsFirstTrial)))
                experimental_condition = [];
                experimental_condition{1}.name = 'random';
                experimental_condition{1}.phase_target = 0;
                experimental_condition{1}.phase_plusminus = pi;
                experimental_condition{1}.marker = 3;
                experimental_condition{1}.random_delay_range = 0.1;
                experimental_condition{1}.port = 1;
                obj.tc.(mrk).stimvalue = [obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.si}{1,1}{1,4} 1.0 1.00];
                obj.tc.(mrk).stepsize = [0.4 0.4 0.4];
                obj.tc.(mrk).minstep =  0.01;
                obj.tc.(mrk).maxstep =  1.00;
                obj.tc.(mrk).minvalue = 0.20;
                obj.tc.(mrk).maxvalue = 90;
                obj.tc.(mrk).responses = {[] [] []};
                obj.tc.(mrk).stimvalues = {[] [] []};  %storage for post-hoc review
                obj.tc.(mrk).stepsizes = {[] [] []};   %storage for post-hoc review
                
                obj.tc.(mrk).lastdouble = [0,0,0];
                obj.tc.(mrk).lastreverse = [0,0,0];
            end
            StimDevice=1;
            stimtype = 1;
            experimental_condition{1}.port = 1;
            
            condition = experimental_condition{1};
            
            
            obj.tc.(mrk).stimvalues{StimDevice} = [obj.tc.(mrk).stimvalues{StimDevice}, round(obj.tc.(mrk).stimvalue(StimDevice),2)];
            obj.tc.(mrk).stepsizes{StimDevice} = [obj.tc.(mrk).stepsizes{StimDevice}, round(obj.tc.(mrk).stepsize(StimDevice),2)];
            
            %             obj.inputs.results.(obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.chLab}{1,obj.inputs.chLab_idx}).MEPAmplitude(obj.inputs.trial,1)=input('enter mep amp  ');
            %             obj.inputs.results.(obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.chLab}{1,obj.inputs.chLab_idx}).MEPAmplitude
            %             m(1:find(m,1,'last'))
            MEPP2PAmpNonZeroIndex=find(obj.inputs.rawData.(obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.chLab}{1,obj.inputs.chLab_idx}).data,1,'last');
            MEPP2PAmp=obj.inputs.rawData.(obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.chLab}{1,obj.inputs.chLab_idx}).data(MEPP2PAmpNonZeroIndex);
            if MEPP2PAmp == (obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.threshold}) % take the threshol for that particular condition, take the condition name from the marker or put that in the cond
                disp('Hit')
                answer = 1;
            else
                disp('Miss')
                answer = 0;
            end
            
            obj.tc.(mrk).responses{StimDevice} = [obj.tc.(mrk).responses{StimDevice}, answer];
            
            
            if length(obj.tc.(mrk).responses{StimDevice}) == 1
                if answer == 1
                    obj.tc.(mrk).stepsize(StimDevice) =  -obj.tc.(mrk).stepsize(StimDevice);
                end
            elseif length(obj.tc.(mrk).responses{StimDevice}) == 2
                if obj.tc.(mrk).responses{StimDevice}(end) ~= obj.tc.(mrk).responses{StimDevice}(end-1)
                    obj.tc.(mrk).stepsize(StimDevice) = -obj.tc.(mrk).stepsize(StimDevice)/2;
                    fprintf(' Step Reversed and Halved\n')
                    obj.tc.(mrk).lastreverse(StimDevice) = length(obj.tc.(mrk).responses{StimDevice});
                end
                
            elseif length(obj.tc.(mrk).responses{StimDevice})  == 3
                if obj.tc.(mrk).responses{StimDevice}(end) ~= obj.tc.(mrk).responses{StimDevice}(end-1)
                    obj.tc.(mrk).stepsize(StimDevice) = -obj.tc.(mrk).stepsize(StimDevice)/2;
                    fprintf(' Step Reversed and Halved\n')
                    obj.tc.(mrk).lastreverse(StimDevice) = length(obj.tc.(mrk).responses{StimDevice});
                elseif obj.tc.(mrk).responses{StimDevice}(end) == obj.tc.(mrk).responses{StimDevice}(end-1) && obj.tc.(mrk).responses{StimDevice}(end) == obj.tc.(mrk).responses{StimDevice}(end-2)
                    obj.tc.(mrk).stepsize(StimDevice) = obj.tc.(mrk).stepsize(StimDevice)*2;
                    fprintf(' Step Size Doubled\n')
                    obj.tc.(mrk).lastdouble(StimDevice) = length(obj.tc.(mrk).responses{StimDevice});
                end
                
            elseif length(obj.tc.(mrk).responses{StimDevice}) > 3
                if obj.tc.(mrk).responses{StimDevice}(end) ~= obj.tc.(mrk).responses{StimDevice}(end-1)
                    %             rule 1
                    obj.tc.(mrk).stepsize(StimDevice) = -obj.tc.(mrk).stepsize(StimDevice)/2;
                    fprintf(' Step Reversed and Halved\n')
                    obj.tc.(mrk).lastreverse(StimDevice) = length(obj.tc.(mrk).responses{StimDevice});
                    %             rule 2 doesnt  need any specific dealing
                    %             rule 4
                elseif obj.tc.(mrk).responses{StimDevice}(end) == obj.tc.(mrk).responses{StimDevice}(end-2) && obj.tc.(mrk).responses{StimDevice}(end) == obj.tc.(mrk).responses{StimDevice}(end-3)
                    obj.tc.(mrk).stepsize(StimDevice) = obj.tc.(mrk).stepsize(StimDevice)*2;
                    fprintf(' Step Size Doubled\n')
                    obj.tc.(mrk).lastdouble(StimDevice) = length(obj.tc.(mrk).responses{StimDevice});
                    %             rule 3
                elseif obj.tc.(mrk).responses{StimDevice}(end) == obj.tc.(mrk).responses{StimDevice}(end-1) && obj.tc.(mrk).responses{StimDevice}(end) == obj.tc.(mrk).responses{StimDevice}(end-2) && obj.tc.(mrk).lastdouble(StimDevice) ~= obj.tc.(mrk).lastreverse(StimDevice)-1
                    obj.tc.(mrk).stepsize(StimDevice) = obj.tc.(mrk).stepsize(StimDevice)*2;
                    fprintf(' Step Size Doubled\n')
                    obj.tc.(mrk).lastdouble(StimDevice) = length(obj.tc.(mrk).responses{StimDevice});
                end
                
            end
            
            if abs(obj.tc.(mrk).stepsize(StimDevice)) < obj.tc.(mrk).minstep
                if obj.tc.(mrk).stepsize(StimDevice) < 0
                    obj.tc.(mrk).stepsize(StimDevice) = -obj.tc.(mrk).minstep;
                else
                    obj.tc.(mrk).stepsize(StimDevice) = obj.tc.(mrk).minstep;
                end
            end
            
            obj.tc.(mrk).stimvalue(StimDevice) = obj.tc.(mrk).stimvalue(StimDevice) + obj.tc.(mrk).stepsize(StimDevice);
            
            if obj.tc.(mrk).stimvalue(StimDevice) < obj.tc.(mrk).minvalue
                obj.tc.(mrk).stimvalue(StimDevice) = obj.tc.(mrk).minvalue;
                disp('Minimum value reached.')
            end
            
            if obj.tc.(mrk).stimvalue(StimDevice) > obj.tc.(mrk).maxvalue
                obj.tc.(mrk).stimvalue(StimDevice) = obj.tc.(mrk).maxvalue;
                disp('Max value reached.')
            end
            
            ConditionMarker=obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.marker};
            TrialsNoForThisMarker=find(vertcat(obj.inputs.trialMat{1:end,obj.inputs.colLabel.marker})==ConditionMarker);
            TrialToUpdate=find(TrialsNoForThisMarker>obj.inputs.trial);
            if ~isempty(TrialToUpdate)
                TrialToUpdate=TrialsNoForThisMarker(TrialToUpdate(1));
                obj.inputs.trialMat{TrialToUpdate,obj.inputs.colLabel.si}{1,1}{1,1}=obj.tc.(mrk).stimvalue(StimDevice);
                obj.inputs.trialMat{TrialToUpdate,obj.inputs.colLabel.si}{1,1}{1,4}=obj.tc.(mrk).stimvalue(StimDevice);
            end
        end
        function psych_threshold_MLE(obj)
            mrk=['mrk' num2str(obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.marker})];
            
            if ~isfield(obj.inputs.Handles.ThresholdData,mrk)
                [~,obj.inputs.Handles.ThresholdData.(mrk).L]=MT_initialize_likelihood_psychmth(obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.si}{1,1}{1,4});
            end
            MEPP2PAmpNonZeroIndex=find(obj.inputs.rawData.(obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.chLab}{1,obj.inputs.chLab_idx}).data,1,'last');
            MEPP2PAmp=obj.inputs.rawData.(obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.chLab}{1,obj.inputs.chLab_idx}).data(MEPP2PAmpNonZeroIndex);
            [nextInt,obj.inputs.Handles.ThresholdData.(mrk).L]=MT_update_likelihood_psychmth(MEPP2PAmp,obj.inputs.Handles.ThresholdData.(mrk).L);
            ConditionMarker=obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.marker};
            TrialsNoForThisMarker=find(vertcat(obj.inputs.trialMat{1:end,obj.inputs.colLabel.marker})==ConditionMarker);
            TrialToUpdate=find(TrialsNoForThisMarker>obj.inputs.trial);
            if ~isempty(TrialToUpdate)
                TrialToUpdate=TrialsNoForThisMarker(TrialToUpdate(1));
                obj.inputs.trialMat{TrialToUpdate,obj.inputs.colLabel.si}{1,1}{1,1}=nextInt;
                obj.inputs.trialMat{TrialToUpdate,obj.inputs.colLabel.si}{1,1}{1,4}=nextInt;
            end
            function [nextInt, L] = MT_initialize_likelihood_psychmth(startInt)
                
                % Custom cdf where 'm' is mean and '0.07*m' is predifined variance
                cdfFormula = @(m) normcdf(0:0.1:10,m,0.07*m);
                
                % this is the cdf I am trying to emulate
                realCdf = zeros(2,101);
                spot = 1;
                for i = 0:0.1:10
                    realCdf(1,spot) = i;
                    spot = spot + 1;
                end
                if startInt<1
                    startInt=1;
                end
                central=startInt;
                first=(central*10+1)-10;
                last=(central*10+1)+10;
                
                realCdf(2,:) = normcdf(0:0.1:10,central,0.07*central);
                
                %% Log likelihood function
                L = zeros(2,101);
                spot = 1;
                for i = 0:0.1:10
                    L(1,spot) = i;
                    spot = spot + 1;
                end
                %% Start with hit at 100% intensity and miss at 0% intensity
                spot = 1;
                for i = 0:0.1:10 % go through all possible intensities
                    thisCdf = cdfFormula(i);
                    % calculate log likelihood function
                    L(2,spot) = log(thisCdf(last)) + log(1-thisCdf(first));
                    spot = spot + 1;
                end
                
                %%
                
                %find max values, returns intensity (no indice problem)
                maxValues = L(1,find(L(2,:) == max(L(2,:))));
                
                % Middle Value from maxValues
                nextInt = round((min(maxValues) + max(maxValues))/2,1);
                % nextInt=sprintf('%.1f', nextInt)
                
                
            end
            function [nextInt, L] = MT_update_likelihood_psychmth(MEP, L)
                
                % Custom cdf where 'm' is mean and '0.07*m' is predifined variance
                cdfFormula = @(m) normcdf(0:0.1:10,m,0.07*m);
                
                
                if MEP ==1
                    disp('Hit')
                    evokedMEP = 1;
                else
                    disp('Miss')
                    evokedMEP = 0;
                    
                end
                
                %find max values
                maxValues = L(1,find(L(2,:) == max(L(2,:))));
                % Middle Value from maxValues
                nextInt = round((min(maxValues) + max(maxValues))/2,1);
                
                
                % calculate updated log likelihood function
                spot = 1;
                for i = 0:0.1:10 % go through all possible intensities
                    thisCdf = cdfFormula(i);
                    central=nextInt*10+1;
                    
                    if evokedMEP == 1 % hit!
                        L(2,spot) = L(2,spot) + 1*log(thisCdf(central));
                    elseif evokedMEP == 0 % miss!
                        L(2,spot) = L(2,spot) + 1*log(1-thisCdf(central));
                    end
                    spot = spot + 1;
                end
                %find max values
                maxValues = L(1,find(L(2,:) == max(L(2,:))));
                % Middle Value from maxValues
                nextInt = round((min(maxValues) + max(maxValues))/2,1);
                %nextInt = maxValues(round(length(maxValues)/2));
                %display(sprintf('using next intensity: %.2f', nextInt))
            end
        end
        function mep_threshold_trace_plot(obj)
            ax=['ax' num2str(obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.axesno}{1,obj.inputs.chLab_idx})];
            axes(obj.app.pr.ax.(ax)), hold on,
            switch obj.inputs.trial
                case num2cell(1:obj.inputs.totalConds)
                    YData=obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.si}{1,1}{1,1};
                    ConditionMarker=obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.marker};
                    TrialsNoForThisMarker=find(vertcat(obj.inputs.trialMat{1:end,obj.inputs.colLabel.marker})==ConditionMarker);
                    TrialToUpdate=find(TrialsNoForThisMarker>obj.inputs.trial);
                    TrialToUpdate=TrialsNoForThisMarker(TrialToUpdate(1));
                    YDataPlusOne=obj.inputs.trialMat{TrialToUpdate,obj.inputs.colLabel.si}{1,1}{1,1};
                    obj.inputs.Handles.(ax).mtplot=plot(YData,'LineWidth',2);
                    xlabel('Trial Number');
                    
                    set(gcf, 'color', 'w')
                    obj.inputs.Handles.(ax).mt_nextIntensityDot=plot(2,YDataPlusOne,'o','Color','r','MarkerSize',4,'MarkerFaceColor','r');
                    switch obj.app.par.hardware_settings.(char(obj.inputs.condsAll.cond1.st1.stim_device)).slct_device
                        case 9
                            ylabel('Stimulation Intensities (mA)');
                            xticks(1:2:1000); yticks(0:0.2:20); ylim auto
                            textMotorThresholdStatus={['Trials to Average:' num2str(obj.inputs.NoOfTrialsToAverage)],['Threshold (mV):' sprintf('%.1f',obj.inputs.MotorThreshold)]};
                        otherwise
                            ylabel('Stimulation Intensities (%MSO)');
                            yticks(0:2:100); xticks(1:1:1000); ylim auto
                            textMotorThresholdStatus={['Trials to Average:' num2str(obj.inputs.NoOfTrialsToAverage)],['Threshold (%MSO):' num2str(obj.inputs.MotorThreshold)]};
                    end
                    xlim([obj.app.pr.ax.(ax).XLim(1) obj.app.pr.ax.(ax).XLim(2)+1])
                    ylim([obj.app.pr.ax.(ax).YLim(1) (obj.app.pr.ax.(ax).YLim(2)*1.1)])
                    obj.app.pr.ax.(ax).UserData.status=text(obj.app.pr.ax.(ax),1,1,textMotorThresholdStatus,'units','normalized','HorizontalAlignment','right','VerticalAlignment','cap','color',[0.45 0.45 0.45]);
                    obj.app.pr.ax.(ax).UserData.ThresholdGirdLine=gridxy([],YData,'Color','k','linewidth',1,'Parent',obj.app.pr.ax.(ax));
                otherwise
                    ConditionMarker=obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.marker};
                    TrialsNoForThisMarker=find(vertcat(obj.inputs.trialMat{1:end,obj.inputs.colLabel.marker})==ConditionMarker);
                    TrialToUpdate=find(TrialsNoForThisMarker>obj.inputs.trial);
                    obj.inputs.Handles.(ax).mtplot.YData=[obj.inputs.Handles.(ax).mtplot.YData obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.si}{1,1}{1,1}];
                    if ~isempty(TrialToUpdate)
                        TrialToUpdate=TrialsNoForThisMarker(TrialToUpdate(1));
                        YDataPlusOne=obj.inputs.trialMat{TrialToUpdate,obj.inputs.colLabel.si}{1,1}{1,1};
                        obj.inputs.Handles.(ax).mt_nextIntensityDot.XData=obj.inputs.Handles.(ax).mt_nextIntensityDot.XData+1;
                        obj.inputs.Handles.(ax).mt_nextIntensityDot.YData=YDataPlusOne;
                    end
                    xlim([obj.app.pr.ax.(ax).XLim(1) obj.app.pr.ax.(ax).XLim(2)+1])
                    ylim auto; ylim([obj.app.pr.ax.(ax).YLim(1) (obj.app.pr.ax.(ax).YLim(2)*1.1)])
                    Channel=obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.chLab}{1,obj.inputs.chLab_idx};
                    obj.computeMotorThreshold(Channel,obj.inputs.Handles.(ax).mtplot.YData)
                    obj.app.pr.ax.(ax).UserData.status.String={['Trials to Average:' num2str(obj.inputs.results.(Channel).NoOfLastTrialsToAverage)],['Threshold (%MSO):' num2str(obj.inputs.results.(Channel).MotorThreshold)]};
                    delete(obj.app.pr.ax.(ax).UserData.ThresholdGirdLine)
                    obj.app.pr.ax.(ax).UserData.ThresholdGirdLine=gridxy([],obj.inputs.results.(Channel).MotorThreshold,'Color','k','linewidth',1,'Parent',obj.app.pr.ax.(ax));
            end
        end
        function psych_threshold_trace_plot(obj)
            ax=['ax' num2str(obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.axesno}{1,obj.inputs.chLab_idx})];
            axes(obj.app.pr.ax.(ax)), hold on,
            switch obj.inputs.trial
                case num2cell(1:obj.inputs.totalConds)
                    YData=obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.si}{1,1}{1,1};
                    ConditionMarker=obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.marker};
                    TrialsNoForThisMarker=find(vertcat(obj.inputs.trialMat{1:end,obj.inputs.colLabel.marker})==ConditionMarker);
                    TrialToUpdate=find(TrialsNoForThisMarker>obj.inputs.trial);
                    TrialToUpdate=TrialsNoForThisMarker(TrialToUpdate(1));
                    YDataPlusOne=obj.inputs.trialMat{TrialToUpdate,obj.inputs.colLabel.si}{1,1}{1,1};
                    obj.inputs.Handles.(ax).mtplot=plot(YData,'LineWidth',2);
                    xlabel('Trial Number');
                    ylabel('Stimulation Intensities (mA)');
                    set(gcf, 'color', 'w')
                    obj.inputs.Handles.(ax).mt_nextIntensityDot=plot(2,YDataPlusOne,'o','Color','r','MarkerSize',4,'MarkerFaceColor','r');
                    xticks(1:2:1000); yticks(0:0.2:20); ylim auto
                    xlim([obj.app.pr.ax.(ax).XLim(1) obj.app.pr.ax.(ax).XLim(2)+1])
                    ylim([obj.app.pr.ax.(ax).YLim(1) (obj.app.pr.ax.(ax).YLim(2)*1.1)])
                    textPsychometricThresholdStatus={['Trials to Average:' num2str(obj.inputs.NoOfTrialsToAverage)],['Threshold (mV):' sprintf('%.1f',obj.inputs.PsychometricThreshold)]};
                    obj.app.pr.ax.(ax).UserData.status=text(obj.app.pr.ax.(ax),1,1,textPsychometricThresholdStatus,'units','normalized','HorizontalAlignment','right','VerticalAlignment','cap','color',[0.45 0.45 0.45]);
                    obj.app.pr.ax.(ax).UserData.ThresholdGirdLine=gridxy([],YData,'Color','k','linewidth',1,'Parent',obj.app.pr.ax.(ax));
                otherwise
                    xticks(1:1:1000);
                    ConditionMarker=obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.marker};
                    TrialsNoForThisMarker=find(vertcat(obj.inputs.trialMat{1:end,obj.inputs.colLabel.marker})==ConditionMarker);
                    TrialToUpdate=find(TrialsNoForThisMarker>obj.inputs.trial);
                    obj.inputs.Handles.(ax).mtplot.YData=[obj.inputs.Handles.(ax).mtplot.YData obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.si}{1,1}{1,1}];
                    if ~isempty(TrialToUpdate)
                        TrialToUpdate=TrialsNoForThisMarker(TrialToUpdate(1));
                        YDataPlusOne=obj.inputs.trialMat{TrialToUpdate,obj.inputs.colLabel.si}{1,1}{1,1};
                        obj.inputs.Handles.(ax).mt_nextIntensityDot.XData=obj.inputs.Handles.(ax).mt_nextIntensityDot.XData+1;
                        obj.inputs.Handles.(ax).mt_nextIntensityDot.YData=YDataPlusOne;
                    end
                    xlim([obj.app.pr.ax.(ax).XLim(1) obj.app.pr.ax.(ax).XLim(2)+1])
                    ylim auto; ylim([obj.app.pr.ax.(ax).YLim(1) (obj.app.pr.ax.(ax).YLim(2)*1.1)])
                    Channel=obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.chLab}{1,obj.inputs.chLab_idx};
                    obj.computePsychometricThreshold(Channel,obj.inputs.Handles.(ax).mtplot.YData)
                    obj.app.pr.ax.(ax).UserData.status.String={['Trials to Average:' num2str(obj.inputs.results.(Channel).NoOfLastTrialsToAverage)],['Threshold (mV):' sprintf('%.1f',obj.inputs.results.(Channel).PsychometricThreshold)]};
                    delete(obj.app.pr.ax.(ax).UserData.ThresholdGirdLine)
                    obj.app.pr.ax.(ax).UserData.ThresholdGirdLine=gridxy([],obj.inputs.results.(Channel).PsychometricThreshold,'Color','k','linewidth',1,'Parent',obj.app.pr.ax.(ax));
            end
        end
        function computePsychometricThreshold(obj,Channel,AllIntensities)
            if obj.inputs.results.(Channel).NoOfLastTrialsToAverage<numel(AllIntensities)
                obj.inputs.results.(Channel).PsychometricThreshold=round(mean(AllIntensities(end-obj.inputs.results.(Channel).NoOfLastTrialsToAverage:end)),1);
            else
                obj.inputs.results.(Channel).PsychometricThreshold=round(mean(AllIntensities),1);
            end
        end
        function computeMotorThreshold(obj,Channel,AllIntensities)
            if obj.inputs.results.(Channel).NoOfLastTrialsToAverage<numel(AllIntensities)
                obj.inputs.results.(Channel).MotorThreshold=ceil(mean(AllIntensities(end-obj.inputs.results.(Channel).NoOfLastTrialsToAverage:end)));
            else
                obj.inputs.results.(Channel).MotorThreshold=ceil(mean(AllIntensities));
            end
        end
        function TEPMeasurementVerticalPlot(obj)
            ax=['ax' num2str(obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.axesno}{1,obj.inputs.chLab_idx})];
            cfg=[];
            cfg.trials=obj.inputs.trial;
            load('S5_raw_segmented.mat');
            obj.inputs.PreProcessedData=data;
            dataA=ft_selectdata(cfg, obj.inputs.PreProcessedData);
            cfg=[];
            cfg.channel=obj.inputs.PreProcessedData.label(1:64);
            dataB=ft_selectdata(cfg, dataA);
            dataB.label=obj.inputs.rawData.ftdata.label;
            cfg=[];
            cfg.viewmode='vertical';
            ft_databrowser(cfg,dataB);
            ah=copy(gca); fh=gcf; fh.Visible='off';
            delete(allchild(obj.app.pr.container.(ax)))
            copyobj(ah,obj.app.pr.container.(ax))
            delete(fh); pause(0.1);
        end
        function TEPMeasurementSinglePlot(obj)
            ax=['ax' num2str(obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.axesno}{1,obj.inputs.chLab_idx})];
            cfg=[];
            cfg.trials=obj.inputs.trial;
            load('S5_raw_segmented.mat');
            obj.inputs.PreProcessedData=data;
            dataA=ft_selectdata(cfg, obj.inputs.PreProcessedData);
            cfg=[];
            cfg.channel=obj.inputs.PreProcessedData.label(5);
            dataB=ft_selectdata(cfg, dataA);
            dataB.label={'C3'};
            cfg=[];
            cfg.viewmode='vertical';
            ft_databrowser(cfg,dataB);
            ah=copy(gca); fh=gcf; fh.Visible='off';
            delete(allchild(obj.app.pr.container.(ax)))
            copyobj(ah,obj.app.pr.container.(ax))
            gca, ylim auto;
            delete(fh); pause(0.1);
        end
        function TEPMeasurementTopoPlot(obj)
            ax=['ax' num2str(obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.axesno}{1,obj.inputs.chLab_idx})];
            
            cfg=[];
            cfg.layout='easycapM1.mat';
            layout=ft_prepare_layout(cfg);
            
            load('S5_raw_segmented.mat');
            obj.inputs.PreProcessedData=data;
            
            cfg=[];
            cfg.channel=obj.inputs.PreProcessedData.label(1:64);
            dataB=ft_selectdata(cfg, obj.inputs.PreProcessedData);
            layout.label=dataB.label;
            
            
            cfg=[];
            cfg.layout=layout;
            cfg.colorbar='yes';
            cfg.trials=obj.inputs.trial;
            figure('Visible','off'); ft_topoplotER(cfg,dataB);
            fh=gcf; % fh.Visible='off';
            delete(allchild(obj.app.pr.container.(ax)))
            fh.Children(3).Parent=obj.app.pr.container.(ax);
            %             fh.Children(2).Parent=obj.app.pr.container.(ax);
            
            delete(fh); pause(0.1);
        end
        function TEPMeasurementMultiPlot(obj)
            ax=['ax' num2str(obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.axesno}{1,obj.inputs.chLab_idx})];
            
            cfg=[];
            cfg.layout='easycapM1.mat';
            layout=ft_prepare_layout(cfg);
            
            load('S5_raw_segmented.mat');
            obj.inputs.PreProcessedData=data;
            
            cfg=[];
            cfg.channel=obj.inputs.PreProcessedData.label(1:64);
            dataB=ft_selectdata(cfg, obj.inputs.PreProcessedData);
            layout.label=dataB.label;
            
            
            cfg=[];
            cfg.layout=layout;
            cfg.colorbar='yes';
            cfg.trials=obj.inputs.trial;
            figure('Visible','off'); ft_multiplotER(cfg,dataB);
            fh=gcf; % fh.Visible='off';
            delete(allchild(obj.app.pr.container.(ax)))
            fh.Children(2).Parent=obj.app.pr.container.(ax);
            %             fh.Children(2).Parent=obj.app.pr.container.(ax);
            
            delete(fh); pause(0.1);
        end
        function StatusTable(obj)
            ax=['ax' num2str(obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.axesno}{1,obj.inputs.chLab_idx})];
            if obj.inputs.trial~=obj.inputs.totalTrials
                obj.app.pr.ax.(ax).Data(1,1)={[num2str(obj.inputs.trial) '/' num2str(obj.inputs.totalTrials)]};
                obj.app.pr.ax.(ax).Data(1,2)={[num2str(obj.inputs.trial+1) '/' num2str(obj.inputs.totalTrials)]};
                obj.app.pr.ax.(ax).Data(2,1)={num2str(obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.iti})};
                obj.app.pr.ax.(ax).Data(2,2)={num2str(obj.inputs.trialMat{obj.inputs.trial+1,obj.inputs.colLabel.iti})};
                obj.app.pr.ax.(ax).Data(3,1)={num2str(obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.si}{1,1}{1,4})};
                obj.app.pr.ax.(ax).Data(3,2)={num2str(obj.inputs.trialMat{obj.inputs.trial+1,obj.inputs.colLabel.si}{1,1}{1,4})};
            else
                obj.app.pr.ax.(ax).Data(1,1)={[num2str(obj.inputs.trial) '/' num2str(obj.inputs.totalTrials)]};
                obj.app.pr.ax.(ax).Data(1,2)={''};
                obj.app.pr.ax.(ax).Data(2,1)={num2str(obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.iti})};
                obj.app.pr.ax.(ax).Data(2,2)={''};
                obj.app.pr.ax.(ax).Data(3,1)={num2str(obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.si}{1,1}{1,4})};
                obj.app.pr.ax.(ax).Data(3,2)={''};
            end
        end
        
        function planTrials_scopePeriods(obj)
            disp enteredtimevect-------------
            
            switch obj.app.par.hardware_settings.(char(obj.inputs.input_device)).slct_device
                case 1 % boss box
                    % multiplying by 5 because the sampling rate is 5khz
                    % and the time is in milieseconds
                    if isfield(obj.inputs,'prestim_scope_plt') && isfield(obj.inputs,'poststim_scope_plt')
                        obj.inputs.sc_samples=((obj.inputs.prestim_scope_plt)+(obj.inputs.poststim_scope_plt))*5;
                        obj.inputs.sc_prepostsamples=(obj.inputs.prestim_scope_plt)*(-5);
                        obj.inputs.timeVect=linspace(-1*(obj.inputs.prestim_scope_plt),obj.inputs.poststim_scope_plt,obj.inputs.sc_samples);
                    end
                    
                    %onset, offset samples conversion to sampling rate
                    if isfield(obj.inputs,'mep_onset') && isfield(obj.inputs,'mep_offset')
                        obj.inputs.mep_onset_samples=(obj.inputs.prestim_scope_plt+obj.inputs.mep_onset)*5;
                        obj.inputs.mep_offset_samples=(obj.inputs.mep_offset+obj.inputs.prestim_scope_plt)*5;
                    end
                    disp enteredtimevect-------------
                    % 18-Mar-2020 18:11:00
                    %                     switch char(obj.inputs.measure_str) || char(obj.inputs.sub_measure_str)%because not all will require MEPs to plot such as the intervention functions or multi stimulator paradigm so this is nec
                    %                         case {'MEP Measurement','Motor Hotspot Search','Motor Threshold Hunting','IOC'}
                    %                             disp enteredtimevect-------------
                    %                         otherwise
                    %                     end
                    
                case 2 % fieldtrip
                    % http://www.fieldtriptoolbox.org/faq/how_should_i_get_started_with_the_fieldtrip_realtime_buffer/
                case 3 %Future: input box
                case 4  % simulated data
                    obj.inputs.sc_samples=((obj.inputs.prestim_scope_plt)+(obj.inputs.poststim_scope_plt))*5;
                case 5 %Future: no input box is selected
            end
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
        
        function boot_magven(obj)
            obj.magven=magventure(obj.app.par.hardware_settings.(char(obj.inputs.output_device)).comport);
            obj.magven.connect;
            obj.magven.arm;
        end
        function boot_magstim(obj)
            obj.magStim=magstim(obj.app.par.hardware_settings.(obj.inputs.output_device).comport);
            obj.magStim.connect;
            obj.magStim.arm;
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
        function boot_digitimer(obj,OutputDevice)
            obj.digitimer.(OutputDevice)=best_digitimer(obj);
            
        end
        function boot_bossbox(obj)
            obj.bossbox=best_sync2brain_bossdevice(obj);
        end
        function boot_fieldtrip(obj)
            obj.fieldtrip=best_fieldtrip(obj);
        end
        function FilteredData = best_VisualizationFilter(obj,RawData)
            data=RawData;
            % Iteration for First Order
            m=mean(data(1,1:50));
            m=abs(m);
            if(m>0)
                data(1,:)=data(1,:)+m;
            end
            if(m<=0)
                %
                data(1,:)=data(1,:)-m;
            end
            % Iteration for Second Order
            m=mean(data(1,1:50));
            m=abs(m);
            if(m>0)
                data(1,:)=data(1,:)-m;
            end
            if(m<=0)
                %
                data(1,:)=data(1,:)+m;
            end
            FilteredData=data;
        end
        function PlotPhaseHistogram(obj)
            ax=['ax' num2str(obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.axesno}{1,obj.inputs.chLab_idx})];
            axes(obj.app.pr.ax.(ax)), hold on,
            ThisChannelName=obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.chLab}{1,obj.inputs.chLab_idx};
            
            ThisPhase=obj.inputs.rawData.(ThisChannelName).data(obj.inputs.trial,1);
            if obj.inputs.trial==1, legend('Location','southoutside','Orientation','horizontal'); hold on; end
            if obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.phase}{1,1}==0 && obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.phase}{1,2}~=pi %Peak
                if ~(isfield(obj.inputs.Handles,'PhaseHistogramPeak'))
                    obj.inputs.Handles.PhaseHistogramPeak=polarhistogram(ThisPhase,20,'FaceColor','green','BinEdges',deg2rad([0 5:10:355 360]),'DisplayName','Peak');
                else
                    obj.inputs.Handles.PhaseHistogramPeak=polarhistogram([obj.inputs.Handles.PhaseHistogramPeak.Data ThisPhase],20,'FaceColor','green','BinEdges',deg2rad(0:5:360));
                    obj.inputs.Handles.PhaseHistogramPeak.Annotation.LegendInformation.IconDisplayStyle = 'off';
                end
            elseif obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.phase}{1,1}==pi && obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.phase}{1,2}~=pi %Trough
                if ~(isfield(obj.inputs.Handles,'PhaseHistogramTrough'))
                    obj.inputs.Handles.PhaseHistogramTrough=polarhistogram(ThisPhase,20,'FaceColor','red','BinEdges',deg2rad([0 5:10:355 360]),'DisplayName','Trough');
                else
                    obj.inputs.Handles.PhaseHistogramTrough=polarhistogram([obj.inputs.Handles.PhaseHistogramTrough.Data ThisPhase],20,'FaceColor','red','BinEdges',deg2rad(0:5:360));
                    obj.inputs.Handles.PhaseHistogramTrough.Annotation.LegendInformation.IconDisplayStyle = 'off';
                end
            elseif obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.phase}{1,1}==0 && obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.phase}{1,2}==pi %Random
                if ~(isfield(obj.inputs.Handles,'PhaseHistogramRandom'))
                    obj.inputs.Handles.PhaseHistogramRandom=polarhistogram(ThisPhase,20,'FaceColor','blue','BinEdges',deg2rad([0 5:10:355 360]),'DisplayName','Random');
                else
                    obj.inputs.Handles.PhaseHistogramRandom=polarhistogram([obj.inputs.Handles.PhaseHistogramRandom.Data ThisPhase],20,'FaceColor','blue','BinEdges',deg2rad(0:5:360));
                    obj.inputs.Handles.PhaseHistogramRandom.Annotation.LegendInformation.IconDisplayStyle = 'off';
                end
            elseif obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.phase}{1,1}==-pi/2 && obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.phase}{1,2}~=pi %Rising Flank
                if ~(isfield(obj.inputs.Handles,'PhaseHistogramRising'))
                    obj.inputs.Handles.PhaseHistogramRising=polarhistogram(ThisPhase,20,'FaceColor','y','BinEdges',deg2rad([0 5:10:355 360]),'DisplayName','Rising');
                else
                    obj.inputs.Handles.PhaseHistogramRising=polarhistogram([obj.inputs.Handles.PhaseHistogramRising.Data ThisPhase],20,'FaceColor','y','BinEdges',deg2rad(0:5:360));
                    obj.inputs.Handles.PhaseHistogramRising.Annotation.LegendInformation.IconDisplayStyle = 'off';
                end
            elseif obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.phase}{1,1}==pi/2 && obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.phase}{1,2}~=pi %Falling Flank
                if ~(isfield(obj.inputs.Handles,'PhaseHistogramFalling'))
                    obj.inputs.Handles.PhaseHistogramFalling=polarhistogram(ThisPhase,20,'FaceColor','m','BinEdges',deg2rad([0 5:10:355 360]),'DisplayName','Falling');
                else
                    obj.inputs.Handles.PhaseHistogramFalling=polarhistogram([obj.inputs.Handles.PhaseHistogramFalling.Data ThisPhase],20,'FaceColor','m','BinEdges',deg2rad(0:5:360));
                    obj.inputs.Handles.PhaseHistogramFalling.Annotation.LegendInformation.IconDisplayStyle = 'off';
                end
            end
            %             if isfield(obj.inputs.Handles,'PhaseHistogramPeak'), legend(obj.inputs.Handles.PhaseHistogramPeak,'Peak','Location','southoutside','Orientation','horizontal'), end
            %             if isfield(obj.inputs.Handles,'PhaseHistogramTrough'), legend(obj.inputs.Handles.PhaseHistogramTrough,'Trough','Location','southoutside','Orientation','horizontal'), end
            %             if isfield(obj.inputs.Handles,'PhaseHistogramRandom'), legend(obj.inputs.Handles.PhaseHistogramRandom, 'Random','Location','southoutside','Orientation','horizontal'), end
            % if isfield(obj.inputs.Handles,'PhaseHistogramPeak') && isfield(obj.inputs.Handles,'PhaseHistogramTrough') && isfield(obj.inputs.Handles,'PhaseHistogramRandom')
            %     legend([obj.inputs.Handles.PhaseHistogramPeak obj.inputs.Handles.PhaseHistogramTrough obj.inputs.Handles.PhaseHistogramRandom], 'Location','southoutside','Orientation','horizontal')
            % end
            
        end % End obj.PlotPhaseHistogram
        function PlotTriggerLockedEEG(obj)
            ax=['ax' num2str(obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.axesno}{1,obj.inputs.chLab_idx})];
            axes(obj.app.pr.ax.(ax)), hold on,
            ThisChannelName=obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.chLab}{1,obj.inputs.chLab_idx};
            ThisEEGTime=obj.inputs.rawData.IEEG.time;
            if obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.phase}{1,1}==0 && obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.phase}{1,2}~=pi %Peak
                if(isfield(obj.inputs.Handles,'TriggerLockedEEGPeak')==0)
                    ThisEEG=obj.inputs.rawData.(ThisChannelName).data(obj.inputs.trial,:);
                    obj.inputs.Handles.TriggerLockedEEGPeak=plot(ThisEEGTime,ThisEEG,'color','green','LineWidth',2,'DisplayName','Peak');
                    legend('Location','southoutside','Orientation','horizontal'); hold on;
                    obj.inputs.Handles.TriggerLockedEEGPeak.UserData(1,1)=obj.inputs.trial;
                else
                    obj.inputs.Handles.TriggerLockedEEGPeak.UserData(1,1+numel(obj.inputs.Handles.TriggerLockedEEGPeak.UserData))=obj.inputs.trial;
                    obj.inputs.Handles.TriggerLockedEEGPeak.YData=mean(obj.inputs.rawData.(ThisChannelName).data(obj.inputs.Handles.TriggerLockedEEGPeak.UserData,:));
                    drawnow;
                end
            elseif obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.phase}{1,1}==pi && obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.phase}{1,2}~=pi %Trough
                if(isfield(obj.inputs.Handles,'TriggerLockedEEGTrough')==0)
                    ThisEEG=obj.inputs.rawData.(ThisChannelName).data(obj.inputs.trial,:);
                    obj.inputs.Handles.TriggerLockedEEGTrough=plot(ThisEEGTime, ThisEEG,'color','red','LineWidth',2,'DisplayName','Trough');
                    obj.inputs.Handles.TriggerLockedEEGTrough.UserData(1,1)=obj.inputs.trial;
                else
                    obj.inputs.Handles.TriggerLockedEEGTrough.UserData(1,1+numel(obj.inputs.Handles.TriggerLockedEEGTrough.UserData))=obj.inputs.trial;
                    obj.inputs.Handles.TriggerLockedEEGTrough.YData=mean(obj.inputs.rawData.(ThisChannelName).data(obj.inputs.Handles.TriggerLockedEEGTrough.UserData,:));
                    drawnow;
                end
            elseif obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.phase}{1,1}==0 && obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.phase}{1,2}==pi %Random
                if(isfield(obj.inputs.Handles,'TriggerLockedEEGRandom')==0)
                    ThisEEG=obj.inputs.rawData.(ThisChannelName).data(obj.inputs.trial,:);
                    obj.inputs.Handles.TriggerLockedEEGRandom=plot(ThisEEGTime, ThisEEG,'color','blue','LineWidth',2,'DisplayName','Random');
                    obj.inputs.Handles.TriggerLockedEEGRandom.UserData(1,1)=obj.inputs.trial;
                else
                    obj.inputs.Handles.TriggerLockedEEGRandom.UserData(1,1+numel(obj.inputs.Handles.TriggerLockedEEGRandom.UserData))=obj.inputs.trial;
                    obj.inputs.Handles.TriggerLockedEEGRandom.YData=mean(obj.inputs.rawData.(ThisChannelName).data(obj.inputs.Handles.TriggerLockedEEGRandom.UserData,:));
                    drawnow;
                end
            elseif obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.phase}{1,1}==-pi/2 && obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.phase}{1,2}~=pi %Rising Flank
                if(isfield(obj.inputs.Handles,'TriggerLockedEEGRising')==0)
                    ThisEEG=obj.inputs.rawData.(ThisChannelName).data(obj.inputs.trial,:);
                    obj.inputs.Handles.TriggerLockedEEGRising=plot(ThisEEGTime, ThisEEG,'color','y','LineWidth',2,'DisplayName','Rising');
                    obj.inputs.Handles.TriggerLockedEEGRising.UserData(1,1)=obj.inputs.trial;
                else
                    obj.inputs.Handles.TriggerLockedEEGRising.UserData(1,1+numel(obj.inputs.Handles.TriggerLockedEEGRising.UserData))=obj.inputs.trial;
                    obj.inputs.Handles.TriggerLockedEEGRising.YData=mean(obj.inputs.rawData.(ThisChannelName).data(obj.inputs.Handles.TriggerLockedEEGRising.UserData,:));
                    drawnow;
                end
            elseif obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.phase}{1,1}==pi/2 && obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.phase}{1,2}~=pi %Falling Flank
                if(isfield(obj.inputs.Handles,'TriggerLockedEEGFalling')==0)
                    ThisEEG=obj.inputs.rawData.(ThisChannelName).data(obj.inputs.trial,:);
                    obj.inputs.Handles.TriggerLockedEEGFalling=plot(ThisEEGTime, ThisEEG,'color','m','LineWidth',2,'DisplayName','Falling');
                    obj.inputs.Handles.TriggerLockedEEGFalling.UserData(1,1)=obj.inputs.trial;
                else
                    obj.inputs.Handles.TriggerLockedEEGFalling.UserData(1,1+numel(obj.inputs.Handles.TriggerLockedEEGFalling.UserData))=obj.inputs.trial;
                    obj.inputs.Handles.TriggerLockedEEGFalling.YData=mean(obj.inputs.rawData.(ThisChannelName).data(obj.inputs.Handles.TriggerLockedEEGFalling.UserData,:));
                    drawnow;
                end
            end
            if obj.inputs.trial==1
                xlim(obj.app.pr.ax.(ax),obj.inputs.EEGXLimit), ylim(obj.app.pr.ax.(ax),obj.inputs.EEGYLimit), drawnow
                xticks(obj.app.pr.ax.(ax),unique(sort([0 obj.inputs.EEGXLimit])))
                ZeroLine=gridxy(0,'Color','k','linewidth',2,'Parent',obj.app.pr.ax.(ax),'Tag','TriggerLockedEEGZeroLine');hold on;
                ZeroLine.Annotation.LegendInformation.IconDisplayStyle = 'off'; legend('Location','southoutside','Orientation','horizontal'); hold on;
            end
        end %End obj.PlotTriggerLockedEEG
        function PlotRunnigAmplitude(obj)
            ax=['ax' num2str(obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.axesno}{1,obj.inputs.chLab_idx})];
            axes(obj.app.pr.ax.(ax)), hold on,
            ThisChannelName=obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.chLab}{1,obj.inputs.chLab_idx};
            switch obj.inputs.trial
                case 1
                    obj.inputs.Handles.RunnigAmplitude=plot(obj.inputs.rawData.(ThisChannelName).data(obj.inputs.trial,:),'color','red','LineWidth',1.5);
                    xlabel(['Celan Data for last' num2str(obj.inputs.AmplitudeAssignmentPeriod) ' min']);
                    ylabel('Ossiciliation Amplitude ( /mu V)');
                otherwise
                    obj.inputs.Handles.RunnigAmplitude.YData=obj.inputs.rawData.(ThisChannelName).data(obj.inputs.trial,:);
            end
        end
        function ERPTriggerLockedEEG(obj)
            ax=['ax' num2str(obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.axesno}{1,obj.inputs.chLab_idx})];
            axes(obj.app.pr.ax.(ax)), hold on,
            ThisChannelName=obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.chLab}{1,obj.inputs.chLab_idx};
            ThisEEGTime=obj.inputs.rawData.IEEG.time;
            if(isfield(obj.inputs.Handles,'ERP')==0)
                ThisEEG=obj.inputs.rawData.(ThisChannelName).data(obj.inputs.trial,:);
                obj.inputs.Handles.ERP=plot(ThisEEGTime,ThisEEG,'color','red','LineWidth',2,'DisplayName','ERP');
                legend('Location','southoutside','Orientation','horizontal'); hold on;
                obj.inputs.Handles.ERP.UserData(1,1)=obj.inputs.trial;
            else
                obj.inputs.Handles.ERP.UserData(1,1+numel(obj.inputs.Handles.ERP.UserData))=obj.inputs.trial;
                obj.inputs.Handles.ERP.YData=mean(obj.inputs.rawData.(ThisChannelName).data(obj.inputs.Handles.ERP.UserData,:));
                drawnow;
            end
            if obj.inputs.trial==1
                xlim(obj.app.pr.ax.(ax),obj.inputs.EEGXLimit), ylim(obj.app.pr.ax.(ax),obj.inputs.EEGYLimit), drawnow
                xticks(obj.app.pr.ax.(ax),unique(sort([0 obj.inputs.EEGXLimit(1):10:obj.inputs.EEGXLimit(2)])))
                ZeroLine=gridxy(0,'Color','k','linewidth',2,'Parent',obj.app.pr.ax.(ax),'Tag','TriggerLockedEEGZeroLine');hold on;
                ZeroLine.Annotation.LegendInformation.IconDisplayStyle = 'off'; legend('Location','southoutside','Orientation','horizontal'); hold on;
            end
        end %End obj.PlotTriggerLockedEEG
        function DeMeanedEEGData =best_DeMeanEEG(obj,RawData)
            DeMeanedEEGData=RawData-mean(RawData);
            
            %             DeMeanedEEGData=RawData-mean(RawData(1:(obj.inputs.EEGDisplayPeriodPre*5)));
            %             m=mean(RawData(1:(obj.inputs.EEGDisplayPeriodPre*5)));
            %             if(m>0)
            %                 DeMeanedEEGData=RawData-m;
            %             elseif(m<0)
            %                 DeMeanedEEGData=RawData+m;
            %             end
            
        end
        function Response = responseKeyboardAndMouse(obj)
            Pressed=getkeywait(obj.inputs.ResponsePeriod/1000);
            if Pressed==-1
                Response=-1;
            else
                Response=1;
            end
            %             f=figure('Name','Response Box | BEST Toolbox','numbertitle', 'off','ToolBar', 'none','MenuBar', 'none','WindowStyle', 'modal','Units', 'normal', 'Position', [0.5 0.5 .25 .05],'Resize','off','CloseRequestFcn',@(~,~)CloseReqFcn);
            %             uicontrol( 'Style','text','Parent', f,'String','Did the subject experience a sensation? ' ,'FontSize',13,'HorizontalAlignment','center','Units','normalized','Position',[0.05 0.5 1 0.4]);
            %             uicontrol( 'Style','pushbutton','Parent', f,'String','Yes','FontSize',12,'HorizontalAlignment','center','Units','normalized','Position',[0.3 0.05 0.2 0.4],'Callback',@cbResponse);
            %             uicontrol( 'Style','pushbutton','Parent', f,'String','No','FontSize',12,'HorizontalAlignment','center','Units','normalized','Position',[0.6 0.05 0.2 0.4],'Callback',@cbResponse);
            %             waitfor(f)
            %             function cbResponse(source,~)
            %                 switch source.String
            %                     case 'Yes'
            %                         Response=1;
            %                     case 'No'
            %                         Response=-1;
            %                 end
            %                 delete(f)
            %             end
            %             function CloseReqFcn, end
        end
        function help (obj)
            %% ----EMG Line Noise Removal Start
            %% Checking toolboxes
            try which ft_defaults; catch, disp ('Umair, Fieldtrip is not on path'), end
            try which nt_zapline; catch, disp ('Umair, NoseTools Toolbox is not on path. Download from: http://audition.ens.fr/adc/NoiseTools/'), end
            
            %% loading sim_mep data
            load sim_mep;
            ftmep=sim_mep';
            
            %% Fieldtrip DFT Method 1
            [filt] = ft_preproc_dftfilter(ftmep, 5000, 50,'dftreplace','zero');
            figure
            plot(ftmep,'DisplayName','unfiltered')
            hold on
            plot(filt,'DisplayName','filtered')
            legend
            
            %% Fieldtrip DFT Method 2
            [filt2] = ft_preproc_dftfilter(ftmep, 5000, [40 51],'dftreplace','neighbour','dftbandwidth', [1 2], 'dftneighbourwidth', [2 2]);
            figure
            plot(ftmep,'DisplayName','unfiltered')
            hold on
            plot(filt2,'DisplayName','filtered')
            legend
            
            %% Fieldtrip Bandstop Filter
            [filt3] = ft_preproc_bandstopfilter(ftmep, 5000, [40 51],4);
            figure
            plot(ftmep,'DisplayName','unfiltered')
            hold on
            plot(filt3,'DisplayName','filtered')
            legend
            
            %% Zap Line Case 1, Fs=5000
            [filt4,~]=nt_zapline(sim_mep,50/5000,1);
            figure
            plot(sim_mep,'DisplayName','unfiltered')
            hold on
            plot(filt4,'DisplayName','filtered')
            legend
            
            %% Zap Line Case 2, Fs=1000
            [filt4,~]=nt_zapline(sim_mep,50/1000,1);
            figure
            plot(sim_mep,'DisplayName','unfiltered')
            hold on
            plot(filt4,'DisplayName','filtered')
            legend
            
            %% Zap Line Case 2, Fs=500
            [filt4,~]=nt_zapline(sim_mep,50/500,1);
            figure
            plot(sim_mep,'DisplayName','unfiltered')
            hold on
            plot(filt4,'DisplayName','filtered')
            legend
            
            %% ----EMG Line Noise Removal End
            
        end
        %% Old Scripts
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
        function best_ioc_OLD(obj)
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
        %% Result Oriented Functions
        function drc_bs2 (obj)
            for tt=1:obj.inputs.totalTrials
                tic
                obj.trigTrial;
                obj.readTrial;
                plotTrial_bs2;
                tic
                obj.saveRuntime;
                toc
                pause(1)
                obj.prepTrial;
                wait_period=obj.inputs.trialMat{obj.inputs.trial-1,obj.inputs.colLabel.iti}-toc;
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
                disp('................................................');
            end
            function plotTrial_bs2
            for i=1:numel(obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.chLab})
                disp entered--------------------------------------------------------====================
                
                obj.inputs.chLab_idx=i;
                (obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.measures}{1,i})
                switch (obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.measures}{1,i})
                    case 'MEP_Measurement'
                        mep_plot_bs2;
                    case 'Threshold Trace'
                        switch obj.inputs.ThresholdMethod
                            case 1
                                obj.mep_threshold;
                            case 2
                                obj.mep_threshold_MLE;
                        end
                        obj.mep_threshold_trace_plot;
                    case 'IOC'
                    case 'Motor Hotspot Search'
                    case 'MEP Scatter Plot'
                        obj.mep_scat_plot;
                    case 'MEP IOC Fit'
                        obj.ioc_fit_plot;
                    case 'PhaseHistogram'
                        obj.PlotPhaseHistogram;
                    case 'TriggerLockedEEG'
                        obj.PlotTriggerLockedEEG;
                    case 'Psychometric Threshold Trace'
                        switch obj.inputs.ThresholdMethod
                            case 1
                                obj.psych_threshold;
                            case 2
                                obj.psych_threshold_MLE;
                        end
                        obj.psych_threshold_trace_plot;
                    case 'TEP Measurement Vertical Plot'
                        obj.TEPMeasurementVerticalPlot;
                    case 'TEP Measurement Single Plot'
%                         obj.TEPMeasurementSinglePlot;
                        obj.ERPTriggerLockedEEG;
                    case 'TEP Measurement Topo Plot'
                        obj.TEPMeasurementTopoPlot;
                    case 'TEP Measurement Multi Plot'
                        obj.TEPMeasurementMultiPlot;
                    case 'StatusTable'
                        obj.StatusTable;
                end
                AxesNum=obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.axesno}{1,obj.inputs.chLab_idx};
                AxesField=['ax' num2str(obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.axesno}{1,obj.inputs.chLab_idx})];
                CopiedAxes=copy(obj.app.pr.ax.(AxesField));
                CopiedAxes.Parent=[]; pause(0.1)
                obj.inputs.Figures{AxesNum}=CopiedAxes;
            end
            end
            function mep_plot_bs2
                ax=['ax' num2str(obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.axesno}{1,obj.inputs.chLab_idx})];
            axes(obj.app.pr.ax.(ax)), hold on,
            ThisChannelName=obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.chLab}{1,obj.inputs.chLab_idx};
            %% Preparing Condition wrt to Dose Function
            switch obj.inputs.DoseFunction
                case {1,2,3}
                    cd=['cd' num2str(obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.stimcdMrk})];
                case 4
                    cd=['cd' num2str(obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.iti})];
                otherwise
                    error('BEST Toolbox: MEP Plot Function does not any have Dose Function to decide about plot condition.')
            end
            if ~(isfield(obj.inputs.Handles,cd))
                switch obj.inputs.DoseFunction
                    case 1 %TS
                        DisplayName=['TS:' num2str(obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.si}{1,1}{1,1})];
                        obj.app.pr.ax.(ax).UserData.ColorsIndex=obj.app.pr.ax.(ax).UserData.ColorsIndex+1;
                    case 2 %CS
                        if obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.si}{1,1}{1,2}~=0
                            DisplayName=['CS:' num2str(obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.si}{1,1}{1,2})];
                        else
                            DisplayName=['TS:' num2str(obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.si}{1,1}{1,1})];
                        end
                        obj.app.pr.ax.(ax).UserData.ColorsIndex=obj.app.pr.ax.(ax).UserData.ColorsIndex+1;
                    case 3 %ISI
                        if obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.si}{1,1}{1,3}~=0
                            DisplayName=['ISI:' num2str(obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.si}{1,1}{1,3})];
                        else
                            DisplayName=['TS:' num2str(obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.si}{1,1}{1,1})];
                        end
                        obj.app.pr.ax.(ax).UserData.ColorsIndex=obj.app.pr.ax.(ax).UserData.ColorsIndex+1;
                    case 4 %ITI
                        DisplayName=['ITI:' num2str(obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.iti})];
                        obj.app.pr.ax.(ax).UserData.ColorsIndex=obj.app.pr.ax.(ax).UserData.ColorsIndex+1;
                end
            end
            %% Plot Latest Trial
            if ~(isfield(obj.inputs.Handles,'LatestMEP'))
                obj.inputs.Handles.LatestMEP=plot(obj.inputs.timeVect,obj.inputs.rawData.(ThisChannelName).data(obj.inputs.trial,:),'LineStyle','-.','Color','k','LineWidth',1.5,'DisplayName','Latest','Parent',obj.app.pr.ax.(ax));
                legend('Location','southoutside','Orientation','horizontal'); hold on;
            else
                obj.inputs.Handles.LatestMEP.YData=obj.inputs.rawData.(ThisChannelName).data(obj.inputs.trial,:);
                drawnow;
            end
            %% Plot Mean respectively prepared condition
            if ~(isfield(obj.inputs.Handles,cd))
                obj.inputs.Handles.(cd)=plot(obj.inputs.timeVect,obj.inputs.rawData.(ThisChannelName).data(obj.inputs.trial,:),'Color',obj.app.pr.ax.(ax).UserData.Colors(obj.app.pr.ax.(ax).UserData.ColorsIndex,:),'LineWidth',2,'DisplayName',DisplayName,'Parent',obj.app.pr.ax.(ax));
                obj.inputs.Handles.(cd).UserData(1,1)=obj.inputs.trial;
                legend('Location','southoutside','Orientation','horizontal'); hold on;
                
            else
                obj.inputs.Handles.(cd).UserData(1,1+numel(obj.inputs.Handles.(cd).UserData))=obj.inputs.trial;
                obj.inputs.Handles.(cd).YData=mean(obj.inputs.rawData.(ThisChannelName).data(obj.inputs.Handles.(cd).UserData,:));
                drawnow;
            end
            %% Plotting Zero and Search Window GirdLine on 1st Trial only
            if obj.inputs.trial==1
                ZeroLine=gridxy([0 (obj.inputs.mep_onset):0.25:(obj.inputs.mep_offset)],'Color',[219/255 246/255 255/255],'linewidth',4,'Parent',obj.app.pr.ax.(ax)) ;
                ZeroLine.Annotation.LegendInformation.IconDisplayStyle = 'off';
                xlim([obj.inputs.EMGXLimit(1), obj.inputs.EMGXLimit(2)]);
                mat1=obj.inputs.prestim_scope_plt*(-1):20:obj.inputs.poststim_scope_plt;
                mat2=[0 obj.inputs.mep_onset*1000 obj.inputs.mep_offset*1000 obj.inputs.timeVect(end)];
                mat=unique(sort([mat1 mat2]));
                xticks(mat);
                xlabel('Time (ms)');
                ylim([obj.inputs.ylimMin obj.inputs.ylimMax]);
                mat3=linspace(obj.inputs.ylimMin,obj.inputs.ylimMax,5);
                mat4=unique(sort([0 mat3]));
                yticks(mat4);
                ylabel('EMG Potential (\mu V)');
            end
            %% Trigger MEPP2P Amplitude Calculation
            obj.mep_amp;
            uistack(obj.inputs.Handles.LatestMEP,'top')
            end
            function scat_plot_bs2
               
            ax=['ax' num2str(obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.axesno}{1,obj.inputs.chLab_idx})];
            axes(obj.app.pr.ax.(ax)), hold on, ylim auto
            if  numel(obj.inputs.ResponseFunctionNumerator) ==1 && numel(obj.inputs.ResponseFunctionDenominator) ==1 && any(obj.inputs.ResponseFunctionNumerator==obj.inputs.ResponseFunctionDenominator)
                %% Preparing xvalue on the basis of Dose Function
                switch obj.inputs.DoseFunction
                    case 1 % TS
                        xvalue=obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.si}{1,1}{1,1};
                        if obj.inputs.trial==1
                            xlabelstring='TS Intensity';
                            ylabelstring='MEP P2P Amplitude (\muV)';
                            si(1,1)=0;
                            for iSI=1:obj.inputs.totalTrials %Previously this was so, now changed1:numel([obj.inputs.trialMat{:,obj.inputs.colLabel.si}]')
                                si(iSI,1)=obj.inputs.trialMat{iSI,obj.inputs.colLabel.si}{1,1}{1,1};
                            end
                            si=unique(si,'stable');
                            xlimvector=[min(si)-(min(si)*.10) max(si)+(max(si)*.10)];
                            xtickvector=unique(sort([si']));
                        end
                    case 2 % CS
                        xvalue=obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.si}{1,1}{1,2};
                        if obj.inputs.trial==1
                            xlabelstring='CS Intensity';
                            ylabelstring='MEP P2P Amplitude (\muV)';
                            si(1,1)=0;
                            for iSI=1:numel([obj.inputs.trialMat{:,obj.inputs.colLabel.si}]')
                                si(iSI,1)=obj.inputs.trialMat{iSI,obj.inputs.colLabel.si}{1,1}{1,2};
                            end
                            si=unique(si,'stable');
                            xlimvector=[min(si)-(min(si)*10) max(si)+(max(si)*10)];
                            xtickvector=unique(sort([si']));
                        end
                    case 3 % ISI
                        xvalue=obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.si}{1,1}{1,3};
                        if obj.inputs.trial==1
                            xlabelstring='ISI (ms)';
                            ylabelstring='MEP P2P Amplitude (\muV)';
                            si(1,1)=0;
                            for iSI=1:numel([obj.inputs.trialMat{:,obj.inputs.colLabel.si}]')
                                si(iSI,1)=obj.inputs.trialMat{iSI,obj.inputs.colLabel.si}{1,1}{1,3};
                            end
                            si=unique(si,'stable');
                            xlimvector=[min(si)-(min(si)*.10) max(si)+(max(si)*.10)];
                            xtickvector=unique(sort([si']));
                        end
                    case 4 % ITI
                        xvalue=obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.iti};
                        if obj.inputs.trial==1
                            xlabelstring='ITI (ms)';
                            ylabelstring='MEP P2P Amplitude (\muV)';
                            si(1,1)=0;
                            for iSI=1:numel([obj.inputs.trialMat{:,obj.inputs.colLabel.iti}]')
                                si(iSI,1)=obj.inputs.trialMat{iSI,obj.inputs.colLabel.iti};
                            end
                            si=unique(si,'stable');
                            xlimvector=[min(si)-(min(si)*.10) max(si)+(max(si)*.10)];
                            xtickvector=unique(sort([si']));
                        end
                end
                %% Preparing yvalue
                yvalue=obj.inputs.results.(obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.chLab}{1,obj.inputs.chLab_idx}).MEPAmplitude(obj.inputs.trial,1);
                %% Plotting
                switch obj.inputs.trial
                    case 1
                        obj.info.plt.(ax).ioc_scatplot=plot(xvalue,yvalue,'o','Color','r','MarkerSize',8,'MarkerFaceColor','r');
                        hold on;
                        xlabel(xlabelstring); ylabel(ylabelstring); xlim(xlimvector); xticks(xtickvector);
                    otherwise
                        set(obj.info.plt.(ax).ioc_scatplot,'Color',[0.45 0.45 0.45],'MarkerSize',8,'MarkerFaceColor',[0.45 0.45 0.45])
                end
                obj.info.plt.(ax).ioc_scatplot=plot(xvalue,yvalue,'o','MarkerSize',8,'Color','r','MarkerFaceColor','r'); hold on; uistack(obj.info.plt.(ax).ioc_scatplot,'top')
            elseif numel(obj.inputs.ResponseFunctionNumerator)>1
                %% Preparing xvalue on the basis of Dose Function
                switch obj.inputs.DoseFunction
                    case 1 % TS
                        xvalue=nonzeros(obj.inputs.results.(obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.chLab}{1,obj.inputs.chLab_idx}).MEPAmplitudeRatios(:,2));
                        if obj.inputs.trial==1
                            xlabelstring='TS Intensity';
                            ylabelstring='MEP Amp. ( \muV )';
                            xlimvalue=vertcat(obj.inputs.trialMat{:,obj.inputs.colLabel.si});
                            xlimvalue=vertcat(xlimvalue{:}); xlimvalue=cell2mat(xlimvalue); xlimvalue=xlimvalue(:,1);
                            stimcdMrkvalue=vertcat(obj.inputs.trialMat{:,obj.inputs.colLabel.stimcdMrk});
                            for iDenominators=1:numel(obj.inputs.ResponseFunctionDenominator)
                                indextodelete=find(stimcdMrkvalue==obj.inputs.ResponseFunctionDenominator(iDenominators));
                                xlimvalue(indextodelete)=0;
                            end
                            xlimvalue=nonzeros(xlimvalue);
                            xlimvalue=unique(xlimvalue,'stable');
                            xlimvector=[min(xlimvalue)-(min(xlimvalue)*.10) max(xlimvalue)+(max(xlimvalue)*.10)];
                            xtickvector=unique(sort([xlimvalue']));
                        end
                    case 2 % CS
                        xvalue=nonzeros(obj.inputs.results.(obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.chLab}{1,obj.inputs.chLab_idx}).MEPAmplitudeRatios(:,3));
                        if obj.inputs.trial==1
                            xlabelstring='CS Intensity';
                            ylabelstring='MEP Amp. ( \muV )';
                            xlimvalue=vertcat(obj.inputs.trialMat{:,obj.inputs.colLabel.si});
                            xlimvalue=vertcat(xlimvalue{:}); xlimvalue=cell2mat(xlimvalue); xlimvalue=xlimvalue(:,2);
                            stimcdMrkvalue=vertcat(obj.inputs.trialMat{:,obj.inputs.colLabel.stimcdMrk});
                            for iDenominators=1:numel(obj.inputs.ResponseFunctionDenominator)
                                indextodelete=find(stimcdMrkvalue==obj.inputs.ResponseFunctionDenominator(iDenominators));
                                xlimvalue(indextodelete)=0;
                            end
                            xlimvalue=nonzeros(xlimvalue);
                            xlimvalue=unique(xlimvalue,'stable');
                            xlimvector=[min(xlimvalue)-(min(xlimvalue)*.10) max(xlimvalue)+(max(xlimvalue)*.10)];
                            xtickvector=unique(sort([xlimvalue']));
                        end
                    case 3 % ISI
                        xvalue=nonzeros(obj.inputs.results.(obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.chLab}{1,obj.inputs.chLab_idx}).MEPAmplitudeRatios(:,4));
                        if obj.inputs.trial==1
                            xlabelstring='ISI (ms)';
                            ylabelstring='MEP Amp. (\muV )';
                            xlimvalue=vertcat(obj.inputs.trialMat{:,obj.inputs.colLabel.si});
                            xlimvalue=vertcat(xlimvalue{:}); xlimvalue=cell2mat(xlimvalue); xlimvalue=xlimvalue(:,3);
                            stimcdMrkvalue=vertcat(obj.inputs.trialMat{:,obj.inputs.colLabel.stimcdMrk});
                            for iDenominators=1:numel(obj.inputs.ResponseFunctionDenominator)
                                indextodelete=find(stimcdMrkvalue==obj.inputs.ResponseFunctionDenominator(iDenominators));
                                xlimvalue(indextodelete)=0;
                            end
                            xlimvalue=nonzeros(xlimvalue);
                            xlimvalue=unique(xlimvalue,'stable');
                            xlimvector=[min(xlimvalue)-(min(xlimvalue)*.10) max(xlimvalue)+(max(xlimvalue)*.10)];
                            xtickvector=unique(sort([xlimvalue']));
                        end
                    case 4 % ITI
                        xvalue=nonzeros(obj.inputs.results.(obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.chLab}{1,obj.inputs.chLab_idx}).MEPAmplitudeRatios(:,5));
                        if obj.inputs.trial==1
                            xlabelstring='ITI (ms)';
                            ylabelstring='MEP Amp. ( \muV )';
                            xlimvalue=vertcat(obj.inputs.trialMat{:,obj.inputs.colLabel.iti});
                            stimcdMrkvalue=vertcat(obj.inputs.trialMat{:,obj.inputs.colLabel.stimcdMrk});
                            for iDenominators=1:numel(obj.inputs.ResponseFunctionDenominator)
                                indextodelete=find(stimcdMrkvalue==obj.inputs.ResponseFunctionDenominator(iDenominators));
                                xlimvalue(indextodelete)=0;
                            end
                            xlimvalue=nonzeros(xlimvalue);
                            xlimvalue=unique(xlimvalue,'stable');
                            xlimvector=[min(xlimvalue)-(min(xlimvalue)*.10) max(xlimvalue)+(max(xlimvalue)*.10)];
                            xtickvector=unique(sort([xlimvalue']));
                        end
                end
                %% Preparing yvalue
                yvalue=nonzeros(obj.inputs.results.(obj.inputs.trialMat{obj.inputs.trial,obj.inputs.colLabel.chLab}{1,obj.inputs.chLab_idx}).MEPAmplitudeRatios(:,1));
                %% Plotting
                %                 if obj.inputs.trial==1
                %                     obj.info.plt.(ax).ioc_scatplot=plot(xvalue,yvalue,'o','Color',[0.45 0.45 0.45],'MarkerSize',8,'MarkerFaceColor',[0.45 0.45 0.45]);
                %                     xlabel(xlabelstring); ylabel(ylabelstring); xlim(xlimvector); xticks(xtickvector); hold on;
                %                 else
                %                     obj.info.plt.(ax).ioc_scatplot=plot(xvalue(end),yvalue(end),'o','Color',[0.45 0.45 0.45],'MarkerSize',8,'MarkerFaceColor',[0.45 0.45 0.45]);
                %                     obj.info.plt.(ax).ioc_scatplot.XData=xvalue; obj.info.plt.(ax).ioc_scatplot.YData=yvalue;
                %                 end
                switch obj.inputs.trial
                    case 1
                        obj.info.plt.(ax).ioc_scatplot=plot(xvalue,yvalue,'o','Color','r','MarkerSize',8,'MarkerFaceColor','r'); hold on;
                        xlabel(xlabelstring); ylabel(ylabelstring); xlim(xlimvector); xticks(xtickvector);
                    otherwise
                        set(obj.info.plt.(ax).ioc_scatplot,'Color',[0.45 0.45 0.45],'MarkerSize',8,'MarkerFaceColor',[0.45 0.45 0.45])
                end
                obj.info.plt.(ax).ioc_scatplot=plot(xvalue(end),yvalue(end),'o','MarkerSize',8,'Color','r','MarkerFaceColor','r'); hold on; uistack(obj.info.plt.(ax).ioc_scatplot,'top')
            end
        
            end
        end
        
        
    end
end
