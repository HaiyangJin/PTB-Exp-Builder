function el_calivali(param)
% do calibration and validation

EyelinkDoTrackerSetup(param.el); %Calibrate
% EyelinkDoDriftCorrection(el); %Drift correction

%% This seems to be unnecessary.
% BUT REMEMBER, after each time you calibrate and correct for drift, you must
% again tell eyelink to record AND what the background color is meant
% to be. I've found that if I don't do this, the display screen will
% revert to the default background eyelink color (dark grey). 

% % start recording eye position
% Eyelink('StartRecording');
% % record a few samples before we actually start displaying
% WaitSecs(0.1);
% % mark zero-plot time in data file
% Eyelink('Message', 'SYNCTIME')
% 
% Screen('FillRect', el.window, instructionColor);

end