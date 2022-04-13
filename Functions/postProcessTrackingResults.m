%% ------------------------------------------------------------------------
 function [apo1 apo2 Hough FPT Hybrid] = postProcessTrackingResults(settings, apo1, apo2, Hough);
% -------------------------------------------------------------------------
% This function post-processes the tracking results from 'trackMuscle.m'.
% 
% Input:            - settings: predefined settings structure.
%                   - apo1: struct containing aponeurosis 2 position and 
%                     tracking results.
%                   - apo2: struct containing aponeurosis 2 position and 
%                     tracking results.
%                   - Hough: struct containing Hough transform tracking
%                     results.
% 
% Output:           - apo1: struct containing aponeurosis 1 position and 
%                     tracking results, including post-processing results.
%                   - apo2: struct containing aponeurosis 2 position and 
%                     tracking results, including post-processing results.
%                   - Hough: struct containing Hough transform tracking
%                     results, including post-processing results.
%                   - FPT: struct containing feature-point tracking
%                     results.
%                   - Hybrid: struct containing hybrid tracking results.
% -------------------------------------------------------------------------

clc

% Smooth aponeurosis lines
for im = 1 : settings.vidLength
    apo1XY(im,:) = [apo1(im).line(1,:) apo1(im).line(2,:)];
    apo2XY(im,:) = [apo2(im).line(1,:) apo2(im).line(2,:)];
end
apo1XY = movmean(apo1XY, 10);
apo2XY = movmean(apo2XY, 10);

for im = 1 : settings.vidLength
    apo1(im).line = [apo1XY(im,1:2); apo1XY(im,3:4)];
    apo2(im).line = [apo2XY(im,1:2); apo2XY(im,3:4)];
end

% Calculate aponeurosis angles
for im = 1 : settings.vidLength;
    apo1(im).angle = atand( (apo1(im).line(2,2)-apo1(im).line(1,2)) / (apo1(im).line(2,1)-apo1(im).line(1,1)) );
    apo1(im).angle = atand( tand(apo1(im).angle) * (settings.horzmm / settings.vertmm) ); % angle corrected for pix-mm ratio
    apo2(im).angle = atand( (apo2(im).line(2,2)-apo2(im).line(1,2)) / (apo2(im).line(2,1)-apo2(im).line(1,1)) );
    apo2(im).angle = atand( tand(apo2(im).angle) * (settings.horzmm / settings.vertmm) ); % angle corrected for pix-mm ratio
