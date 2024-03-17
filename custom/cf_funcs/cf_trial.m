function [output, quitNow] = cf_trial(ttn, param)
% [output, quitNow] = cf_trial(ttn, param)
%
% do the trial for composite face task.
%
% Inputs:
%     ttn         <num> this trial number
%     param       <struct> parameters about this experiment
%
% Outputs:
%     output      <struct> the output of this trial
%     quitNow     <boo> quit after this trial
%
% Created by Haiyang Jin (2020-Feb-10)

% gather information from param
stimuli = param.stimuli;
masks = param.masks;  % the masks structure
ed = param.ed(ttn);  % experiment design
w = param.w; % window
flipSlack = param.flipSlack;
forecolor = param.forecolor;
respKeys = param.respKeys;
alpha = param.alpha;

isUpright = 1;
if isfield(ed, 'isUpright')
    isUpright = ed.isUpright;
end
orieAngle = (1-isUpright)*180;

% preparation for KbQuene
KbQueueCreate([], param.queueKeyList);

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

% top and bottom positions
if isUpright
    faceTopPosition = param.faceTopPosition;
    faceBottomPosition = param.faceBottomPosition;
else
    faceTopPosition = param.faceBottomPosition;
    faceBottomPosition = param.faceTopPosition;
end

% Random offset for test faces
offsets = -param.nOffset : param.nOffset;
xOffsetRand = offsets(randperm(numel(offsets),1))*5; %
yOffsetRand = offsets(randperm(numel(offsets),1))*5; %

alignTestOffset = param.faceX * param.misalignPerc * (1-ed.isTestAligned);

% study faces offset
xStudyTopOffset = alignTestOffset * (1-ed.isTopCued) * param.isStudyOffset;
xStudyBottomOffset = alignTestOffset * ed.isTopCued * param.isStudyOffset;
yStudyTopOffset = 0;
yStudyBottomOffset = 0;

% test faces offset
xTestTopOffset = xOffsetRand + alignTestOffset * (1-ed.isTopCued);
xTestBottomOffset = xOffsetRand + alignTestOffset * ed.isTopCued;
yTestTopOffset = yOffsetRand;
yTestBottomOffset = yOffsetRand;

% test cues & offset
yTestCue = yOffsetRand + (-2*ed.isTopCued+1) * (2*isUpright-1) * ...
    (param.cuePosition+param.faceY/2);
yTestCueLR = yTestCue + (2*ed.isTopCued-1) * (2*isUpright-1) * ...
    param.cueSideLength/2;

% trial began time
trialBeginsAt = GetSecs;

%% Show the stimuli
%%% Fixation %%%
Screen('FillRect', w, forecolor, param.fixarray);

fixationBeganAt = Screen('Flip', w);
blankBeginsWhen = fixationBeganAt + param.fixDuration - flipSlack;

%%% blank %%%
blankBeganAt = Screen('Flip', w, blankBeginsWhen);
studyBeginWhen = blankBeganAt + param.blankDuration - flipSlack ;

%%% Study Face %%%
% Preparation for study face
topStudyPosition = OffsetRect(faceTopPosition, ...
    xStudyTopOffset,yStudyTopOffset);
bottomStudyPosition = OffsetRect(faceBottomPosition,...
    xStudyBottomOffset,yStudyBottomOffset);

Screen('DrawTexture', w, faceStudyTop.texture, param.faceTopRect,...
    topStudyPosition, orieAngle, [], alpha);
Screen('DrawTexture', w, faceStudyBott.texture, param.faceBottomRect,...
    bottomStudyPosition, orieAngle, [], alpha);
Screen('FillRect', w, forecolor, param.lineRect);

% draw study face
studyBeganAt = Screen('Flip', w, studyBeginWhen);
maskBeginWhen = studyBeganAt + param.studyDuration - flipSlack;

%%% mask %%%
maskTexture = masks(ed.maskID).texture;
Screen('DrawTexture', w, maskTexture,[], OffsetRect(param.maskDestRect, xOffsetRand, yOffsetRand));

