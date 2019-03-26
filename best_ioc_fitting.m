 function obj=best_ioc_fitting(obj)
            % function best_ioc_fitting fit creates sigmoid fit parameters for the curve
             obj.p=figure('Name','IOC2');
             set (obj.p, 'Name','IOC1', 'WindowStyle', 'Docked');
             hold on;
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
