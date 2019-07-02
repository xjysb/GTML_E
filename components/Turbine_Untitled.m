%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GTML-E -- Turbine
% written by Yang Shubo
% Aeroengine Control Library, Beihang University
% April 3rd, 2015
% revised by Yang Shubo
% July 2th, 2019
% version 1.02

% MaxNum of bleeds : 10
% to be continued : map scale & error count
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [ GasPthCharOut, PwrOut, NErrorOut, OthrData ] = Turbine_Untitled( CoolingFlwCharIn, GasPthCharIn, Nmech, beta, CoolingPlan, Nc_tab, Beta_tab, Eff_tab, PR_tab, Wc_tab, SF, CNST )

WIn = 0;
TtIn = 0;
PtIn = 0;
FARcIn = 0;

if length(GasPthCharIn) == 5
WIn = GasPthCharIn( 1 );
TtIn = GasPthCharIn( 3 );
PtIn = GasPthCharIn( 4 );
FARcIn = GasPthCharIn( 5 );
end
SF_Wc = SF( 1 );
SF_PR = SF( 2 );
SF_Eff = SF( 3 );
SF_Nc = SF( 4 );
PSTD = CNST( 1 );
TSTD = CNST( 2 );

% -- Load the cooling flow --

[ ~, num ] = size( CoolingPlan );
Wcool = zeros( 1, num );
htcool = zeros( 1, num );
Ttcool = zeros( 1, num );
Ptcool = zeros( 1, num );
FARcool = zeros( 1, num );

[port_num,~] = size( CoolingFlwCharIn );
if ( port_num == 5 )
    for i = 1 : num
        if CoolingPlan( 1, i ) > 0
            Wcool( i ) = CoolingFlwCharIn( 1, i ) * CoolingPlan( 1, i );
            Ttcool( i ) = CoolingFlwCharIn( 3, i );
            Ptcool( i ) = CoolingFlwCharIn( 4, i );
            FARcool( i ) = CoolingFlwCharIn( 5, i );
            htcool( i ) = H_T( Ttcool( i ), FARcool( i ) );
        end
    end
end

% -- Initialize cooling flow sum constants --

dHcools1 = 0;
dHcoolout = 0;
Wcools1 = 0;
Wcoolout = 0;
Wfcools1 = 0;
Wfcoolout = 0;

% -- Calculate cooling flow constants for stage 1 & output of the turbine --

for i = 1 : num
    Wcools1 = Wcools1 + Wcool( i ) * ( 1 - CoolingPlan( 2, i ) );
    Wcoolout = Wcoolout + Wcool( i );
    Wfcools1 = Wfcools1 + FARcool( i ) * Wcool( i ) * ( 1 - CoolingPlan( 2, i ) ) / ( 1 + FARcool( i ) );
    Wfcoolout = Wfcoolout + FARcool( i ) * Wcool( i ) / ( 1 + FARcool( i ) );
end

% -- Compute Total Flow --

Ws1in = WIn + Wcools1;
WOut = WIn + Wcoolout;

% -- Compute Fuel to Air Ratios --

FARs1in = ( FARcIn * WIn / ( 1 + FARcIn ) + Wfcools1 ) / ( WIn / ( 1 + FARcIn ) + Wcools1 - Wfcools1 );
FARcOut = ( FARcIn * WIn / ( 1 + FARcIn ) + Wfcoolout ) / ( WIn / ( 1 + FARcIn ) + Wcoolout - Wfcoolout );

% -- Compute input enthalpy of cooling flow --

for i = 1 : num
    dHcools1 = dHcools1 + htcool( i ) * Wcool( i ) * ( 1 - CoolingPlan( 2, i ) );
    dHcoolout = dHcoolout + htcool( i ) * Wcool( i ) * CoolingPlan( 2, i );
end

% -- Compute avg enthalpy at stage 1 --

htIn = H_T( TtIn, FARcIn );
hts1In = ( htIn * WIn + dHcools1 ) / Ws1in;

% -- Compute stage 1 total temp --

Tts1In = T_H( hts1In, FARs1in );

% -- Compute stage 1 psi, assuming PtIn = Pts1In --

psiIn = psi_T( Tts1In, FARs1in );

% -- Calculate fluid condition related variables --

RSTD = gas_constant( 0 );
RIn = gas_constant( FARcIn );
CpSTD = Cp_T( TSTD );
CpIn = Cp_T( TtIn, FARcIn );
gammaSTD = CpSTD / ( CpSTD - RSTD );
gammaIn = CpIn / ( CpIn - RIn );

delta = PtIn / PSTD;
theta = TtIn * RIn / TSTD / RSTD;
fai = gammaIn / gammaSTD;

% -- Calculate corrected speed --

NcMap = Nmech / sqrt( theta * fai );
NcMap_ = NcMap / SF_Nc;

% -- Compute Total Flow input --

WcMap = interpolation_map( NcMap_, beta, Nc_tab, Beta_tab, Wc_tab );
WcMap = WcMap * SF_Wc;

% -- Compute Pressure Ratio --

PRMap = interpolation_map( NcMap_, beta, Nc_tab, Beta_tab, PR_tab );
PRMap = (PRMap - 1) * SF_PR + 1;

% -- Compute Efficiency --

EffMap = interpolation_map( NcMap_, beta, Nc_tab, Beta_tab, Eff_tab );
EffMap = EffMap * SF_Eff;

% -- Compute pressure output --

PtOut = PtIn / PRMap;

% -- Enthalpy calculations --

R = gas_constant( FARcOut );
psiOut = psiIn + ( R * log( 1 / PRMap ) );
htIdealout = H_T( T_psi( psiOut, FARcOut ), FARcOut );
htOut = ( ( ( htIdealout - hts1In ) * EffMap + hts1In ) * Ws1in + dHcoolout ) / WOut;

% -- Compute Power output only takes into account cooling flow that enters at front of stage 1 --

PwrOut = ( hts1In - htIdealout ) * EffMap * Ws1in * 1e-3;

% -- Compute Temperature output --

TtOut = T_H( htOut, FARcOut );

% -- Compute Normalized Flow Error --

if Ws1in == 0
    NErrorOut = 100;
else
    NErrorOut = ( Ws1in * sqrt( theta / fai ) / delta - WcMap ) / ( Ws1in * sqrt( theta / fai ) / delta );
end

% -- Assign output values port --

GasPthCharOut = zeros( 5, 1 );
GasPthCharOut( 1 ) = WOut;
GasPthCharOut( 2 ) = htOut;
GasPthCharOut( 3 ) = TtOut;
GasPthCharOut( 4 ) = PtOut;
GasPthCharOut( 5 ) = FARcOut;

OthrData = [ WcMap, PRMap, EffMap, NcMap ];

end
