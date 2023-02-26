function [ApFrm, Objects] = prf_aps(dtTable, varargin)
% [ApFrm, Objects] = prf_aps(dtTable, varargin)
%
% Inputs:
%    dtTable         <table> the data table saved from exp_prf().
%                 OR <struct> a struct with the field .dtTable.
%                 OR <str> filename of the data file saved by exp_prf().
% 
% Varargin:
%    .stimshape      <str> the shape of the stimulus. Default to
%                     'rectangle', (or 'oval').
%    .framepersec    <int> number of frames per second, default to 1.
%    .condorder      <cell str> the order of the conditions saved in
%                     [Objects]. Default to the order starting with
%                     'fixation' and then in alphabet order.
%    .corrtime       <num> time to be applied to correct the precision
%                     issue. Default to 0.1 .
%    .apfn           <str> file name. 
%
% Outputs:
%    ApFrm           <boo mat> the aperture matrix.
%    Objects         <int vec> condition numbers.
%
% Created by Haiyang Jin (2023-Feb-26)

%% Deal with inputs
if isstruct(dtTable) && isfield(param, 'dtTable')
    dtTable = param.dtTable;
elseif exist(dtTable, 'file')
    tmp = load(dtTable);
    dtTable = tmp.dtTable;
end

defaultOpts = struct( ...
    'stimshape', 'rectangle', ...
    'framepersec', 1, ...
    'condorder', {''}, ...
    'corrtime', .1, ...
    'apfn', ['ap_prf_' datestr(now, 'yyyymmddHHMM')] ...
    );
opts = ptb_mergestruct(defaultOpts, varargin);

% condition orders
condOrder = opts.condorder;
if isempty(opts.condorder)
    % use the alphabet order by default
    conditions = unique(dtTable.StimCategory);
    isFix = strcmp(conditions, 'fixation');
    condOrder = vertcat(conditions(isFix), conditions(~isFix));

elseif ~strcmp(condOrder{1}, 'fixation')
    % self-define order
    condOrder(strcmp(condOrder, 'fixation')) = [];
    condOrder = horzcat('fixation', condOrder);
end

%% Make aperture
% sort dtTable based on stimulus onsets
dtTable = sortrows(dtTable, 'StimOnsetRela');
nRow = size(dtTable, 1);

% generate the key timepoints
onsets = dtTable.StimOnsetRela;
onsets(1) = 0;
secTotal = round(onsets(nRow) + dtTable.StimDuration(nRow));

% canvas for the aperture
apXY = unique(dtTable.apXY, 'rows'); % apXY
apXY(isnan(apXY))=[];

% number of frames in final ap
frames = 0: 1/opts.framepersec: secTotal;
therows = arrayfun(@(x) find((x + opts.corrtime) >= onsets, 1, 'last'), frames);

% make the aperture for each frame
apFrm = arrayfun(@(x) mkap(dtTable.StimPosiRela(x, :), ...
    dtTable.StimXY(x, :), apXY, opts.stimshape), therows, 'uni', false);

% condition names and numbers
objStr = dtTable.StimCategory(therows);
objInt = cellfun(@(x) find(strcmp(x, condOrder))-1, objStr);

% save the final output
ApFrm = cat(3, apFrm{:});
Objects = objInt;

%% Save the ap_*.mat file
[filepath, name, ext] = fileparts(opts.apfn);
if ~startsWith(name, 'ap_')
    name = ['ap_', name];
end
if ~strcmp(ext, '.mat')
    ext = '.mat';
end
apfn = fullfile(filepath, [name, ext]);

% save the file locally
save(apfn, 'ApFrm', 'Objects', '-v7.3');

end % function prf_aps()

%% function to make aperture
function ap = mkap(stimPosiRela, stimXY, apXY, shape)

% default to not showing stimuli
ap = zeros(apXY);

if isnan(stimPosiRela)
    return
end

% position of stimulus centers
stimPosiX = apXY(2)/2 + stimPosiRela(2);
stimPosiY = apXY(1)/2 - stimPosiRela(1);

% stimulus shape
switch shape

    case 'rectangle'
        ap(stimPosiY-stimXY(1)/2+1 : stimPosiY+stimXY(1)/2, ...
            stimPosiX-stimXY(2)/2+1 : stimPosiX+stimXY(2)/2) = 1;

    case 'oval'
        for x = 1:apXY(1)
            for y = 1:apXY(2)
                if ((y-stimPosiX)^2)/((stimXY(2)/2))^2 + ...
                        ((x-stimPosiY)^2)/((stimXY(1)/2))^2 <= 1
                    ap(x,y) = 1;
                end
            end
        end

%         [canvasXs, canvasYs] = ndgrid(1:apXY(1), 1:apXY(2));
%         ovalmask = arrayfun(@(x,y) ((y-stimPosiX)^2)/((stimXY(2)/2))^2 + ...
%             ((x-stimPosiY)^2)/((stimXY(1)/2))^2 <= 1, ...
%             canvasXs, canvasYs);
%         ap(ovalmask) = 1;       
end % switch shape

end % function mkap()