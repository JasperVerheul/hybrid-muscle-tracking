%% ------------------------------------------------------------------------
 function saveTrackingResults(settings, fasROI, apo1, apo2, Hough, FPT, Hybrid);
% -------------------------------------------------------------------------
% This function saves the tracking results. The output mat file is saved in
% the 'TrackingResults' folder.
% 
% Input:            - settings: predefined settings structure.
%                   - fasROI: struct containing fascicle region of
%                     interest.
%                   - apo1: struct containing aponeurosis 1 position and 
%                     tracking results.
%                   - apo2: struct containing aponeurosis 2 position and 
%                     tracking results.
%                   - FPT: struct containing feature-point tracking
%                     results.
%                   - Hough: struct containing Hough transform results.
%                   - Hybrid: struct containing hybrid tracking results.
% 
% Output:           - mat file of the tracking results for the hybrid, 
%                     Hough transform, and feature-point tracking methods. 
%                     Saved in the 'TrackingResults' folder.
% -------------------------------------------------------------------------

clc

disp('Saving tracking results...');

cd(settings.resultFolder);
save([settings.fileName '_trackingResults.mat'], 'settings', 'fasROI', 'apo1', 'apo2', 'Hough', 'FPT', 'Hybrid');
cd ..\

disp('Results saved!');