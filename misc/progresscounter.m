function out = progresscounter(maxcounter,msg,eta_flag)

% function progresscounter(maxcounter,msg)
%
% Displays a progress counter. Use in the following way:
%
% for m=1:M
%   for n=1:N
%     <do some stuff>
%     progressbar(N*M,msg);
%   end
% end
%
% counter = an integer in the range of [1:maxcounter]
% maxcounter = denotes the number of iterations.
% msg = optional text that is displayed
%
% Note: maxcounter needs to be the exact amount of iterations
% otherwise progressbar gets confused. In this case
% use progressbar('clear') to fix that.


Nu = 100; % number of updates

if nargin<=1 || isempty(msg)
    msg = 'Processing ... ';
end

if nargin<=2
    eta_flag = 1;
end

if strcmp(maxcounter,'clear')
    clear counter tstart str;
    return;
end

persistent counter;
persistent tstart;
persistent str;

if isempty(counter)
    str = [msg, ' ', '0%%'];
    out = str;
    if nargout==0
        fprintf(str);
    end
    counter = 1;
    tstart = tic;
end



wa = ceil(maxcounter/Nu);
if rem(counter,wa)==0 || counter==maxcounter
    if counter==1
        tstr = [];
    else
        telapsed = toc(tstart);
        texp = maxcounter * telapsed/counter;
        [teta, tstr] = seconds2humanreadable(texp - telapsed);
    end
    
    bspc = repmat('\b',[1 length(str)-1]);
    if nargout==0
        fprintf(bspc);
    end
    
    if eta_flag
        str = [msg, num2str(round(100*counter/maxcounter)), '%%', ' - ETA: ',tstr];
    else
        str = [msg, num2str(round(100*counter/maxcounter)), '%%'];
    end
    
    out = str;
    if nargout==0
        fprintf(str);
    end
end

if counter==maxcounter
    clear counter tstart str;
    if nargout==0
        fprintf('\n');
    end
else
    counter = counter + 1;
end

