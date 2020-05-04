classdef best_fieldtrip <handle
    properties
        best_toolbox
        fieldtrip
    end
    
    methods
        function obj = best_fieldtrip(best_toolbox)
            obj.best_toolbox=best_toolbox;
        end
        
        function best2ftdata(obj)
            disp $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
        end
        
        function ftirasa(obj)
            t = (1:1000)/1000; % time axis
            for rpt = 1:100
                % generate pink noise
                dspobj = dsp.ColoredNoise('Color', 'pink', ...
                    'SamplesPerFrame', length(t));
                fn = dspobj()';
                
                % add a 10 Hz oscillation
                data.trial{1,rpt} = fn + cos(2*pi*10*t);
                data.time{1,rpt}  = t;
                data.label{1}     = 'chan';
                data.trialinfo(rpt,1) = rpt;
            end
            
            % partition the data into ten overlapping sub-segments
            w = data.time{1}(end)-data.time{1}(1); % window length
            cfg               = [];
            cfg.length        = w*.9;
            cfg.overlap       = 1-(((w-cfg.length)/cfg.length)/(10-1));
            data_r = ft_redefinetrial(cfg, data);
            
            % perform IRASA and regular spectral analysis
            cfg               = [];
            cfg.foilim        = [1 50];
            cfg.taper         = 'hanning';
            cfg.pad           = 'nextpow2';
            cfg.keeptrials    = 'yes';
            cfg.method        = 'irasa';
            frac_r = ft_freqanalysis(cfg, data_r);
            cfg.method        = 'mtmfft';
            orig_r = ft_freqanalysis(cfg, data_r);
            
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
            frac_a = ft_appendfreq([], frac_s{:});
            orig_a = ft_appendfreq([], orig_s{:});
            
            % average across trials
            cfg               = [];
            cfg.trials        = 'all';
            cfg.avgoverrpt    = 'yes';
            frac = ft_selectdata(cfg, frac_a);
            orig = ft_selectdata(cfg, orig_a);
            
            % subtract the fractal component from the power spectrum
            cfg               = [];
            cfg.parameter     = 'powspctrm';
            cfg.operation     = 'x2-x1';
            osci = ft_math(cfg, frac, orig);
            
            % plot the fractal component and the power spectrum
            axes(obj.best_toolbox.app.pr.ax.ax1)
            plot(frac.freq, frac.powspctrm, ...
                'linewidth', 3, 'color', [0.6 0.6 0.6])
            hold on; plot(orig.freq, orig.powspctrm, ...
                'linewidth', 3, 'color', [0 0 0])
            
            % plot the full-width half-maximum of the oscillatory component
            f    = fit(osci.freq', osci.powspctrm', 'gauss1');
            avg  = f.b1;
            sd   = f.c1/sqrt(2)*2.3548;
            fwhm = [avg-sd/2 avg+sd/2];
            yl   = get(gca, 'YLim');
            p = patch([fwhm flip(fwhm)], [yl(1) yl(1) yl(2) yl(2)], [.9 .9 .9]);
            uistack(p, 'bottom');
            legend('FWHM oscillation', 'Fractal component', 'Power spectrum');
            xlabel('Frequency'); ylabel('Power');
            set(gca, 'YLim', yl);
        end
        
        function ftfft (obj)
            %% 2 EEG mu-alpha peak frequency determination
            % do 2 min resting state EEg recording
            % export to BVA format as eg.g. P03_rsEEG.dat
            
            % read BVA data to fieldtrip
            % re-reference to Hjorth montage
            % demean and detrend
            cfg = [];
            %info.subjectCode = 'P01';
            filepath = fullfile('X:\2018-10 MUSEP\NeurOne Data\' ,info.subjectCode, [info.subjectCode, '_rsEEG.eeg'])
            
            cfg.dataset = filepath;
            cfg.reref       = 'yes';
            cfg.demean   = 'yes'
            cfg.implicitref = 'FCz';
            cfg.refchannel =    {'CP1','FC5','CP5','FC1' };
            data = ft_preprocessing(cfg)
            
            % segment to 2s epochs
            
            cfg = [];
            cfg.length               = 2;
            data                = ft_redefinetrial(cfg, data);
            
            
            % FFT with 0.5 Hz resolution
            
            cfg = [];
            cfg.method = 'mtmfft';
            cfg.output = 'pow';
            cfg.taper = 'hanning';
            cfg.foi = 0.5:0.5:30
            %cfg.tapsmofrq = [2];
            % cfg.trials = [1:60]; %this is for 120 seconds
            cfg.keeptrials = 'no';
            
            [freq] = ft_freqanalysis(cfg, data);
            
            % 1/f² correction (i.e., multiply each power value by the frequency squared
            nominaltargetrange = (freq.freq(find(freq.freq == 8):find(freq.freq == 14)))%.^2);
            targetrangeindices = (find(freq.freq == 8):find(freq.freq == 14))
            % Determine peak frequency in between 8 and 14 Hz
            [targetMuPower,targetMuIndex] = max(freq.powspctrm(5,targetrangeindices).*[8:0.5:14]);
            info.mufreq = freq.freq((find(freq.freq == 7.5))+targetMuIndex)
            
            
            %targetrange = freq.powspctrm(5,17:100);
            %targetrange = targetrange.*(freq.freq(17:100)); %.^2
            
            %plot(freq.freq,freq.powspctrm(5,:))
            
            h_powspectrm = figure;
            subplot(1,2,2);
            title('1/f corrected FFT');
            %plot(freq.freq,freq.powspctrm(5,:).*freq.freq.^2)
            plot(freq.freq,freq.powspctrm(5,:).*freq.freq)
            %plot(freq.freq,freq.powspctrm(5,:))
            line([info.mufreq info.mufreq], ylim(gca), 'Color', [1 0 0]);
            display(['Mu-alpha peak frequency is ' num2str(info.mufreq) ' Hz.']);
            subplot(1,2,1);
            title('uncorrected FFT');
            plot(freq.freq,freq.powspctrm(5,:))
            line([info.mufreq info.mufreq], ylim(gca), 'Color', [1 0 0]);
            % info.mufreq = 11
            
        end
    end
end

