%% ------------------------------------------------------------------------
 function error = correctHybridPoint(settings, p, apo1int_FPT, apo2int_hybrid, houghAngle);
% -------------------------------------------------------------------------
% This function corrects the feature-point tracked hybrid intersection 
% point in the central aponeurosis based on the Hough transform fascicle.
% 
% Input:            - settings: predefined settings structure.
%                   - p: x and y coordinates of the optimised hybrid
%                     fascicle insertion point.
%                   - apo1int_FPT: feature-point tracked fascicle insertion
%                     point in aponeurosis 1.
%                   - apo2int_hybrid: feature-point tracked hybrid fascicle
%                     insertion point in aponeurosis 2.
%                   - houghAngle: Hough fascicle line angle.
% 
% Output:           - error: error metric to minimise.
% -------------------------------------------------------------------------

pxy             = ([p(1) p(2)] - apo1int_FPT) ./ [settings.horzmm settings.vertmm]; % x,y distance in mm (from top left corner of the image) 
plen            = sqrt( sum( pxy.^2 ) ); % fascicle length in mm
pang            = atand( pxy(2) / pxy(1) ); % fascicle angle

d_position      = abs([p(1) p(2)] - apo2int_hybrid) ./ [settings.horzmm settings.vertmm]; % difference in x,y position in mm
d1              = sqrt( sum( d_position.^2 ) ); % distance to hybrid point in im-1
d_theta         = abs(pang - houghAngle); % fascicle angle difference with Hough fascicle line
d2              = plen * d_theta * pi/180; % arclength from hybrid point to Hough fascicle line

error           = abs( settings.hybridWeigh * d1 - d2 );