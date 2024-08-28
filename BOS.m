%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   BOS
%
%   ~
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% reset setting
clear

% Connect to QTM
ip = '127.0.0.1';
% Connects to QTM and keeps the connection alive.
QCM('connect', ip, 'frameinfo', 'force');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% figure setting
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Create a figure window
figureHandle = figure('Position', [300, 300, 1200, 600], 'Name', 'ML Force Feedback', 'NumberTitle','off', 'Color', [0.8, 0.8, 0.8]);
hold on

% set the figure size
set(gcf, 'Units', 'Normalized', 'OuterPosition', [0, 0.04, 1, 0.96]);
% remove ticks from axes
set(gca,'YTick',[])

foot_size = 270;

xlim=[0, 1200];
ylim=[0, foot_size];

% set limits for axes
set(gca, 'xlim', xlim, 'ylim',ylim)

% each bar width
width = 100;

CircleRadius = 20;
CircleCenter = [600, 150];
CirclePos = [CircleCenter(1) - CircleRadius/2, CircleCenter(2) - CircleRadius/2, CircleRadius, CircleRadius];
% x,y,w,h
COP = rectangle('Position', CirclePos, 'Curvature', [1, 1], 'EdgeColor', 'black', 'LineWidth', 2);

plate_info = {"GRFx", "GRFy", "GRFz", "", "COPx", "COPy", "COPz", ""};
plate_data(2) = struct(); % right, left

% Draw rectangles representing the feet
left_foot = rectangle('Position', [550 + 150, 0, 150, 270], 'Curvature', [1, 1], 'EdgeColor', 'b', 'LineWidth', 2);
right_foot = rectangle('Position', [550 - 150, 0, 150, 270], 'Curvature', [1, 1], 'EdgeColor', 'r', 'LineWidth', 2);

while ishandle(figureHandle)
    try
        event = QCM('event');
        [~, force] = QCM;
        
        % GRFx, GRFy, GRFz, ?, COPx, COPy, COPz, ? from plate 1
        for side=1:2 % right, left
            for idx=1:length(plate_info)
                if plate_info{idx} == ""; continue; end
                plate_data(side).(plate_info{idx}) = (force{2,side}(1,idx));
            end
        end

        COPy_net =  calc_COP_net(plate_data(2).COPx, plate_data(1).COPx, ...
                                 plate_data(2).GRFx, plate_data(1).GRFx);

        COPx_net =  calc_COP_net(plate_data(2).COPy, plate_data(1).COPy, ...
                                 plate_data(2).GRFy, plate_data(1).GRFy);

        set(COP, 'Position', [600+COPx_net, foot_size/2+COPy_net, CircleRadius, CircleRadius/3])

        drawnow;
    
    catch exception
        disp(exception.message);
        break;
    end       
end

delete(figureHandle);
