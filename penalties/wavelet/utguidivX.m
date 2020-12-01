function varargout = utguidivX(option,varargin)
%UTGUIDIV Utilities for testing inputs for different "TOOLS" files.
%   VARARGOUT = UTGUIDIV(OPTION,VARARGIN)

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 12-May-98.
%   Last Revision: 15-Jul-2009.
%   Copyright 1995-2009 The MathWorks, Inc.
%   $Revision: 1.1 $  $Date: 2012/02/08 09:52:45 $

switch option
    case 'ini'
        winAttrb = [];
        optval   = varargin{1};
        switch nargin
            case 2
                if ~ischar(optval)
                    winAttrb = optval; optval = 'create';
                end
            otherwise
                if isequal(optval,'create') ,  winAttrb = varargin{2}; end
        end
        varargout = {optval,winAttrb};
        
    case 'WTB_DemoPath'
        testfile = varargin{1};
        dum = which('sumsin.mat','-all');
        pathname = fileparts(dum{1});
        pathname = which([pathname filesep testfile]);
        if ~isempty(pathname)
            ind = findstr(pathname,testfile);
            pathname = pathname(1:ind-1);
        end
        varargout{1} = pathname;       
        
    case {'test_load','test_save'}
        mask = varargin{2};
        txt  = sprintf(varargin{3});
        switch option
            case 'test_load' , [filename,pathname] = uigetfile(mask,txt);
            case 'test_save' , [filename,pathname] = uiputfile(mask,txt);
        end
        ok = 1;
        if isempty(filename) || isequal(filename,0) , ok = 0; end        
        varargout = {filename,pathname,ok};
        
    case {'load_sig','load_dem1D'}
        fig  = varargin{1};
        switch option
            case 'load_sig'       
                mask = varargin{2};
                if isequal(mask,'Signal_Mask')
                    mask = {...
                       '*.mat;*.wav;*.au','Signal ( *.mat , *.wav , *.au)';
                       '*.*','All Files (*.*)'};
                end
                txt  = varargin{3};
                [filename,pathname,ok] = utguidivX('test_load',fig,mask,txt);
                
            case 'load_dem1D'
                pathname = varargin{2};
                filename = varargin{3};
                ok = 1;
        end
        
        % default.
        %---------
        sigInfos = struct(...
            'pathname',pathname, ...
            'filename',filename, ...
            'filesize',0,  ...
            'name','',     ...
            'size',0       ...
            );
        sig_Anal = [];
        
        if ok
            wwaitingX('msg',fig,'Wait ... loading');
            [sigInfos.name,ext,fullName,fileStruct,err] = ...
                getFileINFO(pathname,filename); %#ok<ASGLU>
            sigInfos.filesize = getFileSize(fullName);
            if ~err
                err = 1;
                for k = 1:length(fileStruct)
                    if isequal(fileStruct(k).class,'double')
                        siz = fileStruct(k).size;
                        if min(siz)==1 && max(siz)>1
                            err = 0;
                            sigInfos.name = fileStruct(k).name;
                            break
                        end
                    end
                end
                if ~err
                    try
                        load(fullName,'-mat');
                        sig_Anal = eval(sigInfos.name);
                    catch ME %#ok<NASGU>
                        err = 1; numMSG = 1;
                    end
                else
                    numMSG = 2;
                end
            else
                numMSG = 1;
                [sig_Anal,err,msg] = load_1D_NotMAT(pathname,filename);
                if ~isempty(msg) , numMSG = msg; end
            end
            if ~err
                err = ~isreal(sig_Anal);
                if err , numMSG = 4; end
            end        
            if err ,  dispERROR_1D(fig,sigInfos.filename,numMSG); end
            ok = ~err;
        end
        if ok
            if size(sig_Anal,1)>1 , sig_Anal = sig_Anal'; end
            sigInfos.size = length(sig_Anal);        
        end
        varargout = {sigInfos,sig_Anal,ok};
        
    case {'direct_load_sig'}
        pathname = varargin{2};
        filename = varargin{3};
        [sig_Anal,err] = load_1D_NotMAT(pathname,filename);
        ok = ~err;
        varargout = {sig_Anal,ok};
        
    case {'load_img','load_dem2D'}
        fig  = varargin{1}; 
        switch option
            case 'load_img'       
                mask = varargin{2};
                txt  = varargin{3};
                [filename,pathname,ok] = utguidivX('test_load',fig,mask,txt);
                
            case 'load_dem2D'
                pathname = varargin{2};
                filename = varargin{3};
                ok = 1;
        end
        default_nbcolors = varargin{4};
        if length(varargin)>4
            optIMG = varargin{5};
        else
            optIMG = 'none'; 
        end
        
        % default.
        %---------
        imgInfos = struct(...
            'pathname',pathname, ...    
            'filename',filename, ...
            'filesize',0,   ...    
            'name','',      ...
            'true_name','', ...
            'type','mat',   ...
            'self_map',0,   ...
            'size',[0 0]    ...
            );
        X = []; map = [];
        
        if ok
            wwaitingX('msg',fig,'Wait ... loading');
            [imgInfos.name,ext,fullName,fileStruct,err] = ...
                getFileINFO(pathname,filename); %#ok<ASGLU>
            imgInfos.filesize = getFileSize(fullName);
            if ~err
                err = 1;
                for k = 1:length(fileStruct)
                    [mm,idxMin] = min(fileStruct(k).size);
                    if mm>3
                        err = 0;
                        imgInfos.true_name = fileStruct(k).name;
                        break
                     
                    elseif  mm==3 && idxMin==3 && ...
                            length(fileStruct(k).size)==3
                        err = 0;
                        imgInfos.true_name = fileStruct(k).name;
                        break
                    end
                end
                if ~err
                    try
                        load(fullName,'-mat');
                        imgInfos.type = 'mat';
                        X = eval(imgInfos.true_name);
                        if ~exist('map','var')
                            map = [];
                        end
                        [X,err] = convertImage(optIMG,X,imgInfos.type,map);
                    catch ME    %#ok<NASGU>
                        err = 1; numMSG = 1;
                    end
                else
                    numMSG = 2;
                end
            else
                numMSG = 1;
                try
                    [X,map,imgFormat,colorType,err] = ...
                        load_2D_NotMAT(pathname,filename,optIMG);
                    if ~err
                        mi = min(X(:));
                        if mi<1 , X = X-mi+1; end
                        if isempty(map) && isequal(imgFormat,'mat')
                            ma  = max(X(:));
                            map = pink(ma);
                            X   = wcodematX(X,ma);
                        end
                        [dummy,name,ext] = fileparts(filename);
                        imgInfos.type = imgFormat;
                        imgInfos.name = [name,ext];
                        imgInfos.true_name = 'X';
                        err = 0;
                    else
                        numMSG = 3;
                    end
                catch ME
                    numMSG = ME.message;
                end
            end
            if ~err
                err = ~isreal(X);
                if err , numMSG = 4; end
            end
            ok = ~err;
            if ~err
                imgInfos.self_map = ~isempty(map);
                if ~imgInfos.self_map
                    mi = round(min(X(:)));
                    ma = round(max(X(:)));
                    if mi<=0 , ma = ma-mi+1; end
                    ma  = min([default_nbcolors,max([2,ma])]);
                    map = pink(double(ma));
                end
                sX = size(X);
                sX(1:2) = sX([2,1]);
                imgInfos.size = sX;
            else
                dispERROR_2D(fig,imgInfos.filename,numMSG);
            end
        end
        varargout = {imgInfos,X,map,ok};

    case {'direct_load_img'}
        pathname = varargin{2};
        filename = varargin{3};
        if length(varargin)>3 , optIMG = varargin{4}; else optIMG = 'none'; end
        [X,map,imgFormat,colorType,err] = ...
            load_2D_NotMAT(pathname,filename,optIMG);
        varargout = {X,map,imgFormat,colorType,err};
        
    case 'load_var'
        fig  = varargin{1};
        mask = varargin{2};
        txt  = varargin{3};
        vars = varargin{4};
        [filename,pathname,ok] = utguidivX('test_load',fig,mask,txt);
        if ok
            wwaitingX('msg',fig,'Wait ... loading');
            try
                err = 0;
                load([pathname filename],'-mat');
                for k = 1:length(vars)
                    var = vars{k};
                    if ~exist(vars{k},'var') , err = 1; break; end
                end
                if err , msg = sprintf('variable : %s not found !', var); end
            catch ME    %#ok<NASGU>
                err = 1;
                msg = sprintf('File %s is not a valid file.', filename);
            end
            if err
                wwaitingX('off',fig);
                errordlg(msg,'Load ERROR','modal');
                ok = 0;
            end
        end
        varargout = {filename,pathname,ok};
        
    case 'load_wpdecX'
        fig  = varargin{1};
        mask = varargin{2};
        txt  = varargin{3};
        ord  = varargin{4};
        [filename,pathname,ok] = utguidivX('test_load',fig,mask,txt);
        if ok
            wwaitingX('msg',fig,'Wait ... loading');
            fullName = fullfile(pathname,filename);
            try
                err = 0;
                load(fullName,'-mat');
                if ~exist('tree_struct','var')
                    err = 1; var = 'tree_struct';
                elseif ~exist('data_struct','var')
                    if ~isa(tree_struct,'wptree')
                        err = 1; var = 'data_struct';
                    end
                end
                if ~err
                    order = treeordX(tree_struct);
                    err = ~isequal(ord,order);
                    if err
                        msg = {sprintf(['The decomposition is not a %s '...
                            'dimensional analysis'],int2str(ord)),' '};
                    end
                else
                    msg = sprintf('variable : %s not found !', var);
                end
            catch ME    %#ok<NASGU>
                err = 1;
                msg = sprintf('File %s is not a valid file.', filename);
            end
            if err
                wwaitingX('off',fig);
                errordlg(msg,'Load ERROR','modal');
                ok = 0;
            end
        end
        varargout = {filename,pathname,ok};
        
    case 'load_comp_img'
        fig  = varargin{1}; 
        mask = varargin{2};
        txt  = varargin{3};
        [filename,pathname,ok] = utguidivX('test_load',fig,mask,txt);
        % default_nbcolors = varargin{4};

        % default.
        %---------
        imgInfos = struct(...
            'pathname',pathname,'filename',filename,  ...
            'filesize',0, ...
            'name','','true_name','','type','mat',    ...
            'self_map',0, 'size',[0 0]);
        X = []; map = [];
        if ok
            wwaitingX('msg',fig,'Wait ... loading');
            fullName = fullfile(pathname,filename);
            imgInfos.filesize = getFileSize(fullName);
            [PATHSTR,name,ext] = fileparts(fullName); %#ok<ASGLU>
            try
                X = wtcmngr('read',fullName);
                type = ext(2:end);
                imgInfos.type = type;
                mi = min(X(:));
                if mi<1 , X = X-mi+1; end
                if isempty(map)
                    ma  = round(double(max(X(:))));
                    map = pink(ma);
                    if ndims(X)<3 , X = wcodematX(X,ma); end
                end
                imgInfos.('size') = size(X);
                imgInfos.('self_map') = map;
                imgInfos.name = [name ext];
                imgInfos.('true_name') = 'X';                
            catch ME    %#ok<NASGU>
                ok = false;
            end
        end
        varargout = {imgInfos,X,map,ok};
        
    case 'save_img'
        dlgTitle = varargin{1};
        if isempty(dlgTitle) , dlgTitle = 'Save Image as'; end
        fig = varargin{2}; 
        X   = varargin{3};
        wwaitingX('msg',fig,'Wait ... saving');
                
        % Get file name.
        %---------------
        [filename,pathname,FilterIndex] = uiputfile( ...
            {'*.mat','MAT-files (*.mat)';'*.mat','MAT-files [Colored Image] (*.mat)'; ...
            '*.jpg','Joint Photographic Experts Group files (*.jpg)'; ...
            '*.pcx','Windows Paintbrush files (*.pcx)'; ...
            '*.tif','Tagged Image File Format files (*.tif)'; ...
            '*.bmp','Windows Bitmap files (*.bmp)'; ...
            '*.hdf','Hierarchical Data Format files (*.hdf)'; ...
            '*.png','Portable Network Graphics  (*.png)'; ...
            '*.pbm','Portable Bitmap filees (*.pbm)'; ...
            '*.pgm','Portable Graymap files (*.pgm)'; ...
            '*.ppm','Portable Pixmap files (*.ppm)'; ...
            '*.ras','Sun Raster files (*.ras)'; ...
            '*.xwd','X Window Dump (*.xwd)'; ...
            '*.*',  'All Files (*.*)'}, ...
            dlgTitle, 'Untitled.mat');
        OKsave = ~(isempty(filename) || isequal(filename,0));
        if FilterIndex==2
            
        end
        if OKsave
            BW_Flag = ndims(X)<3;
            if BW_Flag
                default_nbcolors = 255;
                map = cbcolmapX('get',fig,'self_pal');
                if isempty(map)
                    mi = round(min(X(:)));
                    ma = round(max(X(:)));
                    if mi<=0 , ma = ma-mi+1; end
                    ma  = min([default_nbcolors,max([2,ma])]);
                    map = pink(double(ma));
                end
                varCell_to_Save = {'X','map'};
            else
                X = uint8(X);
                varCell_to_Save = {'X'};
            end
            
            % Saving file.
            %--------------
            [name,ext] = strtok(filename,'.');
            if isempty(ext) || isequal(ext,'.')
                ext = '.mat'; filename = [name ext];
            end
            try
                if isequal(ext,'.mat')
                    nbIN = length(varargin);
                    if nbIN>3
                        for k = 4:2:nbIN
                            numstr = int2str(k+1);
                            eval([varargin{k} ' =  varargin{' numstr '};']);
                            varCell_to_Save = ...
                                [varCell_to_Save,varargin{k}]; %#ok<AGROW>
                        end
                    end
                    save([pathname filename],varCell_to_Save{:});
                else
                    if exist('map','var')
                        imwrite(X,map,[pathname,filename],ext(2:end));
                    else
                        imwrite(X,[pathname,filename],ext(2:end));
                    end
                end
            catch ME	%#ok<NASGU>
                OKsave = false;
                errargtX(mfilename,'Save FAILED !','msg');
            end
        end
        varargout = {OKsave,pathname,filename};
        wwaitingX('off',fig);
