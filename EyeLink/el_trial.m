function [trialBeginsAt, param] = el_trial(ttn, param)

% (here)
% topOvalX = 1:10;
% topOvalY = 11:20;
% 
% % Freehand ROI x and y
% topStudyOval = reshape([topOvalX; topOvalY], 1, []);
% bottomStudyOval = reshape([bottomOvalX + alignOffset; ...
%     bottomOvalY], 1, []);
% 
% topTestOval = reshape([(topOvalX + xOffsetRand);(topOvalY + yOffsetRand)], 1, []);
% bottomTestOval = reshape([bottomOvalX + xOffsetRand + alignOffset; ...
%     bottomOvalY + yOffsetRand], 1, []);
% 
% % get the IA file for this trial
% thisIAFile = sprintf([repmat('%d_', 1, 9), '%d', '.ias'],...
%     xStudyTopOffset, yStudyTopOffset, ...
%     xStudyBottomOffset, yStudyBottomOffset, ...
%     xTestTopOffset, yTestTopOffset, ...
%     xTestBottomOffset, yTestBottomOffset, ...
%     screenX, screenY);
% 
% % Name of images sent to Host PC
% alignmentCF = 'am';
% studyCFName = [faceStudyTop.filename(1:5),faceStudyBott.filename(1:5),...
%     alignment(2-ed(ttn).bottomIsAligned),'.bmp'];
% testCFName = [faceTestTop.filename(1:5),faceTestBott.filename(1:5),...
%     alignment(2-ed(ttn).bottomIsAligned),'.bmp'];
% 
% % which image to display on the host PC
% imageList = {studyCFName, testCFName}; %
% 
% % Name of the masks sent to Host PC
% hostMaskName = ['HostCF' filesep stimSet{stimRace} '_Mask' filesep ...
%     'Scram_' num2str(masks(ed(ttn).maskID).round) '_' masks(ed(ttn).maskID).filename];

%% Step 8
% Now starts running individual trials;
% You can keep the rest of the code except for the implementation
% of graphics and event monitoring
% Each trial should have a pair of "StartRecording" and "StopRecording"
% calls as well integration messages to the data file (message to mark
% the time of critical events and the image/interest area/condition
% information for the trial)

% STEP 8.1
% Sending a 'TRIALID' message to mark the start of a trial in Data Viewer.
Eyelink('Message', 'TRIALID %d', ttn);

% This supplies the title at the bottom of the eyetracker display
conditionForHostStudy = 'somestrings';
Eyelink('Command', 'record_status_message "TRIAL %d/%d  %s"', ...
    ttn, param.tn, conditionForHostStudy);

% Before recording, we place reference graphics on the host display
% Must be offline to draw to EyeLink screen
Eyelink('Command', 'set_idle_mode');
% clear tracker display
Eyelink('Command', 'clear_screen 0')
% define the start and end of RT
Eyelink('Command', 'V_RT MESSAGE TestFace_%d Response_%d', ttn, ttn);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% transfer study image to host
% (here)
% imgfile = char(imageList);
% faceHostDir = ['HostCF' filesep stimSet{stimRace} filesep];
% imgfile_study = [faceHostDir char(imageList{1})];
% imgfile_test = [faceHostDir char(imageList{2})];
% transferimginfo=imfinfo(imgfile_study);
% fprintf('img file name is %s\n',transferimginfo.Filename);

% image file should be 24bit or 32bit bitmap
% (here)
% parameters of ImageTransfer:
% imagePath, xPosition, yPosition, width, height, trackerXPosition, trackerYPosition, xferoptions
% trackerXPosition = screenCenterX - transferimginfo.Width/2; %
% trackerYPosition = screenCenterY - faceY/2 - 1; %
% transferStatus =  Eyelink('ImageTransfer',transferimginfo.Filename,0,0,...
%     transferimginfo.Width,transferimginfo.Height,trackerXPosition,...
%     trackerYPosition,1);
% if transferStatus ~= 0
%     fprintf('*****Image transfer Failed*****-------\n');
% end
% 
% WaitSecs(0.1);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% STEP 8.2
% Do a drift correction at the beginning of each trial
% Performing drift correction (checking) is optional for
% EyeLink 1000 eye trackers.
EyelinkDoDriftCorrection(param.el);

% STEP 8.3
% start recording eye position (preceded by a short pause so that
% the tracker can finish the mode transition)
% The paramerters for the 'StartRecording' call controls the
% file_samples, file_events, link_samples, link_events availability
Eyelink('Command', 'set_idle_mode');
WaitSecs(0.05);

Eyelink('StartRecording');
% trail begins from here
trialBeginsAt = GetSecs;

% record a few samples before we actually start displaying
% otherwise you may lose a few msec of data

param.elopts.eye_used = Eyelink('EyeAvailable'); % get eye that's tracked
if param.elopts.eye_used == el.BINOCULAR % if both eyes are tracked
    param.elopts.eye_used = el.LEFT_EYE; % use left eye
end

end
