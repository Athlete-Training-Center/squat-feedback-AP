function optionStr = convertOption(option)
    switch option
        case 1
            optionStr = '상위 15%';
        case 2
            optionStr = '센터';
        case 3
            optionStr = '하위 15%';
        otherwise
            error('Invalid option value');
    end
end
