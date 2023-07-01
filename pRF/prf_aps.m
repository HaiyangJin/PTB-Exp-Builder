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
%    .unit           <str> the unit of the aperture. Default to 'standard',
%                     i.e., 100 * 100 [if the relevant information
%                     {.pixelperva} is avaiable (and positive)]. Other
%                     option is 'va' (visual angle) and 'pixel'.
%                     Alternatively, default to 0 (i.e., pixels).
%    .binary         <bool> whether to use binary image. Default to false,
%                     where the aperture was created with the orignal pixel
%                     size and re-size to the target size. If true,
%                     aperture is created with the target size directly
%                     (then it is a binary aperture).
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
%    .stimsize       <vec> the size of the stimlus in pixels for each trial.
%                     Default to dtTable.StimXY(x, :), i.e., the stimulus
%                     size in pixels.
%                OR  <str> the field name in dtTable.
%    .pixelperva    <num> number of pixels per visual angle. Default to 0.
%                     If .thispixelperva is avaiable in dtTable (when it is
%                     a struct), it will be used as the default.
%    .corrtime       <num> time to be applied to correct the precision
%                     issue for identifying the stimulus, . Default to 0.1.
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
    'unit', 'standard', ...
    'binary', false, ...
    'stimshape', 'rectangle', ...
    'framepersec', 1, ...
    'condorder', {''}, ...
    'stimsize', 'StimXY', ...
    'pixelperva', 0, ...
    'corrtime', .1, ...
    'apfn', ['aps_' char(datetime('now', 'Format', 'yyyyMMddHHmm'))] ...
    );

if isstruct(dtTable) && isfield(param, 'dtTable')
    dtTable = param.dtTable;
elseif exist(dtTable, 'file')
    % use the input file name as the {.apfnextra}
    [~,inputfn] = fileparts(dtTable);
    defaultOpts.apfn = ['aps_' inputfn];
    % load and retrieve the dtTable
    tmp = load(dtTable);
    dtTable = tmp.dtTable;

    if isfield(tmp, 'thispixelperva') && ~isempty(tmp.thispixelperva)
        defaultOpts.pixelperva = tmp.thispixelperva;
    end
end

% Update the .asva default if needed
if ~isempty(defaultOpts.pixelperva) && defaultOpts.pixelperva>0
    defaultOpts.asva = 1;
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
apXY = repmat(ceil(max(apXY)), 1, 2);

% use custom stim size if needed
if ischar(opts.stimsize)
    stimSize = dtTable.(opts.stimsize);
else
    stimSize = opts.stimsize;
end

% reverse the coordinates of Y
dtTable.StimPosiRela = dtTable.StimPosiRela .* [1, -1];

Scaling_factor = NaN;
% calculate the visual angle based on pixel
if opts.binary && (~isempty(opts.pixelperva) && opts.pixelperva>0)

    fprintf('\nMaking binary aperture...\n');

    switch opts.unit

        case {'va', 'visual angle', 'visual'}

            fprintf('Making aperture in the unit of visual angle...\n');

            apXY = apXY/opts.pixelperva * 10;
            % convert to visual angle
            dtTable.StimPosiRela = dtTable.StimPosiRela/opts.pixelperva * 100;
            stimSize = stimSize /opts.pixelperva * 100;

        case {'standard'}

            % save as standard unit
            fprintf('\nMaking aperture in the standard unit (100*100)...\n');
            % aperture X and Y in visual angle
            apXY_va = apXY/opts.pixelperva;
            Scaling_factor = max(apXY_va)/2;
            fprintf('The maximal eccentricy is %d.\n', max(apXY_va)/2);

            apXY = [100, 100];
            to_standard_ratio = apXY / apXY_va;
            % convert to standard unit
            dtTable.StimPosiRela = dtTable.StimPosiRela / opts.pixelperva * to_standard_ratio;
            stimSize = stimSize / opts.pixelperva * to_standard_ratio;

    end % switch opts.unit
end % binary && (~isempty(opts.pixelperva) && opts.pixelperva>0)

% number of frames in final aperture
frames = 0: 1/opts.framepersec: secTotal;
therows = arrayfun(@(x) find((x + opts.corrtime) >= onsets, 1, 'last'), frames(1:end-1));

% condition names and numbers
objStr = dtTable.StimCategory(therows);
objInt = cellfun(@(x) find(strcmp(x, condOrder))-1, objStr);

% make the aperture for each frame
apFrm = arrayfun(@(x) mkap(dtTable.StimCategory(x, :), dtTable.StimPosiRela(x, :), ...
    stimSize(x, :), apXY, opts.stimshape), therows, 'uni', false);
% to update StimXY

