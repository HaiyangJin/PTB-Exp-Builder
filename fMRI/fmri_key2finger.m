function fingers = fmri_key2finger(keys, saveCell)
% fingers = fmri_key2finger(keys, saveCell)
%
% This function converts the key names [1to 5] to fingers.
%
% Input:
%    keys                <num> or <cell str> KeyNames used for responses. 
%                         It has to be from 1 to 5.
%    saveCell            <boo> 1: the output will be saved as a cell.
%                         0: the output will be saved as a string if only
%                         one finger name is obtained.
%
% Output:
%    fingers             <cell str> names of fingers to be used in fMRI 
%                         experiments (the response box).
%
% Created by Haiyang Jin (3-March-2020)

% By default fingers will be a string if there is only one finger in the output 
if ~isempty('saveCell', 'var') || isempty(saveCell)
    saveCell = 0;
end

% keys to be allowed in fMRI
keyAllow = 1:5;

fingerNames = {'thumb', 'index finger', 'middle finger', 'ring finger', ...
    'little finger'};

% if it is a cell string
if iscell(keys)
    % convert cell string to double
    keys = cellfun(@str2double, keys);
    
elseif ischar(keys)
    % char 2 double
    keys = str2double(keys);
end

% make sure the keys are witin the keyAllow
isAllowed = ismember(keys, keyAllow);
if ~all(isAllowed)
    error('Cannot find the corresponding finger for Key %d.', keys(~isAllowed));
end

% get the finger names for the keys
fingers = fingerNames(keys);

% conver the fingers to a string if needed
if numel(fingers) == 1 && ~saveCell
    fingers = fingers{1};
end

end