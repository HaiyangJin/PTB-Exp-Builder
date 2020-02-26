function [output, quitNow] = fmri_doblocktrial(ttn, param, stimuli, ...
    runStartTime, isFixBlock)


if nargin < 1 || isempty(ttn)
    ttn = 0;
    isFixBlock = 1;
    
    baseTime = (param.BlockNum - 1) * param.blockDuration;
else
    
    baseTime = param.nFixBlock * param.blockDuration + (ttn-1) * param.trialDuration;
end

if nargin < 4 || isempty(runStartTime)
    runStartTime = param.runStartTime;
end

if nargin < 5 || isempty(isFixBlock)
    isFixBlock = 0;
end

quitNow = 0;
w = param.w;
forecolor = param.forecolor;
checkTime = 0;


if isFixBlock
    %% Fixation only blocks
    %%% Fixation %%%
    Screen('FillRect', w, forecolor, param.fixarray);
    stimBeganAt = Screen('Flip', w);
    
    % process some trial information
    subBlockNum = param.nFixBlock;
    stimCategory = 0; % 'fixation'
    stimName = '';
    
    while checkTime < param.blockDuration
        checkTime = GetSecs - runStartTime - baseTime;
        % add checking keys later....
    end
    
    stimEndAt = checkTime; % (roughly)
    
else
    %% Stimulus trials
    
    [imgY, imgX] = size(stimuli.matrix);
    stimRect = [0 0 imgX imgY];
    stimPosition = CenterRect([0 0 imgX imgY], param.screenRect);
    
    % display the stimulus
    Screen('DrawTexture', w, stimuli.texture, stimRect,...
        stimPosition, [], []);
    stimBeganAt = Screen('Flip', w);
    
    % process some trial information
    subBlockNum = param.nStimBlock;
    stimCategory = stimuli.condition; % to be updated
    stimName = stimuli.fn;
    
    while checkTime < param.stimDuration
        checkTime = GetSecs - runStartTime - baseTime;
        % add checking keys later....
    end
    
    % display the fixation
    Screen('FillRect', w, forecolor, param.fixarray);
    stimEndAt = Screen('Flip', w);
    
    while checkTime < param.trialDuration
        checkTime = GetSecs - runStartTime - baseTime;
        % add checking keys later....
    end
    
    
end

output.BlockNum = param.BlockNum;
output.SubBlockNum = subBlockNum;
output.SubTrialNum = ttn;

output.StimOnset = stimBeganAt;
output.StimOnsetRela = stimBeganAt - runStartTime;
output.StimEndAt = stimEndAt;
output.StimDuration = stimEndAt - stimBeganAt;
output.StimCateogry = stimCategory;

output.StimName = stimName;

end