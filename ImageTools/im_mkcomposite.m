function compStimDir = im_mkcomposite(stimDir, varargin)
% compStimDir = im_mkcomposite(stimDir, ...)
%
% Create composite stimuli by combining the top and bottom halves of
% stimuli in the same group.
%
% Inputs:
%    stimDir      <structure> stimulus structure created by im_dir and
%                  im_readdir.
%
% Varargin:
%    groupfn      <string> group fieldname to divide the faces into groups.
%                  Default is '' (i.e., only one group for all faces).
%    misratio     <numeric> the size (in pixels) of misaligned. Positive
%                  number refers to misalignment to right; negative is to
%                  the left. If misratio is from -1 to 1, the misalignment
%                  will be stim width times misratio. If the absolute value
%                  of misratio is larger than 1, the misalignment will be
%                  misratio. Default is 0.5, i.e., the half of the stim
%                  width to the right (and the aligned images).
%    cuedhalf     <integer> which half is the cued half; the cued half will
%                  remain in the center of image. 1: top; 2: bottom; 3:
%                  both 1 and 2. Default is 1.
%    gappx        <integer> pixels used for the gap between top and bottom
%                  halves. Default is 3.
%    gapextra     <numeric> the width of the gap line. gapextra can only be
%                  postive. Its usage is similar to misratio. Default is
%                  0.25, i.e., one quarter of the face width (for each side).
%    gapcolor     <integer vector> 1X3 vector. Default is [255, 255, 255],
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

defaultOpts = struct();
defaultOpts.groupfn = '';
defaultOpts.misratio = 0.5;
defaultOpts.cuedhalf = 1;
defaultOpts.gappx = 3;
defaultOpts.gapextra = 0.25;
defaultOpts.gapcolor = [255, 255, 255];

opts = ptb_mergestruct(defaultOpts, varargin{:});

stimWidth = size(stimDir(1).matrix, 2);
groupFn = opts.groupfn;
if abs(opts.misratio) < 1
    misalignPx = stimWidth * opts.misratio;
else
    misalignPx = opts.misratio;
end
if opts.cuedhalf == 3
    cuedHalf = [1, 2];
else
    cuedHalf = opts.cuedhalf;
end
gapPx = opts.gappx;
if abs(opts.gapextra) < 1
    gapExtra = stimWidth * opts.gapextra;
else
    gapExtra = opts.gapextra;
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

cueStr = {'top', 'bot'};

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
    tempGroupCell = cell(nComb, nAlign, numel(cuedHalf));
    
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
                        
            composite_matrix = NaN(stimX+gapPx, stimY+misalignPx*2+gapExtra*2, nLayer);
            
            for iCue = cuedHalf
                
                temp.fn = sprintf('%s_%s_%s_%s%s', cueStr{iCue}, tempFn1, tempFn2, misStr, ext);
                
                topPosi = misalignPx+gapExtra+(1:stimY) + misalign * (iCue-1);
                bottomPosi = misalignPx+gapExtra+(1:stimY) + misalign * (2-iCue);
                
                % create composite stimuli for each layer separately
                for iLayer = 1:nLayer
                    topHalf = compMatrix;
                    bottomHalf = compMatrix;
                    
                    topHalf(:, topPosi) = groupDir(thisComb(1)).matrix(1:halfXIndex, :, iLayer);
                    gapLine = ones(gapPx, stimY+misalignPx*2+gapExtra*2) * opts.gapcolor(iLayer);
                    bottomHalf(:, bottomPosi) = groupDir(thisComb(2)).matrix(halfXIndex+1 : stimX, :, iLayer);
                    
                    composite_matrix(:, :, iLayer) = vertcat(topHalf, gapLine, bottomHalf);
                end
                temp.matrix = composite_matrix;
                
                % save alpha if it is available
                if isfield(groupDir(thisComb(1)), 'alpha')
                    topHalf = compMatrix*0;
                    bottomHalf = compMatrix*0;
                    
                    topHalf(:,topPosi) = groupDir(thisComb(1)).alpha(1:halfXIndex, :);
                    gapLine = ones(gapPx, stimY+misalignPx*2+gapExtra*2) * 255;
                    bottomHalf(:, bottomPosi) = groupDir(thisComb(2)).alpha(halfXIndex+1 : stimX, :);
                    
                    temp.alpha = vertcat(topHalf, gapLine, bottomHalf);
                end

                % save the structure for this combination/composite stimulus
                tempGroupCell{iComb, iAli, iCue} = temp;
                
            end
            
        end
        
    end
    
    % save structure for this group
    groupStimCell{iGroup, 1} = vertcat(tempGroupCell{:});
    
end

% save the stim dir for all composite stimuli
compStimDir = vertcat(groupStimCell{:});

end