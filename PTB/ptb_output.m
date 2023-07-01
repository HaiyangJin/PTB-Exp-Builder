function [acc, nResp, param] = ptb_output(param, fnExtra, outPath)
% [acc, nResp, param] = ptb_output(param, fnExtra, outPath)
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
    param.outfn = '';
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
    fnExtra = ['timestamp-' char(datetime('now', 'Format', 'yyyyMMddHHmm'))];
end

if ~exist('outPath', 'var') || isempty(outPath)
    outPath = fullfile(pwd, '0_BehaData');
    param.outpath = outPath;
end
ptb_mkdir(outPath);

%% file names
csvPath = fullfile(outPath, 'data');
matPath = fullfile(outPath, 'MatBackup');
ptb_mkdir(csvPath);
ptb_mkdir(matPath);

outFn = sprintf('sub-%s_task-%s_%s', param.subjCode, lower(param.expAbbv), fnExtra);
param.outfn = outFn;
theCSVFile = fullfile(csvPath, [outFn '.csv']);
theMatlabFile = fullfile(matPath, [outFn '.mat']);

%% remove matrix in param.stimuli
allfields = fieldnames(param);
toclear = cellfun(@(x) startsWith(x,'stimuli'), allfields);
for ifield = allfields(toclear)'
    param.(ifield{1}) = removematcell(param.(ifield{1}));
end

%% save the files
save(theMatlabFile, '-struct', 'param');
writetable(param.dtTable, theCSVFile);

end

function stimuli = removematcell(stimuli)
% just in case some stimuli is cell instead of struct
    if isstruct(stimuli)
        stimuli = removemat(stimuli);
    elseif iscell(stimuli)
        stimuli = cellfun(@removemat, stimuli, 'uni', false);
    end
end

function stimuli = removemat(stimuli)
% empty .matrix and .alpha
emptycell = repmat({[]}, size(stimuli));
[stimuli.matrix] = deal(emptycell{:});
[stimuli.alpha] = deal(emptycell{:});

end