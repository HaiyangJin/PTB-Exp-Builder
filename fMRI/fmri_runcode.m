function runCode = fmri_runcode(param, extrawc, outPath)
% runCode = frmi_runcode(param, extrawc, outPath)
%
% This function generates the run code based on how many similar output
% files are in the Matlab Data/ folder.
%
% Inputs:
%     param         <struct> the experiment parameters. [only use .SubjCode,
%                    .expCode, .expAbbv]
%     extrawc       <str> additional wildcard to identify run information.
%     outPath       <str> the path to save the output files.
%
% Output:
%     runCode       <int> the run code.
% 
% Created by Haiyang Jin (27-Feb-2020)

if ~exist('extrawc', 'var') || isempty(extrawc)
    extrawc = '';
end

if ~exist('outPath', 'var') || isempty(outPath)
    outPath = '';
    if isfield(param, 'outpath'); outPath = param.outpath; end
end

% outputfilename
outputFn = sprintf('%s_%s_%s_Run*%s', param.subjCode, param.expCode, param.expAbbv, extrawc);

% dir the similar output files
matDir = dir(fullfile(outPath, 'MatBackup', outputFn));

% number of output files with similar names
nFiles = size(matDir, 1);

% the run code
runCode = nFiles + 1;

end