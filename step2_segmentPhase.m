%%

fname='t4_10bots_10fps_22_219'; Nt=500;
Nbots=10;
load(['dat_' fname])

%%

% export each bot as tif stacks,

for i=1:Nbots

    for t=1:Nt
        im=imread([fname '.tif'],t);

        xt=Xmat(i,t);
        yt=Ymat(i,t);
        R=40;

        rt=yt-R; rb=yt+R;
        cl=xt-R; cr=xt+R;
        imSub=im(rt:rb,cl:cr);

        imwrite(imSub, [fname '_bot' num2str(i) '.tif'],'WriteMode','Append');

    end

end

%%

% Detect the reference on the black-white bot

% Define parameters
circleRadiusRange = [30, 150]; % Radius range for circle detection
gradientThreshold = 0.5; % Threshold for gradient detection (adjust as needed)

for i = 1:Nbots
    for t = 1:Nt
        % Read the image
        im = imread([fname '_bot' num2str(i) '.tif'], t);
        
        % Apply Gaussian smoothing
        im2 = imgaussfilt(im, 1);
        
        % Detect circles in the image
        [centers, radii] = imfindcircles(im2, circleRadiusRange, 'ObjectPolarity', 'bright', 'Sensitivity', 0.9);
        
        % Initialize binary mask
        imBW = false(size(im2, 1), size(im2, 2));
        
        % If a circle is detected
        if ~isempty(centers)
            % Get the center and radius of the largest circle
            [~, idx] = max(radii); % Use the largest circle
            center = centers(idx, :);
            radius = radii(idx);
            
            % Create a mask for the circle
            [X, Y] = meshgrid(1:size(im2, 2), 1:size(im2, 1));
            circleMask = (X - center(1)).^2 + (Y - center(2)).^2 <= radius^2;
            
            % Crop the region inside the circle
            imCircle = im2 .* uint8(circleMask);
            
            % Detect the gradient rectangle inside the circle
            % (Example: Use edge detection or color-based thresholding)
            gradientMap = imgradient(imCircle); % Compute gradient magnitude
            rectangleMask = gradientMap > gradientThreshold * max(gradientMap(:));
            
            % Combine the circle mask and rectangle mask
            imBW = circleMask & rectangleMask;
        end
        
        % Convert the binary mask to uint8 (0 and 255)
        imBW = uint8(imBW) * 255;
        
        % Save the binary mask
        imwrite(imBW, [fname '_bot' num2str(i) '_BW.tif'], 'WriteMode', 'Append');
        
        % Optional: Visualize the binary mask for debugging
        figure(1);
        imshow(imBW);
        title(['Bot ' num2str(i) ', Frame ' num2str(t) ' - Binary Mask']);
        pause(0.1); % Pause to inspect the result
    end
end

% % figure()
% for i=1:Nbots
%     for t=1:Nt
%         im=imread([fname '_bot' num2str(i) '.tif'],t);
%         im2=imgaussfilt(im,1);
%         imagesc(im2)
%         imagesc((im2>85).*(im2<130))
%         imBW=uint8((im2<140)*255); %default 120
% 
%         imshow(imBW)
%         imwrite(uint8(imBW), [fname '_bot' num2str(i) '_BW.tif'],'WriteMode','Append')
% 
%         colorbar
%         pause()
%         clf
% 
%     end
% 
% end


