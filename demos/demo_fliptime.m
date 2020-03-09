function demo_fliptime(flipInterval, demoDuration, isDebug)
% demo_fliptime(flipInterval, demoDuration, isDebug)
%
% This demo shows (at least partly) how flip works in Psychotoolbox.
% [Please run this demo in the 'demos/' folder.
%
% Inputs:
%     flipInterval            <numeric> the intervals between two flips
%                             [seconds].
%     demoDuration            <numeric> the whole duration of this demo
%                             [seconds].
%     isDebug                 <logical> 1: the debug mode is on. 0: use
%                             full screen.
%
% Created by Haiyang Jin (5-March-2020)

if nargin < 1 || isempty(flipInterval)
    flipInterval = 0.001; % 1ms
end

if nargin < 2 || isempty(demoDuration)
    demoDuration = 5; % seconds
end

if nargin < 3 || isempty(isDebug)
    isDebug = 1;
end
param.isDebug = isDebug;


% add the necessary path
cellfun(@(x) addpath(genpath(fullfile('..', x))), {'PTB'});

%% Setting parameters
% Setting for the screen
param.frameExpected = 60;
param.forecolor = 'white';  %  (white, black, grey or numbers)
param.backcolor = 'grey';  %  (white, black, grey or numbers)
param.winrect = []; % [] Window Rect; % default [100 100 1300 900];  %[100 100 600 600];

% Parameters of fonts used in this exp
param.textSize = 20;
param.textFont = 'Helvetica';
param.textColor = 255;

% instruction
param.instructText = sprintf('Please press the space bar to start this demo...');
param.instructKey = KbName('SPACE');
param.expKeyName = cellfun(@KbName, {'escape', '=+'});

%% run the demo
ListenChar(2);
% initialize
param = ptb_initialize(param);

% instruction
ptb_instruction(param);

%
param.demoStartTime = GetSecs;
checkTime = 0;
theNumber = 0;

% 
while checkTime < demoDuration
    
    theNumber = theNumber + 1;
    Screen('DrawText', param.w, num2str(theNumber), param.screenCenX, param.screenCenY);
    [VBL, ~, finished] = Screen('Flip', param.w);
%     afterFlipTime = GetSecs;
    
%     disp(VBL-param.demoStartTime);
%     disp(afterFlipTime-param.demoStartTime);
%     
%     
%     disp('delay1');
%     disp(finished - VBL);
%     
%     disp('VBL');
%     disp(afterFlipTime - VBL);
%     disp('finishes 2')
%     disp(afterFlipTime - finished);
    
    % wati for some time
    WaitSecs(flipInterval); 
    
    checkTime = GetSecs - param.demoStartTime;
end

param.demoEndTime = GetSecs;


%% Close the screen
Screen('CloseAll');

% remove the path
cellfun(@(x) rmpath(genpath(fullfile('..', x))), {'PTB'});

ListenChar(0);

% display demo durations
param.demoDuration = param.demoEndTime - param.demoStartTime;
fprintf('\nThis demo lasted %2.2f minutes (%.3f seconds).\n', ...
    param.demoDuration/60, param.demoDuration);
fprintf('The pre-define wait time in the while loop is %d seconds.\n', flipInterval);
fprintf('There are %d flips in this demo.\n', theNumber);
fprintf('The intervals between flips is %2.4f seconds on average.\n', param.demoDuration/theNumber);

end