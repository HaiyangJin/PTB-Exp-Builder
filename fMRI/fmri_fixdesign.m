function fixBlockNum = fmri_fixdesign(nStimCat, nRepetition, nBtwFixBlock)
% fixBlockNum = fmri_fixdesign(nStimCat, nRepetition, nBtwFixBlock)
%
% This function generates the fixation block numbers based on different
% design used in the block fmri experiments.
%
% Inputs:
%     nStimCat           <int> the number of stimulus category.
%                     or <struct> the experiment parameters which include
%                         the fieldnames (nStimCat, nRepetition,
%                         nBtwFixBlock).
%     nRepetition        <int> how many times each stimulus category are
%                         repeated.
%     nBtwFixBlock       <int> which design is used to generates the
%                         fixation block numbers. 1
%
% Output:
%     fixBlockNum        <int vec> the block numbers of fixation blocks.
%
% Created by Haiyang (1-Mar-2020)

%% process inputs
% if nStimCat is structure 
if isstruct(nStimCat)

    if nStimCat.fixBloDuration == 0
        % return if the fixation block duration is 0
        fixBlockNum = [];
        return;
    end
    
    if isfield(nStimCat, 'nRepetition')
        nRepetition = nStimCat.nRepetition;
    else
        nRepetition = '';
    end
    
    if isfield(nStimCat, 'nBtwFixBlock')
        nBtwFixBlock = nStimCat.nBtwFixBlock;
    else
        nBtwFixBlock = '';
    end
    
    % convert nStimCat from structure to numeric
    nStimCat = nStimCat.nStimCat;
    
end

if ~exist('nRepetition', 'var') || isempty(nRepetition)
    nRepetition = 1;
end

if ~exist('nBtwFixBlock', 'var') || isempty(nBtwFixBlock)
    nBtwFixBlock = nStimCat;
end

%% Generate the fixation block numbers
% number of stimlus and fixation blocks
nStimBlock = nStimCat * nRepetition;
nFixBlock = (nStimBlock / nBtwFixBlock) + 1;

% throw warning if the last block is not a fixation block
if mod(nStimBlock, nBtwFixBlock)
    nFixBlock = floor(nFixBlock);
    warning('The last block is not a fixation block.');
end

% number of blocks in total
nBlocks = nStimBlock + nFixBlock;

% generate the fixation block numbers
fixBlockNum = 1:(nBtwFixBlock+1):nBlocks;
% fixBlockNum = [1, 1+(1:nRepetition) * (nBtwFixBlock + 1)];

end
