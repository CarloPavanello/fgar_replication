function s = checkmark(x)

    %   CHECKMARK Convert a binary indicator to a LaTeX symbol.
    %   The function converts 1 to a LaTeX checkmark and 0 to a LaTeX times
    %   symbol. An error is returned for any other input value.
    %
    %   Input:
    %       x   Binary indicator equal to 0 or 1
    %
    %   Output:
    %       s   LaTeX symbol string

    %% function 
    
    if x == 1
        s = '$\checkmark$';
    elseif x == 0
        s = '$\times$';
    else
        error('Input must be 0 or 1');
    end
end