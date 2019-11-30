function obj=best_ioc_outliers(obj)
            % function best_ioc_outliers removes the outliers in the MEPs collected using
            % Levenberg-Marquardt (LM) algorithm and iterative reweighted least squares method
            
            %% Data management
            data=[obj.SI,obj.MEP];
            data_sort=sortrows(data);
            s1=data_sort(:,1); m1=data_sort(:,2);
            outliers=NaN;
            
            
            %% Outliers detection
            outliers = isoutlier(m1,'movmean',15); %TODO Make 15 relative to # of trials
            index_outliers=find(outliers==1);
            
            
            %% Outliers removal from data
            m1(index_outliers)=[];
            s1(index_outliers)=[];
            
            obj.SI_clean=s1;
            obj.MEP_clean=m1;
            %make another change
            
            
            
        end
