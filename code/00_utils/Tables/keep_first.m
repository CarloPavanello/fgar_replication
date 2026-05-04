function output = keep_first(prettyTypes)

    %   KEEP_FIRST Keep only the first occurrence of each string.
    %   The function returns the input string array with repeated entries
    %   replaced by empty strings, while preserving the first occurrence of each
    %   distinct value.
    %
    %   Input:
    %       prettyTypes  String array of type labels
    %
    %   Output:
    %       output       String array with duplicate entries replaced by ""
    
    %% function
    
    % Initialize output as a copy of input
    output = prettyTypes;

    % Keep track of seen type strings
    seen = strings(0,1);

    for i = 1:numel(prettyTypes)
        if any(prettyTypes(i) == seen)
            % Already seen → blank it out
            output(i) = "";
        else
            % First time → keep it and mark as seen
            seen(end+1) = prettyTypes(i);
        end
    end
end
