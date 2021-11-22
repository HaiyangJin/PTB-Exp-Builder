function runCode = fmri_runcode(param, outPath)
% runCode = frmi_runcode(param, outPath)
%
% This function generates the run code based on how many similar output
% files are in the Matlab Data/ folder.
%
% Inputs:
%     param         <struct> the experiment parameters. [only use .SubjCode,
%                    .expCode, .expAbbv]
%     outPath       <str> the path to save the output files.
%
% Output:
%     runCode       <int> the run code.
% 
% Created by Haiyang Jin (27-Feb-2020)

if ~exist('outPath', 'var') || isempty(outPath)
    outPath = pwd;
end

if isfield(param, 'outpath')
    outPath = param.outpath;
end

% outputfilename
outputFn = sprintf('%s_%s_%s_Run*', param.subjCode, param.expCode, param.expAbbv);

% dir the similar output files
matDir = dir(fullfile(outPath, 'MatBackup', outputFn));

% number of output files with similar names
nFiles = size(matDir, 1);

% the run code
runCode = nFiles + 1;

end