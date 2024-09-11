%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   squat_feedback_AP
%
%   ~~
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% reset setting
clear

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% foot size and option setting
%% foot size is must 200 ~ 350
%% The option is to decide which test to do 1)top 20%, 2)top 10%, 3)foot center, 4)bottom 10%, 5)bottom 20%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[foot_size, option] = InputGUI_AP;
option = convertOption(option);

% Connect to QTM
ip = '127.0.0.1';
% Connects to QTM and keeps the connection alive.
QCM('connect', ip, 'frameinfo', 'force');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% figure setting
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Create a figure window
% Units : [0,0,1,1] - full width size
% OuterPosition : position of figure [left, bottom, width, height]
% 4% below, 4% above blank
figureHandle = figure('Units', 'Normalized', 'OuterPosition', [0, 0.04, 0.96, 0.96]);
hold on
% remove ticks from axes
set(gca,'XTICK',[],'YTick',[])

% setting figure size to real force plate size
%           600mm      600mm
%        ---------------------
%      x↑         ¦           ¦
%       o → y     ¦           ¦ 400mm
%       ¦         ¦           ¦ 
%        ---------------------
% original coordinate : left end(x = 0) and center
xlim=[0 1200];
ylim=[-200 200];

% center coordinate for figure size
centerpoint = [(xlim(1) + xlim(2)) / 2, (ylim(1) + ylim(2)) / 2];

% Start the graph from the bottom to the top 76mm (force plate 끝~나사부분 길이 = 76mm)
start_valuey = 76; % 76mm

% set initial coordinate at 70mm from end point of force plate 
% and set total boundary to 100 (%)
ylim = [ylim(1) + start_valuey, ylim(1) + start_valuey + foot_size];

% set limits for axes
set(gca, 'xlim', xlim, 'ylim',ylim)

% Required for 20% calculation of foot size from the center of foot size
foot_center = ylim(1) + foot_size/2;

% bar blank between vertical center line and each bar
margin = 300;
% initial location of each bar (bottom and center point of bar)
loc1_org = [centerpoint(1) - margin, ylim(1)]; % x1 y
loc2_org = [centerpoint(1) + margin, ylim(1)]; % x2 y

