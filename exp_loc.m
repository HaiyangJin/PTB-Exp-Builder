function exp_loc(subjCode, isEmulated)
% Run fMRI localizer (block design).
%
% Input:
%    subjCode      subject code
%
% Created by Haiyang Jin (25-Feb-2020)

% add the functions folder to the path
addpath('PTB/');
addpath('fMRI/');

param.SkipSyncTests = 0;

if nargin < 1
    subjCode = '000';
elseif isnumeric(subjCode)  % the subjCode should be a string
    subjCode = num2str(subjCode);
end

% by default, emulated mode is on... (will not wait for fMRI trigger)
if nargin < 2 || isempty(isEmulated)
    isEmulated = 1;
end

if strcmp(subjCode, '0')
    isDebug = 1;
    isEmulated = 1;
    warning(['Debug mode is on... \n', 'The subjCode is %s'], subjCode);
else
    isDebug = 0;
end

param.subjCode = subjCode;
param.isEmulated = isEmulated;
param.isDebug = isDebug;

%% Experiment inforamtion
param.expCode = '999';
param.expAbbv = 'fMRI_block';

%% Stimuli
stimPath = fullfile('images_loc', filesep);
param.imgDir = im_dir(stimPath, '', 1);
param.nCatStim = numel(unique({param.imgDir.condition}));

% number of repetitions in each block (for 1-back task)
param.nSamePerBlock = 2;

%% Experiment design (ed)

param.nStimPerBlock = 14;  % number of stimili in each block+
param.nRepeated = 2;  % how many times all blocks are repeated

clear param.conditionsArray;
param.conditionsArray = {...
    'stimIndex', 1:param.nStimPerBlock; ... number of stimili in each block
    'stimCategory', 1:param.nCatStim; ... % stimlus (category) conditions
    'repeated', 1:param.nRepeated; % block repeated times 
    };
param.randBlock = 'stimCategory';
param.sortBlock = 'repeated';

% response keys
param.expKeyName = {'escape', '=+'};
param.instructKeyName = 'q';
param.respKeyNames = {'1'; '1!'};

% instructions
if isEmulated
    continueStr = sprintf('Press "%s" to continue...', param.instructKeyName);
else
    param.instructKeyName = 'F1'; % key for triggers
    continueStr = 'Waiting for the trigger...';
end

param.instructText = sprintf(['Welcome to this experiment... \n' ...
    'Please press Key "%s" only when the current image is the same as '...
    'the last image. \n', ...
    '(%s)'], ...
    param.respKeyNames{1, 1}, continueStr);

%% Fixation parameters
% fixations
param.widthFix = 4;
param.lengthFix = 20;
param.fixDuration = 0.5;

% the block numbers for fixation
param.fixBlockNum = [1, 1+(1:param.nRepeated) * (param.nCatStim+1)];  

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
param.do_trial = @fmri_doblocktrial;
param.do_output = @example_output;
param.do_stim = @fmri_block_stim;

fmri_block(param);

end