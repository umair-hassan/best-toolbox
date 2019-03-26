%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% BEST Main class
% This class defines a main object for entire toolbox functions
%
% by Ing. Umair Hassan (umair.hassan@drz-mainz.de)
% last edited 2019/02/15 by UH
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


classdef best_main < handle
    
    properties
        
        curve;      % fitted curve (x,y) points goes here
        fitresult;  % results of fitted equation parameters goes here
        gof;        % results of fit goodnes rsquare, rmse etc goes here
        SI;         % stimulation intensities object values
        MEP;        % mep's object values
        SEM;        % standard error of mean (sem) object values
        ip_x;       % Inflection Point
        pt_x;       % Plateau
        th;         % Threshold
        MEP_clean;  % Outliers removed raw MEP values
        SI_clean;   % Corrosponding outliers removed raw SI values for MEPs
        MEP_Descriptives;
        trial;
        p;
        
    end
    
    methods
        
        function obj= best_main ()
            
            
        end
        
