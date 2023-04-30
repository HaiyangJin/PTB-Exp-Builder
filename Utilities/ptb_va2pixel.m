function [stimPi, stimCm] = ptb_va2pixel(va, dist, pipercm)
% [stimPi, stimCm] = ptb_va2pixel(va, dist, pipercm)
% 
% Calcualte the size of stimulus based on the visual angle (and monitor).
%
% Inputs:
%    va            <num> visual angle in degrees.
%    dist          <num> distance between the participant and the screen in
%                   centimeters.
%    pipercm       <num> pixels per centimeter for this screen. 
%               OR <int> screen index. Default to the main screen (0).
%
% Outputs:
%    stimPi        <num> stimulus size in pixel.
%    stimCm        <num> stimulus size in centimeter.
%
% Created by Haiyang Jin (2023-April-30)

if nargin<1
    fprintf('Usage: [stimPi, stimCm] = ptb_va2pixel(va, dist, pipercm);\n');
    return
end

if ~exist('dist', 'var') || isempty(dist)
    dist = 57;
end

if ~exist('pipercm', 'var') || isempty(pipercm)
    pipercm = 0; % the default (main) screen
end
if isint(pipercm)
    % get the parameters for the screen
    ssize = ptb_screensize(pipercm);
    pipercm = ssize.pipercm;
end

% stimulus in centimeters
stimCm = tan(deg2rad(va))*dist;
% stimulus in pixels
stimPi = round(pipercm * stimCm);

end