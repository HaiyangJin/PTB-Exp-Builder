function runCode = fmri_runcode(param, outputPath)
% runCode = frmi_runcode(param, outputPath)
%
% This function generates the run code based on how many similar output
% files are in the Matlab Data/ folder.
%
% Inputs:
%     param         <structure> the experiment parameters. [only use
%                   .SubjCode, .expCode, .expAbbv]
%     outputPath    <string> the path to save the output files.
%
% Output:
%     runCode       <numeric> the run code
% 
% Created by Haiyang Jin (27-Feb-2020)

if nargin < 2 || isempty(outputPath)
    outputPath = pwd;
end

% outputfilename
outputFn = sprintf('%s_%s_%s_Run*', param.subjCode, param.expCode, param.expAbbv);

% dir the similar output files
matDir = dir(fullfile(outputPath, 'Matlab Data', outputFn));

% number of output files with similar names
nFiles = size(matDir, 1);

% the run code
runCode = nFiles + 1;

end