function param = cat_iafiles(param)
% param = cat_iafiles(param)
%
% Create interest areas files.
%
%% Default ROI (without jitters)
% assume all stimuli are the same size
stimX=size(param.stimuli(1).matrix,2);
stimY=size(param.stimuli(1).matrix,1);
halfFaceX = stimX/2;
halfFaceY = stimY/2;

% Create Oval freehand ROI
% contour coordinates of half an oval with origin at the center of the screen
% all the available points along x axis (i.e., Y)
yOval = -halfFaceY:1:halfFaceY;
xHalfOvalR = round(sqrt(1-(yOval/halfFaceY).^2)*halfFaceX);
xHalfOvalL = -xHalfOvalR;

% left and right half of the oval
lOval = [xHalfOvalL; yOval];
rOval = [xHalfOvalR; fliplr(yOval)];

param.ovalROI = horzcat(lOval, rOval)+[param.screenX/2; param.screenY/2];

%% Create the IA files

% Gather the folder name to save the IA files
if ~isfield(param, 'iafolder') || isempty(param.iafolder)
    param.iafolder = 'IA_Files';
end
if ~exist(param.iafolder, 'dir')
    mkdir(param.iafolder);
end

for iX = param.jitterX % X jitters
    for iY = param.jitterY % Y jitters

        % set the filename
        iaFilename = sprintf([repmat('%d_', 1, 3), '%d', '.ias'],...
            iX, iY, ...
            param.screenX, param.screenY);

        % Freehand ROI x and y
        theCoorPairs = reshape(param.ovalROI+[iX;iY], 1, []);

        % create the file
        thisFileID = fopen(fullfile(param.iafolder, iaFilename), 'w'); %

        % write content to the file
        % Each row is one ROI: start time [relative to the start of the
        % trial onset], stop time, ROI_index, the coordinate pairs,
        % ROI_name;
        fprintf(thisFileID, ...
            ['%d %d FREEHAND %d ', repmat('%d,%d ', 1, size(param.ovalROI,2)), '%s'], ...
            0, - param.stimDuration*1000 + 1, 1, theCoorPairs, 'OvalROI');

    end % iRandY
end % iRandX

