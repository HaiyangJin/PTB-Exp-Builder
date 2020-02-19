function imTexture = im_mktexture(window, imMatrix)
% imTexture = im_mktexture(window, imMatrix)
%
% This function uses ptb_mktexture to make texture if window is not empty.
%
% Inputs:
%     window        <numeric> the window index in PTB
%     imMatrix      <matrix of numeric> the image matrix
%
% Output:
%     imTexture     <numeric> the texture index for the image
%
% Created by Haiyang Jin (19-Feb-2020)

% stop if window is empty
if nargin < 1 || isempty(window)
    imTexture = '';
    return;
end

% create texture
imTexture = ptb_mktexture(window, imMatrix);

end