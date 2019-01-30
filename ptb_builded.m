function design = ptb_builded(expConditions, sortCondition)

%% create a factorial design for experiment and randomize, but order by sortCondition.

% Does a full-factorial design, similar to StatsToolbox function "fullfact",
% using the experiment conditions given in
% the cell array expConditions. expConditions is Nx2, where N is the number of levels
% with condition names in the first column and possible values for
% each condition in the second column, e.g.:

% % expConditions = {...
% %     'IV1', 1:2 ; ...
% %     'IV2', 1:2 ; ...
% %     'IV3', 2/60 ; ...
% %     'ControlVariable', [2,4,6]/60 ; ...
% %     'withinBlockReps', 1:2; ... % 
% %     'blockNumber', 1:4 ...
% %     };
% % blockByCondition = 'blockNumber';
% % ed = BuildExperimentDesign(conditionsArray,blockByCondition);

% Function returns a struct array with number of structs corresponding to
% number of trials. Each trial is a unique combination of possible 
% condition values.

% These unique trials appearing the output struct are in a random order.
% Trials can be balanced by blocks, or another condition, but adding a
% "sortCondition" string argument, which should correspond to a single
% condition name in expConditions.

clear expDesign levelsPerCondition;
levelsPerCondition = cellfun(@length,expConditions(:,2));

%% check formatting of expConditions
if ~iscell(expConditions) || size(expConditions,2)~=2 || ~iscellstr(expConditions(:,1))
    error('expConditions was wrong type, wrong size, or malformed.');
end


%% is sortCondition given?
if nargin == 1
    sortCondition = []; 
elseif ~any(strcmpi(expConditions(:,1),sortCondition))
    error(['Couldn''t find a condition in ''expConditions'' to match requested sortCondition, ''' sortCondition '''.']);
end


%% below code stolen from "fullfact" function in Statistics Toolbox.
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

clear ssize ncycles cols settings nreps

%% Raw full factorial is now 'designFF'. 
% randomize and sort by sortCondition.
designFF = sortrows( designFF(randperm(size(designFF,1)),:) ,...
    find(strcmpi(expConditions(:,1),sortCondition)) );

cellDesign = cell(size(designFF));
for iCol = 1:size(designFF,2)
    for iRow = 1:size(designFF,1)
        cellDesign{iRow,iCol} = expConditions{iCol,2}(designFF(iRow,iCol));
    end
end

design = cell2struct( cellDesign , expConditions(:,1), 2);

clear designFF cellDesign

end

