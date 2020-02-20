function trimMatrix = im_trim(imMatrix, backColor)
% trimMatrix = im_trim(imMatrix, backColor)
%
% This function remove the rows and columns which only contains the
% background color.
%
% Inputs:
%     imMatrix        <matrix of numeric> image matrix
%     backColor       <numeric> the value of background color
%
% Output:
%     trimMatrix      <matrix of numeric> the trimmed image matrix
%
% Created by Haiyang Jin (20-Feb-2020)

% the default background color is white
if nargin < 2 || isempty(backCorlor)
    backColor = 255;
end

% the logical array of if is not backgorund color
isFore = arrayfun(@(x) backColor ~= x, imMatrix);

% logical vector for x and y 
isForeX = logical(sum(isFore, 2));
isForeY = logical(sum(isFore));

% only keep the non-background parts
trimMatrix = imMatrix(isForeX, isForeY);

end