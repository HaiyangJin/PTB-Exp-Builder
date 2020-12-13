function compStimDir = im_mkcomposite(stimDir, groupFn, misalignPx, gapPx, gapExtra, gapColor)
% compStimDir = im_mkcomposite(stimDir, gapPixels, gapColor)
%
% Create composite stimuli by combining the top and bottom halves of
% stimuli in the same group.
%
% Inputs:
%    stimDir      <structure> stimulus structure created by im_dir and
%                  im_readdir.
%    groupFn      <string> group fieldname to divide the faces into groups.
%                  Default is '' (i.e., only one group for all faces).
%    misalignedPx <integer> the size (in pixels) of misaligned. Positive
%                  number refers to misalignment to right; negative is to
%                  the left. Default is the half of the stim width to the
%                  right (and the aligned images).
%    gapPx        <integer> pixels used for the gap between top and bottom
%                  halves. Default is 3.
%    gapExtra     <numeric> the width of the gap line. Default is one
%                  quarter of the face width (for each side).
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

if ~exist('groupFn', 'var') || isempty(groupFn)
    groupFn = '';
end

if ~exist('misalignPx', 'var') || isempty(misalignPx)
    misalignPx = size(stimDir(1).matrix, 2)/2;
end

if ~exist('gapPx', 'var') || isempty(gapPx)
    gapPx = 3;
end

if ~exist('gapExtra', 'var') || isempty(gapExtra)
    gapExtra = size(stimDir(1).matrix, 2)*.25;

if ~exist('gapColor', 'var') || isempty(gapColor)
    gapColor = [255, 255, 255];
end

% group information
if isempty(groupFn)
    groupFn = 'tempgroup';
    onegroup = repmat({'onegroup'}, length(stimDir), 1);
    [stimDir.(groupFn)] = onegroup{:};
end
groups = {stimDir.(groupFn)};
groupList = unique(groups);
nGroup = numel(groupList);

misalignment = [0, misalignPx];
nAlign = numel(misalignment);

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
    tempGroupCell = cell(nComb, nAlign);
    
    for iComb = 1:nComb
        
        % information about this group
        thisComb = combinations(iComb, :);
        [~, tempFn1, ext] = fileparts(groupDir(thisComb(1)).fn);
        [~, tempFn2] = fileparts(groupDir(thisComb(2)).fn);
        
        % save the corresponding fields
        temp = struct;
        %         temp.foler = fullfile(outPath, thisCond);
        temp.condition = thisGroup;
        
        % save the matrix for composite stimuli
        [stimX, stimY, nLayer] = size(groupDir(thisComb(1)).matrix);
        halfXIndex = floor(stimX/2);
        
        % initialize a image matrix for one layer
        compMatrix = ones(halfXIndex, stimY+misalignPx*2+gapExtra*2)*255;
        
        for iAli = 1:nAlign
                       
            % misalign size in pixel for this image
            misalign = misalignment(iAli);
            
            if misalign == 0; misStr = 'ali'; else; misStr = 'mis'; end
            temp.fn = sprintf('%s_%s_%s%s', tempFn1, tempFn2, misStr, ext);
            
            composite_matrix = NaN(stimX+gapPx, stimY+misalignPx*2+gapExtra*2, nLayer);
            
            % create composite stimuli for each layer separately
            for iLayer = 1:nLayer
                topHalf = compMatrix;
                bottomHalf = compMatrix;
                
                topHalf(:, misalignPx+gapExtra+(1:stimY)) = groupDir(thisComb(1)).matrix(1:halfXIndex, :, iLayer);
                gapLine = ones(gapPx, stimY+misalignPx*2+gapExtra*2) * gapColor(iLayer);
                bottomHalf(:, misalignPx+gapExtra+misalign+(1:stimY)) = groupDir(thisComb(2)).matrix(halfXIndex+1 : stimX, :, iLayer);
                
                composite_matrix(:, :, iLayer) = vertcat(topHalf, gapLine, bottomHalf);
            end
            temp.matrix = composite_matrix;
            
            % save alpha if it is available
            if isfield(groupDir(thisComb(1)), 'alpha')
                topHalf = compMatrix*0;
                bottomHalf = compMatrix*0;
                
                topHalf(:, misalignPx+gapExtra+(1:stimY)) = groupDir(thisComb(1)).alpha(1:halfXIndex, :);
                gapLine = ones(gapPx, stimY+misalignPx*2+gapExtra*2) * 255;
                bottomHalf(:, misalignPx+gapExtra+misalign+(1:stimY)) = groupDir(thisComb(2)).alpha(halfXIndex+1 : stimX, :);
                
                temp.alpha = vertcat(topHalf, gapLine, bottomHalf);
            end
            
            % save the structure for this combination/composite stimulus
            tempGroupCell{iComb, iAli} = temp;
            
        end
        
    end
    
    % save structure for this group
    groupStimCell{iGroup, 1} = vertcat(tempGroupCell{:});
    
end

% save the stim dir for all composite stimuli
compStimDir = vertcat(groupStimCell{:});

end