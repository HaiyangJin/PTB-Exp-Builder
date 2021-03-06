function outStimDir = im_bscrambledir(stimDir, widthPatch, heightPatch, nPerStim, ...
    matrixFieldname, alphaFieldname)
% outStimDir = im_bscrambledir(stimDir, widthPatch, heightPatch, nPerStim, ...
%    matrixFieldname, alphaFieldname)
%
% This function generates the phase scrambled for the stimulus direcgtory.
%
% Inputs:
%     stimDir          <structure> stimulus structure [generated by
%                       im_readdir].
%     widthPatch       <integer> the width of the patch. Default is [].
%     heightPatch      <integer> the height of the patch. Default is [].
%     nPerStim         <integer> how many scrambled images will be created
%                       for each stimulus. Default is 1. 
%     matrixFieldname  <fieldname> the fieldname for the image  matrix.
%     alphaFieldname   <fieldname> the fieldname for the alpha layer matrix.
%
% Output:
%     outStimDir       <structure> stimulus structure [a new
%     fieldname .bsmatrix will be added.
%
% Created by Haiyang Jin (11-Aug-2020)
%
% See also:
% im_pscrambledir

if ~exist('widthPatch', 'var') || isempty(widthPatch)
    widthPatch = [];
end
if ~exist('heightPatch', 'var') || isempty(heightPatch)
    heightPatch = [];
end
if ~exist('nPerStim', 'var') || isempty(nPerStim)
    nPerStim = 1;
end
% obtain the cell of stimulus matrix
if ~exist('matrixFieldname', 'var') || isempty(matrixFieldname)
    matrixCell = {stimDir.matrix};
else
    matrixCell = {stimDir.(matrixFieldname)};
end

% obtain the cell of stimulus alpha matrix
if ~exist('alphaFieldname', 'var') || isempty(alphaFieldname)
    alphaFieldname = 'alpha';
end
if isfield(stimDir, alphaFieldname)
    alphaCell = {stimDir.(alphaFieldname)};
else
    alphaCell = cell(size(matrixCell));
end

tmpStimDir = stimDir;
outCell = cell(nPerStim, 1);

for iRound = 1:nPerStim
    
    % generated the phase scrambled matrix
    [scrambledCell, scraAlphaCell] = cellfun(@(x, y) im_boxscramble(x, y, widthPatch, heightPatch),...
        matrixCell, alphaCell, 'uni', false);
    
    % save the phase-scrambled matrix as a new fiedlname
    [tmpStimDir.bsmatrix] = deal(scrambledCell{:});
    if ~isempty(scraAlphaCell)
        [tmpStimDir.bsalpha] = deal(scraAlphaCell{:});
    end
    
    % save the round number
    roundCell = num2cell(ones(size(tmpStimDir))*iRound);
    [tmpStimDir.round] = deal(roundCell{:});
    
    % save the scrambled for this round
    outCell{iRound, 1} = tmpStimDir;
    
end

outStimDir = vertcat(outCell{:});

end