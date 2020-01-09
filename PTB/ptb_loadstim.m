function stimuli = ptb_loadstim(imagetype, window, stim_path)
% Load stimuli in the stim_path folder
%
% Input:
%    imagetype      image type (jpg, png...)
%    
%    stim_path      the path to the stimuli folder
% Output:
%    stimuli        stimuli structure
%
% Created by Haiyang Jin (9-Jan-2020)

if nargin < 3 || isempty(stim_path)
    stim_path = fullfile(pwd, 'stimuli');
end

% list all files and folders
all_dir = dir(stim_path);


%% files
file_dir = dir(fullfile(stim_path, ['*' imagetype]));

stim_str = load_imagedir(file_dir, window);


%% subfolders
folder_dir = all_dir;

% remove files in dir
folder_dir([folder_dir.isdir] == 0) = [];
% remove supradirectory
folder_dir(startsWith({folder_dir.name}, '.')) = [];

subfolder_dir = arrayfun(@(x) dir(fullfile(x.folder, x.name, ['*' imagetype])), folder_dir, 'uni', false);

stim_cell = cellfun(@(x) load_imagedir(x, window), subfolder_dir, 'uni', false);

subfolder_str = vertcat(stim_cell{:});


stimuli = vertcat(stim_str, subfolder_str);


end


function stim_dir = load_imagedir(imageDir, window)

% skip if the dir is empty
if isempty(imageDir) % load files if there is any image
    stim_dir = '';
    return;
end

% number of images
nImage = numel(imageDir);

for iImage = 1:nImage
    
    clear tmp
    
    tmp.filename = imageDir(iImage).name;
    tmp.folder = imageDir(iImage).folder;
    
    % load images as different layers for different types of images
    [~, ~, imagetype] = fileparts(tmp.filename);
    switch imagetype(2:end)
        case 'png'
            [tmp.matrix, ~, tmp.alpha] = imread(fullfile(tmp.folder, tmp.filename));
            tmp.texture = Screen('MakeTexture', window, cat(3, tmp.matrix, tmp.alpha));
        case 'jpg'
            tmp.matrix = imread(fullfile(tmp.folder, tmp.filename));
            tmp.texture = Screen('MakeTexture', window, tmp.matrix);
    end
    
    [~, tmp.category] = fileparts(tmp.folder);
    
    % save the info in stim_dir
    if iImage == 1
        stim_dir = repmat(tmp, nImage, 1);
    else
        stim_dir(iImage) = tmp;
    end
    
end

end