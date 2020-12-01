function F = filenameByMID( mid , path )
%% function F = filenameByMID( mid , path )
%
% input:  mid:  Number of the scan as written in the filename ('*_MIDxxx_*'),
%               where xxx is the mid and * is a wildcard.
%         path: Optional, without specifying it, './ is used.
% output: F:    Filename

% Jakob Asslaender, Uniklinik Freiburg, Aug. 2013


if nargin < 2 || isempty(path)
    path = './';
end


%s = ls;
if isunix
    eval(['[status, s] = unix(''ls ', path, '*.dat'');']);
elseif ispc
    eval(['[status, s] = dos(''dir ', '*.dat'');']);
end
    
    
s = textscan(s, '%s');

% JA: i takes the values 1 and 5, since so far all VB-Versions and VD11 had
%     mid's without any zeros in advance, VD13 now seems write with fixed 5
%     digits.
for i=1:4:5
    midstr = ['_MID', num2str(mid, ['%', num2str(i), '.', num2str(i), 'u']), '_'];
    for k=1:length(s{1})
        I = strfind(s{1}{k}, midstr);
        if ~isempty(I)
            F = s{1}{k};
            return;
        end
    end
end
F = [];