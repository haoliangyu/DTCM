function [ intervalL,intervalS ] = GetHistInterval( imageNo )
    if(imageNo<8)
        intervalL=28;
        intervalS=10;
    elseif(imageNo<10)
        intervalL=10;
        intervalS=14;
    else
        intervalL=12;
        intervalS=8;
    end
end

% Ê¹ÓÃ·ÑÅäÖÃ
% 1.cloudAccuracy:0.92827 landAccuracy:0.94001
%     if(imageNo<8)
%         intervalL=28;
%         intervalS=10;
%     elseif(imageNo<10)
%         intervalL=25;
%         intervalS=16;
%     else
%         intervalL=12;
%         intervalS=8;
%     end