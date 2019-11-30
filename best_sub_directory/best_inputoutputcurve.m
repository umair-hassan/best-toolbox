%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% BEST Input Output Curve function
% best_inputoutputcurve.m
% pause matlab while maintaining communication via serial COM port(s)
%
% by Ing. Umair Hassan (umair.hassan@drz-mainz.de)
% last edited 2019/02/15 by UH
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function obj = best_inputoutputcurve (SI,MEP)

obj=best_main;
obj.SI=SI;
obj.MEP=MEP;
obj = best_ioc_outliers(obj);  %TODO Add if loop here and develop its handle script
obj = best_mep_descriptives(obj);
obj = best_ioc_fitting(obj);
obj = best_ioc_plot(obj);


end
