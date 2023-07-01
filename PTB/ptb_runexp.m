function ptb_runexp(param)
% Example of running experiments.
%
% Input:
%    param     experiment parameters. (created by ptb_expname)
%
% Created by Haiyang Jin (2018)

%% Preparation
param.expStartTime = GetSecs;

% stop receiving typed characters
ListenChar(2);

% Initilize the screen
param = ptb_initialize(param);
% initialize EL if needed
if ~isfield(param, 'isEyelink'); param.isEyelink=0; end
if param.isEyelink; param = el_initialize(param); end

% Load stimuli
param.stimuli = ptb_loadstimdir(param.imgDir, param.w);
if isfield(param, 'maskDir')
    param.masks = ptb_loadstimdir(param.maskDir, param.w);
end
% get the information about stimuli and mask
if isfield(param, 'do_stim') && ~isempty(param.do_stim)
    param = param.do_stim(param);
end

% Build the experiment design
if ~isfield(param, 'ed')
    param.ed = ptb_expdesignbuilder(param.conditionsArray, ...
        param.randBlock, param.sortBlock);
    param.tn = size(param.ed, 1);  % trial number
end

% prepare Eyelink AOIs if needed
% create IA files to be displayed in Eyelink
if param.isEyelink && ...
        isfield(param, 'do_iafile') && ~isempty(param.do_iafile)
    param = param.do_iafile(param);
end

% Keys
KbName('UnifyKeyNames');
param.respKeys = arrayfun(@KbName, param.respKeyNames);
param.expKey = KbName(param.expKeyName);
param.instructKey = KbName(param.instructKeyName);
% KbQueue
keyList = zeros(size(KbName('KeyNames')));
keyList(1, [param.respKeys(:)', param.expKey]) = 1;
param.queueKeyList = keyList;

% Instruction
ptb_instruction(param);

% Fixations
param.fixarray = ptb_fixcross(param.screenX, param.screenY, ...
    param.widthFix, param.lengthFix);

%% Do the trial
expStartTime = GetSecs();

dtTable = table;

for ttn = 1 : param.tn  % this trial number

    % run each trial
    [output, quitNow] = param.do_trial(ttn, param);
    dtTable(ttn, :) = struct2table(output, 'AsArray', true);

    % break check
    ptb_checkbreak(ttn, param);

    if (quitNow), break; end
end

% exp end time
expEndTime = GetSecs();

% experiment duration
param.expDuration = expEndTime - expStartTime;


%% Process and save the output
% create the experiment information table
nRowInfo = size(dtTable,1);

if nRowInfo > 1
    ExpAbbv = repmat({param.expAbbv}, nRowInfo, 1);
    ExpCode = repmat({param.expCode}, nRowInfo, 1);
    SubjCode = repmat({param.subjCode}, nRowInfo, 1);
    expInfoTable = table(ExpAbbv, ExpCode, SubjCode);

    % process the output
    param.dtTable = param.do_output(dtTable, expInfoTable);
else
    param.dtTable = '';
end

% save the output
acc = ptb_output(param);


%% Finishing screen
if (~quitNow)
    doneText = sprintf('The current session is finished!\n \nPlease contact the experimenter.');
    ptb_disptext(param, doneText, param.instructKey);
end

if isfield(param, 'record') && param.record
    Screen('FinalizeMovie', param.mvptr);
    Screen('CloseMovie');
end

% quit EL if needed
if param.isEyelink; el_end(param); end
% close all screens
Screen('CloseAll');

% display informations
fprintf('\nThe current session lasts %2.2f minutes.\n', param.expDuration/60);
fprintf('Mean Accuracy: %s\n', num2str(acc, '%2.1f%%'));

% start receiving typed characters
ListenChar(0);

end