% Atualizado dia 10-08-2021
% Filtro Polinomial

function pars_pol=functionPolimonio(X,Y,x0_p)


f=@(pars,x) pars(1).*x.^6 + pars(2).*x.^5+...
             pars(3).*x.^4 + pars(4).*x.^3+...
             pars(5).*x.^2 + pars(6).*x + pars(7);

         
opts = statset('Display','iter','RobustWgtFun','welsch');

[pars,residual,J] = nlinfit(X,Y,f,x0_p,'Options',opts);

% this is for 95% confidence intervals
alpha = 1 - 0.95; 
pars_ci = nlparci(pars,residual,'jacobian',J,'alpha',alpha);
incertezs =(pars_ci(:,2)-pars_ci(:,1))/2;

pars_pol=pars;

S=std(residual);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

