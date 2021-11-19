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
csvPath = fullfile(outPath, 'data');
matPath = fullfile(outPath, 'matbackup');
ptb_mkdir(csvPath);
ptb_mkdir(matPath);

outputFn = [param.subjCode '_' param.expCode '_' param.expAbbv '_' fnExtra];
theCSVFile = fullfile(csvPath, [outputFn '.csv']);
theMatlabFile = fullfile(matPath, [outputFn '.mat']);

%% save the files
save(theMatlabFile, '-struct', 'param');
writetable(param.dtTable, theCSVFile);

end