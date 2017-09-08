function [t_guess, i] = T_psi(psi,f,tguess)

%t:K

%psi:J/kg/K
%f:-

if nargin == 1
    f = 0;
end

if nargin <= 2
    t_guess = 288.15;
else
    t_guess = tguess;
end

minpsi = psi_T( 200, f );
maxpsi = psi_T( 2200, f );

if psi < minpsi
    psi = minpsi;
elseif psi > maxpsi
    psi = maxpsi;
end

psi_guess= psi_T( t_guess, f );

for i=1:10
    t_guess_plus=t_guess*1.0001;
    psi_guess_plus=psi_T(t_guess_plus,f);
    t_guess_minus=t_guess*0.9999; 
    psi_guess_minus=psi_T(t_guess_minus,f);

    df_dt=((psi_guess_plus-psi)-(psi_guess_minus-psi))/(t_guess*0.0002);
    t_guess=t_guess-((psi_guess-psi)/df_dt);
    if t_guess < 200
        t_guess = 200;
    elseif t_guess > 2200
        t_guess = 2200;
    end
    psi_guess=psi_T(t_guess,f);

    if(abs(psi_guess-psi)<=1e-7)
        break;
    end
end

end
