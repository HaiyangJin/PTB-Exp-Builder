function demo_cat(subjCode, isEyelink)
% Example experiment main body.
%
% An experiment for categorization.
%
% Input:
%    subjCode      subject code
%
% Created by Haiyang Jin (2018).

param.SkipSyncTests = 0;  % will skip in debug mode

if ~exist('subjCode', 'var')
    subjCode = '000';
elseif isnumeric(subjCode)  % the subjCode should be a string
    subjCode = num2str(subjCode);
end

if strcmp(subjCode, '0')
    param.isDebug = 1;
    warning(['Debug mode is on... \nThe subjCode is %s.\n' ...
        'Data will not be saved.'], subjCode);
else
    param.isDebug = 0;
end
param.subjCode = subjCode;

if ~exist('isEyelink', 'var') || isempty(isEyelink)
    isEyelink = 0;
end
param.isEyelink = isEyelink;

% add the functions folder to the path
% clc;
paths = {'PTB', 'ImageTools', 'Utilities/', 'custom/cat_funcs'};
if isEyelink; paths=horzcat(paths, {'Eyelink'}); end
cellfun(@addpath, paths);
% addpath(genpath('functions/'));

%% Experiment inforamtion
param.expCode = '999';
param.expAbbv = 'ExpEL';

% experiment design (ed)
clear param.conditionsArray;
param.conditionsArray = {...
    'IV1', 1:4; ... % 1 (all the study are whole) 0 (study will be part or whole)
    'IV2', 0:1; ... % 0 = part condition; 1 = whole condition (only for test face)
    'blocks', 1; ... %
    };
param.randBlock = '';
param.sortBlock = 'blocks'; 

% response keys
param.expKeyName = {'escape', '=+'};
param.instructKeyName = 'q';
param.respKeyNames = {'1!', '2@';
                       '1', '2'};

% instructions
param.instructText = sprintf(['Insert instructions here... \n', ...
    'Press "%s" or "%s" for each trial. \n', ...
    '(Press "%s" to continue...)'], ...
    param.respKeyNames{1}, param.respKeyNames{2}, param.instructKeyName);

% breaks
param.trialsPerRest = 40;
param.restMinimumTime = 10; % seconds

%% Stimuli
stimPath = fullfile('custom/stimuli/CF_LineFaces', filesep);
param.imgDir = im_dir(stimPath, {'png'});

param.jitterX = ((1:5)-4)*50; % jitter of the stimuli
param.jitterY = ((1:5)-4)*50; % jitter of the stimuli

%% Trial parameters
% fixations
param.widthFix = 4;
param.lengthFix = 20;

% durations
param.fixDuration = 0.5;
param.stimDuration = 0.5;
param.respDuration = 1;
param.blankDuration = 0.5;

% feedback
param.isFeedback = 1;

%% Setting for the screen
param.frameExpected = 60;
param.forecolor = 'white'; % (white, black, grey or numbers)
param.backcolor = 'grey';  % (white, black, grey or numbers)
param.winrect = [];        % [] Window Rect; % default [100 100 1300 900];  %[100 100 600 600];
param.whichscreen = [];    % which screen will be used

%% Parameters of fonts used in this exp
param.textSize = 20;
param.textFont = 'Helvetica';
param.textColor = 255;

%% Eyelink
param.eldummymode = ~isEyelink;
param.do_roi = []; % @cat_roi;
param.do_iafile = @cat_iafiles;

%% Run the Experiment
param.do_trial = @cat_trial;
param.do_output = @ptb_outtable;

ptb_runexp(param);

end