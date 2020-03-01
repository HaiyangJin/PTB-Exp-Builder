function parTable = fmri_fspar(input, condOrder, extraFn)
% parTable = fmri_fspar(input, condOrder, extraFn)
%
% This function convert the 'input' [the dtTable] into a par file format.
%
% Inputs:
%     input             <string> or <table> could be *.mat file containing
%                       dtTable or an Excel file of dtTable. Or it also
%                       could be dtTable (table).
%     condOrder         <cell of string> the order of the condition
%                       categories. [If 'fixation' is included, it has to 
%                       be the first string.] 
%     extraFn           <string> extra strings to be added at the end of
%                       the par filename. 
%
% Output:
%     parTable          <table> the paradigm file table

% process the 'input' and load dtTable
if istable(input)
    dtTable = input;
else
    % get the extension of the file
    [~, ~, ext] = fileparts(input);
    
    % different process for different file types
    switch ext
        case '.mat'
            % load the .mat file
            temp = load(input, 'dtTable');
            dtTable = temp.dtTable;
            clear temp
        case '.xlsx'
            % load the excel file
            dtTable = readtable(input);
    end
end

% all the block name information
blockNames = dtTable{:, 'StimCategory'};

% the identifier to be applied
if nargin < 2 || isempty(condOrder)
    % use the alphabet order by default
    conditions = unique(blockNames);
    isFix = strcmp(conditions, 'fixation');
    
    condOrder = vertcat(conditions(isFix), conditions(~isFix));
    
elseif ~strcmp(condOrder{1}, 'fixation')
    % self define order
    condOrder = horzcat('fixation', condOrder);
end

% the default strings to be added at the end of the par file name
if nargin < 3 || isempty(extraFn)
    extraFn = unique(dtTable.ExpAbbv);
    extraFn = extraFn{1};
end

% the column of block names
nRowDtTable = numel(blockNames);

% whether is the first trial in each block
blockRows = [true arrayfun(@(x) ~strcmp(blockNames{x}, blockNames{x-1}), 2:nRowDtTable)];

%% Different columns for the par file
% number of rows in par(adigm) file
nRowPar = sum(blockRows);

% stimlus/block onsets
StimOnsets = dtTable{blockRows, 'StimOnsetRela'};
% stimulus category names
CondNames = blockNames(blockRows);
% stimulus identifier
Identifier = cellfun(@(x) find(strcmp(x, condOrder))-1, CondNames);
% stimulus durations
Duration = transpose([arrayfun(@(x) StimOnsets(x) - StimOnsets(x-1), 2:nRowPar), ...
    dtTable{nRowDtTable, 'RunEndTime'} - dtTable{nRowDtTable, 'RunStartTime'} -  StimOnsets(nRowPar)]);
% weights
Weight = ones(numel(CondNames), 1);

% combine data together
parTable = table(StimOnsets, Identifier, Duration, Weight, CondNames);

%% Save parTable in the parfile/folder
% the folder to save the par file
parFolder = fullfile(pwd, 'parfile');
if ~exist(parFolder, 'dir')
    mkdir(parFolder);
end

subjCode = unique(dtTable.SubjCode);
runCode = unique(dtTable.RunCode);
% the filename of the par file
parFn = sprintf('Subj%s_Run%s_%s.par', subjCode{1}, runCode{1}, extraFn);

% create the par file
fs_createfile(fullfile(parFolder, parFn), table2cell(parTable));

end