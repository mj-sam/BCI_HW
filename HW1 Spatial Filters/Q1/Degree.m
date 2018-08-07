function [ Deg ] = Degree( X,Y )
    %% find the degree between two vector
    T1 = Y(1) - X(1);
    T2 = Y(2) - X(2);
    Rad = atan2(T2,T1);
    Deg = rad2deg(Rad);
    
%      Deg1 = atan2(T1(2),T1(1));
%      Deg1 = Deg1 * 360 / (2*pi)
%      Deg2 = atan2(T2(2),T2(1));
%      Deg2 = Deg2 * 360 / (2*pi)
%      Deg = Deg2 - Deg1;
    if Deg < 0
       Deg = Deg + 360;
    end

end

