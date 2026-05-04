function [Result, combos] = columnCombinationsStack(X, k)

    %   COLUMNCOMBINATIONSSTACK Stack all k-column combinations across slices.
    %   [Result, combos] = columnCombinationsStack(X, k) returns all unordered
    %   k-combinations of the columns of X, where X is an nRows x nCols x nSlices
    %   array.
    %
    %   For each combination, the selected columns are stacked by column first
    %   and by slice second. For example, if nSlices = 5 and the selected
    %   combination is [3 7], then the output block contains column 3 from
    %   slices 1,...,5 followed by column 7 from slices 1,...,5.
    %
    %   Inputs:
    %       X       nRows x nCols x nSlices numeric array
    %       k       Number of columns in each combination
    %
    %   Outputs:
    %       Result  nRows x nCombos x (k*nSlices) array containing the stacked
    %               columns for each k-combination
    %       combos  nCombos x k matrix containing the column indices used in
    %               each combination
    
    %% function

    arguments
        X {mustBeNumeric, mustBeNonempty}
        k (1,1) {mustBeInteger, mustBePositive}
    end

    [nRows, nCols, nSlices] = size(X);
    if k > nCols
        error('k must be <= number of columns in X.');
    end

    % All unordered k-combinations of columns
    combos = nchoosek(1:nCols, k);
    nCombos = size(combos, 1);

    % Preallocate, preserving X's type/storage (double, single, gpuArray, etc.)
    Result = zeros(nRows, nCombos, k*nSlices, 'like', X);

    for c = 1:nCombos
        cols = combos(c, :);         % chosen column indices [i j ...]
        block = X(:, cols, :);       % nRows x k x nSlices

        % Reorder to: nRows x nSlices x k, so we group by column, then slices
        block = permute(block, [1 3 2]);

        % Flatten the last two dims: nRows x (k*nSlices)
        block2D = reshape(block, nRows, []);

        % Store as the c-th combo
        Result(:, c, :) = block2D;
    end
end