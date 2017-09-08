%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Untitled -- Mixer_Untitled.c
% written by Yang Shubo
% Aeroengine Control Library, Beihang University
% July 7th, 2015

% version 1.1
%
% Msg:  0 or -ABC, 0 means ok, -ABC means warnning
%       A: flow of primary input, 1 : too small, 2 : too large 
%       B: flow of secondary input, 1 : too small, 2 : too large
%       C: pressure of primary input, 1 : too small, 2 : too large
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [ GasPthCharOut, NErrorOut, OthrData, Msg ] = Mixer_Untitled( GasPthCharIn1, GasPthCharIn2, Adesign1, Adesign2 )

% -- Load data --

WIn1 = 0;
TtIn1 = 0;
PtIn1 = 0;
FARcIn1 = 0;
WIn2 = 0;
TtIn2 = 0;
PtIn2 = 0;
FARcIn2 = 0;

if length( GasPthCharIn1 ) == 5
WIn1 = GasPthCharIn1( 1 );
TtIn1 = GasPthCharIn1( 3 );
PtIn1 = GasPthCharIn1( 4 );
FARcIn1 = GasPthCharIn1( 5 );
end

if length( GasPthCharIn2 ) == 5
WIn2 = GasPthCharIn2( 1 );
TtIn2 = GasPthCharIn2( 3 );
PtIn2 = GasPthCharIn2( 4 );
FARcIn2 = GasPthCharIn2( 5 );
end

% -- Calculate Flow out of mixer --

WOut = WIn1 + WIn2;

% -- Calculate output fuel to air ratio --

Wftot = FARcIn1 * WIn1 / ( 1 + FARcIn1 ) + FARcIn2 * WIn2 / ( 1 + FARcIn2 );
FARcOut = Wftot / ( WOut - Wftot );

% --  Calculate total output temperature --
 
htin1 = H_T( TtIn1, FARcIn1 );
htin2 = H_T( TtIn2, FARcIn2 );
htOut = ( WIn1 * htin1 + WIn2 * htin2 ) / WOut;
TtOut = T_H( htOut, FARcOut );

% --  Calculate lambda1 --

RIn1 = gas_constant( FARcIn1 );
CpIn1 = Cp_T( TtIn1, FARcIn1 );
gammaIn1 = CpIn1 / (CpIn1 - RIn1);
Kqlambda1 = sqrt( gammaIn1/RIn1*( (2/(gammaIn1+1))^((gammaIn1+1)/(gammaIn1-1)) ) );
qlambdaIn1 = ( WIn1 * sqrt( TtIn1 ) ) / ( Kqlambda1 * Adesign1 * PtIn1 * 1e3 );
[ lamada1, ~, message ] = lambda_root( qlambdaIn1, gammaIn1 );
Msg = message;

% --  Calculate lambda2 --

RIn2 = gas_constant( FARcIn2 );
CpIn2 = Cp_T( TtIn2, FARcIn2 );
gammaIn2 = CpIn2 / (CpIn2 - RIn2);
Kqlambda2 = sqrt( gammaIn2/RIn2*( (2/(gammaIn2+1))^((gammaIn2+1)/(gammaIn2-1)) ) );
qlambdaIn2 = ( WIn2 * sqrt( TtIn2 ) ) / ( Kqlambda2 * Adesign2 * PtIn2 * 1e3 );
[ lamada2, ~, message ] = lambda_root( qlambdaIn2, gammaIn2 );
Msg = Msg * 10 + message;

% --  Calculate output Area --

AOut = Adesign1 + Adesign2;

% --  Calculate output Impulse --

flamada1 = (lamada1^2+1) * (1-(gammaIn1-1)/(gammaIn1+1)*lamada1^2)^(1/(gammaIn1-1));
flamada2 = (lamada2^2+1) * (1-(gammaIn2-1)/(gammaIn2+1)*lamada2^2)^(1/(gammaIn2-1));
ImpulseIn = PtIn1*Adesign1*flamada1 + PtIn2*Adesign2*flamada2;

% --  Iterate to find output pressure, calculated from errors in Impulse --

ROut = gas_constant( FARcOut );
CpOut = Cp_T( TtOut, FARcOut );
gammaOut = CpOut / (CpOut - ROut);
PtOut = ( PtIn1 * WIn1 + PtIn2 * WIn2 ) / WOut;
KqlambdaOut = sqrt( gammaOut/ROut*( (2/(gammaOut+1))^((gammaOut+1)/(gammaOut-1)) ) );
qlambdaOut = WOut * sqrt( TtOut ) / AOut / PtOut / 1e3 / KqlambdaOut; 
[ lambdaOut, ~, ~ ] = lambda_root( qlambdaOut, gammaOut );

