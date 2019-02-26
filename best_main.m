%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% BEST Main class
% All the low-level functions of BEST Toolbox goes here
%
% by Ing. Umair Hassan (umair.hassan@drz-mainz.de)
% last edited 2019/02/26 by UH
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


classdef best_main < handle
    
    properties
        
        curve;      % fitted curve (x,y) points goes here
        fitresult;  % results of fitted equation parameters goes here
        gof;        % results of fit goodnes rsquare, rmse etc goes here
        SI;         % stimulation intensities object values
        MEP;        % mep's object values
        SEM;        % standard error of mean (sem) object values
        ip_x;       % Inflection Point
        pt_x;       % Plateau
        th;         % Threshold
        MEP_clean;  % Outliers removed raw MEP values
        SI_clean;   % Corrosponding outliers removed raw SI values for MEPs
        MEP_Descriptives;
        trial;
        
    end
    
    methods
        
        function obj=best_main ()
            
            
        end
        
        
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
        
        %% STIM LOOP FUNCTION
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
        
        function obj=best_mep_p2pamp (obj)
            idx= size(obj.SI);
            
            i=1;
            while i <= idx(1)
                
                obj.SI(i);
                if obj.SI(i) <=49
                    xmin=0.01;
                    xmax=1;
                    
                    obj.MEP(i)=xmin+rand(1)*(xmax-xmin);
                    
                    
                elseif obj.SI(i) >=86
                    xmin=2.8;
                    xmax=3.8;
                    
                    obj.MEP(i)=xmin+rand(1)*(xmax-xmin);
                    
                else
                    xmin=1.5;
                    xmax=3.2;
                    
                    obj.MEP(i)=xmin+rand(1)*(xmax-xmin);
                    
                    
                    %                     obj.MEP(i)=rand(1)*obj.SI(i)*0.4;
                end
                i=i+1;
            end
            obj.MEP=obj.MEP';
        end
        
        
        %% Outliers removal
        function obj=best_ioc_outliers(obj)
            % function best_ioc_outliers removes the outliers in the MEPs collected using
            % Levenberg-Marquardt (LM) algorithm and iterative reweighted least squares method
            
            %% Data management
            data=[obj.SI,obj.MEP];
            data_sort=sortrows(data);
            s1=data_sort(:,1); m1=data_sort(:,2);
            
            
            %% Outliers detection
            outliers = isoutlier(m1,'movmean',15); %TODO Make 15 relative to # of trials
            index_outliers=find(outliers==1);
            
            
            %% Outliers removal from data
            m1(index_outliers)=[];
            s1(index_outliers)=[];
            
            obj.SI_clean=s1;
            obj.MEP_clean=m1;
            
            
            
        end
        
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
        
        
        function obj=best_ioc_fitting(obj)
            % function best_ioc_fitting fit creates sigmoid fit parameters for the curve
            
            % Preventing plot while fitting the curve
            set(gcf,'Visible', 'off');
            %% Data transformations for fitting
            [SIData, MEPData] = prepareCurveData(obj.SI ,obj.MEP );
            
            
            %% Setting boltzman sigmoid equation as type of fit
            ft = fittype( 'MEPmax*SI^n/(SI^n+SI50^n)', 'independent', 'SI', 'dependent', 'MEP' );
            
            
            %% Optimization of fit paramters;
            opts = fitoptions( ft );
            opts.Display = 'Off';
            opts.Lower = [0 0 0 ];
            opts.StartPoint = [10 10 10];
            opts.Upper = [Inf Inf Inf];
            
            
            %% Fit sigmoid model to data
            [obj.fitresult,obj.gof] = fit( SIData, MEPData, ft, opts);
            
            
            %% Extract fitted curve points
            plot( obj.fitresult, SIData, MEPData);
            obj.curve= get(gca,'Children');
            
        end
        
        function obj = best_ioc_plot(obj)
            % function best_ioc_plot performs plotting of fitted parameters
            
            format short g
            
            %% Inflection point (ip) detection on fitted curve
            %             index_ip=find(abs(obj.curve(1).XData-obj.fitresult.SI50)<10^-1, 1, 'first');
            %              obj.ip_x=obj.curve(1).XData(index_ip);
            %             ip_y = obj.curve(1).YData(index_ip)
            
            [value_ip , index_ip] = min(abs(obj.curve(1).XData-obj.fitresult.SI50));
            obj.ip_x = obj.curve(1).XData(index_ip);
            ip_y = obj.curve(1).YData(index_ip);
            
            %% Threshold (th) detection on fitted curve
            index_ip1=index_ip+50;
            ip1_x=obj.curve(1).XData(index_ip1);
            ip1_y=obj.curve(1).YData(index_ip1);
            % Calculating slope (m) using two-points equation
            m1=(ip1_y-ip_y)/(ip1_x-obj.ip_x)
            m=m1+0.40
            % Calculating threshold (th) using point-slope equation
            
            
            
            %% Creating plot
            hold on;
            a=obj.fitresult.MEPmax;
            c=obj.fitresult.SI50;
            b=m;
            x=linspace (min(obj.SI),max(obj.SI),4000);
            sigmoid=a ./ (1+exp(-b*(x-c)));
            cla;
            
            
            
            h= plot (x,sigmoid);
            obj.curve= get(gca,'Children');
            h1=plot(obj.SI,obj.MEP);
            
            
            
            %             h = plot( obj.fitresult, obj.SI, obj.MEP);
            set(h(1),'Marker','.','LineStyle','-','Color','r');
            set(h1(1), 'MarkerFaceColor',[0 0 0],'MarkerEdgeColor',[0 0 0],'Marker','square','LineStyle','none');
            
            % Plotting SEM on Curve points
            errorbar(obj.SI, obj.MEP ,obj.SEM, 'or');
            set(h(1),'LineWidth',0.25);
            set(h1(1),'LineWidth',2);
            
            
            %% Inflection point (ip) detection on fitted curve
            %             index_ip=find(abs(obj.curve(1).XData-obj.fitresult.SI50)<10^-1, 1, 'first');
            %              obj.ip_x=obj.curve(1).XData(index_ip);
            %             ip_y = obj.curve(1).YData(index_ip)
            
            [value_ip , index_ip] = min(abs(obj.curve(1).XData-obj.fitresult.SI50));
            obj.ip_x = obj.curve(1).XData(index_ip);
            ip_y = obj.curve(1).YData(index_ip);
            
            %% Plateau (pt) detection on fitted curve
            %             index_pt=find(abs(obj.curve(1).YData-obj.fitresult.MEPmax)<10^1, 1, 'first');
            %             obj.pt_x=obj.curve(1).XData(index_pt);
            %             pt_y=obj.curve(1).YData(index_pt);
            %
            [value_pt , index_pt] = min(abs(obj.curve(1).YData-(0.993*(obj.fitresult.MEPmax) ) ) );   %99.3 % of MEP max %TODO: Test it with longer plateu
            obj.pt_x=obj.curve(1).XData(index_pt);
            pt_y=obj.curve(1).YData(index_pt);
            
            %% Threshold (th) detection on fitted curve
            index_ip1=index_ip+50;
            ip1_x=obj.curve(1).XData(index_ip1);
            ip1_y=obj.curve(1).YData(index_ip1);
            % Calculating slope (m) using two-points equation
            m1=(ip1_y-ip_y)/(ip1_x-obj.ip_x)
            m=m1
            % Calculating threshold (th) using point-slope equation
            obj.th=obj.ip_x-(ip_y/m);
            
            
            
            % Create xlabel
            xlabel('Intensity (% MSO)','FontSize',14,'FontName','Calibri');   %TODO: Put if loop of RMT or MSO
            
            % Create ylabel
            ylabel('MEP Amplitude (mV)','FontSize',14,'FontName','Calibri');
            
            % x & y ticks and labels
            yticks(-1:0.5:10000);  % will have to be referneced with GUI
            xticks(0:5:1000);    % will have to be referneced with GUI
            
            % Create title
            title({'Input Output Curve'},'FontWeight','bold','FontSize',14,'FontName','Calibri');
            set(gcf, 'color', 'w')
            
            SI_min_point = (round(min(obj.SI)/5)*5)-5; % Referncing the dotted lines wrt to lowest 5ths of SI_min
            
            % Plotting Inflection point's horizontal & vertical dotted lines
            plot([obj.ip_x,30],[ip_y,ip_y],'--','Color' , [0.75 0.75 0.75]);
            plot([obj.ip_x,obj.ip_x],[ip_y,0],'--','Color' , [0.75 0.75 0.75]);
            legend_ip=plot(obj.ip_x,ip_y,'rs','MarkerSize',15);
            
            % Plotting Plateau's horizontal & vertical dotted lines
            plot([obj.pt_x,30],[pt_y,pt_y],'--','Color' , [0.75 0.75 0.75]);
            plot([obj.pt_x,obj.pt_x],[pt_y,0],'--','Color' , [0.75 0.75 0.75]);
            legend_pt=plot(obj.pt_x,pt_y,'rd','MarkerSize',15);
            
            % Plotting Threshold's horizontal & vertical dotted lines
            plot([obj.th,30],[0.05,0.05],'--','Color' , [0.75 0.75 0.75]);
            plot([obj.th,obj.th],[0.05,0],'--','Color' , [0.75 0.75 0.75]);
            legend_th=plot(obj.th, 0.05,'r*','MarkerSize',15);
            
            
            %% Creating legends
            h_legend=[h1(1);h(1); legend_ip;legend_pt;legend_th];
            l=legend(h_legend, 'Amp(MEP) vs Stim. Inten', 'Sigmoid Fit', 'Inflection Point','Plateau','Threshold');
            set(l,'Orientation','horizontal','Location', 'southoutside','FontSize',12);
            
            
            %% Creating Properties annotation box
            
            str_ip=['Inflection Point: ',num2str(obj.ip_x),' (%MSO)',' , ',num2str(ip_y),' (mV)'];
            str_pt=['Plateau: ',num2str(obj.pt_x),' (%MSO)',' , ',num2str(pt_y),' (mV)'];
            str_th=['Thershold: ',num2str(obj.th),' (%MSO)',' , ', '0.05',' (mV)'];
            
            dim = [0.69 0.35 0 0];
            str = {str_ip,[],str_th,[],str_pt};
            annotation('textbox',dim,'String',str,'FitBoxToText','on','FontSize',12);
            
            box on; drawnow;
            set(gcf,'Visible', 'on');
            
            
            
            
        end
    end
end
