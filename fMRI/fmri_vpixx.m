function out = fmri_vpixx(status, corrButton)
% out = fmri_vpixx(status)
%
% Sets up the experiment to use Vpixx to wait for triggers, 'finish' 
% when it is triggered, or detect the response.
%
% Input:
%    status        <str> strings for different usage.
%                   'on' [default]: codes for starting the run;
%                   'off': codes for closing vpixx.
%                   'resp': detect the responses and output whether the five
%                           keys were pressed.
%                   'button': output all the available keys (which
%                             correspond to the output when using 'resp').
%    corrButton    <str> the button name of the correct response. Default
%                   is []. The correct button should be one of the
%                   available keys in 'button'.
%
% Output:
%    out           [when status is 'on' or 'off'], out is [];
%                  [when status is 'resp'], out is <num vector>, indicating
%                    whether the five keys were pressed.
%                  [when status is 'resp' and corrButton is not empty], out
%                    is a 1x2 vector, which were whether the pressed key
%                    matched the corrButton and when it was pressed.
%                  [when status is 'button'], out is <cell str>, listing all
%                    colors of available buttons.
%
% Created by Haiyang Jin (2021-12-06)

out = [];

if ~exist('status', 'var') || isempty(status)
    status = 'on';
end

if ~exist('corrButton', 'var') || isempty(corrButton)
    corrButton = [];
end
if ~isempty(corrButton)
    % make sure corrButton is one of the available keys
    buttons = fmri_vpixx('buttons');
    assert(ismember(corrButton, buttons));
end

switch status
    case 'on'
        %% Open the device and wait for trigger
        % The following code is obtained from the Scene study (SceneLocalizer.m).
        disp('Datapixx is ready...');

        % NYUAD_MRI_trigger_Datapixx;
        Datapixx('Open');
        Datapixx('StopAllSchedules');
        Datapixx('RegWrRd');
        init_check =dec2bin(Datapixx('GetDinValues'));
        trigger_state =init_check(14);

        while 1
            Datapixx('RegWrRd');
            regcheck =dec2bin(Datapixx('GetDinValues'));
            if regcheck(14) ~= trigger_state
                fprintf('Triggered!\n')
                break;
            end
        end

    case 'off'
        %% Close the device
        Datapixx('StopAllSchedule');
        Datapixx('Close');

    case {'resp', 'response'}
        %% Deal with responses
        Datapixx('RegWrRd');
        trialValues =dec2bin(Datapixx('GetDinValues'));

        % row vector
        buttonChecked = arrayfun(@(x) str2double(trialValues(x)), 15:19);
        
        % regard "all resp" as "no resp"
        if all(buttonChecked); buttonChecked = zeros(size(buttonChecked)); end
        
        respButton = buttons(logical(buttonChecked));
        out = cell(1,4);
        if ~isempty(respButton)
            out{1} = 1;
            out{2} = strcmp(respButton, corrButton);
            out(4) = respButton; 
        else
            out{1} = 0;
            out{2} = 0;
        end
        out{3} = GetSecs;

    case {'button', 'buttons'}
        %% All available responses
        out = {'white', 'blue', 'green', 'yellow', 'red'};

    otherwise
        error('Cannot recognize the status (%s) for fmri_vpixx().', status);
end

end