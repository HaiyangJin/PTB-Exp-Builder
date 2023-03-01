function [output, quitNow] = demo1_trial(ttn, param)
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
ed = param.ed;
respKeys = param.respKeys;

correctAns = 1;

if param.isEyelink
    [trialBeginsAt, param] = el_trial(ttn, param);
else
    trialBeginsAt = GetSecs;
end

%% Do the trial
if param.isEyelink
    stimBeginsWhen = now;
else
    %%%%%%%%%%%%%% fixation %%%%%%%%%%%%%%
    Screen('FillRect', param.w, param.forecolor, param.fixarray);
    fixationBeganAt = Screen('Flip', param.w);
    stimBeginsWhen = fixationBeganAt + param.fixDuration - param.flipSlack;
end

%%%%%%%%%%%%%% stimuli %%%%%%%%%%%%%%
Screen('DrawTexture', param.w, stimuli(ttn).texture,[]); %OffsetRect(faceTopRect,100*(1-ed(ttn).isAligned)*(1-ed(ttn).topIsCued),0)
stimBeganAt = Screen('Flip', param.w, stimBeginsWhen);
respBeginsWhen = stimBeganAt + param.stimDuration - param.flipSlack;
if param.isEyelink 
    Eyelink('Message', ['Trial_' num2str(ttn)]);
    %%%%% load the IA file for this trial %%%%%
%     Eyelink('Message', '!V IAREA File %s', 'path/to/file');
    Eyelink('Message', sprintf('!V CLEAR %d %d %d', param.backcolor));
%     Eyelink('Message', '!V IMGLOAD TOP_LEFT %s %d %d', imgfile_study, ...
%         trackerXPosition, trackerYPosition);
end

%%%%%%%%%%%%%% response %%%%%%%%%%%%%%
responseBegins = Screen('Flip', param.w, respBeginsWhen);

%%%%%%%%%% Response (keys) %%%%%%%%%%
RestrictKeysForKbCheck([respKeys(:)', param.expKey]);  % , KbName('5')
[pressTime, keyCode] = KbWait([],0);

if param.isEyelink
    Eyelink('Message', ['Response_', num2str(ttn)]);
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
    % Send out interest area information for the trial (AOIs)
    
    % FREEHAND ROI (half oval) for study face
    % studyStartStamp1 = round((GetSecs - studyBeganAt)*1000);
    % Eyelink('Message', sprintf(['!V IAREA %d %d FREEHAND %d ', repmat('%d,%d ', 1, nXOval), '%s'],...
    %     studyStartStamp1, studyStartStamp1 - studyDuration*1000 + 1,...
    %     1, topStudyOval, 'topStudyOval'));
    % studyStartStamp2 = round((GetSecs - studyBeganAt)*1000);
    % Eyelink('Message', sprintf(['!V IAREA %d %d FREEHAND %d ', repmat('%d,%d ', 1, nXOval), '%s'],...
    %     studyStartStamp2, studyStartStamp2 - studyDuration*1000 + 1,...
    %     2, bottomStudyOval, 'bottomStudyOval'));
    
    % Rectangular ROI
    %     Eyelink('Message', sprintf('!V IAREA %d %d RECTANGLE %d %d %d %d %d %s',...
    %         studyStartStamp1, studyStartStamp1 - studyDuration*1000 + 1, 11, topStudyPosition,'topStudy'));
    %     Eyelink('Message', sprintf('!V IAREA %d %d RECTANGLE %d %d %d %d %d %s',...
    %         studyStartStamp2, studyStartStamp2 - studyDuration*1000 + 1, 12, bottomStudyPosition,'bottomStudy'));
    
    WaitSecs(0.001);
    
    % FREEHAND ROI (half oval)
    % Eyelink('Message', sprintf(['!V IAREA %d %d FREEHAND %d ', repmat('%d,%d ', 1, nXOval), '%s'],...
    %     round((GetSecs - responseBegins)*1000), round((GetSecs - pressTime)*1000), 3, topTestOval, 'topTestOval'));
    % Eyelink('Message', sprintf(['!V IAREA %d %d FREEHAND %d ', repmat('%d,%d ', 1, nXOval), '%s'],...
    %     round((GetSecs - responseBegins)*1000), round((GetSecs - pressTime)*1000), 4, bottomTestOval, 'bottomTestOval'));
    
    % Rectangular ROI
    %     Eyelink('Message', sprintf('!V IAREA %d %d RECTANGLE %d %d %d %d %d %s', ...
    %         round((GetSecs - responseBegins)*1000), round((GetSecs - pressTime)*1000), 13, topTestPosition,'topTest'));
    %     Eyelink('Message', sprintf('!V IAREA %d %d RECTANGLE %d %d %d %d %d %s', ...
    %         round((GetSecs - responseBegins)*1000), round((GetSecs - pressTime)*1000), 14, bottomTestPosition,'bottomTest'));
    
    % Send messages to report trial condition information
    % Each message may be a pair of trial condition variable and its
    % corresponding value follwing the '!V TRIAL_VAR' token message
    % See "Protocol for EyeLink Data to Viewer Integration-> Trial
    % Message Commands" section of the EyeLink Data Viewer User Manual
    WaitSecs(0.001);
    Eyelink('Message', '!V TRIAL_VAR trialNum %d', ttn);
    Eyelink('Message', '!V TRIAL_VAR Congruency %s', congruency(2-ed(ttn).isCongruent));
    Eyelink('Message', '!V TRIAL_VAR Alignment %s', alignment(2-ed(ttn).bottomIsAligned));
    Eyelink('Message', '!V TRIAL_VAR SameDifferent %s', sameDifferent(2-ed(ttn).topIsSame));
    Eyelink('Message', '!V TRIAL_VAR SameDifferent %d', ACC);
    
    %collect eye movement data
    % EyelinkCollectData;

end

%% Save the variable and response
RestrictKeysForKbCheck([]);

output.Trial = ttn;
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