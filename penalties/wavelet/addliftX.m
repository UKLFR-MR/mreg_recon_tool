function LSN = addliftX(LS,ELS,loc)
%ADDLIFT Add primal or dual liftingX steps.
%   LSN = ADDLIFT(LS,ELS) returns the new liftingX
%   scheme LSN obtained by appending the elementary
%   liftingX step ELS to the liftingX scheme LS.
%   
%   LSN = ADDLIFT(LS,ELS,'begin') prepends the specified 
%   elementary liftingX step.
% 
% 	ELS is either a cell array (see LSINFO) which format is: 
%        {TYPEVAL, COEFS, MAX_DEG}  
% 	or a structure (see LIFTFILT) which format is:
%         struct('type',TYPEVAL,'value',LPVAL) 
% 	with LPVAL = laurpoly(COEFS, MAX_DEG)
%
%   ADDLIFT(LS,ELS,'end') is equivalent to ADDLIFT(LS,ELS).
%
% 	If ELS is a sequence of elementary liftingX steps, stored 
% 	in a cell array or an array of structures, then each of
% 	the elementary liftingX steps is added to LS.
%
%   For more information about liftingX schemes type: lsinfoX.
%   
%   Examples:
%      LS = liftwaveX('db1')
%      els = { 'p', [-1 2 -1]/4 , [1] };
%      LSend = addliftX(LS,els)
%      LSbeg = addliftX(LS,els,'begin')
%      displsX(LSend)
%      displsX(LSbeg)
%      twoels(1) = struct('type','p','value',laurpoly([1 -1]/8,0));
%      twoels(2) = struct('type','p','value',laurpoly([1 -1]/8,1));
%      LStwo = addliftX(LS,twoels)
%      displsX(LStwo)
%
%   See also LIFTFILT.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 28-May-2001.
%   Last Revision: 08-Dec-2008.
%   Copyright 1995-2008 The MathWorks, Inc.
%   $Revision: 1.1 $  $Date: 2012/02/08 09:52:45 $

if nargin<3 ,loc = 'end'; end
loc = lower(loc(1:3));
structMODE = isstruct(ELS);
if structMODE
    switch loc
        case 'end' ,
            LSN =  LS(1:end-1,:);
            for k = 1:length(ELS)
                [C,D] = get(ELS(k).value,'coefs','maxDEG');
                one_els = {ELS(k).type,C,D};
                LSN = [LSN ; one_els];
            end
            LSN = [ LSN ; LS(end,:) ];
            
        case 'beg' ,
            LSN =  LS;
            for k = 1:length(ELS)
                [C,D] = get(ELS(k).value,'coefs','maxDEG');
                one_els = {ELS(k).type,C,D};
                LSN = [one_els ; LSN];
            end
    end
    return
end

cellMODE = ~(isequal(ELS{1,1},'p') || isequal(ELS{1,1},'d'));
if ~cellMODE
    switch loc
        case 'end' ,  
            LSN = [ LS(1:end-1,:) ; ELS ; LS(end,:) ];
        case 'beg' ,  
            LSN = [ ELS ; LS ];         
    end    
else
    switch loc
        case 'end' ,
            LSN =  LS(1:end-1,:);
            for k = 1:length(ELS)
                LSN = [ LSN ; ELS{k}];
            end
            LSN = [ LSN ; LS(end,:) ];
            
        case 'beg' ,
            LSN =  LS;
            for k = 1:length(ELS)
                LSN = [ ELS{k} ; LSN ];
            end
    end
end
