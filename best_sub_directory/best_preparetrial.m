function obj=best_preparetrial (obj)
            
            
            SI_raw= obj.trial.SI_min:obj.trial.SI_step:obj.trial.SI_max;
            obj.trial.total_trials=(obj.trial.SI_max-obj.trial.SI_min) / obj.trial.SI_step * obj.trial.trials_per_SI + obj.trial.trials_per_SI;
            
            obj.trial.avg_iti = (obj.trial.ITI_min+obj.trial.ITI_max)/2;
            jitter = obj.trial.avg_iti - obj.trial.ITI_min;
            obj.SI = [];
            obj.trial.intensities_indices = [];
            for i = 1:obj.trial.trials_per_SI
                indices = 1:length(SI_raw);
                obj.trial.intensities_indices = [obj.trial.intensities_indices indices(randperm(length(indices)))];
            end
            trial_no = 0;
            for intensities_index = obj.trial.intensities_indices
                trial_no = trial_no + 1;
                SI_raw(intensities_index)
                obj.SI = [obj.SI, SI_raw(intensities_index)];
                
            end
            obj.SI=obj.SI'
            obj.trial.timing_sequence = (1:obj.trial.total_trials)*obj.trial.avg_iti;
            obj.trial.timing_sequence = obj.trial.timing_sequence + rand(size(obj.trial.timing_sequence))*jitter;
        end
