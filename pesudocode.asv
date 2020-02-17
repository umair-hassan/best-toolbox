function mep
trialprep
stimloop
for mep=1
%     trigger output
%     read inputthistrial
%     prepare nexttrial
%     plot thistrial
%     wait fornexttrial
    trigger_output
    prepare_trial
    read_trial
end

    function trigger_output
        %this function will just give external trigger out i.e. a single
        %pulse for boss box controlled devices, and for host controlled
        %devices i have to check if just a fire would do the job when the
        %mode is setup
        host_magven
        host_magstim
        host_bistim
        host_rapid
        boss_magven
        boss_bistim
        boss_rapid
        boss_rapid
        arduino_digitmer
        arduino_fMRI
    end

    function prepare_trial
        one stim
                    host_magven
                                    sp, pp, burst,train
                    host_magstim
                                    sp, pp, burst,train
                    host_bistim
                                    sp, pp, burst,train
                    host_rapid
                                    sp, pp, burst,train
                    boss_magven
                                   sp, pp, burst,train
                    boss_magstim
                                    sp, pp, burst,train
                    boss_bistim
                                    sp, pp, burst,train
                    boss_rapid
                                    sp, pp, burst,train
                    arduino_digitmer
                                    sp, pp, burst,train
                    arduino_fMRI
                                   sp, pp, burst,train
        
    end

    function read_trial
        ft
            channel1
            channel2
            channel3
            channel4
            channel5
            channel6
        boss_neurone
        button_box
    end
end

