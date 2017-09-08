%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright (c) 2014-2015
% Athor: Yang Shubo & Long Yifu
% Date: 2014/12/10
% Version: 1.0
% Describe:
% 	Give an increasing vector 'x(n)' and vector 'v(n)' and 'xi' 
% return 1-D interp result 'vi'
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function vi = Interpolation( x, v, xi )

    n = length( x );
    
    %	Find 'ih'&'il' by BinarySearch method, means 'x( il ) < xi <= x( ih )'.  
    if ( xi < x( 2 ) )
        il = 1;
    elseif ( xi > x( n - 1 ) )
        il = n - 1;
    else
        st = 1;
        ed = n;
        while ( ed - st > 1 )
            mid = floor( ( st + ed ) / 2 );
            if ( x( mid ) < xi )
                st = mid;
            else
                ed = mid;
            end
        end
        il = floor( st );
    end
    ih = il + 1;
    
    prm = ( xi - x( il ) ) / ( x( ih ) - x( il ) );
    vi = v( il ) + prm * ( v( ih ) - v( il ) );
    
end