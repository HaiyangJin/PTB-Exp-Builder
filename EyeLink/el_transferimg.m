function param = el_transferimg(param)
% param = el_transferimg(param)
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
    if ~isfield(param, 'imgDir') || isempty(param.imgDir)
        param.transferDir = param.imgDir;
    else
        return
    end
elseif ischar(param.transferDir)
    % use relative path
    param.transferDir = im_dir(param.transferDir, [], [], 1); 
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
    param.transferDir = im_dir('TransferImg', 'bmp', [], 1);
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
transferStatus = Eyelink('ImageTransfer',imgfile,0,0,... imginfo.Filename
    imginfo.Width,imginfo.Height); % ,screenCenterX, screenCenterY,1
if transferStatus ~= 0
    fprintf('*****Image (%s) transfer Failed*****-------\n', ...
        imginfo.Filename);
end
% WaitSecs(0.1);

end % function transferimg