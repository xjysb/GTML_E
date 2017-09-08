%%%%%%%%%%%%%%%%%%%%%%%%%
% Informal version
%%%%%%%%%%%%%%%%%%%%%%%%%

function [beta,i_sum, maxnum, minnum] = MapBetaSolution( n_cor,pi,n_tab,beta_tab,pi_tab,beta_guess )

pi_guess=interpolation_map(n_cor,beta_guess,n_tab,beta_tab,pi_tab);
maxnum = pi_guess;
minnum = pi_guess;

for i_sum=1:50
    
    if(abs(pi_guess-pi)<=1e-7)
        beta=beta_guess;
        break;
    else
        beta_guess_plus=beta_guess*1.0001;
        pi_guess_plus=interpolation_map(n_cor,beta_guess_plus,n_tab,beta_tab,pi_tab);
        beta_guess_minus=beta_guess*0.9999;
        pi_guess_minus=interpolation_map(n_cor,beta_guess_minus,n_tab,beta_tab,pi_tab);
        df_dt=((pi_guess_plus-pi)-(pi_guess_minus-pi))/(beta_guess*0.0002);
        beta_guess=beta_guess-(pi_guess-pi)/df_dt;

        if (beta_guess<0)
            beta_guess=0.001;
        elseif(beta_guess>1)
            beta_guess=0.999;
        else
            beta_guess=beta_guess*1;
        end
        pi_guess=interpolation_map(n_cor,beta_guess,n_tab,beta_tab,pi_tab);
    
        if  pi_guess < minnum 
            minnum = pi_guess;
        elseif pi_guess > maxnum
            maxnum = pi_guess;
        end
    beta = beta_guess;
end

end

