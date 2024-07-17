function [foot_size, option] = dualInputGUI
    % Initialize output variables
    foot_size = '';
    option = '';

    % Create a figure for the GUI
    fig = figure('Position', [300, 300, 400, 200], 'MenuBar', 'none', 'Name', 'Dual Input GUI', 'NumberTitle', 'off', 'Resize', 'off', 'CloseRequestFcn', @closeCallback);

    % Create the first input label and text box
    uicontrol('Style', 'text', 'Position', [50, 140, 200, 30], 'String', 'Input the foot size (mm) : ', 'HorizontalAlignment', 'left', 'FontSize', 10);
    foot_size_Box = uicontrol('Style', 'edit', 'Position', [250, 140, 100, 30], 'FontSize', 10);

    % Create the second input label and text box
    uicontrol('Style', 'text', 'Position', [50, 80, 200, 30], 'String', 'Input the option (1,2,3) : ', 'HorizontalAlignment', 'left', 'FontSize', 10);
    option_Box = uicontrol('Style', 'edit', 'Position', [250, 80, 100, 30], 'FontSize', 10);

    % Create a submit button
    uicontrol('Style', 'pushbutton', 'Position', [150, 20, 100, 40], 'String', 'Submit', 'FontSize', 10, 'Callback', @submitCallback);

    % Store initial data in the figure's UserData property
    data.foot_size = '';
    data.option = '';
    set(fig, 'UserData', data);

    % Wait for the user to close the figure
    uiwait(fig);

    % Check if the figure still exists before retrieving data
    if isvalid(fig)
        data = get(fig, 'UserData');
        foot_size = data.foot_size;
        option = data.option;
        delete(fig);
    else
        disp('Figure was closed before data could be retrieved.');
    end

    % Callback function for the submit button
    function submitCallback(~, ~)
        foot_size = str2double(get(foot_size_Box, 'String'));
        option = str2double(get(option_Box, 'String'));
        
        % Check the input values
        if isnan(foot_size) || foot_size < 200 || foot_size > 350
            errordlg('Bad size! Foot size must be between 200 and 350 mm.', 'Input Error');
            return;
        end
        
        if isnan(option) || ~ismember(option, [1, 2, 3])
            errordlg('Option must be 1, 2, or 3.', 'Input Error');
            return;
        end

        % Store the inputs in the figure's UserData property
        data.foot_size = foot_size;
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

    disp(foot_size);
    disp(option);
end
