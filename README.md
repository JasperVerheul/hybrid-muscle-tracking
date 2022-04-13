# Hybrid muscle tracking

## Summary
This respository contains the MATLAB code for a hybrid method to track skeletal muscle architecture from B-mode ultrasound videos. This fully-automated approach builds on the complimentary nature of a sequential (feature-point tracking) and non-sequential (Hough transform) method. The main outcome measures of muscle architecture include:
+ fascicle pennation angle
+ fascicle length 
+ aponeurosis displacement

The hybrid muscle tracking method and its application for tibialis anterior tracking during isometric contractions are described in more detail in our [bioRxiv preprint](). 

All code described below and contained in this repository has been developed and tested in MATLAB version R2021a. 

## Example instructions
An example MATLAB script (***hybridMuscleTracking.m***) for executing the hybrid tracking method, including an example ultrasound video, can be found in the main folder of the [hybrid-muscle-tracking](https://github.com/JasperVerheul/hybrid-muscle-tracking) repository. This code can be executed by following the below steps:
1. Download all the folders and files in the [hybrid-muscle-tracking](https://github.com/JasperVerheul/hybrid-muscle-tracking) repository.
2. Open ***hybridMuscleTracker.m*** in MATLAB.
3. Make sure the MP4 ultrasound video of interest is located in the [Data](https://github.com/JasperVerheul/hybrid-muscle-tracking/tree/main/Data) folder.
4. Change '*fileName*' to desired video file name to track (e.g., '*exampleVideoTA*').
5. Run the code.

Note: if checkReferenceImage in ***getInitialROIs.m*** is set to **1**, check if the aponeurosis and fascicle ROIs are in the correct position, and press 'FINISH'. If not, change '*referenceImage*' to another ultrasound image as a starting point.

Tracking results are saved in the [TrackingResults](https://github.com/JasperVerheul/hybrid-muscle-tracking/tree/main/TrackingResults) folder as '*fileName_trackingResults.mat*'. Optionally, a video of the tracking results can be created, of which an example (gif) is shown below, and saved in the [TrackingResults](https://github.com/JasperVerheul/hybrid-muscle-tracking/tree/main/TrackingResults) folder as '*fileName_trackingResults_mp4*'.

![picture](https://github.com/JasperVerheul/hybrid-muscle-tracking/blob/main/TrackingResults/exampleVideoTA_trackingResults_gif.gif)

## Function descriptions
Below is a short description for each function included in the [Functions](https://github.com/JasperVerheul/hybrid-muscle-tracking/tree/main/Functions) folder. Please see the code of individual functions for more details.
+ ***correctHybridPoint.m***: correct the feature-point tracked hybrid intersection point in the central aponeurosis based on the Hough transform fascicle.
+ ***getAponeurosis.m***: determine the aponeurosis location and region of interest.
+ ***getHoughLines.m***: perfom Hough transform on the fascicle region of interest.
+ ***getInitialROIs.m***: determine the location of the aponeuroses and fascicle region of interest in the first image of the video.
+ ***getLineIntersection.m***: determine the intersection point of two lines (e.g., fascicle and aponeurosis).
+ ***getSettings.m***: load predefined settings.
+ ***hybridMuscleTracking.m***: main (example) script for performing hybrid muscle tracking.
+ ***initialiseTracker.m***: set the aponeurosis tracker to track selected feature points.
+ ***plotTrackingResults.m***: create an MP4 video of the tracked muscle and tracking results.
+ ***postProcessTrackingResults.m***: post-process the tracking results from ***trackMuscle.m*** (comprises hybrid approach).
+ ***saveTrackingResults.m***: save the tracking results to a mat file.
+ ***setFolders.m***: set the required folder paths (input ultrasound video data, output tracking results, and Frangi vesselness filter).
+ ***trackMuscle.m***: perform Hough transform and feature-point tracking for each image in the video.

Note: ***trackMuscle.m*** and ***getFascicleROI.m*** make use of the open-source Hessian-based Frangi vesselness filter functions developed by [Dirk-Jan Kroon](https://uk.mathworks.com/matlabcentral/fileexchange/24409-hessian-based-frangi-vesselness-filter), which can be found in the [FrangiFilter](https://github.com/JasperVerheul/hybrid-muscle-tracking/tree/main/FrangiFilter) folder.

## Licensing
All code and data files in this repository are available under the Apache-2.0 License (see the [LICENSE file](https://github.com/JasperVerheul/hybrid-muscle-tracking/blob/main/LICENSE) for more details).
