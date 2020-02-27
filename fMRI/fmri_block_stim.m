function param = fmri_block_stimdesign(param, stimuli)
% load stimulus information for composite face task.
%
% Input:
%     param           <structure> parameters of the exp
%     stimuli         <structure> stimulus structure
%
% Output:
%     param           <structure> parameters of the exp
%
% Created by Haiyang Jin (26-Feb-2020)

%% Sizes of images are different
% % screen dimenstions
% screenRect = param.screenRect;
% screenX = screenRect(3);
% screenY = screenRect(4);
%
% % stimulus dimentions
% [imgY, imgX, ~] = size(stimuli(1,1).matrix);
% param.stimY = imgY;
% param.stimX = imgX;
%
% % stimulus rect information
% param.imgRect = [0 0 imgX imgY];
%
% % stimulus positions
% param.stimPosition = CenterRect([0 0 imgX imgY], screenRect);


%% Stimuli
% number of images used in each block (minus repeated trials)
nImgPerBlock = param.nStimPerBlock - param.nSamePerBlock;

% random select all images for each category at the same time (for the whole run)
imageCell = arrayfun(@(x) transpose(ptb_randperm(size(stimuli, 1), ...
    nImgPerBlock * param.nRepeated)), 1:size(stimuli, 2), 'uni', false);
imageMat = horzcat(imageCell{:});

% divide the images of the same category into different blocks
blockCode = transpose(ceil((1:size(imageMat, 1))/nImgPerBlock));
blockCell = arrayfun(@(x) imageMat(blockCode==x, :), unique(blockCode), 'uni', false);

% empty cell for saving stimulus design
stimCell = cell(size(blockCell));

% generate same trials for each repetition separately
for iRepeat = 1:param.nRepeated
    
    thisStim = blockCell{iRepeat};
    
    % which images will be repeated (i.e., the "same" images for 1-back)
    sameCell = arrayfun(@(x) transpose(randperm(size(thisStim, 1), ...
        param.nSamePerBlock)), 1:size(thisStim, 2), 'uni', false);
    
    % combine the same code with the stimulus code (all stimuli)
    stimCode = vertcat(horzcat(sameCell{:}), transpose(repmat(1:nImgPerBlock, param.nCatStim, 1)));
    
    % code array for images
    codeCell = arrayfun(@(x) sort(stimCode(:, x)), 1:param.nCatStim, 'uni', false);
    codeArray = horzcat(codeCell{:});
    
    % stimulus matrix for each trial
    [rowTemp, colTemp] = ndgrid(1: size(codeArray, 1), 1: size(codeArray, 2));
    stimArray = arrayfun(@(x, y) thisStim(codeArray(x, y), y), rowTemp, colTemp);
    
    stimCell(iRepeat, 1) = {stimArray};
    
end

% the order of stimuli for each block
param.stimCell = stimCell;

end