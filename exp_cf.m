function exp_cf(subjCode)
% The composite face task.
%
% Input:
%    subjCode      subject code
%
% Created by Haiyang Jin (5-Feb-2019).

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

%% Stimuli
stimPath = fullfile('CF_LineFaces', filesep); % CFFaces  CF_LineFaces
imgDir = ptb_dirimg(stimPath, {'png'});
param.nFacePerGroup = 4;
nGroup = numel(unique({imgDir.condition}));  % number of groups (folders)

param.alpha = 1;  % 0: transparent; 1: opaque

% reformat stimuli structure by group names
tempDir = cellfun(@(x) imgDir(strcmp({imgDir.condition}, x)), ...
    unique({imgDir.condition}), 'uni', false);
param.imgDir = [tempDir{:}];

%% Experiment inforamtion
param.expCode = '999';
param.expAbbv = 'CF';

% experiment design (ed)
clear param.conditionsArray;
param.conditionsArray = {...
    'isTestAligned', 0:1; ... % 0 = misaligned; 1 = aligned
    'isTopCued', 1;... %  0 = bottom is cued; 1 = top is cued
    'isCongruent', 0:1;...  % 0 = incongruent; 1 = congruent
    'isCuedSame', 0:1; ... % 0 = different; 1 = same
    'faceGroup', 1:nGroup; ... % number of groups
    'faceIndex', 1:4;... % 4 images in each group
    'withinBlockReps', 1; ... % 
    'blockNumber', 1; ... % 
    };
% Which condition is used to block the trials? (balance the randomization 
% so that unique conditions appear in different blocks). 
% just use doublequotes (='') if you don't want to use.
param.blockByCondition = 'blockNumber'; 

% response keys
param.expKeyName = {'escape', '=+'};
param.instructKeyName = 'q';
respKeyNames = {
    '1', '2';
    '1!', '2@'};

if param.isDebug; subjCode = 1; end
param.respKeyNames = ptb_balancekeys(subjCode, respKeyNames); % counterbalance keys


% instructions
param.instructText = sprintf(['Welcome to this experiment.'...
    '\n\n\n'...
    'On each trial, you will see two faces, one after the other.'...
    '\n \n'...
    'Please focus on the upper parts of the faces and ignore the lower parts.'...
    '\n \n\n \n'...
    'If the upper parts of the two consecutive faces are the same,'...
    '\n\n'...
    'please press KEY %s.'...
    '\n\n\n \n'...
    'If the upper parts of the two consecutive faces are different,'...
    '\n\n'...
    'please press KEY %s.'...
    '\n \n \n \n'...
    'Please respond as quickly and accurately as possible.'], ...
    param.respKeyNames{1,1}, param.respKeyNames{1,2});

% breaks
param.trialsPerRest = 40;
param.restMinimumTime = 10; % seconds

%% Face Selection
% select face based on condition
% columns: studyTop; studyBottom; targetTop; targetBottom
% rows: top(CS,CD,IS,ID), bottom(CS,CD,IS,ID) 
param.faceSelector = ...
    [0 1 0 1 ; % TCS
     0 1 2 3 ; % TCD
     0 1 0 2 ; % TIS
     0 1 3 1 ; % TID
     0 1 0 1 ; % BCS
     0 1 2 3 ; % BCD
     0 1 3 1 ; % BIS
     0 1 0 2]; % BID
% Usage: 
%   trialType = 1 + 4*(1-ed(ttn).isTopCued) + 2*(1-ed(ttn).isCongruent) + (1-ed(ttn).isCuedSame);
%   thisFaceSet = mod((ed(ttn).faceIndex + faceSelector(trialType,:)-1),4)+1;

%% Trial parameters

% misaligned percentage
param.misalignPerc = 0.5;

% cues
param.showCue = 0; % 0: not show cue, 1: show cues
param.cuePixel = 6; 
param.cueLength = 1.5; % times of the wide of stimuli (face)
param.cueSideLength = 22;  % the "hook" part (even number)
param.cuePosition = 22;  % distance from the position to the middle of the screen

% fixations
param.widthFix = 4;
param.lengthFix = 20;
param.fixDuration = 0.5;

% blanks
param.blankDuration = 0.5;

% study faces
param.studyDuration = 0.5;
param.testDuration = 0.5;

% masks
param.maskDuration = 0.5;

% test faces
param.nOffset = 4; % the jitter is [-4:4] * 5

% responses
param.respDuration = 1;

% interval
param.ITInterval = 0.5;

% feedback
param.isFeedback = 0;

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
% cf functions
param.do_stim = @cf_stim;  % process stimuli after initializing windows
param.do_trial = @cf_trial; % run trials
param.do_output = @cf_output;  % process output

% run the experiment
ptb_runexp(param);

end