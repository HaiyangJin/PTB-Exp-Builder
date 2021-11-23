function fmri_block_runexp(param)
% fmri_block_runexp(param)
%
% This funciton runs an fMRI experiment with block design.
%
% Input:
%     param            <struct> experiment structure
%
% Created by Haiyang Jin (27-Feb-2020)

%% Preparation
param.expStartTime = GetSecs;

% stop receiving typed characters
ListenChar(2);

% Initilize the screen
param = ptb_initialize(param);

% Load stimuli
stimuli = ptb_loadstimdir(param.imgDir, param.w, param.isim);
% get the information about stimuli
if isfield(param, 'do_stim') && ~isempty(param.do_stim)
    [param, stimuli] = param.do_stim(param, stimuli);
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
param.nStimBlock = 0;
param.nFixBlock = 0;
tnStart = 0; % the starting trial number
dtFixTable = table;  % for saving fxiation output later
dtStimTable = table;  % for saving stimulus otuput later

% pre-load KbCheck (the first load takes longer time)
KbCheck;

% display the instruction
ptb_instruction(param);

% wait for trigger if is not emulated
if ~param.isEmulated
    fmri_nyuad;
end

% run starts
param.runStartTime = GetSecs;

% display fixation screen once the run starts (may be helpful)
Screen('FillRect', param.w, param.forecolor, param.fixarray); % param.forecolor
Screen('Flip', param.w);

%% Run blocks
[param.outputDummy, quitNow] = fmri_dummyvol(param);
% quit if experimenter key is pressed
if ~quitNow
    
    for iBlock = 1:nBlock
        
        % if this block is fixation block
        isFixBlock = ismember(iBlock, param.fixBlockNum);
        param.BlockNum = iBlock;
        
        if isFixBlock
            %%%%% do fixation blocks %%%%%
            % the number (index) of fixation blocks
            param.nFixBlock = param.nFixBlock + 1;
            
            % do this fixation block
            [output, quitNow] = param.do_trial([], param, [], ...
                param.runStartTime, isFixBlock);
            
            % save the output
            dtFixTable(param.nFixBlock, :) = struct2table(output, 'AsArray', true);
            
            % quit if experimenter key is pressed
            if quitNow; break; end
            
        else
            %%%%% do stimulus blocks %%%%%
            % the number (index) of fixation blocks
            param.nStimBlock = param.nStimBlock + 1;
            
            % stim for this repetition
            thisRepeStim = param.stimCell{param.ed(tnStart + 1).repeated, 1};
            % stim for this block
            thisBlockStim = thisRepeStim(:, param.ed(tnStart + 1).stimCategory);
            
            for ttn = 1 : param.nStimPerBlock
                % ttn is the trial number within this block
                
                % tn is the tiral number within all stimulus blocks
                tn = tnStart + ttn;
                % stimuli to be used in this trial
                thisStim = stimuli(thisBlockStim(ttn), param.ed(tn).stimCategory);
                
                % the correct answer
                if ttn == 1
                    thisStim.correctAns = NaN;
                else
                    thisStim.correctAns = thisBlockStim(ttn) == thisBlockStim(ttn-1);
                end
                
                % do this trial
                [output, quitNow] = param.do_trial(tn, param, thisStim, ...
                    param.runStartTime, isFixBlock);
                
                % save the output
                dtStimTable(tn, :) = struct2table(output, 'AsArray', true);
                
                % quit if experimenter key is pressed
                if quitNow; break; end
            end % ttn
            
            % update the start trial number (within all stimulus blocks)
            tnStart = tn;
            
        end % isFixBlock
        % quit if experimenter key is pressed
        if quitNow; break; end
    end % iBlock
end % quitNow

% run finishes
param.runEndTime = GetSecs;
param.runDuration = param.runEndTime - param.runStartTime;

%% Finishing screen
if ~quitNow
    doneText = sprintf('This part is finished.');
    DrawFormattedText(param.w, doneText, 'center', 'center', param.forecolor);
    Screen('Flip', param.w);
end

%% Process the outputs
if isempty(dtStimTable)
    % if quit at first fixation...
    param.dtTable = '';
else
    
    % add the repetition column
    dtFixTable.Repetitions = NaN(size(dtFixTable, 1), 1);
    dtStimTable.Repetitions = ceil(dtStimTable.SubBlockNum/param.nStimCat);
    
    % combine fixation and stimulus tables
    dtTable = vertcat(dtFixTable, dtStimTable);
    
    % create the experiment information table
    nRowInfo = size(dtTable,1);
    
    ExpAbbv = repmat({param.expAbbv}, nRowInfo, 1);
    ExpCode = repmat({param.expCode}, nRowInfo, 1);
    SubjCode = repmat({param.subjCode}, nRowInfo, 1);
    RunCode = repmat({num2str(param.runCode)}, nRowInfo, 1);
    TrialNum = transpose(1:size(dtTable, 1));
    RunStartTime = repmat(param.runStartTime, nRowInfo, 1);
    RunEndTime = repmat(param.runEndTime, nRowInfo, 1);
    DummyDuration = repmat(param.dummyDuration, nRowInfo, 1);
    
    expInfoTable = table(ExpAbbv, ExpCode, SubjCode, RunCode, ....
        RunEndTime, TrialNum, RunStartTime, DummyDuration);
    
    % process the output
    param.dtTable = param.do_output(sortrows(dtTable, 'StimOnset'), expInfoTable);
    
end

% save the output
param.expEndTime = GetSecs;
param.expDuration = param.expEndTime - param.expStartTime;
[acc, nResp] = ptb_output(param, sprintf('Run%d', param.runCode), param.outpath);

% save par files used in FreeSurfer
fmri_parevent(param.dtTable, 'outpath', param.outpath);

%% Finishing...
% close all screens
Screen('CloseAll');

% display run durations
fprintf('\nThis run lasted %2.2f minutes (%.3f seconds).\n', ...
    param.runDuration/60, param.runDuration);

% display behvioral responses
fprintf('%d responses were detected (Accuracy: %2.1f%%).\n', nResp, acc);

% start receiving typed characters
ListenChar(0);

end