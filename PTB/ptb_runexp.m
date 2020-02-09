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

% Build the experiment design
param.ed = ptb_expdesignbuilder(param.conditionsArray, param.blockByCondition);
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
param.fixarray = ptb_fixcross(param.screenX, param.screenY, param.widthFix, param.lengthFix);

%% Do the trial
expStartTime = GetSecs();
% dtStruct = struct;

for ttn = 1 : param.tn  % this trial number 
    
    % run each trial
    [output, quitNow] = do_trial(ttn, param, stimuli);
    dtStruct(ttn) = output; %#ok<AGROW>
    
    % break check
    ptb_checkbreak(ttn, param);
    
    if (quitNow), break; end
end

% exp end time
expEndTime = GetSecs();

% create the experiment information table
nRow_Info = length(dtStruct);
ExperimentAbbv = repmat({param.expAbbv}, nRow_Info, 1);
ExpCode = repmat({param.expCode}, nRow_Info, 1);
SubjCode = repmat({param.subjCode}, nRow_Info, 1);
expInfoTable = table(ExperimentAbbv, ExpCode, SubjCode);

% combine the exp information table and data table
if numel(dtStruct) > 1
    param.dtTable = [expInfoTable, struct2table(dtStruct)];
else
    param.dtTable = [];
end

%% Finishing
if (~quitNow)
    breakText = sprintf('The current session is finished!\n \nPlease contact the experimenter.');
    DrawFormattedText(param.w, breakText, 'center', 'center', param.forecolor);
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