function obj = best_hotspotsearch(SI,no_of_trials,ITI_min,ITI_max)
obj=best_main;

obj.trial.SI_min=SI;
obj.trial.SI_max=SI;
obj.trial.SI_step=0;
obj.trial.trials_per_SI=no_of_trials;
obj.trial.ITI_min=ITI_min;
obj.trial.ITI_max=ITI_max;

% these low level functions are turned-on by DEFAULT
%TODO: Add capability of their optionality for switching them off
obj.best_mep_liveplot.event=1;
obj.best_mep_measurement.event=1;
obj.best_mep_p2pamp.event=1;
obj.best_hotspot_plot.event=1;

best_preparetrial(obj);
best_stimloop(obj);

end
