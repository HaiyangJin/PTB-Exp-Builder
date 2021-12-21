function [output, quitNow] = fmri_block_dotrial(ttn, param, stimuli, ...
    runStartTime, isFixBlock)
% [output, quitNow] = fmri_doblocktrial(ttn, param, stimuli, ...
%    runStartTime, isFixBlock)
%
% Run the fixation blocks and the trials in the stimulus blocks (with
% images). For displaying videos, see fmri_block_dovtrial().
%
% Inputs:
%     ttn            <int> this trial number. if ttn is empty, this
%                     trial/block will be the fixation only task.
%     param          <struct> the experiment parameters.
%     stimuli        <struct> stimuli to be shown in this trial. [only
%                     information of one image is included]
%     runStartTime   <num> the start time point of this run.
%     isFixBlock     <boo> 1: a fixation only block; 0: one trial in
%                     the stimulus blocks.
%
% Output:
%     output         <struct> this trial information to be saved.
%     quitNow        <boo> 1: quit the experiment. 0: do not quit.
%
% Created by Haiyang Jin (27-Feb-2020)
%
% See also:
% fmri_block_dovtrial

%% Preparation

if ~exist('ttn', 'var') || isempty(ttn)
    ttn = 0;
    isFixBlock = 1;

    % the baseline time for this fixation block
    baseTime = (param.nFixBlock - 1) * param.fixBloDuration + ...
        param.nStimBlock * param.stimBloDuration + ...
        param.dummyDuration;
else
    % the baseline time for this trial [in stimulus block]
    baseTime = param.nFixBlock * param.fixBloDuration + ...
        (ttn-1) * param.trialDuration + ...
        param.dummyDuration;
end

% by default use the param.runStartTime
if ~exist('runStartTime', 'var') || isempty(runStartTime)
    runStartTime = param.runStartTime;
end

% by default it is a trial [in stimulus block]
if ~exist('isFixBlock', 'var') || isempty(isFixBlock)
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
pressed = '';

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

    while checkTime < param.fixBloDuration - param.flipSlack
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
    [imgY, imgX, ~] = size(stimuli.matrix);
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
    stimCategory = stimuli.condition;
    stimName = stimuli.fn;
    correctAns = stimuli.correctAns;

    % only response and experimenter keys are allowed
    RestrictKeysForKbCheck([param.respKeys(:)', param.expKey]);

    while checkTime < param.stimDuration - param.flipSlack

        if ~param.isEmulated && ~isempty(param.respButton)
            theout = param.do_trigger('resp', param.respButton);
            isButton = theout{1};
        else 
            isButton = 0;
        end
        % check if any key is pressed
        [isKey, keyTime, keyCode] = KbCheck;

        % only the first response within each trial will be recorded
        if (isKey || isButton) && isnan(isSame)
            
            quitNow = any(keyCode(param.expKey));
            if quitNow; break; end

            if ~param.isEmulated && ~isempty(param.respButton)
                 isSame = theout{2};
                 keyTime = theout{3};
                 pressed = theout{4};
                % check response from response box
                if param.dispPress && ~isempty(pressed)
                    fprintf('\nA button was pressed (%s).', pressed);
                end
            else
                % deal with response from keyboard
                pressed = KbName(find(keyCode));
                isSame = any(keyCode(param.respKeys(:, 1)));
                if param.dispPress
                    fprintf('\nA key was pressed (%s).', pressed);
                end
            end

            ACC = isSame == correctAns;
            RT = keyTime - stimBeganAt;

            fprintf(' [ACC: %d]', ACC);
        end

        % check the time
        checkTime = GetSecs - runStartTime - baseTime;
    end

    %%%%%%%%%% display the fixation/blank %%%%%%%%%%
    %     Screen('FillRect', w, param.forecolor, OffsetRect(param.fixarray, ...
    %         xJitterRand, yJitterRand));
    if param.trialDuration > param.stimDuration
        stimEndAt = Screen('Flip', w);
    else
        % this is a rough time; the stimulus offset should be the onset of
        % the next stimuli
        stimEndAt = GetSecs;
    end

    while checkTime < param.trialDuration - param.flipSlack && ~quitNow

        if ~param.isEmulated && ~isempty(param.respButton)
            theout = param.do_trigger('resp', param.respButton);
            isButton = theout{1};
        else 
            isButton = 0;
        end
        % check if any key is pressed
        [isKey, keyTime, keyCode] = KbCheck;

        % only the first response within each trial will be recorded
        if (isKey || isButton) && isnan(isSame)
            
            quitNow = any(keyCode(param.expKey));
            if quitNow; break; end

            if ~param.isEmulated && ~isempty(param.respButton)
                 isSame = theout{2};
                 keyTime = theout{3};
                 pressed = theout{4};
                % check response from response box
                if param.dispPress && ~isempty(pressed)
                    fprintf('\nA button was pressed (%s).', pressed);
                end
            else
                % deal with response from keyboard
                pressed = KbName(find(keyCode));
                isSame = any(keyCode(param.respKeys(:, 1)));
                if param.dispPress
                    fprintf('\nA key was pressed (%s).', pressed);
                end
            end

            ACC = isSame == correctAns;
            RT = keyTime - stimBeganAt;

            fprintf(' [ACC: %d]', ACC);
        end

        % check the time
        checkTime = GetSecs - runStartTime - baseTime;
    end

end

if isnan(isSame) && correctAns==1
    % missing a key press was treated as incorrect
    ACC = 0;
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
output.StimCategory = stimCategory;
output.StimName = stimName;

% responses
output.CorrectAns = correctAns;
output.Pressed = pressed;
output.Response = isSame;
output.isCorrect = ACC;
output.RespTime = RT;

end