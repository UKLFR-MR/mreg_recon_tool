function [header headerascii]=readVB17Header(datfilename);
% function headers=read_dat_headers(datfilename);
%
% function to read Siemens dat file headers for meas.dat (VB17)
%
% header.ascii is output structure containing ascii protocol data
%     headerascii.Config
%     headerascii.Dicom
%     headerascii.Meas          (don't exist in VB13!)
%     headerascii.MeasYaps
%     headerascii.Phoenix
%     headerascii.Spice
%
% header.protocol is a Matlab structure corresponding to ascii data
%     header.Config
%     header.Dicom
%     header.Meas           (don't exist in VB13!)
%     header.MeasYaps
%     header.Phoenix        (contains header.Phoenix.part1 and header.Phoenix.part2)
%     header.Spice

       

%     ***************************************
%     *  Peter Kellman  (kellman@nih.gov)   *
%     *  Laboratory for Cardiac Energetics  *
%     *  NIH NHLBI                          *
%     ***************************************

%     ***************************************
%     *  Daniel Weber (weber@mr-bavaria.de) *
%     ***************************************


fid=fopen(datfilename,'r');

hdrlen=fread(fid,1,'int32');
nbuffers=fread(fid,1,'int32');
for i=1:nbuffers
   tmp=1;
   name{i}=[];
   while tmp~=0;
       tmp=fread(fid,1,'char');
       name{i}=[name{i},tmp];
   end
   name{i}=char(name{i}(1:end-1));
   length(i)=fread(fid,1,'int32');
   tmp=char(fread(fid,length(i),'char')');
   eval(['headerascii.',name{i},'= tmp;']);   
end

%if nargout==2
    % Weil die Funktion MeasYaps2struct() auch einen Teil der Phoenix-Daten
    % auslesen kann wird sie auch darauf losgelassen:
    
    if isfield(headerascii, 'Config');      header.Config             = Config2struct(    headerascii.Config); end
    if isfield(headerascii, 'Dicom');       header.Dicom              = Config2struct(    headerascii.Dicom); end
    if isfield(headerascii, 'Meas');        header.Meas               = Config2struct(    headerascii.Meas); end
    if isfield(headerascii, 'MeasYaps');    header.MeasYaps           = MeasYaps2struct(  headerascii.MeasYaps); end
    if isfield(headerascii, 'Phoenix');     header.Phoenix.part1      = Config2struct(    regexprep(headerascii.Phoenix, '([^#]*)(.*)', '$1')); end     % Phoenix enthält zwei Teile, also beide Strukturtypen kommen vor
    if isfield(headerascii, 'Phoenix');     header.Phoenix.part2      = MeasYaps2struct(  regexprep(headerascii.Phoenix, '([^#]*)(.*)', '$2')); end     % Werden deshalb aufgeteilt und mit den entspr. Funktionen ausgewertet
    if isfield(headerascii, 'Spice');       header.Spice              = Config2struct(    headerascii.Spice); end
    
%end
fclose(fid);

% header description
% // |X X X X|X X X X|X X X X X....0|X X X X|X X X X X.....|X X X X X X....0|X X X X|X X X X X.....|XXXX..............|XXXX....
% // |4 bytes|4 bytes|   x Bytes    |4 Bytes|     x Bytes  |    x Bytes     |4 Bytes|  x Bytes     | padding          | data
% // |hdr len|buf nr.| name 1       |len 1  | prot 1       | name 2         |len 2  | prot 2       | 32byte aligned   |
% 
% Description:
% First 4 Bytes: Overall length of header (hdr len).
% This can be used to hop directly to the raw data.
% The next 4 bytes indicates the number of embedded data structures (buf nr.)
% Each data structure starts with a name (e.g. name 1):
% this is a NULL terminated string, then the next 4 bytes are
% indicating the length (e.g. len 1) of the data structure and
% the data structure (e.g. prot 1) itself.

end













function header=MeasYaps2struct(MeasYaps);
% function header=MeasYaps2struct(headers);
%
% function to covert MeasYaps from text to Matlab structure

%     ***************************************
%     *  Peter Kellman  (kellman@nih.gov)   *
%     *  Laboratory for Cardiac Energetics  *
%     *  NIH NHLBI                          *
%     ***************************************

%MeasYaps=headers.MeasYaps;
lf = find(double(MeasYaps)==10); % find positions of line feeds
lf = [0,lf];

for line=1:length(lf)-1
    tline = MeasYaps(lf(line)+1:lf(line+1)-1);
    if ~ischar(tline); return; end
    index=findstr(tline,'=');
    
    if ~isempty(index)
        fieldname=deblank(tline(1:findstr(tline,'=')-1));
        fieldvalue=deblank(tline(findstr(tline,'=')+1:end));
        if max(isletter(fieldvalue))==0
            fieldvalue=str2num(fieldvalue);
        end
        fieldname=strrep(fieldname,'[','{');
        fieldname=strrep(fieldname,']','}');
        index2=findstr(fieldname,'{');
        index3=findstr(fieldname,'}');
 
%coding changes - vmpai - for vb12+ versions of IDEA. June 2005        
      
%         if ~isempty(index2)
%             fieldname = strrep(fieldname,fieldname(index2+1:index3-1),...
%                 num2str(str2num(fieldname(index2+1:index3-1))+1));
%         end

        eb = size(index2,2);
        ee = size(index3,2);
      
        strs = eb + 1;
        nums = eb;
        
        if ~isempty(index2)

            %split out the character portions of the statement
            str(1) = {fieldname(1:index2(1))};
            for i = 2:strs-1
                str(i) = {fieldname(index3(i-1):index2(i))};
            end
            str(strs) = {fieldname(index3(strs-1):end)};
            
			%pull out, increment and reconvert to string the numeric portion of the
			%statement
			for i=1:nums
                numstr(i) = {num2str(str2num(fieldname(index2(i)+1:index3(i)-1))+1)};
			end

			%combine the string and the numeric portions of the statement
			nstr = '';
            for i=1:eb
                nstr = strcat(nstr, str(i), numstr(i));
			end
            
           %convert from cell array to char array before pushing back in.
           fieldname = char(strcat(nstr,str(strs)));
%end coding change - vmpai - june 2005.           
        end
        eval(['header.',fieldname,'= fieldvalue;']);
    end
end

end










function header=Config2struct(headers);
% function header=Config2struct(headers);
%
% function to covert Config et al. from text to Matlab 'structure'
%
%     ***************************************
%     *  Daniel Weber (weber@mr-bavaria.de) *
%     ***************************************
%
% Das ist bisher eine SEHR rudimentäre Implementierung!
% Die Daten werden alle ohne Struktur eingelesen, nur immer Variablenname
% und der entsprechende Wert. Da die Daten eigentlich eine Struktur
% besitzen kann es unter Umständen vorkommen, dass Werte überschrieben
% werden!
%
% Bessere Alternative:
% 
% Die Parameter liegen im Siemens-Format evp vor (siehe
% http://www.mr-idea.com/idea%5Cmessages/4822.html und die Antworten dazu),
% welches ähnlich wie ein xml-File aufgebaut ist. Das sog. EvaProtocol kann
% wohl auch in evp oder xml ausgegeben werden. Auf S.150-154 im Ice Users
% Guide (IceUsersGuide_VB15B.pdf) steht auch was dazu, wie aus dem
% .dat-File mit EHE das Headerzeug aus dem .dat-File extrahiert werden
% kann. Die Strings liegen hier aber in headers auch schon vor. Man könnte
% also einen Parser in Matlab schreiben, der evp2xml macht, und das
% xml-Zeug dann z.B. mit der xml-Toolbox von
% http://www.mathworks.com/matlabcentral/fileexchange/4278 in eine
% Matlab-Structure verwandlen. Als Inspiration:
% 
% bla = headers.Dicom;
% bla = regexprep(bla, '<(\w*)\."(\w*)">\s*{\s*([^{}]*)}', '<$2 type="$1">$3</$2>')
% bla = regexprep(bla, '([\w"]) *<', '$1<')
% bla = regexprep(bla, '><Precision>\s*([0-9]*)\s*', ' precision="$1">')
% ...
% 
% Macht an der Stelle zu viel Arbeit, brauchen wir im Moment nicht. Aber
% falls mal jemandem langweilig sein sollte...
% 
% 
% 
% 
% 



%% ParamString:
    [start_idx, end_idx, extents, matches, tokens] = regexp(headers, '<ParamString\."(\w+)">\s*{([^}]*)');
    for m=1:size(matches,2)
        Variable    = char(tokens{m}(1));
        Wert        = char(strrep(strtrim(tokens{m}(2)),'"',''));
        % Bisschen säubern:
        [Variable, Wert] = clearVariableWert(Variable, Wert);
        
        eval(['header.' Variable '=''' Wert ''';']);
    end

%% ParamLong:
    [start_idx, end_idx, extents, matches, tokens] = regexp(headers, '<ParamLong\."(\w+)">\s*{([^}]*)');
    for m=1:size(matches,2)
        Variable    = char(tokens{m}(1));
        Wert        = char(strtrim(tokens{m}(2)));
        % Bisschen säubern:
        [Variable, Wert] = clearVariableWert(Variable, Wert);
        
        
        % Falls der Wert leer ist (also hier ein leerer String) soll er den Wert "0" bekommen:
        if isempty(Wert)
            Wert='0';
        end
        % Manchmal ist der Wert ein Array (getrennt durch mindestens ein Leerzeichen), dann auch zu einem machen:
        if ~isempty(strfind(Wert, ' '))
            % kann auch sein, dass die Werte aucf mehrere Zeilen verteilt sind:
            Wert = regexprep(Wert, '\n', ' ');
            % evtl. doppelte Leerzeichen entfernen:
            Wert = regexprep(Wert, ' +', ' ');
            % Klammern hinzufügen, damit die Werte bei eval() als Array gefressen werden:
            Wert = ['[' Wert ']'];
        end
            
        eval(['header.' Variable '=' Wert ';']);
    end


%% ParamDouble:
    [start_idx, end_idx, extents, matches, tokens] = regexp(headers, '<ParamDouble\."(\w+)">\s*{\s*(<Precision>\s*[0-9]*)?\s*([^}]*)');
    for m=1:size(matches,2)
        Variable    = char(tokens{m}(1));
        Wert        = char(strtrim(tokens{m}(3)));
        % Bisschen säubern:
        [Variable, Wert] = clearVariableWert(Variable, Wert);
        
        
        % Falls der Wert leer ist (also hier ein leerer String) soll er den Wert "0" bekommen:
        if isempty(Wert)
            Wert='0';
        end
        % Manchmal ist der Wert ein Array (getrennt durch mindestens ein Leerzeichen), dann auch zu einem machen:
        if ~isempty(strfind(Wert, ' '))
            % kann auch sein, dass die Werte aucf mehrere Zeilen verteilt sind:
            Wert = regexprep(Wert, '\n', ' ');
            % evtl. doppelte Leerzeichen entfernen:
            Wert = regexprep(Wert, ' +', ' ');
            % Klammern hinzufügen, damit die Werte bei eval() als Array gefressen werden:
            Wert = ['[' Wert ']'];
        end
            
        eval(['header.' Variable '=' Wert ';']);
    end

%% ParamBool:
    [start_idx, end_idx, extents, matches, tokens] = regexp(headers, '<ParamBool\."(\w+)">\s*{([^}]*)');
    for m=1:size(matches,2)
        Variable    = char(tokens{m}(1));
        Wert        = char(strrep(strtrim(tokens{m}(2)),'"',''));
        % Bisschen säubern:
        [Variable, Wert] = clearVariableWert(Variable, Wert);
        
        if strcmp(Wert, 'true')
            eval(['header.' Variable '=true;']);
        else
            eval(['header.' Variable '=false;']);
        end
    end


end


function [Variable, Wert] = clearVariableWert(Variable, Wert)
%function [Variable, Wert] = clearVariableWert(Variable, Wert)

    % Variablennamen muss mit Letter anfangen:
    while ~isletter(Variable(1)); Variable=Variable(2:end); end

    % Manchmal stehen vor dem Wert noch bspw:
    %   <Label> "Before measurement" 
    %   <MinSize> 1 
    %   <MaxSize> 1000000000
    %   <LimitRange> { 1 100 }
    % Manchmal stehen die Sachen auch in EINER Zeile...
    % Das muss noch entfernt werden:
    Wert = strtrim(regexprep(Wert, ' *<\w*> *[^\n]*', ''));
    
    
    % Falls sich ein Wert über mehrere Zeilen erstreckt sollten sie noch
    % einzeilig gemacht werden:
    Wert = regexprep(Wert, ' *\n *', ' ');
    
end



