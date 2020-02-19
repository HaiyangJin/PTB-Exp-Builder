function stimDir = im_readdir(imgDir, window)
% stimDir = im_readdir(imgDir, window)
%
% This function read the images in imgDir (and make texture if window is
% not empty).
%
% Inputs:
%     imgDir        <structure> the image dir (generated by im_dir.m).
%     window        <numeric> the window index in PTB
%
% Output:
%     stimDir       <structure> the stimulus structure
%
% Created by Haiyang Jin (19-Feb-2020)

if nargin < 2 || isempty(window)
    window = '';
end

% number of images
nImage = numel(imgDir);

% load information for each image separately
for iImage = 1:nImage
    
    clear tmp
    
    tmp.filename = imgDir(iImage).name;
    tmp.folder = imgDir(iImage).folder;
    tmp.condition = imgDir(iImage).condition;
    
    % load images as different layers for different types of images
    [~, ~, imagetype] = fileparts(tmp.filename);
    switch imagetype(2:end)
        case 'png'
            [tmp.matrix, ~, tmp.alpha] = imread(fullfile(tmp.folder, tmp.filename));
            tmp.texture = im_mktexture(window, cat(3, tmp.matrix, tmp.alpha));
        case {'jpg', 'tif', 'bmp'}
            tmp.matrix = imread(fullfile(tmp.folder, tmp.filename));
            tmp.alpha = ''; % creat NaN array
            tmp.texture = im_mktexture(window, tmp.matrix);
        otherwise
            error('Please define the processing for %s. (You may wanna to contact the author)',...
                imagetype(2:end));
    end
    
    % save the info in stim_dir
    if iImage == 1
        stimDir = repmat(tmp, nImage, 1);
    else
        stimDir(iImage) = tmp;
    end
        
end

% remove the field names if all the values are empty
names = fieldnames(stimDir);
% the values of which filename is empty 
isRmove = cellfun(@(x) all(cellfun(@isempty, {stimDir.(x)})), names);

% trim stimDir
stimDir = rmfield(stimDir, names(isRmove));

end

