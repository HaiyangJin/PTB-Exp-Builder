function demo_fmri_block(subjCode, isEmulated, runCode)
% demo_fmri_block(subjCode, isEmulated, runCode)
%
% Run fMRI localizer (block design).
%
% Input:
%    subjCode           <string> subject code
%    isEmulated         <logical> 1: emulated and will not wait for MRI
%                       trigger (default). 0: will wait for MRI trigger.
%    runCode            <integer> the run code/number. It can be generated
%                       based on the output files in Matlab Data/.
%
% Created by Haiyang Jin (25-Feb-2020)

% add the functions folder to the path
funcFolers = {'PTB/', 'fMRI/', 'ImageTools/', 'Utilities/'};
cellfun(@addpath, funcFolers);
% addpath(genpath('functions/'));

% skip Sync tests
param.SkipSyncTests = 0;  % will skip in debug mode
% display the key name for key press
param.dispPress = 1;

%% Experiment inforamtion
param.expCode = '999';
param.expAbbv = 'fMRIblock';
param.outpath= 'output';

%% Process the in-arguments
% subject code
if ~exist('subjCode', 'var')
    subjCode = '000';
elseif isnumeric(subjCode)  % the subjCode should be a string
    subjCode = num2str(subjCode);
end

% by default, emulated mode is on... (will not wait for fMRI trigger)
if ~exist('isEmulated', 'var') || isempty(isEmulated)
    isEmulated = 1;
end

% debug mode
if strcmp(subjCode, '0')
    isDebug = 1;
    isEmulated = 1;
    warning(['Debug mode is on... \nThe subjCode is %s.\n', ...
        'Data will not be saved.'], subjCode);
else
    isDebug = 0;
end
param.subjCode = subjCode;
param.isDebug = isDebug;
param.isEmulated = isEmulated;

% run Code
if ~exist('runCode', 'var') || isempty(runCode)
    runCode = fmri_runcode(param, 35);
end
param.runCode = runCode;
fprintf('\nRun code: %d\n\n', runCode);

%% Stimuli
% load the stimulus
stimPath = fullfile('custom/stimuli/loc_stim', filesep);
param.imgDir = im_dir(stimPath, '', 1);
param.nStimCat = numel(unique({param.imgDir.condition}));
param.isim = 1;

% the jitter of stimulus
param.jitter = 3; % the jitter is [-4:4] * 3

% number of same trials in each block (for 1-back task)
param.nSamePerBlock = 1;

%% Experiment design (ed)
% number of stimili in each block+
param.nStimPerBlock = 5;
% how many times all blocks are repeated
param.nRepetition = 2;

% experiment design array
clear param.conditionsArray;
param.conditionsArray = {...
    'stimIndex', 1:param.nStimPerBlock; ... number of stimili in each block
    'stimCategory', 1:param.nStimCat; ... % stimlus (category) conditions
    'repeated', 1:param.nRepetition; % block repeated times
    };
param.randBlock = 'stimCategory';
param.sortBlock = 'repeated';

%% response keys
param.expKeyName = {'escape', '=+'};
param.instructKeyName = 'q';
param.respKeyNames = {'2'; '2@'};
param.respButton = 'red';

%% instructions
if isEmulated
    keyStr = sprintf('Key "%s"', param.respKeyNames{1, 1});
    continueStr = sprintf('Press "%s" to continue...', param.instructKeyName);
else
    keyStr = sprintf('the button with your %s', fmri_key2finger(param.respKeyNames{1, 1}));
    continueStr = 'Waiting for the trigger...';
    param.instructKeyName = '';  % do not wait for response
end

% instruction texts
param.instructText = sprintf(['Welcome to this experiment... \n\n\n' ...
    'Please press %s when the image is the same as '...
    'the previous one. \n\n', ...
    '(%s)'], ...
    keyStr, continueStr);

%% Dummy volumes
param.dummyDuration = 0; % seconds

%% Trial parameters
% stimuli
param.stimDuration = 0.8;
param.trialDuration = 1;  % The total duration of one trial.
param.stimBloDuration = param.trialDuration * param.nStimPerBlock;

%% Fixation parameters
% fixations
param.widthFix = 4;
param.lengthFix = 20;
param.fixBloDuration = param.stimBloDuration;

% the block numbers for fixation
param.fixBlockNum = fmri_fixdesign(param);

%% Setting for the screen
param.frameExpected = 60;
param.forecolor = 'white';  % (white, black, grey or numbers)
param.backcolor = 'grey';  % (white, black, grey or numbers)
param.winrect = [];         % [] Window Rect; % default [100 100 1300 900];  %[100 100 600 600];
param.whichscreen = [];     % which screen to display stimuli

%% Parameters of fonts used in this exp
param.textSize = 20;
param.textFont = 'Helvetica';
param.textColor = 255;

%% Run the Experiment
param.do_trigger = @fmri_vpixx; % mandatory to work with MRI
param.do_trial = @fmri_block_dotrial;
param.do_stim = @fmri_block_stim;
param.do_output = @ptb_outtable;
param.do_ed = [];

% % to use ABABABABA design
% param.do_ed = @fmri_block_ABAed;
% param.ed_remove = 1:10;
% % to use ABCCBA design
% param.do_ed = @fmri_block_ABBAed;

% run the fmri experiment in block design
fmri_block_runexp(param);

%% remove the path
cellfun(@rmpath, funcFolers);
% rmpath(genpath('functions/'));

end