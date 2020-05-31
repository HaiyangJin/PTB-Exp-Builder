function outCell = ndcol(varargin)
% outCell = ndcol(varargin)
%
% This function converts inputs into a cell, which are the combinations of
% all information in varargin.
%
% Example:
% ndcol({1, 2}, {3, 4}, {5, 6})
% Output is:
%     {[1]}    {[3]}    {[5]}
%     {[2]}    {[3]}    {[5]}
%     {[1]}    {[4]}    {[5]}
%     {[2]}    {[4]}    {[5]}
%     {[1]}    {[3]}    {[6]}
%     {[2]}    {[3]}    {[6]}
%     {[1]}    {[4]}    {[6]}
%     {[2]}    {[4]}    {[6]}
% 
% Created by Haiyang Jin (23-May-2020)

% convert string to cell
isOne = cellfun(@ischar, varargin);
varargin(isOne) = cellfun(@(x) {x}, varargin(isOne), 'uni', false);

% create all possible combinations 
pathComb = cell(size(varargin));
[pathComb{:}] = ndgrid(varargin{:});

% make strings in each cell to one column
outCell = cellfun(@(x) x(:), pathComb, 'uni', false);

outCell = horzcat(outCell{:});

end