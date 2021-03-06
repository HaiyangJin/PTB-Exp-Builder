function ptb_disptext(param, texts, respKey)
% ptb_disptext(param, texts, respKey)
%
% This function displays the texts with .forecolor.
%
% Inputs:
%     param      <structure> parameters.
%     texts      <string> the texts to be displayed.
%     respKey    <string> the key name. Default is any key.
%
% Created by Haiyang Jin (6-March-2020)

if ~exist('respKey', 'var') || isempty(respKey)
    respKey = [];
elseif isstring(respKey)
    respKey = KbName(respKey);
end

DrawFormattedText(param.w, texts, 'center', 'center', param.forecolor);
Screen('Flip', param.w);
RestrictKeysForKbCheck(respKey);
KbWait([], 2);

end