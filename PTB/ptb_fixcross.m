function fixArray = ptb_fixcross(winX, winY, fixWidth, fixLength)
% This function creates the matrix for the fixation cross.
%
% Inputs:
%     winX            <integer> the width of the window
%     winY            <integer> the height of the window
%     fixWidth        <integer> the width of the horizontal and vertical
%                     "white" lines
%     fixLength       <integer> the length of the horizontal and vertical
%                     "white" lines
% Output:
%     fixArray        the fixation array
%
% Created by Haiyang Jin (2018)

if nargin < 3
    fixWidth = 4;
end
if nargin < 4
    fixLength = 20;
end

fixArray = ([winX/2-fixWidth/2, winY/2-fixLength/2,...
    winX/2+fixWidth/2, winY/2+fixLength/2; % vertical matrix
    winX/2-fixLength/2, winY/2-fixWidth/2, ...
    winX/2+fixLength/2, winY/2+fixWidth/2])'; % horizontal matrix

end