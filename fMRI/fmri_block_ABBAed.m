function param = fmri_block_ABBAed(param)
% param = fmri_block_ABBAed(param)
%
% Remove some of the trials from the experimental design (ed) and update
% some information accordingly. 
%
% Input:
%     param            <struct> experiment structure
%
% Output:
%     param            <struct> experiment structure with updated .ed, .tn,
%                       .bn.
%
% Created by Haiyang Jin (2021-11-23)

ed = param.ed;

assert(max([ed.repeated]) == 2, 'There should be only two stimulus blocks.');

blo1Order = [ed(1:length(ed)/2).stimCategory];
% flip the order in the first block
blo2Order = num2cell(flip(blo1Order));

[ed(length(ed)/2 + 1:end).stimCategory] = deal(blo2Order{:});

param.ed = ed;

end