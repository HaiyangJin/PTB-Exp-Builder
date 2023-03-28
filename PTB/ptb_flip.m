function nextBeginsWhen = ptb_flip(param, beginWhen, duration)
% nextBeginsWhen = ptb_flip(param, beginWhen, duration)
%
% Flip screen and record screens to video.
%
% Inputs:
%    param            <struct> parameters.
%    beginWhen        <num> timestamp to flip. Default to GetSecs (now).
%    duration         <num> duration of this flip (in seconds). Default to
%                      0, i.e., not add to the video.
%
% Output:
%    nextBeginsWehn   <num> timestamp for next screen to flip. 
%
% Created by Haiyang Jin (2023-March-28)

if ~exist('beginWhen', 'var') || isempty(beginWhen)
    beginWhen = GetSecs;
end

if ~exist('duration', 'var') || isempty(duration)
    duration = 0;
end

% flip the screen
BeganAt = Screen('Flip', param.w, beginWhen);
nextBeginsWhen = BeganAt + duration - param.flipSlack;

% add frames to the record if needed
if param.record && duration > 0
    frameduration = floor(duration*30);
    Screen('AddFrameToMovie', param.w, [], [], param.mvptr,frameduration);
end

end