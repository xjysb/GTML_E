%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright (c) 2014-2018
% Athor: Yang Shubo
% Date: 2018/12/13
% Version: 1.1
% Describe:
% 	Give fuel air ratio 'FAR(-)' and flag 'Oil/Gas'. 
%   Return corresponding 'Rg(J/(kg*K))'.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
function Rg = gas_constant( FAR, flag )

%FAR:-
%Rg:J/(kg*K)

if nargin == 1

    flag = 'Oil';
end

if strcmp(flag, 'Gas')
    
    Rg = 8.313846 / fcn( 1, FAR ) * 1e3;
else

    Rg = 287.05-0.00990*FAR+1e-7*FAR^2;
end

end

function y = fcn(gin,Wf)

Mgair=28*79/100+32*21/100; 
MOL_air=gin*1000/Mgair; 

L0=Wf*1000*0.595238;

MOL_air_rest = MOL_air-L0 ;
MOL_N2_rest = MOL_air_rest*0.79; 
MOL_O2_rest = MOL_air_rest*0.21; 

MOL_mix = 0.87*Wf*1000/12+0.126*Wf*1000/2+0.79*L0;
MOL_mix_CO2 = MOL_mix*0.0725/(0.0725+0.063+0.3907);
MOL_mix_H2O = MOL_mix*0.063/(0.0725+0.063+0.3907);
MOL_mix_N2 = MOL_mix*0.3907/(0.0725+0.063+0.3907);

MOL_gas_CO2 = MOL_mix_CO2;
MOL_gas_H2O =MOL_mix_H2O;
MOL_gas_O2 = MOL_O2_rest;
MOL_gas_N2 = MOL_N2_rest+MOL_mix_N2;

Mol_tot = MOL_gas_CO2 + MOL_gas_H2O + MOL_gas_O2 + MOL_gas_N2;
Mol_H2O = MOL_gas_H2O / Mol_tot; 
Mol_CO2 = MOL_gas_CO2 / Mol_tot;
Mol_N2 = MOL_gas_N2 / Mol_tot;
Mol_O2 = MOL_gas_O2 / Mol_tot;

y = Mol_H2O*18+Mol_CO2*44+Mol_N2*28+Mol_O2*32;

end