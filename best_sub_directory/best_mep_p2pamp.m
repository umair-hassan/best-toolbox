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
        
