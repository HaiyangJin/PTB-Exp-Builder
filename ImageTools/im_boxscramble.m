function [imScrambled, imScrmAlpha] = im_boxscramble(imMatrix, imAlpha, widthPatch, heightPatch)
% [imScrambled, imScrmAlpha] = im_boxscramble(imMatrix, imAlpha, widthPatch, heightPatch)
%
% This function generates the box scrambled image matrix.
%
% Inputs:
%     imMatrix      <numeric array> image matrix.
%     imAlpha       <numeric array> alpha matrix. Default is [].
%     widthPatch    <integer> the width of the patch. Default is 1.
%     heightPatch   <integer> the height of the patch. Default is 1.
%
% Output:
%     imScrambled   <numeric array> box scrambled image matrix.
%     imScramAlpha  <numeric array> box scrambled alpha layer.
%
% Created by Haiyang Jin (11-Aug-2020)

if ~exist('widthPatch', 'var') || isempty(widthPatch)
    widthPatch = 1;
end

if ~exist('heightPatch', 'var') || isempty(heightPatch)
    heightPatch = 1;
end

% replcate the matrix to 3 layers (in the third dimention) if it is not
imSize = size(imMatrix);
if numel(imSize) == 2
    imMatrix = repmat(imMatrix, 1, 1, 3);
    imSize = size(imMatrix);
end

% the number of patch along x and y axis
nXPatch = imSize(2) / widthPatch;
nYPatch = imSize(1) / heightPatch;

% Reformat the matrix (and alpha) to cell (each cell element is one patch)
yCell = repmat(widthPatch, 1, nXPatch);
xCell = repmat(heightPatch, 1, nYPatch);
tempMatrixCell = mat2cell(imMatrix(:,:,1), xCell, yCell);

% reshape the tempCell (and alpha) to one row and randomize it
rowMatrix = reshape(tempMatrixCell, 1, []);
randomSeq = randperm(length(rowMatrix));
randRowMatrix = rowMatrix(randomSeq);

% reshape the randCell (and alpha) back to the original format of cell
randMatixCell = reshape(randRowMatrix, nYPatch, nXPatch);

% convert cell to mat
imScrambled = cell2mat(randMatixCell);

%% Alpha layer
if exist('imAlpha', 'var') && ~isempty(imAlpha)
    % apply the same procedure to the alpha layer
    alphaCell = mat2cell(imAlpha, xCell, yCell);
    rowAlpha = reshape(alphaCell, 1, []);
    randRowAlpha = rowAlpha(randomSeq);
    randAlphaCell = reshape(randRowAlpha, nYPatch, nXPatch);
    imScrmAlpha = cell2mat(randAlphaCell);
else
    imScrmAlpha = [];
end

end