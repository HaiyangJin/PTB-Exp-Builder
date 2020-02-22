function param = ptb_screensize(param)
% param = ptb_screensize(param)
%
% This function obtains the ScreenPixelsPerInch and calculates the actual
% size of the screen/window (in inch and centimeters). 
% 
% Input:
%     param         <structure> the parameter structure in PTB.
%
% Output:
%     param         <structure> several fieldnames are added.
%
% Created by Haiyang Jin (22-Feb-2020)

if nargin < 1 || isempty(param)
    param = struct;
end

param.ScreenPixelsPerInch = get(0, 'ScreenPixelsPerInch');
param.ScreenPixelsPerCm = get(0, 'ScreenPixelsPerInch') / 2.54;

% the resolution of the screen (in pixels)
set(0,'units','pixels')
param.screenResolution = get(0,'screensize');

% the actual size of the monitor (in inch and centimeters)
if isfield(param, 'screenRect')
    
    % actual size in inch
    param.screenSizeInch = param.screenRect / param.ScreenPixelsPerInch;
    % actual size in cm
    param.screenSizeCm = param.screenRect / param.ScreenPixelsPerCm;
    
end

% set(0,'units','centimeters')
% get(0,'screensize');

end
