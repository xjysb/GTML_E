%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright (c) 2014-2018
% Athor: Yang Shubo
% Date: 2018/12/14
% Version: 1.0
% Describe:
% 	Give an increasing vector 'x(n)' and 'xi' 
% return last position 'il' where 'x(il) <= xi'
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function il = FindPos( x, xi )

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
end