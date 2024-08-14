function optionStr = convertOption(option)
    switch option
        case "1"
            optionStr = '상위 20%';
        case "2"
            optionStr = '상위 10%';
        case "3"
            optionStr = '센터';
        case "4"
            optionStr = '하위 10%';
        case "5"
            optionStr = '하위 20%';
        otherwise
            error('Invalid option value');
    end
end