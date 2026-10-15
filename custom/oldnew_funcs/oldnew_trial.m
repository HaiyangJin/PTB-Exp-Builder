function [output, quitNow] = oldnew_trial(ttn, param)
% OLDNEW_TRIAL Run one study or recognition trial.
% Uses KbCheck rather than KbQueue to avoid conflicts with GetChar/ListenChar.

quitNow = 0;
w = param.w;
stimuli = param.stimuli;
ed = param.ed(ttn);
stim = stimuli(ed.stimIndex);

% Output fields must be identical across trials.
output.Trial = ttn;
output.Phase = double(~ed.isStudy) + 1;
output.StimulusIndex = ed.stimIndex;
output.StimulusFile = {stim.fn};
output.IsOld = ed.isOld;
output.Response = NaN;       % 1 = old/F; 2 = new/J
output.isCorrect = NaN;
output.ReactionTime = NaN;
output.KeyPressed = {''};

% The user's system was confirmed to detect keys with KbCheck(0).
if isfield(param, 'keyboardDevice')
    keyboardDevice = param.keyboardDevice;
else
    keyboardDevice = 0;
end

% Avoid carrying a held key into the next trial. This does not create a queue.
KbReleaseWait(keyboardDevice);
firstPressAll = [];

%% Start EyeLink recording, if enabled
if param.isEyelink
    doDriftCorrection = (ttn == 1) || (ttn == param.nStudy + 1);
    [trialBeginsAt, param] = el_trial(ttn, param, doDriftCorrection);
    Eyelink('Message', 'PHASE %d', output.Phase);
else
    trialBeginsAt = GetSecs;
end

%% Fixation
Screen('FillRect', w, param.backcolor);
Screen('FillRect', w, param.forecolor, param.fixarray);
fixOnset = Screen('Flip', w);

while GetSecs < fixOnset + param.fixDuration
    [quitNow, firstPressAll] = oldnew_checkEscape( ...
        param, firstPressAll, keyboardDevice);
    if quitNow, break; end
    WaitSecs(0.005);
end

%% Present face
if ~quitNow
    Screen('FillRect', w, param.backcolor);
    oldnew_drawFace(w, stim, param);
    stimOnset = Screen('Flip', w);
    if param.isEyelink
        Eyelink('Message', 'STIM_ONSET %d', ttn);
    end
else
    stimOnset = GetSecs;
end

%% Study phase
if ed.isStudy
    while ~quitNow && GetSecs < stimOnset + param.studyDuration
        [quitNow, firstPressAll] = oldnew_checkEscape( ...
            param, firstPressAll, keyboardDevice);
        if quitNow, break; end
        WaitSecs(0.005);
    end

    Screen('FillRect', w, param.backcolor);
    Screen('Flip', w);
    if param.isEyelink
        Eyelink('Message', 'STUDY_STIMULUS_END %d', ttn);
    end
    output.Phase = 'study';

    if ~quitNow && ttn == param.nStudy
        DrawFormattedText(w, ...
            ['Study phase complete.\n\n', ...
            'Next is the recognition test.' ...
            'You will then see faces one at a time.\n\n', ...
            'Press F if the face appeared in the study phase.\n\n', ...
            'Press J if the face is new.\n\n\n', ...
            'Respond as quickly and accurately as possible.\n\n\n', ...
            'Press Q to continue.'], ...
            'center', 'center', param.textColor);
        Screen('Flip', w);
        RestrictKeysForKbCheck(param.instructKey);
        KbWait([],2);
    end

%% Test phase
else
    output.Phase = 'test';
    responseDeadline = stimOnset + param.responseMaxDuration;
    responseFound = false;

    RestrictKeysForKbCheck(param.respKeys);

    while ~quitNow && ~responseFound && GetSecs < responseDeadline
        [keyIsDown, secs, keyCode] = KbCheck(keyboardDevice);

        if isempty(firstPressAll)
            firstPressAll = zeros(size(keyCode));
        end

        if keyIsDown
            newPresses = logical(keyCode) & (firstPressAll == 0);
            firstPressAll(newPresses) = secs;

            if any(firstPressAll(param.expKey) > 0)
                quitNow = 1;
                break;
            end

            responseFound = any(firstPressAll(param.respKeys) > 0);
        end
        WaitSecs(0.005);
    end

    Screen('FillRect', w, param.backcolor);
    Screen('Flip', w);

    if ~isempty(firstPressAll)
        responseTimes = firstPressAll(param.respKeys);
    else
        responseTimes = zeros(size(param.respKeys));
    end

    if any(responseTimes > 0)
        [responseTime, response] = max(responseTimes);
        output.Response = response;
        output.ReactionTime = responseTime - stimOnset;
        output.isCorrect = double( ...
            (response == 1 && ed.isOld == 1) || ...
            (response == 2 && ed.isOld == 0));
    end

    if param.isEyelink
        if isnan(output.Response)
            Eyelink('Message', 'NO_RESPONSE %d', ttn);
        else
            Eyelink('Message', 'RESPONSE %d', output.Response);
            Eyelink('Message', 'RT %.4f', output.ReactionTime);
            Eyelink('Message', 'CORRECT %d', output.isCorrect);
        end
    end
end

%% Record detected key names
if ~isempty(firstPressAll) && any(firstPressAll > 0)
    output.KeyPressed = {KbName(find(firstPressAll > 0))};
end

%% Stop EyeLink recording
if param.isEyelink
    Eyelink('Message', 'TRIAL_RESULT 0');
    Eyelink('StopRecording');
end

%% End trial
Screen('FillRect', w, param.backcolor);
Screen('Flip', w);
if ~quitNow
    WaitSecs(param.ITInterval);
end
output.TrialDuration = GetSecs - trialBeginsAt;
end
