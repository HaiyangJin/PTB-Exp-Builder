function P = ptb_randperm(n, k)
% This function returns a vector containing K "unique" integers selected
% randomly from 1:n. If k is larger than n, it returns the fewest
% repetitions in the vector P.
%
% Inputs:
%     n           <integer> 1:n will be range to generated the random
%                 integers.
%     k           <integer> the number of integers in P.
%
% Output:
%     P           <a vector of integers> the output random integers.
%
% Created by Haiyang Jin (26-Feb-2020)

if nargin < 2 || isempty(k)
    k = n;
end

% do the permutations
if k <= n
    % if k is not large than n, run randperm
    P = randperm(n, k);
else
    % if k is larger than n, calculate the mod and 
    nTimes = floor(k/n);
    extra = mod(k, n);
    
    % run permutations for nTimes
    pCell = arrayfun(@randperm, repmat(n, 1, nTimes), 'uni', false);
    pVect = horzcat(pCell{:});
    
    % run permutations for extra and combine P
    P = horzcat(pVect, randperm(n, extra));
    
end

end