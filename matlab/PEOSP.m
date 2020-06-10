%% 讀取物符合名稱的資訊(檔名路徑)
addpath('D:\杏鮑菇\1030')
w(:,1)=dir('D:\杏鮑菇\1030\*LED1.png');
w(:,2)=dir('D:\杏鮑菇\1030\*LED2.png');
w(:,3)=dir('D:\杏鮑菇\1030\*LED3.png');
w(:,4)=dir('D:\杏鮑菇\1030\*LED4.png');
w(:,5)=dir('D:\杏鮑菇\1030\*LED5.png');
w(:,6)=dir('D:\杏鮑菇\1030\*LED6.png');
%% 將檔案imread至LED
% LED(i,            30,         480,  640,  3)
% LED(i=第幾個檔案  ,j=哪個LED , X軸 , Y軸 , k RGB)
for i=1:30
    for j=1:6
        LED(i,j,:,:,:)=imread(w(i,j).name);
    end
end
%% 白校正
addpath('D:\杏鮑菇\white');
wdir1=dir('D:\杏鮑菇\white\*LED1.png');
wdir2=dir('D:\杏鮑菇\white\*LED2.png');
wdir3=dir('D:\杏鮑菇\white\*LED3.png');
wdir4=dir('D:\杏鮑菇\white\*LED4.png');
wdir5=dir('D:\杏鮑菇\white\*LED5.png');
wdir6=dir('D:\杏鮑菇\white\*LED6.png');
white(1,:,:,:)=imread(wdir1(1).name);
white(2,:,:,:)=imread(wdir2(1).name);
white(3,:,:,:)=imread(wdir3(1).name);
white(4,:,:,:)=imread(wdir4(1).name);
white(5,:,:,:)=imread(wdir5(1).name);
white(6,:,:,:)=imread(wdir6(1).name);
%% dark 黑校正
dark40=imread('20191122_085241_dark_40.png');
dark30=imread('20191122_085242_dark_30.png');
dark100=imread('20191122_085242_dark_100.png');

%% mask
mask=zeros(480,640);
for i=1:480
    for j=1:640
        if ((i-200)^2+(j-320)^2)<35000
            mask(i,j)=1;
        end
    end
end
imshow(mask)
%% Reflectivity
for i=1:30
    reflect(i,1,:,:,:)=(double(squeeze(LED(i,1,:,:,:))-dark40)./...
                       double(squeeze(white(1,:,:,:))-dark40).*mask);
    reflect(i,2,:,:,:)=(double(squeeze(LED(i,2,:,:,:))-dark30)./...
                       double(squeeze(white(2,:,:,:))-dark30).*mask);
    reflect(i,3,:,:,:)=(double(squeeze(LED(i,3,:,:,:))-dark30)./...
                       double(squeeze(white(3,:,:,:))-dark30).*mask);
    reflect(i,4,:,:,:)=(double(squeeze(LED(i,4,:,:,:))-dark30)./...
                       double(squeeze(white(4,:,:,:))-dark30).*mask);
    reflect(i,5,:,:,:)=(double(squeeze(LED(i,5,:,:,:))-dark30)./...
                       double(squeeze(white(5,:,:,:))-dark30).*mask);
    reflect(i,6,:,:,:)=(double(squeeze(LED(i,6,:,:,:))-dark100)./...
                       double(squeeze(white(6,:,:,:))-dark100).*mask);
end
%% 顯示
for i=1
    for j=1:6
        for k=1:3
            figure(2)
            subplot(5,6,6+6*(k-1)+j)
            imshow(squeeze(reflect(i,j,:,:,k)))
            impixelinfo
            title({string(w(i,j).name), 'GP'+string(i)+ '  LED:'+string(j)+'  RGB '+string(k)})
        end
            subplot(5,6,24+j)
            imshow(squeeze(reflect(i,j,:,:,:)))
            subplot(5,6,j)
            imshow(squeeze(LED(i,j,:,:,:)))
    end
end
%% 自訂光譜組合(有些光譜有很多Nan Inf、全白或全黑 不適合做OSP)
LEDMIX(:,1,:,:)=squeeze(reflect(:,1,:,:,1));
LEDMIX(:,2,:,:)=squeeze(reflect(:,2,:,:,1));
LEDMIX(:,3,:,:)=squeeze(reflect(:,3,:,:,1));
LEDMIX(:,4,:,:)=squeeze(reflect(:,3,:,:,2));
LEDMIX(:,5,:,:)=squeeze(reflect(:,4,:,:,1));
LEDMIX(:,6,:,:)=squeeze(reflect(:,4,:,:,2));
LEDMIX(:,7,:,:)=squeeze(reflect(:,4,:,:,3));
LEDMIX(:,8,:,:)=squeeze(reflect(:,5,:,:,1));
LEDMIX(:,9,:,:)=squeeze(reflect(:,5,:,:,2));
LEDMIX(:,10,:,:)=squeeze(reflect(:,5,:,:,3));
LEDMIX(:,11,:,:)=squeeze(reflect(:,6,:,:,1));
LEDMIX(:,12,:,:)=squeeze(reflect(:,6,:,:,2));
LEDMIX(:,13,:,:)=squeeze(reflect(:,6,:,:,3));
%% 顯示組合成高光譜影像的結果
for j=1:13
    figure(1)
    subplot(3,6,j)
    imshow(squeeze(LEDMIX(1,j,:,:)))
    title('band'+string(j))
    impixelinfo
end
%% 將數值為NAN的值設為0 才能進行OSP運算
LEDMIX(find(isnan(LEDMIX)))=0;
%% 將數值為INF的值設為0 才能進行OSP運算
LEDMIX(find(isinf(LEDMIX)))=0;
%%  OSP
addpath('D:\杏鮑菇');
u1=reshape(LEDMIX(1,:,177,170),13,1);
u2=reshape(LEDMIX(1,:,89,265),13,1);
u3=reshape(LEDMIX(1,:,86,285),13,1);
u=cat(2,u1);
for i=1:30
    [band,x,y]=size(squeeze(LEDMIX(i,:,:,:)));
    cubearr=reshape(squeeze(LEDMIX(i,:,:,:)),band,x*y);
    out=OSPFX(cubearr, u);
    image(i,:,:)=reshape(out,480,640);
    imagebi(i,:,:)=image(i,:,:)>0.5;
end
%% 查看某組資料OSP與設定Mask
subplot(1,2,1)
imshow(squeeze(image(1,:,:)))
title('OSP')
subplot(1,2,2)
imshow(squeeze(imagebi(1,:,:)));
title('MASK')
impixelinfo
%cubeafterosp=cube.*s;
%% 將混合光譜經過OSP MASK
for i=1:30
    for j=1:13
        LEDMIXAF(i,j,:,:)=squeeze(LEDMIX(i,j,:,:)).*squeeze(imagebi(i,:,:));
    end
end
%% 顯示經過OSP與MASK過後的光譜組合
for j=1:13
    figure(1)
    subplot(3,6,j)
    imshow(squeeze(LEDMIXAF(1,j,:,:)))
    title('band'+string(j))
    impixelinfo
end
