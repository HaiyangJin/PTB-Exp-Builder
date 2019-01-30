function ptb_output(param, stimuli)

%% filenames
excelDir = ['Excel Data' filesep];
excelExtension = '.xlsx';
saveDir = ['Matlab Data' filesep];
% backupDir = ['']; % this should be the full path to the dropbox on the main experiment computer

thisDateVector = now;
theDateString = datestr(thisDateVector,'yyyy-mm-dd-HHMM');
% theDate8 = str2double(datestr(thisDateVector,'yyyymmdd'));
theDataFilename = [param.subjCode '_' param.expNum '_' param.experimentAbbv '_' theDateString];
theExcelFile = [excelDir theDataFilename excelExtension];
theMatlabFile = [saveDir theDataFilename '.mat'];


%% save the files
save(theMatlabFile, 'param', 'stimuli');
writetable(param.dtTable, theExcelFile);

end