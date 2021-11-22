function imTexture = im_mktexture(window, X, alpha)
% imTexture = im_mktexture(window, X, alpha)
%
% This function uses ptb_mktexture to make texture if window is not empty.
%
% Inputs:
%     window        <int> the window index in PTB.
%     X             <num array> the image matrix.
%     alpha         <num mat> the alpha layer. Default is [].
%
% Output:
%     imTexture     <int> the texture index for the image
%
% Created by Haiyang Jin (19-Feb-2020)

% stop if window is empty
if ~exist('window', 'var') || isempty(window)
    imTexture = '';
    return;
end

if ~exist('alpha', 'var') || isempty(alpha)
    alpha = [];
end

% create texture
imTexture = ptb_mktexture(window, cat(3, X, alpha));

end