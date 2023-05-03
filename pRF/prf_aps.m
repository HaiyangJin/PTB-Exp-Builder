function [ApFrm, Objects] = prf_aps(dtTable, varargin)
% [ApFrm, Objects] = prf_aps(dtTable, varargin)
%
% Make aperture file. 
%
% Inputs:
%    dtTable         <table> the data table saved from exp_prf().
%                 OR <struct> a struct with the field .dtTable.
%                 OR <str> filename of the data file saved by exp_prf().
% 
% Varargin:
%    .unit           <str> the unit for the output {ApFrm}. Default to
%                     'va' (i.e., visual angle) [if the relevant
%                     information {.distance, .cmperpi} is avaiable].
%                     Alternatively, default to 'pi' (i.e., pixels).
%    .stimshape      <str> the shape of the stimulus. Default to
%                     'rectangle', (or 'oval').
%    .framepersec    <int> number of frames per second, default to 1.
%                     {.framepersec} will be saved for each second in the
%                     actual experiment. For instance, when {.framepersec}
%                     is 2, every 0.5 second in the actual experiment was
%                     saved as one frame/one layer along the third
%                     dimension in {ApFrm}. It is different from 
%                     {Framerate} in samsrf_apmovie(), where {Framerate}
%                     refers to the number of frames/layers along the third
%                     dimension to be displayed in one second in the video
%                     generated.                     
%    .condorder      <cell str> the order of the conditions saved in
%                     [Objects]. Default to the order starting with
%                     'fixation' and then in alphabet order.
%    .distance       <num> distance from the participant to the screen in
%                     centimeter. Default to 0.
%    .cmperpi        <num> size (in centimeter) per pixel. Default to 0.
%    .corrtime       <num> time to be applied to correct the precision
%                     issue. Default to 0.1.
%    .apfn           <str> the file name of the output aperture. 
%
% Outputs:
%    ApFrm           <boo mat> the aperture matrix, which can be visualized
%                     via samsrf_apmovie() or ViewAperture() in SamSrf toolbox. 
%    Objects         <int vec> condition numbers.
%
% Created by Haiyang Jin (2023-Feb-26)
%
% See also:
% samsrf_apmovie(); ViewApertures();

%% Deal with inputs
defaultOpts = struct( ...
    'unit', 'pi', ...
    'stimshape', 'rectangle', ...
    'framepersec', 1, ...
    'condorder', {''}, ...
    'distance', 0, ...
    'cmperpi', 0, ...
    'corrtime', .1, ...
    'apfn', ['ap_' char(datetime('now', 'Format', 'yyyyMMddHHmm'))] ...
    );

if isstruct(dtTable) && isfield(param, 'dtTable')
    dtTable = param.dtTable;
elseif exist(dtTable, 'file')
    % use the input file name as the {.apfnextra}
    [~,inputfn] = fileparts(dtTable);
    defaultOpts.apfn = ['ap_' inputfn];
    % load and retrieve the dtTable
    tmp = load(dtTable);
    dtTable = tmp.dtTable;

    if isfield(tmp, 'distance') && ~isempty(tmp.distance)
        defaultOpts.distance = tmp.distance;
    end
    if isfield(tmp, 'cmperpi') && ~isempty(tmp.cmperpi)
        defaultOpts.cmperpi = tmp.cmperpi;
    end
end

% Update the .va default if needed
if (~isempty(defaultOpts.distance) && defaultOpts.cmperpi>0) && ...
    (~isempty(defaultOpts.cmperpi) && defaultOpts.cmperpi>0)
    defaultOpts.unit = 'va';
end

% integrate default and custom options
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

% calculate the visual angle based on pixel
if (~isempty(opts.distance) && opts.cmperpi>0) && ...
    (~isempty(opts.cmperpi) && opts.cmperpi>0) && strcmp(opts.unit,'va')

    fprintf('\nSave the aperture in the unit of visual angle...\n');

    % aperture X and Y in visual angle
    apXY = round(ptb_visualangle(apXY*opts.cmperpi, opts.distance) * 100)+20;
    % convert to visual angle
    dtTable.StimPosiRela = round(ptb_visualangle(dtTable.StimPosiRela*opts.cmperpi, opts.distance) * 100);
    dtTable.StimXY = round(ptb_visualangle(dtTable.StimXY*opts.cmperpi, opts.distance) * 100);
    
end

% number of frames in final aperture
frames = 0: 1/opts.framepersec: secTotal;
therows = arrayfun(@(x) find((x + opts.corrtime) >= onsets, 1, 'last'), frames(1:end-1));

% condition names and numbers
objStr = dtTable.StimCategory(therows);
objInt = cellfun(@(x) find(strcmp(x, condOrder))-1, objStr);

% make the aperture for each frame
apFrm = arrayfun(@(x) mkap(dtTable.StimCategory(x, :), dtTable.StimPosiRela(x, :), ...
    dtTable.StimXY(x, :), apXY, opts.stimshape), therows, 'uni', false);

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
% make sure not overwrite files
apfn0 = 0;
while exist(apfn, 'file')
    apfn0 = apfn0 + 1;
    apfn = fullfile(filepath, [name '_' num2str(apfn0), ext]);
end

% save the file locally
save(apfn, 'ApFrm', 'Objects', '-v7.3');

end % function prf_aps()

%% function to make aperture
function ap = mkap(stimCond, stimPosiRela, stimXY, apXY, shape)
% stimPosiRela  <num vec> stimulus position relative to the center of the
%                screen.
% stimXY        <num vec> height and width of the stimulus.
% apXY          <num vec> hieght and width of the aperature.
% shape         <str> shape of the stimulus. 'rectangle' or 'oval'.

% default to not showing stimuli
ap = zeros(apXY);

if any(isnan(stimPosiRela)) || strcmp(stimCond, 'fixation')
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
end % switch shape

end % function mkap()