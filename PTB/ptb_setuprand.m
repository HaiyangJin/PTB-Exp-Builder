function ptb_setuprand
% ptb_setuprand
%
% This function is created based on Sam's code [SetupRand.m].
%
% Copied by Haiyang Jin (22-Feb-2020)

%%%%%%%%%%%%%%%%%%%% copied from here %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Set up the randomizers for uniform and normal distributions.
% It is of great importance to do this before anything else!

try
    % Use the recommended method in Matlab R2012a.
%     rng('default');
    rng('shuffle');
    disp('Using modern randomizer...');
    
catch
    % Use worse methods for old versions of Matlab (e.g. 7.1.0.246 (R14) SP3).
    try
        rand('twister',sum(100*clock));
        randn('state',sum(100*clock));
        warning('Using outdated randomizer...');
    catch
        % For very old Matlab versions these are the only methods you can use.
        % These are supposed to be flawed although you will probably not
        % notice any effect of this for most situations.
        rand('state',sum(100*clock));
        randn('state',sum(100*clock));
        warning('Using "flawed" randomizer...');
    end
end

end