function param = cf_stim(param, stimuli)
% load stimulus information for composite face task.
%
% Input:
%     param           <structure> parameters of the exp
%     stimuli         <structure> stimulus structure
%
% Output:
%     param           <structure> parameters of the exp

screenRect = param.screenRect;

% stimulus dimentions
[faceY, faceX] = size(stimuli(1,1).matrix);
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
param.lineRect = [screenRect(3)/2-(3*misalignSize + (faceCenter(3)-faceCenter(1)))/2 ...
    screenRect(4)/2-1 ...
    screenRect(3)/2+(3*misalignSize+(faceCenter(3)-faceCenter(1)))/2 ...
    screenRect(4)/2+2];

end