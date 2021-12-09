function [outTable, eventTable] = fmri_parevent(input, varargin)
% [outTable, eventTable] = fmri_parevent(input, varargin)
%
% Converts the 'input' [i.e., dtTable] into a par file in FreeSurfer or/and
% Event tsv file in BIDS.
%
% Inputs:
%     input            <str> or <table> could be *.mat file containing
%                       dtTable or an Excel file of dtTable. Or it also
%                       could be dtTable (table).
%
% Varargin:
%     condorder        <cell str> the order of the condition
%                       categories. [If 'fixation' is included, it has to
%                       be the first string.] <this is mainly useful for
%                       par files in FreeSurfer.
%     boxcar           <boo> 1: both stimuli and blank in the same
%                       trial are treated as stimuli (boxcar); 0: stimuli
%                       and blank in the same trial are estimated
%                       separately. [blank will be treated as fixations]
%     extrafn          <str> extra strings to be added at the end of
%                       the par filename; default is ''.
%     type             <int> 1, 2, 3 (default). 1: only output the par
%                       files used in FreeSurfer. 2: only output the event
%                       tsv files used in BIDS. 3: will output both types
%                       of files.
%     outpath          <str> where to save the output file; default is pwd.
%
% Output:
%     outTable         <table> the paradigm file table.
%     eventTable       <table> the Event tsv table in BIDS.
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
elseif isfield(input, 'dtTable')
    % if input is struct
    dtTable = input.dtTable;
    outTable = table;
    eventTable = table;
    if input.isDebug || isempty(dtTable); return; end
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

% default settings
defaultOpts = struct(...
    'condorder', [], ...
    'boxcar', 1, ...
    'extrafn', [], ...
    'type', 3, ...
    'outpath', pwd ...
    );

opts = ptb_mergestruct(defaultOpts, varargin);

condOrder =opts.condorder;
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

% the default strings to be added at the end of the par file name
extraFn = opts.extrafn;
if ~isempty(extraFn) && ~startsWith(extraFn, '_extra-')
    extraFn = ['_extra-' extraFn];
end

types = {{'fs'}; {'bids'}; {'fs', 'bids'}};
type = types{opts.type};

% the column of block names
nRowDtTable = numel(blockNames);

% whether is the first trial in each block
if opts.boxcar
    blockRows = [true arrayfun(@(x) ~strcmp(blockNames{x}, blockNames{x-1}), 2:nRowDtTable)];
else
    blockRows = true(1, nRowDtTable);
end

%% Different columns for the par file
% number of rows in par(adigm) file
nRowPar = sum(blockRows);

% stimlus/block onsets
onset = dtTable{blockRows, 'StimOnsetRela'};
onset(1) = 0; % force the first onset to be 0
% stimulus category names
trial_type = blockNames(blockRows);
% stimulus identifier
Identifier = cellfun(@(x) find(strcmp(x, condOrder))-1, trial_type);
% stimulus durations
if opts.boxcar
    duration = transpose([arrayfun(@(x) onset(x) - onset(x-1), 2:nRowPar), ...
        dtTable{nRowDtTable, 'RunEndTime'} - dtTable{nRowDtTable, 'RunStartTime'} -  onset(nRowPar)]);
else
    duration = dtTable.StimDuration;
end
% weights
Weight = ones(numel(trial_type), 1);

% combine data together
outTable = table(onset, Identifier, duration, Weight, trial_type);

%% add dummy volumes if needed

% fill the gaps between trials if needed
needFix = arrayfun(@(x) onset(x) + duration(x) ~= onset(x+1), 1:nRowPar-1);

if any(needFix)
    tempOnsets = onset + duration;
    tempDuration = arrayfun(@(x) onset(x+1) - duration(x), 1:nRowPar-1);

    onset = tempOnsets(needFix);
    trial_type = repmat({'fixation'}, sum(needFix), 1);
    Identifier = zeros(sum(needFix), 1);
    duration = transpose(tempDuration(needFix));
    Weight = ones(sum(needFix), 1);

    fixTable = table(onset, Identifier, duration, Weight, trial_type);

    outTable = sortrows(vertcat(outTable, fixTable), 'onset');
end

%% Save output files
% some general information
subjCode = unique(dtTable.SubjCode);
if ~iscell(subjCode) && isint(subjCode); subjCode = {num2str(subjCode)};end
runCode = unique(dtTable.RunCode);
if ~iscell(runCode) && isint(runCode); runCode = {num2str(runCode)};end
expAbbv = unique(dtTable.ExpAbbv);
outFn = sprintf('sub-%s_task-%s_run-%s%s', ...
    subjCode{1}, expAbbv{1}, runCode{1}, extraFn);

% Save par files used in FreeSurfer
if ismember('fs', type)
    % the folder to save the par file
    parFolder = fullfile(opts.outpath, 'parfile');
    ptb_mkdir(parFolder);
    % the filename of the par file
    parFn = sprintf('%s.par', outFn);

    % create the par file
    try
        % try to create par file with fs_createfile
        fm_mkfile(fullfile(parFolder, parFn), table2cell(outTable));

    catch
        % if failed, use writetable and rename the file
        tempText = fullfile(parFolder, [parFn '.txt']);
        writetable(outTable, tempText, 'Delimiter',' ', 'WriteVariableNames', false);
        % rename the file
        movefile(tempText, fullfile(parFolder, parFn));
    end
end

% Save Event tsv file used in BIDS
if ismember('bids', type)
    % create Event table
    eventTable = outTable(:, {'onset', 'duration', 'trial_type'});

    % the folder to save the event tsv file
    bidsFolder = fullfile(opts.outpath, 'eventfile');
    ptb_mkdir(bidsFolder);

    % save Event table as tsv
    tempText = fullfile(bidsFolder, [parFn '.txt']);
    writetable(eventTable, tempText, 'Delimiter', '\t');
    % rename the file
    movefile(tempText, fullfile(bidsFolder, [outFn '_events.tsv']));
end

end