function param = prf_nbackletter(param)
% param = prf_nbackletter(param)
% 
% Input:
%     param            <struct> experiment structure.
%     .nback           <int> number of repetitions in each block.
%     .ratio           <num> percentage of trials having .nback
%                       repetitions, and others having .nback-1
%                       repetitions.
%    
% Created by Haiyang Jin (2023-Feb-27)

% use stimuli
stimuli = param.stimuli;
nCol = size(stimuli,2);

% create default empty outpus
lettStim = repmat({''}, size(stimuli));
answers = NaN(size(stimuli));

% all letters
if isfield(param, 'letterstimuli')
    letters = 1:26;
    lettStim(size(lettStim,1), :) = {27};
else
    letters = 'A':'Z';
end

% number of letters to be shown in each block
nLetterPerTrial = param.nStimPerBlock-param.nFixaEndPerBlock; % PerBlock
% which block will show the .nback repetition
istask = sort(randperm(nCol, ceil(nCol * param.ratio)));

% block answers
param.blockAns = zeros(nCol, 1);
param.blockAns(istask) = 1;

for itn = 1:nCol % each column in stimuli

    % only some of the blocks show .nback repetitions
    if ismember(itn, istask)
        nback = param.nback;
    else
        nback = param.nback-1;
    end

    %% Generate the letters to be shown
    % generate unique letters
    Nunique = nLetterPerTrial-nback;
    whichletters = randperm(26, Nunique);
    uniletters = arrayfun(@(x) letters(x), whichletters, 'uni', false)';

    % generate the repeated letter
    whichrep = randperm(Nunique, nback);
    repletter = uniletters(whichrep);

    % save the letters
    theletters = repmat(repletter, nLetterPerTrial, 1);
    theletters(~ismember(1:nLetterPerTrial,whichrep)) = uniletters;

    lettStim(1:nLetterPerTrial, itn) = theletters;

    %% Save the answers
    thisans = [NaN; zeros(nLetterPerTrial-1, 1)];
    thisans(whichrep+1)=1;
    answers(1:nLetterPerTrial, itn) = thisans;

end %itn

%% Save the output
param.taskstim = lettStim;
param.answers = answers;

end