function [output, quitNow] = prf_dotrial(ttn, param, stimuli, stimPosi)
% [output, quitNow] = fmri_doblocktrial(ttn, param, stimuli)
%
% Run the fixation blocks and the trials in the stimulus blocks (with
% images). For displaying videos, see fmri_block_dovtrial().
%
% Inputs:
%     ttn            <int> this trial number. if ttn is empty, this
%                     trial/block will be the fixation only task.
%     param          <struct> the experiment parameters.
%     stimuli        <struct> stimuli to be shown in this trial. [only
%                     information of one image is included]
%     stimPosi       <num> 1x2 the position of the stimuli (relative to the
%                     screen center).
%
% Output:
%     output         <struct> this trial information to be saved.
%     quitNow        <boo> 1: quit the experiment. 0: do not quit.
%
% Created by Haiyang Jin (2023-Feb-26)

%% Preparation
% the baseline time for this trial
baseTime = (ttn-1) * param.trialDuration + param.dummyDuration + param.runStartTime;

% get the window index
w = param.w;

% set the default values
quitNow = 0;
checkTime = 0;

isSame = NaN;
ACC = NaN;
RT = NaN;
pressed = '';
correctAns = NaN;
correctAnsBlock = NaN;
ACCBlock = NaN;

% task information
switch param.do_attentaskstr
    case 'prf_nbackletter'
        thestim = param.taskstim{param.subTrialNum, param.BlockNum};
        correctAns = param.answers(param.subTrialNum, param.BlockNum); % stimuli.correctAns;
        correctAnsBlock = sum(param.answers(1:param.subTrialNum,param.BlockNum),'omitnan');
end

%% Display each (sub-)trial
% this stimulus rect and position
[stimY, stimX, ~] = size(stimuli.matrix);
stimRect = [0 0 stimX stimY];
stimXtrg = stimX*param.faceratio;
stimYtrg = stimY*param.faceratio;
stimPosition = [stimPosi(1)-stimXtrg/2+param.screenCenX ...
    stimPosi(2)-stimYtrg/2+param.screenCenY ...
    stimPosi(1)+stimXtrg/2-1+param.screenCenX ...
    stimPosi(2)+stimYtrg/2-1+param.screenCenY];

if isfield(param, 'letterstimuli')
    % get this letter image information
    thisletter = param.letterstimuli(thestim);
    [letterY, letterX, ~] = size(thisletter.matrix);
    letterRect = [0 0 letterX letterY];

    % calculate the ratio
    letterva_pi = ptb_va2pixel(param.lettervva, param.distance, param.pipercm);
    letterratio = letterva_pi/size(thisletter.matrix,1);
    
    % letter image position
    letterXtrg = letterX*letterratio;
    letterYtrg = letterY*letterratio;
    letterPosition = [letterRect(1)-letterXtrg/2+param.screenCenX ...
        letterRect(2)-letterYtrg/2+param.screenCenY ...
        letterRect(1)+letterXtrg/2-1+param.screenCenX ...
        letterRect(2)+letterYtrg/2-1+param.screenCenY];
end

% display the stimulus
ptb_drawcirclearray(param);
Screen('DrawDots', w, param.prfposi2, param.dsize, param.dcolor, ...
    [param.screenCenX, param.screenCenY], 1);
Screen('DrawTexture', w, stimuli.texture, stimRect, stimPosition);
switch param.do_attentaskstr
    case 'fixation'
        Screen('FillRect', w, param.forecolor, param.fixarray);
    case 'prf_nbackletter'
        Screen('DrawDots', w, [0,0], 25, [255;51;51], ...
            [param.screenCenX, param.screenCenY], 1); % red dot background
        if isfield(param, 'letterstimuli')
            Screen('DrawTexture', w, thisletter.texture, letterRect, letterPosition);
        else
            DrawFormattedText(w, thestim, param.screenCenX-7, ...
                param.screenCenY+7, param.forecolor);
%             DrawFormattedText2(['<size=40><color=000000>' thestim], 'win', w, ...
%                 'sx','center','sy','center','xalign','center','yalign','center');
        end
end
stimBeganAt = Screen('Flip', w);

% only response and experimenter keys are allowed
RestrictKeysForKbCheck([param.respKeys(:)', param.expKey]);

% check response while the stimulus is on
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
        ACCBlock = isSame == correctAnsBlock;
        RT = keyTime - stimBeganAt;
        fprintf(' [ACC: %d; BACC: %d]', ACC, ACCBlock);

    end

    % check the time
    checkTime = GetSecs - baseTime;
end

%%%%%%%%%% display the fixation/blank %%%%%%%%%%
switch param.do_attentaskstr
    case 'fixation'
        Screen('FillRect', w, param.forecolor, param.fixarray);
end
ptb_drawcirclearray(param);
Screen('DrawDots', w, param.prfposi2, param.dsize, param.dcolor, ...
    [param.screenCenX, param.screenCenY], 1);
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
        ACCBlock = isSame == correctAnsBlock;
        RT = keyTime - stimBeganAt;
        fprintf(' [ACC: %d; BACC: %d]', ACC, ACCBlock);
    end

    % check the time
    checkTime = GetSecs - baseTime;
end

if isnan(isSame) && correctAns==1
    % missing a key press was treated as incorrect
    ACC = 0;
end
if isnan(isSame) && correctAnsBlock==1
    % missing a key press was treated as incorrect
    ACCBlock = 0;
end

%% trial information to be saved
% trial and block numbers
output.BlockNum = param.BlockNum;
output.SubTrialNum = param.subTrialNum;
output.TrialNum = ttn;

% stimulus onsets
output.StimOnset = stimBeganAt;
output.StimOnsetRela = stimBeganAt - param.runStartTime;
output.StimEndAt = stimEndAt;
output.StimDuration = stimEndAt - stimBeganAt;

% stimulus
output.StimCategory = stimuli.condition;
output.StimName = stimuli.fn;
output.StimXY = size(stimuli.matrix, 1:2);
output.StimPosiRela = stimPosi;
output.StimPosition = stimPosition;
output.apXY = param.canvasxy + output.StimXY;

% responses
output.CorrectAns = correctAns;
output.CorrectAnsBlock = correctAnsBlock;
output.Pressed = pressed;
output.Response = isSame;
output.isCorrect = ACC;
output.isCorrectBlock = ACCBlock;
output.RespTime = RT;

end