function outTable = ptb_outtable(dtTable, expInfoTable)
% outTable = ptb_outtable(dtTable, expInfoTable)
%
% This function processes the output for the example task.
%
% Inputs:
%     dtTable           <table> the output table from do_trial
%     expInfoTable      <table> the experiment information table
%
% Output:
%     outTable          <table> table for the output
%
% Created by Haiyang Jin (14-Feb-2020)

% combine the exp information table and data table
if size(dtTable,1) > 1
    outTable = horzcat(expInfoTable, dtTable);
else
    outTable = [];
end

end