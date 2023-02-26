function [output, quitNow] = fmri_dummyvol(param, basetime)
% [output, quitNow] = fmri_dummyvol(param)
%
% This function displays fixation screen for dummy volume at the beginning
% of the run (or the end).
%
% Inputs:
%     param             <struct> experiment parameter structure
%
% Output:
%     output            <struct> output structure
%     quitNow           <boo> quit the experiment
%
% Created by Haiyang Jin (1-March-2020)

if ~exist('basetime', 'var') || isempty(basetime)
    basetime = param.runStartTime;
end

if ~isfield(param, 'dummyDuration')
    param.dummyDuration = 0;
end
if ~isfield(param, 'dummyDurationEnd')
    param.dummyDurationEnd = 0;
end
% return if it does not need dummy volume
quitNow = 0;
if param.dummyDuration == 0 && param.dummyDurationEnd == 0
    output = table;
    return;
end

%%% Fixation %%%
Screen('FillRect', param.w, param.forecolor, param.fixarray); % 
stimBeganAt = Screen('Flip', param.w);

% process some trial information
stimCategory = 'dummyVol';
stimName = 'fixation';

% only experimenter key is allowed
RestrictKeysForKbCheck(param.expKey);

checkTime = GetSecs - basetime;
while checkTime < param.dummyDuration 
    % check if experimenter key is pressed
    quitNow = KbCheck;
    if quitNow; break; end
    % check the time
    checkTime = GetSecs - basetime;
end

stimEndAt = checkTime + basetime; % (roughly, not accurate)

%% dummy volumes information to be saved
% stimulus onsets
output.StimOnset = stimBeganAt;
output.StimOnsetRela = stimBeganAt - param.runStartTime;
output.StimEndAt = stimEndAt;
output.StimDuration = stimEndAt - stimBeganAt;

% stimulus
output.StimCategory = stimCategory;
output.StimName = stimName;

end