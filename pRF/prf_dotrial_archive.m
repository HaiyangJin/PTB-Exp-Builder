function [output, quitNow] = prf_dotrial_archive(ttn, param, stimuli, runStartTime, isFixTrial)
% [output, quitNow] = prf_dotrial_archive(ttn, param, stimuli, runStartTime, isFixTrial)
%
% This function will display stimulus for long duration (without breaks).
% You may want to use prf_dotrial() instead.
%
% Inputs:
%     ttn            <int> this trial number. if ttn is empty, this
%                     trial/block will be the fixation only task.
%     param          <struct> the experiment parameters.
%     stimuli        <struct> stimuli to be shown in this trial. [only
%                     information of one image is included]
%     runStartTime   <num> the start time point of this run.
%     isFixTrial     <boo> 1: a fixation only block; 0: one trial in
%                     the stimulus blocks.
%
% Output:
%     output         <struct> this trial information to be saved.
%     quitNow        <boo> 1: quit the experiment. 0: do not quit.
%
% Created by Haiyang Jin (2023-Feb-25)

%% Preparation

if ~exist('ttn', 'var') || isempty(ttn)
    ttn = 0;
    isFixTrial = 1;
end

% the baseline time for this fixation block
baseTime = (param.nFixTrial - 1 + param.nStimTrial) * param.trialDuration + ...
    param.dummyDuration;

% by default use the param.runStartTime
if ~exist('runStartTime', 'var') || isempty(runStartTime)
    runStartTime = param.runStartTime;
end

% by default it is a trial with stimulus
if ~exist('isFixTrial', 'var') || isempty(isFixTrial)
    isFixTrial = 0;
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

if isFixTrial
    %% Fixation only trial
    %%% Fixation %%%
    Screen('FillRect', w, param.forecolor, param.fixarray);
    stimBeganAt = Screen('Flip', w);

    % process some trial information
    subTrialNum = param.nFixTrial;
    stimCategory = 'fixation';
    stimName = 'fixation';
    correctAns = NaN;

    % only experimenter key is allowed
    RestrictKeysForKbCheck(param.expKey);

    while checkTime < param.fixDuration - param.flipSlack
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
    [stimY, stimX, ~] = size(stimuli.matrix);
    posiXY = param.prfposi{param.ed(ttn).stimPosiY, param.ed(ttn).stimPosiX};
    stimRect = [0 0 stimX stimY];
    stimPosition = [posiXY(1)-stimX/2+param.screenCenX ... 
        posiXY(2)-stimY/2+param.screenCenY ...
        posiXY(1)+stimX/2-1+param.screenCenX ...
        posiXY(2)+stimY/2-1+param.screenCenY];

    % display the stimulus
    Screen('FillRect', w, param.forecolor, param.fixarray);
    Screen('DrawTexture', w, stimuli.texture, stimRect,...
        stimPosition, [], []);
    stimBeganAt = Screen('Flip', w);

    % process some trial information
    subTrialNum = param.nStimTrial;
    stimCategory = stimuli.condition;
    stimName = stimuli.fn;
    correctAns = NaN;

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

% if isnan(isSame) && correctAns==1
%     % missing a key press was treated as incorrect
%     ACC = 0;
% end

%% trial information to be saved
% trial and block numbers
output.BlockNum = []; % param.BlockNum;
output.SubBlockNum = subTrialNum;
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