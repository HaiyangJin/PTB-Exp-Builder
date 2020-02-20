function im_writedir(stimDir, imgExt, outputPath)
% im_writedir(stimDir, imgExt, outputPath)
%
% This function write image directory into image files with specific image
% file type.
%
% Inputs:
%     stimDir           <structure> stimulus structure [generated by
%                       im_readdir].
%     imgExt            <string> image extensions. if isempty, images will
%                       be saved as their original formats.
%     outputPath        <string> the path to the output folder
%
% Output:
%     creat images in the outputPath
%
% Created by Haiyang Jin (20-Feb-2020)

% if imgExt is empty, images will be saved in their original formats
if nargin < 2 || isempty(imgExt)
    imgExt = '';
    newExt = false;
else
    newExt = true;
    
    % add point to the extention if necessary
    if ~strcmp(imgExt(1), '.')
        imgExt = ['.' imgExt];
    end
end

% creat the default output folder
if nargin < 3 || isempty(outputPath)
    outputPath = fullfile(pwd, 'newimages');
end

% creat the output folder (and its subfolders)
if isfield(stimDir, 'condition')
    subFolders = unique({stimDir.condition});
    subFolders(strcmp(subFolders, 'main')) = [];
    tempFolders = fullfile(outputPath, subFolders);
    isSub = true;
else
    tempFolders = {outputPath};
    isSub = false;
end

% creat the folder and subfolders
cellfun(@mkdir, tempFolders);

% number of images to be written
nImg = numel(stimDir);

for iImg = 1:nImg
    
    % structure for this image
    thisImg = stimDir(iImg);
    
    % add new extension if needed
    if newExt
        [~, f, ~] = fileparts(thisImg.filename);
        thisFn = [f imgExt];
    else
        thisFn = thisImg.filename;
    end
    
    % add subfolders to the path
    if isSub && ~strcmp(thisImg.condition, 'main')
        thisPath = fullfile(outputPath, thisImg.condition);
    else
        thisPath = outputPath;
    end
    
    % write the image
    imwrite(thisImg.matrix, fullfile(thisPath, thisFn));
    
end

end