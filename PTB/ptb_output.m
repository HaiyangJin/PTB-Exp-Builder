function [acc, nResp] = ptb_output(param, fnExtra, outPath)
% [acc, nResp] = ptb_output(param, fnExtra, outPath)
%
% Save the experiment parameters, stimuli structure, and save the output as
% *.xlsx and *.csv.
% 
% Inputs:
%     param         <struc> experiment parameters.
%     fnExtra       <str> unique strings at the end of the file name.
%     outPath       <str> where these files will be saved.
% 
% Output:
%     acc           <num> the average accuracy across all trials.
%     nResp         <int> the number of responses detected.
%
% Created by Haiyang Jin (2018)

% quit if param.dtTable is empty
if isempty(param.dtTable)
    acc = 0;
    nResp = 0;
    return;
else
    acc = NaN;
    nResp = NaN;
end

if ismember('isCorrect', param.dtTable.Properties.VariableNames)
    acc = 100*mean(param.dtTable.isCorrect, 'omitnan');
end
if ismember('Response', param.dtTable.Properties.VariableNames)
    nResp = sum(~isnan(param.dtTable.Response));
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
csvPath = fullfile(outPath, 'data');
matPath = fullfile(outPath, 'MatBackup');
ptb_mkdir(csvPath);
ptb_mkdir(matPath);

outFn = [param.subjCode '_' param.expCode '_' param.expAbbv '_' fnExtra];
theCSVFile = fullfile(csvPath, [outFn '.csv']);
theMatlabFile = fullfile(matPath, [outFn '.mat']);

%% save the files
save(theMatlabFile, '-struct', 'param');
writetable(param.dtTable, theCSVFile);

end