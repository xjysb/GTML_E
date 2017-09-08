%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Untitled -- Duct_Untitled.c
% written by Miao Keqiang
% Aeroengine Control Library, Beihang University
% July 2nd, 2015

% MaxNum of bleeds : 10
% version 1.1
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [ GasPthCharOut, OthrData ] = Duct_Untitled ( GasPthCharIn , CNST, PtIn_des, TtIn_des, WIn_des, sigma_des, Blds )

% f_in = 0;
% TtIn = 0;
% PtIn = 0;
% WIn = 0;
% 
% if length(GasPthCharIn) == 5

f_in = GasPthCharIn( 5 );
TtIn = GasPthCharIn( 3 );
PtIn = GasPthCharIn( 4 );
WIn  = GasPthCharIn( 1 );

% end

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
sigma = 1-(1-sigma_des)*Wcin^2/Wcindes^2;

%%%%% sigma计算end %%%%%

H_in = H_T(TtIn,f_in);
Wbleed = 0;
h = 0;

[ port_num, bleed_num ] = size( Blds );
if ( port_num == 5 )
    for i = 1 : bleed_num
    
        h = h + Blds( 1, i ) * Blds( 2, i );
        Wbleed = Wbleed + Blds( 1, i );
    end
end
WOut=WIn+Wbleed;
f_out=f_in;
H_out=(WIn*H_in+h)/WOut;
TtOut=T_H( H_out, f_out );
PtOut=sigma*PtIn;

GasPthCharOut = zeros( 1, 5 );
GasPthCharOut( 1 ) = WOut;
GasPthCharOut( 2 ) = H_out;
GasPthCharOut( 3 ) = TtOut;
GasPthCharOut( 4 ) = PtOut;
GasPthCharOut( 5 ) = f_out;
OthrData = Wbleed;

end