function runCode = fmri_runcode(param, duration, outPath)
% runCode = frmi_runcode(param, fnExtra, outPath)
%
% This function generates the run code based on how many similar output
% files are in the Matlab Data/ folder.
%
% Inputs:
%     param         <struct> the experiment parameters. [only use .SubjCode,
%                    .expCode, .expAbbv]
%     duration      <str> expected duration in seconds.
%     outPath       <str> the path to save the output files.
%
% Output:
%     runCode       <int> the run code.
% 
% Created by Haiyang Jin (27-Feb-2020)

if isnumeric(duration)
    duration = num2str(duration);
end

if ~exist('outPath', 'var') || isempty(outPath)
    outPath = '';
    if isfield(param, 'outpath'); outPath = param.outpath; end
end

% outputfilename
outFn = sprintf('sub-%s_task-%s_run-*_duration-%s', param.subjCode, param.expAbbv, duration);
if ~endsWith(outFn, '*'); outFn = [outFn, '*']; end

% dir the similar output files
matDir = dir(fullfile(outPath, 'MatBackup', outFn));

% number of output files with similar names
nFiles = size(matDir, 1);

% the run code
runCode = nFiles + 1;

end