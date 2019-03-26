function obj = best_stimloop (obj)
            
            %% MAGIC Intilization
            % % % % % %             magventureObject = magventure('COM3');
            % % % % % %             magventureObject.connect; %connecting
            % % % % % %             magventureObject.arm();
            
            trial_no = 0;
            for intensities_index = obj.trial.intensities_indices
                trial_no = trial_no + 1;
                fprintf('\nTrial: %i', trial_no)
                
                %% set intensity via MAGIC toolbox commands
                SI_value=obj.SI(intensities_index);
                % % % % % %                 magventureObject.setAmplitude(SI_value);
                % % % % % %                 pause(0.1) % give stimulator time to set intensity value
                
                %% trigger the pulse via DBSP commands
                % % % % % %                 % rtcls.sendPulse; % preferabbly sending pulse via this
                % % % % % %                 % port is easiest
                
                
                fprintf('\nTrial completed .')
                
                % TODL: check if rt.generator_running works with
                % rt.sendPulse too, if yes keep this feature as it is
                % % % % % % % % % % % % % % % while strcmp(rt.generator_running, 'yes')
                % % % % % % % % % % % % % % % fprintf('.')
                % % % % % % % % % % % % % % % pause(1)
                % % % % % % % % % % % % % % %
                % % % % % % % % % % % % % % % end
                
                %% Pseudorandomization in ITIs
                pause(obj.trial.ITI_min+rand*(obj.trial.ITI_max-obj.trial.ITI_min));  %Pseudorandomization of ITI
                
                
            end
            % % % % % % % %             magventureObject.disconnect();
            
            fprintf(' Stim Loop Completed\n')
        end
