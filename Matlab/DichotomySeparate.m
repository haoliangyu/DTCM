% Use dichotomy to determine the threshold of imageBlock
% This has been examinated!

function [ threshold ] = DichotomySeparate( imageBlock )
    threshold=Dichotomy(imageBlock,mean(imageBlock(:)));
end

