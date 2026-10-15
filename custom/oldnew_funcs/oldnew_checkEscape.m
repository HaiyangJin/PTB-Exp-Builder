function [quitNow, firstPressAll] = oldnew_checkEscape(param, firstPressAll, keyboardDevice)
% OLDNEW_CHECKESCAPE Detect ESC using KbCheck, without KbQueue.

if nargin < 3 || isempty(keyboardDevice)
    keyboardDevice = 0;
end

quitNow = 0;
[keyIsDown, secs, keyCode] = KbCheck(keyboardDevice);

if isempty(firstPressAll)
    firstPressAll = zeros(size(keyCode));
end

if keyIsDown
    newPresses = logical(keyCode) & (firstPressAll == 0);
    firstPressAll(newPresses) = secs;
end

if any(firstPressAll(param.expKey) > 0)
    quitNow = 1;
end
end
