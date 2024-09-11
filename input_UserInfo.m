function [UserInfo, err] = input_UserInfo()
    err = '';
    fig = figure('Position', [300, 300, 400, 200], 'MenuBar','none', 'Name', ...
        'InterFace for Input User Information', 'NumberTitle','off', 'Resize','off', ...
        'CloseRequestFcn',@closeCallback);
    % Number, Name, foot size, height, weight
    % Create input label and text bot
    uicontrol('Style','text', 'Position', [50, 120, 200, 30], 'String', ...
        'User Number', 'HorizontalAlignment', 'left', 'FontSize',10);
    UserNumber_box = uicontrol('Style', 'edit', 'Position', [250, 120, 100, 30], 'FontSize',10);
    
    % Create a submit button
    uicontrol('Style', 'pushbutton', 'Position', [150, 20, 100, 40], 'String', ...
       'Submit', 'FontSize',10, 'Callback', @submitCallback);

    data.UserNumber = '';
    set(fig, 'UserData', data);

    uiwait(fig);

    % if date input, save that in variables
    if isvalid(fig)
        data = get(fig, 'UserData');
        UserNumber = data.UserNumber;
        delete(fig);
    else
        disp('Figure was closed before data could be retrieved')
    end

    UserInfo = struct("UserNumber", UserNumber, "Name", "", "Height", 0, "Weight", 0, "FootSize", 0);

    % Callback function for the submit button
    function submitCallback(~, ~)
        UserNumber = get(UserNumber_box, 'String');

        % store the inputs in the figure's UserData property
        data.UserNumber = UserNumber;
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

        err = 'figure close';
    end        
end