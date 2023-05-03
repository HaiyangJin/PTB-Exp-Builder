function videomat = vi_mov2mat(movfn)
% videomat = vi_mov2mat(movfn)
% 
% (Please use this function only when you have to.)
% Convert *.mov (or other files that can be read via VideoReader()) into
% *.mat. In most cases, the video is too large to be saved as *.mat (you
% will see error message [out of memory]).
%
% Input:
%    movfn           <str> (path and) file name of the video file that can 
%                     be read by VideoReader(). 
%
% Output:
%    videomat        <mat> the output video mat. The four dimensions are 
%                     height * width * color channels * frames.
%
% Created by Haiyang Jin (2023-May-3)
%
% See also:
% vi_mat2wmv(); vi_mov2wmv()

[thepath, fn] = fileparts(movfn);
outfn = fullfile(thepath, [fn '.mat']);

% read the video
vidObj = VideoReader(movfn);

% initialize the NaN video matrix
videomat = NaN([size(read(vidObj,1)), vidObj.NumFrames]);

for iframe = 1:vidObj.NumFrames
    videomat(:,:,:,iframe) = read(vidObj,iframe);
end

% save the output mat
save(outfn, 'videomat', '-v7.3');

end