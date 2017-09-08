%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Untitled -- Nozzle_Untitled.m
% written by Yang Shubo
% Aeroengine Control Library, Beihang University
% April 27th, 2015

% to be continued : CD nozzle & calculate gamma by Ts
% version 1.1
%
% Msg:  0 or -A, 0 means ok, -A means warnning
%       A: pressure of input, 1 : too small, 2 : too large
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [ WOut, FgOut, NErrorOut, OthrData, Msg ] = Nozzle_Untitled( GasPthCharIn, PambIn, AthroatIn, Cdth, CV, CX )

Msg = 0;

% -- Load data --

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

% -- Calculate PsMN1 --
  
Rth = gas_constant( FARcIn ); 
Cpth = Cp_T( TtIn, FARcIn );
gammath = Cpth / ( Cpth - Rth );
PRMN1 = (( gammath + 1 ) / 2 ) ^ ( gammath / ( gammath - 1 ) );
PsMN1 = PtIn / PRMN1;

% -- Determine if Nozzle is choked --

if ( PsMN1 < PambIn )
	choked = 0;
else
	choked = 1;
end
  
% -- Assumed not choked,  set Ps to ambient pressure and calculate parameters --
if ( choked == 0 )
	Psth = PambIn;
	PRlambdath = Psth / PtIn;
    
    %-- Limit pilambda range --
    if ( PRlambdath > 1 )
        PRlambdath = 1;
        Msg = -1;
    elseif ( PRlambdath < 0.01 )
        PRlambdath = 0.01;
        Msg = -2;
    end
	lambdath = sqrt( ( ( gammath + 1 ) / ( gammath - 1 ) ) * ( 1 - ( PRlambdath ^ ( ( gammath - 1 ) / gammath ) ) ) );
	qlambdath = ( ( gammath + 1 ) / 2 ) ^ ( 1 / ( gammath - 1 ) ) * lambdath;
	qlambdath = qlambdath * ( ( 1 - ( gammath - 1 ) / ( gammath + 1 ) * lambdath * lambdath ) ^ ( 1 / ( gammath - 1 ) ) );
else
% -- Assuming choked, determine static pressure and tempurature --
	Psth = PsMN1;
	lambdath = 1;
	qlambdath = 1;
end

% -- Calculate Flow out of nozzle --

WOut = WIn;
Kq = sqrt( ( 2 / ( gammath + 1 ) ) ^ ( ( gammath + 1 ) / ( gammath - 1 ) ) * ( gammath / Rth ) );
Woutcalc = Kq * PtIn * Cdth * AthroatIn * qlambdath * CV / sqrt( TtIn ) * 1e+3;
 
% -- Calculate velocity & gross thrust --

V = lambdath * CV * sqrt( ( 2 * gammath / ( gammath + 1 ) ) * Rth * TtIn );
FgOut = ( WOut * V + ( Psth - PambIn ) * AthroatIn * 1e+3 ) * CX;
 
% -- Compute Normalized Flow Error --

if ( WIn == 0 )
	NErrorOut = 100;
else 
	NErrorOut = ( WIn - Woutcalc ) / WIn ;
end

% -- Assign output values --

OthrData = [Woutcalc];
    
end