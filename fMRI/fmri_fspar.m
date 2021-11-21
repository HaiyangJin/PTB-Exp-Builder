function parTable = fmri_fspar(input, condOrder, boxcar, extraFn)
% parTable = fmri_fspar(input, condOrder, boxcar, extraFn)
%
% This function convert the 'input' [the dtTable] into a par file format.
%
% Inputs:
%     input            <str> or <table> could be *.mat file containing
%                       dtTable or an Excel file of dtTable. Or it also
%                       could be dtTable (table).
%     condOrder        <cell str> the order of the condition
%                       categories. [If 'fixation' is included, it has to
%                       be the first string.]
%     boxcar           <boo> 1: both stimuli and blank in the same
%                       trial are treated as stimuli (boxcar); 0: stimuli
%                       and blank in the same trial are estimated
%                       separately. [blank will be treated as fixations]
%     extraFn          <str> extra strings to be added at the end of
%                       the par filename; default is ''.
%
% Output:
%     parTable          <table> the paradigm file table
%
% Created by Haiyang Jin (28-Feb-2020)

if ~exist('input', 'var') || isempty(input)
    % open GUI to select file
    [thisFile, thisPath] = uigetfile({...
        '*.*', 'All files (*.*)'; ...
        '*.mat', 'Matlab files (*.mat)'; ...
        '*.csv', 'csv files (*.csv)'; ...
        '*.xls;*.xlsx', 'Excel files (*.xls;*.xlsx)'},...
        'Please select one output file...');
    
    input = fullfile(thisPath, thisFile);
end

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
        case {'.xlsx', '.csv', '.xls'}
            % load the excel file
            dtTable = readtable(input);
    end
end

% all the block name information
blockNames = dtTable{:, 'StimCategory'};

% the identifier to be applied
if ~exist('condOrder', 'var') || isempty(condOrder)
    % use the alphabet order by default
    conditions = unique(blockNames);
    isFix = strcmp(conditions, 'fixation');
    
    condOrder = vertcat(conditions(isFix), conditions(~isFix));
    
elseif ~strcmp(condOrder{1}, 'fixation')
    % self define order
    condOrder = horzcat('fixation', condOrder);
end

% both stimuli and blank in the same trial are treated as stimuli by default.
if ~exist('boxcar', 'var') || isempty(boxcar)
    boxcar = 1;
end

% the default strings to be added at the end of the par file name
if ~exist('extraFn', 'var') || isempty(extraFn)
    extraFn = '';
end
if ~isempty(extraFn) && ~startsWith(extraFn, '_')
    extraFn = ['_' extraFn];
end

% the column of block names
nRowDtTable = numel(blockNames);

% whether is the first trial in each block
if boxcar
    blockRows = [true arrayfun(@(x) ~strcmp(blockNames{x}, blockNames{x-1}), 2:nRowDtTable)];
else
    blockRows = true(1, nRowDtTable);
end

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
if boxcar
    Duration = transpose([arrayfun(@(x) StimOnsets(x) - StimOnsets(x-1), 2:nRowPar), ...
        dtTable{nRowDtTable, 'RunEndTime'} - dtTable{nRowDtTable, 'RunStartTime'} -  StimOnsets(nRowPar)]);
else
    Duration = dtTable.StimDuration;
end
% weights
Weight = ones(numel(CondNames), 1);

% combine data together
parTable = table(StimOnsets, Identifier, Duration, Weight, CondNames);

%% add dummy volumes if needed
% the onset of the first block
iniOnset = parTable{1, 'StimOnsets'};

% if the first simOnsets is not 0
if round(iniOnset) ~= 0
    parTable{1, 'Duration'} = parTable{1, 'Duration'} + iniOnset;
    parTable{1, 'StimOnsets'} = 0;
end

% fill the gaps between trials if needed
needFix = arrayfun(@(x) StimOnsets(x) + Duration(x) ~= StimOnsets(x+1), 1:nRowPar-1);

if any(needFix)
    tempOnsets = StimOnsets + Duration;
    tempDuration = arrayfun(@(x) StimOnsets(x+1) - Duration(x), 1:nRowPar-1);
    
    StimOnsets = tempOnsets(needFix);
    CondNames = repmat({'fixation'}, sum(needFix), 1);
    Identifier = zeros(sum(needFix), 1);
    Duration = transpose(tempDuration(needFix));
    Weight = ones(sum(needFix), 1);
    
    fixTable = table(StimOnsets, Identifier, Duration, Weight, CondNames);
    
    parTable = sortrows(vertcat(parTable, fixTable), 'StimOnsets');
end

%% Save parTable in the parfile/folder
% the folder to save the par file
parFolder = fullfile(pwd, 'parfile');
if ~exist(parFolder, 'dir')
    mkdir(parFolder);
end

subjCode = unique(dtTable.SubjCode);
if ~iscell(subjCode) && isint(subjCode); subjCode = {num2str(subjCode)};end
runCode = unique(dtTable.RunCode);
if ~iscell(runCode) && isint(runCode); runCode = {num2str(runCode)};end
expAbbv = unique(dtTable.ExpAbbv);
% the filename of the par file
parFn = sprintf('Subj%s_Run%s_%s%s.par', subjCode{1}, runCode{1}, expAbbv{1}, extraFn);

% create the par file
try
    % try to create par file with fs_createfile
    fs_createfile(fullfile(parFolder, parFn), table2cell(parTable));
    
catch
    % if failed, use writetable and rename the file
    tempText = fullfile(parFolder, [parFn '.txt']);
    writetable(parTable, tempText, 'Delimiter',' ', 'WriteVariableNames', false)
    % rename the file
    movefile(tempText, fullfile(parFolder, parFn));
    
end

end