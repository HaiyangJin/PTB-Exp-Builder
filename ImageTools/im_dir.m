function imgDir = im_dir(imgPath, imgExt, reformat)
% imgDir = im_dir(imgPath, imgExt)
%
% This function get the directory information of all the images matching the
% image extension in the imgPath and its subfolders.
%
% Inputs:
%     imgPath      <strings> the path to the sitmuli folder
%     imgExt       <strings> or <a cell of strings> the file extentions of
%                   the images.
%     reformat     <logical> if true, imgDir will be reformat to multiple
%                   columns and each column is one condition (folder). By
%                   default reformat is false.
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
    imgExt = {''};
elseif ischar(imgExt)
    imgExt = {imgExt};
end

if nargin < 3 || isempty(reformat)
    reformat = 0; % by deafult do not reformat imgDir
end

%% dir information in the imgPath folder
mainDir = dir_img(imgPath);

% image files matching imgExt in the imgPath
isExt = endsWith({mainDir.name}, imgExt);

mainImgDir = dir_imgcond(mainDir(isExt), 'main');


%% dir information in the subfolders
% the subfolder names
subNames = {mainDir([mainDir.isdir]).name};
subPath = fullfile(imgPath, subNames);

[tempPath, tempExt] = ndgrid(subPath, imgExt);
subDir = cellfun(@(x, y) dir_img(fullfile(x, ['*' y])), tempPath(:), tempExt(:), 'uni', false);

% add the condition names
tempName = ndgrid(subNames, imgExt);
subImgDir = cellfun(@(x, y) dir_imgcond(x, y), subDir, tempName(:), 'uni', false);


%% coombine all dir together
isEmpty = cellfun(@isempty, subImgDir);
subImgDir(isEmpty) = [];

if ~isempty(mainImgDir)
    imgDir = vertcat(mainImgDir, subImgDir{:});
else
    imgDir = vertcat(subImgDir{:});
end

% error if there is no image files
if size(imgDir) == 0
    error('There are no image files in folder ''%s''.', imgPath);
end

%% reformat the dir (if reformat)
if reformat
    % reformat stimuli structure by group (condition) names
    tempDir = cellfun(@(x) imgDir(strcmp({imgDir.condition}, x)), ...
        unique({imgDir.condition}), 'uni', false);
    imgDir = [tempDir{:}];
end
    
end


function thisDir = dir_img(thisPath)
% dir the path and remove the hidden files

theDir = dir(thisPath);
% remove the "hidden" files or folders
theDir(cellfun(@(x) strcmp(x(1), '.'), {theDir.name})) = [];
theDir(cellfun(@(x) startsWith(x, 'Icon'), {theDir.name})) = [];

thisDir = theDir;

end


function thisDir = dir_imgcond(thisDir, condName)
% add condition names to the dir

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