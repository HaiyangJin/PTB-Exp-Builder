function objSize = im_objsize(degree, objDist)
% objSize = im_objsize(degree, objDist)
%
% This function calculates the object size based on the visual angle and
% object distance (based on https://elvers.us/perception/visualAngle/va.html).
% Please make sure the units of objSize and objDist are the same.
%
% Inputs:
%     degree      <numeric> the visual angle in degrees.
%     objDist     <numeric> the distance from the eyes to the object.
%
% Output:
%     objSize     <numeric> or <array of numeric> the size of the object;
%
% Usage:
%     objSize = im_objsize([4.7719, 9.5273], 60);
% 
% The reverse function is im_va.m.
%
% Created by Haiyang Jin (18-Feb-2020)

% the visual angle in radians
radians = degree * pi / 180;

% the object size (in the same unit as objDist)
objSize = 2 * tan(radians/2) * objDist;

end