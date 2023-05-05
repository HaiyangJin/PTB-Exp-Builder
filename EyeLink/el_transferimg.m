function el_transferimg(param)
% el_transferimg(param)
%
% Transfer images to Eyelink/host, which will be used in 'IMGLOAD' later:
% e.g., Eyelink('Message', '!V IMGLOAD CENTER...). By default, it will
% transfer all images in param.imgDir. If {param.transferDir} is char, it
% will be treated as a directory and all images in this directory will be
% transfered to the host PC.
%
% Inputs:
%    param       experiment parameters.
%
% Created by Haiyang Jin (2023-May-5)

if ~isfield(param, 'transferDir') || isempty(param.transferDir)
    param.transferDir = param.imgDir;
elseif ischar(param.transferDir)
    % it is better to use relative path
    param.transferDir = im_dir(param.transferDir); 
end

% save the to-be-transfered images as *.bmp if they are not
% (the transparent layer will not be saved.)
isbmp = cellfun(@(x) endsWith(x, '.bmp'), {param.transferDir.name});
if ~all(isbmp)
    % load the images
    imgdir = im_readdir(param.transferDir);
    % save the image as *.bmp
    im_writedir(imgdir, 'TransferImg', 'matrix', 'bmp');
    % re-dir the TransferImg
    param.transferDir = im_dir('TransferImg', 'bmp');
end

% transfer all images
cellfun(@transferimg, ...
    fullfile({param.transferDir.folder}, {param.transferDir.name}));

end % function el_transferimg

function transferimg(imgfile)
% transfer single image to Host PC
imginfo=imfinfo(imgfile);

% image file should be 24bit or 32bit bitmap
% parameters of ImageTransfer:
% (imagePath, xPosition, yPosition, width, height, 
% trackerXPosition, trackerYPosition, xferoptions)
transferStatus = Eyelink('ImageTransfer',imginfo.Filename,0,0,...
    imginfo.Width,imginfo.Height); % ,screenCenterX, screenCenterY,1
if transferStatus ~= 0
    fprintf('*****Image (%s) transfer Failed*****-------\n', ...
        imginfo.Filename);
end
% WaitSecs(0.1);

end % function transferimg