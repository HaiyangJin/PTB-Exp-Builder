function [output, quitNow] = fmri_block_dovtrial(ttn, param, stimuli, ...
    runStartTime, isFixBlock)
% [output, quitNow] = fmri_block_dovtrial(ttn, param, stimuli, ...
%     runStartTime, isFixBlock)
%
% Run the fixation blocks and the trials in the stimulus blocks (with
% videos). For displaying images, see fmri_block_dotrial().
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
% Created by Haiyang Jin (2021-11-23)
%
% See also:
% fmri_block_dotrial

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

    while checkTime < param.fixBloDuration
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
    stimRect = [0 0 stimuli.imgX stimuli.imgY];
    stimPosition = CenterRect([0 0 stimuli.imgX stimuli.imgY], param.screenRect);

    % random jitters
    jitter = -param.jitter : param.jitter;
    xJitterRand = jitter(randperm(numel(jitter),1))*5; %
    yJitterRand = jitter(randperm(numel(jitter),1))*5; %

    % process some trial information
    subBlockNum = param.nStimBlock;
    stimCategory = stimuli.condition;
    stimName = stimuli.name;
    correctAns = stimuli.correctAns;

    % only response and experimenter keys are allowed
    RestrictKeysForKbCheck([param.respKeys(:)', param.expKey]);

    % play video
    Screen('PlayMovie', stimuli.movieptr, 1, 1);

    %%%%%%% the first frame %%%%%%
    texture = Screen('GetMovieImage', w, stimuli.movieptr);
    % Draw the new texture immediately to screen:
    Screen('DrawTexture', w, texture, stimRect,...
        OffsetRect(stimPosition, xJitterRand, yJitterRand), [], []);
    % Update display:
    stimBeganAt = Screen('Flip', w);
    % Release texture:
    Screen('Close', texture);

    % Playback loop: Runs until end of movie and check key press
    while checkTime < param.stimDuration

        % Wait for next movie frame, retrieve texture handle to it
        texture = Screen('GetMovieImage', w, stimuli.movieptr, 1);

        % Valid texture returned? A negative value means end of movie reached:
        if texture<=0
            % We're done, break out of loop:
            break;
        end

        % Draw the new texture immediately to screen:
        Screen('DrawTexture', w, texture, stimRect,...
            OffsetRect(stimPosition, xJitterRand, yJitterRand), [], []);

        % Update display:
        Screen('Flip', w);

        % Release texture:
        Screen('Close', texture);

        % check if any key is pressed
        [isKey, keyTime, keyCode] = KbCheck;

        % only the first response within each trial will be recorded
        if isKey && isnan(isSame)
            quitNow = any(keyCode(param.expKey));
            if quitNow; break; end
            isSame = any(keyCode(param.respKeys(:, 1)));
            ACC = isSame == correctAns;
            RT = keyTime - stimBeganAt;
            if param.dispPress
                disp(KbName(find(keyCode)));
            end
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
        % Roughly when the video ends but actually it should be the onset of
        % the next video
        stimEndAt = GetSecs;
    end
    % Stop playback and close movie
    Screen('PlayMovie', stimuli.movieptr, 0);
    %     Screen('CloseMovie', stimuli.movieptr);

    while checkTime < param.trialDuration && ~quitNow
        % check if any key is pressed
        [isKey, keyTime, keyCode] = KbCheck;
        % only the first response within each trial will be saved
        if isKey && isnan(isSame)
            quitNow = any(keyCode(param.expKey));
            if quitNow; break; end
            isSame = any(keyCode(param.respKeys(:, 1)));
            ACC = isSame == correctAns;
            RT = keyTime - stimBeganAt;
            if param.dispPress
                disp(KbName(find(keyCode)));
            end
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
output.Response = isSame;
output.isCorrect = ACC;
output.RespTime = RT;

end