function stimDir = ptb_loadstimdir(imgDir, window)
% This function loads the stimDir created by ptb_dirstim and add .matrix
% and .texture for displaying images later.
%
% Inputs:
%     stimDir       <structure> or <array of structure> created by ptb_dirstim.m
%     window        <double> should be param.w
%
% Output:
%     stimDir       <structure> stimuli structure
%
% Created by Haiyang Jin (3-Feb-2020)

% return if the dir is empty
if isempty(imgDir) 
    stimDir = '';
    return;
end

if size(imgDir, 2) > 1 % if it is an array
    % run arrayfun if imgDir is an array (load texture)
    stimDir = arrayfun(@(x) load_stimdir(x, window), imgDir); 
else
    % load texture
    stimDir = load_stimdir(imgDir, window);
end

end

function stimDir = load_stimdir(imgDir, window)
% function to load texture and other infomation

% number of images
nImage = numel(imgDir);

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
            tmp.texture = Screen('MakeTexture', window, cat(3, tmp.matrix, tmp.alpha));
        case 'jpg'
            tmp.matrix = imread(fullfile(tmp.folder, tmp.filename));
            tmp.texture = Screen('MakeTexture', window, tmp.matrix);
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

end