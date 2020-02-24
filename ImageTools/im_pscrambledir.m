function stimDir = im_pscrambledir(stimDir, matrixFieldname)
% stimDir = im_pscrambledir(stimDir, matrixFieldname)
%
% This function generates the phase scrambled for the stimulus direcgtory.
%
% Inputs:
%     stimDir                 <structure> stimulus structure [generated by
%                             im_readdir].
%     matrixFieldname         <fieldname> the fieldname for the image
%                             matrix.
%
% Output:
%     stimDir                 <structure> stimulus structure [a new
%     fieldname called .psmatrix is added.
%
% Created by Haiyang Jin (20-Feb-2020)

% obtain the cell of stimulus matrix
if nargin < 2 || isempty(matrixFieldname)
    matrixCell = {stimDir.matrix};
else
    matrixCell = {stimDir.(matrixFieldname)};
end

% generated the phase scrambled matrix
scrambledCell = cellfun(@im_phasescramble, matrixCell, 'uni', false);

% save the phase-scrambled matrix as a new fiedlname
[stimDir.psmatrix] = deal(scrambledCell{:});

end