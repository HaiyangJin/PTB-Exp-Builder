function ptb_drawcirclearray(param)
% ptb_drawcirclearray(param)
% 
% Draw array of circles as background.
%
% Inputs:
%    param             <struct> the experiment parameters.
%    .circlecolor      <vec> the circle color.
%    .circleva         <num vec> visual angles for each circle.
%    {other param obtained from ptb_screensize()}
%
% Output:
%    draw circles.
%
% Created by Haiyang Jin (2023-May-1)

if ~isfield(param, 'circlecolor') || isempty(param.circlecolor)
    param.circlecolor = [200, 200, 200];
end

if ~isfield(param, 'circleva') || isempty(param.circleva)
    param.circleva = 1:20;
end

assert(isfield(param, 'distance'), ['Please set the distance between the ' ...
    'participant and screen (e.g., param.distance = 57;).']);
assert(isfield(param, 'pipercm'), ['Please use ptb_screensize() to get ' ...
    'the pixels per centimeter.']);

% pixels for each circle
pixels = arrayfun(@(x) ptb_va2pixel(x, param.distance, param.pipercm), param.circleva);

% rects for all circles
circlearray=[param.screenCenX-pixels;
    param.screenCenY-pixels;
    param.screenCenX+pixels;
    param.screenCenY+pixels];

% Draw circle frames
Screen('FrameOval', param.w, param.circlecolor, circlearray);

end