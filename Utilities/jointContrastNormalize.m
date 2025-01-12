function [normImages,fractionPixelsClipped] = jointContrastNormalize(inputImages,clipCutoff)
% jointContrastNormalize - jointly normalizes the contrast for a set of images
%
% normImages = jointContrastNormalize(inputImages,clipCutoff)
% jointly normalizes contrast and mean luminance to be the same
% across all input images.
%
% Input:
%   inputImages: cell array with images to be normalized
%   clipCutoff: cutoff for clipping extreme values, in standard deviations
%               from the mean - default; 2
%
% Output:
%   normImages: cell array with the normalized images with luminance values in [0,1]
%   fractionPixelsClipped: vector with fraction of pixels clipped for each
%                          of the input images

% Copyright (C) 2020 by Dirk Bernhardt-Walther 
% (bernhardt-walther@psych.utoronto.ca)
% For details please see (and cite):
% Sabrina Perfetto, John Wilder, and Dirk B. Walther (2020) 
% Effects of spatial frequency filtering choices on the perception 
% of filtered images, Vision 2020, 4(2), 29; https://doi.org/10.3390/vision4020029


% cutoff for clipping extreme values
if nargin < 2
    clipCutoff = 2; % standard deviations from the mean
end

% pre-compute z scores and min and max
numImg = length(inputImages);
grandMin = 0;
grandMax = 0;
fractionPixelsClipped = NaN(size(inputImages));
for im = 1:numImg
    % z-score images
    inputImages{im} = (inputImages{im} - mean(inputImages{im}(:))) / std(inputImages{im}(:),1);
    
    % apply cutoffs
    negCutoffs = (inputImages{im} < -clipCutoff);
    posCutoffs = (inputImages{im} >  clipCutoff);
    inputImages{im}(negCutoffs) = -clipCutoff;
    inputImages{im}(posCutoffs) =  clipCutoff;
    fractionPixelsClipped(im) = (sum(negCutoffs(:)) + sum(posCutoffs(:))) / numel(negCutoffs(:));
    
    % rescale with std due to clipping
    inputImages{im} = inputImages{im} / std(inputImages{im}(:),1);
    
    % compute min and max
    grandMin = min(grandMin,min(inputImages{im}(:)));
    grandMax = max(grandMax,max(inputImages{im}(:)));
end

% compute normalized images
normImages = cell(size(inputImages));
for im = 1:numImg
    normImages{im} = (inputImages{im} - grandMin) / (grandMax - grandMin);
end
