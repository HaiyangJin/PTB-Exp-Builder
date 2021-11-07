function cmd_link = ptb_linkfile(source, target, islink)
% cmd_link = ptb_linkfile(source, target, islink)
%
% This function links (or copy) files from source to targets. This may be
% useful if the actual stimuli cannot be put in the target folder (for
% saving space or copy right issues).
%
% Inputs:
%     source       <str> the source folder which stores stimuli and
%                   subfolders that stores stimuli. 
%     target       <str> the target folder.
%     islink       <boo> whether link the files (default: 1) or copy (0).
%
% Output:
%     cmd_link     <cell str> a list of commands using ln. 
%
% Created by Haiyang Jin (2021-11-07)

if ~exist('islink', 'var') || isempty(islink)
    islink = 1;
end

% make the target folder
ptb_mkdir(target);

% dir source 
assert(logical(exist(source, 'dir')), 'Cannot find %s...', source);
sourcedir = dir(source);
sourcedir(ismember({sourcedir.name}, {'.', '..'})) = [];

% identify folders and files
subfolders = sourcedir([sourcedir.isdir]);
files = sourcedir(~[sourcedir.isdir]);

nsubf = length(subfolders);

% empty cell for saving dirs
subsrccell = cell(nsubf+1, 1);
subtrgcell_link = cell(nsubf+1, 1);
subtrgcell_copy = cell(nsubf+1, 1);

% for each subfolder separately
for iSubf = 1:nsubf

    % this subfolder
    thesub = subfolders(iSubf);
    ptb_mkdir(fullfile(target, thesub.name));

    % find all files in the subfolder
    thedir = dir(fullfile(thesub.folder, thesub.name));
    thefiles = thedir([thedir.isdir]==0);

    % path to source and target 
    subsrccell{iSubf, 1} = fullfile({thefiles.folder}, {thefiles.name})';
    subtrgcell_link{iSubf, 1} = repmat({fullfile(target, thesub.name)}, numel({thefiles.name}), 1);
    subtrgcell_copy{iSubf, 1} = fullfile(target, thesub.name, {thefiles.name})';

end

% for files in source
subsrccell{nsubf+1, 1} = fullfile({files.folder}, {files.name})';
subtrgcell_link{nsubf+1, 1} = repmat({target}, numel({files.name}), 1);
if ~isempty(files)
    subtrgcell_copy{iSubf+1, 1} = fullfile(target, files.name);
end

% combine all files in both main and subfolders
srccell = vertcat(subsrccell{:});
trgcell_parent = vertcat(subtrgcell_link{:});
trgcell = vertcat(subtrgcell_copy{:});

% remove existed target files
isexist = cellfun(@(x) logical(exist(x, 'file')), trgcell);
cellfun(@delete, trgcell(isexist));


if islink
    % link files
    cmd_link = cellfun(@(x,y) sprintf('ln -s %s %s', x, y), srccell, trgcell_parent, 'uni', false);
    cellfun(@system, ptb_cleancmd(cmd_link));

else
    % copy files
    cmd_link = {''};
    cellfun(@(x,y) copyfile(x,y), srccell, trgcell, 'uni', false);

end

end
