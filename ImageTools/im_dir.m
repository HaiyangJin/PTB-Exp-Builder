function imgDir = im_dir(imgPath, imgExt)
% This function get the directory information of all the images matching the
% image extension in the imgPath and its subfolders.
%
% Inputs:
%     imgPath      <strings> the path to the sitmuli folder
%     imgExt       <strings> or <a cell of strings> the file extentions of
%                   the images.
% Output:
%     imgDir       <structure> the dir structure with condition name. The 
%                   names of subfolders will be the condition names for the
%                   images in those subfolders. 'main' will be the 
%                   condition name for images in imgPath. 
%
% Created by Haiyang Jin (03-Feb-2020)

if nargin < 1 || isempty(imgPath)
    imgPath = fullfile('stimuli', filesep);
end

if nargin < 2 || isempty(imgExt)
    imgExt = {'png'};
elseif ischar(imgExt)
    imgExt = {imgExt};
end

%% dir information in the imgPath folder
mainDir = dir(imgPath);
% remove the "hidden" files or folders
mainDir(cellfun(@(x) strcmp(x(1), '.'), {mainDir.name})) = [];

% image files matching imgExt in the imgPath
isExt = endsWith({mainDir.name}, imgExt);

mainImgDir = dirimg(mainDir(isExt), 'main');


%% dir information in the subfolders
% the subfolder names
subNames = {mainDir([mainDir.isdir]).name};
subPath = fullfile(imgPath, subNames);

[tempPath, tempExt] = ndgrid(subPath, imgExt);
subDir = cellfun(@(x, y) dir(fullfile(x, ['*' y])), tempPath(:), tempExt(:), 'uni', false);

tempName = ndgrid(subNames, imgExt);
subImgDir = cellfun(@(x, y) dirimg(x, y), subDir, tempName(:), 'uni', false);


%% coombine all dir together
isEmpty = cellfun(@isempty, subImgDir);
subImgDir(isEmpty) = [];

if ~isempty(mainImgDir)
    imgDir = vertcat(mainImgDir, subImgDir{:});
else
    imgDir = vertcat(subImgDir{:});
end

end


function thisDir = dirimg(thisDir, condName)

% return if thisDir is empty
if isempty(thisDir)
    return;
end

% remove the dir for folders
thisDir([thisDir.isdir]) = [];  

% add condition name to the dir
tempCondName = repmat({condName}, numel(thisDir), 1);
[thisDir.condition] = tempCondName{:};

end