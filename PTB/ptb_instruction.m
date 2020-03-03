function ptb_instruction(param)
% This function display the instructions.
%
% Inputs:
%     param               parameter used in ptb
%
% fieldnames of param used in this function:
%     .instructText       <string> or <cell of string> instruction(s) to
%                         be displayed. Strings in the cell are displayed
%                         in separate frames sequentially.
%     .instructKey        <string> or <cell of string>
%                         <string> the same key will be used for all
%                         frames.
%                         <cell of strings> different keys are used for
%                         each frame.
%     .w                  window code in PTB.
%     .forecolor          color of instruction texts
%
% If the instructKey is [], it will only display the instruction text
% and will not wait for responses. This is useful in fMRI experiments
% (where the screen will wait for triggers).
%
% created by Haiyang Jin (10-Feb-2020)

% convert the instructText to cell if it is char
if ischar(param.instructText)
    instructText = {param.instructText};
else
    instructText = param.instructText;
end

% convert the instructKey to cell if it is char
if isnumeric(param.instructKey)
    instructKey = {param.instructKey};
else
    instructKey = param.instructKey;
end

% convert the instructKey to a column if it is a row
if size(instructText, 2) > 1
    instructText  = instructText';
end

% check the number of instruct keys
if numel(instructKey) == 1
    instructKey = repmat(instructKey, numel(instructText), 1);
elseif numel(instructKey) ~= numel(instructText) % make sure the number of keys and texts are the same
    error('The number of instructions are not equal to the number of keys.');
end

% display the instructions
cellfun(@(x, y) disp_instruction(x, y, param), instructText, instructKey, 'uni', false);

end

function disp_instruction(instructText, instructKey, param)
% display the instruction

DrawFormattedText(param.w, instructText, 'center', 'center', param.forecolor);
Screen('Flip', param.w);

% do not wait for responses if the instructKey is 'none'
if ~isempty(instructKey)
    RestrictKeysForKbCheck(instructKey);
    KbWait([],2);
end

end