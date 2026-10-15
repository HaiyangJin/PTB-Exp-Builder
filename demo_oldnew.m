function demo_oldnew(subjCode, isEyelink, skipSyncTest)
% demo_oldnew(subjCode, isEyelink, skipSyncTest)
%
% Old/new face recognition task based on PTB-Exp-Builder.
%
% Inputs
%   subjCode       Subject code. Use '0' for debugging.
%   isEyelink      0 = no EyeLink; 1 = use EyeLink.
%   skipSyncTest   0 = run PTB sync tests; 1 = bypass sync tests.
%
% Example calls
%   demo_oldnew('0', 0, 1)       % Debug without EyeLink
%   demo_oldnew('001', 1, 0)     % Example EyeLink session
%
% IMPORTANT:
% Bypassing synchronization tests is for debugging only.
% Validate display timing before collecting experimental data.

%% 1. Handle inputs

if nargin < 1 || isempty(subjCode)
    subjCode = '0';
end

if isnumeric(subjCode)
    subjCode = num2str(subjCode);
end

if nargin < 2 || isempty(isEyelink)
    isEyelink = 0;
end

if nargin < 3 || isempty(skipSyncTest)
    skipSyncTest = 1;
end

param.subjCode = subjCode;
param.isDebug = strcmp(subjCode, '0');
param.isEyelink = logical(isEyelink);
param.eldummymode = ~param.isEyelink;
param.SkipSyncTests = skipSyncTest;

if param.isDebug
    warning(['Debug mode: subject code is 0. ', ...
        'Check the output behavior before collecting data.']);
end

if skipSyncTest
    warning(['PTB synchronization tests are bypassed. ', ...
        'Use this setting for debugging only, not for ', ...
        'validated experimental data collection.']);
end

%% 2. Set up repository paths

repoRoot = fileparts(mfilename('fullpath'));

% Add PTB-Exp-Builder utilities and EyeLink functions.
addpath(genpath(repoRoot));

%% 3. Experiment information

param.expCode = '001';
param.expAbbv = 'OldNew';

%% 4. Response keys

% F = old; J = new.
param.respKeyNames = {'f', 'j'};

% ESC requests termination of the experiment.
param.expKeyName = {'escape'};

% This Mac was verified to detect key presses with KbCheck(0).
% The old/new task uses KbCheck throughout and does not create KbQueue.
param.keyboardDevice = 0;

% Space starts the experiment after the instructions.
param.instructKeyName = 'q';

param.instructText = sprintf([ ...
    'Welcome to this experiment.\n\n\n', ...
    'You will first study a series of faces.\n\n', ...
    'Try to remember each face as accurately as possible.\n\n\n', ...
    'You will then see faces one at a time.\n\n', ...
    'Press F if the face appeared in the study phase.\n\n', ...
    'Press J if the face is new.\n\n\n', ...
    'Respond as quickly and accurately as possible.\n\n\n', ...
    'Press Q to begin.']);

%% 5. Stimuli

stimPath = fullfile(repoRoot, ...
    'custom', 'stimuli', 'CF_LineFaces');

if ~exist(stimPath, 'dir')
    error('Stimulus directory not found: %s', stimPath);
end

param.imgDir = im_dir(stimPath, {'png'});

%% 6. Experiment design

% Number of faces in the study phase.
param.nStudy = 4;

% Number of old and new faces in the recognition phase.
param.nTestOld = param.nStudy;
param.nTestNew = param.nStudy;

% The preparation function selects the images and creates
% the study and test trial sequence.
param.do_stim = @oldnew_prepare;

%% 7. Trial parameters

param.fixDuration = 0.5;
param.studyDuration = 3;
param.blankDuration = 0.5;

% Maximum response time, measured from test stimulus onset.
param.responseMaxDuration = 5.0;

% Delay between study and recognition phases.
param.studyTestDelay = 5.0;

% Maximum stimulus dimension in pixels.
param.maxStimSize = 500;

% Intertrial interval.
param.ITInterval = 0.5;

% fixations
param.widthFix = 4;
param.lengthFix = 20;
param.fixDuration = 0.5;

%% 8. Breaks and feedback

param.trialsPerRest = 40;
param.restMinimumTime = 10;

% Feedback is omitted in this basic version.
param.isFeedback = 0;

%% 9. Display settings

param.frameExpected = 60;

param.forecolor = 'white';
param.backcolor = 'grey';

% Use a window rather than fullscreen.
% Rectangle format: [left top right bottom].
param.winrect = []; % 100 100 1100 800qqffffffff q

param.whichscreen = [];

param.textSize = 24;
param.textFont = 'Helvetica';
param.textColor = 255;

%% 10. EyeLink settings

% EyeLink initialization and shutdown are handled by ptb_runexp.
% The trial function sends event messages to the tracker.
param.do_roi = [];
param.do_iafile = []; 

%% 11. Assign experiment functions

param.do_trial = @oldnew_trial;
param.do_output = @ptb_outtable;

%% 12. Run the experiment

ptb_runexp(param);

end
