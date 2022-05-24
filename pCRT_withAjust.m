% CRT test analysis
% Updated 20-11-2020 10h30'
% Raquel Pantojo de Souza- USP-SP


clear 
clc
close all

% Usar Funções:
% cropIR
% functionExponencial
% functionPolimonio


% Delimitar região pequena % ROI grande não da certo
xyloObj=VideoReader('CR1.wmv');


off=0;%starting frame - 1
hll=1;wll=1; %high and width lower limits
dsr=1;%down sampling ratio
fsr=1;%frame skip ratio
 
%  Uncomment this if there is no memory limitation
%opens the full video assuming there is no memory limitation
v1=read(xyloObj); %#ok<*VIDREAD>
StartFrame=1;
k=xyloObj.NumberOfFrames;
nf=k-(off+1);%number of frames
    
n=xyloObj.Height;   hul = n; %hight upper limit
m=xyloObj.Width;    wul = m; %width upper limit


t=xyloObj.Duration;
    
T=t/k;
fs=round(1/T);

%  cortar a janela
v=v1(hll:dsr:hul,   wll:dsr:wul,    :,  off+1:fsr:nf);


% %entradas sao (y,x,RGB,frame) onde R=1, G=2, B=3
% rgbImage=v(:,:,:,400); 

rgbImage=v(:,:,:,400); 
disp('Select region CRT test skin') 

%select very small region, big ROI has a lot of noise.

%
[~,~,Bw]=cropIR(rgbImage);
%% 
I_red=zeros();
I_green=zeros();
I_blue=zeros();
   
%%%%%%% Channel Red   

for i=1:nf
     % this creates an image the same size as v but with zeroes outside of the ROI
        %when above the third entry of v. Red :1
        g1=double(Bw).*double(v(:,:,1,i));
%       [~,sizeR1]= size(Bw);
        R1=im2col(g1,[1 1]);
        I=find(R1==0);
        R1(I)=[]; %this eliminates the black regions outside the ROI       
        I_red(i)=mean(R1);
        
end


% Channel Green

 for i=1:nf
%      Green : 2
        g2=double(Bw).*double(v(:,:,2,i)); 
        G1=im2col(g2,[1 1]);
        I=find(G1==0);
        G1(I)=[]; %this eliminates the black regions outside the ROI       
        I_green(i) = mean(G1);
 end


%Channel Blue
 for i=1:nf
     %      Blue : 3
        g3=double(Bw).*double(v(:,:,3,i));
        B1=im2col(g3,[1 1]);
        I=find(B1==0);
        B1(I)=[]; %this eliminates the black regions outside the ROI       
        I_blue(i) = mean(B1);
 end
   

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Vector X:time
X_red=1:1:length(I_red);
X_red=(X_red./(nf/t));

X_green=1:1:length(I_green); 
X_green=(X_green./(nf/t));

X_blue=1:1:length(I_blue);
X_blue=(X_blue./(nf/t));


Y_green=I_green;
Y_red=I_red;
Y_blue=I_blue;
%%

%%figure
figure(2)
plot(X_red,I_red,'r');hold on
plot(X_green,I_green,'g');
plot(X_blue,I_blue,'b');

%% Findpeaks Region Decay 

[p,l]=findpeaks(Y_green,X_green);


% Eliminates starting points that sometimes appear larger than the peak.
pki=8; %pki: it's on a time scale, value will depend on the video of the test start time
[~,k]=find(l<=pki);


% Finds the location of maximum peak
k_max=find(Y_green==max(p((k(end)+1):length(p))));
k_green=find(X_green<=35);


%% Create graphs of intensity values ??by time and forearm image
figure(2)
subplot(321);rgbImage=v(:,:,1,200);imshow(rgbImage);title('R')
subplot(322);plot(X_red,Y_red,'o','MarkerSize',4,'MarkerEdgeColor','black','MarkerFaceColor','red')

subplot(323);rgbImage=v(:,:,2,200);imshow(rgbImage);title('G')
subplot(324);plot(X_green,Y_green,'o','MarkerSize',4,'MarkerEdgeColor','black','MarkerFaceColor','green')
intensidade=ylabel('Intensity pixel ');
intensidade.FontSize=20;
intensidade.HorizontalAlignment='center';


subplot(325);rgbImage=v(:,:,3,200);imshow(rgbImage);title('B')
subplot(326);plot(X_blue,Y_blue,'o','MarkerSize',4,'MarkerEdgeColor','black','MarkerFaceColor','blue')
time=xlabel('Time(s)');
time.FontSize=20;
time.HorizontalAlignment='center';
set(gcf,'Color',[1 1 1])