end


%--------------------------------------------------------------------------
function [name,ext,fullName,fileStruct,err] = getFileINFO(pathname,filename)

fullName = fullfile(pathname,filename);
[name,ext] = strtok(filename,'.');
if ~isempty(ext) , ext = ext(2:end); end
try
    fileStruct = wfileinfX(fullName);
    err = 0;
catch ME    %#ok<NASGU>
    err = 1; fileStruct = [];
end
%--------------------------------------------------------------------------
function dispERROR_1D(fig,fileName,numMSG)

if isnumeric(numMSG)
    switch numMSG
        case 1 , strMSG = 'File %s is not a valid file.';
        case 2 , strMSG = 'File %s doesn''t contain one dimensional Signal.';
        case 3 , strMSG = 'File %s is not a valid file or is empty.';
        case 4 , strMSG = 'File %s doesn''t contain a real Signal.';
    end
    if numMSG>1
        msg = {sprintf(strMSG,fileName) , ' '};
    else
        msg = sprintf(strMSG,fileName);
    end
else
    msg = numMSG;
end
wwaitingX('off',fig);
errordlg(msg,'Load Signal ERROR','modal');
%--------------------------------------------------------------------------
function dispERROR_2D(fig,fileName,numMSG)

if isnumeric(numMSG)
    switch numMSG
        case 1 , msg = 'File %s is not a valid file or is empty.';
        case 2 , msg = 'File %s doesn''t contain an Image.';
        case 3 , msg = 'File %s doesn''t contain  an indexed Image.';
        case 4 , msg = 'File %s doesn''t contain real data.';
    end
    msg = {sprintf(msg,fileName) , ' '};
