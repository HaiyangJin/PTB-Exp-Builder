function [output, quitNow] = do_trial(ttn, param, stimuli)
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

%% Independent variables
IV1 = {'11', '12', '13', '14'};
IV2 = {'20', '21'};

% experiment design
ed = param.ed;

iv1 = ed(ttn).IV1;
iv2 = ed(ttn).IV2;

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
RestrictKeysForKbCheck([param.respKeys, param.expKey]);  % , KbName('5')
[pressTime, keyCode] = KbWait([],0);

% quit if the experimenter key is pressed
if any(keyCode(param.expKey))
    quitNow = 1;
end

% trial is finished.
trialEndedAt = Screen('Flip',param.w);
totalTrialDuration = trialEndedAt - trialBeginsAt;

%%%%%%%%%% Post-processing %%%%%%%%%%
if sum(keyCode(param.respKeys))==1 
    Resp = mod(find(keyCode(param.respKeys))-1,2)+1;
    ACC = double(Resp == correctAns);
    reactionTime = pressTime - responseBegins;
    
else
    
    if quitNow
        ACC = 0; 
        noResponseText = 'Press any key to quit the program.';
    else
        ACC = NaN;
        noResponseText = 'Something wrong happens. Press any key.';
    end
    
    % wrong key, double key or timeout
    Resp = '';
    reactionTime = NaN;
    beep;
    DrawFormattedText(param.w, noResponseText, 'center', 'center', param.forecolor);
    Screen('Flip',param.w);
    RestrictKeysForKbCheck([]);
    KbWait([], 2);
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