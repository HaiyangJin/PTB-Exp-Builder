function degree = im_va(objSize, objDist)
% degree = im_va(objSize, objDist)
%
% This function calculates the visual angle of the objects (based on
% https://elvers.us/perception/visualAngle/va.html). Please make sure the
% units of objSize and objDist are the same.
% 
% Inputs:
%     objSize     <numeric> or <array of numeric> the size of the object;
%     objDist     <numeric> the distance from the eyes to the object.
%
% Output:
%     degree       <numeric> the visual angle in degrees.
%
% Usage:
%     degree = im_va([5, 10], 60);
%     
% Created by Haiyang Jin (18-Feb-2020)

% get the radians
radians = 2 * atan(objSize/2/objDist);

% convert radians to degrees
degree = radians * 180 / pi;

end