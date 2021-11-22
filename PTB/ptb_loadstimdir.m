function stimDir = ptb_loadstimdir(imgDir, window)
% stimDir = ptb_loadstimdir(imgDir, window)
%
% This function loads the stimDir created by ptb_dirstim and add .matrix
% and .texture for displaying images later.
%
% Inputs:
%     stimDir       <struct> or <array of structure> created by im_readdir.m
%     window        <int> should be param.w
%
% Output:
%     stimDir       <struct> stimuli structure
%
% Created by Haiyang Jin (3-Feb-2020)

if ~exist('window', 'var') || isempty(window)
    window = '';
end

% return if the dir is empty
if isempty(imgDir)
    stimDir = '';
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