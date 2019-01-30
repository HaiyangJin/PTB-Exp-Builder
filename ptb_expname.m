function ptb_expname(subjCode)

addpath('Utilities');

if nargin < 1  
    subjCode = '000';
    warning(['Debug mode is on... \n', 'The subjCode is %s'], subjCode);
elseif isnumeric(subjCode)  % the subjCode should be a string
    subjCode = num2str(subjCode);
end

param.subjCode = subjCode;
    

%% Experiment inforamtion
param.expCode = '000';
param.expAbbv = 'ExpAbbv';

% experiment design (ed)
clear param.conditionsArray;
param.conditionsArray = {...
    'IV1', 1:4; ... % 1 (all the study are whole) 0 (study will be part or whole)
    'IV2', 0:1; ... % 0 = part condition; 1 = whole condition (only for test face)
    'blocks', 1; ... % 
    };
param.blockByCondition = 'blocks'; % Which condition is used to block the trials? (balance the randomization so that unique conditions appear in different blocks). just use doublequotes (='') if you don't want to use.

% screen settings
param.winrect = [];  % [100 100 600 600]

% response keys
param.expKeyName = 'ESC';
param.instructKeyName = 'q';

param.respKeyNames = {'1!', '2@'};

% instructions
param.instructText = 'Insert instructions here...';


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


%% Seeting for the screen
param.frameExpected = 60;
param.forecolor = 'white';  %  (white, black, grey or numbers)
param.backcolor = 'grey';  %  (white, black, grey or numbers)


%% Parameters of fonts used in this exp
param.textSize = 20;
param.textFont = 'Helvetica';
param.textColor = 255; 


%% Run the Experiment
ptb_runexp(param);

end