function im_mat2png(imgMat, imgFilename)
% im_mat2png(imgMat, imgFilename)
%
% This function saves an image matrix as a png image.
%
% Inputs:
%    imgMat        <numeric array>
%    imgFilename   <string> the filename of the png file.
%
% Output:
%    a new png file.
%
% Created by Haiyang Jin (23-May-2020)

figure('Visible', 'off');
imshow(imgMat);

export_fig(imgFilename, '-png','-transparent','-m2');

end


