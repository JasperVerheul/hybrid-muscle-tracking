%% ------------------------------------------------------------------------
 function settings = getSettings(settings, Ultrasound, fileName);
% -------------------------------------------------------------------------
% This function is used to set and store the settings for the various steps
% required for hybrid muscle tracking. Settings can be adjusted prior to 
% calling this function to be taken into account during the hybrid tracking 
% process.
% 
% Input:            - settings: settings struct containing folder paths.
%                   - Ultrasound: ultrasound video of the muscle to be 
%                     tracked.
%                   - fileName: name of the input video file to be 
%                     analysed.
% 
% Output:           - settings: predefined settings struct to be used for 
%                     the various steps of the hybrid muscle tracking
%                     process.
% -------------------------------------------------------------------------

%% File name
settings.fileName           = fileName;

%% Ultrasound video
settings.scanWidth          = 38; % scanning width in mm
settings.scanDepth          = 35; % scanning depth in mm
settings.imps               = 30; % capture rate in Hz (images per second)
settings.imHeight           = size(Ultrasound,1); % image height in pixels
settings.imWidth            = size(Ultrasound,2); % image height in pixels
settings.vidLength          = size(Ultrasound,3); % video length in # images
settings.vertmm             = settings.imHeight / settings.scanDepth; % number of pixels per vertical mm
settings.horzmm             = settings.imWidth / settings.scanWidth; % number of pixels per horizontal mm

%% Filtering 
settings.fasFrangiFilt      = struct('FrangiScaleRange', [1 2], 'FrangiScaleRatio', .2, ...
                            'FrangiBetaOne', 0.5, 'FrangiBetaTwo', 15, ...
                            'verbose',false,'BlackWhite',false); % Frangi filter settings for fascicle ROI
settings.apoFrangiFilt      = struct('FrangiScaleRange', [settings.vertmm 2*settings.vertmm], 'FrangiScaleRatio', 1, ...
                            'FrangiBetaOne', 0.5, 'FrangiBetaTwo', 15, ...
                            'verbose',false,'BlackWhite',false); % Frangi filter settings for aponeurosis identification

%% Aponeurosis detection
settings.apo1searchWin      = [.05 .20]; % search window for aponeurosis 1
settings.apo2searchWin      = [.30 .60]; % search window for aponeurosis 2

%% Hough transform
settings.stretchVert        = 3; % vertical stretch factor for fascicle ROI
settings.stretchHorz        = 1; % horizontal stretch factor for fascicle ROI
settings.numHoughPeaks      = 50; % number of Hough peaks to use
settings.fillGap            = 5; % maximal gap to fill between Hough lines
settings.minLength          = .5 * settings.horzmm; % minimal acceptable Hough line length

%% Hough transform post-processing
settings.exclHoughLines     = 'true'; % exclude defined Hough lines (see below) if 'true' 
settings.exclSmallerThan    = 1; % exclude Hough lines if angle is smaller than
settings.exclLargerThan     = 90; % exclude Hough lines if angle is larger than
settings.exclIQR            = 1.5; % exclude Hough lines if angle is outside defined interquartile range
settings.weighHoughAngles   = 'true'; % weigh Hough lines for line length if 'true'
settings.apo2correct        = 'true'; % correct Hough line angles for aponeurosis 2 angle if 'true'

%% Feature-point tracking
settings.NumPyramidLevels       = 4; % number of pyramid levels
settings.MaxBidirectionalError  = 1; % maximal bidirectional error
settings.BlockSize              = [31 31]; % block size
settings.MaxIterations          = 50; % maximal number of search iterations
settings.minPointConfidence     = 0.9; % minimal acceptable point-tracking confidence score
settings.minValidPointRatio     = 0.2; % minimal acceptable number of valid tracked points
settings.hybridWeigh            = 12; % hybrid weigh factor for FPT-Hough 

