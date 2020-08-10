function param = cf_stim(param)
% load stimulus information for composite face task.
%
% Input:
%     param           <structure> parameters of the exp.
%
% Output:
%     param           <structure> parameters of the exp

% screen dimenstions
screenRect = param.screenRect;
screenX = screenRect(3);
screenY = screenRect(4);

%% Composite stimuli
% stimulus dimentions
[faceY, faceX, ~] = size(param.stimuli(1,1).matrix);
faceCenter = CenterRect([0 0 faceX faceY], screenRect);
param.faceY = faceY;
param.faceX = faceX;

% stimulus rect information
param.faceTopRect = [0 0 faceX faceY/2];
param.faceBottomRect = [0 faceY/2 faceX faceY];

% stimulus positions 
param.faceTopPosition = [faceCenter(1)...
    faceCenter(2)-1 ...
    faceCenter(3) ...
    faceCenter(4)-(faceCenter(4)-faceCenter(2))/2-1];

param.faceBottomPosition =[faceCenter(1) ...
    faceCenter(2)+(faceCenter(4)-faceCenter(2))/2+2 ...
    faceCenter(3) ...
    faceCenter(4)+2];

% white line information
misalignSize = param.faceX * param.misalignPerc;
param.lineRect = [screenX/2-(3*misalignSize + (faceCenter(3)-faceCenter(1)))/2 ...
    screenY/2-1 ...
    screenX/2+(3*misalignSize+(faceCenter(3)-faceCenter(1)))/2 ...
    screenY/2+2];

% cue position (in the middle of the screen)
cuePixel = param.cuePixel;
cueLengthHalf = param.cueLength * faceX/2;
cueSideLength = param.cueSideLength;

param.cuePosi = [screenX/2-cueLengthHalf screenY/2-cuePixel/2 ...
    screenX/2+cueLengthHalf screenY/2+cuePixel/2];
param.cuePosiL = [screenX/2-cueLengthHalf screenY/2-cueSideLength/2 ...
    screenX/2-cueLengthHalf+cuePixel screenY/2+cueSideLength/2];
param.cuePosiR = [screenX/2+cueLengthHalf-cuePixel screenY/2-cueSideLength/2 ...
    screenX/2+cueLengthHalf screenY/2+cueSideLength/2];

%% Scrambled face masks
% randomly assign maskID for each trial
maskID = num2cell(mod(randperm(param.tn)-1, length(param.masks))+1);
[param.ed.maskID] = maskID{:};
param.maskDestRect = faceCenter;

end