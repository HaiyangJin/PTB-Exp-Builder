function cmd = ptb_touch(source, target, istouch)
% cmd = ptb_touch(source, target, istouch)
%
% This function touches (or copies; links) files from source to targets. 
% This may be useful if the actual stimuli cannot be put in the target 
% folder (for saving space or copy right issues). 
% 
% The links (via istouch=2) created by this function does not seem to work 
% properly but they may serve to show the directory structure.
%
% Inputs:
%     source       <str> the source folder which stores stimuli and
%                   subfolders that stores stimuli.
%     target       <str> the target folder.
%     istouch      <boo> whether touch the files (default: 1) or copy (0);
%                   or link (2).
%
% Output:
%     cmd          <cell str> a list of commands using ln.
%
% Created by Haiyang Jin (2021-11-07)

assert(exist(source, 'dir'), '<source> should be a directory.');

if ~exist('target', 'var') || isempty(target)
    if endsWith(source, filesep); source = source(1:end-1); end
    [~, srcfolder] = fileparts(source);
    target = fullfile(source, '..', [srcfolder '_tmp']);
end

if ~exist('istouch', 'var') || isempty(istouch)
    istouch = 1;
end

% make the target folder
if logical(exist(target, 'dir')); rmdir(target, 's'); end
mkdir(target);

if istouch == 0
    % copy files
    cmd = {''};
    copyfile(source, target, 'f');
    return;
end

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
subtrgcell = cell(nsubf+1, 1);

% for each subfolder separately
for iSubf = 1:nsubf

    % this subfolder
    thesub = subfolders(iSubf);
    ptb_mkdir(fullfile(target, thesub.name));

    % find all files in the subfolder
    thedir = dir(fullfile(thesub.folder, thesub.name));
    thefiles = thedir([thedir.isdir]==0);

    % path to source and target
    subsrccell{iSubf, 1} = fullfile(source, thesub.name, {thefiles.name})';
    subtrgcell{iSubf, 1} = fullfile(target, thesub.name, {thefiles.name})';

end

% for files in source
subsrccell{nsubf+1, 1} = fullfile(source, {files.name})';
subtrgcell{nsubf+1, 1} = fullfile(target, {files.name})';

% combine all files in both main and subfolders
srccell = vertcat(subsrccell{:});
trgcell = vertcat(subtrgcell{:});

% remove existed target files
isexist = cellfun(@(x) logical(exist(x, 'file')), trgcell);
cellfun(@delete, trgcell(isexist));

% touch OR link and move files
switch istouch
    case 1
        % touch
        cmd = cellfun(@(x) sprintf('touch %s', x), ptb_2cmdpath(trgcell), 'uni', false);
        cellfun(@system, cmd);
    case 2
        % link
        cmd = cellfun(@(x,y) link_move(x, y), srccell, trgcell, 'uni', false);
end
end

function cmd = link_move(source, target)

[~, fn, ext] = fileparts(source);
sourcefn = [fn, ext];

% save linked files in the temporary folder
cmd = sprintf('ln -s %s %s', ptb_2cmdpath(source), ptb_2cmdpath(sourcefn));
system(cmd);

% move files from the temporary folders to the target folder
movefile(sourcefn, target);

end
