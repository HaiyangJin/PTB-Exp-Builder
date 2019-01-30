function fixArray = ptb_fixcross(screenX, screenY, widthFix, lengthFix)

if nargin < 3
    widthFix = 4;
end
if nargin < 4
    lengthFix = 20;
end

fixArray = ([screenX/2-widthFix/2, screenY/2-lengthFix/2,...
    screenX/2+widthFix/2, screenY/2+lengthFix/2; % vertical
    screenX/2-lengthFix/2, screenY/2-widthFix/2, ...
    screenX/2+lengthFix/2, screenY/2+widthFix/2])'; % horizontal

end