% width of each bar
width = 100;
% height of bars
height = ylim(2) - ylim(1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% draw outlines
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% draw frame of figure like force plate
plot([0 0],get(gca,'ylim'),'k', 'linewidth',3)
plot([xlim(2) xlim(2)],get(gca,'ylim'),'k', 'linewidth',3)
plot([centerpoint(1) centerpoint(1)],get(gca,'ylim'),'k', 'linewidth',3)
plot(get(gca,'xlim'),[ylim(2) ylim(2)],'k', 'linewidth',3)
plot(get(gca,'xlim'),[ylim(1) ylim(1)],'k', 'linewidth',3)
title('Left                                                            Right','fontsize',30)

% make handles for each bar to update vGRF and AP COP data
%plot_bar1 = plot([loc1_org(1)-width/2, loc1_org(1)-width/2], [ylim(1), foot_center], 'LineWidth', 90, 'Color', 'red');
%plot_bar2 = plot([loc2_org(1)+width/2, loc2_org(1)+width/2], [ylim(1), foot_center], 'LineWidth', 90, 'Color', 'blue');
plot_bar3 = plot([loc2_org(1), loc2_org(1)], [ylim(1), foot_center], 'LineWidth', 90, 'Color', 'black');

% draw left bar frame
plot([loc1_org(1)-width/2, loc1_org(1)+width/2],[height, height],'k', 'linewidth', 1) % top
plot([loc1_org(1)-width/2, loc1_org(1)-width/2],[ylim(1), height],'k', 'linewidth', 1); % left
plot([loc1_org(1)+width/2, loc1_org(1)+width/2],[ylim(1), height],'k', 'linewidth', 1); % right

% draw right bar frame
plot([loc2_org(1)-width/2, loc2_org(1)+width/2], [height, height], 'k', 'linewidth', 1); % top
plot([loc2_org(1)-width/2, loc2_org(1)-width/2], [ylim(1), height], 'k', 'linewidth', 1); % left
plot([loc2_org(1)+width/2, loc2_org(1)+width/2], [ylim(1), height], 'k', 'linewidth', 1); % right

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% draw target line
% option 1 : +20%, 2 : +10%, 3 : foot center, 4 : -10%, 5 : -20%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
target_value = drawTargetLine(width, option, foot_size, foot_center, loc1_org, loc2_org);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% trigger to start measuring data
% when the button clicked, start stacking data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
global start_trigger;
start_trigger = false;

% Create a start button
hButton = uicontrol('Style', 'pushbutton', 'String', 'Start', ...
                    'Units', 'normalized', 'Position', [0.1, 0.8, 0.06, 0.06],  ...
                    'FontSize', 13, 'Callback', @startCallback);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% COP data list for variability graph
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
cop_array = cell(1,2);
i = 1;

% Real time loop
while ishandle(figureHandle)
    %use event function to avoid crash
    try
        event = QCM('event');
        % ### Fetch data from QTM
        [frameinfo,force] = QCM;
        
        % get COP Z from plate 1,2
        COP1Z = (force{2,1}(1,7)); % right
        COP2Z = (force{2,2}(1,7)); % left

        COP_net = calc_COP_net(COP2Z, COP1Z, (force{2,2}(1,3)), (force{2,1}(1,3)));
        
        % Update each bar
        %set(plot_bar1,'xdata',[loc1_org(1), loc1_org(1)],'ydata',[ylim(1), -COP1Z])
        %set(plot_bar2,'xdata',[loc2_org(1), loc2_org(1)],'ydata',[ylim(1), -COP2Z])
        set(plot_bar3,'xdata',[centerpoint(1), centerpoint(1)],'ydata',[ylim(1), -COP_net])
        
        
        if start_trigger == true
            % append cop to cop_list        
            cop_array{1,1}{i} = -COP1Z;
            cop_array{1,2}{i} = -COP2Z;
            i = i + 1;
        end

        % update the figure
        drawnow;
    catch exception
        disp(exception.message);
        break
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% draw graph
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for i=1:2
    % convert cell format to mat
    cop_data = cell2mat(cop_array{1,i});
    
    % to measure some value, get size of cop data, n : stacked cop data
    [~, n] = size(cop_data);

    subplot(2,1,i);
    set(gcf, 'Units', 'Normalized', 'OuterPosition', [0, 0.04, 1, 0.96]);
    
    hold on;
    
    title(sprintf('Percent Difference from Target Value %.i plate (%s)', i, option), 'FontSize', 20);
    xlabel('Time ', 'FontSize', 15);
    ylabel('Difference ', 'FontSize', 15);
    grid on;
    
    % plot cop data
    plot((1: n), cop_data, 'black');
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% calculate RMSE(Root Mean Sqaure Error)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    text_position_x = round(n / 2);
    switch option
        case {"상위 20%", "상위 10%"}
            upper_rmse = sqrt(sum((cop_data - target_value).^2) / n);
            disp(['Upper Mean Percent Difference: ', num2str(upper_rmse), '%']);
            plot([1 n], [target_value target_value], ...
                'black','LineWidth', 1, 'LineStyle','--');

            % 상단 평균 퍼센트 차이 텍스트 추가
            upper_text_position_y = target_value-10;
            text(text_position_x, upper_text_position_y, ['RMSE: ', num2str(upper_rmse), '%'], ...
                'FontSize', 15, 'HorizontalAlignment', 'center', 'Color', 'red');   

        case '센터'
            center_rmse = sqrt(sum((cop_data - foot_center).^2) / n);
            disp(['Center Mean Percent Difference: ', num2str(center_rmse), '%']);
            plot([1 n], [foot_center foot_center], ...
                'black','LineWidth', 1, 'LineStyle','--');
            % 센터 평균 퍼센트 차이 텍스트 추가
            center_text_position_y = foot_center+10;
            text(text_position_x, center_text_position_y, ['RMSE: ', num2str(center_rmse), '%'], ...
                'FontSize', 15, 'HorizontalAlignment', 'center', 'Color', 'black');

        case {"하위 20%", "하위 10%"}
            lower_rmse = sqrt(sum((cop_data - target_value).^2) / n);
            disp(['Lower Mean Percent Difference: ', num2str(lower_rmse), '%']);
            plot([1 n], [target_value target_value], ...
                'black','LineWidth', 1, 'LineStyle','--');

            % 하단 평균 퍼센트 차이 텍스트 추가
            lower_text_position_y = target_value+10;
            text(text_position_x, lower_text_position_y, ['RMSE: ', num2str(lower_rmse), '%'], ...
                'FontSize', 15, 'HorizontalAlignment', 'center', 'Color', 'blue');

    end
end

QCM('disconnect');
clear mex

function target_value = drawTargetLine(width, option, foot_size, foot_center, loc1_org, loc2_org)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % draw target line
    %% option 1 : +20%, 2 : +10%, 3 : foot center, 4 : -10%, 5 : -20%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    p10_line_value = foot_size * 0.1;
    p20_line_value = foot_size * 0.2;
    switch option
        case '하위 20%'
            target_value = foot_center - p20_line_value;
            % horizontal p20_under_line
            plot([loc1_org(1)-width/2 loc2_org(1)+width/2], [target_value, target_value], 'black','LineWidth', 10);
            text(loc1_org(1) - width/2 - 100, foot_center - p20_line_value, '하위 20%','fontsize', 20);

        case '하위 10%'
            target_value = foot_center - p10_line_value;
            % horizontal p10_under_line
            plot([loc1_org(1)-width/2 loc2_org(1)+width/2], [target_value, target_value], 'black','LineWidth', 10);
            text(loc1_org(1) - width/2 - 100, target_value, '하위 10%','fontsize', 20);        

        case '상위 20%'
            target_value = foot_center + p20_line_value;
            % horizontal p20_upper_line
            plot([loc1_org(1)-width/2 loc2_org(1)+width/2], [target_value, target_value], 'black','LineWidth', 10);
            text(loc1_org(1) - width/2 - 100, foot_center + p20_line_value, '상위 20%','fontsize', 20);

        case '상위 10%'
            target_value = foot_center + p10_line_value;
            % horizontal p10_upper_line
            plot([loc1_org(1)-width/2 loc2_org(1)+width/2], [target_value, target_value], 'black','LineWidth', 10);
            text(loc1_org(1) - width/2 - 100, target_value, '상위 10%','fontsize', 20);
        
        case '센터'
            % center horizontal line
            target_value = foot_center;
            plot([loc1_org(1) - width/2, loc2_org(1) + width/2], [foot_center, foot_center], 'black', 'LineWidth', 10);
            text(loc1_org(1) - width/2 - 150, foot_center, 'Foot Center', 'fontsize', 20);
    end
end

function startCallback(~, ~)
    global start_trigger;
    start_trigger = true;
end