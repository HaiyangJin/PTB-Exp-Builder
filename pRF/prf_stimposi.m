function param = prf_stimposi(param)
% param = prf_stimposi(param)
%
% Inputs:
%     param        <struct> experiment parameters.
%     .prfcoordys  <str> pRF coordiante system. Default to 'Cartesian',
%                   alternative is 'polar'.
%     .prfNxy      <int> number of positions along different dimenstions.
%                   For 'Cartesian', {.prfNxy} refers to number of
%                   positions for rows and columns axis. 
%                   For 'polar', {.prfNxy} refers to the number of
%                   positions along each angle and the number of angles.
%     .canvasxy    <int> the X and Y size of the canvas to display the
%                   stimlus.
%
% Example 1:
% param = struct;
% param.canvasxy = [800, 800];
% param = prf_stimposi(param);
%
% Example 2:
% param = struct;
% param.canvasxy = [800, 800];
% param.prfcoorsys = 'polar';
% param = prf_stimposi(param);
%
% Created by Haiyang Jin (2023)

% Default settings
if ~isfield(param, 'prfcoorsys')
    prfcoorsys = 'Cartesian';
else
    prfcoorsys = param.prfcoorsys;
end
if ~isfield(param, 'prfNxy')
    prfNxy = [5, 4];
else
    prfNxy = param.prfNxy;
end
if ~isfield(param, 'canvasxy') && ~isfield(param, 'facebtw')
    oneside = floor(min(param.screenRect(3:4)) * .7);
    param.canvasxy = [oneside, oneside];
end

% generate the positions of stimulus centers
switch prfcoorsys
    case {'Cartesian', 'cartesian', 'carte', 'cart'}
        if ~isfield(param, 'canvasxy') && isfield(param, 'facebtw')
            param.canvasxy = (param.prfNxy-1) * param.facebtw; 
        end
        [param.prfposi, param.prfposi2] = prfposi_carte(prfNxy, param.canvasxy);

    case {'Polar', 'polar', 'pola'}
        % default of [phase] to 0
        if ~isfield(param, 'phase')
            phase = 0;
        else
            phase = param.phase;
        end
        if ~isfield(param, 'canvasxy') && isfield(param, 'facebtw')
            param.canvasxy = param.prfNxy * param.facebtw * 2;
        end
        [param.prfposi, param.prfposi2] = prfposi_polar(prfNxy, param.canvasxy, phase);

    otherwise
        error('Unknown coordinate systems...')
end
end

function [prfposi, prfposi2] = prfposi_carte(Nxy, canvasxy, ~)
% prfposi = prfposi_carte(Nxy, canvasxy, ~)
%
% Nxy        <int vec> the number of stimulus on each row and column.
% canvasxy   <int vec> the canvas of stimulus centers.

% distances between stim centers
distxy = arrayfun(@(x) floor(canvasxy(x)/(Nxy(x)-1)), 1:2);

% coordinates of all stim positions
xs = (0 : distxy(1) : canvasxy(1)) - canvasxy(1)/2;
ys = (0 : distxy(2) : canvasxy(2)) - canvasxy(2)/2;

% create all combinations
[x, y] = ndgrid(xs, ys);

% coordinates for all stim positions
prfposi = arrayfun(@(x,y) [x,y], x, y, 'uni', false);
prfposi2 = [x(:),y(:)];

end

function [prfposi, prfposi2] = prfposi_polar(Nxy, canvasxy, phase)
% prfposi = prfposi_polar(Nxy, canvasxy, phase)
%
% Nxy        <int vec> the number of angles and distances along each angle.
% canvasxy   <int vec> the canvas of stimulus centers (minimal distance
%             will be used).
% phase      <num> the starting angle. Default to 0.

if ~exist('phase', 'var') || isempty(phase)
    phase = 0;
end

% angles between positions
perangle = 360/Nxy(2);
% disntances between positions
perdist = min(canvasxy)/2/Nxy(1);

% all angles and distances
angles = (0 : perangle : 359) + phase;

% save the coordinates of the initial positions (along y-axis; positive)
distances = (0 : -perdist : -min(canvasxy)/2);
distances = [zeros(size(distances)); distances];

% rotate the initial positions
outposi = arrayfun(@(x) rotatecarte(distances, x), angles, 'uni', false);

% save as one cell
prfposi = horzcat(outposi{:});
prfposi2 = vertcat(prfposi{:})';
prfposi2 = unique(prfposi2','rows','stable'); % get unique columns

end

function outxy = rotatecarte(cartexy, angle)
% outxy = rotatecarte(cartexy, angle)
%
% cartexy  <mat> 2xM matrix. Each column is one cartesian coordinate: the
%           first and second rows are the x and y coordinates.
% angle    <num> the degree to be rotated counterclockwise.

if size(cartexy,1)~=2 && size(cartexy,2)==2
    cartexy = cartexy';
end

% rotate matrix
R = [cosd(angle) -sind(angle); sind(angle) cosd(angle)];

% rotate the points
outxy = num2cell((R * cartexy)', 2);

end
