function [ tau ] = MakeTau( xy, mics )
%MAKETAU Calculates the time delay of arrival between the microphones.
% tau > 0 if an acoustic source reaches mic 0 earlier than mic m
    fs = 48000;

    X = 1;
    Y = 2;
    
    mics = mics;
    
    xy = xy;
    x = xy(X);
    y = xy(Y);
    
    v = 340.3;
    
    % tau = TDOA between microphones.
    % tau is in s
    taum =  @(m,x,y) (...
        sqrt( (mics(m,X)-x)^2 + (mics(m,Y)-y)^2) - ...
        sqrt( x^2 + y^2 )) / v;

    tau = fs * [ taum(1, x, y),    ...
                 taum(2, x, y),    ...
                 taum(3, x, y)];
end

