classdef best_sync2brain_bossdevice

    
    properties
        bb %bossbox API object
    end
    
    methods
        function obj = best_sync2brain_bossdevice
                obj.bb=dbsp('10.10.10.1');
        end
        
        function singlePulse(obj,portNo)
            portNo
                obj.bb.sendPulse(portNo)
        end
        
        function multiPulse(obj)
            disp not_programmed_yet
        end
    end
end

