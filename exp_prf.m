function exp_prf(subjCode, isEmulated, runCode)
% exp_prf(subjCode, isEmulated, runCode)
%
% Run fMRI pRF for category stimuli. 
%
% Input:
%    subjCode           <str> subject code
%    isEmulated         <boo> 1: emulated and will not wait for MRI
%                       trigger (default). 0: will wait for MRI trigger.
%    runCode            <int> the run code/number. It can be generated
%                       based on the output files in Matlab Data/.
%
% Created by Haiyang Jin (2023-Feb-25)

% add the functions folder to the path
funcFolers = {'PTB/', 'fMRI/', 'ImageTools/', 'Utilities/', 'pRF/'};
cellfun(@addpath, funcFolers);
% addpath(genpath('functions/'));

% skip Sync tests
param.SkipSyncTests = 0;  % will skip in debug mode
% display the key name for key press
param.dispPress = 1;

%% Experiment inforamtion
param.expCode = '999';
param.expAbbv = 'pRFfaces';
param.outpath= 'Output';

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
    runCode = fmri_runcode(param);
end
param.runCode = runCode;

%% Stimuli
% load the stimulus
stimPath = fullfile('custom/stimuli/loc_stim', filesep);
param.imgDir = im_dir(stimPath, '', 1);
param.nStimCat = numel(unique({param.imgDir.condition}));

% number of same trials in each block (for 1-back task)
% param.nSamePerBlock = 1;

%% Experiment design (ed)
% how many times the same trials will be repeated
param.nRepetition = 1; % not in use

% pRF designs (to be used in prf_stimposi())
param.prfcoorsys = 'carte';
param.prfNxy = [2, 2]; % number of rows and columns

% experiment design array
clear param.conditionsArray;
param.conditionsArray = {...
    'stimPosiX', 1:param.prfNxy(2); ...
    'stimPosiY', 1:param.prfNxy(1); ...
    'stimCategory', 1:param.nStimCat; ... % stimlus (category) conditions
    'repeated', 1:param.nRepetition; % block repeated times
    };
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
    keyStr, continueStr); % not in use

%% Dummy volumes
param.dummyDuration = 1; % seconds; fixation duration before any trial
param.dummyDurationEnd = 1; % fixation duration after all trials

%% Trial parameters
% stimuli
param.stimDuration = .3;
param.trialDuration = .5; % The total duration of one trial
param.nStimPerBlock = 4;  % .5*8 = 4s
param.nFixaEndPerBlock = 1; 
param.stimBloDuration = param.trialDuration * param.nStimPerBlock;

%% Fixation parameters
% fixations
param.widthFix = 4;
param.lengthFix = 20;
param.fixDuration = param.stimBloDuration;

% the block numbers for fixation
param.fixBlockN = 2; % randomly interleaved with experimental trials

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
param.do_trial = @prf_dotrial;
param.do_stim = @prf_stim;
param.do_output = @ptb_outtable;
param.do_ed = @prf_doed;

% run the fmri experiment in block design
try
    prf_runexp(param);
catch error
    ListenChar(0);
    sca;
    rethrow(error);
end

%% remove the path
cellfun(@rmpath, funcFolers);
% rmpath(genpath('functions/'));

end