function imScrambled = im_phasescramble(imMatrix)
% imScrambled = im_phasescramble(imMatrix)
% 
% This function generates the phase scrambled image matrix.
%
% Inputs:
%     imMatrix      <numeric array> image matrix.
%
% Output:
%     imScrambled   <numeric array> phase-scrambled image matrix.
%
% Created by Haiyang Jin (18-Feb-2020)
%
% See also:
% im_bscrambledir; im_pscrambledir; im_boxscramble

% standarize the image matrix
im = mat2gray(double(imMatrix));

% size of the image
imSize = size(im);

% replcate the matrix to 3 layers (in the third dimention) if it is not
if numel(imSize) == 2
    im = repmat(im, 1, 1, 3);
    imSize = size(im);
end

% make sure there are three layers in the image matrix
if numel(imSize) ~= 3
    error('The image matrix is not three layers. \n[Size: %s]', num2str(imSize));
end

%generate random phase structure
randomPhase = angle(fft2(rand(imSize(1:2))));

% creat an NaN array for scrambled image matrix
imScrambled = NaN(imSize);

for layer = 1:imSize(3)
    
    % Fast-fourier transform
    imFourier = fft2(im(:, :, layer));
    
    % amplitude spectrum
    amp = abs(imFourier);
    
    % phase spectrum
    phase = angle(imFourier);
    
    % add random phase to original phase
    phase = phase + randomPhase;
    
    % combine Amp and Phase then perform inverse Fourier
    imScrambled(:, :, layer) = ifft2(amp .* exp(sqrt(-1)*phase));
    
end

%get rid of imaginery part in image (due to rounding error)
imScrambled = real(imScrambled);
    
end