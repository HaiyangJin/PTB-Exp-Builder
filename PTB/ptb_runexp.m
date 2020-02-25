function ptb_runexp(param)
% Example of running experiments.
%
% Input:
%    param     experiment parameters. (created by ptb_expname)
%
% Created by Haiyang Jin (2018)

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
param.ed = ptb_expdesignbuilder(param.conditionsArray, ...
    param.randBlock, param.sortBlock);
param.tn = size(param.ed, 1);  % trial number

% Keys
KbName('UnifyKeyNames');
param.respKeys = arrayfun(@KbName, param.respKeyNames);
param.expKey = KbName(param.expKeyName);
param.instructKey = KbName(param.instructKeyName);

% Instruction
ptb_instruction(param);
% DrawFormattedText(param.w, param.instructText, 'center', 'center', param.forecolor);
% Screen('Flip', param.w);
% RestrictKeysForKbCheck(param.instructKey);
% KbWait([],2);

% Fixations
param.fixarray = ptb_fixcross(param.screenX, param.screenY, ...
    param.widthFix, param.lengthFix);

%% Do the trial
expStartTime = GetSecs();

dtTable = table;

for ttn = 1 : param.tn  % this trial number 
    
    % run each trial
    [output, quitNow] = param.do_trial(ttn, param, stimuli);
    dtTable(ttn, :) = struct2table(output); 
    
    % break check
    ptb_checkbreak(ttn, param);
    
    if (quitNow), break; end
end

% exp end time
expEndTime = GetSecs();

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

%% Finishing
if (~quitNow)
    doneText = sprintf('The current session is finished!\n \nPlease contact the experimenter.');
    DrawFormattedText(param.w, doneText, 'center', 'center', param.forecolor);
    Screen('Flip', param.w);
    RestrictKeysForKbCheck(param.instructKey);
    KbWait([],2);
    clear doneText;
end

% experiment duration
param.expDuration = expEndTime - expStartTime;

% close all screens
Screen('CloseAll');

%% Saving the output
acc = ptb_output(param, stimuli);

fprintf('\nThe current session lasts %2.2f minutes.\n', param.expDuration/60); 
fprintf('Mean Accuracy: %s\n', num2str(acc, '%2.1f%%'));

% start receiving typed characters
ListenChar(0);

end