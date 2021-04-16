%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright (c) 2014-2018
% written by Long Yifu
% April 15th, 2021
% version: 1.1
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [t_guess, i] = T_psi(psi, f, t_guess, flag)
%t:K
%psi:J/kg/K
%f:-


if nargin <= 3
    flag = 'Oil';
end
if nargin <= 2
  t_guess = 288.15;
end
if nargin == 1
  f = 0;
end

minpsi = psi_T( 200, f, flag );
maxpsi = psi_T( 2200, f, flag );

if psi < minpsi
    psi = minpsi;
elseif psi > maxpsi
    psi = maxpsi;
end


psi_guess= psi_T( t_guess, f, flag );

for i=1:10
    t_guess_plus=t_guess*1.0001;
    psi_guess_plus=psi_T(t_guess_plus,f,flag);
    t_guess_minus=t_guess*0.9999; 
    psi_guess_minus=psi_T(t_guess_minus,f,flag);

    df_dt=((psi_guess_plus-psi)-(psi_guess_minus-psi))/(t_guess*0.0002);
    t_guess=t_guess-((psi_guess-psi)/df_dt);
    if t_guess < 200
        t_guess = 200;
    elseif t_guess > 2200
        t_guess = 2200;
    end
    psi_guess=psi_T(t_guess,f,flag);

    if(abs(psi_guess-psi)<=1e-7)
        break;
    end
end

end
