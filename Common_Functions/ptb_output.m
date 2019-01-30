function ptb_output(param, stimuli)

%% filenames
excelDir = ['Excel Data' filesep];
excelExtension = '.xlsx';
saveDir = ['Matlab Data' filesep];
% backupDir = ['']; % this should be the full path to the dropbox on the main experiment computer

thisDateVector = now;
theDateString = datestr(thisDateVector,'yyyy-mm-dd-HHMM');
% theDate8 = str2double(datestr(thisDateVector,'yyyymmdd'));
theDataFilename = [param.subjCode '_' param.expCode '_' param.expAbbv '_' theDateString];
theExcelFile = [excelDir theDataFilename excelExtension];
theMatlabFile = [saveDir theDataFilename '.mat'];

if ~exist(excelDir, 'dir'); mkdir(excelDir); end
if ~exist(saveDir, 'dir'); mkdir(saveDir); end

%% save the files
save(theMatlabFile, 'param', 'stimuli');
writetable(param.dtTable, theExcelFile);

end