function ptb_addminipath()
% ptb_addminipath()
%
% Usually subdirectories in PTB-Exp-Builder should not be included in 
% Matlab Path. But some functions in PTB-Exp-Builder/ImageTools may be 
% needed independently. This function will adds PTB-Exp-Builder/ImageTools
% to Matlab path temporarily (if PTB-Exp-Builder is in Matlab path).
% 
% Created by Haiyang Jin (2021-11-12)

% locate this function
thepath = fileparts(which('ptb_addminipath'));
% add path
addpath(fullfile(thepath, 'ImageTools'));
addpath(fullfile(thepath, 'Utilities'))

end