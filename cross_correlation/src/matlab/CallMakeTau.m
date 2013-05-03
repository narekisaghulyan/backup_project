mics = [ 0, 0.16; ...
         0.16, 0.16; ...
         0.16, 0];

xy = [ -7,17 ];

tau = MakeTau(xy, mics)

dir = -tau * mics;

normdir = dir/norm(dir)

angle = atan(normdir(2)/normdir(1))*180/pi

%sinecraft

%sine1 = hex2dec(dlmread('sines1.hex'));
%sine2 = hex2dec(dlmread('sines2.hex'));

%xcorr(sine1,sine2)