% %%
% % Assuming you have a binary image stack with dimensions 81-by-81
% % The stack is stored in a 3D matrix where the third dimension is time.
% % For example: binaryImageStack = rand(81, 81, numFrames) > 0.5;
% 
% % Sample input (binary stack)
% % Replace this with your actual binary image stack
% % binaryImageStack = rand(81, 81, 50) > 0.5;  % 50 frames example
% % [numRows, numCols, numFrames] = size(binaryImageStack);
% numFrames=Nt;
% % Define the center of the image
% center = [41, 41];
% 
% phaseMat=zeros(Nbots,Nt);
% 
% % Define the area constraint
% maxArea = 500;  % Area must be less than 500 pixels^2
% 
% % figure()
% for i=1:Nbots
%     phasei=zeros(1,Nt);
%     % Loop through each frame
%     for frameIdx = 1:numFrames
%         % Get the binary image for the current frame
%         binaryImage = imread([fname '_bot' num2str(i) '_BW.tif'],frameIdx)==255;
% 
%         % Get region properties for regions with value 1, including Area
%         props = regionprops(binaryImage, 'Centroid', 'Orientation', 'MajorAxisLength', 'MinorAxisLength', 'Area');
% 
%         % Filter out regions with area larger than 500 pixels
%         props = props([props.Area] < maxArea);
% 
%         % Extract the centroids of all regions
%         centroids = cat(1, props.Centroid);
% 
%         % If there are no regions, skip this frame
%         if isempty(centroids)
%             continue;
%         end
% 
%         % Compute distances from each region's centroid to the center (41, 41)
%         distances = sqrt(sum((centroids - center).^2, 2));
% 
%         % Find the region closest to the center
%         [~, closestIdx] = min(distances);
% 
%         % Get the properties of the closest region
%         region1Centroid = props(closestIdx).Centroid;
%         region1Orientation = props(closestIdx).Orientation;   % Orientation angle in degrees
%         majorAxisLength = props(closestIdx).MajorAxisLength;
%         minorAxisLength = props(closestIdx).MinorAxisLength;
% 
%         phasei(frameIdx)=region1Orientation;
% 
% 
%         % Draw the ellipse representing the region's major and minor axis
%         % Create the ellipse in parameterized form
%         theta = linspace(0, 2*pi, 100);
%         ellipseX = (majorAxisLength / 2) * cos(theta);
%         ellipseY = (minorAxisLength / 2) * sin(theta);
% 
%         % Rotate the ellipse by the orientation angle
%         rotationMatrix = [cosd(region1Orientation), -sind(region1Orientation); ...
%             sind(region1Orientation), cosd(region1Orientation)];
%         rotatedEllipse = rotationMatrix * [ellipseX; ellipseY];
% 
%         % Plot the binary image
%         % imagesc(binaryImage); hold on;
%         % plot(region1Centroid(1), region1Centroid(2), 'ro', 'MarkerSize', 10, 'LineWidth', 2);
%         % plot(rotatedEllipse(1, :) + region1Centroid(1), rotatedEllipse(2, :) + region1Centroid(2), 'g-', 'LineWidth', 2);
%         % title(sprintf('Frame %d: Orientation = %.2f°', frameIdx, region1Orientation));
%         %
%         % pause();
%         % clf
%     end
% 
%     phaseMat(i,:)=phasei;
% end
% 
% disp('Ellipses plotted for all frames.');
% 
% %%
% 
% figure()
% plot(phasei)
% 
% %%
% 
% omegaMat=zeros(Nbots,Nt);
% 
% figure()
% hold on
% for i=1:Nbots
% 
%     phasei=phaseMat(i,:);
% 
%     dphasei=diff(phasei);
%     dphasei(dphasei<90)=dphasei(dphasei<90)+180;
%     dphasei(dphasei>90)=180-dphasei(dphasei>90);
% 
%     phasei2=cumsum(dphasei);
% 
%     % omegaMat(i,2:end-1)=diff(phasei2)';
% 
%     plot(smooth(diff(phasei2),11)*fps);
%     omegaMat(i,2:end-1)=smooth(diff(phasei2),5)*fps;
%     pause(0.1)
%     xlabel('Time (frame)')
%     ylabel('Spinning frequency (deg/s)')
% 
% end
% 
% omegaMat(:,1)=omegaMat(:,2);
% omegaMat(:,end)=omegaMat(:,end-1);
% 
% %%
% 
% save(['dat_phaseOmega' fname],'phaseMat','omegaMat')