function latmat = latsq(n, isrand)
% latmat = latsq(n, isrand)
%
% Creates a latin squre design. 
%
% Inputs:
%    n              <int> number of condition.
%    isrand         <boo> whether to randomize the rows of the latin square
%                    matrix. Default is 1.
%
% Output:
%    latmat         <mat> a latin square design matrix.
%
% % Example 1: latin square matrix with randomizing rows.
% latsq(4);
%
% Example 2: latin square matrix without randomizing rows. 
% latsq(4, 0);
% 
% Created by Haiyang Jin (2021-12-12)

if ~exist('isrand', 'var') || isempty(isrand)
    isrand = 1;
end

% make the original matrix
mat = repmat(1:n, n, 1);

% create a binary mask for putting indices at the end
isendcell = arrayfun(@(x) mat(x, :) < x, 1:n, 'uni', false);
isend = vertcat(isendcell{:});

% move those indices to the end for each row
latmatcell = arrayfun(@(x) [mat(x, ~isend(x, :)), mat(x, isend(x, :))], 1:n, 'uni', false);
latmat = vertcat(latmatcell{:});

if isrand
    randrow = randperm(n);
    latmat = latmat(randrow, :);
end

end