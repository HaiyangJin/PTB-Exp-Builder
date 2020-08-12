function [output, quitNow] = example1_trial(ttn, param)
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

%% Do the trial
trialBeginsAt = GetSecs;

%%%%%%%%%%%%%% fixation %%%%%%%%%%%%%%
Screen('FillRect', param.w, param.forecolor, param.fixarray);

fixationBeganAt = Screen('Flip', param.w);
stimBeginsWhen = fixationBeganAt + param.fixDuration - param.flipSlack;

%%%%%%%%%%%%%% stimuli %%%%%%%%%%%%%%
Screen('DrawTexture', param.w, stimuli(ttn).texture,[]); %OffsetRect(faceTopRect,100*(1-ed(ttn).isAligned)*(1-ed(ttn).topIsCued),0)
stimBeganAt = Screen('Flip', param.w, stimBeginsWhen);
respBeginsWhen = stimBeganAt + param.stimDuration - param.flipSlack;

%%%%%%%%%%%%%% response %%%%%%%%%%%%%%
responseBegins = Screen('Flip', param.w, respBeginsWhen);

%%%%%%%%%% Response (keys) %%%%%%%%%%
RestrictKeysForKbCheck([respKeys(:)', param.expKey]);  % , KbName('5')
[pressTime, keyCode] = KbWait([],0);

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
    DrawFormattedText(param.w, noRespText, 'center', 'center', param.forecolor);
    Screen('Flip',param.w);
    RestrictKeysForKbCheck([]);
    KbWait([], 2);
end

% display feedback if necessary
if param.isFeedback
    ptb_feedback(ACC, param.w);
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

end