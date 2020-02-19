function imTexture = ptb_mktexture(window, imMatrix)
% imTexture = ptb_mktexture(window, imMatrix)
%
% This function makes texture for the image.
%
% Inputs:
%     window        <numeric> the window index in PTB
%     imMatrix      <matrix of numeric> the image matrix
%
% Output:
%     imTexture     <numeric> the texture index for the image
%
% Created by Haiyang Jin (19-Feb-2020)

% create the texture
imTexture = Screen('MakeTexture', window, imMatrix);

end