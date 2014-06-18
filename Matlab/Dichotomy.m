% Use dichotomy to determine the threshold of imageBlock

function [ threshold ] = Dichotomy( imageBlock, preMean )
    separationA=imageBlock>preMean;
    separationB=imageBlock<=preMean;
    blockA=imageBlock.*separationA;
    blockB=imageBlock.*separationB;
    mA=sum(blockA(:))/sum(separationA(:));
    mB=sum(blockB(:))/sum(separationB(:));
    mean=(mA+mB)/2;

    if(abs(mean-preMean)/preMean<0.1)
        threshold=mean;
    else
        threshold=Dichotomy(imageBlock,mean);
    end
end

