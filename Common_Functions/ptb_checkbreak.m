function ptb_checkbreak(ttn, param)

if (mod(ttn, param.trialsPerRest)==0 && ttn~=param.tn)
    
    breakText = sprintf(['Please take a rest.\n\n You''re ' num2str(floor(100*ttn/param.tn),'%0.0f') '%% finished for this part.']);
    DrawFormattedText(param.w, breakText, 'center', param.screenY-150, param.forecolor);
    
    Screen('Flip', param.w);
    Beeper(1900,.15,.25);
    WaitSecs(param.restMinimumTime);
    
    breakText = sprintf('You can now continue with this part.\n \nPress any key when ready.');
    DrawFormattedText(param.w, breakText, 'center', param.screenY-150, param.forecolor);
    
    Screen('Flip', param.w);
    Beeper(1280,.15,.25);
    
    RestrictKeysForKbCheck([]);
    KbWait([],3);
    
    clear breakText;
    
end


end