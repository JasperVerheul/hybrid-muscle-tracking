%% ------------------------------------------------------------------------
 function settings = setFolders(baseFolder);
% -------------------------------------------------------------------------
% This function sets the folders for general tracking script (e.g.,
% 'hybridMuscleTracker.m'), input ultrasound video data, Frangi vesselness
% filter functions, tracking functions, and tracking results. If any of the
% folders does not exist, it is created.
% -------------------------------------------------------------------------

settings.baseFolder     = baseFolder;
settings.functionFolder = [baseFolder 'Functions\'];
settings.dataFolder     = [baseFolder 'Data\'];
settings.resultFolder   = [baseFolder 'TrackingResults\'];
settings.FrangiFolder   = [baseFolder 'FrangiFilter\'];

cd(baseFolder);
addpath(genpath(baseFolder));

% Create non-existing folders
folderNames = fieldnames(settings);
for i = 1 : numel(folderNames);
    if not(isfolder( settings.(char(folderNames(i))) ));
        mkdir( settings.(char(folderNames(i))) );
    end
end
