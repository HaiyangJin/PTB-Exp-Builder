function [output, quitNow] = cf_trial(ttn, param, stimuli)
% do the trial for composite face task.
%
% Inputs:
%     ttn         <double> this trial number
%     param       <structure> parameters about this experiment
%     stimuli     <structure> stimuli structure
%
% Outputs:
%     output      <structure> the output of this trial
%     quitNow     <logical> quit after this trial
%
% Created by Haiyang Jin (10-Feb-2020)

% gather information from param
% masks = param.masks;  % the masks structure
ed = param.ed(ttn);  % experiment design
w = param.w; % window
flipSlack = param.flipSlack;
forecolor = param.forecolor;
respKeys = param.respKeys;
alpha = param.alpha;

quitNow = 0;

%% Conditions generation
trialType = 1 + 4*(1-ed.isTopCued) + 2*(1-ed.isCongruent) + ...
    (1-ed.isCuedSame);
thisFaceSet = mod((ed.faceIndex + param.faceSelector(trialType, :)-1),...
    param.nFacePerGroup)+1;

faceStudyTop = stimuli(thisFaceSet(1),ed.faceGroup);
faceStudyBott = stimuli(thisFaceSet(2),ed.faceGroup);
faceTestTop = stimuli(thisFaceSet(3),ed.faceGroup);
faceTestBott = stimuli(thisFaceSet(4),ed.faceGroup);

% Random offset for test faces
offsets = -param.nOffset : param.nOffset;
xOffsetRand = offsets(randperm(numel(offsets),1))*5; %
yOffsetRand = offsets(randperm(numel(offsets),1))*5; %

alignTestOffset = param.faceX * param.misalignPerc * (1-ed.isTestAligned);

xStudyTopOffset = 0;
yStudyTopOffset = 0;
yStudyBottomOffset = 0;
xStudyBottomOffset = 0;

xTestTopOffset = xOffsetRand + alignTestOffset * (1-ed.isTopCued);
xTestBottomOffset = xOffsetRand + alignTestOffset * ed.isTopCued;
yTestTopOffset = yOffsetRand;
yTestBottomOffset = yOffsetRand;

% trial began time
trialBeginsAt = GetSecs;

%% show the stimuli

%%% Fixation %%%
Screen('FillRect', w, forecolor, param.fixarray);

fixationBeganAt = Screen('Flip', w);
blankBeginsWhen = fixationBeganAt + param.fixDuration - flipSlack;

%%% blank %%%
blankBeganAt = Screen('Flip', w, blankBeginsWhen);
studyBeginWhen = blankBeganAt + param.blankDuration - flipSlack ;

%%% Study Face %%%
% Preparation for study face
topStudyPosition = OffsetRect(param.faceTopPosition, ...
    xStudyTopOffset,yStudyTopOffset);
bottomStudyPosition = OffsetRect(param.faceBottomPosition,...
    xStudyBottomOffset,yStudyBottomOffset);

Screen('DrawTexture', w, faceStudyTop.texture, param.faceTopRect,...
    topStudyPosition, [], [], alpha);
Screen('DrawTexture', w, faceStudyBott.texture, param.faceBottomRect,...
    bottomStudyPosition, [], [], alpha);
Screen('FillRect', w, forecolor, param.lineRect);

% draw study face
studyBeganAt = Screen('Flip', w, studyBeginWhen);
maskBeginWhen = studyBeganAt + param.studyDuration - flipSlack;

%%% mask %%%
% maskTexture = masks(ed.maskID).texture;
% Screen('DrawTexture',window,maskTexture,[],maskDestRect);

maskBeganAt = Screen('Flip', w, maskBeginWhen);
testBeginWhen = maskBeganAt + param.maskDuration - flipSlack;

%%% test face %%%
topTestPosition = OffsetRect(param.faceTopPosition, xTestTopOffset, yTestTopOffset);
bottomTestPosition = OffsetRect(param.faceBottomPosition, ...
    xTestBottomOffset, yTestBottomOffset);

Screen('DrawTexture', w, faceTestTop.texture, param.faceTopRect,...
    topTestPosition, [], [], alpha);
Screen('DrawTexture', w, faceTestBott.texture, param.faceBottomRect,...
    bottomTestPosition, [], [], alpha);
Screen('FillRect', w, forecolor, OffsetRect(param.lineRect, xOffsetRand, yOffsetRand));

responseBegins = Screen('Flip', w, testBeginWhen);

%%% Keys %%%
RestrictKeysForKbCheck([respKeys(:)', param.expKey]);  
[pressTime, keyCode] = KbWait([],0);

% quit if F12
if any(keyCode(param.expKey))
    quitNow = 1;
end

% trial is finished.
trialEndedAt = Screen('Flip',w);
totalTrialDuration = trialEndedAt - trialBeginsAt;

%% postprocessing
if sum(sum(keyCode(respKeys)))==1
    % process responses
    Resp = find(sum(keyCode(respKeys)));  % 1-same, 2-different
    ACC = double( Resp == 2-ed.isCuedSame );
    reactionTime = pressTime - responseBegins;
else
    % wrong key, double key or timeout
    Resp = NaN;
    if quitNow
        ACC = 0; 
        noRespText = sprintf(['The experiment will quit now. \n\n'...
            'Please press any key to continue...']);
    else
        ACC = NaN; 
        noRespText = sprintf(['Something wrong happended... \n\n'...
            'Please press any key to continue...']);
    end
    reactionTime = NaN;
    beep;
    DrawFormattedText(w, noRespText,'center','center',forecolor);
    Screen('Flip',w);
    RestrictKeysForKbCheck([]);
    KbWait([], 2);
end

% display feedback if necessary
if param.isFeedback
    ptb_feedback(ACC, param.w);
end

%% Clean up
RestrictKeysForKbCheck([]);

output.Trial = ttn;
output.Cue = ed.isTopCued;
output.Congruency = ed.isCongruent;
output.Alignment = ed.isTestAligned;
output.SameDifferent = ed.isCuedSame;
output.FaceGroup = stimuli(thisFaceSet(1), ed.faceGroup).condition;
output.StudyTop = faceStudyTop.filename;
output.StudyBottom = faceStudyBott.filename;
output.TestTop = faceTestTop.filename;
output.TestBottom = faceTestBott.filename;
output.thisResponse = Resp;
output.isCorrect = ACC;
output.reactionTime = reactionTime;
output.studyDuration = param.studyDuration;
output.maskDuration = param.maskDuration;
output.topStudyOffset = [xStudyTopOffset,yStudyTopOffset];
output.bottomStudyOffset = [xStudyBottomOffset,yStudyBottomOffset];
output.topTestOffset = [xTestTopOffset, yTestTopOffset];
output.bottomTestOffset = [xTestBottomOffset, yTestBottomOffset];
output.TrialDuration = totalTrialDuration;
output.trialEndTime = datestr(now,'yyyy-mm-dd-HH:MM:SS');

% trial intervals
WaitSecs(param.ITInterval);