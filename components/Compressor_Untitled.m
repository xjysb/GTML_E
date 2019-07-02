%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GTML-E -- Compressor
% written by Yang Shubo
% Aeroengine Control Library, Beihang University
% March 27th, 2015
% revised by Yang Shubo
% July 2th, 2019
% version 1.02

% MaxNum of bleeds : 10
% to be continued : map scale & error count & stall margin
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [ GasPthCharOut, PwrOut, NErrorOut, OthrData, CustBldsCharOut, FBldsCharOut, Msg ] = Compressor_Untitled( GasPthCharIn, Nmech, beta, VSV, CustBldsPlan, FBldsPlan, Nc_tab, Beta_tab, Eff_tab, PR_tab, Wc_tab, SF, CNST, WcSurgeVec, PRSurgeVec )

WIn = 0;
TtIn = 0;
PtIn = 0;

if length(GasPthCharIn) == 5
WIn = GasPthCharIn( 1 );
TtIn = GasPthCharIn( 3 );
PtIn = GasPthCharIn( 4 );
end
SF_Wc = SF( 1 );
SF_PR = SF( 2 );
SF_Eff = SF( 3 );
SF_Nc = SF( 4 );
PSTD = CNST( 1 );
TSTD = CNST( 2 );

% -- Compute output Fuel to Air Ratio --

FAROut = 0;

% -- Compute Input enthalpy --

htIn = H_T( TtIn );

% -- Compute Input psi --
psiIn = psi_T( TtIn );

% -- Calculate fluid condition related variables and corected Flow --

RSTD = gas_constant( 0 );
RIn = gas_constant( 0 );
CpSTD = Cp_T( TSTD );
CpIn = Cp_T( TtIn );
gammaSTD = CpSTD / ( CpSTD - RSTD );
gammaIn = CpIn / ( CpIn - RIn );

delta = PtIn / PSTD;
theta = TtIn / TSTD;
fai = gammaIn / gammaSTD;

Wcin = WIn * sqrt( theta / fai ) / delta;

% -- Calculate corrected speed --

NcMap = Nmech / sqrt( theta * fai );
NcMap_ = NcMap / SF_Nc;

% -- Compute Total Flow input --

WcMap = interpolation_map( NcMap_, beta, Nc_tab, Beta_tab, Wc_tab );
WcMap = WcMap + VSV * WcMap * 1e-2;
WcMap = WcMap * SF_Wc;

% -- Compute Pressure Ratio --

PRMap = interpolation_map( NcMap_, beta, Nc_tab, Beta_tab, PR_tab );
PRMap = (PRMap - 1) * SF_PR + 1;

% -- Compute Efficiency --

EffMap = interpolation_map( NcMap_, beta, Nc_tab, Beta_tab, Eff_tab );
EffMap = EffMap - VSV * VSV * 1e-4 * EffMap;
EffMap = EffMap * SF_Eff;

% -- Compute pressure output --

PtOut = PtIn * PRMap;

% -- Enthalpy calculations --

R = gas_constant( FAROut );
psiOut = psiIn + ( R * log( PRMap ) );
htOut = htIn + ( H_T( T_psi( psiOut ) ) - htIn ) / EffMap;
TtOut = T_H( htOut );

% -- Initalize Bleed sums --

Wbleeds = 0;
PwrBld = 0;

% -- Compute customer Bleed components --

[ ~, uWidth1 ] = size( CustBldsPlan );
WcustOut = zeros( 1, uWidth1 );
htcustOut = zeros( 1, uWidth1 );
TtcustOut = zeros( 1, uWidth1 );
PtcustOut = zeros( 1, uWidth1 );
FARcustOut = zeros( 1, uWidth1 );

for i = 1 : uWidth1
    if CustBldsPlan( 1, i ) > 0
        Wbleeds = Wbleeds + CustBldsPlan( 1, i );
        WcustOut( 1, i ) = CustBldsPlan( 1, i );
        FARcustOut( 1, i ) = FAROut;
        htcustOut( 1, i ) = htIn + CustBldsPlan( 2, i ) * ( htOut - htIn );
        PtcustOut( 1, i ) = PtIn + CustBldsPlan( 3, i ) * ( PtOut - PtIn );
        TtcustOut( 1, i ) = T_H( htcustOut( 1, i ) );
        PwrBld = PwrBld + WcustOut( 1, i ) * ( htcustOut( 1, i ) - htOut );
    end
end

% -- Compute fractional Bleed components --

[ ~, uWidth2 ] = size( FBldsPlan );
WbldOut = zeros( 1, uWidth2 );
htbldOut = zeros( 1, uWidth2 );
TtbldOut = zeros( 1, uWidth2 );
PtbldOut = zeros( 1, uWidth2 );
FARbldOut = zeros( 1, uWidth2 );

for i = 1 : uWidth2
    if FBldsPlan( 1, i ) > 0
        WbldOut( 1, i ) = WIn * FBldsPlan( 1, i );
        Wbleeds = Wbleeds + WbldOut( 1, i );
        FARbldOut( 1, i ) = FAROut;
        htbldOut( 1, i ) = htIn + FBldsPlan( 2, i ) * ( htOut - htIn );
        PtbldOut( 1, i ) = PtIn + FBldsPlan( 3, i ) * ( PtOut - PtIn );
        TtbldOut( 1, i ) = T_H( htbldOut( 1, i ) );
        PwrBld = PwrBld + WbldOut( 1, i ) * ( htbldOut( 1, i ) - htOut );
    end
end

% -- Compute Flows --

Wb4bleed = WIn;
WOut = WIn - Wbleeds;

% -- Compute Powers --

Pwrb4bleed = Wb4bleed * ( htIn - htOut );
PwrOut = ( Pwrb4bleed - PwrBld ) * 1e-3;

% -- Compute Normalized Flow Error --

if WIn == 0
    NErrorOut = 100;
else
    NErrorOut = ( Wcin - WcMap ) / Wcin;
end

% -- Compute Stall Margin --

SPR = Interpolation( WcSurgeVec, PRSurgeVec, Wcin );
SM = ( SPR / PRMap - 1 ) * 100;

% -- Assign output values port --

GasPthCharOut = zeros( 5, 1 );
GasPthCharOut( 1 ) = WOut;
GasPthCharOut( 2 ) = htOut;
GasPthCharOut( 3 ) = TtOut;
GasPthCharOut( 4 ) = PtOut;
GasPthCharOut( 5 ) = FAROut;

OthrData = [ SM, WcMap, PRMap, EffMap, NcMap ];

CustBldsCharOut = zeros( 5, uWidth1 );
CustBldsCharOut( 1, : ) = WcustOut;
CustBldsCharOut( 2, : ) = htcustOut;
CustBldsCharOut( 3, : ) = TtcustOut;
CustBldsCharOut( 4, : ) = PtcustOut;
CustBldsCharOut( 5, : ) = FARcustOut;

FBldsCharOut = zeros( 5, uWidth2 );
FBldsCharOut( 1, : ) = WbldOut;
FBldsCharOut( 2, : ) = htbldOut;
FBldsCharOut( 3, : ) = TtbldOut;
FBldsCharOut( 4, : ) = PtbldOut;
FBldsCharOut( 5, : ) = FARbldOut;

if ( NcMap_ <= Nc_tab( 1 ) * 1.01 )
    message = -1;
elseif ( NcMap_ >= Nc_tab( end ) * 0.99 )
    message = -2;
else
    message = 0;
end
Msg = message;

if ( beta <= 0.01 )
    message = -1;
elseif ( beta >= 0.99 )
    message = -2;
else
    message = 0;
end
Msg = Msg * 10 + message;

end
