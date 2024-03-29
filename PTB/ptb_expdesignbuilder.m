function [design, nTrial, nBlock] = ptb_expdesignbuilder(expConditions, randBlock, sortBlock, isRand)
% design = ptb_expdesignbuilder(expConditions, randBlock, sortBlock, isRand)
%
% This function creates a full-factorial design based on expConditions. The
% design is fully randomized at first. Then, it will be sorted by 
% randBlock and the orders of "randBlock" will be randomized as chunks.
% Finally, the design will be (ascending) sorted by sortBlock (without 
% randomization). 
%
% Inputs:
%     expConditions      <cell> expConditions is Nx2 cell, where N is the 
%                         number of levels with condition names in the 
%                         first column and possible values for each 
%                         condition in the second column.
%     randBlock          <cell str> the name of the variables. 
%                     OR <num vec> the order/number of the variables. 
%                         After fully randomized (if needed), the design 
%                         will then be sorted by randBlcok and be 
%                         randomized as chunks based on randBlock. 
%     sortBlock          <cell str> the name of the variables. 
%                     OR <num> the order/number of the variables. 
%                         The design will only be sorted (no randomization) 
%                         based on sortBlock. The order for sorting
%                         each condition is the same as their order in
%                         sortBlock.
%     isRand             <boo> if randomize the design. By default
%                         isRand is 1 and the design will be randomized.
%
% Output:
%     design             <struct> a structure of the design. The
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
% or
%
% randBlock = {'IV3', 'IV2'};
% sortBlock = {'blockNumber', 'StimCategory'};
% ed = ptb_expdesignbuilder(expConditions, randBlock, sortBlock);
%
%%%%%%%%%%%%%%%%%%%% Comments from Matt Oxner %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Does a full-factorial design, similar to StatsToolbox function "fullfact",
% using the experiment conditions given in the cell array expConditions.
% expConditions is Nx2, where N is the number of levels with condition
% names in the first column and possible values for each condition in the
% second column.
%
% Function returns a struct array with number of structs corresponding to
% number of trials. Each trial is a unique combination of possible
% condition values.
%
% These unique trials appearing the output struct are in a random order by 
% default.
% Trials can be balanced by blocks, or another condition, but adding a
% "sortBlock" string argument, which should correspond to a single
% condition name in expConditions.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% This code is built based on Matt Oxner's code.
% Created by Haiyang Jin (25-Feb-2020)

%% check the in arguments
% condition names and number of levels
condNames = expConditions(:,1);
levelsPerCond = cellfun(@length,expConditions(:,2));

% check formatting of expConditions
if ~iscell(expConditions) || size(expConditions,2)~=2 || ~iscellstr(condNames) %#ok<ISCLSTR>
    error('expConditions was wrong type, wrong size, or malformed.');
end

% is randBlock given
if nargin < 2 || isempty(randBlock)
    randBlockNum = [];
    nRandBlock = 1;
else
    randBlockNum = processBlock(randBlock, condNames, 'randBlock');
    nRandBlock = prod(levelsPerCond(randBlockNum));
end

% is sortBlock given
if nargin < 3 || isempty(sortBlock)
    sortBlockNum = [];
    nSortBlock = 1;
else 
    sortBlockNum = processBlock(sortBlock, condNames, 'sortBlock');
    nSortBlock = prod(levelsPerCond(sortBlockNum(:)));
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
% below code stolen from "fullfact" function in Statistics Toolbox (Matt).
ssize = prod(levelsPerCond);
ncycles = ssize;
cols = length(levelsPerCond);

designFF = zeros(ssize,cols,class(levelsPerCond));

for k = 1:cols
    settings = (1:levelsPerCond(k));                % settings for kth factor
    nreps = ssize./ncycles;                  % repeats of consecutive values
    ncycles = ncycles./levelsPerCond(k);            % repeats of sequence
    settings = settings(ones(1,nreps),:);    % repeat each value nreps times
    settings = settings(:);                  % fold into a column
    settings = settings(:,ones(1,ncycles));  % repeat sequence to fill the array
    designFF(:,k) = settings(:);
end

%% Randomize the design if needed

if isRand
    
    % randomize the whole design
    designFF = designFF(randperm(size(designFF,1)),:);
    
    nRandColu = numel(randBlockNum);  % number of columns for randBlockNum
    for iRand = nRandColu:-1:1 % reverse loop
        
        % already randomized randBlock condition
        if iRand == nRandColu
            doneRand = [];
        else
            doneRand = randBlockNum(iRand+1 : nRandColu);
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

    if nRandColu == 0
        % sort by sortBlock (sort by the order in sortBlock).
        designFF = sortrows(designFF, sortBlockNum);
    end
end

%% Replace double numbers in designFF with "real" level values
% temporary row and column indices
[rowTemp, colTemp] = ndgrid(1:size(designFF, 1), 1:size(designFF, 2));

% convert to the "real" level values
cellDesign = arrayfun(@(x, y) expConditions{y,2}(designFF(x,y)), ...
    rowTemp, colTemp, 'uni', false);

% convert cell to structure
design = cell2struct(cellDesign , expConditions(:,1), 2);

%% number of trials and blocks
% number of trials
nTrial = size(design, 1);
% number of blocks
nBlock = prod([nRandBlock, nSortBlock]);

end

function condNum = processBlock(block, conditionNames, varName)
% Convert randBlock and sortBlock into condition numbers accordinly.

% number of conditions
nCondition = numel(conditionNames);

if isnumeric(block) % if it is numeric
    % make sure the block number  do not exceed the condition number
    if any(block > nCondition)
        error([varName 'sortBlock (%d) exceeds the conditon number.'], block(:));
    end
    
    condNum = block;
else
    % convert strings or cell of strings into numeric
    if ischar(block); block = {block}; end
    isNot = cellfun(@(x) ~any(strcmpi(conditionNames, x)), block);
    
    % make sure randBlock is in expConditions
    if any(isNot)
        error(['Couldn''t find a condition in ''expConditions'' to match '...
            varName '''%s''.\n'], block{isNot});
    end
    
    condNum = cellfun(@(x) find(strcmpi(conditionNames, x)), block);
    
end
    
end