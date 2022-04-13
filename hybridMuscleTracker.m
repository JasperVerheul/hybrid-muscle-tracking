%% ------------------------------------------------------------------------
% -------------------------------------------------------------------------
% This script contains example code for running hybrid muscle tracking. In
% sequential order the script: 
%   - Loads ultrasound video of interest.
%   - Loads pre-defined settings.
%   - Detects aponeurosis locations and fascicle region of interest. 
%   - Tracks aponeurosis and fascicle region of interest.
%   - Post-processes tracking results (comprises hybrid approach).
%   - Saves tracking results to mat file.
%   - Creates tracking results video.
%
% Several functions are used and can be found in the 'Functions' folder, or
% downloaded from the hybrid muscle tracking GitHub repository 
% "https://github.com/JasperVerheul/hybrid-muscle-tracking". For the 
% Hessian-based Frangi vesselness filtering, open-source functions
% developed by Dirk-Jan Kroon are used which can be found in the
% 'FrangiFilter' folder or downloaded from 
% "https://uk.mathworks.com/matlabcentral/fileexchange/24409-hessian-based-
% frangi-vesselness-filter".
%
% Input:            - Set 'fileName' for the ultrasound video of interest.
%
% Output:           - mat file containing:
%                       * settings: predefined settings structure.
%                       * fasROI: struct containing fascicle region of
%                         interest.
%                       * apo1: struct containing aponeurosis 1 location 
%                         and tracking results.
%                   	* apo2: struct containing aponeurosis 2 location 
%                         and tracking results.
%                       * FPT: struct containing feature-point tracking
%                         results.
%                       * Hough: struct containing Hough transform tracking
%                         results.
%                       * Hybrid: struct containing hybrid tracking 
%                         results.
% 	                - MP4 video of the tracked muscle and tracking results.
% 
% Author:           Jasper Verheul, PhD
%                   Cardiff Metropolitan University, United Kingdom
% 
% First release:    April 2022
%
% MATLAB version:   R2021a
% 
% License:          All code and example data are available under the 
%                   Apache-2.0 License.         
% -------------------------------------------------------------------------
% -------------------------------------------------------------------------
clear
clc

% Set file name
fileName = 'exampleVideoTA';

% Add main script location to Matlab path
addpath(genpath([fileparts(matlab.desktop.editor.getActiveFilename) '\']));

% Set folders
settings = setFolders([fileparts(matlab.desktop.editor.getActiveFilename) '\']);

% Load ultrasound video
Ultrasound = getUltrasoundVideo(settings, fileName);

% Get settings for muscle tracking
settings = getSettings(settings, Ultrasound, fileName); 

% Initialise tracking process
referenceImage = Ultrasound(:,:,1);
[fasROI apo1 apo2] = getInitialROIs(settings, referenceImage, 1);
apo1Tracker = initialiseTracker(settings, referenceImage, apo1);
apo2Tracker = initialiseTracker(settings, referenceImage, apo2);

% Track the muscle
[fasROI apo1 apo2 Hough] = trackMuscle(settings, Ultrasound, apo1, apo2, apo1Tracker, apo2Tracker);

% Post-process tracking results
[apo1 apo2 Hough FPT Hybrid] = postProcessTrackingResults(settings, apo1, apo2, Hough);

% Save results
saveTrackingResults(settings, fasROI, apo1, apo2, Hough, FPT, Hybrid);

% Plot results
plotTrackingResults(settings, Ultrasound, fasROI, apo1, apo2, Hough, FPT, Hybrid);
