function T2=shells_tse(N,R_radial0,R_radialEnd,R_parallel0,R_parallelEnd,rect_flag)

if nargin < 6
    rect_flag = 0;
end

if nargin == 3
    R_parallel0 = R_radial0;
    R_parallelEnd = R_radialEnd;
end

if nargin == 0
    R_radial0       = 2;
    R_radialEnd     = 2;
    R_parallel0     = 2;
    R_parallelEnd   = 5;
end

fov=0.256;%[m]
kmax0 = (1/fov)*(N/2.0); %should be in[1/m]  , fix the voxel size to fov/64

SYSTEM=GradSystemStructure('slow');

%% Set up the parameters for the individual shells
deltak_full_r = kmax0/(N/2);
[k_vd n] = radial_sampling_density(R_radial0,R_radialEnd,1,N/2);

shell_radius = kmax0*k_vd;
deltak_full_p = deltak_full_r;
a_full = pi./asin((deltak_full_p./(2*shell_radius(2:end))));

Rp_ink=(R_parallelEnd- R_parallel0)/length(shell_radius(2:end));
if Rp_ink == 0
    Rp = R_parallel0*ones(1,length(a_full));
else
    Rp = R_parallel0 :Rp_ink:R_parallelEnd;
end
a_accelerated = a_full./Rp(1:length(a_full));
%% Create all single elements

sign=1;
for m=1:n-1
    T(m)=single_element_shell(round(a_accelerated(m)/2),shell_radius(m+1),sign,SYSTEM,0,rect_flag);
    sign = -sign;
    durations(m)=T(m).duration;
    display(m)
end



%% group shorter elements
max_duration = max(durations);

n_start =1;
m=1;
while(n_start < length(T))
    dsum=cumsum(durations);
    l=find(~(dsum < max_duration),1,'first');
    l=l-1;
    E{m}=n_start:(n_start-1)+l;
    durations=durations(l+1:end);
    n_start = n_start+l;
    m=m+1;
end

%prolong single elements
for n=1:length(E)
    if (length(E{n}) == 1)
        d = T(E{n}(1)).duration;
        i=0;
        while d < 0.98*max_duration
            
            a=round(a_accelerated(E{n}(1))/2)+i;
            test=single_element_shell(a,shell_radius(E{n}(1)+1),sign,SYSTEM,0,rect_flag);
            d=test.duration;
            display(d)
            if d > 0.98*max_duration 
                break;
            else
                T(E{n}(1)) = test;
            end
            i=i+1;
            display(i)
        end
       
    end
display(n)
end

for n=1:length(E)
    T2(n)=T(E{n}(1));
    if length(E{n}) > 1
        for k=1:length(E{n})-1
            T2(n)=trajectStruct_connect(T2(n),T(E{n}(k+1)));
        end
    end
end

%% make better use of available inter echo duration
%for n=3:length(T2)
%    if( T2(n).duration < 0.9*max_duration)
%        tmp=
%end

%% rotate elements and balance gradient (dephase and rephase gradient)
alpha= 0;
for l=1:length(T2)
    T2(l) = trajectStruct_rotate(T2(l),alpha,[0 0 1]);
    alpha = alpha + pi;
    T2(l)=trajectStruct_balance(T2(l));
end


