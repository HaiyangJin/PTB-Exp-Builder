function respKeys = ptb_balancekeys(subjCode, respKeys, method)
% This function counterbalance the keys based on subjCode.
%
% Inputs:
%     subjCode         <string> subject code
%     respKeys         <cell of strings> response keys
%     method           <integer> 1 (for future development)
%
% Output:
%     respKeys         <cell of strings> response keys after counterbalance
%
% Created by Haiyang Jin (05-Feb-2020)

if ischar(subjCode)
    subjCode = str2double(subjCode);
end

if nargin < 3 || isempty(method)
    method = 1;
end

switch method
    case 1 % method 1
        %
        if ~mod(subjCode, 2) % switch keys for even subjCode
            respKeys = respKeys(:, [2, 1]);
        end
        
end