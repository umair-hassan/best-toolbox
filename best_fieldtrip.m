classdef best_fieldtrip <handle
    properties
        best_toolbox
        fieldtrip
    end
    
    methods
        function obj = best_fieldtrip(best_toolbox)
            obj.best_toolbox=best_toolbox;
        end
        
        function irasa(obj,EEGData,InputDevice)
                %% Rename obj.inputs to obj.best_toolbox.inputs
                EEGChannelsIndex=find(strcmp(obj.best_toolbox.app.par.hardware_settings.(InputDevice).NeurOneProtocolChannelSignalTypes,'EEG'));
                EEGChanelsLabels=obj.best_toolbox.app.par.hardware_settings.(InputDevice).NeurOneProtocolChannelLabels(EEGChannelsIndex);                
                %% Creating RawEEGData
                obj.best_toolbox.inputs.results.RawEEGData.label=EEGChanelsLabels';
                obj.best_toolbox.inputs.results.RawEEGData.fsample=5000;
                obj.best_toolbox.inputs.results.RawEEGData.trial={EEGData.Data};
                obj.best_toolbox.inputs.results.RawEEGData.time={EEGData.Time};
                %% Referencing RawEEGData
                if ~isempty(obj.best_toolbox.inputs.TargetChannels)
                    if ~isempty(obj.best_toolbox.inputs.ReferenceChannels)
                        cfg=[];
                        cfg.reref         = 'yes';
                        cfg.refchannel    = obj.best_toolbox.inputs.ReferenceChannels;
                        if ~isempty(obj.best_toolbox.inputs.RecordingReference)
                            cfg.implicitref   =obj.best_toolbox.inputs.RecordingReference;
                        end
                        obj.best_toolbox.inputs.results.ReReferencedData = ft_preprocessing(cfg, obj.best_toolbox.inputs.results.RawEEGData);
                    end
                end
                %% Montage Creation
                if ~isempty(obj.best_toolbox.inputs.MontageChannels)
                    montage=[];
                    montage.tra = obj.best_toolbox.inputs.MontageWeights;
                    montage.labelold = obj.best_toolbox.inputs.MontageChannels;
                    montage.labelnew = {'Montage1'};
                    obj.best_toolbox.inputs.results.MontageData = ft_apply_montage(obj.best_toolbox.inputs.results.RawEEGData,montage);
                end
                %% Selected Data
                if ~isempty(obj.best_toolbox.inputs.TargetChannels)
                    cfg=[];
                    cfg.channel = obj.best_toolbox.inputs.TargetChannels;
                    if ~isempty(obj.best_toolbox.inputs.ReferenceChannels)
                        SelectedEEGData=ft_selectdata(cfg,obj.best_toolbox.inputs.results.ReReferenced);
                    else
                        SelectedEEGData=ft_selectdata(cfg,obj.best_toolbox.inputs.results.RawEEGData) ;
                    end
                end
                
                if ~isempty(obj.best_toolbox.inputs.TargetChannels) && ~isempty(obj.best_toolbox.inputs.MontageChannels)
                    cfg=[];
                    cfg.keepsampleinfo ='no';                    
                    obj.best_toolbox.inputs.results.SelectedData=ft_appenddata(cfg , SelectedEEGData , obj.best_toolbox.inputs.results.MontageData); %% Check if this works properly
                elseif ~isempty(obj.best_toolbox.inputs.TargetChannels) && isempty(obj.best_toolbox.inputs.MontageChannels)
                    obj.best_toolbox.inputs.results.SelectedChannels=SelectedEEGData;
                elseif isempty(obj.best_toolbox.inputs.TargetChannels)>0 && ~isempty(obj.best_toolbox.inputs.MontageChannels)
                    obj.best_toolbox.inputs.results.SelectedData=obj.best_toolbox.inputs.results.MontageData;
                end
                %% Filtered Data
                cfg=[];
                if ~isempty(obj.best_toolbox.inputs.HighPassFrequency)
                    cfg.hpfilter      = 'yes'; % high-pass in order to get rid of low-freq trends
                    cfg.hpfiltord     = obj.best_toolbox.inputs.HighPassFilterOrder;
                    cfg.hpfreq        = obj.best_toolbox.inputs.HighPassFrequency;
                end
                if ~isempty(obj.best_toolbox.inputs.BandStopFrequency)
                    cfg.bsfilter      = 'yes'; % band-stop filter, to take out 50 Hz and its harmonics
                    cfg.bsfiltord     = obj.best_toolbox.inputs.BandPassFilterOrder;
                    cfg.bsfreq        = obj.best_toolbox.inputs.BandPassFrequency;
                end
                if ~isempty(cfg)
                    obj.best_toolbox.inputs.results.FilteredData = ft_preprocessing(cfg, obj.best_toolbox.inputs.results.SelectedData); %% 
                end
                %% Segmented Data
                cfg               = [];
                cfg.length        = obj.best_toolbox.inputs.EEGEpochPeriod;
                cfg.overlap       = 0;
                if isfield(obj.best_toolbox.inputs.results,'FilteredData')
                    obj.best_toolbox.inputs.results.SegmentedData = ft_redefinetrial(cfg, obj.best_toolbox.inputs.results.FilteredData);
                else
                    obj.best_toolbox.inputs.results.SegmentedData = ft_redefinetrial(cfg, obj.best_toolbox.inputs.results.SelectedData);
                end
                %% Overlapped Data etc
                w = obj.best_toolbox.inputs.results.SegmentedData.time{1}(end)-obj.best_toolbox.inputs.results.SegmentedData.time{1}(1); % window length
                cfg               = [];
                cfg.length        = w*.9;
                cfg.overlap       = 1-(((w-cfg.length)/cfg.length)/(10-1));
                obj.best_toolbox.inputs.results.OverlappedData = ft_redefinetrial(cfg, obj.best_toolbox.inputs.results.SegmentedData);
                %% Orignial, Fractal and Oscillation Components Spectral Analysis
                cfg               = [];
                cfg.foi        = [1:1/obj.best_toolbox.inputs.EEGEpochPeriod:45];
                cfg.taper         = 'hanning';
                cfg.pad           = 'nextpow2';
                cfg.keeptrials    = 'yes';
                cfg.method        = 'irasa';
                frac_r = ft_freqanalysis(cfg, obj.best_toolbox.inputs.results.OverlappedData); % Frac
                cfg.method        = 'mtmfft';
                orig_r = ft_freqanalysis(cfg, obj.best_toolbox.inputs.results.OverlappedData); %Raw
                
                % average across the sub-segments
                frac_s = {};
                orig_s = {};
                for rpt = unique(frac_r.trialinfo(:,end))'
                    cfg               = [];
                    cfg.trials        = find(frac_r.trialinfo(:,end)==rpt);
                    cfg.avgoverrpt    = 'yes';
                    frac_s{end+1} = ft_selectdata(cfg, frac_r);
                    orig_s{end+1} = ft_selectdata(cfg, orig_r);
                end
                frac_a = ft_appendfreq([], frac_s{:}); %Frac
                orig_a = ft_appendfreq([], orig_s{:}); %Raw
                
                % average across trials
                cfg               = [];
                cfg.trials        = 'all';
                cfg.avgoverrpt    = 'yes';
                obj.best_toolbox.inputs.results.FractalComponents = ft_selectdata(cfg, frac_a); %Frac
                obj.best_toolbox.inputs.results.OriginalComponents = ft_selectdata(cfg, orig_a); %Raw
                
                % subtract the fractal component from the power spectrum
                cfg               = [];
                cfg.parameter     = 'powspctrm';
                cfg.operation     = 'x2-x1';
                obj.best_toolbox.inputs.results.OscillationComponents = ft_math(cfg, obj.best_toolbox.inputs.results.FractalComponents, obj.best_toolbox.inputs.results.OriginalComponents); %Osci
                %% Percentage Difference 
                obj.best_toolbox.inputs.results.percentageOscillationOverFractalComponent.powspctrm=100*(obj.best_toolbox.inputs.results.OscillationComponents.powspctrm./obj.best_toolbox.inputs.results.FractalComponents.powspctrm);
                obj.best_toolbox.inputs.results.percentageOscillationOverFractalComponent.freq=obj.best_toolbox.inputs.results.FractalComponents.freq;
                %% DB Scaling 
                obj.best_toolbox.inputs.results.dbOscillationOverFractalComponent.powspctrm=real(log10(100*(obj.best_toolbox.inputs.results.percentageOscillationOverFractalComponent.powspctrm)));
                obj.best_toolbox.inputs.results.dbOscillationOverFractalComponent.freq=obj.best_toolbox.inputs.results.FractalComponents.freq;
                %% Plotting , Annotating and Saving Peak Frequency
                TargetFrequencyRange=(find(obj.best_toolbox.inputs.results.OriginalComponents.freq == obj.best_toolbox.inputs.TargetFrequencyRange(1)):find(obj.best_toolbox.inputs.results.OriginalComponents.freq == obj.best_toolbox.inputs.TargetFrequencyRange(2)));
                for channel=1:numel(obj.best_toolbox.inputs.results.OriginalComponents.label)
                    ax1=['ax' num2str(channel*4-3)];
                    axes(obj.best_toolbox.app.pr.ax.(ax1))
                    plot(obj.best_toolbox.inputs.results.FractalComponents.freq, obj.best_toolbox.inputs.results.FractalComponents.powspctrm(chanel,:),'linewidth', 3, 'color', [0 0 0],'DisplayName','Fractal'); hold on; legend;
                    plot(obj.best_toolbox.inputs.results.OriginalComponents.freq, obj.best_toolbox.inputs.results.OriginalComponents.powspctrm(chanel,:),'linewidth', 3, 'color', [0.6 0.6 0.6],'DisplayName','Original')
                    gridxy((obj.best_toolbox.inputs.TargetFrequencyRange(1)):0.25:(obj.best_toolbox.inputs.TargetFrequencyRange(2)),'Color',[219/255 246/255 255/255],'linewidth',4) ;
                    
                    ax2=['ax' num2str(channel*4-2)];
                    axes(obj.best_toolbox.app.pr.ax.(ax2))
                    plot(obj.best_toolbox.inputs.results.OscillationComponents.freq, obj.best_toolbox.inputs.results.OscillationComponents.powspctrm(chanel,:),'linewidth', 3, 'color', [0 0 0]); hold on;
                    gridxy((obj.best_toolbox.inputs.TargetFrequencyRange(1)):0.25:(obj.best_toolbox.inputs.TargetFrequencyRange(2)),'Color',[219/255 246/255 255/255],'linewidth',4) ;
                    %Find Peak Frequency, store it and annotate it 
                     [~,PeakPowerIndex] = find(obj.best_toolbox.inputs.results.OscillationComponents.powspctrm(channel,TargetFrequencyRange)==max(obj.best_toolbox.inputs.results.OscillationComponents.powspctrm(channel,TargetFrequencyRange)));
                    obj.best_toolbox.inputs.results.PeakFrequency.(obj.best_toolbox.inputs.results.OscillationComponents.label(channel))=obj.best_toolbox.inputs.results.OscillationComponents.freq(1,PeakPowerIndex);
                    obj.best_toolbox.app.pr.ax.(ax2).UserData.TextAnnotationPeakFrequency=text(obj.app.pr.ax.(ax),1,1,{['Peak Freq (Hz):' num2str(obj.best_toolbox.inputs.results.PeakFrequency.(obj.best_toolbox.inputs.results.OscillationComponents.label(channel)))]},'units','normalized','HorizontalAlignment','right','VerticalAlignment','cap','color',[0.45 0.45 0.45]);
               
                    
                    ax3=['ax' num2str(channel*4-1)];
                    axes(obj.best_toolbox.app.pr.ax.(ax3))
                    plot(obj.best_toolbox.inputs.results.percentageOscillationOverFractalComponent.freq, obj.best_toolbox.inputs.results.percentageOscillationOverFractalComponent.powspctrm(chanel,:),'linewidth', 3, 'color', [0 0 0]); hold on;
                    gridxy((obj.best_toolbox.inputs.TargetFrequencyRange(1)):0.25:(obj.best_toolbox.inputs.TargetFrequencyRange(2)),'Color',[219/255 246/255 255/255],'linewidth',4) ;

                    ax4=['ax' num2str(channel*4)];
                    axes(obj.best_toolbox.app.pr.ax.(ax4))
                    plot(obj.best_toolbox.inputs.results.dbOscillationOverFractalComponent.freq, obj.best_toolbox.inputs.results.dbOscillationOverFractalComponent.powspctrm(chanel,:),'linewidth', 3, 'color', [0 0 0]); hold on;
                    gridxy((obj.best_toolbox.inputs.TargetFrequencyRange(1)):0.25:(obj.best_toolbox.inputs.TargetFrequencyRange(2)),'Color',[219/255 246/255 255/255],'linewidth',4) ;
                end
        end
            
        function fft(obj,EEGData,InputDevice)
                %% Rename obj.inputs to obj.best_toolbox.inputs
                EEGChannelsIndex=find(strcmp(obj.best_toolbox.app.par.hardware_settings.(InputDevice).NeurOneProtocolChannelSignalTypes,'EEG'));
                EEGChanelsLabels=obj.best_toolbox.app.par.hardware_settings.(InputDevice).NeurOneProtocolChannelLabels(EEGChannelsIndex);                
                %% Creating RawEEGData
                obj.best_toolbox.inputs.results.RawEEGData.label=EEGChanelsLabels';
                obj.best_toolbox.inputs.results.RawEEGData.fsample=5000;
                obj.best_toolbox.inputs.results.RawEEGData.trial={EEGData.Data};
                obj.best_toolbox.inputs.results.RawEEGData.time={EEGData.Time};
                %% Referencing RawEEGData
                if ~isempty(obj.best_toolbox.inputs.TargetChannels)
                    if ~isempty(obj.best_toolbox.inputs.ReferenceChannels)
                        cfg=[];
                        cfg.reref         = 'yes';
                        cfg.refchannel    = obj.best_toolbox.inputs.ReferenceChannels;
                        if ~isempty(obj.best_toolbox.inputs.RecordingReference)
                            cfg.implicitref   =obj.best_toolbox.inputs.RecordingReference;
                        end
                        obj.best_toolbox.inputs.results.ReReferencedData = ft_preprocessing(cfg, obj.best_toolbox.inputs.results.RawEEGData);
                    end
                end
                %% Montage Creation
                if ~isempty(obj.best_toolbox.inputs.MontageChannels)
                    montage=[];
                    montage.tra = obj.best_toolbox.inputs.MontageWeights;
                    montage.labelold = obj.best_toolbox.inputs.MontageChannels;
                    montage.labelnew = {'Montage1'};
                    obj.best_toolbox.inputs.results.MontageData = ft_apply_montage(obj.best_toolbox.inputs.results.RawEEGData,montage);
                end
                %% Selected Data
                if ~isempty(obj.best_toolbox.inputs.TargetChannels)
                    cfg=[];
                    cfg.channel = obj.best_toolbox.inputs.TargetChannels;
                    if ~isempty(obj.best_toolbox.inputs.ReferenceChannels)
                        SelectedEEGData=ft_selectdata(cfg,obj.best_toolbox.inputs.results.ReReferenced);
                    else
                        SelectedEEGData=ft_selectdata(cfg,obj.best_toolbox.inputs.results.RawEEGData) ;
                    end
                end
                
                if ~isempty(obj.best_toolbox.inputs.TargetChannels) && ~isempty(obj.best_toolbox.inputs.MontageChannels)
                    cfg=[];
                    cfg.keepsampleinfo ='no';                    
                    obj.best_toolbox.inputs.results.SelectedData=ft_appenddata(cfg , SelectedEEGData , obj.best_toolbox.inputs.results.MontageData); %% Check if this works properly
                elseif ~isempty(obj.best_toolbox.inputs.TargetChannels) && isempty(obj.best_toolbox.inputs.MontageChannels)
                    obj.best_toolbox.inputs.results.SelectedChannels=SelectedEEGData;
                elseif isempty(obj.best_toolbox.inputs.TargetChannels)>0 && ~isempty(obj.best_toolbox.inputs.MontageChannels)
                    obj.best_toolbox.inputs.results.SelectedData=obj.best_toolbox.inputs.results.MontageData;
                end
                %% Filtered Data
                cfg=[];
                if ~isempty(obj.best_toolbox.inputs.HighPassFrequency)
                    cfg.hpfilter      = 'yes'; % high-pass in order to get rid of low-freq trends
                    cfg.hpfiltord     = obj.best_toolbox.inputs.HighPassFilterOrder;
                    cfg.hpfreq        = obj.best_toolbox.inputs.HighPassFrequency;
                end
                if ~isempty(obj.best_toolbox.inputs.BandStopFrequency)
                    cfg.bsfilter      = 'yes'; % band-stop filter, to take out 50 Hz and its harmonics
                    cfg.bsfiltord     = obj.best_toolbox.inputs.BandPassFilterOrder;
                    cfg.bsfreq        = obj.best_toolbox.inputs.BandPassFrequency;
                end
                if ~isempty(cfg)
                    obj.best_toolbox.inputs.results.FilteredData = ft_preprocessing(cfg, obj.best_toolbox.inputs.results.SelectedData); %% 
                end
                %% Segmented Data
                cfg               = [];
                cfg.length        = obj.best_toolbox.inputs.EEGEpochPeriod;
                cfg.overlap       = 0;
                if isfield(obj.best_toolbox.inputs.results,'FilteredData')
                    obj.best_toolbox.inputs.results.SegmentedData = ft_redefinetrial(cfg, obj.best_toolbox.inputs.results.FilteredData);
                else
                    obj.best_toolbox.inputs.results.SegmentedData = ft_redefinetrial(cfg, obj.best_toolbox.inputs.results.SelectedData);
                end
                %% Orignial, Fractal and Oscillation Components Spectral Analysis
                cfg               = [];
                cfg.foilim        = [1:1/obj.best_toolbox.inputs.EEGEpochPeriod:45];
                cfg.taper         = 'hanning';
                cfg.pad           = 'nextpow2';
                cfg.method        = 'mtmfft';
                obj.best_toolbox.inputs.results.OriginalComponents = ft_freqanalysis(cfg, obj.best_toolbox.inputs.results.SegmentedData); %Raw
                %% Plotting, Annotating and Saving Peak Frequency
                TargetFrequencyRange=(find(obj.best_toolbox.inputs.results.OriginalComponents.freq == obj.best_toolbox.inputs.TargetFrequencyRange(1)):find(obj.best_toolbox.inputs.results.OriginalComponents.freq == obj.best_toolbox.inputs.TargetFrequencyRange(2)));
                for channel=1:numel(obj.best_toolbox.inputs.results.OriginalComponents.label)
                    ax1=['ax' num2str(channel)];
                    axes(obj.best_toolbox.app.pr.ax.(ax1))
                    plot(obj.best_toolbox.inputs.results.OriginalComponents.freq, obj.best_toolbox.inputs.results.OriginalComponents.powspctrm(chanel,:),'linewidth', 3, 'color', [0 0 0]); hold on;
                    gridxy((obj.best_toolbox.inputs.TargetFrequencyRange(1)):0.25:(obj.best_toolbox.inputs.TargetFrequencyRange(2)),'Color',[219/255 246/255 255/255],'linewidth',4) ;
                    [~,PeakPowerIndex] = find(obj.best_toolbox.inputs.results.OriginalComponents.powspctrm(channel,TargetFrequencyRange)==max(obj.best_toolbox.inputs.results.OriginalComponents.powspctrm(channel,TargetFrequencyRange)));%.*[8:0.5:14]);
                    obj.best_toolbox.inputs.results.PeakFrequency.(obj.best_toolbox.inputs.results.OriginalComponents.label(channel))=obj.best_toolbox.inputs.results.OriginalComponents.freq(1,PeakPowerIndex);
                    obj.best_toolbox.app.pr.ax.(ax1).UserData.TextAnnotationPeakFrequency=text(obj.app.pr.ax.(ax),1,1,{['Peak Freq (Hz):' num2str(obj.best_toolbox.inputs.results.PeakFrequency.(obj.best_toolbox.inputs.results.OriginalComponents.label(channel)))]},'units','normalized','HorizontalAlignment','right','VerticalAlignment','cap','color',[0.45 0.45 0.45]);
                end
            end

    end
end

