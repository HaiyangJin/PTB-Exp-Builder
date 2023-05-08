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
    if strcmp(param.language, 'en')
        breakText = sprintf(['Please take a rest.\n\n You''re ' ...
            num2str(floor(100*ttn/param.tn),'%0.0f') '%% finished for this part.']);
    elseif strcmp(param.language, 'cn')
        breakText = double(sprintf(['请稍作休息。\n\n你已经完成了这部分的' ...
            num2str(floor(100*ttn/param.tn)) '%%。']));
    end
    DrawFormattedText(param.w, breakText, 'center', param.screenY-150, param.forecolor);
    
    % show break message
    Screen('Flip', param.w);
    Beeper(1900,.15,.25);
    WaitSecs(param.restMinimumTime);
    
    % break finish message
    DrawFormattedText(param.w, param.breakEndText, 'center', param.screenY-150, param.forecolor);
    
    Screen('Flip', param.w);
    Beeper(1280,.15,.25);
    
    RestrictKeysForKbCheck([]);
    KbWait([],3);

    % re-calibrate and validate (if needed)
    if param.isEyelink; el_calivali(param); end
        
end

end