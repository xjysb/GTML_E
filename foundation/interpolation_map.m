%%%%%%%%%%%%%%%%%%%%%%%%%
% Informal version
%%%%%%%%%%%%%%%%%%%%%%%%%

function c=interpolation_map(a,b,ax,bx,pcx)

na = length(ax);
nb = length(bx);

ih = 0;  

if a >=ax(na)
    a = ax(na);
end

if a<=ax(1)
    a = ax(1);
end

for i=1:na
    ih=i;
    if a<ax(i)
        break;
    end
end

il=ih-1;
prm=(a-ax(il))/(ax(ih)-ax(il));

cx=pcx(il,:)+prm*(pcx(ih,:)-pcx(il,:));

bh=b;

if b>=bx(nb)
    bh = bx(nb);
end

if b<=bx(1)
    bh = bx(1);
end

c=Interpolation(bx,cx,bh);

end