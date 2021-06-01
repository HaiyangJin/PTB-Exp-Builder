function [ imfilt ] = KP_SF_Filter( im, opt )
% spatial frequency filter grayscale images
% opt needs to contain:
% opt.type = ''; can be 'butt'  for butterworth or 'gauss' for gaussian
%                filter
% opt.cutoff = []; % can be one number (when .whichfilter is lowpass or
%                    highpass)or [low,high] (when .whichfilter is bandpass)
% opt.order = []; this is only needed if .type == 'butt'; if not given,
% defaults to 2
% opt.whichfilter = []; %which filter do you want? 0 == lowpass; 1 == highpass; 2 == bandpass


if ~ length(fieldnames(opt)) >=3
    error('check the function info to see which input is required!')
end

if strcmp(opt.type, 'butt')
    if ~ isfield(opt, 'order')
        opt.order = 2;
    elseif ~(opt.order>=1 && opt.order <=10 && ceil(opt.order) == floor(opt.order))
        opt.order  = 2;
        warning('your chosen filterorder does not make sense. Defaulted to 2');
    end
    L = size(im);
    % Computes the distance grid
    dist = zeros(L, 'double');
    m = L(1) / 2 + 1;
    for i = 1:L(1)
        for j = 1:L(1)
            dist(i, j) = sqrt((i - m)^2 + (j - m)^2);
        end;
    end;
    
    if length(opt.cutoff)<2
        if opt.whichfilter == 0
            opt.cutoff(2) = opt.cutoff(1);
        elseif opt.whichfilter == 1
            opt.cutoff(2) = opt.cutoff(1);
        elseif opt.whichfilter ==3
            error('you need to provide two cutoff values to make a band-pass filter [low high]');
        end
    end
    
    % Create Butterworth filter.
    LP = 1 ./ (1 + (dist / opt.cutoff(1)).^(2 * opt.order));
    HP = 1 ./ (1 + (dist / opt.cutoff(2)).^(2 * opt.order));
    
    HPFilter = (1.0 - HP) ;
    LPFilter = (1.0 ) .* LP;
    BPFilter  = 1 - LP;
    BPFilter = HP .* BPFilter;
    
    FFT = fft2(im);
    FFT(1,1) = 0; %removing DC component
    FFT = fftshift(FFT);
    LowFrequencies = real(ifft2(ifftshift(LPFilter .* FFT)));
    HighFrequencies = real(ifft2(ifftshift(HPFilter .* FFT)));
    BandFrequencies = real(ifft2(ifftshift(BPFilter .* FFT)));
    
elseif strcmp(opt.type, 'gauss')
      
    if length(opt.cutoff)<2
        if opt.whichfilter == 0
            opt.cutoff(2) = opt.cutoff(1);
        elseif opt.whichfilter == 1
            opt.cutoff(2) = opt.cutoff(1);
        elseif opt.whichfilter ==3
            error('you need to provide two cutoff values to make a band-pass filter [low high]');
        end
    end
    
    [nx,ny]= size(im);
    FFT = fft2(im,2*nx-1,2*ny-1);
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
            filter1(i,j) = exp(-dist^2/(2*opt.cutoff(1)^2));
            filter2(i,j) = exp(-dist^2/(2*opt.cutoff(2)^2));
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
    
else
    error('opt.type must be "butt" or "gauss"');
end

if opt.whichfilter == 0
    imfilt = LowFrequencies;
elseif opt.whichfilter == 1
    imfilt = HighFrequencies;
elseif opt.whichfilter == 2
    imfilt = BandFrequencies;
else error('You need to set opt.whichfilter to 1  2  or 3');
end

end