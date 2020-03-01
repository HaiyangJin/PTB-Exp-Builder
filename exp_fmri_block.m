function exp_fmri_block(subjCode, isEmulated, runCode)
% exp_fmri_block(subjCode, isEmulated, runCode)
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
addpath('PTB/');
addpath('fMRI/');

% skip Sync tests
param.SkipSyncTests = 0;  % will skip on Macs
% display the key name for key press
param.dispPress = 1;

%% Experiment inforamtion
param.expCode = '999';
param.expAbbv = 'fMRI_block';

%% Process the in-arguments
% subject code
if nargin < 1
    subjCode = '000';
elseif isnumeric(subjCode)  % the subjCode should be a string
    subjCode = num2str(subjCode);
end

% by default, emulated mode is on... (will not wait for fMRI trigger)
if nargin < 2 || isempty(isEmulated)
    isEmulated = 1;
end

% debug mode
if strcmp(subjCode, '0')
    isDebug = 1;
    isEmulated = 1;
    warning(['Debug mode is on... \n', 'The subjCode is %s'], subjCode);
else
    isDebug = 0;
end
param.subjCode = subjCode;
param.isDebug = isDebug;
param.isEmulated = isEmulated;

% run Code
if nargin < 3 || isempty(runCode)
    runCode = fmri_runcode(param);
end
param.runCode = runCode;

%% Stimuli
% load the stimulus
stimPath = fullfile('images_loc', filesep);
param.imgDir = im_dir(stimPath, '', 1);
param.nStimCat = numel(unique({param.imgDir.condition}));

% the jitter of stimulus
param.jitter = 3; % the jitter is [-4:4] * 3

% number of same trials in each block (for 1-back task)
param.nSamePerBlock = 1;

%% Experiment design (ed)
% number of stimili in each block+
param.nStimPerBlock = 14;
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
param.respKeyNames = {'1'; '1!'};

%% instructions
if isEmulated
    continueStr = sprintf('Press "%s" to continue...', param.instructKeyName);
else
    param.instructKeyName = '`~'; % key for triggers [to be confirmed]
    continueStr = 'Waiting for the trigger...';
end

% instruction texts
param.instructText = sprintf(['Welcome to this experiment... \n\n\n' ...
    'Please press Key "%s" only when the current image is the same as '...
    'the previous one. \n\n', ...
    '(%s)'], ...
    param.respKeyNames{1, 1}, continueStr);

%% Dummy volumes
param.dummyDuration = 10; % seconds

%% Fixation parameters
% fixations
param.widthFix = 4;
param.lengthFix = 20;
param.fixDuration = 0.5;

% the block numbers for fixation
param.fixBlockNum = fmri_fixdesign(param);

%% Trial parameters
% stimuli
param.stimDuration = 0.5;
param.trialDuration = 1;  % The total duration of one trial.

%% Setting for the screen
param.frameExpected = 60;
param.forecolor = 'black';  %  (white, black, grey or numbers)
param.backcolor = 'white';  %  (white, black, grey or numbers)
param.winrect = []; % [] Window Rect; % default [100 100 1300 900];  %[100 100 600 600];

%% Parameters of fonts used in this exp
param.textSize = 20;
param.textFont = 'Helvetica';
param.textColor = 255;

%% Run the Experiment
param.do_trial = @fmri_block_dotrial;
param.do_stim = @fmri_block_stim;
param.do_output = @ptb_outtable;

% run the fmri experiment in block design
fmri_block_runexp(param);

end