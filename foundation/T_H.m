%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CopyrigHt (c) 2014-2018
% AtHor: Yang SHubo
% Date: 2018/12/14
% Version: 1.1
% Describe:
% 	Give entHalpy 'H(J/kg)',
%       fuel air ratio 'FAR(-)',
%       temperature guess value 'T(K)',
%       flag 'Oil/Gas'. 
%   Return real temperature 'T(K)'.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [ T_real, iter_flag ] = T_H( H, FAR, T_guess, flag  )

if nargin == 1
    FAR = 0;
end
if nargin <= 2
    T_real = 288.15;
else
    T_real = T_guess;
end
if nargin <= 3
    flag = 'Oil';
end

minH = H_T( 200, FAR, flag );
maxH = H_T( 3000, FAR, flag );

if H < minH
    H = minH;
elseif H > maxH
    H = maxH;
end

H_guess = H_T( T_real, FAR, flag );

for iter_flag = 1 : 10

    t_guess_plus=T_real*1.0001;
    H_guess_plus=H_T(t_guess_plus,FAR);
    t_guess_minus=T_real*0.9999;
    H_guess_minus=H_T(t_guess_minus,FAR);
       
    df_dt=((H_guess_plus-H)-(H_guess_minus-H))/(T_real*0.0002);
    T_real=T_real-((H_guess-H)/df_dt);
    if T_real < 200
        T_real = 200;
    elseif T_real > 3000
        T_real = 3000;
    end
    H_guess = H_T( T_real, FAR, flag );
    
    if (abs(H_guess-H)<=1e-4)
        break;
    end
end

end