classdef bossdevice_oscillation
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        tg
        name
    end
    
    properties (Dependent)
        phase_target
        phase_plusminus
        amplitude_min
        amplitude_max
        lpf_fir_coeffs % Nyquist filter before decimating the signal from 5 kHz to the sample rate of the oscillation
        bpf_fir_coeffs % band pass filter coefficients
        offset_samples
        % Underprogress
        sample_rate
        epoch_length
        edge_length
        hilbert_window_length
        ar_model_order
    end
   
    methods
        function obj = bossdevice_oscillation(tg, name)
            %UNTITLED Construct an instance of this class
            %   Detailed explanation goes here
            obj.tg = tg;
            obj.name = name;
            obj.phase_target = getparam(obj.tg, ['EVD/' obj.name], 'phase_target');
            obj.phase_plusminus = getparam(obj.tg, ['EVD/' obj.name], 'phase_plusminus');
            obj.amplitude_min = getparam(obj.tg, ['EVD/' obj.name], 'amplitude_min');
            obj.amplitude_max = getparam(obj.tg, ['EVD/' obj.name], 'amplitude_max');           
        end
              
        
        function phase_target = get.phase_target(obj)
            phase_target = getparam(obj.tg, ['EVD/' obj.name], 'phase_target');
        end
        
        function obj = set.phase_target(obj, phase_target)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            setparam(obj.tg, ['EVD/' obj.name], 'phase_target', phase_target);
        end

        
        function phase_plusminus = get.phase_plusminus(obj)
            phase_plusminus = getparam(obj.tg, ['EVD/' obj.name], 'phase_plusminus');
        end
        
        function obj = set.phase_plusminus(obj, phase_plusminus)
            %set.phase_plusminus Set phase tolerance
            %   A tolerance of pi ignores the phase in generation of events
            setparam(obj.tg, ['EVD/' obj.name], 'phase_plusminus', phase_plusminus);
        end

        
        function amplitude_min = get.amplitude_min(obj)
            amplitude_min = getparam(obj.tg, ['EVD/' obj.name], 'amplitude_min');
        end
        
        function obj = set.amplitude_min(obj, amplitude_min)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            setparam(obj.tg, ['EVD/' obj.name], 'amplitude_min', amplitude_min);
        end        


        function amplitude_max = get.amplitude_max(obj)
            amplitude_max = getparam(obj.tg, ['EVD/' obj.name], 'amplitude_max');
        end
        
        function obj = set.amplitude_max(obj, amplitude_max)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            setparam(obj.tg, ['EVD/' obj.name], 'amplitude_max', amplitude_max);
        end

        
        function lpf_fir_coeffs = get.lpf_fir_coeffs(obj)
            lpf_fir_coeffs = getparam(obj.tg, ['OSC/' obj.name], 'lpf_fir_coeffs');
        end
        
        function obj = set.lpf_fir_coeffs(obj, coeffs)
            setparam(obj.tg, ['OSC/' obj.name], 'lpf_fir_coeffs', coeffs)
        end
        
        
        function bpf_fir_coeffs = get.bpf_fir_coeffs(obj)
            bpf_fir_coeffs = getparam(obj.tg, ['OSC/' obj.name], 'bpf_fir_coeffs');
        end
        
        function obj = set.bpf_fir_coeffs(obj, coeffs)
            assert(numel(coeffs) <= numel(obj.bpf_fir_coeffs), 'number of coefficients exceeds maximum')
            if numel(coeffs) < numel(obj.bpf_fir_coeffs)
                coeffs(numel(obj.bpf_fir_coeffs)) = 0; % fill with zeros
            end
            setparam(obj.tg, ['OSC/' obj.name], 'bpf_fir_coeffs', coeffs)
        end        
        
        function offset_samples = get.offset_samples(obj)
            offset_samples = getparam(obj.tg, ['OSC/' obj.name], 'offset_samples');
        end
        
        function obj = set.offset_samples(obj, weights)
            setparam(obj.tg, ['OSC/' obj.name], 'offset_samples', weights)
        end

        
        function obj = ignore(obj, varargin)
            if nargin > 1
                % ignore a specific channel
                i = varargin{1};
                obj.phase_plusminus(i) = pi;
                obj.amplitude_min(i) = 0;
                obj.amplitude_max(i) = 1e6;
            else
                % ignore all channels
                obj.phase_plusminus = pi * ones(size(obj.phase_plusminus));
                obj.amplitude_min = zeros(size(obj.amplitude_min));
                obj.amplitude_max = 1e6 * ones(size(obj.amplitude_max));
            end
        end
        %% sample_rate
        function obj = set.sample_rate(obj,Fs)
            %assert bounds
            setparam(obj.tg, ['OSC/' obj.name], 'output_sample_time', Fs)
        end
        
        function sample_rate = get.sample_rate(obj)
            sample_rate = getparam(obj.tg, ['OSC/' obj.name], 'output_sample_time');
        end
        %% epoch_length
        function obj = set.epoch_length(obj,epoch_length)
            %assert bounds
            setparam(obj.tg, ['OSC/' obj.name], 'window_length', epoch_length)
        end
        
        function epoch_length = get.epoch_length(obj)
            epoch_length = getparam(obj.tg, ['OSC/' obj.name], 'window_length');
        end
        %% edge_length
        function obj = set.edge_length(obj,edge_length)
            %assert bounds
            setparam(obj.tg, ['OSC/' obj.name], 'edge_samples', edge_length)
        end
        
        function edge_length = get.edge_length(obj)
            edge_length = getparam(obj.tg, ['OSC/' obj.name], 'edge_samples');
        end
        %% hilbert_window_length
        function obj = set.hilbert_window_length(obj,hilbert_window_length)
            %assert bounds
            setparam(obj.tg, ['OSC/' obj.name], 'hilbert_window_samples', hilbert_window_length)
        end
        
        function hilbert_window_length = get.hilbert_window_length(obj)
            hilbert_window_length = getparam(obj.tg, ['OSC/' obj.name], 'hilbert_window_samples');
        end
        %% ar_model_order
        function obj = set.ar_model_order(obj,ar_model_order)
            %assert bounds
            setparam(obj.tg, ['OSC/' obj.name], 'ar_model_order', ar_model_order)
        end
        
        function ar_model_order = get.ar_model_order(obj)
            ar_model_order = getparam(obj.tg, ['OSC/' obj.name], 'ar_model_order');
        end

        
    end
end

