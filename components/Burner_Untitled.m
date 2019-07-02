%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GTML-E -- Burner
% Aeroengine Control Laboratory, Beihang University
% written by Miao Keqiang
% July 7th, 2015
% revised by Yang Shubo
% July 2th, 2019
% version 1.05
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [ GasPthCharOut, OthrData ] = Burner_Untitled ( GasPthCharIn , CNST, dpbur, LHV, Eff_des, PtIn_des, TtIn_des, WIn_des, TtIn_fuel, Wfin, FuelType, Load_tab, Eff_tab, SF, FixEff, Volume )

WIn = 0;
TtIn = 0;
PtIn = 0;
f_in = 0;

if length( GasPthCharIn ) == 5
    f_in = GasPthCharIn( 5 );
    TtIn = GasPthCharIn( 3 );
    PtIn = GasPthCharIn( 4 );
    WIn  = GasPthCharIn( 1 );
end

if FuelType == 1
    MARK = 'Oil';
else
    MARK = 'Gas';
end

SF_Load = SF(1); 
SF_Eff = SF(2);

PSTD = CNST( 1 );
TSTD = CNST( 2 );
delta = PtIn / PSTD;
theta = TtIn / TSTD;
delta_des = PtIn_des / PSTD;
theta_des = TtIn_des / TSTD;

R0=gas_constant(0,MARK);
Cp0=Cp_T(TSTD,0,MARK);
k0=Cp0/(Cp0-R0);

R3_design=gas_constant(f_in,MARK);
Cp3_design=Cp_T(TtIn_des,0,MARK);
k3_design=Cp3_design/(Cp3_design-R3_design);

R3=gas_constant(f_in,MARK);
Cp3=Cp_T(TtIn,0,MARK);
k3=Cp3/(Cp3-R3);

Wcin = WIn * sqrt( theta ) / delta*(sqrt(R3*k0/R0/k3));
Wcindes = WIn_des * sqrt( theta_des ) / delta_des*(sqrt(R3_design*k0/R0/k3_design));
dp = dpbur*Wcin^2/Wcindes^2;

CombLoad = PtIn^1.75 * log(TtIn / 300) * Volume / WIn;
CombLoad_ = CombLoad / SF_Load;
if ( FixEff == 1 )

    Eff = Eff_des;
else

    Eff = Interpolation( Load_tab, Eff_tab, CombLoad_ );
end
Eff = Eff * SF_Eff;

H_in=H_T(TtIn,f_in,MARK);
H_in_f=H_T(TtIn_fuel,100000,MARK);%this 100000 should be Inf in theory
WOut=WIn+Wfin;%Perfect combustion
Wf_cb = f_in * WIn / ( 1 + f_in );
f_out = ( Wf_cb + Wfin ) / ( WOut - Wf_cb - Wfin );
H_out=(WIn*H_in+Wfin*H_in_f+Wfin*LHV*Eff)/WOut;
TtOut=T_H(H_out,f_out,TtIn,MARK);
PtOut=(1-dp)*PtIn;

OthrData = [ CombLoad, Eff ];

GasPthCharOut = zeros( 5, 1 );
GasPthCharOut( 1 ) = WOut;
GasPthCharOut( 2 ) = H_out;
GasPthCharOut( 3 ) = TtOut;
GasPthCharOut( 4 ) = PtOut;
GasPthCharOut( 5 ) = f_out;

end