function val=valfun3(k)
%%Reference: http://www3.nd.edu/~esims1/val_fun_iter.pdf
%Eric Sims, University of Notre Dame, Spring 2011
%Continuous time value function iteration using linear splines
%%
global v0 beta delta alpha kmat k0 sigma kgrid P logzgrid

klo=max(sum(k>kmat),1); 
khi=klo+1;

% do the interpolation
gg = v0(klo,:) + (k-kmat(klo))*(v0(khi,:) - v0(klo,:))/(kmat(khi) - kmat(klo));

c =  2.8613*k0^alpha - k + (1-delta)*k0; % consumption
if c<=0
val = -8888888888888888-800*abs(c);
else
val = (1/(1-sigma))*(c^(1-sigma)-1) + beta*(gg*P(3,:)');
end
val = -val; % make it negative since we're maximizing and code is to minimize.