%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% BEST Main class 
% All the low-level functions of BEST Toolbox goes here
%
% by Ing. Umair Hassan (umair.hassan@drz-mainz.de)
% last edited 2019/02/15 by UH
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
        
    end
    
    methods
        
        function obj=best_main ()
            
           
        end
        
        
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
            m=(ip1_y-ip_y)/(ip1_x-obj.ip_x);
            % Calculating threshold (th) using point-slope equation
            obj.th=obj.ip_x-(ip_y/m);
            
            
            %% Creating plot
            hold on;
            h = plot( obj.fitresult, obj.SI, obj.MEP);
            set(h(1), 'MarkerFaceColor',[0 0 0],'MarkerEdgeColor',[0 0 0],'Marker','square','LineStyle','none');
            
            % Plotting SEM on Curve points
            errorbar(obj.SI, obj.MEP ,obj.SEM, 'o');
            set(h(2),'LineWidth',2);
            
            % Create xlabel
            xlabel('Intensity (% MSO)','FontSize',14,'FontName','Calibri');   %TODO: Put if loop of RMT or MSO
            
            % Create ylabel
            ylabel('MEP Amplitude (mV)','FontSize',14,'FontName','Calibri');
            
            % x & y ticks and labels
            yticks(1:0.5:10000);  % will have to be referneced with GUI
            xticks(0:5:1000);    % will have to be referneced with GUI
            
            % Create title
            title({'Input Output Curve'},'FontWeight','bold','FontSize',14,'FontName','Calibri');
            set(gcf, 'color', 'w')
            
            SI_min_point = round(min(obj.SI)/5)*5-5; % Referncing the dotted lines wrt to lowest 5ths of SI_min
         
            % Plotting Inflection point's horizontal & vertical dotted lines
            plot([obj.ip_x,SI_min_point],[ip_y,ip_y],'--','Color' , [0.75 0.75 0.75]); 
            plot([obj.ip_x,obj.ip_x],[ip_y,0],'--','Color' , [0.75 0.75 0.75]);
            legend_ip=plot(obj.ip_x,ip_y,'rs','MarkerSize',15);
            
            % Plotting Plateau's horizontal & vertical dotted lines
            plot([obj.pt_x,SI_min_point],[pt_y,pt_y],'--','Color' , [0.75 0.75 0.75]); 
            plot([obj.pt_x,obj.pt_x],[pt_y,0],'--','Color' , [0.75 0.75 0.75]);
            legend_pt=plot(obj.pt_x,pt_y,'rd','MarkerSize',15);
            
            % Plotting Threshold's horizontal & vertical dotted lines
            plot([obj.th,SI_min_point],[0.05,0.05],'--','Color' , [0.75 0.75 0.75]); 
            plot([obj.th,obj.th],[0.05,0],'--','Color' , [0.75 0.75 0.75]);
            legend_th=plot(obj.th, 0.05,'r*','MarkerSize',15);
            
            
            %% Creating legends
            h_legend=[h(1); h(2); legend_ip;legend_pt;legend_th];
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
