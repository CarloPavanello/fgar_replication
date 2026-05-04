function s = bolder_gains(val, isBold)

    %   BOLDER_GAINS Format tick-loss gains for LaTeX output.
    %   The function formats a numeric value with one decimal place. If isBold
    %   is true, the value is wrapped in a LaTeX bold command.
    %
    %   Inputs:
    %       val     Numeric value to format
    %       isBold  Indicator for bold formatting
    %
    %   Output:
    %       s       Formatted LaTeX string

    %% function
    
    if isBold
        s = sprintf('\\textbf{%0.1f}', val);
    else
        s = sprintf('%0.1f', val);
    end
end
