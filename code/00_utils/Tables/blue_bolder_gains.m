function s = blue_bolder_gains(val, isBold)

    %   BLUE_BOLDER_GAINS Format tick-loss gains for LaTeX output.
    %   The function formats a numeric value with one decimal place. If isBold
    %   is true, the value is wrapped in LaTeX commands for bold text and the
    %   theme emphasis color.
    %
    %   Inputs:
    %       val     Numeric value to format
    %       isBold  Indicator for bold colored formatting
    %
    %   Output:
    %       s       Formatted LaTeX string
    
    %% function
    
    if isBold
        s = sprintf('\\textbf{\\textcolor{athemeemph}{%0.1f}}', val);
    else
        s = sprintf('%0.1f', val);
    end
end