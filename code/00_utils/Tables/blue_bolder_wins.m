function s = blue_bolder_wins(val, isBold)

    %   BLUE_BOLDER_WINS Format win counts for LaTeX output.
    %   The function formats an integer value. If isBold is true, the value is
    %   wrapped in LaTeX commands for bold text and the theme emphasis color.
    %
    %   Inputs:
    %       val     Integer value to format
    %       isBold  Indicator for bold colored formatting
    %
    %   Output:
    %       s       Formatted LaTeX string
    
    %% function
    
    if isBold
        s = sprintf('\\textbf{\\textcolor{athemeemph}{%d}}', val);
    else
        s = sprintf('%d', val);
    end
end