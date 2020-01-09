function ptb_checkbreak(ttn, param)
% check if a forced break should happen at this trial
%
% Inputs:
%    ttn           this trial number
%    param         experiment parameters
%
% Created by Haiyang Jin (2018)

% check if this trial number is N folder of the preset trial number
if (mod(ttn, param.trialsPerRest)==0 && ttn~=param.tn)
    
    % break message
    breakText = sprintf(['Please take a rest.\n\n You''re ' num2str(floor(100*ttn/param.tn),'%0.0f') '%% finished for this part.']);
    DrawFormattedText(param.w, breakText, 'center', param.screenY-150, param.forecolor);
    
    % show break message
    Screen('Flip', param.w);
    Beeper(1900,.15,.25);
    WaitSecs(param.restMinimumTime);
    
    % break finish message
    breakText = sprintf('You can now continue with this part.\n \nPress any key when ready.');
    DrawFormattedText(param.w, breakText, 'center', param.screenY-150, param.forecolor);
    
    Screen('Flip', param.w);
    Beeper(1280,.15,.25);
    
    RestrictKeysForKbCheck([]);
    KbWait([],3);
    
    clear breakText;
    
end

end