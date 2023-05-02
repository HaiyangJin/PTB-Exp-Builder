function prf_examplestim(prfposi, immat, varargin)
% prf_examplestim(prfposi, immat, varargin)
%
% Create an example of the stimulus position.
%
% Inputs:
%     prfposi      <cell> a cell of stimulus positions. [could be obtained
%                   from prf_stimposi().
%     immat        <struct> a struct of stimlus to be displayed. [could be
%                   obtained from im_readdir().
%
% Varagin:
%     .mask        <boo array> it should have the same size as [prfposi].
%                   Whether the stim on each position should be displayed.
%                   Default to displaying stimuli at all positions (unless
%                   [immat] is not specified).
%     .dotopt      <cell> options for scatter(). Default to {{100, 'k', 
%                   'filled'}}.
%     .outfn       <str> the filename to be saved as. Default to
%                   'stimulus_position'.
%     .outext      <str> the extension of the to-be-saved file. Default to
%                   png.
%     .closefig    <boo> whether close the figure in matlab. Default to 0.
%
% Example:
% param = struct;
% param.canvasxy = [1000, 800];
% param = prf_stimposi(param);
% prfposi = param.prfposi;
% prf_examplestim(prfposi);
%
% Created by Haiyang Jin (2023-Feb-25)

% default settings
defaultOpts = struct(...
    'mask', ones(size(prfposi)), ...
    'dotopt', {{100, 'k', 'filled', ...
                'MarkerFaceAlpha',.5,'MarkerEdgeAlpha',.5}}, ... % size, black, type
    'outfn', 'stimulus_position', ...
    'outext', 'png', ...
    'closefig', 0 ...
    );
opts = ptb_mergestruct(defaultOpts, varargin);

% make a fake immat
if ~exist('immat', 'var') || isempty(immat)
    immat = struct;
    immat.matrix = zeros(256, 200);
    immat.alpha = zeros(256, 200);
    immat = repmat(immat, numel(prfposi), 1);
    opts.mask = zeros(size(prfposi));
end

% convert into a vector
positions = prfposi(:);
masks = opts.mask(:);

fig = figure;

% display dot array
dots_posi = vertcat(positions{:});
scatter(dots_posi(:,1), dots_posi(:,2), opts.dotopt{:});
set(gca, 'YDir', 'reverse');
hold on

% display stimulus at each location
for iposi = 1:length(positions)

    % position coodinates
    posiX = positions{iposi}(1);
    posiY = positions{iposi}(2);
    % stimulus size
    stimX = size(immat(iposi).matrix,2);
    stimY = size(immat(iposi).matrix,1);

    if size(immat(iposi).matrix, 3)==1
        thismat = repmat(immat(iposi).matrix,1,1,3);
    else
        thismat = immat(iposi).matrix;
    end

    % plot the image at specific location
    h = image([posiX-stimX/2 posiX+stimX/2+-1], ...
        [posiY-stimY/2 posiY+stimY/2-1], ...
        thismat);

    % apply transparency
    if masks(iposi)
        alpha = immat(iposi).alpha;
    else
        alpha = zeros(size(immat(iposi).alpha));
    end
    set(h, 'AlphaData', alpha);
    hold on

end % for iposi

% deal with axis
axis equal;
axis tight;
axis off;

% saveas local file
print(fig, [opts.outfn, '1'], ['-d' opts.outext]);
if opts.closefig; close(fig); end

end