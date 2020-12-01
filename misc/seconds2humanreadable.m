function [t, tstr] = seconds2humanreadable(s)

% function [t, tstr] = seconds2humanreadable(s)
%
% decomposes a number of seconds into years, days, hours, minutes and seconds
%
% t = [sec, min, hours, days, years];


s = round(s);

sm = 60;
sh = sm*60;
sd = sh*24;
sy = sd*365;

tstr = '';

if s>=sy
    t1 = floor(s/sy);
    s = s - t1*sy;
    tstr = [tstr, num2str(t1), 'y '];
else
    t1 = 0;
end

if s>=sd
    t2 = floor(s/sd);
    s = s - t2*sd;
    tstr = [tstr, num2str(t2), 'd '];
else
    t2 = 0;
end

if s>=sh
    t3 = floor(s/sh);
    s = s - t3*sh;
    tstr = [tstr, num2str(t3), 'h '];
else
    t3 = 0;
end

if s>=sm
    t4 = floor(s/sm);
    s = s - t4*sm;
    tstr = [tstr, num2str(t4), 'm '];
else
    t4 = 0;
end

t5 = s;

t = [t5,t4,t3,t2,t1];

if t5==0
    if all(t(2:end)==0)
        tstr = [tstr, num2str(t5), 's'];
    else
        tstr = sprintf([tstr]);
    end
else
    tstr = [tstr, num2str(t5), 's'];
end

t(t==0) = [];

if isempty(t);
    t = 0;
end