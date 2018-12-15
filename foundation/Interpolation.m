%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright (c) 2014-2018
% Athor: Yang Shubo & Long Yifu
% Date: 2018/12/14
% Version: 1.1
% Describe:
% 	Give an increasing vector 'x(n)' and vector 'v(n)' and 'xi' 
% return 1-D interp result 'vi'
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function vi = Interpolation( x, v, xi )

    il = FindPos( x, xi );
    ih = il + 1;
    
    prm = ( xi - x( il ) ) / ( x( ih ) - x( il ) );
    vi = v( il ) + prm * ( v( ih ) - v( il ) );
end