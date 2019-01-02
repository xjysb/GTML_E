%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GTML-E -- Burner
% Aeroengine Control Laboratory, Beihang University
% written by Miao Keqiang
% July 7th, 2015
% revised by Yang Shubo
% January 2rd, 2019

% version 1.03
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function GasPthCharOut  = Burner_Untitled ( GasPthCharIn , CNST, dpbur, LHV, Eff, PtIn_des, TtIn_des,WIn_des,TtIn_fuel,Wfin, IsOil)


TtIn = GasPthCharIn( 3 );
PtIn = GasPthCharIn( 4 );
WIn  = GasPthCharIn( 1 );

if IsOil
    MARK = 'Oil';
else
    MARK = 'Gas';
end

PSTD = CNST( 1 );
TSTD = CNST( 2 );
delta = PtIn / PSTD;
theta = TtIn / TSTD;
delta_des = PtIn_des / PSTD;
theta_des = TtIn_des / TSTD;

R0=gas_constant(0,MARK);
Cp0=Cp_T(TSTD,0,MARK);
k0=Cp0/(Cp0-R0);

R3_design=gas_constant(0,MARK);
Cp3_design=Cp_T(TtIn_des,0,MARK);
k3_design=Cp3_design/(Cp3_design-R3_design);

R3=gas_constant(0,MARK);
Cp3=Cp_T(TtIn,0,MARK);
k3=Cp3/(Cp3-R3);

Wcin = WIn * sqrt( theta ) / delta*(sqrt(R3*k0/R0/k3));
Wcindes = WIn_des * sqrt( theta_des ) / delta_des*(sqrt(R3_design*k0/R0/k3_design));
dp = dpbur*Wcin^2/Wcindes^2;

H_in=H_T(TtIn,0,MARK);
H_in_f=H_T(TtIn_fuel,100000,MARK);
WOut=WIn+Wfin;%Perfect combustion
f_out = Wfin / WIn;
H_out=(WIn*H_in+Wfin*H_in_f+Wfin*LHV*Eff)/WOut;
TtOut=T_H(H_out,f_out,TtIn,MARK);
PtOut=(1-dp)*PtIn;

GasPthCharOut = zeros( 5, 1 );
GasPthCharOut( 1 ) = WOut;
GasPthCharOut( 2 ) = H_out;
GasPthCharOut( 3 ) = TtOut;
GasPthCharOut( 4 ) = PtOut;
GasPthCharOut( 5 ) = f_out;

end