function I = kwicSort(Kin, Iin)

% function I = kwicSort(Kin, Iin)

if nargin==1
    Iin = cell(1,length(Kin));
    for n=1:length(Iin)
        Iin{n} = [1:size(Kin{n},1)];
    end
end

idxin = cell(1,length(Kin));
for n=1:length(Iin)
    idxin{n} = zeros(size(Kin{n},1),1);
    idxin{n}(Iin{n}) = 1;
    idxin{n} = boolean(idxin{n});
end



Ni = length(Kin);

if rem(log2(Ni),1)~=0
    warning('Number of interleaves should be an integer power of 2 for KWIC.');
    wflag = 1;
else
    wflag = 0;
end


rad = pi/(log2(Ni)+1);

idx = cell(1,length(Kin));
idx{1} = boolean( ones(size(Kin{1},1),1) );
for n=0:log2(Ni)-1
    kidx = 2^n+1:2^(n+1);
    for m=1:length(kidx)
        idx{kidx(m)} = (sqrt(sum(abs(Kin{kidx(m)}).^2,2)) >= (n+1)*rad);
    end
end

% cut out same range of points for the remaining interleaves
if wflag==1
    kidx = 2^(n+1)+1:Ni;
    for m=1:length(kidx)
        idx{kidx(m)} = (sqrt(sum(abs(Kin{kidx(m)}).^2,2)) >= (n+1)*rad);
    end
end

I = cell(1,Ni);
for n=1:length(Kin)
    idx{n} = col(idx{n}) .* col(idxin{n});
    I{n} = [1:size(Kin{n},1)];
    I{n}(~idx{n}) = [];
end
