function Expanded = expandTriangular(InputMatrix)

    %   EXPANDTRIANGULAR Expand each column into an upper-triangular 3D structure.
    %   The function takes an nRows x nCols matrix and expands each column into
    %   an nRows x nRows upper-triangular matrix stored across the third
    %   dimension of the output array.
    %
    %   For each column of InputMatrix, row i is filled with InputMatrix(i,j)
    %   from the diagonal onward, while entries before the diagonal are set to
    %   NaN.
    %
    %   Input:
    %       InputMatrix  nRows x nCols numeric matrix
    %
    %   Output:
    %       Expanded     nRows x nCols x nRows array containing the triangular
    %                    expansion of each input column

    %% function
    
    [nRows, nCols] = size(InputMatrix);
    Expanded = NaN(nRows, nCols, nRows);   % preallocate output
    
    % Loop over each column of the input
    for colIdx = 1:nCols
        currentVector = InputMatrix(:,colIdx);   % take one column
        triangularMatrix = NaN(nRows, nRows);    % temporary n x n matrix
        
        % Fill the triangular structure
        for rowIdx = 1:nRows
            triangularMatrix(rowIdx, rowIdx:end) = currentVector(rowIdx);
        end
        
        % Assign each column of the triangularMatrix into the 3rd dimension
        for sliceIdx = 1:nRows
            Expanded(:, colIdx, sliceIdx) = triangularMatrix(:, sliceIdx);
        end
    end
end