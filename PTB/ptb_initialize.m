function param = ptb_initialize(param)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Clear the workspace and the screen
sca;
close all;

% Here we call some default settings for setting up Psychtoolbox
PsychDefaultSetup(2);
 
commandwindow;
Priority(1);
warning('off','MATLAB:sprintf:InputForPercentSIsNotOfClassChar');
warning('off','MATLAB:fprintf:InputForPercentSIsNotOfClassChar');

Screen('Preference', 'SkipSyncTests', 1);

rand('twister',sum(100*clock));
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Initialize and setup the screen
Screen('Preference','TextEncodingLocale','UTF-8');
screens = Screen('Screens');
whichScreen = max(screens);

% Define black and white (white will be 1 and black 0). This is because
% in general luminace values are defined between 0 and 1 with 255 steps in
% between. All values in Psychtoolbox are defined between 0 and 1
colorCode.white = WhiteIndex(whichScreen) * 255;
colorCode.black = BlackIndex(whichScreen);

% Do a simply calculation to calculate the luminance value for grey. This
% will be half the luminace values for white
colorCode.grey = colorCode.white / 2; % 128 

param.forecolor = colorconverter(param.forecolor, colorCode);
param.backcolor = colorconverter(param.backcolor, colorCode);

pixelSizes = Screen('PixelSizes', whichScreen);
if max(pixelSizes) < 32 && ispc
    warning('Sorry, I need a screen that supports 32-bit pixelSize.\n');
    return;
end

if param.isDebug
    param.winrect = [100 100 1300 900]; % default for debug mode
end

[window, screenRect] = Screen('OpenWindow', whichScreen, param.backcolor, ...
    param.winrect, max(pixelSizes));
[screenCenX,screenCenY] = RectCenter(screenRect);
screenX = screenRect(3);
screenY = screenRect(4);

if ~param.isDebug
    HideCursor;
end

Screen('BlendFunction', window, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA );

frameRate = Screen('NominalFrameRate', window); % the Hz refresh rate
if (frameRate ~= param.frameExpected) && ispc
   beep;
   disp(['WARNING... the framerate is not ', num2str(frameRateExpected), '; it''s ' num2str(frameRate) ' Hz. This may cause timing issues.']);
end
msPerFrame = Screen('GetFlipInterval',window); % milliseconds per frame
flipSlack = .5 * msPerFrame; % needed so that Screen('Flip') can be prepared when the flip occurs.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Set font, size, and color for texts
Screen('TextSize', window, param.textSize);
if ~ismac, Screen('TextFont', window, param.textFont); end
Screen('TextColor', window, param.forecolor);

%% Matlab is loading the program...
% Screen('DrawText', window, 'Experiment is loading... Please wait.', screenX/2, screenY/2, white);
loadingText = sprintf('Experiment is loading... Please wait...');
DrawFormattedText(window, loadingText,'center','center', param.forecolor);

Screen('Flip', window);

%% output for ptb_initialize
param.w = window;
param.screenCenX = screenCenX;
param.screenCenY = screenCenY;
param.screenRect = screenRect;
param.screenX = screenX;
param.screenY = screenY;
param.flipSlack = flipSlack;

end

% local function
function color = colorconverter(color, colorCode)
% convert the color (string) to color (num)
if ischar(color)
    switch color
        case 'white'
            color = colorCode.white;
        case 'black'
            color = colorCode.black;
        case 'gray'
            color = colorCode.grey;
        case 'grey'
            color = colorCode.grey;
        otherwise
            error('Failed to identify the color...');
    end
elseif ~isnumeric(color)
    error('Failed to identify the color...');
end

end