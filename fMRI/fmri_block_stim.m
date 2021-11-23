function [param, stimuli] = fmri_block_stim(param, stimuli)
% load stimulus information for composite face task.
%
% Input:
%     param           <struct> parameters of the exp.
%     stimuli         <struct> stimulus structure.
%
% Output:
%     param           <struct> parameters of the exp.
%     stimuli         <struct> stimulus structure.
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
    nImgPerBlock * param.nRepetition)), 1:size(stimuli, 2), 'uni', false);
imageMat = horzcat(imageCell{:});

% divide the images of the same category into different blocks
blockCode = transpose(ceil((1:size(imageMat, 1))/nImgPerBlock));
blockCell = arrayfun(@(x) imageMat(blockCode==x, :), unique(blockCode), 'uni', false);

% empty cell for saving stimulus design
stimCell = cell(size(blockCell));

% generate same trials for each repetition separately
for iRepeat = 1:param.nRepetition
    
    thisStim = blockCell{iRepeat};
    
    % which images will be repeated (i.e., the "same" images for 1-back)
    sameCell = arrayfun(@(x) transpose(randperm(size(thisStim, 1), ...
        param.nSamePerBlock)), 1:size(thisStim, 2), 'uni', false);
    
    % combine the "same" code with the stimulus code (all stimuli)
    stimCode = vertcat(horzcat(sameCell{:}), transpose(repmat(1:nImgPerBlock, param.nStimCat, 1)));
    
    % code array for images
    codeCell = arrayfun(@(x) sort(stimCode(:, x)), 1:param.nStimCat, 'uni', false);
    codeArray = horzcat(codeCell{:});
    
    % stimulus matrix for each trial
    [rowTemp, colTemp] = ndgrid(1: size(codeArray, 1), 1: size(codeArray, 2));
    stimArray = arrayfun(@(x, y) thisStim(codeArray(x, y), y), rowTemp, colTemp);
    
    stimCell(iRepeat, 1) = {stimArray};
    
end

% the order of stimuli for each block
param.stimCell = stimCell;

%% Preload videos if applicable
% note that the preloading video only works if the number of vidoes is less
% than 100.
if isfield(param, 'isim') && param.isim == 0

    % create the necessary filenames
    stimuli(1,1).movieptr = [];
    stimuli(1,1).duration = [];
    stimuli(1,1).fps = [];
    stimuli(1,1).imgX = [];
    stimuli(1,1).imgY = [];
    stimuli(1,1).count = [];

    for iCat = 1:size(stimuli, 2)
        for iStim = 1:size(imageMat, 1)

            stimuli(imageMat(iStim, iCat), iCat) = ptb_openmovie( ...
                stimuli(imageMat(iStim, iCat), iCat), param.w);

        end % iStim
    end % iCat

    %%%%%%% Testing one video before main exp %%%%%%%
    % to avoid unknown delay in the main exp if these parts of codes are
    % not included.
    % play video
    tmp = ptb_openmovie(stimuli(1,1), param.w);
    Screen('PlayMovie', tmp.movieptr, 1, 0);

    while 1
        % Wait for next movie frame, retrieve texture handle to it
        tex = Screen('GetMovieImage', param.w, tmp.movieptr);

        % Valid texture returned? A negative value means end of movie reached:
        if tex<=0
            % We're done, break out of loop:
            break;
        end

        % Draw the new texture immediately to screen:
        Screen('DrawTexture', param.w, tex);

        % Update display:
%         Screen('Flip', param.w);

        % Release texture:
        Screen('Close', tex);
    end
    % Stop playback:
    Screen('PlayMovie', tmp.movieptr, 0);
    Screen('Flip', param.w);

end % if needed to preload stimuli

end