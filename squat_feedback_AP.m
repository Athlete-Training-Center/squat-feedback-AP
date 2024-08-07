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
%% foot size is must 200~350
%% option 은 어떤 테스트를 할 것인지 1) 상위 20%, 2) 하위 20%, 3) 발 센터
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[foot_size, option] = MultiInputGUI("AP");
option = convertOption(option);

% Connect to QTM
ip = '127.0.0.1';
% Connects to QTM and keeps the connection alive.
QCM('connect', ip, 'frameinfo', 'force');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% figure setting
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Create a figure window
figureHandle = figure(1);
hold on
% set the figure size
set(gcf, 'Units', 'Normalized', 'OuterPosition', [0, 0.04, 1, 0.96]);
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
ylim=[-200 200]; %%%% TODO: 범위를 -200~200으로 할지 0~400으로 변환할지

% center coordinate for figure size
centerpoint = [(xlim(1) + xlim(2)) / 2, (ylim(1) + ylim(2)) / 2];

% Start the graph from the bottom to the top 70mm (force plate 끝~나사부분 길이 = 70mm)
start_valuey = 70; % 70mm

% set initial coordinate at 70mm from end point of force plate
ylim = [ylim(1) + start_valuey, ylim(2)];

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
% draw outlines
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% draw frame of figure like force plate
plot([0 0],get(gca,'ylim'),'k', 'linewidth',3)
plot([xlim(2) xlim(2)],get(gca,'ylim'),'k', 'linewidth',3)
plot([centerpoint(1) centerpoint(1)],get(gca,'ylim'),'k', 'linewidth',3)
plot(get(gca,'xlim'),[ylim(2) ylim(2)],'k', 'linewidth',3)
plot(get(gca,'xlim'),[ylim(1) ylim(1)],'k', 'linewidth',3)
title('Left                                                            Right','fontsize',30)

% make handles for each bar to update vGRF and AP COP data
plot_bar1 = plot([loc1_org(1)-width/2, loc1_org(1)-width/2], [ylim(1), foot_center], 'LineWidth', 90, 'Color', 'red');
plot_bar2 = plot([loc2_org(1)+width/2, loc2_org(1)+width/2], [ylim(1), foot_center], 'LineWidth', 90, 'Color', 'blue');

% draw left bar frame
plot([loc1_org(1)-width/2, loc1_org(1)+width/2],[height, height],'k', 'linewidth', 1) % top
plot([loc1_org(1)-width/2, loc1_org(1)-width/2],[ylim(1), height],'k', 'linewidth', 1); % left
plot([loc1_org(1)+width/2, loc1_org(1)+width/2],[ylim(1), height],'k', 'linewidth', 1); % right

% draw right bar frame
plot([loc2_org(1)-width/2, loc2_org(1)+width/2], [height, height], 'k', 'linewidth', 1); % top
plot([loc2_org(1)-width/2, loc2_org(1)-width/2], [ylim(1), height], 'k', 'linewidth', 1); % left
plot([loc2_org(1)+width/2, loc2_org(1)+width/2], [ylim(1), height], 'k', 'linewidth', 1); % right

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% draw target line
%% option 1 : -20%, 2 : +20%, 3 : foot center 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
p20_line_value = foot_size * 0.2;
switch option
    case '하위 20%'
        lower_target_value = foot_center - p20_line_value;
        p20_under_lineh = plot([loc1_org(1)-width/2 loc2_org(1)+width/2], [lower_target_value, lower_target_value], 'black','LineWidth', 10);
        text(loc1_org(1) - width/2 - 100, foot_center - p20_line_value, '하위 20%','fontsize', 20);
    
    case '상위 20%'
        upper_target_value = foot_center + p20_line_value;
        p20_upper_lineh = plot([loc1_org(1)-width/2 loc2_org(1)+width/2], [upper_target_value, upper_target_value], 'black','LineWidth', 10);
        text(loc1_org(1) - width/2 - 100, foot_center + p20_line_value, '상위 20%','fontsize', 20);
    
    case '센터'
        plot([loc1_org(1) - width/2, loc2_org(1) + width/2], [foot_center, foot_center], 'black', 'LineWidth', 10);
        text(loc1_org(1) - width/2 - 150, foot_center, 'Foot Center', 'fontsize', 20);
end

% cop1_value = text(loc1_org(1)-width/2-50, centerpoint(2), num2str(0), 'FontSize', 30);
% cop2_value = text(loc2_org(1)+width/2+50, centerpoint(2), num2str(0), 'FontSize', 30);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% COP data list for variability graph
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
cop_list1 = [];
cop_list2 = [];

