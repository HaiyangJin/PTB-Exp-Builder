function [output, quitNow] = Do_Trial(ttn, param, stimuli, quitNow)


%% Independent variables
IV1 = {'11', '12', '13', '14'};
IV2 = {'20', '21'};

ed = param.ed;

iv1 = ed(ttn).IV1;
iv2 = ed(ttn).IV2;

correctAns = 1;

%% Do the trial
trialBeginsAt = GetSecs;
%%%%%%%%%%%%%% fixation %%%%%%%%%%%%%%
Screen('FillRect', param.w, param.forecolor, param.fixarray);

fixationBeganAt = Screen('Flip', param.w);
testBeginsWhen = fixationBeganAt + param.fixDuration - param.flipSlack;


%%%%%%%%%%%%%% response %%%%%%%%%%%%%%
responseBegins = Screen('Flip', param.w, testBeginsWhen);

%%%%%%%%%% Response (keys) %%%%%%%%%%
RestrictKeysForKbCheck([param.respKeys, param.expKey]);  % , KbName('5')
[pressTime, keyCode] = KbWait([],0);

% quit if F12
if keyCode(param.expKey)
    quitNow = 1;
end

% trial is finished.
trialEndedAt = Screen('Flip',param.w);
totalTrialDuration = trialEndedAt - trialBeginsAt;

%%%%%%%%%% Post-processing %%%%%%%%%%
if sum(keyCode(para.responseKeys))==1 
    Resp = mod(find(keyCode(para.respKeys))-1,2)+1;
    ACC = double(Resp == correctAns);
    reactionTime = pressTime - responseBegins;
    
else
    % wrong key, double key or timeout
    Resp = '';
    if quitNow; ACC = 0; else ACC = NaN; end
    reactionTime = NaN;
    beep;
    noResponseText = 'Something wrong happens. Press any key.';
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