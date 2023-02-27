function demo_disppng(imfn, winrect)
% demo_disppng(imfn, winrect)
%
% Inputs:
%    imfn     <str> path to the image to be displayed. Please make sure the
%              image has an alpha layer.
%    winrect  <int vect> the window rect. 
%
% Created by Haiyang Jin (2023-Feb-27)

%% Load the image
if ~exist('imfn', 'var') || isempty(imfn)
    imfn = '../custom/stimuli/CF_LineFaces/Line1/m1.png';
elseif ~endsWith(imfn, '.png')
    warning('Please make sure the image has a transparent layer.');
end

% read the images first (both RGB and alpha)
[img, ~, alpha] = imread(imfn);
% make the image into RGB if needed
if size(img,3)==1
    img = repmat(img,1,1,3);
end
if isempty(alpha)
    warning('The alpha layer seems to be empty.');
end

imgRect = [0 0 size(img,2), size(img,1)];

%% Set up the window

if ~exist('winrect', 'var') || isempty(winrect)
    winrect = 300 + imgRect;
end

% general settings
PsychDefaultSetup(2);
Screen('Preference', 'SkipSyncTests', 1);
screenNum = max(Screen('Screens')); % set screen
% Screen('Preference', 'VisualDebugLevel', 3);
[w, rect] = Screen('OpenWindow', screenNum, [128 128 128], winrect);

% this HAS to be included
Screen('BlendFunction', w, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');

%% Display the image
% put the image at the center of the screen
centerRect = CenterRect(imgRect, rect);

% texture without alpha
texture1 = Screen('MakeTexture', w, img);

% texture with alpha
imgalpha = cat(3, img, alpha); % add the alpha layer to image
texture2 = Screen('MakeTexture', w, imgalpha);

% show image without transparent
Screen('DrawTexture', w, texture1, [], centerRect);
Screen('Flip', w);
WaitSecs(2);

% display an empty screen
Screen('Flip', w);
WaitSecs(1);

% show image with transparent
Screen('DrawTexture', w, texture2, [], centerRect);
Screen('Flip', w);
WaitSecs(2);
sca;

end