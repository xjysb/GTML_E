%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Untitled -- Burner_Untitled.c
% written by Miao Keqiang
% Aeroengine Control Library, Beihang University
% July 7th, 2015

% version 1.02
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function GasPthCharOut  = Burner_Untitled ( GasPthCharIn , CNST, dpbur, LHV, Eff, PtIn_des, TtIn_des,WIn_des,TtIn_fuel,Wfin )

% dpbur=0.04;LHV=43031000;Eff=0.995;

f_in = GasPthCharIn( 5 );
TtIn = GasPthCharIn( 3 );
PtIn = GasPthCharIn( 4 );
WIn  = GasPthCharIn( 1 );

%计算dp
PSTD = CNST( 1 );
TSTD = CNST( 2 );
delta = PtIn / PSTD;
theta = TtIn / TSTD;
delta_des = PtIn_des / PSTD;
theta_des = TtIn_des / TSTD;

% %公式被简化的部分
R0=gas_constant(0);
Cp0=Cp_T(TSTD);
k0=Cp0/(Cp0-R0);

R3_design=gas_constant(f_in);
Cp3_design=Cp_T(TtIn_des);
k3_design=Cp3_design/(Cp3_design-R3_design);

R3=gas_constant(f_in);
Cp3=Cp_T(TtIn);
k3=Cp3/(Cp3-R3);
% %公式被简化的部分

Wcin = WIn * sqrt( theta ) / delta*(sqrt(R3*k0/R0/k3));
Wcindes = WIn_des * sqrt( theta_des ) / delta_des*(sqrt(R3_design*k0/R0/k3_design));
dp = dpbur*Wcin^2/Wcindes^2;
%%%%% dp计算end %%%%%

H_in=H_T(TtIn,f_in);
H_in_f=H_T(TtIn_fuel,100000);%此处100000理论上应该为Inf
WOut=WIn+Wfin;%Perfect combustion
Wf_cb = f_in * WIn / ( 1 + f_in );
f_out = ( Wf_cb + Wfin ) / ( WOut - Wf_cb - Wfin );
%f_out=((WIn - a * Wf_cb) * f_in + Wfin) / ((WIn - a * Wf_cb));
%f_out=((WIn - a * Wf_cb) * f_in + Wfin) / ((WIn - a * Wf_cb) * (1 - f_in));
%f_out=(WIn * f_in + Wfin) / (WIn* (1 - f_in));
H_out=(WIn*H_in+Wfin*H_in_f+Wfin*LHV*Eff)/WOut;
%H_out=2.4999e+6;%GSP中数据
TtOut=T_H(H_out,f_out);
PtOut=(1-dp)*PtIn;

GasPthCharOut = zeros( 5, 1 );
GasPthCharOut( 1 ) = WOut;
GasPthCharOut( 2 ) = H_out;
GasPthCharOut( 3 ) = TtOut;
GasPthCharOut( 4 ) = PtOut;
GasPthCharOut( 5 ) = f_out;

end