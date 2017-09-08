%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright (c) 2014-2015
% Athor: Yang Shubo
% Date: 2014/09/05
% Version: 1.0
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
function r = gas_constant(f)

%f:Wf/W3
%r:J/(kg*K)

r=287.05-0.00990*f+1e-7*f^2;

end