%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%            Filtro_Polinomial
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Region Only Decay
X_green_exp=X_green(k_max:k_green(end));
Y_green_exp=Y_green(k_max:k_green(end));

figure(3)

x0_p= [1e-05 -0.01 0.1 -0.1 -1 100 100]; %% mudar outros

pars_pol=functionPolimonio(X_green_exp,Y_green_exp,x0_p);

x=X_green_exp;

f_pol= pars_pol(1).*x.^6 + pars_pol(2).*x.^5+...
             pars_pol(3).*x.^4 + pars_pol(4).*x.^3+...
             pars_pol(5).*x.^2 + pars_pol(6).*x + pars_pol(7);
                                              
plot(X_green_exp,f_pol,'linestyle','-','color','blue','LineWidth',1);grid
hold on

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%            Fit Exponential
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

x0= [1 10 0.1];
x0_exp2=[1 10 0.1];

plot(X_green_exp,Y_green_exp,'o','MarkerSize',4,'MarkerEdgeColor','green','MarkerFaceColor','green','LineWidth',3)
hold on

[pars_exp,incertezs,rr]=functionExponencial(X_green_exp,Y_green_exp,x0);

X=X_green_exp;
f_exp= pars_exp(1)+(pars_exp(2).*exp(-(X-X(1))./pars_exp(3)));

plot(X_green_exp,f_exp,'linestyle','-','color','red','LineWidth',1.5);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Região que a polinomial se afasta da exponencial
%Encontra o ponto que a exponencial é afetada pela polinomial

SS=size(Y_green_exp);
Diference_function=zeros(1,SS(2));
% f2=f_pol(1:length(f_exp));
% pDiference=[];
% 
for j=1:1:(length(f_exp))

Diference_function(j)=abs((f_exp(j)-f_pol(j)));
% Diference_function(j)=((f_exp(j)-f_pol(j)));
end 
Diference_function(1:50)=0;
% 

% 
% for j=1:1:(length(f_exp))
% j= find(f_exp>f_pol) ;
%     && j==loks(1,1);
%     Diference_function(j)>=pDiference_max
% X_cut1=X_green_exp(1:j(end));
% y_cut1=Y_green_exp(1:j(end));

% % end
% end

% Mantive essa parte pois em alguns casos estava cortando no ponto errado!!
% Atualizado dia 20-11-2019 as 17:57h

pDiference_max=max(Diference_function);
[pDiference,loks]=findpeaks(Diference_function);
loksr=find(Diference_function>=pDiference_max);

pks=find(Diference_function>=pDiference_max);  


if length(loks)>=2
    X_cut1=X_green_exp(1:loks(2));
    y_cut1=Y_green_exp(1:loks(2));

elseif length(loks)<=2
    X_cut1=X_green_exp(1:loks);
    y_cut1=Y_green_exp(1:loks);
end

% pDiference_max=max(pDiference);
% pDiference_min=min(pDiference);

% if
% 
% 
% % if length(pDiference_min)>=3 ; %max(Diference_function);
% %     pks=find(Diference_function>=pDiference_min);
%      
% %       
%       
%       
%     
% % else if length(pDiference)<=2 ;
% %         pksr=find(Diference_function==pDiference(1));
% %         X_cut=X_green_exp(1:pksr);
%         y_cut=Y_green_exp(1:pksr);
%     end  

% end
%
X_cut=X_cut1;
y_cut=y_cut1;


pars_exp2=functionExponencial(X_cut,y_cut,x0_exp2);
f_cut= pars_exp2(1)+(pars_exp2(2).*exp(-(X_cut-X_cut(1))./pars_exp2(3)));

plot(X_cut1,f_cut,'linestyle','-.','color','magenta','LineWidth',2);grid

    title('textbox',...
    'String',{['\tau= ',num2str(pars_exp2(3),'%10.2f\n'),'\pm',num2str(incertezs(3),'%10.2f\n')],...
    ['R^2= ' num2str(rr,'%10.3f\n')]},...
    'FontSize',14,...
    'FontName','Georgia',...
    'EdgeColor','black',...
    'LineWidth',2,...
    'HorizontalAlignment','center',...
    'Color','black');

intensidade=ylabel('Pixel Colour Value - Green Channel');grid
intensidade.FontSize=15;
intensidade.HorizontalAlignment='right';

time=xlabel('Time(s)');
time.FontSize=20;
time.HorizontalAlignment='center';
l=legend('Fit Polynomial','Green Channel','Fit Exponential 1','Fit Exponential 2');
l.FontSize=20;



