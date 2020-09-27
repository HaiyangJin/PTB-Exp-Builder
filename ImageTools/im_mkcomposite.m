function compStimDir = im_mkcomposite(stimDir, gapPixels, gapColor)
% compStimDir = im_mkcomposite(stimDir, gapPixels, gapColor)
%
% Create composite stimuli by combining the top and bottom halves of
% stimuli in the same group.
%
% Inputs:
%    stimDir      <structure> stimulus structure created by im_dir and
%                  im_readdir.
%    gapPixels    <integer> pixels used for the gap between top and bottom
%                  halves. Default is 3.
%    gapColor     <integer vector> 1X3 vector. Default is [255, 255, 255],
%                  i.e., white.
%
% Output:
%    compStimDir   <structure> the output stimulus structure. It can be
%                   used to save the composite stimuli with im_writedir.
%
% Created by Haiyang Jin (27-Sept-2020)

% % Example:
% imDir = im_dir('CF_LineFaces', 'png');
% stimDir = im_readdir(imDir);
% compStimDir = im_mkcomposite(stimDir);
% im_writedir(compStimDir);

if ~exist('gapPixels', 'var') || isempty(gapPixels)
    gapPixels = 3;
end

if ~exist('gapColor', 'var') || isempty(gapColor)
    gapColor = [255, 255, 255];
end

% group information
groups = {stimDir.condition};
groupList = unique(groups);
nGroup = numel(groupList);

groupStimCell = cell(nGroup, 1);

% Create composite stimuli within each group
for iGroup = 1:nGroup
    
    % dir for this group
    thisGroup = groupList{iGroup};
    isThisGroup = ismember(groups, thisGroup);
    groupDir = stimDir(isThisGroup);
    
    % create all combinations
    halfComb = nchoosek(1:numel(groupDir), 2);
    combinations = [halfComb; halfComb(:, [2, 1])];
    
    nComb = size(combinations, 1);
    tempGroupCell = cell(nComb, 1);
    
    for iComb = 1:nComb
        
        % information about this group
        thisComb = combinations(iComb, :);
        [~, tempFn1, ext] = fileparts(groupDir(thisComb(1)).fn);
        [~, tempFn2] = fileparts(groupDir(thisComb(2)).fn);
        
        % save the corresponding fields
        temp = struct;
        temp.fn = sprintf('%s_%s%s', tempFn1, tempFn2, ext);
%         temp.foler = fullfile(outPath, thisCond);
        temp.condition = thisGroup;
        
        % save the matrix for composite stimuli
        [stimX, stimY, nLayer] = size(groupDir(thisComb(1)).matrix);
        halfXIndex = floor(stimX/2);
        
        composite_matrix = NaN(stimX+gapPixels, stimY, nLayer);
        % create composite stimuli for each layer separately
        for iLayer = 1:nLayer
            composite_matrix(:, :, iLayer) = vertcat(groupDir(thisComb(1)).matrix(1:halfXIndex, :, iLayer), ...
                ones(gapPixels, stimY) * gapColor(iLayer), ...
                groupDir(thisComb(2)).matrix(halfXIndex+1 : stimX, :, iLayer));
        end
        temp.matrix = composite_matrix;
        
        % save alpha if it is available
        if isfield(groupDir(thisComb(1)), 'alpha')
            temp.alpha = vertcat(groupDir(thisComb(1)).alpha(1:halfXIndex, :), ...
                ones(gapPixels, stimY) * 255, ...
                groupDir(thisComb(2)).alpha(halfXIndex+1 : stimX, :));
        end
        
        % save the structure for this combination/composite stimulus
        tempGroupCell{iComb, 1} = temp;
        
    end
    
    % save structure for this group
    groupStimCell{iGroup, 1} = vertcat(tempGroupCell{:}); 

end

% save the stim dir for all composite stimuli
compStimDir = vertcat(groupStimCell{:});

end