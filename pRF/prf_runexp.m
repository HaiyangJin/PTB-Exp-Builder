function prf_runexp(param)
% prf_runexp(param)
%
% This funciton runs an fMRI experiment with pRF design (stimulus version;
% not retinotopic mapping).
%
% Input:
%     param            <struct> experiment structure.
%
% Created by Haiyang Jin (2023-Feb-25)

%% Preparation
param.expStartTime = GetSecs;

% stop receiving typed characters
ListenChar(2);

% Initilize the screen
param = ptb_initialize(param);

% Load stimuli
param.stimuli = ptb_loadstimdir(param.imgDir, param.w);
% Build the experiment design
[param.ed, param.tn, param.bn] = ptb_expdesignbuilder( ...
    param.conditionsArray, ...
    param.sortBlock);

% get the information about stimuli
if isfield(param, 'do_stim') && ~isempty(param.do_stim)
    param = param.do_stim(param);
end
% apply additional function to ed if needed
if isfield(param, 'do_ed') && ~isempty(param.do_ed)
    param = param.do_ed(param);
end
if isfield(param, 'do_attentask') && ~isempty(param.do_attentask)
    % generate stimuli for extra task (attention)
    param = param.do_attentask(param);
    param.do_attentaskstr = func2str(param.do_attentask);
else
    param.do_attentaskstr = 'fixation';
end
% generate the stimulus positions
param = prf_stimposi(param);

% Fixations
param.fixarray = ptb_fixcross(param.screenX, param.screenY, ...
    param.widthFix, param.lengthFix);

% Keys
KbName('UnifyKeyNames');
param.respKeys = arrayfun(@KbName, param.respKeyNames);
param.expKey = KbName(param.expKeyName);
param.instructKey = KbName(param.instructKeyName);

% initialize the output
dtStimTable = table;  % for saving stimulus otuput later

% pre-load KbCheck (the first load takes longer time)
KbCheck;

% display the instruction
ptb_instruction(param);

% wait for trigger if is not emulated
if ~param.isEmulated
    param.do_trigger('on');
    param.do_trigger('trigger');
end

% run starts
param.runStartTime = GetSecs;

% display fixation screen once the run starts (may be helpful)
Screen('FillRect', param.w, param.forecolor, param.fixarray); % param.forecolor
Screen('Flip', param.w);

%% Run blocks
% fixations at the beginning
[outDummy, quitNow] = fmri_dummyvol(param, param.runStartTime);
dummyTable = struct2table(outDummy, 'AsArray', true);
dummyTableEnd = table; % save fixation data (before)

% quit if experimenter key is pressed
if ~quitNow

    for iBlock = 1:param.tn+param.fixBlockN

        param.BlockNum = iBlock;
        thisPosi = param.prfposi{param.alled(iBlock).stimPosiY, ...
            param.alled(iBlock).stimPosiX};

        for tn = 1 : param.nStimPerBlock
            
            % tn is the trial number within this block
            param.subBlockNum = tn;

            % stimuli to be used in this trial
            thisStim = param.stimuli(tn, iBlock);

            % do this trial
            ttn = (iBlock-1)*param.nStimPerBlock + tn; % overall trial number
            [output, quitNow] = param.do_trial(ttn, param, thisStim, thisPosi);

            % save the output
            dtStimTable(ttn, :) = struct2table(output, 'AsArray', true);

            % quit if experimenter key is pressed
            if quitNow; break; end
        end % ttn

    % quit if experimenter key is pressed
    if quitNow; break; end
    end % iBlock
end % quitNow

% fixations at the end of the experiment
if ~quitNow
    basetime = (param.tn+param.fixBlockN) * param.stimBloDuration + ...
        param.dummyDuration + param.runStartTime;
    [outDummyEnd, quitNow] = fmri_dummyvol(param, basetime);
    dummyTableEnd = struct2table(outDummyEnd, 'AsArray', true);
end

%% Finishing screen
% run finishes
if ~quitNow
    doneText = sprintf('This part is finished.');
    DrawFormattedText(param.w, doneText, 'center', 'center', param.forecolor);
    param.runEndTime = Screen('Flip', param.w);
else
    param.runEndTime = GetSecs;
end

param.runDuration = param.runEndTime - param.runStartTime;

%% Process the output
if isempty(dtStimTable)
    % if quit at first fixation...
    param.dtTable = '';
else

    % combine fixation and stimulus tables
    tmpTable = outerjoin(dtStimTable, dummyTable, 'MergeKeys',true);
    dtTable = outerjoin(tmpTable, dummyTableEnd, 'MergeKeys',true);

    % create the experiment information table
    nRowInfo = size(dtTable,1);

    ExpAbbv = repmat({param.expAbbv}, nRowInfo, 1);
    ExpCode = repmat({param.expCode}, nRowInfo, 1);
    SubjCode = repmat({param.subjCode}, nRowInfo, 1);
    RunCode = repmat({num2str(param.runCode)}, nRowInfo, 1);
    TrialNum = transpose(1:size(dtTable, 1));
    RunStartTime = repmat(param.runStartTime, nRowInfo, 1);
    RunEndTime = repmat(param.runEndTime, nRowInfo, 1);

    expInfoTable = table(ExpAbbv, ExpCode, SubjCode, RunCode, ....
        RunEndTime, TrialNum, RunStartTime);

    % process the output
    param.dtTable = param.do_output(sortrows(dtTable, 'StimOnset'), expInfoTable);

end

% save the output
param.expEndTime = GetSecs;
param.expDuration = param.expEndTime - param.expStartTime;
[acc, nResp] = ptb_output(param, sprintf('Run%d', param.runCode), param.outpath);

% save par files used in FreeSurfer
fmri_parevent(param, 'outpath', param.outpath);

%% Finishing...
% colse vpixx
if ~param.isEmulated
    param.do_trigger('off');
end

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