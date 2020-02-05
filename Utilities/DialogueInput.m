% Example for opening a window to collect participant's information.

% prompt for each question
prompt = {'Enter the participant code: ', ...
    'Enter the ethnicity of participant: ', ... % (Caucasian: 1, Chinese: 2)
    'Enter the ethnicity of stimuli used: (Caucasian: 1, Chinese: 2)', ...
    'Will EyeLink be used? (Yes: 1, No: 0)'};

% title for the dialogue
title = 'Please input the information';

% 
dims = [1 50];

% default inputs
defaultInput = {'300', '2', '2', '0'};

% open the window
inputs = inputdlg(prompt, title, dims, defaultInput);

% collect the values for each input
participantNum = inputs{1};
subjRace = str2double(inputs{2});
stimRace = str2double(inputs{3});
isEyelink = str2double(inputs{4});