end
apo1Ang = num2cell( movmean([apo1.angle], 10)' );
[apo1.angle] = apo1Ang{:};
apo2Ang = num2cell( movmean([apo2.angle], 10)' );
[apo2.angle] = apo2Ang{:};

% -------------------------------------------------------------------------
% Hough transform
% -------------------------------------------------------------------------
% Delete hough angles that are smaller/greater than [median +/- interquartile range] for all angles in video
houghAngs1 = [];
for im = 1:length(Hough); % get all Hough angles for video
    houghAngs1 = vertcat(houghAngs1, [repelem(im,length([Hough(im).lines.angle]))', [Hough(im).lines.angle]', [Hough(im).lines.length]']);
end

for im = 1:length(Hough); % delete values
    Hough(im).lines([Hough(im).lines.angle]' < (median(houghAngs1(:,2)) - settings.exclIQR*iqr(houghAngs1(:,2)))) = [];
    Hough(im).lines([Hough(im).lines.angle]' > (median(houghAngs1(:,2)) + settings.exclIQR*iqr(houghAngs1(:,2)))) = [];
end

houghAngs = [];
for im = 1:length(Hough); % get all Hough angle for video after deleting
    houghAngs = vertcat(houghAngs, [repelem(im,length([Hough(im).lines.angle]))', [Hough(im).lines.angle]', [Hough(im).lines.length]']);
end

% Fit time-dependent Hough angle
fitHT = fit(houghAngs(:,1), houghAngs(:,2),'smoothingspline','Weights', houghAngs(:,3));
fitHT = num2cell( movmean( feval(fitHT,[1:length(Hough)]), 10) ); % moving mean of time-dependent fit Hough angles
[Hough.angle] = fitHT{:};

% -------------------------------------------------------------------------
% Hybrid tracking
% -------------------------------------------------------------------------
for im = 1:settings.vidLength;
    % Apply geometric affine transformation to apo1 intersection points
    if im == 1;
        FPT(im).line = [apo2(im).line(2,1)-(apo2(im).line(2,2)-mean([apo1(im).line(:,2);apo2(im).line(:,2)])) / tand(Hough(im).angle), mean([apo1(im).line(:,2);apo2(im).line(:,2)]); ...
            apo2(im).line(2,1), apo2(im).line(2,2)];
        FPT(im).apo1int       = getLineIntersection(apo1(im).line, FPT(im).line);
        FPT(im).apo2int       = getLineIntersection(apo2(im).line, FPT(im).line);
        Hybrid(im).apo2int     = FPT(im).apo2int;
        
        apo1(im).lineFT       = apo1(im).line;
        apo2(im).lineFT       = apo2(im).line;
    else
        if sum(apo1(im).pointValidity) > settings.minValidPointRatio * length(apo1(im).pointValidity);
            apo1(im).lineFT   = double( transformPointsForward(apo1(im).tform, apo1(im-1).lineFT));
            FPT(im).apo1int   = double( transformPointsForward(apo1(im).tform, FPT(im-1).apo1int));
        else
            apo1(im).lineFT   = apo1(im-1).lineFT;
            FPT(im).apo1int   = FPT(im-1).apo1int;
        end
        
        if sum(apo2(im).pointValidity) > settings.minValidPointRatio * length(apo2(im).pointValidity);
            apo2(im).lineFT   = double( transformPointsForward(apo2(im).tform, apo2(im-1).lineFT));
            FPT(im).apo2int   = double( transformPointsForward(apo2(im).tform, FPT(im-1).apo2int));
            Hybrid(im).apo2int = double( transformPointsForward(apo2(im).tform, Hybrid(im-1).apo2int));
        else
            apo2(im).lineFT   = apo2(im-1).lineFT;
            FPT(im).apo2int   = FPT(im-1).apo2int;
            Hybrid(im).apo2int = Hybrid(im-1).apo2int;
        end
    end
    
    % Calculate feature-point tracking (FPT) fascicle dimensions
    FPT(im).height      = (FPT(im).apo2int(2)-FPT(im).apo1int(2)) / settings.vertmm;
    FPT(im).width       = (FPT(im).apo2int(1)-FPT(im).apo1int(1)) / settings.horzmm;
    FPT(im).length      = sqrt( FPT(im).height^2 + FPT(im).width^2 ) ;
    FPT(im).angle       = atand( FPT(im).height / FPT(im).width );
    
    % Create line and find intersection points for Hough transform angle
    Hough(im).line      = [FPT(im).apo1int; ...
        FPT(im).apo1int + [1 tand(Hough(im).angle)] ];
    Hough(im).apo1int   = FPT(im).apo1int;
    Hough(im).apo2int   = getLineIntersection(apo2(im).line, Hough(im).line);
    Hough(im).line      = [Hough(im).apo1int; Hough(im).apo2int];
    Hough(im).length    = sqrt( (diff(Hough(im).line(:,1)) / settings.horzmm)^2 + (diff(Hough(im).line(:,2)) / settings.vertmm)^2 );
    
    % Hybrid aponeurosis 2 intersection from Hough line
    options = optimoptions('lsqnonlin', 'OptimalityTolerance', 1e-6, 'FunctionTolerance', 1e-6, 'StepTolerance', 1e-6, 'MaxFunctionEvaluations', 500);
    minLims = max( min(Hybrid(im).apo2int, Hough(im).apo2int), mean([Hybrid(im).apo2int;Hough(im).apo2int]) - [2*settings.horzmm 2*settings.vertmm]);
    maxLims = min( max(Hybrid(im).apo2int, Hough(im).apo2int), mean([Hybrid(im).apo2int;Hough(im).apo2int]) + [2*settings.horzmm 2*settings.vertmm]);
    p_opt = lsqnonlin(@(p) correctHybridPoint(settings, p, FPT(im).apo1int, Hybrid(im).apo2int, Hough(im).angle), ...
            [0 0], minLims, maxLims, options);
    
    Hybrid(im).apo2int   = getLineIntersection([FPT(im).apo1int; p_opt],apo2(im).line);
    
    % Calculate hybrid fascicle line properties
    Hybrid(im).height    = (Hybrid(im).apo2int(2)-FPT(im).apo1int(2)) / settings.vertmm;
    Hybrid(im).width     = (Hybrid(im).apo2int(1)-FPT(im).apo1int(1)) / settings.horzmm;
    Hybrid(im).length    = sqrt( Hybrid(im).height^2 + Hybrid(im).width^2 );
    Hybrid(im).angle     = atand( Hybrid(im).height / Hybrid(im).width );
    
    % Calculate aponeurosis displacement
    if im > 1
        % Hough intersection point displacement
        Hough(im).apo1dx  = (Hough(im).apo1int(1) - Hough(1).apo1int(1)) / settings.horzmm;
        Hough(im).apo1dy  = (Hough(im).apo1int(2) - Hough(1).apo1int(2)) / settings.vertmm;
        Hough(im).apo1dxy = sqrt(Hough(im).apo1dx^2 + Hough(im).apo1dy^2);
        Hough(im).apo2dx  = (Hough(im).apo2int(1) - Hough(1).apo2int(1)) / settings.horzmm;
        Hough(im).apo2dy  = (Hough(im).apo2int(2) - Hough(1).apo2int(2)) / settings.vertmm;
        Hough(im).apo2dxy = sqrt(Hough(im).apo2dx^2 + Hough(im).apo2dy^2);
        
        % Feature-point tracking (FPT) intersection point displacement
        apo1(im).dx  = (FPT(im).apo1int(1) - FPT(1).apo1int(1)) / settings.horzmm;
        apo1(im).dy  = (FPT(im).apo1int(2) - FPT(1).apo1int(2)) / settings.vertmm;
        apo1(im).dxy = sqrt(apo1(im).dx^2 + apo1(im).dy^2);
        apo2(im).dx  = (FPT(im).apo2int(1) - FPT(1).apo2int(1)) / settings.horzmm;
        apo2(im).dy  = (FPT(im).apo2int(2) - FPT(1).apo2int(2)) / settings.vertmm;
        apo2(im).dxy = sqrt(apo2(im).dx^2 + apo2(im).dy^2);
        
        % Hybrid intersection point displacement
        Hybrid(im).dx  = (Hybrid(im).apo2int(1) - Hybrid(1).apo2int(1)) / settings.horzmm;
        Hybrid(im).dy  = (Hybrid(im).apo2int(2) - Hybrid(1).apo2int(2)) / settings.vertmm;
        Hybrid(im).dxy = sqrt(Hybrid(im).dx^2 + Hybrid(im).dy^2);
    end
    clc
end

% Adjust fascicle pennation angles for aponeurosis 2 angle
if strcmp(settings.apo2correct, 'true')
    adjHough = num2cell( [Hough.angle] - [apo2.angle] )';
    [Hough.angle_aac] = adjHough{:};
    
    adjFas = num2cell( [FPT.angle] - [apo2.angle] )';
    [FPT.angle_aac] = adjFas{:};
    
    adjHybrid = num2cell( [Hybrid.angle] - [apo2.angle] )';
    [Hybrid.angle_aac] = adjHybrid{:};
end