if param.showCue
    Screen('FillRect', w, forecolor, OffsetRect(param.cuePosi, xOffsetRand, yTestCue));
    Screen('FillRect', w, forecolor, OffsetRect(param.cuePosiL, xOffsetRand, yTestCueLR));
    Screen('FillRect', w, forecolor, OffsetRect(param.cuePosiR, xOffsetRand, yTestCueLR));
end

maskBeganAt = Screen('Flip', w, maskBeginWhen);
testBeginWhen = maskBeganAt + param.maskDuration - flipSlack;

%%% test face %%%
topTestPosition = OffsetRect(faceTopPosition, xTestTopOffset, yTestTopOffset);
bottomTestPosition = OffsetRect(faceBottomPosition, ...
    xTestBottomOffset, yTestBottomOffset);

Screen('DrawTexture', w, faceTestTop.texture, param.faceTopRect,...
    topTestPosition, orieAngle, [], alpha);
Screen('DrawTexture', w, faceTestBott.texture, param.faceBottomRect,...
    bottomTestPosition, orieAngle, [], alpha);
Screen('FillRect', w, forecolor, OffsetRect(param.lineRect, xOffsetRand, yOffsetRand));

if param.showCue
    Screen('FillRect', w, forecolor, OffsetRect(param.cuePosi, xOffsetRand, yTestCue));
    Screen('FillRect', w, forecolor, OffsetRect(param.cuePosiL, xOffsetRand, yTestCueLR));
    Screen('FillRect', w, forecolor, OffsetRect(param.cuePosiR, xOffsetRand, yTestCueLR));
end

testBeganAt = Screen('Flip', w, testBeginWhen);
respScreenBeginWhen = testBeganAt + param.testDuration - flipSlack;
respMaxDuration = testBeganAt + param.respMaxDuration - flipSlack;

%%%%%% start to collect responses %%%%%
KbQueueStart();
pressed = 0;
while GetSecs < respScreenBeginWhen && ~pressed
    [pressed, firstPress] = KbQueueCheck();
end

%%% Response screen %%%
if ~pressed
    [pressed, firstPress] = KbQueueCheck();
    DrawFormattedText(w, sprintf('Respond?'), 'center', 'center', forecolor);
    Screen('Flip', w);
end

while ~pressed && GetSecs < respMaxDuration
    [pressed, firstPress] = KbQueueCheck();
end

KbQueueRelease();
%%%%% Stop to collect responses %%%%%%

% trial is finished.
trialEndedAt = Screen('Flip',w);
totalTrialDuration = trialEndedAt - trialBeginsAt;

%% postprocessing
if sum(firstPress(respKeys)>0, 'all')==1 
    % process responses
    reactionTime = sum(firstPress(respKeys), 'all') - testBeganAt;
    Resp = find(sum(firstPress(respKeys)>0)); % 1-same, 2-different
    ACC = double( Resp == 2-ed.isCuedSame );
else
    % wrong key, double keys or timeout
    Resp = NaN;
    ACC = NaN; 
    reactionTime = NaN;
    
    if any(firstPress(param.expKey))  % quit as expKey is pressed
        quitNow = 1;
        noRespText = sprintf(['The experiment will quit now. \n\n'...
            'Please press any key to continue...']);
    elseif ~pressed
        noRespText = sprintf(['Please respond as quickly and accurately as possible. \n\n'...
            'Please press any key to continue...']);
    else
        noRespText = sprintf(['Something wrong happended... \n\n'...
            'Please press any key to continue...']);
    end
    beep;
    ptb_disptext(param, noRespText);
end

% display feedback if necessary
if param.isFeedback
    ptb_feedback(ACC, param);
end

%% Clean up
RestrictKeysForKbCheck([]);

output.Trial = ttn;
output.Orientation = isUpright;
output.Cue = ed.isTopCued;
output.Congruency = ed.isCongruent;
output.Alignment = ed.isTestAligned;
output.SameDifferent = ed.isCuedSame;
output.FaceGroup = {stimuli(thisFaceSet(1), ed.faceGroup).condition};
output.StudyTop = {faceStudyTop.fn};
output.StudyBottom = {faceStudyBott.fn};
output.TestTop = {faceTestTop.fn};
output.TestBottom = {faceTestBott.fn};
output.Resp = Resp;
output.keyPressed = {KbName(firstPress)};  % the name of pressed key
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