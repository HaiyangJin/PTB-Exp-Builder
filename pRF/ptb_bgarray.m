function ptb_bgarray(param)
% ptb_bgarray(param)
% 
% Draw array of circles as background.
%
% Inputs:
%    param             <struct> the experiment parameters.
%    .bgarraycolor     <vec> the circle color.
%    .circleva         <num vec> visual angles for each circle.
%    .nradial          <int> number of radial lines. Default to 8.
%    .radialphase      <num> starting phase. Default to 0.
%    {other param obtained from ptb_screensize()}
%
% Output:
%    draw circles.
%
% Created by Haiyang Jin (2023-May-1)

if ~isfield(param, 'bgarraycolor') || isempty(param.bgarraycolor)
    param.bgarraycolor = [165, 165, 165];
end

if ~isfield(param, 'circleva') || isempty(param.circleva)
    param.circleva = 1:100;
end

if ~isfield(param, 'nradial') || isempty(param.nradial)
    param.nradial = 8;
end

if ~isfield(param, 'radialphase') || isempty(param.radialphase)
    param.radialphase = 0;
end

assert(isfield(param, 'distance'), ['Please set the distance between the ' ...
    'participant and screen (e.g., param.distance = 57;).']);
assert(isfield(param, 'pipercm'), ['Please use ptb_screensize() to get ' ...
    'the pixels per centimeter.']);

%% Draw circles
% pixels for each circle
pixels_size = arrayfun(@(x) ptb_va2pixel(x, param.distance, param.pipercm), param.circleva);
pixels = [pixels_size.pi];

% rects for all circles
circlearray=[param.screenCenX-pixels;
    param.screenCenY-pixels;
    param.screenCenX+pixels;
    param.screenCenY+pixels];

% Draw circle frames
Screen('FrameOval', param.w, param.bgarraycolor, circlearray);

%% Draw radants
alinemat = ones(1,param.screenX,3)*param.bgarraycolor(1);
alinealpha = ones(1,param.screenX)*255;
alinealpha(:,param.screenCenX-pixels(1):param.screenCenX+pixels(1)) = 0;
aline = Screen('MakeTexture', param.w, cat(3,alinemat, alinealpha));
% Screen('Drawline', aline, param.bgarraycolor, ...); % x, y in tex coordinates
% Screen('DrawLines', windowPtr, xy [,width] [,colors] [,center] [,smooth][,lenient]);

% display the line
alinePosi = [1, param.screenCenY-1, param.screenX, param.screenCenY];
rotates = param.radialphase + (0: (360/param.nradial): 359);
arrayfun(@(x) Screen('DrawTexture', param.w, aline, [], alinePosi, x), ...
    rotates, 'uni', false); % rotationAngle can keep changing

end