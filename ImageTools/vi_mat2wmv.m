function vi_mat2wmv(videomat, N_sec, fn, mmpath)
% vi_mat2wmv(videomat, N_sec, fn, mmpath)
%
% Convert *.mat into *.wmv. This function has to be run in WINDOWS (with 
% K-Lite_Codec_Pack_1687_Full.exe installed).
% list available video and audio encoders installed on your system 
% Vidlist = mmwrite('','ListAviVideoEncoders');
% Audlist = mmwrite('','ListAviAudioEncoders');
% 
% Inputs:
%    videomat        <mat> the output video matrix. The four dimensions are 
%                     height * width * color channels * frames.
%    N_sec           <int> how long is the run (seconds).
%    fn              <str> output file name. Default to
%                     'video_for_nordic.wmv'.
%    mmpath          <str> path to the mmwrite toolbox.
%
% Created by Haiyang Jin (2023-May-3)
%
% See also:
% vi_mov2mat(); vi_mov2wmv()

if ~exist('fn', 'var') || isempty(fn)
    fn = 'video_for_nordic.wmv';
end

% add necessary paths for external toolboxes
if ~exist('mmpath', 'var') || isempty(mmpath)
    mmpath = fullfile(pwd, 'mmwrite');
end
addpath(genpath(mmpath));

assert(~isunix, 'vi_mov2wmv() only works in Windows.');

%% Export video
nframes = size(videomat,4);
FrameRate = nframes / N_sec; 

% Set video parameters
video.times = (1:nframes) ./ FrameRate; 
video.height = size(videomat,1); 
video.width = size(videomat,2);  

% Create video frames
frames = struct;
for i = 1:nframes
    frames(i).cdata = videomat(:,:,:,i);
end 
video.frames = frames;

% Write video using mmwrite function
try
    mmwrite(fn, video);
 catch error
    fprintf(['Please make sure the mmwrite toolbox (%s) is set up properly.', ...
        'https://www.mathworks.com/matlabcentral/fileexchange/15881-mmwrite']);
    rethrow(error);
end

end