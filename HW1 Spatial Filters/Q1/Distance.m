function [ Output ] = Distance( X,Y )
    dX = abs(X(1)-Y(1));
    dY = abs(X(2)-Y(2));
    Output = sqrt(power(dX,2)+power(dY,2));
end

