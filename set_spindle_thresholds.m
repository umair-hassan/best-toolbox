% b=bossdevice;
% setparam(b.tg, 'STFTSpindle4', 'rms_threshold', 3.42) % careful, change!
% setparam(b.tg, 'STFTSpindle4', 'crr_threshold', 0.3)
% setparam(b.tg, 'STFTSpindle4', 'sigma_threshold', 0.1)
% warning('please ensure best_toolbox 1x1 best_applicatiocan exist in workspace')B
best_toolbox.par.spindle_parameters = [2, 0.20, 0.1]; %{rms, crr, sigma] %8.50, 0.65, 0.2 %5, 0, 0       %17.55