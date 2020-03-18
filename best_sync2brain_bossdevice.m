classdef best_sync2brain_bossdevice

    
    properties
        bb %bossbox API object
    end
    
    methods
        function obj = best_sync2brain_bossdevice
                obj.bb=dbsp('10.10.10.1');
        end
        
        function singlePulse(obj,portNo)
                obj.bb.sendPulse(portNo)
        end
        
        function multiPulse(obj,time_port_marker_vector)
            obj.bb.configure_time_port_marker(cell2mat(time_port_marker_vector'));
            obj.bb.manualTrigger;
        end
    end
end

