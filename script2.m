   %% Configuring Real-Time Scopes for Amplitude Tracking
            AMP_TRACING_SCOPES_IDS = [93 94];
            
            % remove any pre-existing scopes with these ids
            for id = AMP_TRACING_SCOPES_IDS
                if(find(obj.bb.tg.Scopes == id))
                    fprintf('\nRemoving scope %i', id)
                    remscope(obj.bb.tg, id);
                end
            end
            
            sig_id_amp = getsignalid(obj.bb.tg, 'OSC/alpha/IA'); %amplitude
            sig_id_qly = getsignalid(obj.bb.tg, 'QLY/Logical Operator2'); %eeg_is_clean
            
            sc = addscope(obj.bb.tg, 'host', AMP_TRACING_SCOPES_IDS);
            addsignal(sc, [sig_id_amp sig_id_qly]);
            
            sc(1).NumSamples = 500;
            sc(1).Decimation = 10;
            sc(1).TriggerSample = -1;
            
            sc(2).NumSamples = 500;
            sc(2).Decimation = 10;
            sc(2).TriggerSample = -1;
            
            sc(1).TriggerMode = 'Scope';
            sc(1).TriggerScope = AMP_TRACING_SCOPES_IDS(2);
            
            sc(2).TriggerMode = 'Scope';
            sc(2).TriggerScope = AMP_TRACING_SCOPES_IDS(1);
            
            start(sc); % now they are ready for being triggered
            
            activeScope = 1;
            mAmplitudeScopeCircBufTotalBlocks = amplitude_assignment_period;
            mAmplitudeScopeCircBufCurrentBlock = 1;
            mAmplitudeScopeCircBuf = [];
            hAmplitudeHistoryAxes = subplot(1,2,1);
            hAmplitudeDistributionAxes = subplot(1,2,2);
            
            trigger(sc(activeScope));