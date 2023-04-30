function ssize = ptb_screensize(whichscreen)
% ssize = ptb_screensize(whichscreen)
%
% Get the screen size in pixels and centimeters. 
%
% Input:
%    whichscreen   <int> which screen. Default to 0.
%
% Output:
%    ssize        <struct> the screen size in pixels and centimeters.
%    .cm           width and height in centimeters.
%    .pi           width and height in pixels.
%    .cmperpi      centimeters per pixel.
%    .pipercm      pixels per centimeter.
%
% Created by Haiyang Jin (2023-April-30)
%
% See also:
% ptb_visualangle()

if nargin<1
    fprintf('Usage: ssize = ptb_screensize(whichscreen);\n');
    return
end

if ~exist('whichscreen', 'var') || isempty(whichscreen)
    whichscreen = 0; % the default (main) screen
elseif isstruct(whichscreen) && isfield(whichscreen, 'whichscreen')
    ssize = whichscreen; % backup the struct
    whichscreen = whichscreen.whichscreen;
end

[wcm, hcm] = screensize(whichscreen, 'cm');
[wpi, hpi] = screensize(whichscreen, 'pi');

ssize.cm = [wcm, hcm];
ssize.pi = [wpi, hpi];
ssize.cmperpi = wcm/wpi;
ssize.pipercm = wpi/wcm;

end %function ptb_screensize()

function [width, height] = screensize(whichscreen, sizeUnit)
% whichscreen: screen index
% sizeUnit: 'cm' or 'pixels'

switch sizeUnit
    case {'pi', 'pixel', 'pixels'}
        try
            [width, height] = Screen('WindowSize', whichscreen); 

        catch
            warning('Matlab built-in function was used to get the screen size in pixels.')
            % Get the screen size in pixels
            set(0,'units','pixels');
            pixels = get(0,'MonitorPositions');
            width = pixels(whichscreen+1,3);
            height = pixels(whichscreen+1,4);
        end

    case {'cm', 'centimeter', 'centimeters'}
        try
            [width_mm, height_mm] = Screen('DisplaySize', whichscreen); 
            width = width_mm/10;
            height = height_mm/10;

        catch
            warning(['Matlab built-in function was used to get' ...
                ' the screen size in centimeters. It may not be correct/accurate.'])
            % Get the screen size in centimeters
            set(0,'units','centimeters');
            pixels = get(0,'MonitorPositions');
            width = pixels(whichscreen+1,3);
            height = pixels(whichscreen+1,4);

        end

    otherwise
        warning('Unknown units.')
        width = -1;
        height = -1;

end %sizeUnit
end %function screensize()
