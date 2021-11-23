function stimDir = ptb_loadstimdir(imgDir, window, isim)
% stimDir = ptb_loadstimdir(imgDir, window, isim)
%
% This function loads the stimDir created by ptb_dirstim and add .matrix
% and .texture for displaying images later.
%
% Inputs:
%     stimDir       <struct> or <struct array> created by im_readdir.m
%     window        <int> should be param.w
%     isim          <boo> whether imgDir is image (default: 1) or video (0).
%
% Output:
%     stimDir       <struct> stimuli structure
%
% Created by Haiyang Jin (3-Feb-2020)

if ~exist('window', 'var') || isempty(window)
    window = '';
end

if ~exist('isim', 'var') || isempty(isim)
    isim = 1;
end

% return if imgDir is not images (e.g., videos)
if ~isim
    stimDir = imgDir;
    return;
end

% return if the dir is empty
if isempty(imgDir)
    stimDir = struct();
    return;
end

if size(imgDir, 2) > 1 % if it is an array
    % run arrayfun if imgDir is an array (load texture)
    stimDir = arrayfun(@(x) im_readdir(x, window), imgDir);
else
    % load texture
    stimDir = im_readdir(imgDir, window);
end

end