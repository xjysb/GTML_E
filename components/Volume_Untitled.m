%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright (c) 2014-2015
% Athor: Yang Shubo
% Date: 2014/09/07
% Version: 1.0
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [dPt, dTt] = Volume_Untitled( Tt_in, W_in, Wf, Pt_state, Tt_state, W_out, volume )

%T:K
%W:kg/s
%P:kPa
%dP:kPa/s
%dT:K/s
%volume:m^3

f = Wf / ( W_in - Wf );
H_in = H_T( Tt_in );
H_out = H_T( Tt_state );
Cp = Cp_T( Tt_state );
R = gas_constant( f );

mnet = W_in-W_out;
hnet = H_in*W_in-H_out*W_out;
dTt=((R*Tt_state)/(volume*Pt_state*1e3)/(Cp-R))*(-(H_out-R*Tt_state)*mnet+hnet);
dPt=(R/volume)*((Tt_state-((H_out-R*Tt_state)/(Cp-R)))*mnet+(1/(Cp-R))*hnet);
dPt=dPt*1e-3;

end