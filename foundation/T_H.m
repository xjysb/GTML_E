function [t_guess,i]=T_H(h,f,tguess)

%t:K

%h:J/kg
%f:-

if nargin == 1
    f = 0;
end

if nargin <= 2
    t_guess = 288.15;
else
    t_guess = tguess;
end

minH = H_T( 200, f );
maxH = H_T( 2200, f );

if h < minH
    h = minH;
elseif h > maxH
    h = maxH;
end

h_guess = H_T( t_guess, f );

for i=1:10
    t_guess_plus=t_guess*1.0001;
    h_guess_plus=H_T(t_guess_plus,f);
    t_guess_minus=t_guess*0.9999;
    h_guess_minus=H_T(t_guess_minus,f);
       
    df_dt=((h_guess_plus-h)-(h_guess_minus-h))/(t_guess*0.0002);
    t_guess=t_guess-((h_guess-h)/df_dt);
    if t_guess < 200
        t_guess = 200;
    elseif t_guess > 2200
        t_guess = 2200;
    end
    h_guess=H_T(t_guess,f);
    
    if (abs(h_guess-h)<=1e-7)
        break;
    end
end

end