% Real time loop
while ishandle(figureHandle)
    %use event function to avoid crash
    try
        event = QCM('event');
        % ### Fetch data from QTM
        [frameinfo,force] = QCM;
        
        fig = get(groot, 'CurrentFigure');
        % error occurs when getting realtime grf data. Sometimes there is no data.
        if isempty(fig)
            break
        end
        if isempty(force{2,1}) || isempty(force{2,2})
            continue
        end
        
        % get GRF Z from plate 1,2
        GRF1 = abs(force{2,2}(1,3));
        GRF2 = abs(force{2,1}(1,3));
        
        % get COP Z from plate 1,2
        COP1Z = (force{2,2}(1,7));
        COP2Z = (force{2,1}(1,7));
        
        % Update each bar
        set(plot_bar1,'xdata',[loc1_org(1), loc1_org(1)],'ydata',[ylim(1), -COP1Z])
        set(plot_bar2,'xdata',[loc2_org(1), loc2_org(1)],'ydata',[ylim(1), -COP2Z])
        % set(cop1_value,'string', round(COP1Z, 1), 'Position', [loc1_org(1)-width/2-100, -COP1Z]);
        % set(cop2_value,'string', round(COP2Z, 1), 'Position', [loc2_org(1)+width/2+100, -COP2Z]);
        
        % append cop to cop_list
        cop_list1 = [cop_list1, -COP1Z];
        cop_list2 = [cop_list2, -COP2Z];
        
        % update the figure
        drawnow;
    catch exception
        disp(exception.message);
        break
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% noise filtering
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for i=1:2
    if i == 1
        cop_list = cop_list1;
    else
        cop_list = cop_list2;
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % remove unnecessary data
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    new_cop_list = [];
    start_collect = false;
    for j = 1:length(cop_list)
        if cop_list(j) > -5 || cop_list(j) < 5
            start_collect = true;
        end
    
        if start_collect
            new_cop_list = [new_cop_list, cop_list(j)];
        end
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % draw the graph
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   
    n = length(new_cop_list);

    [numRows, numCols] = size(new_cop_list);

    subplot(2,1,i);
    set(gcf, 'Units', 'Normalized', 'OuterPosition', [0, 0.04, 1, 0.96]);
    
    hold on;

    title(sprintf('Percent Difference from Target Value %.i plate (%s)', i, option), 'FontSize', 20);
    xlabel('Time ', 'FontSize', 15);
    ylabel('Difference ', 'FontSize', 15);
    grid on;
    
    plot((1: numCols), new_cop_list, 'black');
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % calculate RMSE(Root Mean Sqaure Error)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    text_position_x = round(numCols / 2);
    switch option
        case '하위 20%'
            lower_rmse = sqrt(sum((new_cop_list - lower_target_value).^2) / n);
            disp(['Lower Mean Percent Difference: ', num2str(lower_rmse), '%']);
            plot([1 numCols], [lower_target_value lower_target_value], ...
                'black','LineWidth', 1, 'LineStyle','--');

            % 하단 평균 퍼센트 차이 텍스트 추가
            lower_text_position_y = lower_target_value+10;
            text(text_position_x, lower_text_position_y, ['RMSE: ', num2str(lower_rmse), '%'], ...
                'FontSize', 15, 'HorizontalAlignment', 'center', 'Color', 'blue');

        case '상위 20%'
            upper_rmse = sqrt(sum((new_cop_list - upper_target_value).^2) / n);
            disp(['Upper Mean Percent Difference: ', num2str(upper_rmse), '%']);
            plot([1 numCols], [upper_target_value upper_target_value], ...
                'black','LineWidth', 1, 'LineStyle','--');

            % 상단 평균 퍼센트 차이 텍스트 추가
            upper_text_position_y = upper_target_value-10;
            text(text_position_x, upper_text_position_y, ['RMSE: ', num2str(upper_rmse), '%'], ...
                'FontSize', 15, 'HorizontalAlignment', 'center', 'Color', 'red');

        case '센터'
            center_rmse = sqrt(sum((new_cop_list - foot_center).^2) / n);
            disp(['Center Mean Percent Difference: ', num2str(center_rmse), '%']);
            plot([1 numCols], [foot_center foot_center], ...
                'black','LineWidth', 1, 'LineStyle','--');
            % 센터 평균 퍼센트 차이 텍스트 추가
            center_text_position_y = foot_center+10;
            text(text_position_x, center_text_position_y, ['RMSE: ', num2str(center_rmse), '%'], ...
                'FontSize', 15, 'HorizontalAlignment', 'center', 'Color', 'black');
    end
end

QCM('disconnect');
clear mex
