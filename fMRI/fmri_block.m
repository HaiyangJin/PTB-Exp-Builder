function fmri_block(param)



%% Preparation
param.expStartTime = now();

% stop receiving typed characters
ListenChar(2);

% Initilize the screen
param = ptb_initialize(param);

% Load stimuli
stimuli = ptb_loadstimdir(param.imgDir, param.w);
% get the information about stimuli
if isfield(param, 'do_stim') && ~isempty(param.do_stim)
    param = param.do_stim(param, stimuli);
end

% Build the experiment design
[param.ed, param.tn, param.bn] = ptb_expdesignbuilder(param.conditionsArray, ...
    param.randBlock, param.sortBlock);

% Fixations
param.fixarray = ptb_fixcross(param.screenX, param.screenY, ...
    param.widthFix, param.lengthFix);

% Keys
KbName('UnifyKeyNames');
param.respKeys = arrayfun(@KbName, param.respKeyNames);
param.expKey = KbName(param.expKeyName);
param.instructKey = KbName(param.instructKeyName);

% block information
nBlock = param.bn + numel(param.fixBlockNum);
param.blockDuration = param.trialDuration * param.nStimPerBlock;
param.nStimBlock = 0;
param.nFixBlock = 0;
tnStart = 0; % the starting trial number

% display the instruction
ptb_instruction(param);
% run starts
param.runStartTime = GetSecs;

%% Run blocks

for iBlock = 1:nBlock
    
    % if this block is fixation block
    isFixBlock = ismember(iBlock, param.fixBlockNum);
    param.BlockNum = iBlock;
    
    if isFixBlock
        % do fixation blocks
        param.nFixBlock = param.nFixBlock + 1;
        [output, quitNow] = param.do_trial([], param, [], ...
            param.runStartTime, isFixBlock);
        
    else
        % do stimuli blocks
        param.nStimBlock = param.nStimBlock + 1;
        
        % stim for this repetition
        thisRepeStim = param.stimCell{param.ed(tnStart + 1).repeated, 1};
        % stim for this block
        thisBlockStim = thisRepeStim(:, param.ed(tnStart + 1).stimCategory);
        
        for ttn = 1 : param.nStimPerBlock
            
            tn = tnStart + ttn;
            
            thisStim = stimuli(thisBlockStim(ttn), param.ed(tn).stimCategory);
            
            [output, quitNow] = param.do_trial(tn, param, thisStim, ...
                param.runStartTime, isFixBlock);
            
        end
        
        % update the start trial number
        tnStart = tn;
        
    end
    
end

% run finishes
param.runEndTime = GetSecs;

%% output
% runstart time
% the whole trial number
% repeated number
% param.expCode = '999';
% param.expAbbv = 'fMRI_block';

param.runDuration = param.runEndTime - param.runStartTime;
fprintf('\nThe current run lasts %2.2f minutes (%.3f seconds).\n', ...
    param.runDuration/60, param.runDuration); 


% start receiving typed characters
sca;
ListenChar(0);

end