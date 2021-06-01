function im_filtered = im_sffilter(imMatrix, varargin)
% im_filtered = im_sffilter(imMatrix, varargin)
%
% This function filter the images with different spatial frequencies.
% This function is modified from the code from Goffaux lab
% (https://sites.uclouvain.be/goffauxlab/index.html). [The original code
% can be found at ../Utilities/KP_SF_Filter.m. 
%
% Please cite the following paper if this function is used:
%   Petras, K., ten Oever, S., Jacobs, C., & Goffaux, V. (2019). 
%   Coarse-to-fine information integration in human vision. NeuroImage, 
%   186, 103?112. https://doi.org/10.1016/j.neuroimage.2018.10.086
%
% Inputs:
%    imMatrix    <numeric array> image matrix.
%
% Varargin:
%    'type'      <string> 'butt' for butterworth filter. 'gauss' for
%                 gaussan filter (default).
%    'cutoff'    <numeric> % can be one number (when .filter is
%                 lowpass or highpass)or [low,high] (when .filter is
%                 bandpass). Default is 8.
%    'order'     <integer> this is only needed if .type == 'butt'; default
%                 is 2.
%    'filter'    <integer> which filter to be applied? 0 == lowpass; 
%                 1 == highpass (default); 2 == bandpass.
%    'norm'      <numeric vector> [contrast, luminance] of the output 
%                 image. Default is 0 (no normalization will be applied).
%                 E.g., [1, 0] apply contrast of 1 and luminance of 0 to
%                 the output image.
%
% Output:
%    im_filtered <numeric array> spatial frequency filtered image array.
%
% Modified by Haiyang Jin (29-May-2021)

defaultOpts = struct;
defaultOpts.type = 'gauss';
defaultOpts.cutoff = 8;
defaultOpts.order = 2;
defaultOpts.filter = 1;
defaultOpts.norm = 0;

opts = ptb_mergestruct(defaultOpts, varargin{:});

if length(opts.cutoff)<2
    if opts.filter ==2
        error('you need to provide two cutoff values to make a band-pass filter [low high]');
    else
        opts.cutoff(2) = opts.cutoff(1);
    end
end

switch opts.type
    case 'butt'
        
        if ~(opts.order>=1 && opts.order <=10 && ceil(opts.order) == floor(opts.order))
            opts.order  = 2;
            warning('your chosen filterorder does not make sense. Defaulted to 2');
        end
        
        L = size(imMatrix);
        % Computes the distance grid
        dist = zeros(L, 'double');
        
        m = L(1) / 2 + 1;
        for i = 1:L(1)
            for j = 1:L(1)
                dist(i, j) = sqrt((i - m)^2 + (j - m)^2);
            end
        end
        
        % Create Butterworth filter.
        LP = 1 ./ (1 + (dist / opts.cutoff(1)).^(2 * opts.order));
        HP = 1 ./ (1 + (dist / opts.cutoff(2)).^(2 * opts.order));
        
        HPFilter = (1.0 - HP) ;
        LPFilter = (1.0 ) .* LP;
        BPFilter  = 1 - LP;
        BPFilter = HP .* BPFilter;
        
        FFT = fft2(imMatrix);
        FFT(1,1) = 0; %removing DC component
        FFT = fftshift(FFT);
        LowFrequencies = real(ifft2(ifftshift(LPFilter .* FFT)));
        HighFrequencies = real(ifft2(ifftshift(HPFilter .* FFT)));
        BandFrequencies = real(ifft2(ifftshift(BPFilter .* FFT)));
        
    case 'gauss'
        
        [nx,ny]= size(imMatrix);
        FFT = fft2(imMatrix,2*nx-1,2*ny-1);
        FFT(1,1) = 0; %removing DC component
        FFT = fftshift(FFT);
        % Initialize filter.
        filter1 = ones(2*nx-1,2*ny-1);
        filter2 = ones(2*nx-1,2*ny-1);
        filter3 = ones(2*nx-1,2*ny-1);
        
        for i = 1:2*nx-1
            for j =1:2*ny-1
                dist = ((i-(nx+1))^2 + (j-(ny+1))^2)^.5;
                % Use Gaussian filter.
                filter1(i,j) = exp(-dist^2/(2*opts.cutoff(1)^2));
                filter2(i,j) = exp(-dist^2/(2*opts.cutoff(2)^2));
                filter2(i,j) = 1.0 - filter2(i,j);
                filter3(i,j) = filter1(i,j).*filter2(i,j);
            end
        end
        % Update image with passed frequencies
        LowFrequencies = ifft2(ifftshift((filter1.*FFT)),2*nx-1,2*ny-1);
        LowFrequencies = real(LowFrequencies(1:nx,1:ny));
        HighFrequencies = ifft2(ifftshift((filter2.*FFT)),2*nx-1,2*ny-1);
        HighFrequencies = real(HighFrequencies(1:nx,1:ny));
        BandFrequencies = ifft2(ifftshift((filter3.*FFT)),2*nx-1,2*ny-1);
        BandFrequencies = real(BandFrequencies(1:nx,1:ny));
        
    otherwise
        error('".type" must be "butt" or "gauss".');
end

if opts.filter == 0
    raw_filtered = LowFrequencies;
elseif opts.filter == 1
    raw_filtered = HighFrequencies;
elseif opts.filter == 2
    raw_filtered = BandFrequencies;
else 
    error('You need to set .filter to 0, 1 or 2.');
end

% apply custom contrast and luminance
if any(opts.norm)
    norm_filtered = (raw_filtered - mean(raw_filtered(:)))/std(raw_filtered(:));
    im_filtered = norm_filtered * opts.norm(1) + opts.norm(2);
else
    im_filtered = raw_filtered;
end

end
