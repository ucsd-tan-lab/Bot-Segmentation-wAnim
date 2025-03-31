
% set parameters here:
fname='Gaming'; 
downsample_factor=6;

% start time to export to tif
startMin = 0; % Example: 1 minute
startSec = 30; % Example: 30 seconds

% end time to export to tif
endMin = 2; % Example: 1 minute
endSec = 0; % Example: 30 seconds

% Also, line 36, set dimension of frame as desired
% by default, we downsample x, y by 2 times to make analysis faster

%%

videoObj = VideoReader([ fname '.MOV']);
% Get video properties
frameRate = videoObj.FrameRate;
fps=round(frameRate/downsample_factor);

% Set the CurrentTime property of the video object to the target time
videoObj.CurrentTime = startMin*60+startSec;
totSec=(endMin-startMin)*60+(endSec-startSec);
nlength=totSec*frameRate;

%%

timeStr=[num2str(startMin*100+startSec) '_' num2str(endMin*100+endSec)];

frameIdx=1;
% while hasFrame(videoObj)
for t=1:nlength
    frame = readFrame(videoObj);  % Read current frame
    frame=frame(2:2:end,2:2:end,1);
    if mod(frameIdx, downsample_factor) == 0  % Only keep every ds_fac-th frame
        imwrite(frame, [fname '_' num2str(fps) 'fps_' timeStr '.tif'],'WriteMode','Append')   
    end
    frameIdx = frameIdx + 1;
end
