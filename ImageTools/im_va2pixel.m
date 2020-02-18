function stimPixel = im_va2pixel(va, screenReso, screenSize, screenDist)
% stimPixel = im_va2pixel(va, screenReso, screenSize, screenDist)
%
% This function calculates the stimulus size in pixels based on the visual
% angle.
%
% Inputs:
%     va               <numeric> or <vector of numeric> the visual angles
%                      in degrees. The number of rows should be the same as
%                       the length of screenReso and screenSize.
%     screenReso       <numeric> or <vector of numeric> the resolution of 
%                      the screen along the stimPixel dimension (in pixels).
%     screenSize       <numeric> or <vector of numeric> sizes of screenReso 
%                      in the actual units (cm or mm).
%     screenDist       <numeric> the distance from the screen to the eyes
%                      in actual units (cm or mm).
%
% Output:
%     stimPixel        <numeric> or <array of numeric> the pixel size of
%                      the stimlui displayed on the screen. 
%
% Usage:
%     im_va2pixel([1.4210, 6.9538], [1920,1080], [53,30], 63);
%     im_va2pixel([1.4210,2.2165, 2.8415;8.9082, 11.3878,13.3288],[1920,1080], [30,53], 63);
%
% Created by Haiyang Jin (18-Feb-2020)

[nXva, nYva] = size(va); % the number of rows and columns
nScreenReso = numel(screenReso);
nScreenSize = numel(screenSize);

% The lengths of screenReso and screenSize have to be the same.
if nScreenReso ~= nScreenSize
    error('The lengths of screenReso (%d) and screenSzie (%d) have to be the same.',...
        nScreenReso, nScreenSize);
end

% transpose va if necessary [a, b] to [a; b]
if nXva == 1 && nYva == nScreenReso 
    va = transpose(va);
    nXva = nYva;
end
    
% The number of rows in va have to be same as the length of sreenReso.
if nXva ~= nScreenReso
    error(['The number of rows in stimPixel (%d) have to be same as '...
        'the length of sreenReso (%d).'], nXva, nScreenReso);
end

% calculate the object size
stimSize = im_objsize(va, screenDist);

% cell of the stimulus sizes
stimPixel = arrayfun(@(x) stimSize(x, :)* screenReso(x) / screenSize(x), ...
    1:nXva, 'uni', false);

% calculate the stimPixel
stimPixel = vertcat(stimPixel{:});

end