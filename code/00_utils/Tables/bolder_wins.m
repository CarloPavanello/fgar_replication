function s = bolder_wins(val, isBold)

    %   BOLDER_WINS Format win counts for LaTeX output.
    %   The function formats an integer value. If isBold is true, the value is
    %   wrapped in a LaTeX bold command.
    %
    %   Inputs:
    %       val     Integer value to format
    %       isBold  Indicator for bold formatting
    %
    %   Output:
    %       s       Formatted LaTeX string

    %% function
    
    if isBold
        s = sprintf('\\textbf{%d}', val);
    else
        s = sprintf('%d', val);
    end
end
