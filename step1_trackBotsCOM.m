% set parameters here:
fname = 'Gaming_5fps_30_200'; Nt = 400;

%% Initialize arrays for storing positions and radii
posArr = cell(1, Nt); 
radiusArr = cell(1, Nt);

for t = 1:Nt
    im = imread([fname '.tif'], t);
    [centers, radii] = imfindcircles(im, [20 50]);

    % Store positions and radii of detected circles
    if length(centers) >= 2
        posArr{t} = centers'; 
        radiusArr{t} = radii;
    else
        % If less than two circles detected, store NaN for missing values
        posArr{t} = NaN(2, 2);  % 2 rows for 2 bots, but NaN for missing
        radiusArr{t} = NaN(1, 2);
    end

    
    imshow(im)
    hold on
    if ~any(isnan(posArr{t}(1, :)))  % Check if the centers are not NaN
        viscircles(posArr{t}', radiusArr{t}, 'Color', 'r'); 
    end
    title(t)
    pause(0.1)
    clf
end

%% Tracking the positions of the bots
[Xmat, Ymat] = myTracking(posArr(1:end), 20, 0);

avgradii=mean(radii);
botradius=12.7;
scale_factor = botradius/avgradii;

x_cm = Xmat * scale_factor;
y_cm = Ymat * scale_factor;
figure;
hold on;
plot(x_cm(1, :), y_cm(1, :), 'b', 'LineWidth', 2);
plot(x_cm(2, :), y_cm(2, :), 'r', 'LineWidth', 2);
xlabel('X Position (cm)');
ylabel('Y Position (cm)');
title('Smoothed Bot Trajectories');
axis equal;
grid on;
hold off;


%% Setup for plotting the trajectory of both bots

figure('Position', [100, 100, 800, 600]); % Set figure size (wider view)
cmap = jet(Nt); % Use jet colormap for a smooth gradient


figure;
hold on;

gif_filename = [fname '_bot_animation.gif'];
colormap(jet);
cbar = colorbar;
cbar.Label.String = 'Time (s)';
cbar.Ticks = linspace(0, 1, 5);
cbar.TickLabels = round(linspace(min(t), max(t), 5), 2);

xlabel('X Position (cm)');
ylabel('Y Position (cm)');
title('Bot Trajectories Over Time');
axis equal;
grid on;
xlim([min(x_cm(:)) - 5, max(x_cm(:)) + 5]);
ylim([min(y_cm(:)) - 5, max(y_cm(:)) + 5]);
bot_marker1 = plot(NaN, NaN, 'ko', 'MarkerSize', 50, 'LineWidth', 2);
bot_marker2 = plot(NaN, NaN, 'go', 'MarkerSize', 50, 'LineWidth', 2);

dt=0.1;

% Animation loop
for i = 2:Nt
    
    plot(x_cm(1, i-1:i), y_cm(1, i-1:i), 'Color', cmap(i, :), 'LineWidth', 2);
    plot(x_cm(2, i-1:i), y_cm(2, i-1:i), 'Color', cmap(i, :), 'LineWidth', 2);

    
    set(bot_marker1, 'XData', x_cm(1, i), 'YData', y_cm(1, i), 'Color', cmap(i, :));
    set(bot_marker2, 'XData', x_cm(2, i), 'YData', y_cm(2, i), 'Color', cmap(i, :));

    
    frame = getframe(gcf);
    im = frame2im(frame);
    [imind, cm] = rgb2ind(im, 256);

    
    if i == 2
        imwrite(imind, cm, gif_filename, 'gif', 'LoopCount', Inf, 'DelayTime', dt);
    else
        imwrite(imind, cm, gif_filename, 'gif', 'WriteMode', 'append', 'DelayTime', dt);
    end

    % Pause for animation effect
    pause(dt);
end

