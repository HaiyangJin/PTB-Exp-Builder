function [param, stimOut] = prf_stim(param, stimIn)
% [param, stimOut] = prf_stim(param, stimIn)
%
% Input:
%     param           <struct> experiment structure.
%     stimIn          <struct> stimuli loaded by ptb_loadstimdir().
%
% Created by Haiyang Jin (2023-Feb-26)

%% Fake transparent image
% make a fake transparent image struct
transImg = stimIn(1);
transImg.fn = 'transparent.png';
transImg.condition = 'fixation';
transImg.matrix = ones(size(stimIn(1).matrix)) * .5; % a grey color 
transImg.alpha = zeros(size(stimIn(1).alpha));
% make texture
transImg.texture = ptb_mktexture(param.w, cat(3, transImg.matrix, transImg.alpha));

% make a block of fake transparent images
transBlock = repmat(transImg, param.nStimPerBlock, 1);

%% Images blocks
% generate stimlus cell for each Block/trial
imgCell = cell(param.tn, 1);

% for each block/trial separately
for ttn = 1:param.tn

    % randomly select stimuli for each block/trial
    thisAll = stimIn(:, param.ed(ttn).stimCategory);
    thisStim = thisAll(randperm(numel(thisAll), ...
        param.nStimPerBlock - param.nFixaEndPerBlock));

    % add fixation at the end
    imgCell{ttn, 1} = vertcat(thisStim, repmat(transImg, param.nFixaEndPerBlock,1)); 

end

%% Combine fixation and images
% obtain the trial numbers for fixations
param.imageBlockNum = sort(randperm(param.tn + param.fixBlockN, param.tn));
stimCell = repmat({transBlock}, param.tn + param.fixBlockN, 1);
stimCell(param.imageBlockNum) = imgCell;

% saveas struct
stimOut = horzcat(stimCell{:});

end