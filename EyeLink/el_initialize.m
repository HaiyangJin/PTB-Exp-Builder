function param = el_initialize(param)
% param = el_initialize(param)
%
% This function should run after ptb_initialize()

% initialize the struct for opts
elopts = struct;

%% STEP 1
% Open a graphics window on the main screen
% using the PsychToolbox's Screen function.
% backgroundColor = 0;
% instructionColor = 255;
% screenNumber = max(Screen('Screens'));
% [window, screenRect]=Screen('OpenWindow', screenNumber, backgroundColor,[],32,2);
% Screen('BlendFunction',window,GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
%
% Done by ptb_initialize()

%% STEP 2
% Provide Eyelink with details about the graphics environment
% and perform some initializations. The information is returned
% in a structure that also contains useful defaults
% and control codes (e.g. tracker state bit and Eyelink key values).
el=EyelinkInitDefaults(param.window);

%% STEP 3
% Initialization of the connection with the Eyelink Gazetracker.
dummymode = param.eldummymode;       % set to 1 to initialize in dummymode

% exit program if this fails.
if ~EyelinkInit(dummymode)
    fprintf('Eyelink Initialization aborted.\n');
    return;
end

%% STEP 4
% the following code is used to check the version of the eye tracker
% and version of the host software
sw_version = 0;
[elopts.version, elopts.vs]=Eyelink('GetTrackerVersion');
fprintf('Running experiment on a ''%s'' tracker.\n', param.elopts.vs);

%% STEP 5
% Name Eyelinke file and open it to record data 
elopts.edfFile = [param.experimentAbbv, param.subjCode]; 

i = Eyelink('Openfile', elopts.edfFile);
if i~=0
    fprintf('Cannot create EDF file ''%s'' ', elopts.edfFile);
    Eyelink( 'Shutdown');
    Screen('CloseAll');
    return;
end

%% STEP 6
% SET UP TRACKER CONFIGURATION
Eyelink('command', 'add_file_preamble_text ''Recorded by Haiyang Jin''');
% set the sampling rate 
Eyelink('command', 'sample_rate = 1000');

% Setting the proper recording resolution, proper calibration type, 
% as well as the data file content;
Eyelink('command','screen_pixel_coords = %ld %ld %ld %ld', 0, 0, screenX-1, screenY-1);
Eyelink('message', 'DISPLAY_COORDS %ld %ld %ld %ld', 0, 0, screenX-1, screenY-1);    

% set calibration type.
Eyelink('command', 'calibration_type = HV9');
% set parser (conservative saccade thresholds)

% set EDF file contents using the file_sample_data and
% file-event_filter commands
% set link data thtough link_sample_data and link_event_filter
Eyelink('command', 'file_event_filter = LEFT,RIGHT,FIXATION,SACCADE,BLINK,MESSAGE,BUTTON,INPUT');
Eyelink('command', 'link_event_filter = LEFT,RIGHT,FIXATION,SACCADE,BLINK,MESSAGE,BUTTON,INPUT');

% check the software version
% add "HTARGET" to record possible target data for EyeLink Remote
if sw_version >=4
    Eyelink('command', 'file_sample_data  = LEFT,RIGHT,GAZE,HREF,AREA,HTARGET,GAZERES,STATUS,INPUT');
    Eyelink('command', 'link_sample_data  = LEFT,RIGHT,GAZE,GAZERES,AREA,HTARGET,STATUS,INPUT');
else
    Eyelink('command', 'file_sample_data  = LEFT,RIGHT,GAZE,HREF,AREA,GAZERES,STATUS,INPUT');
    Eyelink('command', 'link_sample_data  = LEFT,RIGHT,GAZE,GAZERES,AREA,STATUS,INPUT');
end

% allow to use the big button on the eyelink gamepad to accept the 
% calibration/drift correction target
% Eyelink('command', 'button_function 5 "accept_target_fixation"');

% make sure we're still connected.
if Eyelink('IsConnected')~=1 && dummymode == 0
    fprintf('not connected, clean up\n');
    Eyelink( 'Shutdown');
    Screen('CloseAll');
    return;
end

%% STEP 7
% Setup the proper calibration parameters
% setup the proper calibration foreground and background colors
el.backgroundcolour = param.backcolor;
el.calibrationtargetcolour = param.forecolor;

% parameters are in frequency, volume, and duration
% set the second value in each line to 0 to turn off the sound
el.cal_target_beep=[600 0.5 0.05];
el.drift_correction_target_beep=[600 0.5 0.05];
el.calibration_failed_beep=[400 0.5 0.25];
el.calibration_success_beep=[800 0.5 0.25];
el.drift_correction_failed_beep=[400 0.5 0.25];
el.drift_correction_success_beep=[800 0.5 0.25];
% you must call this function to apply the changes above
EyelinkUpdateDefaults(el);

% Hide the mouse cursor;
% Screen('HideCursorHelper', window);
fprintf('Before.\n' );
EyelinkDoTrackerSetup(el);
fprintf('Tracker.\n' );

% save the el and opts in param
param.el = el;
param.elopts = elopts;

%% STEP 8
% Now starts running individual trials;
%
% You can keep the rest of the code except for the implementation
% of graphics and event monitoring 
% Each trial should have a pair of "StartRecording" and "StopRecording" 
% calls as well integration messages to the data file (message to mark 
% the time of critical events and the image/interest area/condition 
% information for the trial)
%
% more see el_trial() and demo1_trial();

%% STEP 9
% End of Experiment; close the file first   
% close graphics window, close data file and shut down tracker
% 
% more see el_end();

%% STEP 10
% close the eye tracker and window
%
% more see el_end();

end %function el_initialize 