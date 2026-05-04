function [prettyFactors, prettyTypes] = categorize_factors(specs)

    %   CATEGORIZE_FACTORS Convert factor specifications into display labels.
    %   The function maps factor specification strings to readable factor names
    %   and factor-type categories.
    %
    %   Factor names are created by replacing underscores with " + ". Factor
    %   types are assigned using a predefined token-to-category mapping, repeated
    %   categories are removed, and the remaining categories are ordered as
    %   Bench, Macro, Fin, Stat, and Text.
    %
    %   Input:
    %       specs          String array of factor specifications
    %
    %   Outputs:
    %       prettyFactors  Readable factor labels
    %       prettyTypes    Ordered factor-type labels

    %% function

    % ---- mapping: token -> type ----
    types = struct( ...
        'HIST','Bench','AR1','Bench', ...
        'MUNC','Macro','HPI','Macro','CTG','Macro', ...
        'EBP','Fin','CISS','Fin','FUNC','Fin','NFCI','Fin','VIX','Fin', ...
        'GPR','Text','WUI','Text','PRISK','Text','NPRISK','Text','RISK','Text','EPU','Text', ...
        'PC1','Stat','QF1','Stat','PCF1','Stat','PC2','Stat','QF2','Stat','PCF2','Stat', ...
        'PC3','Stat','QF3','Stat','PCF3','Stat' ...
    );

    typeOrder = {'Bench','Macro','Fin','Stat','Text'};  % desired global order

    % normalize to column vector
    specs = specs(:);

    n = numel(specs);
    prettyFactors = strings(n,1);
    prettyTypes   = strings(n,1);

    for i = 1:n
        s = specs(i);

        % 1) Pretty factor names: replace "_" with " + "
        tokens = split(s, "_");           % string array of tokens
        prettyFactors(i) = strjoin(tokens, " + ");

        % 2) Map tokens -> types (error if unknown)
        mapped = cell(1,numel(tokens));
        for k = 1:numel(tokens)
            key = char(tokens(k));
            if ~isfield(types, key)
                error('Unknown factor: "%s"', key);
            end
            mapped{k} = types.(key);
        end

        % remove repeated categories while preserving first appearance
        mapped_unique = unique(mapped, 'stable');

        % enforce global order using intersect with 'stable' on typeOrder
        ordered = intersect(typeOrder, mapped_unique, 'stable');

        prettyTypes(i) = strjoin(string(ordered), " + ");
    end
end
