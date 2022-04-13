%% ------------------------------------------------------------------------
 function plotTrackingResults(settings, Ultrasound, fasROI, apo1, apo2, Hough, FPT, Hybrid);
% -------------------------------------------------------------------------
% This function creates a video of the tracking results. The output video
% is saved in the 'TrackingResults' folder.
% 
% Input:            - settings: predefined settings structure.
%                   - Ultrasound: ultrasound video under analysis.
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
% Output:           - MP4 video of the tracked muscle, including result 
%                     plots for the hybrid, Hough transform, and 
%                     feature-point tracking methods. Saved in the
%                     'TrackingResults' folder.
% -------------------------------------------------------------------------

close all
cd(settings.resultFolder);

for im = 1 : settings.vidLength;
    clc;
    disp(['Plotting video. Current image: ' num2str(im) '/' num2str(size(Ultrasound,3))]);
    
    if im == 1;
        figure; 
        set(gcf, 'Units', 'Normalized', 'OuterPosition', [0 0 1 1], 'Visible', 'off'); 
        hold on;
    end
    
    % Get current image
    currentImage = Ultrasound(:,:,im);
    
    % ------------------------------------------------------
    % Add tracking features and Hough lines to current image
    % ------------------------------------------------------   
    % Aponeurosis 1 ROI, feature-tracking points, and line
    a1b = apo1(im).ROI.boundary';
    currentImage = insertShape(currentImage,'polygon',a1b(:)', 'LineWidth',2, 'Color','red');
    currentImage = insertMarker(currentImage, apo1(im).pointsTracked, '+', 'Color','green');
    currentImage = insertShape(currentImage, 'Line', [apo1(im).line(1,:) apo1(im).line(2,:)] , 'LineWidth',3, 'Color','blue');
    
    % Aponeurosis 2 ROI, feature-tracking points, and line
    a2b = apo2(im).ROI.boundary';
    currentImage = insertShape(currentImage,'polygon',a2b(:)', 'LineWidth',2, 'Color','red');
    currentImage = insertMarker(currentImage, apo2(im).pointsTracked, '+', 'Color','green');
    currentImage = insertShape(currentImage, 'Line', [apo2(im).line(1,:) apo2(im).line(2,:)] , 'LineWidth',3, 'Color','blue');
    
    % Feature-point tracking (FPT) fascicle line and intersection point
    currentImage = insertShape(currentImage, 'Line', [FPT(im).apo1int FPT(im).apo2int], 'LineWidth',5, 'Color','red');
    currentImage = insertShape(currentImage, 'FilledCircle', [FPT(im).apo2int(1) FPT(im).apo2int(2) 7], 'Color','red');
    
    % Hybrid fascicle line and intersection point
    currentImage = insertShape(currentImage, 'Line', [FPT(im).apo1int Hybrid(im).apo2int], 'LineWidth',5, 'Color',[0 .5 0]);
    currentImage = insertShape(currentImage, 'FilledCircle', [Hybrid(im).apo2int(1) Hybrid(im).apo2int(2) 7], 'Color',[0 .5 0]);
    
    % Rotate fascicle ROI (if necessary) and insert Hough lines
    fROI = fasROI(im).position';
    currentImage = insertShape(currentImage, 'polygon', fROI(:)', 'LineWidth',2, 'Color','yellow'); 
    for k = 1:length(Hough(im).lines);
        xy = [Hough(im).lines(k).point1; Hough(im).lines(k).point2] ./ [settings.stretchHorz settings.stretchVert; settings.stretchHorz settings.stretchVert]  + [min(fasROI(im).position(:,1)) min(fasROI(im).position(:,2)); min(fasROI(im).position(:,1)) min(fasROI(im).position(:,2))];
        currentImage = insertShape(currentImage, 'Line', reshape(xy', 1, []), 'LineWidth',1, 'Color','green');
    end
    
    % Insert Hough fascicle line
    currentImage = insertShape(currentImage, 'Line', [FPT(im).apo1int Hough(im).apo2int], 'LineWidth',5, 'Color',[0 0 1]);
    currentImage = insertShape(currentImage, 'FilledCircle', [Hough(im).apo2int(1) Hough(im).apo2int(2) 7], 'Color',[0 0 1]);
    
    % ---------------------
    % Plot tracking results
    % ---------------------
    subplot(3,5,[1 2 3, 6 7 8, 11 12 13]);
        imshow(currentImage(1:.6*end,:,:));
        title(['Image:' num2str(im) '/' num2str(size(Ultrasound,3))]);
    subplot(3,5,[4 5]);
        plot([Hough(1:im).angle_aac], 'b:', 'LineWidth',1.5);hold on;
        plot([FPT(1:im).angle_aac], 'r:', 'LineWidth',1.5);
        plot([Hybrid(1:im).angle_aac], 'Color',[0 .5 0], 'LineStyle','-', 'LineWidth', 1.5);
        xline(im);hold off;
        title('Fascicle pennation angle');
        xlabel('Time (images)');xlim([0 size(Ultrasound,3)]);ylabel('Angle (deg)');      
        legend('Hough', 'FPT', 'Hybrid');
    subplot(3,5,[9 10]);
        plot([Hough(1:im).length], 'b:', 'LineWidth',1.5);hold on;
        plot([FPT(1:im).length], 'r:', 'LineWidth',1.5);hold on;
        plot([Hybrid(1:im).length], 'Color',[0 .5 0], 'LineStyle','-', 'LineWidth',1.5);
        xline(im);hold off;
        title('Fascicle length');
        xlabel('Time (images)');xlim([0 size(Ultrasound,3)]);ylabel('Length (mm)');      
        legend('Hough', 'FPT', 'Hybrid');
    subplot(3,5,[14 15]);
        plot([Hough(1:im).apo2dxy], 'b-', 'LineWidth',1.5);hold on;
        plot([apo2(1:im).dxy], 'r:', 'LineWidth',1.5);hold on;
        plot([Hybrid(1:im).dxy], 'Color',[0 .5 0], 'LineStyle','-', 'LineWidth',1.5);
        xline(im);hold off;
        title('Aponeurosis displacement');
        xlabel('Time (images)');xlim([0 size(Ultrasound,3)]);ylabel('Displacement (mm)');      
        legend('Hough', 'FPT', 'Hybrid');
    drawnow;
    
    if im == 1;
        video = VideoWriter([settings.fileName '_trackingResults_mp4'], 'MPEG-4');
        video.FrameRate = settings.imps;
        open(video);
    end
    writeVideo(video, getframe(gcf));
end

close(video);

cd ..\
disp('Result video ready!');
