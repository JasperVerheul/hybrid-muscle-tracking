%% ------------------------------------------------------------------------
 function apoTracker = initialiseTracker(settings, referenceImage, apo);
% -------------------------------------------------------------------------
% This function initialises the feature-point tracker object to track the
% affine transformation of the feature points within the aponeurosis region
% of interest.
% 
% Input:            - settings: predefined settings structure.
%                   - referenceImage: reference ultrasound image for 
%                     initialisation. 
% 	                - apo: struct containing the location, region of 
%                     interest, and feature points for aponeurosis.
% 
% Output:           - apoTracker: feature-point tracker object for
%                     aponeurosis tracking. 
% -------------------------------------------------------------------------

clc

apoTracker = vision.PointTracker('NumPyramidLevels',settings.NumPyramidLevels, ...
    'MaxBidirectionalError',settings.MaxBidirectionalError, ...
    'BlockSize',settings.BlockSize, 'MaxIterations',settings.MaxIterations);

initialize(apoTracker, apo.points, referenceImage);    