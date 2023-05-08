function [output, quitNow] = cat_trial(ttn, param)
% [output, quitNow] = cat_trial(ttn, param)
% 
% Example do trial.
%
% Inputs:
%    ttn         this trial number
%    param       experiment parameters
%    stimuli     stimuli structure
% Outputs:
%    output      output from this trial
%    quitNow     if the experiment should quite now
%
% Created by Haiyang Jin

%% set quitNow as false by default
quitNow = 0;

% experiment design
stimuli = param.stimuli;
respKeys = param.respKeys;

correctAns = 1;

%% This jitter
jitterX = param.jitterX(randperm(length(param.jitterX),1));
jitterY = param.jitterY(randperm(length(param.jitterY),1));

stimRect = [0 0 size(stimuli(ttn).matrix,2) size(stimuli(ttn).matrix,1)];

if param.isEyelink
    % set the IA filename
    iaFilename = fullfile(param.iafolder, ...
        sprintf([repmat('%d_', 1, 3), '%d', '.ias'],...
        jitterX, jitterY, ...
        param.screenX, param.screenY));
end

<<<<<<< HEAD:custom/demo1_funcs/demo1_trial.m
[~,stimBeginsWhen] = ptb_flip(param, [], param.fixDuration);
% fixationBeganAt = Screen('Flip', param.w);
% stimBeginsWhen = fixationBeganAt + param.fixDuration - param.flipSlack;

%%%%%%%%%%%%%% stimuli %%%%%%%%%%%%%%
Screen('DrawTexture', param.w, stimuli(ttn).texture,[]); %OffsetRect(faceTopRect,100*(1-ed(ttn).isAligned)*(1-ed(ttn).topIsCued),0)
[~,respBeginsWhen] = ptb_flip(param, stimBeginsWhen, param.stimDuration);
% stimBeganAt = Screen('Flip', param.w, stimBeginsWhen);
% respBeginsWhen = stimBeganAt + param.stimDuration - param.flipSlack;
=======
% stim position
stimXPosition = param.screenCenX - size(stimuli(ttn).matrix,2)/2;
stimYPosition = param.screenCenY - size(stimuli(ttn).matrix,1)/2;

%% Do the trial
if param.isEyelink
    [trialBeginsAt, param] = el_trial(ttn, param);
    stimBeginsWhen = GetSecs;
else
    trialBeginsAt = GetSecs;
    %%%%%%%%%%%%%% fixation %%%%%%%%%%%%%%
    Screen('FillRect', param.w, param.forecolor, param.fixarray);
    fixationBeganAt = Screen('Flip', param.w);
    stimBeginsWhen = fixationBeganAt + param.fixDuration - param.flipSlack;
end

%%%%%%%%%%%%%% stimuli %%%%%%%%%%%%%%
Screen('DrawTexture', param.w, stimuli(ttn).texture,[], ...
    OffsetRect(stimRect, stimXPosition+jitterX, stimYPosition+jitterY));
stimBeganAt = Screen('Flip', param.w, stimBeginsWhen);
respBeginsWhen = stimBeganAt + param.stimDuration - param.flipSlack;
if param.isEyelink
    Eyelink('Message', 'Trial_%d', ttn);
    %%%%% load the IA file for this trial %%%%%
    Eyelink('Message', '!V IAREA File %s', iaFilename); % ROI file
    Eyelink('Message', sprintf('!V CLEAR %d %d %d', param.backcolor));
    Eyelink('Message', '!V IMGLOAD TOP_LEFT %s %d %d', ... CENTER
        fullfile(param.transferDir(ttn).folder, param.transferDir(ttn).name), ...
        stimXPosition+jitterX, stimYPosition+jitterY); % image to show in Eyelink
end

%%%%%%%%%%%%%% response %%%%%%%%%%%%%%
[~,responseBegins] = ptb_flip(param, respBeginsWhen, 1);
% responseBegins = Screen('Flip', param.w, respBeginsWhen);

%%%%%%%%%% Response (keys) %%%%%%%%%%
RestrictKeysForKbCheck([respKeys(:)', param.expKey]); 
[pressTime, keyCode] = KbWait([],0);

if param.isEyelink
    Eyelink('Message', 'Response_%d', ttn);
    Eyelink('Message', sprintf('!V CLEAR %d %d %d', param.backcolor));
    % stop the recording of eye-movements for the current trial
    Eyelink('StopRecording');
end

% trial is finished.
trialEndedAt = Screen('Flip',param.w);
totalTrialDuration = trialEndedAt - trialBeginsAt;

%%%%%%%%%% Post-processing %%%%%%%%%%
if sum(sum(keyCode(respKeys)))==1
    Resp = find(sum(keyCode(respKeys)));
    ACC = double(Resp == correctAns);
    reactionTime = pressTime - responseBegins;

else
    Resp = NaN;
    ACC = NaN;
    reactionTime = NaN;

    if any(keyCode(param.expKey))
        % quit if the experimenter key is pressed
        quitNow = 1;
        noRespText = sprintf(['The experiment will quit now. \n\n'...
            'Please press any key to continue...']);
    else
        noRespText = sprintf(['Something wrong happended... \n\n'...
            'Please press any key to continue...']);
    end

    % wrong key, double key or timeout
    beep;
    ptb_disptext(param, noRespText);
end

% display feedback if necessary
if param.isFeedback
    ptb_feedback(ACC, param.w);
end

%% STEP 8.7 AOI and conditions
if param.isEyelink
    % Send out necessary integration messages for data analysis

    % Send messages to report trial condition information
    % Each message may be a pair of trial condition variable and its
    % corresponding value follwing the '!V TRIAL_VAR' token message
    % See "Protocol for EyeLink Data to Viewer Integration-> Trial
    % Message Commands" section of the EyeLink Data Viewer User Manual
    WaitSecs(0.001);
    Eyelink('Message', '!V TRIAL_VAR trialNum %d', ttn);
    Eyelink('Message', '!V TRIAL_VAR JitterX %d', jitterX);
    Eyelink('Message', '!V TRIAL_VAR JitterY %d', jitterY);
    Eyelink('Message', '!V TRIAL_VAR Response %d', ACC);

end

%% Save the variable and response
RestrictKeysForKbCheck([]);

output.Trial = ttn;
output.JitterX = jitterX;
output.JitterY = jitterY;
output.ThisResponse = Resp;
output.correctAnswer = correctAns;
output.isCorrect = ACC;
output.ReactionTime = reactionTime;
output.FixDuration = param.fixDuration;
output.TrialDuration = totalTrialDuration;

%% STEP 8.8
% Send an integration message so that an image can be loaded as
% overlay backgound when performing Data Viewer analysis.  This
% message can be placed anywhere within the scope of a trial (i.e.,
% after the 'TRIALID' message and before 'TRIAL_RESULT')

% Sending a 'TRIAL_RESULT' message to mark the end of a trial in
% Data Viewer. This is different than the end of recording message
% END that is logged when the trial recording ends. The viewer will
% not parse any messages, events, or samples that exist in the data
% file after this message.
if param.isEyelink; Eyelink('Message', 'TRIAL_RESULT 0'); end

end