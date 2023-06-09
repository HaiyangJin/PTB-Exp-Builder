function el_end(param)
% el_end(param)
%
% This function finish eyelink.

% STEP 9
% End of Experiment; close the file first
% close graphics window, close data file and shut down tracker
Eyelink('Command', 'set_idle_mode');
% WaitSecs(0.05);
Eyelink('CloseFile');

% download data file
edfFile = param.elopts.edfFile;   
try
    fprintf('Receiving data file ''%s''\n', edfFile);
    status=Eyelink('ReceiveFile');
    if status > 0
        fprintf('ReceiveFile status %d\n', status);
    end
    if exist(edfFile, 'file')==2
        fprintf('Data file ''%s'' can be found in ''%s''\n', edfFile, pwd);
    end

    % move the edf file to a subfodler called "edf" in param.output
    ptb_mkdir(fullfile(param.outpath, 'edf'));
    movefile(edfFile, fullfile(param.outpath, 'edf', edfFile));
    
catch
    fprintf('Problem receiving data file ''%s''\n', edfFile);
end

% STEP 10
% close the eye tracker and window
Eyelink('ShutDown');

end