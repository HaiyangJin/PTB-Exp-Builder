function fileDir = im_dir(imgPath, imgExt, reformat)
% fileDir = im_dir(imgPath, imgExt, reformat)
%
% This function get the directory information of all the images matching the
% image extension in the imgPath and its subfolders.
%
% Inputs:
%     imgPath      <str> the path to the sitmuli folder
%     imgExt       <str> or <cell str> the file extentions of the images.
%     reformat     <boo> if true, fileDir will be re-formated to multiple
%                   columns and each column is one condition (folder). By
%                   default reformat is false.
% Output:
%     fileDir      <struct> the dir structure with condition name. The
%                   names of subfolders will be the condition names for the
%                   images in those subfolders. 'main' will be the
%                   condition name for images in imgPath.
%
% Created by Haiyang Jin (03-Feb-2020)
%
% See also:
% im_readdir, im_writedir, im_resizevd, im_writedirvd

if ~exist('imgPath', 'var') || isempty(imgPath)
    imgPath = fullfile('stimuli', filesep);
end

if ~exist('imgExt', 'var') || isempty(imgExt)
    imgExt = {''};
elseif ischar(imgExt)
    imgExt = {imgExt};
end

if ~exist('reformat', 'var') || isempty(reformat)
    reformat = 0; % by deafult do not reformat fileDir
end

%% dir information in the imgPath folder
mainDir = dir_img(imgPath);

% image files matching imgExt in the imgPath
isExt = endsWith({mainDir.name}, imgExt);

mainFileDir = dir_imgcond(mainDir(isExt), 'main');


%% dir information in the subfolders
% the subfolder names
subNames = {mainDir([mainDir.isdir]).name};
subPath = fullfile(imgPath, subNames);

[tempPath, tempExt] = ndgrid(subPath, imgExt);
subDir = cellfun(@(x, y) dir_img(fullfile(x, ['*' y])), tempPath(:), tempExt(:), 'uni', false);

% add the condition names
tempName = ndgrid(subNames, imgExt);
subFileDir = cellfun(@(x, y) dir_imgcond(x, y), subDir, tempName(:), 'uni', false);


%% coombine all dir together
isEmpty = cellfun(@isempty, subFileDir);
subFileDir(isEmpty) = [];

if ~isempty(mainFileDir)
    fileDir = vertcat(mainFileDir, subFileDir{:});
else
    fileDir = vertcat(subFileDir{:});
end

% error if there is no image files
if size(fileDir) == 0
    error('There are no image files in folder ''%s''.', imgPath);
end

%% reformat the dir (if reformat)
if reformat
    % reformat stimuli structure by group (condition) names
    tempDir = cellfun(@(x) fileDir(strcmp({fileDir.condition}, x)), ...
        unique({fileDir.condition}), 'uni', false);
    fileDir = horzcat(tempDir{:});
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