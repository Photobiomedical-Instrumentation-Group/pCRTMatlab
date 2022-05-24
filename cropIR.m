% Função que realiza uma mascara na região que o usuário define como ROI
% Encontra a curva de intensidade do valores RGB da ROI. 

function [c123out,ipos,Bw,pos]=cropIR(f)
figure
title('selecione a região de interesse')
h_im=imshow(f);
[n,m,k]=size(f);


h=imfreehand(gca,'Closed',true);
%teste com Retangulo
% h = imrect(gca);
pos=getPosition(h);
binaryImage = h.createMask();

Bw=poly2mask(pos(:,1)',pos(:,2)',n,m);


g1=double(Bw).*double(f(:,:,1));
g2=double(Bw).*double(f(:,:,2));
g3=double(Bw).*double(f(:,:,3));
R=im2col(g1,[1 1])';
G=im2col(g2,[1 1])';
B=im2col(g3,[1 1])';
I=find(R==0 & G==0 & B==0);
R(I)=[];
G(I)=[];
B(I)=[];
c123out=[R G B];
ipos = uint8(pos);
