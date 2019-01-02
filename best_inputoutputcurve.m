classdef best_inputoutputcurve < handle
    
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
        
    end
    
    methods
        
        function obj=best_inputoutputcurve (SI, MEP, SEM)
            
                obj.SI=SI;
                obj.MEP=MEP;
                obj.SEM=SEM;
                obj = best_ioc_fitting(obj);
                obj = best_ioc_plot(obj);
           
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
            
           
            %% Inflection point (ip) detection on fitted curve
            index_ip=find(abs(obj.curve(1).XData-obj.fitresult.SI50)<10^-1, 1, 'first');
            obj.ip_x=obj.curve(1).XData(index_ip);
            ip_y=obj.curve(1).YData(index_ip);
            
            
            %% Plateau (pt) detection on fitted curve
            index_pt=find(abs(obj.curve(1).YData-obj.fitresult.MEPmax)<10^-1, 1, 'first');
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
            xlabel('Intensity (% MSO)','FontSize',14,'FontName','Calibri');
            
            % Create ylabel
            ylabel('MEP Amplitude (mV)','FontSize',14,'FontName','Calibri');
            % x & y ticks and labels
            yticks(-1:0.5:24);  % will have to be referneced with GUI
            xticks(0:5:200);    % will have to be referneced with GUI
            
            % Create title
            title({'Input Output Curve'},'FontWeight','bold','FontSize',14,'FontName','Calibri');
            set(gcf, 'color', 'w')
            
            % Plotting Inflection point's horizontal & vertical dotted lines
            plot([obj.ip_x,30],[ip_y,ip_y],'--','Color' , [0.75 0.75 0.75]); % will have to be referneced with GUI
            plot([obj.ip_x,obj.ip_x],[ip_y,0],'--','Color' , [0.75 0.75 0.75]);
            legend_ip=plot(obj.ip_x,ip_y,'rs','MarkerSize',15);
            
            % Plotting Plateau's horizontal & vertical dotted lines
            plot([obj.pt_x,30],[pt_y,pt_y],'--','Color' , [0.75 0.75 0.75]); % will have to be referneced with GUI
            plot([obj.pt_x,obj.pt_x],[pt_y,0],'--','Color' , [0.75 0.75 0.75]);
            legend_pt=plot(obj.pt_x,pt_y,'rd','MarkerSize',15);
            
            % Plotting Threshold's horizontal & vertical dotted lines
            plot([obj.th,30],[0.05,0.05],'--','Color' , [0.75 0.75 0.75]); % will have to be referneced with GUI
            plot([obj.th,obj.th],[0.05,0],'--','Color' , [0.75 0.75 0.75]);
            legend_th=plot(obj.th, 0.05,'r*','MarkerSize',15);
            
            
            %% Creating legends
            h_legend=[h(1); h(2); legend_ip;legend_pt;legend_th];
            l=legend(h_legend, 'Amp(MEP) vs Stim. Inten', 'Sigmoid Fit', 'Inflection Point','Plateau','Threshold');
            set(l,'Orientation','horizontal','Location', 'southoutside','FontSize',12); 
            
            
            %% Creating Properties annotation box
            str_ip=['Inflection Point: ',num2str(obj.ip_x),' %MSO'];
            str_pt=['Plateau: ',num2str(obj.pt_x),' %MSO'];
            str_th=['Thershold: ',num2str(obj.th),' %MSO'];
            dim = [0.69 0.35 0 0];
            str = {str_ip,[],str_th,[],str_pt};
            annotation('textbox',dim,'String',str,'FitBoxToText','on','FontSize',12);
            
            box on; drawnow;
            set(gcf,'Visible', 'on');
            
            
        end
    end
end
