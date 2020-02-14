function ptb_example(subjCode)
% Example experiment main body.
%
% Input:
%    subjCode      subject code
%
% Created by Haiyang Jin (2018).

% add the functions folder to the path
clc;
addpath('PTB/');

if nargin < 1
    subjCode = '000';
elseif isnumeric(subjCode)  % the subjCode should be a string
    subjCode = num2str(subjCode);
end

if strcmp(subjCode, '0')
    param.isDebug = 1;
    warning(['Debug mode is on... \n', 'The subjCode is %s'], subjCode);
else
    param.isDebug = 0;
end

param.subjCode = subjCode;

%% Experiment inforamtion
param.expCode = '999';
param.expAbbv = 'ExpAbbv';

% experiment design (ed)
clear param.conditionsArray;
param.conditionsArray = {...
    'IV1', 1:4; ... % 1 (all the study are whole) 0 (study will be part or whole)
    'IV2', 0:1; ... % 0 = part condition; 1 = whole condition (only for test face)
    'blocks', 1; ... %
    };
% Which condition is used to block the trials? (balance the randomization 
% so that unique conditions appear in different blocks). 
% just use doublequotes (='') if you don't want to use.
param.blockByCondition = 'blocks'; 

% response keys
param.expKeyName = {'escape', '=+'};
param.instructKeyName = 'q';
param.respKeyNames = {'1!', '2@'};

% instructions
param.instructText = sprintf(['Insert instructions here... \n', ...
    'Press "%s" or "%s" for each trial. \n', ...
    '(Press "%s" to continue...)'], ...
    param.respKeyNames{1}, param.respKeyNames{2}, param.instructKeyName);

% breaks
param.trialsPerRest = 40;
param.restMinimumTime = 10; % seconds

%% Stimuli
stimPath = fullfile('stimuli', filesep);
param.imgDir = ptb_dirimg(stimPath, {'jpg'});

%% Trial parameters
% fixations
param.widthFix = 4;
param.lengthFix = 20;
param.fixDuration = 0.5;

% stimuli
param.stimDuration = 0.5;

% responses
param.respDuration = 1;

% blank
param.blankDuration = 0.5;


%% Setting for the screen
param.frameExpected = 60;
param.forecolor = 'white';  %  (white, black, grey or numbers)
param.backcolor = 'grey';  %  (white, black, grey or numbers)
param.winrect = []; % [] Window Rect; % default [100 100 1300 900];  %[100 100 600 600];

%% Parameters of fonts used in this exp
param.textSize = 20;
param.textFont = 'Helvetica';
param.textColor = 255;

%% Run the Experiment
param.do_trial = @example_trial;
param.do_output = @example_output;

ptb_runexp(param);

end