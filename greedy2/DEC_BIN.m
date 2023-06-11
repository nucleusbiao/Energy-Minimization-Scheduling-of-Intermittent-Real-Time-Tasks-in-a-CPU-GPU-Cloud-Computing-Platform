function BIN = DEC_BIN(dec,width)
BIN=zeros(1,width);
for i= 0:width
    if dec==0
        BIN=zeros(width);
        real=0;
        break
    
    elseif 2^i>=dec
        real = i;
        BIN(real)=1;
        real =real -1;
        dec=dec-2^(real);
        break

    elseif 2^i==dec
        real=i+1;
        BIN(real)=1;
        real = real-1;
        dec=dec-2^real;
        break
    end
    
end
while real >= 1
    if 2^(real-1)>dec
        BIN(real)=0;
        real = real-1;
    elseif 2^(real-1)<dec
         BIN(real)=1;
         real=real-1;
         dec=dec-2^real;
    elseif 2^(real-1)==dec
        BIN(real)=1;
        if real>1
            BIN(1:real-1)=0;
        end
        break
    end
end
for i=1:width
    BIN_real(i)=BIN(width+1-i);
end
BIN=BIN_real;
end