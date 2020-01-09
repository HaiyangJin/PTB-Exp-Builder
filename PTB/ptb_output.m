function ptb_output(param, stimuli, output_path)
% Save the experiment parameters, stimuli structure, and save the output as
% *.xlsx and *.csv.
% 
% Inputs:
%     param         experiment parameters
%     stimuli       stimuli structure used in this experiment
%     output_path   where these files will be saved
%
% Created by Haiyang Jin (2018)

% Do not save files if debug model is on
if param.isDebug
    return;
end

if nargin < 3 || isempty(output_path)
    output_path = pwd;
end

%% filenames
excelDir = fullfile(output_path, 'Excel Data');
saveDir = fullfile(output_path, 'Matlab Data');
if ~exist(excelDir, 'dir'); mkdir(excelDir); end
if ~exist(saveDir, 'dir'); mkdir(saveDir); end
% backupDir = ['']; % this should be the full path to the dropbox on the main experiment computer

thisDateVector = now;
theDateString = datestr(thisDateVector,'yyyy-mm-dd-HHMM');
% theDate8 = str2double(datestr(thisDateVector,'yyyymmdd'));

theDataFilename = [param.subjCode '_' param.expCode '_' param.expAbbv '_' theDateString];
theExcelFile = fullfile(excelDir, [theDataFilename '.xlsx']);
theMatlabFile = fullfile(saveDir, [theDataFilename '.mat']);


%% save the files
save(theMatlabFile, 'param', 'stimuli');
writetable(param.dtTable, theExcelFile);

end