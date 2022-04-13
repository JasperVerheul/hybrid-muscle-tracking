%% ------------------------------------------------------------------------
 function [fasROI apo1 apo2 Hough] = trackMuscle(settings, Ultrasound, apo1, apo2, apo1Tracker, apo2Tracker);
% -------------------------------------------------------------------------
% This function tracks the muscle by running a Hough transform and feature-
% point tracking algorithm on each image in the ultrasound video.
% 
% The open-source Hessian-based Frangi vesselness filtering functions used 
% in this function were developed by Dirk-Jan Kroon. 
% (https://uk.mathworks.com/matlabcentral/fileexchange/24409-hessian-based-
% frangi-vesselness-filter).
% 
% Input:            - settings: predefined settings structure.
%                   - Ultrasound: ultrasound video under analysis.
%                   - fasROI: struct containing fascicle region of
%                     interest.
%                   - apo1: struct containing aponeurosis 1 location.
%                   - apo2: struct containing aponeurosis 2 location.
%                   - apo1Tracker: feature-point tracker object for 
%                     aponeurosis 1.
%                   - apo2Tracker: feature-point tracker object for 
%                     aponeurosis 2.
% 
% Output:           - fasROI: struct containing fascicle region of
%                     interest.
%                   - apo1: struct containing aponeurosis 1 position and 
%                     tracking results.
%                   - apo2: struct containing aponeurosis 2 position and 
%                     tracking results.
%                   - Hough: struct containing Hough transform results.
% -------------------------------------------------------------------------

tic

for im = 1:settings.vidLength;
    clc;
    disp(['Tracking muscle. Current image: ' num2str(im) '/' num2str(size(Ultrasound,3))]);

% Get current image
    currentImage = Ultrasound(:,:,im);
 
% -------------------------------------------------------------------------
% Identify aponeuroses and fascicle regions of interest
% -------------------------------------------------------------------------
    % Filter image  
    currentImageFiltered  = FrangiFilter2D(currentImage, settings.apoFrangiFilt);
    currentImageFiltered  = imbinarize(currentImageFiltered, 'adaptive', 'ForegroundPolarity', 'bright',  'sensitivity', .2);

    % Set aponeurosis search areas for current image
    if im > 1;
        apo1(im).ROI.searcharea = [max( min(apo1(im-1).ROI.boundary(:,2))-settings.vertmm, settings.apo1searchWin(1)*settings.imHeight), ...
                                   min( max(apo1(im-1).ROI.boundary(:,2))+settings.vertmm, settings.apo1searchWin(2)*settings.imHeight)];
        apo2(im).ROI.searcharea = [max( min(apo2(im-1).ROI.boundary(:,2))-settings.vertmm, settings.apo2searchWin(1)*settings.imHeight), ...
                                   min( max(apo2(im-1).ROI.boundary(:,2))+settings.vertmm, settings.apo2searchWin(2)*settings.imHeight)];
    end
    
    % Identify aponeurosis ROIs and lines   
    [apo1(im).line apo1(im).ROI] = getAponeurosis(settings, currentImageFiltered, apo1(im).ROI.searcharea);
    [apo2(im).line apo2(im).ROI] = getAponeurosis(settings, currentImageFiltered, apo2(im).ROI.searcharea);
    
    % define fascicle region of interest
    fasROI(im).position = [     1              apo1(im).line(1,2)+settings.vertmm; ...
                        settings.imWidth-1  apo1(im).line(2,2)+settings.vertmm; ...
                        settings.imWidth-1  apo2(im).line(2,2)-settings.vertmm; ...
                                1              apo2(im).line(1,2)-settings.vertmm];
    fasROI(im).mask = poly2mask(fasROI(im).position(:,1), fasROI(im).position(:,2), settings.imHeight, settings.imWidth);
                      
    [ROIr, ROIc] = find(fasROI(im).mask);
    fasROI(im).pixels = Ultrasound(:,:,im) .* fasROI(im).mask;
    fasROI(im).pixels = fasROI(im).pixels(min(ROIr):max(ROIr), min(ROIc):max(ROIc));
    
    clearvars ROIr ROIc

% -------------------------------------------------------------------------
% Hough transform
% -------------------------------------------------------------------------   
    % Filter fascicle ROI with Frangi filter             
    fasROI(im).pixels  = FrangiFilter2D(fasROI(im).pixels, settings.fasFrangiFilt);
    fasROI(im).pixels  = imbinarize(fasROI(im).pixels, 'adaptive', 'ForegroundPolarity', 'bright',  'sensitivity', .2);
    fasROI(im).pixels  = imresize(fasROI(im).pixels, ...
                    [settings.stretchVert*size(fasROI(im).pixels,1) settings.stretchHorz*size(fasROI(im).pixels,2)], ...
                    'Bicubic');

    % Get Hough angles in current image ROI
    Hough(im) = getHoughLines(settings, fasROI(im).pixels, apo1(im).ROI, apo2(im).ROI);
        
% -------------------------------------------------------------------------
% Feature point tracking
% -------------------------------------------------------------------------
    % track feature points on current image
    [apo1(im).pointsTracked, apo1(im).pointValidity, apo1(im).pointConfidence] = step(apo1Tracker, currentImage);
    [apo2(im).pointsTracked, apo2(im).pointValidity, apo2(im).pointConfidence] = step(apo2Tracker, currentImage);
    
    % only use points that are above the minimum point confidence threshold 
    apo1(im).pointsTracked  = apo1(im).pointsTracked(apo1(im).pointValidity & apo1(im).pointConfidence > settings.minPointConfidence, :);     
    apo1(im).points         = apo1(im).points(apo1(im).pointValidity & apo1(im).pointConfidence > settings.minPointConfidence, :);

    apo2(im).pointsTracked  = apo2(im).pointsTracked(apo2(im).pointValidity & apo2(im).pointConfidence > settings.minPointConfidence, :);     
    apo2(im).points         = apo2(im).points(apo2(im).pointValidity & apo2(im).pointConfidence > settings.minPointConfidence, :);
    
    % estimate geometric affine transformation from feature points
    if size(apo1(im).points,1) > 3 && size(apo1(im).pointsTracked,1) > 3
        apo1(im).tform = estimateGeometricTransform2D(apo1(im).points, apo1(im).pointsTracked, 'similarity'); 
    else
        apo1(im).tform = affine2d([1 0 0; 0 1 0; 0 0 1]);
    end
    
    if size(apo2(im).points,1) > 3 && size(apo2(im).pointsTracked,1) > 3
        apo2(im).tform = estimateGeometricTransform2D(apo2(im).points, apo2(im).pointsTracked, 'similarity');
    else
        apo2(im).tform = affine2d([1 0 0; 0 1 0; 0 0 1]);
    end
    
    % set new tracking points for next iteration
    points = detectMinEigenFeatures(currentImage);
    points = points.Location;
    
    if im < settings.vidLength;
        apo1(im+1).points = points(inpolygon(points(:,1), points(:,2), apo1(im).ROI.boundary(:,1), apo1(im).ROI.boundary(:,2)) ,:);    
        apo2(im+1).points = points(inpolygon(points(:,1), points(:,2), apo2(im).ROI.boundary(:,1), apo2(im).ROI.boundary(:,2)) ,:);    

        setPoints(apo1Tracker, apo1(im+1).points);
        setPoints(apo2Tracker, apo2(im+1).points);
    end
end

% Store total tracking time
trackTime = toc

% Clear PointTracker objects
clear apo1Tracker apo2Tracker