function struct1 = ptb_updatestruct(struct1, struct2)
% struct1 = ptb_updatestruct(struct1, struct2)
%
% This function updates/adds the fieldnames of struct2 to struct1. 
%
% Inputs:
%    struct1      <structure> whose fieldnames will be updated. It usually 
%                  should be 'param'. 
%    struct2      <structure> whose fieldnames will be saved/added to
%                  struct1.
%
% Output:
%    struct1      <structure> output structure.
%
% Created by Haiyang Jin (11-Aug-2020)

for fn = fieldnames(struct2)'
    struct1.(fn{1}) = struct2.(fn{1});
end

end