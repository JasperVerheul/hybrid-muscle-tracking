%% ------------------------------------------------------------------------
 function [fasROI apo1 apo2] = getInitialROIs(settings, referenceImage, checkReferenceImage);
% -------------------------------------------------------------------------
% This function detects the aponeurosis locations and regions of interest
% (ROI), and the fascicle ROI, in the first image of the ultrasound video. 
% These ROIs are used to initialise the feature-point tracker objects to  
% determine the geometric transformations of the aponeuroses.
% 
% The open-source Hessian-based Frangi vesselness filtering functions used 
% in this function were developed by Dirk-Jan Kroon. 
% (https://uk.mathworks.com/matlabcentral/fileexchange/24409-hessian-based-
% frangi-vesselness-filter).
% 
% Input:            - settings: predefined settings structure.
%                   - referenceImage: reference ultrasound image for 
%                     initialisation. The default is the first image in a 
%                     video sequence, but can be adjusted if the
%                     aponeuroses cannot be detected well.
%                   - checkReferenceImage: check the determined location of
%                     the aponeuroses and fascicle region of interest in
%                     the reference image. 0=false; 1=true.
%
% Output:           - fasROI: struct containing the location and pixels of 
%                     the fascicle region of interest.
% 	                - apo1: struct containing the location, region of 
%                     interest, and feature points for aponeurosis 1.
% 	                - apo2: struct containing the location, region of 
%                     interest, and feature points for aponeurosis 2.
% -------------------------------------------------------------------------

clc

% Identify feature tracking points
points = detectMinEigenFeatures(referenceImage);
points = points.Location;

% Convert image to black white 
refImageFiltered  = FrangiFilter2D(referenceImage, settings.apoFrangiFilt);
refImageFiltered  = imbinarize(refImageFiltered, 'adaptive', 'ForegroundPolarity', 'bright',  'sensitivity', .2);

% Identify aponeurosis ROIs and lines
[apo1.line apo1.ROI] = getAponeurosis(settings, refImageFiltered, settings.apo1searchWin .* [settings.imHeight settings.imHeight]);
[apo2.line apo2.ROI] = getAponeurosis(settings, refImageFiltered, settings.apo2searchWin .* [settings.imHeight settings.imHeight]);

apo1.points = points(inpolygon(points(:,1), points(:,2), apo1.ROI.boundary(:,1), apo1.ROI.boundary(:,2)) ,:);
apo2.points = points(inpolygon(points(:,1), points(:,2), apo2.ROI.boundary(:,1), apo2.ROI.boundary(:,2)) ,:);

% Define fascicle region of interest
fasROI.position = [         1              apo1.line(1,2)+settings.vertmm; ...
                    settings.imWidth-1  apo1.line(2,2)+settings.vertmm; ...
                    settings.imWidth-1  apo2.line(2,2)-settings.vertmm; ...
                            1              apo2.line(1,2)-settings.vertmm];
fasROI.mask = poly2mask(fasROI.position(:,1), fasROI.position(:,2), settings.imHeight, settings.imWidth);

[ROIr, ROIc] = find(fasROI.mask);
fasROI.pixels = referenceImage .* fasROI.mask;
fasROI.pixels = fasROI.pixels(min(ROIr):max(ROIr), min(ROIc):max(ROIc));

if checkReferenceImage == 1;
    figure;
    imshow(referenceImage);
    hold on;
    title('Press FINISH when ready');
    
    % Draw fascicle region of interest
    drawpolygon('Color',[1 1 0] , 'InteractionsAllowed','all', 'Position',fasROI.position);
    
    % Draw aponeurosis lines
    drawline('Color',[0 0 1] , 'InteractionsAllowed','all', 'Position', apo1.line);
    drawline('Color',[0 0 1] , 'InteractionsAllowed','all', 'Position', apo2.line);
    
    % Draw aponeurosis boundaries
    plot(apo1.ROI.boundary(:,1), apo1.ROI.boundary(:,2), 'r', 'LineWidth', 2);
    scatter(apo1.points(:,1), apo1.points(:,2), 'gx');
    scatter(apo1.ROI.properties.Centroid(1,1), apo1.ROI.properties.Centroid(1,2), 'bo', 'LineWidth', 4);
    
    plot(apo2.ROI.boundary(:,1), apo2.ROI.boundary(:,2), 'r', 'LineWidth', 2);
    scatter(apo2.points(:,1), apo2.points(:,2), 'gx');
    scatter(apo2.ROI.properties.Centroid(1,1), apo2.ROI.properties.Centroid(1,2), 'bo', 'LineWidth', 4);
      
    uicontrol('Units', 'Normalized','Position',[.7 .2 .15 .05],'String','FINISH',...
        'Callback','uiresume(gcf)');
    uiwait(gcf);
    
    close(gcf);
end