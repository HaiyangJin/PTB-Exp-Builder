function va = im_pixel2va(stimPixel, screenReso, screenSize, screenDist)
% va = im_pixel2va(stimPixel, screenReso, screenSize, screenDist)
%
% This function calculates the visual angle for the stimuli displayed on
% the screen.
%
% Inputs:
%     stimPixel        <numeric> or <array of numeric> the pixel size of
%                      the stimlui displayed on the screen. The number of 
%                      rows should be the same as the length of screenReso 
%                      and screenSize.
%     screenReso       <numeric> or <vector of numeric> the resolution of 
%                      the screen along the stimPixel dimension (in pixels).
%     screenSize       <numeric> or <vector of numeric> sizes of screenReso 
%                      in the actual units (cm or mm).
%     screenDist       <numeric> the distance from the screen to the eyes
%                      in actual units (cm or mm).
%
% Output:
%     va               <numeric> or <vector of numeric> the visual angles
%                      in degrees.
%
% Usage:
%     va = im_pixel2va([100, 156], [1920, 1080], [30, 53], 63);
%     va = im_pixel2va([100, 156, 200; 200, 256, 300], [1920, 1080], [30, 53], 63);
%
% Created by Haiyang Jin (18-Feb-2020)

[nXStim, nYStim] = size(stimPixel); % the number of rows and columns
nScreenReso = numel(screenReso);
nScreenSize = numel(screenSize);

% The lengths of screenReso and screenSize have to be the same.
if nScreenReso ~= nScreenSize
    error('The lengths of screenReso (%d) and screenSzie (%d) have to be the same.',...
        nScreenReso, nScreenSize);
end

% transpose stimPixel if necessary [a, b] to [a; b]
if nXStim == 1 && nYStim == nScreenReso 
    stimPixel = transpose(stimPixel);
    nXStim = nYStim;
end
    
% The number of rows in stimPixel have to be same as the length of
% sreenReso.
if nXStim ~= nScreenReso
    error(['The number of rows in stimPixel (%d) have to be same as '...
        'the length of sreenReso (%d).'], nXStim, nScreenReso);
end

% cell of the stimulus sizes
stimSize = arrayfun(@(x) stimPixel(x, :)* screenSize(x) / screenReso(x), ...
    1:nXStim, 'uni', false);

% array of the stimulus sizes
stimSize = vertcat(stimSize{:});

% calculate the visual angels in degrees
va = im_va(stimSize, screenDist);

end