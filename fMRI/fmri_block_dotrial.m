function [output, quitNow] = fmri_block_dotrial(ttn, param, stimuli, ...
    runStartTime, isFixBlock)
% [output, quitNow] = fmri_doblocktrial(ttn, param, stimuli, ...
%    runStartTime, isFixBlock)
%
% This function run the fixation blocks and the trials in the stimulus
% blocks.
%
% Inputs:
%     ttn            <numeric> this trial number. if ttn is empty, this
%                    trial/block will be the fixation only task.
%     param          <structure> the experiment parameters.
%     stimuli        <structure> stimuli to be shown in this trial. [only
%                    information of one image is included]
%     runStartTime   <numeric> the start time point of this run.
%     isFixBlock     <logical> 1: a fixation only block; 0: one trial in
%                    the stimulus blocks.
%
% Output:
%     output         <structure> this trial information to be saved.
%     quitNow        <logical> 1: quit the experiment. 0: do not quit.
%
% Created by Haiyang Jin (27-Feb-2020)

%% Preparation
if nargin < 1 || isempty(ttn)
    ttn = 0;
    isFixBlock = 1;
    
    % the baseline time for this fixation block
    baseTime = (param.BlockNum - 1) * param.blockDuration;
else
    % the baseline time for this trial [in stimulus block]
    baseTime = param.nFixBlock * param.blockDuration + (ttn-1) * param.trialDuration;
end

% by default use the param.runStartTime
if nargin < 4 || isempty(runStartTime)
    runStartTime = param.runStartTime;
end

% by default it is a trial [in stimulus block]
if nargin < 5 || isempty(isFixBlock)
    isFixBlock = 0;
end

% get the window index
w = param.w;

% set the default values
quitNow = 0;
checkTime = 0;

isSame = NaN;
ACC = NaN;
RT = NaN;

if isFixBlock
    %% Fixation only blocks
    %%% Fixation %%%
    Screen('FillRect', w, param.forecolor, param.fixarray);
    stimBeganAt = Screen('Flip', w);
    
    % process some trial information
    subBlockNum = param.nFixBlock;
    stimCategory = 'fixation';
    stimName = 'fixation';
    correctAns = NaN;
    
    % only experimenter key is allowed
    RestrictKeysForKbCheck(param.expKey);
    
    while checkTime < param.blockDuration
        % check if experimenter key is pressed
        quitNow = KbCheck;
        if quitNow; break; end
        % check the time
        checkTime = GetSecs - runStartTime - baseTime;
    end
    
    stimEndAt = checkTime + runStartTime + baseTime; % (roughly, not accurate)
    
else
    %% Stimulus trials
    
    % this stimulus rect and position
    [imgY, imgX] = size(stimuli.matrix);
    stimRect = [0 0 imgX imgY];
    stimPosition = CenterRect([0 0 imgX imgY], param.screenRect);
    
    % random jitters
    jitter = -param.jitter : param.jitter;
    xJitterRand = jitter(randperm(numel(jitter),1))*5; %
    yJitterRand = jitter(randperm(numel(jitter),1))*5; %
    
    % display the stimulus
    Screen('DrawTexture', w, stimuli.texture, stimRect,...
        OffsetRect(stimPosition, xJitterRand, yJitterRand), [], []);
    stimBeganAt = Screen('Flip', w);
    
    % process some trial information
    subBlockNum = param.nStimBlock;
    stimCategory = stimuli.condition; % to be updated
    stimName = stimuli.fn;
    correctAns = stimuli.correctAns;
    
    % only response and experimenter keys are allowed
    RestrictKeysForKbCheck([param.respKeys(:)', param.expKey]);
    
    while checkTime < param.stimDuration
        
        % check if any key is pressed
        [isKey, keyTime, keyCode] = KbCheck;
        
        % only the first response within each trial will be saved
        if isKey && isnan(isSame)
            quitNow = any(keyCode(param.expKey));
            isSame = any(keyCode(param.respKeys(:, 1)));
            ACC = isSame == correctAns;
            RT = keyTime - stimBeganAt;
            if param.dispPress
                disp(KbName(find(keyCode)));
            end
        end
        
        if quitNow; break; end
        % check the time
        checkTime = GetSecs - runStartTime - baseTime;
    end
    
    % display the fixation
%     Screen('FillRect', w, param.forecolor, OffsetRect(param.fixarray, ...
%         xJitterRand, yJitterRand));
    stimEndAt = Screen('Flip', w);
    
    while checkTime < param.trialDuration && ~quitNow
        % check if any key is pressed
        [isKey, keyTime, keyCode] = KbCheck;
        % only the first response within each trial will be saved
        if isKey && isnan(isSame)
            quitNow = any(keyCode(param.expKey));
            isSame = any(keyCode(param.respKeys(:, 1)));
            ACC = isSame == stimuli.correctAns;
            RT = keyTime - stimBeganAt;
            if param.dispPress
                disp(KbName(find(keyCode)));
            end
        end
        
        if quitNow; break; end
        % check the time
        checkTime = GetSecs - runStartTime - baseTime;
    end
    
end

%% trial information to be saved
% trial and block numbers
output.BlockNum = param.BlockNum;
output.SubBlockNum = subBlockNum;
output.SubTrialNum = ttn;

% stimulus onsets
output.StimOnset = stimBeganAt;
output.StimOnsetRela = stimBeganAt - runStartTime;
output.StimEndAt = stimEndAt;
output.StimDuration = stimEndAt - stimBeganAt;

% stimulus
output.StimCateogry = stimCategory;
output.StimName = stimName;

% responses
output.CorrectAns = correctAns;
output.Response = isSame;
output.isCorrect = ACC;
output.RespTime = RT;

end