else
    msg = numMSG;
end
wwaitingX('off',fig);
errordlg(msg,'Load Image ERROR','modal');
%--------------------------------------------------------------------------
function [sig,err,msg] = load_1D_NotMAT(pathname,filename)

fullName = fullfile(pathname,filename);
[name,ext] = strtok(filename,'.'); %#ok<ASGLU>
if ~isempty(ext) , ext = ext(2:end); end
sig = []; err = 1; msg = '';
switch lower(ext)
case 'wav' 
    try 
        sig = wavread(fullName); 
        err = 0;
    catch ME
        msg = ME.message; 
    end
case 'au'
    try 
        sig = auread(fullName);  
        err = 0; 
    catch ME
        msg = ME.message; 
    end
end
if ~err && size(sig,1)>1 , sig = sig'; end          
%--------------------------------------------------------------------------
function [X,map,imgFormat,colorType,err] = ...
    load_2D_NotMAT(pathname,filename,optIMG)

[name,ext,fullName] = getFileINFO(pathname,filename); %#ok<ASGLU>
imgFileType = getimgfiletypeX('Cell');
switch ext
    case imgFileType
        info = imfinfo(fullName,ext);
    otherwise
        info = imfinfo(fullName);
end
if length(info)>1 , info = info(1); end
imgFormat = info.Format;
colorType = lower(info.ColorType);

