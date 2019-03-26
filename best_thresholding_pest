        function obj=best_thresholding_pest (obj)
            
            % Custom cdf where 'm' is mean and '0.07*m' is predifined variance
            cdfFormula = @(m) normcdf(0:0.5:100,m,0.07*m);
            
            % this is the cdf I am trying to emulate
            realCdf = zeros(2,201);
            spot = 1;
            for i = 0:0.5:100
                realCdf(1,spot) = i;
                spot = spot + 1;
            end
            realCdf(2,:) = normcdf(0:0.5:100,40,0.07*40);
            
            %% Log likelihood function
            L = zeros(2,201);
            spot = 1;
            for i = 0:0.5:100
                L(1,spot) = i;
                spot = spot + 1;
            end
            %% Start with hit at 100% intensity and miss at 0% intensity
            spot = 1;
            for i = 0:0.5:100 % go through all possible intensities
                thisCdf = cdfFormula(i);
                % calculate log likelihood function
                L(2,spot) = log(thisCdf(101)) + log(1-thisCdf(61));
                spot = spot + 1;
            end
            
            %%
            
            %find max values, returns intensity (no indice problem)
            maxValues = L(1,find(L(2,:) == max(L(2,:))));
            
            % Middle Value from maxValues
            nextInt = (min(maxValues) + max(maxValues))/2;

            %% MEP Measurment
            
            No_of_iterations=10;
            
            for N=1:No_of_iterations
                
                % MAGIC command for setting Intensity
                rtcls.sendPulse(1); %RTCLS command for stimulating at that command
                rtcls.MEP(1);       %RTCLS command for measuring raw data
                obj=best_main_P2P(obj); %BEST command for calcualting P2P amps
                
                % Custom cdf where 'm' is mean and '0.07*m' is predifined variance
                cdfFormula = @(m) normcdf(0:0.5:100,m,0.07*m);
                
                
                if MEP > 50
                    disp('Hit')
                    evokedMEP = 1;
                else
                    disp('Miss')
                    evokedMEP = 0;
                    
                end
                
                %find max values
                maxValues = L(1,find(L(2,:) == max(L(2,:))));
                % Middle Value from maxValues
                nextInt = round((min(maxValues) + max(maxValues)) / 2);
                %nextInt = maxValues(round(length(maxValues)/2));
                
                % calculate updated log likelihood function
                spot = 1;
                for i = 0:0.5:100 % go through all possible intensities
                    thisCdf = cdfFormula(i);
                    if evokedMEP == 1 % hit!
                        L(2,spot) = L(2,spot) + factor*log(thisCdf(2*nextInt+1));
                    elseif evokedMEP == 0 % miss!
                        L(2,spot) = L(2,spot) + factor*log(1-thisCdf(2*nextInt+1));
                    end
                    spot = spot + 1;
                end
                
                display(sprintf('using next intensity: %.2f', nextInt))
                
            end
            
            % Plotting visualiztion of nextInt variable
            

        
        end
      
