function outTable = cf_output(dtTable, expInfoTable)
% This function processes the output for composite face task.
%
% Inputs:
%     dtTable           <table> the output table from do_trial
%     expInfoTable      <table> the experiment information table
%
% Output:
%     outTable          <table> the output table
%
% Created by Haiyang Jin (14-Feb-2020)

% process information
cue = {'top', 'bottom'};  % TB
alignment = {'ali', 'mis'};  % 'AM'; % aligned, misaligned
congruency = {'con', 'inc'};  % 'CI'; % congruent, incongruent
samediff = {'same', 'diff'}; % 'SD'; % same, different

dtTable.Cue = transpose(cue(2 - dtTable.Cue));
dtTable.Alignment = transpose(alignment(2 - dtTable.Alignment));
dtTable.Congruency = transpose(congruency(2 - dtTable.Congruency));
dtTable.SameDifferent = transpose(samediff(2 - dtTable.SameDifferent));

% combine the exp information table and data table
if size(dtTable,1) > 1
    outTable = horzcat(expInfoTable, dtTable);
else
    outTable = [];
end

end