function optionStr = convertOption(option)
    switch option
        case "1"
            optionStr = '하위 20%';
        case "2"
            optionStr = '상위 20%';
        case "3"
            optionStr = '센터';
        otherwise
            error('Invalid option value');
    end
end