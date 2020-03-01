function [output, quitNow] = fmri_dummyvol(param)
% [output, quitNow] = fmri_dummyvol(param)
%
% This function displays fixation screen for dummy volume at the beginning
% of the run.
%
% Inputs:
%     param             <structure> experiment parameter structure
%
% Output:
%     output            <structure> output structure
%     quitNow           <logical> quit the experiment
%
% Created by Haiyang Jin (1-March-2020)

% return if the dummy duration is 0
if param.dummyDuration == 0
    return;
end

%%% Fixation %%%
Screen('FillRect', param.w, [128 128 128], param.fixarray); % param.forecolor
stimBeganAt = Screen('Flip', param.w);

checkTime = 0;

% process some trial information
stimCategory = 'dummyVol';
stimName = 'fixation';
correctAns = NaN;

% only experimenter key is allowed
RestrictKeysForKbCheck(param.expKey);

while checkTime < param.dummyDuration
    % check if experimenter key is pressed
    quitNow = KbCheck;
    if quitNow; break; end
    % check the time
    checkTime = GetSecs - param.runStartTime;
end

stimEndAt = checkTime + param.runStartTime; % (roughly, not accurate)

%% dummy volumes information to be saved
% trial and block numbers
output.BlockNum = 0;
output.SubBlockNum = 0;
output.SubTrialNum = 0;

% stimulus onsets
output.StimOnset = stimBeganAt;
output.StimOnsetRela = stimBeganAt - param.runStartTime;
output.StimEndAt = stimEndAt;
output.StimDuration = stimEndAt - stimBeganAt;

% stimulus
output.StimCategory = stimCategory;
output.StimName = stimName;

% responses
output.CorrectAns = correctAns;
output.Response = NaN;
output.isCorrect = NaN;
output.RespTime = NaN;

end