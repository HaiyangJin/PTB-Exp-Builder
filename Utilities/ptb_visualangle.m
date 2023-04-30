function va = ptb_visualangle(stimSize, dist)
% va = ptb_visualangle(stimSize, dist)
%
% Caulcalate the visual angle (assuming the participant is front of the
% monitor and fixate at the center of the screen, and one end of the
% stimulus is at the center of screen). 
%
% Input:
%    stimSize      <num> size of the stimulus in centimeter.
%    dist          <num> distance between the participant and the screen
%                   (in centimeter, at least its unit should match {stimSize}).
%
% Output:
%    va            <num> visual angle in degrees. 
%
% Created by Haiyang Jin (2023-April-30)
%
% See also:
% ptb_screensize()

if nargin<1
    fprintf('Usage: va = ptb_visualangle(stimSize, dist);\n');
    return
end

if ~exist('dist', 'var') || isempty(dist)
    dist = 57;
end

% calculate the visual angle
va = rad2deg(atan((stimSize)/dist));

end

