function stim = ptb_va2pixel(va, dist, pipercm)
% stim = ptb_va2pixel(va, dist, pipercm)
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
%    stim          <struct> stimulus size in centimeter (.cm), points (.pt),
%                   and pixels (.pi).
%
% Created by Haiyang Jin (2023-April-30)

if nargin<1
    fprintf('Usage: stim = ptb_va2pixel(va, dist, pipercm);\n');
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

stim = struct();
% stimulus in centimeters
stim.cm = tan(deg2rad(va))*dist;
% stimulus in points
stim.pt = stim.cm * (72/2.54);
% stimulus in pixels
stim.pi = pipercm * stim.cm;

end