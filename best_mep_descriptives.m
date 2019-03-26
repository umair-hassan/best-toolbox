function obj = best_mep_descriptives(obj)
            
            %% Data Trasnformation from Outliers array
            [si,ia,idx] = unique(obj.SI_clean,'stable');
            mep_median = accumarray(idx,obj.MEP_clean,[],@median);
            mep_mean = accumarray(idx,obj.MEP_clean,[],@mean);
            mep_std = accumarray(idx,obj.MEP_clean,[],@std);
            mep_min = accumarray(idx,obj.MEP_clean,[],@min);
            mep_max = accumarray(idx,obj.MEP_clean,[],@max);
            mep_var = accumarray(idx,obj.MEP_clean,[],@var);
            
            M=[si,mep_median,mep_mean,mep_std, mep_min, mep_max, mep_var];
            M1 = M(randperm(size(M,1)),:,:,:,:,:,:);
            obj.SI=M1(:,1);
            obj.MEP=M1(:,2);
            obj.MEP_Descriptives.mean=M1(:,3);
            obj.MEP_Descriptives.std=M1(:,4);
            obj.MEP_Descriptives.min=M1(:,5);
            obj.MEP_Descriptives.max=M1(:,6);
            obj.MEP_Descriptives.var=M1(:,7);
            
            
            obj.SEM=obj.MEP_Descriptives.std/sqrt(15);    %TODO: Make it modular by replacing 15 to # trials per intensity object value
            
        end
