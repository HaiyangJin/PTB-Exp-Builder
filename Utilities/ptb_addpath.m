function pathlist = ptb_addpath(ptbpath, folderlist, remove)
% pathlist = ptb_addpath(ptbpath, folderlist, remove)
%
% Adds functions to Matlab Path (useful when developing new programs). This
% function is not recommended to be used in real experiments. 
% 1. Functions in 'PTB-Exp-Builder/' will be added by default. 
% 2. If PTB-Exp-Builder/' is not avaiable in Matlab Path, 'functions/' in 
%    pwd (if available) will be added to Matlab Path.
% 3. If 'functions/' is not avaiable in pwd, <folderlist> in the pwd will
%    be added to Matlab Path. 
%
% Inputs:
%    ptbpath        <str> where folders in <folderlist> are.
%    folderlist     <cell str> folders to be added to Matlab Path. 
%    remove         <boo> whether remove <pathlist> from Matlab Path.
%                    Default is 0 (i.e., add).
%
% Output:
%    pathlist       <cell str> list of folders added to /removed from
%                    Matlab path. 
%
% Created by Haiyang Jin (2021-11-22)

if ~exist('folderlist', 'var') || isempty(folderlist)
    folderlist = {'PTB/', 'fMRI/', 'ImageTools/', 'Utilities/'};
end
if ischar(folderlist)
    folderlist = {folderlist};
end

if ~exist('ptbpath', 'var') || isempty(ptbpath)
    % use functions in PTB-Exp-Builder by default
    ptbpath = fileparts(which('ptb_addminipath'));
end
if isempty(ptbpath)
    % if PTB-Exp-Builder is not added to path, use 'functions/' in pwd.
    ptbpath = 'functions/';
end

if ~exist('remove', 'var') || isempty(remove)
    remove = 0;
end

% add all avaiable folders to Matlab path
pathlist = fullfile(ptbpath, folderlist);

if ~remove
    cellfun(@addpath, pathlist);
else
    cellfun(@rmpath, pathlist);
end

end