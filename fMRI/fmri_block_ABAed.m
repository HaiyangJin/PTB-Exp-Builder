function param = fmri_block_ABAed(param)
% param = fmri_block_ABAed(param)
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

% remove some trials (usually at the beginning or the end)
if isfield(param, 'ed_remove') && ~isempty(param.ed_remove)
    ed(param.ed_remove) = [];
end

param.ed = ed;
% this is an estimation and may not be accurate
param.bn = param.bn * length(ed) / param.tn; % old_bn * new_tn / old_tn
param.tn = length(ed);

end