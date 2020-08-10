function [acc, nResp] = ptb_output(param, fnExtra, outPath)
% [acc, nResp] = ptb_output(param, fnExtra, outPath)
%
% Save the experiment parameters, stimuli structure, and save the output as
% *.xlsx and *.csv.
% 
% Inputs:
%     param         <structure> experiment parameters.
%     fnExtra       <string> unique strings at the end of the file name.
%     outPath       <string> where these files will be saved.
% 
% Output:
%     acc           <numeric> the average accuracy across all trials.
%     nResp         <integer> the number of responses detected.
%
% Created by Haiyang Jin (2018)

% quit if param.dtTable is empty
if isempty(param.dtTable)
    acc = 0;
    nResp = 0;
    return;
elseif ismember('isCorrect', param.dtTable.Properties.VariableNames)
    acc = 100*mean(param.dtTable.isCorrect, 'omitnan');
    nResp = sum(~isnan(param.dtTable.isCorrect));
else
    acc = NaN;
    nResp = NaN;
end

% Do not save files if debug model is on
if param.isDebug
    return;
end

if ~exist('fnExtra', 'var') || isempty(fnExtra)
    fnExtra = datestr(now,'yyyy-mm-dd-HHMM');
end

if ~exist('outPath', 'var') || isempty(outPath)
    outPath = pwd;
end

%% file names
excelPath = fullfile(outPath, 'Excel Data');
matPath = fullfile(outPath, 'Matlab Data');
if ~exist(excelPath, 'dir'); mkdir(excelPath); end
if ~exist(matPath, 'dir'); mkdir(matPath); end
% backupDir = ['']; % this should be the full path to the dropbox on the main experiment computer

outputFn = [param.subjCode '_' param.expCode '_' param.expAbbv '_' fnExtra];
theExcelFile = fullfile(excelPath, [outputFn '.xlsx']);
theMatlabFile = fullfile(matPath, [outputFn '.mat']);

%% save the files
save(theMatlabFile, '-struct', 'param');
writetable(param.dtTable, theExcelFile);

end