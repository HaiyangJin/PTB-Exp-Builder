function ptb_runexp(param)

%% Preparation
% Initilize the screen
param.expStartTime = now();
expStartTime = GetSecs();
param = ptb_initialize(param);

% Load stimuli
stimuli = [];

% Build the experiment design
param.ed = ptb_builded(param.conditionsArray, param.blockByCondition);
param.tn = size(param.ed, 1);  % trial number

% Keys
param.respKeys = arrayfun(KbName, param.respKeyNames);
param.expKey = KbName(param.expKeyName);
param.instructKey = KbName(param.instructKeyName);

% Instruction
DrawFormattedText(param.w, param.instructText, 'center', 'center', param.forecolor);
Screen('Flip', param.w);
RestrictKeysForKbCheck(param.instructKey);
KbWait([],2);

% Fixations
param.fixarray = ptb_fixcross(param.screenX, param.screenY, param.widthFix, param.lengthFix);


%% Do the trial
quitNow = 0;

for ttn = 1 : param.tn  % this trial number 
    
    [output, quitNow] = Do_Trial(ttn, param, stimuli, quitNow);
    dtStruct(ttn) = output;
    
    ptb_checkbreak;
    
    if (quitnow), break; end

end

param.dtTable = struct2table(dtStruct);

% create the experiment information table
xInfor = size(dtStruct, 1);
ExperimentAbbv = repmat({param.expAbbv}, xInfor, 1);
ExpCode = repmat({param.expCode}, xInfor, 1);
SubjCode = repmat({param.subjCode}, xInfor, 1);
expInforTable = table(ExperimentAbbv, ExpCode, SubjCode);

% combine the exp information table and data table
param.dtTable = [expInforTable, struct2table(dtStruct)];


%% Finishing
if (~quitNow)
    breakText = sprintf('This part is finished!\n \nPlease contact the experimenter.');
    DrawFormattedText(param.w, breakText, 'center', 'center', param.forecolor);
    Screen('Flip', param.w);
    RestrictKeysForKbCheck(param.instructKey);
    KbWait([],2)
    clear doneText;
end

expEndTime = GetSecs();
param.expDuration = expEndTime - expStartTime;

Screen('CloseAll');

%% Saving the output
ptb_output(param, stimuli);

fprintf('\nThe current session lasts %2.2f minutes.\n', param.expDuration/60);
disp(['Mean Accuracy: ' num2str(100*mean(param.dtTable.isCorrect),'%2.1f%%')]);

