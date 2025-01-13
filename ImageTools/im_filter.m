function im_filtered = im_filter(imMatrix, varargin)
% im_filtered = im_filter(imMatrix, varargin)
%
% This function filter the images with different spatial frequencies.
%
% Please cite the following paper if this function is used:
%     Perfetto, S., Wilder, J., & Walther, D. B. (2020). Effects of spatial 
% frequency filtering choices on the perception of filtered images. Vision,
% 4(2), Article 2. https://doi.org/10.3390/vision4020029
%
% Inputs:
%    imMatrix    <num array> image matrix.
%
% Varargin:
%    'filter'    <str> 'low' for making low spatial frequency images (default);
%                 'high' for making high spatial frequency images.
%    'vapi'      <num> the angle size of the stimuli (width), default to 5.
%    'cutoff'    <num> the cutoff (cycles per image/face or cycles per 
%                 digreees if vapi>0) to be used in filtering. Default to 8. 
%                 Can be translated to the sigma of the Gaussian filter 
%                 kernel. (Full-Width-Half-Maximum, FWHM)
%                 To standardize multipel images, use jointContrastNormalize().
%
% Output:
%    im_filtered <num array> (unstandardized) spatial frequency filtered 
%                 image array.
%
% Modified by Haiyang Jin (2025-10-12)

defaultOpts = struct( ...
    'filter', 'low', ...
    'vapi', 5, ...
    'cutoff', 8);

opts = ptb_mergestruct(defaultOpts, varargin{:});

% process input image
FS = im2double(imMatrix);
if ndims(FS) == 3
    FS = rgb2gray(FS);
end
imsize = size(FS);

% generate spatial frequency grids
Fsamp = imsize ./ opts.vapi;

% The Gaussian filter is implemented by convolution in image space
% we construct the sigma of the Gaussian kernel in image space
% such that the corresponding Gaussian kernel in frequency space
% has its half maximum at the cutoff point
factor = pi * sqrt(2 * log(2)); % FWHM = 2*sqrt(2*log(2) * sigma
sigma = Fsamp / factor / opts.cutoff;
% sigma = imsize / (opts.vapi * pi * sqrt(2 * log(2)) * opts.cutoff)

% LSF: just filter with Gaussian
LSF = imgaussfilt(FS,sigma,'FilterDomain','Spatial');

% HSF: subtract LSF with HSF cutoff from original
HSF = FS - LSF;

switch opts.filter
    case {'low', 'lsf', 'l'}
        im_filtered = LSF;
    case {'high', 'hsf', 'h'}
        im_filtered = HSF;
    case 'FS'
        im_filtered = FS;
    otherwise
        error(['Unknown filter type: ', opts.filter]);
end

end