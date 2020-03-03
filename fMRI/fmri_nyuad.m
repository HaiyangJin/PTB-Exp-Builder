function fmri_nyuad
% fmri_nyuad
%
% This function sets up the experiment to wait for triggers and 'finishi'
% when it is triggered.
%
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

end