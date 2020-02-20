function acc = ptb_output(param, stimuli, outputPath)
% Save the experiment parameters, stimuli structure, and save the output as
% *.xlsx and *.csv.
% 
% Inputs:
%     param         experiment parameters
%     stimuli       stimuli structure used in this experiment
%     output_path   where these files will be saved
%
% Created by Haiyang Jin (2018)

% quit if param.dtTable is empty
if isempty(param.dtTable)
    acc = 0;
    return;
else
    acc = 100*mean(param.dtTable.isCorrect);
end

% Do not save files if debug model is on
if param.isDebug
    return;
end

if nargin < 3 || isempty(outputPath)
    outputPath = pwd;
end

%% file names
excelDir = fullfile(outputPath, 'Excel Data');
saveDir = fullfile(outputPath, 'Matlab Data');
if ~exist(excelDir, 'dir'); mkdir(excelDir); end
if ~exist(saveDir, 'dir'); mkdir(saveDir); end
% backupDir = ['']; % this should be the full path to the dropbox on the main experiment computer

thisDateVector = now;
theDateString = datestr(thisDateVector,'yyyy-mm-dd-HHMM');
% theDate8 = str2double(datestr(thisDateVector,'yyyymmdd'));

theDataFn = [param.subjCode '_' param.expCode '_' param.expAbbv '_' theDateString];
theExcelFile = fullfile(excelDir, [theDataFn '.xlsx']);
theMatlabFile = fullfile(saveDir, [theDataFn '.mat']);


%% save the files
save(theMatlabFile, 'param', 'stimuli');
writetable(param.dtTable, theExcelFile);

end