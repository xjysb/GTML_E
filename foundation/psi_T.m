%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright (c) 2014-2018
% written by Long Yifu
% April 15th, 2021
% version: 1.1
% T[200K~2200K]
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function psi = psi_T(t, f, flag)
%psi:KJ/kg/K
%t:K

if nargin <= 2
    flag = 'Oil';
end
if nargin == 1
    f = 0;
end

if t < 199
    t = 199;
elseif t > 2201
    t = 2201;
end

tz=t/1000;

A0=0.992313;
A1=0.236688;
A2=-1.852148;
A3=6.083152;
A4=-8.893933;
A5=7.097112;
A6=-3.234725;
A7=0.794571;
A8=-0.081873;
% A9=0.422178;
A10=0.001053;

B0=-0.718874;
B1=8.747481;
B2=-15.863157;
B3=17.254096;
B4=-10.233795;
B5=3.081778;
B6=-0.361112;
B7=-0.003919;
% B8=0.0555930;
B9=-0.0016079;

psi=(A0*log(tz)+A1*tz^1+A2*tz^2/2+A3*tz^3/3+A4*tz^4/4+A5*tz^5/5+A6*tz^6/6+A7*tz^7/7+A8*tz^8/8+A10)+((f/(1+f))*(B0*log(t)+B1*tz^1/1+B2*tz^2/2+B3*tz^3/3+B4*tz^4/4+B5*tz^5/5+B6*tz^6/6+B7*tz^7/7+B9));

psi=psi*1e3;

if strcmp(flag, 'Gas')

    psi = psi*1.0145;
end

end