[X,map] = imread(fullName,ext);
[X,err] = convertImage(optIMG,X,colorType,map);
%--------------------------------------------------------------------------
function [X,err] = convertImage(optIMG,X,colorType,map)

conv2BW = wtbxmngrX('get','IndexedImageOnly');
QuestionToConvert = true;

% For Automatic demos
%--------------------
ST = dbstack; 
CST = struct2cell(ST);
CST = CST(2,:);
if isempty(optIMG)
    optIMG = 'BW';
elseif any(strcmp('dguidw2d',CST)) 
    optIMG = 'FORCE';
end

switch optIMG
    case 'mdwt2X' , X = double(X); err = 0; return;
        
    case {'BW','forceBW'}
        QuestionToConvert = false;
        if (length(size(X))<3)
            err = 0;
            X = double(X);
            return;
        end
        conv2BW = true;

    case {'COL','forceCOL'}
        QuestionToConvert = false;

    case {'FORCE'}
        QuestionToConvert = false;
        conv2BW = true;
end

err = 0;
if QuestionToConvert
    ColorIMG = any(strcmp({'rgb','truecolor','mat'},colorType)) | ...
                (~isempty(map) && ~isequal(map(:,1),map(:,2)));
    if ~conv2BW && ColorIMG
        switch colorType
            case {'rgb','truecolor'}
                str1 = sprintf('This is a true color image.');
                str2 = sprintf(['Keep it (Yes) ' ...
                    'or convert it to grayscale (No) ?']);
            case 'mat'
                str1 = sprintf('This is a matlab indexed image.');
                str2 = sprintf(['Use the true color image (Yes) ' ...
                    'or the grayscale one (No) ?']);
        end
        quest = {str1,str2};
        
        Answer_Quest = questdlg(quest,'Loading an Image','Yes','No','Yes');
        if strcmpi(Answer_Quest,'no') , conv2BW = true; end
    end
