% To divide the image into subregions.

function [ blocks ] = GetImageBlock( image )
    [row,col]=size(image);

    % Vertically divide the image into four block, following the method of
    % FY-3 A/B VIRR.
    blockRow=row;
    blockCol=col*0.25;
    
    % covered matrix to cell
    blocks=mat2cell(image,ones(1,row/blockRow)*blockRow,ones(1,col/blockCol)...
        *blockCol);
end

