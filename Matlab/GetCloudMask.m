function [ cloudMask ] = GetCloudMask( masks )
    count=length(masks);
    [row,col]=size(masks{1});
        
% ************ Cloud Conservative *************** %
    cloudMask=zeros(row,col);
    for i=1:1
        cloudMask=masks{i}|cloudMask;
    end
end

