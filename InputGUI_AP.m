function [paramter, option] = InputGUI_AP
    % Initialize output variables
    paramter = '';
    option = '';

    sentence = {'Input the foot size (mm) : ', 'Input the option (1,2,3,4,5) : '};

    
    % Create a figure for the GUI
    fig_size = [500, length(sentence) * 150];
    fig = figure('Position', [500, 500, fig_size(1), fig_size(2)], 'MenuBar', 'none', 'Name', 'Dual Input GUI', 'NumberTitle', 'off', 'Resize', 'off', 'CloseRequestFcn', @closeCallback);

    % Create the first input label and text box
    text_pos = fig.Position(1) * 0.1; % 50;
    box_pos = fig.Position(1) * 0.6; % 300;
    text_width = 250;
    box_width = 100;
    height = 30;
    uicontrol('Style', 'text', 'Position', [text_pos, 220, text_width, height], 'String', sentence{1}, 'HorizontalAlignment', 'left', 'FontSize', 14);
    paramter_Box = uicontrol('Style', 'edit', 'Position', [box_pos, 220, box_width, height], 'FontSize', 14);

    % Create the second input label and text box
    uicontrol('Style', 'text', 'Position', [text_pos, 160, text_width, height], 'String', sentence{2}, 'HorizontalAlignment', 'left', 'FontSize', 14);
    option_Box = uicontrol('Style', 'edit', 'Position', [box_pos, 160, box_width, height], 'FontSize', 14);

    % Create a submit button
    uicontrol('Style', 'pushbutton', 'Position', [fig.Position(1) * 0.4, 50, 100, 40], 'String', 'Submit', 'FontSize', 14, 'Callback', @submitCallback);

    uicontrol('Style', 'text', 'Position', [50, 20, 100, 100], 'FontSize', 12, 'HorizontalAlignment','left', ...
                'String', {'1: +20%', '2: +10%', '3: 0%(center)', '4: -10%', '5: -20%'});

    % Store initial data in the figure's UserData property
    data.paramter = '';
    data.option = '';
    set(fig, 'UserData', data);

    % Wait for the user to close the figure
    uiwait(fig);

    % Check if the figure still exists before retrieving data
    if isvalid(fig)
        data = get(fig, 'UserData');
        paramter = data.paramter;
        option = data.option;
        delete(fig);
    else
        disp('Figure was closed before data could be retrieved.');
    end

    % Callback function for the submit button
    function submitCallback(~, ~)
        paramter = str2double(get(paramter_Box, 'String'));
        option = get(option_Box, 'String');
                
        
        % Store the inputs in the figure's UserData property
        data.paramter = paramter;
        data.option = option;
        set(fig, 'UserData', data);

        % Resume the GUI
        uiresume(fig);
    end

    % Callback function for closing the figure
    function closeCallback(~, ~)
        % Resume the GUI
        uiresume(fig);
        % Delete the figure
        delete(fig);
    end

    disp(paramter);
    disp(option);
end