flambdaOut = (lambdaOut^2+1) * (1-(gammaOut-1)/(gammaOut+1)*lambdaOut^2)^(1/(gammaOut-1));
ImpulseOut = flambdaOut * PtOut * AOut;
Err = ( ImpulseIn - ImpulseOut ) / ImpulseIn;
PtOut_new = PtOut + 0.05;

if ( Msg == 0 )
    for i_sum = 1 : 20
    
        Err_old = Err;
        PtOut_old = PtOut;
        if ( abs( PtOut_new - PtOut ) < 0.03 )
            PtOut = PtOut + 0.05;
        else
            PtOut = PtOut_new;
        end
        qlambdaOut = WOut * sqrt( TtOut ) / AOut / PtOut / 1e3 / KqlambdaOut; 
        [ lambdaOut, ~, ~ ] = lambda_root( qlambdaOut, gammaOut );
        flambdaOut = (lambdaOut^2+1) * (1-(gammaOut-1)/(gammaOut+1)*lambdaOut^2)^(1/(gammaOut-1));
        ImpulseOut = flambdaOut * PtOut * AOut;
        Err = ( ImpulseIn - ImpulseOut ) / ImpulseIn;
        %-- Determine error --
        if ( abs( Err ) < 1e-7 )
            break;
        end
        %-- Determine next guess pressure by secant algorithm --
        PtOut_new = PtOut - Err * (PtOut - PtOut_old) / (Err - Err_old);
        %-- Limit algorthim change --
        if ( PtOut_new > 1.1*PtOut )
            PtOut_new = 1.1 * PtOut;
        elseif ( PtOut_new < 0.9*PtOut )
            PtOut_new = 0.9 * PtOut;
        end
    end
end

%-- Calculate secondary flow --
pilambda1 = (1-(gammaIn1-1)/(gammaIn1+1)*lamada1^2)^(gammaIn1/(gammaIn1-1));
PsIn = PtIn1 * pilambda1;
pilambda2 = PsIn / PtIn2;
%-- Limit pilambda range --
if ( pilambda2 < 0.01 )
    pilambda2 = 0.01;
    message = -1;
elseif ( pilambda2 > 1 )
    pilambda2 = 1;
    message = -2;
else
    message = 0;
end
Msg = Msg * 10 + message;
lambda2c = sqrt( (gammaIn2+1)/(gammaIn2-1) * (1 - pilambda2^((gammaIn2-1)/gammaIn2)) );
qlambdaIn2c = ((gammaIn2+1)/2)^(1/(gammaIn2-1)) * (1-((gammaIn2-1)/(gammaIn2+1)*lambda2c^2))^(1/(gammaIn2-1)) * lambda2c;
WIn2c = Kqlambda2 * PtIn2*1e3 * Adesign2 * qlambdaIn2c / sqrt(TtIn2);

%-- Compute normalized error --
if ( WIn2 == 0 )
	NErrorOut = 100;
else
    NErrorOut = ( WIn2 - WIn2c ) / WIn2;
end

%-- Assign output values --
GasPthCharOut = zeros( 1, 5 );
GasPthCharOut( 1 ) = WOut;
GasPthCharOut( 2 ) = htOut;
GasPthCharOut( 3 ) = TtOut;
GasPthCharOut( 4 ) = PtOut;
GasPthCharOut( 5 ) = FARcOut;
OthrData = WIn2c;

end

function [ lambda, i_sum, message ] = lambda_root( q_lambda0, k )
	
    %-- Limit qlambda range --
    if ( q_lambda0 < 0.01 )
        q_lambda0 = 0.01;
        message = -1;
    elseif ( q_lambda0 > 1 )
        q_lambda0 = 1;
        message = -2;
    else
        message = 0;
    end
    
	lambda = q_lambda0;
	q_lambda = ((k+1)/2)^(1/(k-1)) * lambda * (1-(k-1)/(k+1)*lambda^2)^(1/(k-1));
	Err = ( q_lambda0 - q_lambda ) / q_lambda0;
	lambda_new = lambda + 0.05;
	for i_sum = 1 : 20
		
		lambda_old = lambda;
		Err_old = Err;
		lambda = lambda_new;
		q_lambda = ((k+1)/2)^(1/(k-1)) * lambda * (1-(k-1)/(k+1)*lambda^2)^(1/(k-1));
		Err = ( q_lambda0 - q_lambda ) / q_lambda0;
		if ( abs( Err ) < 1e-7 )
			break;
		end
		lambda_new = lambda - Err * ( lambda - lambda_old ) / ( Err - Err_old );
        %-- Limit algorthim change --
        if ( lambda_new > 1.1*lambda )
            lambda_new = 1.1 * lambda;
        elseif ( lambda_new < 0.9*lambda )
            lambda_new = 0.9 * lambda;
        end
	end
	
end