else
    ColorIMG = false;
end

if conv2BW
    try
        X = double(round(0.299*X(:,:,1) + 0.587*X(:,:,2) + 0.114*X(:,:,3)));
    catch ME %#ok<NASGU>
        switch colorType
            case {'indexed','grayscale','mat'}
            otherwise , err = 1;
        end        
    end
else
    if length(size(X))<3
        convFLAG = true;
        if  (isequal(class(X),'uint8') || isequal(class(X),'logical')) ...
             && ~isequal(optIMG,'COL') && ~ColorIMG
            X = double(X);
            convFLAG = false;
        end
        
        nbCOL = size(map,1);
        if min(X(:))<1 || nbCOL>255, X = X + 1; end
        % The grayscale images are converted in true color images.
        if convFLAG
            maxX = max(X(:));
            if nbCOL==0
                map = pink(maxX);
            elseif nbCOL<maxX
                map = [map ; map(nbCOL*ones(1,maxX-nbCOL),:)];
            end
            IMAP = 256*map;
            Z = cell(1,3);
            for k = 1:3
                tmp = zeros(size(X));
                tmp(:) = IMAP(X(:),k);
                Z{k} = tmp;
            end
            X = uint8(cat(3,Z{:}));
        end
    end
end
%--------------------------------------------------------------------------
function filesize = getFileSize(fullName)

fid  = fopen(fullName);
[dummy,filesize] = fread(fid); %#ok<ASGLU>
fclose(fid);
%--------------------------------------------------------------------------
