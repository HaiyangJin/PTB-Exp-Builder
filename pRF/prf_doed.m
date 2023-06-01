function param = prf_doed(param)
% param = prf_doed(param)
%
% This function should be run after running ptb_expdesignbuilder().
%
% Input:
%     param            <struct> experiment structure.
%
% Created by Haiyang Jin (2023-Feb-26)

% Faked experimental design for fixation (transparent image)
transEd = param.ed(1);
% transEd.stimPosiX = 1; % the first position (random nubmer)
% transEd.stimPosiY = 1; % the first position (random nubmer)
transEd.stimCategory = 0;
transEd.repeated = 0;

% combine the original param.ed with the transparent (fixation) ed
param.alled = repmat(transEd, param.bn + param.fixBlockN, 1);
param.alled(param.imageBlockNum) = param.ed;

end