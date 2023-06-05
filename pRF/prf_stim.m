function param = prf_stim(param)
% param = prf_stim(param)
%
% Input:
%     param           <struct> experiment structure.
%
% Created by Haiyang Jin (2023-Feb-26)

stimIn = param.stimuli;
param.stimuli_orig = param.stimuli; % make a backup

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
imgCell = cell(param.bn, 1);

% for each block/trial separately
for ttn = 1:param.bn

    % randomly select stimuli for each block/trial
    thisAll = stimIn(:, param.ed(ttn).stimCategory);
    thisStim = thisAll(randperm(numel(thisAll), ...
        param.nStimPerBlock - param.nFixaEndPerBlock));

    % add fixation at the end
    imgCell{ttn, 1} = vertcat(thisStim, repmat(transImg, param.nFixaEndPerBlock,1)); 

end

%% Combine fixation and images
% obtain the trial numbers for fixations
% add dummy blocks and overrun blocks
param.imageBlockNum = sort(randperm(param.bn + param.fixBlockN, param.bn)) ...
    + param.fixBlockDummy;
param.tbn = param.bn + param.fixBlockN + param.fixBlockDummy + param.fixBlockOverrun;
stimCell = repmat({transBlock}, param.tbn, 1);
stimCell(param.imageBlockNum) = imgCell;

% saveas struct
param.stimuli = horzcat(stimCell{:});

%% Calculate stimulus size and positions
% use 1 degree as the conversion rate
pixelperva = ptb_va2pixel(1, param.distance, param.pipercm);
param.thispixelperva = pixelperva.pi;

facev = param.thispixelperva * param.facevva;
param.faceratio = facev/size(param.stimuli(1).matrix,1);

param.facebtw = round(param.thispixelperva * param.facebtw);

param.dotva = round(param.thispixelperva * param.dva);

%% Load letter images
if isfield(param, 'imgLetterDir')
    param.letterstimuli = ptb_loadstimdir(param.imgLetterDir, param.w);
    transImg.matrix = ones(size(param.letterstimuli(1).matrix)) * .5; % a grey color
    transImg.alpha = zeros(size(param.letterstimuli(1).alpha));
    param.letterstimuli(27) = transImg;
end

end