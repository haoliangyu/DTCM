% This function is used to retrive the raw band from images.

function [ dataCollection ] = GetData( imageAPath, imageBPath )
    dataA=double(imread(imageAPath));
    dataB=double(imread(imageBPath));
    data=cell(10,1);                                                       % Create the dataset to be analyzed
                                                                           % with bands below:
    data{1}=dataA(:,:,1);                                                  % Band 1
    data{2}=dataA(:,:,2);                                                  % Band 2
    data{3}=dataB(:,:,1);                                                  % Band 3
    data{4}=dataB(:,:,2);                                                  % Band 4
    data{5}=dataB(:,:,3);                                                  % Band 5
    data{6}=dataA(:,:,3);                                                  % Band 6
    data{7}=dataA(:,:,7);                                                  % Band 10
    data{10}=dataB(:,:,3)-dataB(:,:,2);                                    % Band 5-4
    data{9}=dataB(:,:,1)-dataB(:,:,2);                                     % Band 3-4
    data{8}=dataB(:,:,1)-dataB(:,:,3);                                     % Band 3-5    
    
    % The ratio data is currently unavailable.
    % data(:,:,11)=dataA(:,:,2)./dataA(:,:,1);                             % Band 2/1
    % data(:,:,11)=round(data(:,:,11)*100);
    
    % NDWI mask, a water mask to remove the water body on image because
    % DTCM is originally designed for land image and it indeed does not
    % function well at sea image.
    band9=dataA(:,:,6);
    waterMask=(band9-data{2})./(band9+data{2});
    waterMask(waterMask<0.37|isnan(waterMask)|isinf(waterMask))=0;
    waterMask(waterMask~=0)=1;
    
    % NDVI mask, a vegetation mask to remove regetated area. It is
    % especially for the near infared band, at which the reflectance of
    % vegetation may be close to that of cloud.
    vMask=(data{2}-data{1})./(data{2}+data{1});
    vMask(vMask<0.3|isnan(vMask)|isinf(vMask))=0;
    vMask(vMask~=0)=1;
    
    for i=1:10
        temp=data{i};
        temp(temp<0|temp>10000)=0;
        data{i}=temp;
    end
    
    dataCollection{1}=data;
    dataCollection{2}=vMask|waterMask;
end

