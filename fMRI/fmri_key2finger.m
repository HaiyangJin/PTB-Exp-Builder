function fingers = fmri_key2finger(keys)
% fingers = fmri_key2finger(keys)
%
% This function converts the key names [1to 5] to fingers.
%
% Input:
%    keys                <numeric> or <cell of strings> KeyNames used for
%                        responses. It has to be from 1 to 5.
%
% Output:
%    fingers             <cell of strings> names of fingers to be used in
%                        fMRI experiments (the response box)
%
% Created by Haiyang Jin (3-March-2020)

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

end