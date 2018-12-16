%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GTML-E -- Turbine_EnthalpyMethod
% written by Yang Shubo
% Aeroengine Control Library, Beihang University
% December 13, 2018

% MaxNum of bleeds : 10
% to be continued : map scale & error count
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [ GasPthCharOut, PwrOut, NErrorOut, OthrData ] = Turbine_EnthalpyMethod( CoolingFlwCharIn, GasPthCharIn, Nmech, PRMap, IsOil, CoolingPlan, Nc_tab, Eff_tab, PR_tab, Wc_tab, Degnrt, CNST )

WIn = GasPthCharIn( 1 );
TtIn = GasPthCharIn( 3 );
PtIn = GasPthCharIn( 4 );
FARcIn = GasPthCharIn( 5 );
Wc_Degnrt = Degnrt( 1 );
Eff_Degnrt = Degnrt( 2 );
PSTD = CNST( 1 );
TSTD = CNST( 2 );
if IsOil
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

for i = 1 : num
    if CoolingPlan( 1, i ) > 0
        Wcool( i ) = CoolingFlwCharIn( 1, i ) * CoolingPlan( 1, i );
        Ttcool( i ) = CoolingFlwCharIn( 3, i );
        Ptcool( i ) = CoolingFlwCharIn( 4, i );
        FARcool( i ) = CoolingFlwCharIn( 5, i );
        htcool( i ) = H_T( Ttcool( i ), FARcool( i ), MARK );
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

il = FindPos( Nc_tab, NcMap );
prm = ( NcMap - Nc_tab( il ) ) / ( Nc_tab( il + 1 ) - Nc_tab( il ) );
PR_line = PR_tab( il, : ) + prm * ( PR_tab( il + 1 ) - PR_tab( il ) );

% -- Compute Total Flow input --

WcMap = interpolation_map( NcMap, PRMap, Nc_tab, PR_line, Wc_tab );
WcMap = WcMap * Wc_Degnrt;

% -- Compute Efficiency --

EffMap = interpolation_map( NcMap, PRMap, Nc_tab, PR_line, Eff_tab );
EffMap = EffMap * Eff_Degnrt;

% -- Compute pressure output --

PtOut = PtIn / PRMap;

% -- Enthalpy calculations --

R = gas_constant( FARcOut, MARK );
Tmid_guess = Tts1In;
CpTMP = Cp_T( Tmid_guess, FARs1in, MARK );
kgTMP = CpTMP / ( CpTMP - R );
ToutTMP = Tts1In * (1 - EffMap * ( 1 - PRMap^(-(kgTMP-1)/kgTMP) ));
err_guess = ( Tts1In - ToutTMP ) / ToutTMP;

for i = 1 : 10
        
    Tmid_guess_plus = Tmid_guess * 1.01;
    CpTMP = Cp_T( Tmid_guess_plus, FARs1in, MARK );
    kgTMP = CpTMP / ( CpTMP - R );
    ToutTMP = Tts1In * (1 - EffMap * ( 1 - PRMap^(-(kgTMP-1)/kgTMP) ));
    err_guess_plus = ( Tmid_guess_plus * 2 - Tts1In - ToutTMP ) / ToutTMP;
    
    derr_dTmid = (err_guess_plus - err_guess)/0.01/Tmid_guess;
    Tmid_guess = Tmid_guess - err_guess/derr_dTmid;
    CpTMP = Cp_T( Tmid_guess, FARs1in, MARK );    
    kgTMP = CpTMP / ( CpTMP - R );
    ToutTMP = Tts1In * (1 - EffMap * ( 1 - PRMap^(-(kgTMP-1)/kgTMP) ));
    Tts1Out = Tmid_guess * 2 - Tts1In;
    err_guess = ( Tts1Out - ToutTMP ) / ToutTMP;
        
    if ( abs ( err_guess ) < 1e-6 ) 
        break;
    end
end

% -- Compute avg output enthalpy --

hts1Out = H_T( Tts1Out, FARs1in, MARK );
htOut = ( hts1Out * Ws1in + dHcoolout ) / WOut;

% -- Compute output total temp --

TtOut = T_H( htOut, FARcOut, Tts1Out, MARK );

% -- Compute Power output only takes into account cooling flow that enters at front of stage 1 --

PwrOut = ( hts1In - hts1Out ) * Ws1in * 1e-3;

% -- Compute Normalized Flow Error --

if Ws1in == 0
    NErrorOut = 100;
else
    NErrorOut = ( WIn * sqrt( theta / fai ) / delta - WcMap ) / ( WIn * sqrt( theta / fai ) / delta );
end

% -- Assign output values port --

GasPthCharOut = zeros( 5, 1 );
GasPthCharOut( 1 ) = WOut;
GasPthCharOut( 2 ) = htOut;
GasPthCharOut( 3 ) = TtOut;
GasPthCharOut( 4 ) = PtOut;
GasPthCharOut( 5 ) = FARcOut;

OthrData = [ WcMap, EffMap, NcMap, Wcoolout - Wcools1];

end
