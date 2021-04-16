%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GTML-E -- Turbine
% written by Yang Shubo
% Aeroengine Control Library, Beihang University
% April 3rd, 2015
% revised by Long Yifu
% April 16th, 2021
% version 1.03
% MaxNum of bleeds : 10
% to be continued : map scale & error count
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [ GasPthCharOut, PwrOut, NErrorOut, OthrData, Msg ] = Turbine_Untitled( CoolingFlwCharIn, GasPthCharIn, Nmech, PRMap, CoolingPlan, Nc_tab, Eff_tab, PR_tab, Wc_tab, SF, CNST, FuelType )

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

if FuelType == 1
    MARK = 'Oil';
else
    MARK = 'Gas';
end

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
            htcool( i ) = H_T( Ttcool( i ), FARcool( i ), MARK );
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

htIn = H_T( TtIn, FARcIn, MARK );
hts1In = ( htIn * WIn + dHcools1 ) / Ws1in;

% -- Compute stage 1 total temp --

Tts1In = T_H( hts1In, FARs1in, TtIn, MARK );

% -- Compute stage 1 psi, assuming PtIn = Pts1In --

psiIn = psi_T( Tts1In, FARs1in, MARK );

% -- Calculate fluid condition related variables --

RSTD = gas_constant( 0, MARK );
RIn = gas_constant( FARcIn, MARK );
CpSTD = Cp_T( TSTD, 0, MARK );
CpIn = Cp_T( TtIn, FARcIn, MARK );
gammaSTD = CpSTD / ( CpSTD - RSTD );
gammaIn = CpIn / ( CpIn - RIn );

delta = PtIn / PSTD;
theta = TtIn * RIn / TSTD / RSTD;
fai = gammaIn / gammaSTD;

% -- Calculate corrected speed --

NcMap = Nmech / sqrt( theta * fai );
NcMap_ = NcMap / SF_Nc;

% -- Compute Pressure Ratio --

PRMap_ = (PRMap - 1) / SF_PR + 1;

% -- Compute Total Flow input --

WcMap_ = interpolation_map( NcMap_, PRMap_, Nc_tab, PR_tab, Wc_tab );
WcMap = WcMap_ * SF_Wc;

% -- Compute Efficiency --

EffMap_ = interpolation_map( NcMap_, PRMap_, Nc_tab, PR_tab, Eff_tab );
EffMap = EffMap_ * SF_Eff;

% -- Compute pressure output --

PtOut = PtIn / PRMap;

% -- Enthalpy calculations --

R = gas_constant( FARcOut, MARK );
psiOut = psiIn + ( R * log( 1 / PRMap ) );
htIdealout = H_T( T_psi( psiOut, FARcOut, Tts1In, MARK ), FARcOut, MARK );
htOut = ( ( ( htIdealout - hts1In ) * EffMap + hts1In ) * Ws1in + dHcoolout ) / WOut;

% -- Compute Power output only takes into account cooling flow that enters at front of stage 1 --

PwrOut = ( hts1In - htIdealout ) * EffMap * Ws1in * 1e-3;

% -- Compute Temperature output --

TtOut = T_H( htOut, FARcOut, Tts1In, MARK );

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

% -- Message ------

if ( NcMap_ <= Nc_tab( 1 ) * 1.01 )
    message = -1;
elseif ( NcMap_ >= Nc_tab( end ) * 0.99 )
    message = -2;
else
    message = 0;
end
Msg = message;

end