if ~opts.binary && (~isempty(opts.pixelperva) && opts.pixelperva>0)

    switch opts.unit

        case {'va', 'visual angle', 'visual'}

            fprintf('\nMaking non-binary aperture...\n');
            fprintf('\nMaking aperture in the unit of visual angle...\n');

            trgsize = max(apXY/opts.pixelperva * 10);
            apFrm = cellfun(@(x) imresize(x, [trgsize, trgsize]), apFrm, 'uni', false);
            apFrm = cellfun(@(x) max(x,0), apFrm, 'uni', false); % convert all negative values to 0

        case {'standard'}

            % save as standard unit
            fprintf('\nMaking non-binary aperture...\n');
            fprintf('\nMaking aperture in the standard unit (100*100)...\n');
            % aperture X and Y in visual angle
            apXY_va = max(apXY/opts.pixelperva);
            Scaling_factor = apXY_va/2;
            fprintf('The maximal eccentricy is %d.\n', apXY_va/2);

            apFrm = cellfun(@(x) imresize(x, [100, 100]), apFrm, 'uni', false);
            apFrm = cellfun(@(x) max(x,0), apFrm, 'uni', false); % convert all negative values to 0
    end
    
end

% save the final output
ApFrm = cat(3, apFrm{:});
Objects = objInt;

%% Save the aps_*.mat file
[filepath, name, ext] = fileparts(opts.apfn);
if ~startsWith(name, 'aps_')
    name = ['aps_', name];
end
if ~strcmp(ext, '.mat')
    ext = '.mat';
end
apfn = fullfile(filepath, [name, '_shape-', opts.stimshape, ext]);
% make sure not overwrite files
apfn0 = 0;
while exist(apfn, 'file')
    apfn0 = apfn0 + 1;
    apfn = fullfile(filepath, [name '_shape-' opts.stimshape '_' num2str(apfn0), ext]);
end

% save the file locally
save(apfn, 'ApFrm', 'Objects', 'Scaling_factor');

end % function prf_aps()

%% function to make an aperture
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
stimPosiX = apXY(2)/2 + stimPosiRela(1);
stimPosiY = apXY(1)/2 - stimPosiRela(2);

% stimulus shape
switch shape

    case 'rectangle'
        ap(stimPosiY-stimXY(1)/2+1 : stimPosiY+stimXY(1)/2, ...
            stimPosiX-stimXY(2)/2+1 : stimPosiX+stimXY(2)/2) = 1;

    case {'oval', 'circle'}
        for y = 1:apXY(1)
            for x = 1:apXY(2)
                if ((x-stimPosiX)^2)/((stimXY(2)/2))^2 + ...
                        ((y-stimPosiY)^2)/((stimXY(1)/2))^2 <= 1
                    ap(y,x) = 1;
                end
            end
        end

    case 'cf'
        switch stimCond{1}
            case 'aligned'
                ap = ap_cf(stimPosiRela, stimXY, apXY, 0);
            case 'misaligned_l'
                ap = ap_cf(stimPosiRela, stimXY, apXY, 1);
            case 'misaligned_r'
                ap = ap_cf(stimPosiRela, stimXY, apXY, 2);
        end

end % switch shape
end % function mkap()

%% Make special aperature (CF)
function ap = ap_cf(stimPosiRela, stimXY, apXY, ismis)
% stimPosiRela  <num vec> stimulus position relative to the center of the
%                screen along x and y axis.
% stimXY        <num vec> width and height of the stimulus.
% apXY          <num vec> width and hieght of the aperature.
% ismis         <int> 0: aligned; 1: bottom to left; 2: bottom to right

% default to not showing stimuli
ap = NaN(apXY);

% position of stimulus centers
stimPosiX = apXY(2)/2 + stimPosiRela(1);
stimPosiY = apXY(1)/2 - stimPosiRela(2);

% line
lineratio = 3/259;
lineh_half = lineratio * stimXY(2)/2;

% alignment
oval_w = stimXY(1)*(1-(ismis~=0)*(1/3));
mis = (ismis~=0)*(1.5-ismis)*2*stimXY(1)/3/2; % left: 1, right: -1

for y = 1:apXY(1)
    for x = 1:apXY(2)
        isInTopOval = ((x-stimPosiX-mis)^2)/(oval_w/2)^2 + ...
            ((y-stimPosiY+lineh_half)^2)/((stimXY(2)/2))^2 <= 1 && ...
            y-stimPosiY+lineh_half < 0; % top oval
        isInBotOval = ((x-stimPosiX+mis)^2)/(oval_w/2)^2 + ...
            ((y-stimPosiY-lineh_half)^2)/((stimXY(2)/2))^2 <= 1 && ...
            y-stimPosiY-lineh_half > 0; % bottom oval
        isInLine = y > stimPosiY-lineh_half && ...
            y < stimPosiY+lineh_half && ...
            x > stimPosiX-stimXY(1)/2 && ...
            x < stimPosiX+stimXY(1)/2; % the line between two halves

        ap(y,x) = (isInTopOval + isInBotOval + isInLine)>0;
    end
end

end % ap_cf