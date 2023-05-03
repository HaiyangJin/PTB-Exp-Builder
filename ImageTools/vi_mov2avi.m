function vi_mov2avi(infile)

% Read Video
videoFReader = VideoReader(infile);
[inpath, infn] = fileparts(infile);

% Write Video
videoFWrite = VideoWriter([inpath, infn, '.avi']);

open(videoFWrite);

for count = 1:abs(videoFReader.Duration*videoFReader.FrameRate)
    key_frame = read(videoFReader,count);
    writeVideo(videoFWrite,key_frame);
end

% Release video object
% close(videoFReader);
close(videoFWrite);
disp('COMPLETED');

end