% This function is used to produce the gray histogram of specific image
% block. The result has two rows: 1) frequency and 2) DN referring to the
% frequency.

function [ histogram ] = GetHistogram( imageBlock )
    [row,col]=size(imageBlock);
    array=reshape(imageBlock,1,row*col);
    
    % Remove the error.
    array(array==0)=[];
    maxValue=max(array);
    minValue=min(array);

    histogram=ones(2,maxValue-minValue+1);
    histogram(1,:)=histc(array(1,:),minValue:maxValue);
    histogram(2,:)=minValue:maxValue;
end

