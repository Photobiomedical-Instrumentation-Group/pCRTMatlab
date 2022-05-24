%%
% Programa, usa fit exponencial, 
% Osajustes possuem metodos interativo com algoritmo Levenberg 

% X_exp=X_green_exp;
% y_exp=Y_green_exp;


%%
function [pars_exp,incertezs,rr]=functionExponencial(X,Y,x0)

f_exp = @(pars,x)    pars(1)+ (pars(2).*exp(-(x-x(1))./pars(3)));

% opts = statset('Display','iter','RobustWgtFun',[]);
% opts = statset('Display','iter','RobustWgtFun','welsch');

[pars,residual,J] = nlinfit(X,Y,f_exp,x0); %,'Options',opts

tester=fitnlm(X,Y,f_exp,x0);
rr=tester.Rsquared.Ordinary;

% Calcula erro:
J=full(J);
alpha = 0.05; % this is for 95% confidence intervals
pars_ci = nlparci(pars,residual,'jacobian',J,'alpha',alpha);
incertezs=(pars_ci(:,2)-pars_ci(:,1))/2;
pars_exp=pars;



