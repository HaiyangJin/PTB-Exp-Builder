function vi_mov2avi(movfn)
% vi_mov2avi(movfn)
%
% Convert mov (in Mac) to *.avi.
% 
% Input:
%    movfn           <str> (path and) file name of the video file that can 
%                     be read by VideoReader(). 
%
% % Created by Haiyang Jin (2023-May-3)
%
% See also:
% vi_mat2wmv(); vi_mov2wmv()

% Read Video
movReader = VideoReader(movfn);
[inpath, infn] = fileparts(movfn);

% Write Video
viWrite = VideoWriter([inpath, infn, '.avi']);

% set the frame rate
viWrite.FrameRate = movReader.FrameRate;

% Save frame into the writer
open(viWrite);

for count = 1:abs(movReader.Duration*movReader.FrameRate)
    key_frame = read(movReader,count);
    writeVideo(viWrite,key_frame);
end

% Release video object
close(viWrite);
fprintf('The conversion is completed.\n');

end