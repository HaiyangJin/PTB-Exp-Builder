function stimuli = ptb_dirstim(stimPath, stimExt)
% This function get the directory information of all the stimuli matching the
% stimulus extension in the stimPath and its subfolders.
%
% Inputs:
%     stimPath      <strings> the path to the sitmuli folder
%     stimExt       <strings> or <a cell of strings> the file extentions of
%                   the images.
% Output:
%     stimuli       <structure> the dir structure with condition name. The 
%                   names of subfolders will be the condition names for the
%                   images in those subfolders. 'main' will be the 
%                   condition name for images in stimPath. 
%
% Created by Haiyang Jin (03-Feb-2020)

if nargin < 1 || isempty(stimPath)
    stimPath = fullfile('stimuli', filesep);
end

if nargin < 2 || isempty(stimExt)
    stimExt = {'png'};
elseif ischar(stimExt)
    stimExt = {stimExt};
end

%% dir information in the stimPath folder
mainDir = dir(stimPath);
% remove the "hidden" files or folders
mainDir(cellfun(@(x) strcmp(x(1), '.'), {mainDir.name})) = [];

% stimuli files matching StimExt in the stimPath
isExt = endsWith({mainDir.name}, stimExt);

mainStimDir = dirstim(mainDir(isExt), 'main');


%% dir information in the subfolders
% the subfolder names
subNames = {mainDir([mainDir.isdir]).name};
subPath = fullfile(stimPath, subNames);

[tempPath, tempExt] = ndgrid(subPath, stimExt);
subDir = cellfun(@(x, y) dir(fullfile(x, ['*' y])), tempPath(:), tempExt(:), 'uni', false);

tempName = ndgrid(subNames, stimExt);
subStimDir = cellfun(@(x, y) dirstim(x, y), subDir, tempName(:), 'uni', false);


%% coombine all dir together
isEmpty = cellfun(@isempty, subStimDir);
subStimDir(isEmpty) = [];

if ~isempty(mainStimDir)
    stimuli = vertcat(mainStimDir, subStimDir{:});
else
    stimuli = vertcat(subStimDir{:});
end

end


function thisDir = dirstim(thisDir, condName)

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