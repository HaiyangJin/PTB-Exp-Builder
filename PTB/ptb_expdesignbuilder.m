function design = ptb_expdesignbuilder(expConditions, randBlock, sortBlock, isRand)
% design = ptb_expdesignbuilder(expConditions, randBlock, sortBlock, isRand)
%
% This function creates a full-factorial design based on expConditions. The
% design is fully randomized at first. Then, it will be sorted by 
% randBlock and the orders of "randBlock" will be randomized as chunks.
% Finally, the design will be (ascending) sorted by sortBlock (without 
% randomization). 
%
% Inputs:
%     expConditions      <cell> each row is one variable. The first
%                        column is the names of the variables and the
%                        second column is the levels of the variables.
%     randBlock          <cell of strings> the name of the variables. or
%                        <numeric> the order/number of the variables. The
%                        design will be sorted and then be randomized as
%                        chunks.
%     sortBlock          <cell of strings> the name of the variables. or
%                        <numeric> the order/number of the variables. The
%                        design will only be sorted (no randomization).
%     isRand             <logical> if randomize the design. By default
%                        isRand is 1 and the design will be randomized.
%
% Output:
%     design             <strucutre> a structure of the design. The
%                        fieldnames will be the variable names. Each row is
%                        one trial.
%
% Usage:
% expConditions = {...
%     'IV1', 1:3 ; ...
%     'IV2', 1:4 ; ...
%     'IV3', 1:5 ; ...
% %     'ControlVariable', [2,4,6]/60 ; ...
%     'StimCategory', 1:4;...
%     'blockNumber', 1:2 ...
%     };
% randBlock = {'StimCategory', 'IV3'};
% sortBlock = 'blockNumber';
% ed = ptb_expdesignbuilder(expConditions, randBlock, sortBlock);
%
% This code is built based on Matt Oxner's code.
%
% Created by Haiyang Jin (25-Feb-2020)


%% Comments from Matt Oxner
% Does a full-factorial design, similar to StatsToolbox function "fullfact",
% using the experiment conditions given in
% the cell array expConditions. expConditions is Nx2, where N is the number of levels
% with condition names in the first column and possible values for
% each condition in the second column.
%
% Function returns a struct array with number of structs corresponding to
% number of trials. Each trial is a unique combination of possible
% condition values.
%
% These unique trials appearing the output struct are in a random order.
% Trials can be balanced by blocks, or another condition, but adding a
% "sortCondition" string argument, which should correspond to a single
% condition name in expConditions.

%% condition names and number
condNames = expConditions(:,1);
nCon = numel(condNames);

%% check formatting of expConditions
if ~iscell(expConditions) || size(expConditions,2)~=2 || ~iscellstr(condNames) %#ok<ISCLSTR>
    error('expConditions was wrong type, wrong size, or malformed.');
end

% is randBlock given
if nargin < 2 || isempty(randBlock)
    randBlockNum = [];
elseif isnumeric(randBlock) % if it is numeric
    
    if any(randBlock > nCon)
        error('sortBlock (%d) exceeds the conditon number.', randBlock(:));
    end
    
else
    
    if ischar(randBlock); randBlock = {randBlock}; end
    isRandNot = cellfun(@(x) ~any(strcmpi(condNames, x)), randBlock);
    
    % make sure randBlock is in expConditions
    if any(isRandNot)
        error(['Couldn''t find a condition in ''expConditions'' to match '...
            'requested sortCond ''%s''.\n'], randBlock{isRandNot});
    end
    
    randBlockNum = cellfun(@(x) find(strcmpi(condNames, x)), randBlock);
end

% is sortBlock given
if nargin < 3 || isempty(sortBlock)
    randBlockNum = [];
    
elseif isnumeric(sortBlock) % if it is numeric
    
    if any(sortBlock > nCon)
        error('sortBlock (%d) exceeds the conditon number.', sortBlock(:));
    end
    
else
    if ischar(sortBlock); sortBlock = {sortBlock}; end
    isSortNot = cellfun(@(x) ~any(strcmpi(condNames, x)), sortBlock);
    
    % make sure sortBlock is in expConditions
    if any(isSortNot)
        error(['Couldn''t find a condition in ''expConditions'' to match '...
            'requested sortCond ''%s''.\n'], sortBlock{isSortNot});
    end
    
    sortBlockNum = cellfun(@(x) find(strcmpi(condNames, x)), sortBlock);
end

% make sure there is no overlapping between randBlock and sortBlock
isOverlap = any(ismember(randBlockNum, sortBlockNum));

if any(isOverlap)
    error(['Please make sure there is no overlapping between randBlock '...
        'and sortBlock.']);
end

% randomize the design by default
if nargin < 4 || isempty(isRand)
    isRand = 1;
end

%% Create the full factorial design (without randomization)
% below code stolen from "fullfact" function in Statistics Toolbox.
levelsPerCondition = cellfun(@length,expConditions(:,2));

ssize = prod(levelsPerCondition);
ncycles = ssize;
cols = length(levelsPerCondition);

designFF = zeros(ssize,cols,class(levelsPerCondition));

for k = 1:cols
    settings = (1:levelsPerCondition(k));                % settings for kth factor
    nreps = ssize./ncycles;                  % repeats of consecutive values
    ncycles = ncycles./levelsPerCondition(k);            % repeats of sequence
    settings = settings(ones(1,nreps),:);    % repeat each value nreps times
    settings = settings(:);                  % fold into a column
    settings = settings(:,ones(1,ncycles));  % repeat sequence to fill the array
    designFF(:,k) = settings(:);
end


%% Randomize the design if needed

if isRand
    
    % randomize the whole design
    designFF = designFF(randperm(size(designFF,1)),:);
    
    % sort by sortBlock (sort by the order in sortBlock).
%     designFF = sortrows(designFF, [sortBlockNum, randBlockNum]);
    
    for iRand = 1:numel(randBlockNum)
        
        % already randomized randBlock condition
        if iRand == 1
            doneRand = [];
        else
            doneRand = randBlockNum(1:iRand-1);
        end
        
        % this randBlock number
        thisRand = randBlockNum(iRand);
        % the randBlock number to be randomized later
        toBeRand = randBlockNum(~ismember(randBlockNum, [thisRand, doneRand]));
        
        % get all the columns for identifying groups (without randomized
        % randBlock numbers)
        columns = arrayfun(@(x) designFF(:, x), [thisRand, toBeRand, sortBlockNum], 'uni', false);
        
        % identify the groups (the group number is in order)
        thisGroup = findgroups(columns{:});
        
        % randomize the order of groups
        temporder = transpose(randperm(numel(unique(thisGroup))));
        newGroupOrder = temporder(thisGroup);
        
        % add the new group order to the design matrix
        designPlus = horzcat(designFF, newGroupOrder);
        % sort by the newGroupOrder
        designPlus = sortrows(designPlus, size(designPlus, 2));
        % remove the (new) order column
        designFF = designPlus(:, 1:end-1);
        
        % sort the design by sortBlockNum and to be randomized randBlock
        designFF = sortrows(designFF, [sortBlockNum, toBeRand]);

    end
end


%% Replace double numbers in designFF with "real" values

cellDesign = cell(size(designFF));
for iCol = 1:size(designFF,2)
    for iRow = 1:size(designFF,1)
        cellDesign{iRow,iCol} = expConditions{iCol,2}(designFF(iRow,iCol));
    end
end

% convert cell to structure
design = cell2struct( cellDesign , expConditions(:,1), 2);

end