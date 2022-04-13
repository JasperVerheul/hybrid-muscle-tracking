%% ------------------------------------------------------------------------
 function Ultrasound = getUltrasoundVideo(settings, fileName);
% -------------------------------------------------------------------------
% This function loads the ultrasound video of the muscle to be tracked.
% 
% Input:            - settings: settings struct containing folder paths.
%                   - fileName: name of the input video file to be 
%                     analysed.
%
% Output            - Ultrasound: ultrasound video of the muscle to be 
%                     tracked.
% -------------------------------------------------------------------------

vid = VideoReader([settings.dataFolder fileName '.mp4']);
for im = 1 : vid.NumFrames;
    Ultrasound(:,:,im) = rgb2gray( im2double(read(vid,im,'native')) );
end

