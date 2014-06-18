function [ cloudAccuracy, landAccuracy ] = GetAccuracy( cloudMask, CTMProduct )
    [row,col]=size(cloudMask);
    map=cloudMask&CTMProduct;
    cloudAccuracy=sum(map(:))/sum(CTMProduct(:));
    map=~cloudMask&~CTMProduct;
    landAccuracy=sum(map(:))/sum(reshape(~CTMProduct,row*col,1));
end

