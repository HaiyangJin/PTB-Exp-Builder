function stimDir = im_setluminance(stimDir, reflum, mask)
% stimDir = im_setluminance(stimDir, reflum, mask)
%
% Set/Balance luminance for images read by im_readdir().
%
% Inputs:
%    stimDir      <struct> the stimulus struct read by im_readdir().
%    reflum       <int> reference luminance. Default is 128.
%              OR <str> 'meanlum': use the mean luminance (.matrix) of
%                  all stimuli as the reflum.
%    mask         <boo array> which pixels will be used to calculate the
%                  luminance differences, which will be removed from all
%                  pixels. Default is all pixels.
%              OR <str> 'pngalpha': alpha layer of the png file will be
%                  used as the mask; 'upperleft': only the left upper
%                  corner of the first layer is 1 in the mask.
%
% Output:
%    stimDir      <struct> the updated stimulus struct.
%
% Created by Haiyang Jin (2021-11-08)

if ~exist('reflum', 'var') || isempty(reflum)
    reflum = 128;
end
if ischar(reflum)
    switch reflum
        case 'meanlum'
            % use mean luminance across all stimuli
            reflum = mean(cat(4, stimDir.matrix), 'all');

        otherwise
            error('Reference luminance of %s is not available.', reflum);
    end
end

if ~exist('mask', 'var') || isempty(mask)
    % all pixels will be used to calculate the luminance difference
    mask = ones(size(stimDir(1).matrix));
end
if ischar(mask)
    switch mask
        case 'pngalpha'
            % do nothing here (will do something in the for loop)
        case 'leftupper'
            mask = zeros(size(stimDir(1).matrix));
            mask(ones(1, ndims(mask))) = 1;

        otherwise
            error('Mask for %s is not available.', mask);
    end
end

%% Process each stimulus separately
nImg = length(stimDir);

for i = 1:nImg

    themat = stimDir(i).matrix;

    % use the alpha as mask if needed
    if ischar(mask) && strcmp(mask, 'pngalpha') && endsWith(stimDir(i).fn, 'png')
        mask = stimDir(i).alpha;
    end

    % calculate the luminance differences
    difflum = mean(themat(logical(mask)), 'all') - reflum;

    % updated stimulus
    stimDir(i).matrix = themat-difflum;
end

end