function param = ptb_winrect(param)
% param = ptb_winrect(param)
%
% This function to set the param.winrect if needed. '.winrect' could be
% negative integer.
%
% Input:
%     param     <structre> the parameter structure;
%
% Output:
%     param     <structre> the parameter structure;
%
%
% '.winrect' will be set as 
%
% Created by Haiyang Jin (6-March-2020)

winrects = [...
    100 100 600 600;
    100 100 1300 900];

% set when .winrect is negative
if any(param.winrect < 0)
    param.winrect = winrects(-param.winrect, :);
end

% set for debugging
if param.isDebug
    param.winrect = winrects(2, :);
end

end