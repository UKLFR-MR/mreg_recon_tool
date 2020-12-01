classdef twix_map_obj < matlab.mixin.Copyable %handle
% class to hold information about raw data from siemens MRI scanners
% (currently VB and VD software versions are supported and tested).
%
% Author: Philipp Ehses (philipp.ehses@tuebingen.mpg.de), Aug/19/2011
%
%
% Modified by Wolf Blecher (wolf.blecher@tuebingen.mpg.de), Apr/26/2012
% Added reorder index to indicate which lines are reflected
% Added slice position for sorting, Mai/15/2012
%
% Order of many mdh parameters are now stored (including the reflected ADC
% bit); PE, Jun/14/2012
%
% data is now 'memory mapped' and not read until demanded;
% (see mapVBVD for a description) PE, Aug/02/2012
%
% twix_obj.image.unsorted now returns the data in its acq. order
% [NCol,NCha,nsamples in acq. order], all average flags don't have an
% influence on the output, but 'flagRemoveOS' still works, PE, Sep/04/13
%
properties(Dependent=true)
    % flags
    flagRemoveOS        % removes oversampling in read (col) during read operation
    flagDoAverage       % averages over all avg during read operation
    flagAverageReps     % averages over all repetitions
    flagAverageSets     % averages over all sets
    flagIgnoreSeg       % sum over all segments during read operation
    flagSkipToFirstLine % skips lines/partitions up to the first
                        % actually acquired line/partition
                        % (e.g. only the center k-space is acquired in
                        % refscans, we don't want all the leading zeros
                        % in our data)
                        % this is the default behaviour for everything
                        % but image scans (but can be changed manually)
    flagRampSampRegrid  % perform on-the-fly ramp sampling regridding
    flagDoRawDataCorrect     %SRY: apply raw data correction factors during read operation
    RawDataCorrectionFactors %SRY: allow the user to set/get the factors
end

properties(GetAccess='public', SetAccess='public')
    filename
    dataType
end

properties(GetAccess='public', SetAccess='protected')
    softwareVersion

    dataSize % this is the current output size, depends on fullSize + some flags
    dataDims
    sqzSize
    sqzDims

    NCol  % mdh information
    NCha  % mdh information
    NLin  % mdh information
    NPar  % mdh information
    NSli  % mdh information
    NAve  % mdh information
    NPhs  % mdh information
    NEco  % mdh information
    NRep  % mdh information
    NSet  % mdh information
    NSeg  % mdh information
    NIda  % mdh information
    NIdb  % mdh information
    NIdc  % mdh information
    NIdd  % mdh information
    NIde  % mdh information
    NAcq  % simple counter

    % mdh information
    Lin
    Par
    Sli
    Ave
    Phs
    Eco
    Rep
    Set
    Seg
    Ida
    Idb
    Idc
    Idd
    Ide

    centerCol
    centerLin
    centerPar
    cutOff
    coilSelect
    ROoffcenter
    timeSinceRF
    IsReflected
    IsRawDataCorrect %SRY: storage for MDH flag raw data correct

    slicePos
    freeParam
    iceParam
    scancounter
    timestamp
    pmutime
    rampSampTrj

    % memory position in file
    memPos

    % index that translates simple, linear order of mdh info vectors
    % to target matrix (of size dataSize)
    ixToTarget % inverted page table (physical to virtual addresses)
    ixToRaw    % page table (virtual to physical addresses)
    
    isBrokenFile % errors when parsing? 
end

properties(Hidden=true, SetAccess='protected')
    arg  % arguments

    fullSize % this is the full size of the data set according to the mdhs, i.e. flags
             % like 'reduceOS' have no influence on it

    freadInfo

    skipLin
    skipPar
end

methods
    % Constructor:
    function this = twix_map_obj(arg,dataType,fname,version,rstraj)

        if ~exist('dataType','var')
            this.dataType = 'image';
        else
            this.dataType = lower(dataType);
        end

        this.filename         = fname;
        this.softwareVersion  = version;

        this.IsReflected      = logical([]);
        this.IsRawDataCorrect = logical([]); %SRY
        this.NAcq             = 0;
        this.isBrokenFile     = false;

        this.setDefaultFlags();
        if exist('arg','var')
            % copy relevant arguments from mapVBVD argument list
            names=fieldnames(arg);
            for k=1:numel(names)
                if isfield(this.arg,names{k})
                    this.arg.(names{k}) = arg.(names{k});
                end
            end
        end

        switch this.softwareVersion
            case 'vb'
                % every channel has its own full mdh
                this.freadInfo.szScanHeader    =   0; % [bytes]
                this.freadInfo.szChannelHeader = 128; % [bytes]
                this.freadInfo.iceParamSz      =   4;
            case 'vd'
                if ( this.arg.doRawDataCorrect )
                    error('raw data correction for VD not supported/tested yet');
                end
                this.freadInfo.szScanHeader    = 192; % [bytes]
                this.freadInfo.szChannelHeader =  32; % [bytes]
                this.freadInfo.iceParamSz      =  24; % vd version supports up to 24 ice params
            otherwise
                error('software version not supported');
        end

        if exist('rstraj','var')
            this.rampSampTrj = rstraj;
        else
            this.rampSampTrj        = [];
            this.arg.rampSampRegrid = false;
        end
    end

    function this = readMDH(this, mdh, filePos )
        % extract all values in all MDHs at once
        %
        % data types:
        % Use double for everything non-logical, both ints and floats. Seems the
        % most robust way to avoid unexpected cast-issues with very nasty side effects.
        % Examples: eps(single(16777216)) == 2
        %           uint32( 10 ) - uint32( 20 ) == 0
        %           uint16(100) + 1e5 == 65535
        %           size(1 : 10000 * uint16(1000)) ==  [1  65535]
        %
        % The 1st example always hits the timestamps.

        if ~isstruct( mdh ) || isempty( mdh )
            return
        end

        this.NAcq     = numel( filePos );
        sLC           = double( mdh.sLC ) + 1;  % +1: convert to matlab index style
        evalInfoMask1 = double( mdh.aulEvalInfoMask(:,1) ).';

        % save mdh information for each line
        this.NCol       = double( mdh.ushSamplesInScan ).';
        this.NCha       = double( mdh.ushUsedChannels ).';
        this.Lin        = sLC(:,1).' ;
        this.Ave        = sLC(:,2).' ;
        this.Sli        = sLC(:,3).' ;
        this.Par        = sLC(:,4).' ;
        this.Eco        = sLC(:,5).' ;
        this.Phs        = sLC(:,6).' ;
        this.Rep        = sLC(:,7).' ;
        this.Set        = sLC(:,8).' ;
        this.Seg        = sLC(:,9).' ;
        this.Ida        = sLC(:,10).';
        this.Idb        = sLC(:,11).';
        this.Idc        = sLC(:,12).';
        this.Idd        = sLC(:,13).';
        this.Ide        = sLC(:,14).';

        this.centerCol   = double( mdh.ushKSpaceCentreColumn ).' + 1;
        this.centerLin   = double( mdh.ushKSpaceCentreLineNo ).' + 1;
        this.centerPar   = double( mdh.ushKSpaceCentrePartitionNo ).' + 1;
        this.cutOff      = double( mdh.sCutOff ).';
        this.coilSelect  = double( mdh.ushCoilSelect ).';
        this.ROoffcenter = double( mdh.fReadOutOffcentre ).';
        this.timeSinceRF = double( mdh.ulTimeSinceLastRF ).';
        this.IsReflected = logical(min(bitand(evalInfoMask1,2^24),1));
        this.scancounter = double( mdh.ulScanCounter ).';
        this.timestamp   = double( mdh.ulTimeStamp ).';
        this.pmutime     = double( mdh.ulPMUTimeStamp ).';
        this.IsRawDataCorrect = logical(min(bitand(evalInfoMask1,2^10),1)); %SRY
        this.slicePos    = double( mdh.SlicePos ).';
        this.iceParam    = double( mdh.aushIceProgramPara ).';
        this.freeParam   = double( mdh.aushFreePara ).';

        this.memPos = filePos;

    end % of readMDH

    function this = tryAndFixLastMdh(this)
        eofWarning = [mfilename() ':UnxpctdEOF'];   % We have it inside this.readData()
        warning( 'off', eofWarning )    % silence warnings for read...
        warning( 'off', 'foo:bar'  )    % ... and a stupid placeholder

        isLastAcqGood = false;
        cnt = 0;

        while ~isLastAcqGood  &&  this.NAcq > 0  && cnt < 100
            warning( 'foo:bar', 'baz') % make sure that lastwarn() does not return eofWarning
            try
                this.clean();
                this.unsorted(this.NAcq);
                [~, warnid] = lastwarn();
                if strcmp( warnid, eofWarning )
                    error( 'Make sure to go to the catch block.')
                end
                isLastAcqGood = true;
            catch
                this.isBrokenFile = true;
                this.NAcq = this.NAcq-1;
            end
            cnt = cnt + 1;
        end
        
%         if this.NAcq == 0  ||  cnt > 99    % everything is garbage
%             warning(  )
%         end

        warning( 'on', eofWarning )
    end

    function this = clean(this)
        
        if this.NAcq == 0
            return;
        end

        % Cut mdh data to actual size. Maybe we rejected acquisitions at the end
        % due to read errors.
        fields = { 'NCol', 'NCha',                                                  ...
                   'Lin', 'Par', 'Sli', 'Ave', 'Phs', 'Eco', 'Rep',                 ...
                   'Set', 'Seg', 'Ida', 'Idb', 'Idc', 'Idd', 'Ide',                 ...
                   'centerCol'  ,   'centerLin',   'centerPar',           'cutOff', ...
                   'coilSelect' , 'ROoffcenter', 'timeSinceRF',      'IsReflected', ...
                   'scancounter',   'timestamp',     'pmutime', 'IsRawDataCorrect', ...
                   'slicePos'   ,    'iceParam',   'freeParam',           'memPos'  };
        
        nack = this.NAcq;
        idx = 1:nack;

        for f = fields
            f1 = f{1};
            if size(this.(f1),2) > nack   % rarely
                this.(f1) = this.(f1)(:,idx);       % 1st dim: samples,  2nd dim acquisitions
            end
        end

        this.NLin = max(this.Lin);
        this.NPar = max(this.Par);
        this.NSli = max(this.Sli);
        this.NAve = max(this.Ave);
        this.NPhs = max(this.Phs);
        this.NEco = max(this.Eco);
        this.NRep = max(this.Rep);
        this.NSet = max(this.Set);
        this.NSeg = max(this.Seg);
        this.NIda = max(this.Ida);
        this.NIdb = max(this.Idb);
        this.NIdc = max(this.Idc);
        this.NIdd = max(this.Idd);
        this.NIde = max(this.Ide);

        % ok, let us assume for now that all NCol and NCha entries are
        % the same for all mdhs:
        this.NCol = this.NCol(1);
        this.NCha = this.NCha(1);

        this.dataDims = {'Col','Cha','Lin','Par','Sli','Ave','Phs',...
            'Eco','Rep','Set','Seg','Ida','Idb','Idc','Idd','Ide'};

        if strcmp(this.dataType,'refscan')
            %pehses: check for lines with 'negative' line/partition numbers
            %this can happen when the reference scan line/partition range
            %exceeds the one of the actual imaging scan
            if this.NLin>65500  %uint overflow check
                this.Lin  = mod(this.Lin + (65536 - min(this.Lin(this.Lin>65500))),65536)+1;
                this.NLin = max(this.Lin);
            end
            if this.NPar>65500  %uint overflow check
                this.Par  = mod(this.Par + (65536 - min(this.Par(this.Par>65500))),65536)+1;
                this.NPar = max(this.Par);
            end
        end

        % to reduce the matrix sizes of non-image scans, the size
        % of the refscan_obj()-matrix is reduced to the area of the
        % actually scanned acs lines (the outer part of k-space
        % that is not scanned is not filled with zeros)
        % this behaviour is controlled by flagSkipToFirstLine which is
        % set to true by default for everything but image scans
        if ~this.flagSkipToFirstLine
            % the output matrix should include all leading zeros
            this.skipLin = 0;
            this.skipPar = 0;
        else
            % otherwise, cut the matrix size to the start of the
            % first actually scanned line/partition (e.g. the acs/
            % phasecor data is only acquired in the k-space center)
            this.skipLin = min(this.Lin)-1;
            this.skipPar = min(this.Par)-1;
        end
        NLinAlloc = max(1, this.NLin - this.skipLin);
        NParAlloc = max(1, this.NPar - this.skipPar);

        this.fullSize = [ this.NCol this.NCha NLinAlloc NParAlloc...
                          this.NSli this.NAve this.NPhs this.NEco...
                          this.NRep this.NSet this.NSeg this.NIda...
                          this.NIdb this.NIdc this.NIdd this.NIde ];

        this.dataSize = this.fullSize;

        if this.arg.removeOS
            this.dataSize(1) = this.NCol/2;
        end

        if this.arg.doAverage
            this.dataSize(6) = 1;
        end

        if this.arg.averageReps
            this.dataSize(9) = 1;
        end

        if this.arg.averageSets
            this.dataSize(10) = 1;
        end

        if this.arg.ignoreSeg
            this.dataSize(11) = 1;
        end

        % calculate sqzSize
        this.calcSqzSize;

        % calculate indices to target & source(raw)
        this.calcIndices;

        nByte = this.NCha*(this.freadInfo.szChannelHeader+8*this.NCol);

        % size for fread
        this.freadInfo.sz    = [2 nByte/8];
        % reshape size
        this.freadInfo.shape = [this.NCol+this.freadInfo.szChannelHeader/8 ...
                               , this.NCha];
        % we need to cut MDHs from fread data
        this.freadInfo.cut   = this.freadInfo.szChannelHeader/8 + (1 : this.NCol);

    end % of clean


    function varargout = subsref(this, S)
        % this is where the magic happens
        % Now seriously. Overloading of the subsref-method and working
        % with a gazillion indices got really messy really fast. At
        % some point, I should probably clean this code up a bit. But
        % good news everyone: It seems to work.
        switch S(1).type
            case '.'
                % We don't want to manage method/variable calls, so we'll
                % simply call the built-in subsref-function in this case.
                if nargout == 0
                    varargout{1} = builtin('subsref', this, S); % CTR fix.
                else
                    varargout      = cell(1, nargout);
                    [varargout{:}] = builtin('subsref', this, S);
                end
                return;
            case {'()','{}'}
            otherwise
                error('operator not supported');
        end

        [selRange,selRangeSz,outSize] = this.calcRange(S(1));

        tmp = reshape(1:prod(double(this.fullSize(3:end))), this.fullSize(3:end));
        tmp = tmp(selRange{3:end});
        cIxToRaw = this.ixToRaw(tmp); clear tmp;
        cIxToRaw = cIxToRaw(:);
        % delete all entries that point to zero (the "NULL"-pointer)
        notAcquired = (cIxToRaw == 0);
        cIxToRaw (notAcquired) = []; clear notAcquired;

        % calculate cIxToTarg for possibly smaller, shifted + segmented
        % target matrix:
        cIx = zeros(14, numel(cIxToRaw), 'single');
        cIx( 1,:) = this.Lin(cIxToRaw) - this.skipLin;
        cIx( 2,:) = this.Par(cIxToRaw) - this.skipPar;
        cIx( 3,:) = this.Sli(cIxToRaw);
        if this.arg.doAverage
            cIx( 4,:) = 1;
        else
            cIx( 4,:) = this.Ave(cIxToRaw);
        end
        cIx( 5,:) = this.Phs(cIxToRaw);
        cIx( 6,:) = this.Eco(cIxToRaw);
        if this.arg.averageReps
            cIx( 7,:) = 1;
        else
            cIx( 7,:) = this.Rep(cIxToRaw);
        end
        if this.arg.averageSets
            cIx( 8,:) = 1;
        else
            cIx( 8,:) = this.Set(cIxToRaw);
        end
        if this.arg.ignoreSeg
            cIx( 9,:) = 1;
        else
            cIx( 9,:) = this.Seg(cIxToRaw);
        end
        cIx(10,:) = this.Ida(cIxToRaw);
        cIx(11,:) = this.Idb(cIxToRaw);
        cIx(12,:) = this.Idc(cIxToRaw);
        cIx(13,:) = this.Idd(cIxToRaw);
        cIx(14,:) = this.Ide(cIxToRaw);

        % make sure that indices fit inside selection range
        for k=3:numel(selRange)
            tmp = cIx(k-2,:);
            for l=1:numel(selRange{k})
                cIx(k-2,tmp==selRange{k}(l)) = l;
            end
        end

        cIxToTarg = this.sub2ind_double(selRangeSz(3:end),cIx(1,:),cIx(2,:),cIx(3,:),...
            cIx(4,:),cIx(5,:),cIx(6,:),cIx(7,:),cIx(8,:),cIx(9,:),...
            cIx(10,:),cIx(11,:),cIx(12,:),cIx(13,:),cIx(14,:));

        mem = this.memPos(cIxToRaw);
        % sort mem for quicker access, sort cIxToTarg/Raw accordingly
        [mem,ix]  = sort(mem);
        cIxToTarg = cIxToTarg(ix);
        cIxToRaw  = cIxToRaw(ix);
        clear ix;

        % For a call of type data{:,:,1:3} matlab expects more than one
        % output variable (three in this case) and will throw an error
        % otherwise. This is a lazy way (and the only one I know of) to
        % fix this.
        varargout    = cell(1, nargout);
        varargout{1} = this.readData(mem,cIxToTarg,cIxToRaw,selRange,selRangeSz,outSize);
    end % of subsref

    function out = unsorted(this,ival)
        % returns the unsorted data [NCol,NCha,#samples in acq. order]
        if ~exist('ival','var')
            mem = this.memPos;
        else
            mem = this.memPos(ival);
        end
        out = this.readData(mem);
    end

    function out = readData(this,mem,cIxToTarg,cIxToRaw,selRange,selRangeSz,outSize)

        if ~exist('outSize','var')
            selRange{1} = ':';
            selRange{2} = ':';
            outSize = [this.dataSize(1:2),numel(mem)];
            selRangeSz = outSize;
            cIxToTarg = 1:selRangeSz(3);
            cIxToRaw  = cIxToTarg;
        else
            if isequal( selRange{1}(:), (1:this.dataSize(1)).' )
                selRange{1} = ':';
            end
            if isequal( selRange{2}(:), (1:this.dataSize(2)).' )
                selRange{2} = ':';
            end
        end
        out = complex(zeros(outSize,'single'));
        out = reshape(out, selRangeSz(1), selRangeSz(2), []);

        if isempty( mem )
            out = reshape(out,outSize);
            return
        end

        cIxToTarg = this.cast2MinimalUint( cIxToTarg );

        % subsref overloading makes this.that-calls slow, so we need to
        % avoid them whenever possible
        szScanHeader = this.freadInfo.szScanHeader;
        readSize     = this.freadInfo.sz;
        readShape    = this.freadInfo.shape;
        readCut      = this.freadInfo.cut;
        keepOS       = [1:this.NCol/4, 1+this.NCol*3/4:this.NCol];
        bRemoveOS    = this.arg.removeOS;
        bIsReflected = this.IsReflected( cIxToRaw );
        bRegrid      = this.flagRampSampRegrid && numel(this.rampSampTrj);
        %SRY store information about raw data correction
        bDoRawDataCorrect = this.arg.doRawDataCorrect;
        bIsRawDataCorrect = this.IsRawDataCorrect( cIxToRaw );
        isBrokenRead      = false;
        if (bDoRawDataCorrect)
            rawDataCorrect = this.arg.rawDataCorrectionFactors;
        end

        % MiVö: Raw data are read line-by-line in portions of 2xNColxNCha float32 points (2 for complex).
        % Computing and sorting(!) on these small portions is quite expensive, esp. when
        % it employs non-sequential memory paths. Examples are non-linear k-space acquisition
        % or reflected lines.
        % This can be sped up if slightly larger blocks of raw data are collected, first.
        % Whenever a block is full, we do all those operations and save it in the final "out" array.
        % What's a good block size? Depends on data size and machine (probably L2/L3/L4 cache sizes).
        % So...? Start with a small block, measure the time-per-line and double block size until
        % a minimum is found. Seems sufficiently robust to end up in a close-to-optimal size for every
        % machine an data.
        blockSz   = 2;          % size of blocks; must be 2^n; will be increased
        doLockblockSz = false;  % whether blockSZ should be left untouched
        tprev     = inf;        % previous time-per-line
        blockCtr  = 0;
        blockInit = -inf(readShape(1), readShape(2), blockSz, 'single'); %init with garbage
        blockInit = complex( blockInit );
        block     = blockInit;
        
        if bRegrid
            v1       = single(1:selRangeSz(2));
            v2       = single(1:blockSz);
            rsTrj    = {this.rampSampTrj,v1,v2};
            trgTrj   = linspace(min(this.rampSampTrj),max(this.rampSampTrj),this.dataSize(1));
            trgTrj   = {trgTrj,v1,v2};
        end
    
        % counter for proper scaling of averages/segments
        count_ave = zeros([1 1 size(out,3)],'single');
        kMax      = numel( mem );   % max loop index

        fid = this.fileopen();

        for k = 1:kMax
            % skip scan header
            fseek(fid,mem(k) + szScanHeader,'bof');
            raw = fread(fid, readSize, 'float=>single').';

            % MiVö: With incomplete files fread() returns less than readSize points. The subsequent reshape will therefore error out.
            %       We could check if numel(raw) == prod(readSize), but people recommend exception handling for performance
            %       reasons. Do it.
            try
                raw = reshape( complex(raw(:,1), raw(:,2)), readShape);
            catch exc
                offset_bytes = mem(k) + szScanHeader;
                %remainingSz = readSize(2) - size(raw,1);
                warning( [mfilename() ':UnxpctdEOF'],  ...
                          [ '\nAn unexpected read error occurred at this byte offset: %d (%g GiB)\n'...
                            'Actual read size is [%s], desired size was: [%s]\n'                    ...
                            'Will ignore this line and stop reading.\n'                             ...
                            '=== MATLABs error message ================\n'                          ...
                            exc.message                                                             ...
                            '\n=== end of error =========================\n'                        ...
                            ], offset_bytes, offset_bytes/1024^3, num2str(size(raw)), num2str(readSize.') )

                % Reject this data fragment. To do so, init with the values of blockInit
                clear raw
                raw( 1:prod(readShape) ) = blockInit(1);
                raw = reshape( raw, readShape );
                isBrokenRead = true;   % remember it and bail out later
            end

            blockCtr = blockCtr + 1;
            block(:,:,blockCtr) = raw;  % fast serial storage in a cache array
            
            % Do expensive computations and reorderings on the gathered block.
            % Unfortunately, a lot of code is necessary, but that is executed much less
            % frequent, so its worthwhile for speed.
            % TODO: Do *everything* block-by-block
            if blockCtr == blockSz || k == kMax || (isBrokenRead && blockCtr > 1)
                s = tic;    % measure the time to process a block of data
            
                % remove MDH data from block:
                block = block(readCut,:,:);
                
                if bRegrid
                    F     = griddedInterpolant(rsTrj,block);
                    block = F(trgTrj);
                elseif bRemoveOS % remove oversampling in read
                    block = ifft( block,[],1);
                    block =  fft( block(keepOS,:,:),[],1);
                end

                if ( bDoRawDataCorrect && bIsRawDataCorrect(k) )
                    %SRY apply raw data correction if necessary
                    block = bsxfun(@times, block, rawDataCorrect);
                end
                
                if blockCtr == blockSz    % the typical trivial case
                    ix = 1 + k - blockSz : k;
                    validIdx = ':';
                else
                    % Using find() is expensive. Only do it in non-trivial cases
                    validIdx = any(any( isfinite(block), 1 ),2);
                    ix = find(validIdx);
                    ix = ix - numel(ix) + k;
                end
                
                isRefl = bIsReflected(ix);
                block(:,:,isRefl) = block(end:-1:1,:,isRefl);
                
                if ~isequal(selRange{1},':') || ~isequal(selRange{2},':') || ~isequal(validIdx,':')
                    block = block( selRange{1}, selRange{2}, validIdx );    % a bit slow
                end
                
                [sortIdx, I] = sort( cIxToTarg(ix), 'ascend' );
                block = block(:,:,I);     % reorder according to sorted target indices

                % Mark duplicate indices with 1; we'll have to treat them special for proper averaging
                % Bonus: The very first storage can be made much faster, because it's in-place.
                %        Matlab urgently needs a "+=" operater, which makes "A(:,:,idx) = A(:,:,idx) + B"
                %        in-place and more readable.
                isDupe  = [ false, diff(sortIdx) == 0 ];

                idx1 = sortIdx(~isDupe);     % acquired once in this block
                idxN = sortIdx( isDupe);     % acquired multiple times

                count_ave(idx1) = count_ave(idx1) + 1;

                if isempty( idxN )
                    % no duplicates
                    if all( count_ave(idx1) == 1 )  % first acquisition of this line
                        out(:,:,idx1) = block;                              % fast
                    else
                        out(:,:,idx1) = out(:,:,idx1) + block;              % slow
                    end
                else
                    out(:,:,idx1) = out(:,:,idx1) + block(:,:,~isDupe);     % slower

                    block = block(:,:,isDupe);
                    for n = 1:numel(idxN)
                        out(:,:,idxN(n)) = out(:,:,idxN(n)) + block(:,:,n); % snail :-)
                        count_ave(idxN(n)) = count_ave(idxN(n)) + 1;
                    end
                end

                % At the first few iterations, evaluate the spent time-per-line and decide
                % what to do with the block size.
                if ~doLockblockSz
                    t = 1e6 * toc(s)/blockSz;   % micro seconds

                    if t <= 1.1 * tprev % allow 10% inaccuracy. Usually bigger == better
                        % New block size was faster. Go a step further.
                        blockSz = blockSz * 2;
                        blockInit = cat(3, blockInit, blockInit);
                    else
                        % regression; reset size and lock it
                        blockSz = max( blockSz/2, 1 );
                        blockInit = blockInit(:,:,1:blockSz);
                        doLockblockSz = true;
                    end
                    if bRegrid
                        rsTrj{3}  = single(1:blockSz);
                        trgTrj{3} = rsTrj{3};
                    end
                    tprev = t;
                end

                blockCtr = 0;
                block = blockInit;  % reset to garbage
            end

            if isBrokenRead
                this.isBrokenFile = true;
                break
            end
        end

        fclose(fid);

        % proper scaling (we don't want to sum our data but average it)
        % For large "out" bsxfun(@rdivide,out,count_ave) is incredibly faster than
        % bsxfun(@times,out,count_ave)!
        % @rdivide is also running in parallel, while @times is not. :-/
        if any( reshape(count_ave,[],1) > 1 )
            clearvars -except  out  count_ave  outSize
            count_ave = max( 1, count_ave );
            out       = bsxfun( @rdivide, out, count_ave);
        end

        out = reshape(out,outSize);
    end % of readData


    function setDefaultFlags(this)
        % method to set flags to default values
        this.arg.removeOS            = false;
        this.arg.doAverage           = false;
        this.arg.averageReps         = false;
        this.arg.averageSets         = false;
        this.arg.ignoreSeg           = false;
        this.flagRampSampRegrid      = false;
        this.arg.doRawDataCorrect    = false;
        if strcmp(this.dataType,'image') || strcmp(this.dataType,'phasecor') || strcmp(this.dataType,'phasestab')
            this.arg.skipToFirstLine = false;
        else
            this.arg.skipToFirstLine = true;
        end
        if ~isfield(this.arg,'rawDataCorrectionFactors')
            this.arg.rawDataCorrectionFactors = [];
        end
    end

    function dummy = resetFlags(this)
        % method to reset flags to default values
        this.flagRemoveOS            = false;
        this.flagDoAverage           = false;
        this.flagAverageReps         = false;
        this.flagAverageSets         = false;
        this.flagIgnoreSeg           = false;
        this.flagRampSampRegrid      = false;
        this.flagDoRawDataCorrect    = false;
        if strcmp(this.dataType,'image') || strcmp(this.dataType,'phasecor') || strcmp(this.dataType,'phasestab')
            this.arg.skipToFirstLine = false;
        else
            this.arg.skipToFirstLine = true;
        end
        dummy = [];
    end

    function set.flagRemoveOS(this,val)
        % set method for removeOS
        this.arg.removeOS = logical(val);

        % we also need to recalculate our data size:
        if this.arg.removeOS
            this.dataSize(1) = this.NCol(1)/2;
            this.sqzSize(1)  = this.NCol(1)/2;
        else
            this.dataSize(1) = this.NCol(1);
            this.sqzSize(1)  = this.NCol(1);
        end
    end


    function out = get.flagRemoveOS(this)
        out = this.arg.removeOS;
    end


    function set.flagDoAverage(this,val)
        % set method for doAverage
        this.arg.doAverage = logical(val);

        if this.arg.doAverage
            this.dataSize(6) = 1;
        else
            this.dataSize(6) = this.NAve;
        end

        % update sqzSize
        this.calcSqzSize;
    end


    function out = get.flagDoAverage(this)
        out = this.arg.doAverage;
    end

    function set.flagAverageReps(this,val)
        % set method for doAverage
        this.arg.averageReps = logical(val);

        if this.arg.averageReps
            this.dataSize(9) = 1;
        else
            this.dataSize(9) = this.NRep;
        end

        % update sqzSize
        this.calcSqzSize;
    end


    function out = get.flagAverageReps(this)
        out = this.arg.averageReps;
    end


    function set.flagAverageSets(this,val)
        % set method for doAverage
        this.arg.averageSets = logical(val);

        if this.arg.averageSets
            this.dataSize(10) = 1;
        else
            this.dataSize(10) = this.NSet;
        end

        % update sqzSize
        this.calcSqzSize;
    end


    function out = get.flagAverageSets(this)
        out = this.arg.averageSets;
    end


    function set.flagSkipToFirstLine(this,val)
        val = logical(val);
        if val ~= this.arg.skipToFirstLine
            this.arg.skipToFirstLine = val;

            if this.arg.skipToFirstLine
                this.skipLin = min(this.Lin)-1;
                this.skipPar = min(this.Par)-1;
            else
                this.skipLin = 0;
                this.skipPar = 0;
            end
            NLinAlloc = max(1, this.NLin - this.skipLin);
            NParAlloc = max(1, this.NPar - this.skipPar);
            this.fullSize(3:4) = [NLinAlloc NParAlloc];
            this.dataSize(3:4) = this.fullSize(3:4);

            % update sqzSize
            this.calcSqzSize;
            % update indices
            this.calcIndices;
        end
    end


    function out = get.flagSkipToFirstLine(this)
        out = this.arg.skipToFirstLine;
    end


    function set.flagIgnoreSeg(this,val)
        % set method for ignoreSeg
        this.arg.ignoreSeg = logical(val);

        if this.arg.ignoreSeg
            this.dataSize(11) = 1;
        else
            this.dataSize(11) = this.NSeg;
        end

        % update sqzSize
        this.calcSqzSize;
    end


    function out = get.flagIgnoreSeg(this)
        out = this.arg.ignoreSeg;
    end


    function out = get.flagRampSampRegrid(this)
        out = this.arg.rampSampRegrid;
    end

    function set.flagRampSampRegrid(this, val)
        val = logical(val);
        if (val == true && isempty(this.rampSampTrj))
            error('No trajectory for regridding available');
        end
        this.arg.rampSampRegrid = val;
    end

    %SRY: accessor methods for raw data correction
    function out = get.flagDoRawDataCorrect(this)
        out = this.arg.doRawDataCorrect;
    end

    function set.flagDoRawDataCorrect(this, val)
        val = logical(val);
        if (val == true && strcmp(this.softwareVersion, 'vd'))
            error('raw data correction for VD not supported/tested yet');
        end

        this.arg.doRawDataCorrect = val;
    end

    function out = get.RawDataCorrectionFactors(this)
        out = this.arg.rawDataCorrectionFactors;
    end

    function set.RawDataCorrectionFactors(this, val)
        %this may not work if trying to set the factors before NCha has
        %a meaningful value (ie before calling clean)
        if (~isrow(val) || length(val) ~= this.NCha)
            error('RawDataCorrectionFactors must be a 1xNCha row vector');
        end
        this.arg.rawDataCorrectionFactors = val;
    end

end

methods (Access='protected')
    % helper functions

    function fid = fileopen(this)
        % look out for unlikely event that someone is switching between
        % windows and unix systems:
        [path,name,ext] = fileparts(this.filename);
        this.filename   = fullfile(path,[name ext]);

        % test access
        if numel(dir(this.filename))==0
            % update path when file of same name can be found in current
            % working dir. -- otherwise throw error
            [oldpath,name,ext] = fileparts(this.filename);
            newloc = fullfile(pwd,[name ext]);
            if numel(dir(newloc))==1
                fprintf('Warning: File location updated from "%s" to current working directory.\n',oldpath);
                this.filename = newloc;
            else
                error(['File "' this.filename '" not found.']);
            end
        end
        fid = fopen(this.filename);
    end

    function [selRange,selRangeSz,outSize] = calcRange(this,S)

        switch S.type
            case '()'
                bSqueeze = false;
            case '{}'
                bSqueeze = true;
        end

        selRange = num2cell(ones(1,numel(this.dataSize)));
        outSize  = ones(1,numel(this.dataSize));

        if ( isempty(S.subs) || strcmpi(S.subs(1),'') )
            % obj(): shortcut to select all data
            % unfortunately, matlab does not allow the statement
            % obj{}, so we can't use it...
            % alternative: obj{''} (obj('') also works)
            for k=1:numel(this.dataSize)
                selRange{k}   = 1:this.dataSize(k);
            end
            if ~bSqueeze
                outSize = this.dataSize;
            else
                outSize = this.sqzSize;
            end
        else
            for k=1:numel(S.subs)
                if ~bSqueeze
                    cDim = k; % nothing to do
                else
                    % we need to rearrange selRange from squeezed
                    % to original order
                    cDim = find(strcmp(this.dataDims,this.sqzDims{k}) == 1);
                end
                if strcmp(S.subs{k},':')
                    if k<numel(S.subs)
                        selRange  {cDim} = 1:this.dataSize(cDim);
                    else % all later dimensions selected and 'vectorized'!
                        for l=cDim:numel(this.dataSize)
                            selRange{l} = 1:this.dataSize(l);
                        end
                        outSize(k) = prod(double(this.dataSize(cDim:end)));
                        break; % jump out ouf for-loop
                    end
                elseif isnumeric(S.subs{k})
                    selRange{cDim} = single(S.subs{k});
                else
                    error('unknown string in brackets (e.g. 1:end does not work here)');
                end
                outSize(k) = numel(selRange{cDim});
            end
            for k=1:numel(selRange)
                if max(selRange{k}) > this.dataSize(k)
                    error('selection out of range');
                end
            end
        end

        selRangeSz = ones(1,numel(this.dataSize));
        for k=1:numel(selRange)
            selRangeSz(k) = numel(selRange{k});
        end

        % now select all averages in case doAverage is selected
        if this.arg.doAverage
            selRange{6}  = 1:this.fullSize(6);
        end
        % now select all repetitions in case averageReps is selected
        if this.arg.averageReps
            selRange{9}  = 1:this.fullSize(9);
        end
        % now select all sets in case averageSets is selected
        if this.arg.averageSets
            selRange{10}  = 1:this.fullSize(10);
        end
        % now select all segments in case ignoreSeg is selected
        if this.arg.ignoreSeg
            selRange{11} = 1:this.fullSize(11);
        end

    end

    function calcSqzSize(this)
        % calculate sqzSize and sqzDims
        this.sqzSize    = [];
        this.sqzDims    = [];
        this.sqzSize(1) = this.dataSize(1);
        this.sqzDims{1} = 'Col';
        c = 1;
        for k=2:numel(this.dataSize)
            if this.dataSize(k)>1
                c = c+1;
                this.sqzSize(c) = this.dataSize(k);
                this.sqzDims{c} = this.dataDims{k};
            end
        end
    end

    function calcIndices(this)
        % calculate indices to target & source(raw)
        LinIx     = this.Lin  - this.skipLin;
        ParIx     = this.Par  - this.skipPar;
        this.ixToTarget = this.sub2ind_double(this.fullSize(3:end),...
            LinIx, ParIx, this.Sli, this.Ave, this.Phs, this.Eco,...
            this.Rep, this.Set, this.Seg, this.Ida, this.Idb,...
            this.Idc, this.Idd, this.Ide);

        % now calculate inverse index
        % inverse index of lines that are not measured is zero
        this.ixToRaw = zeros(1,prod(this.fullSize(3:end)),'double');

        this.ixToRaw(this.ixToTarget) = 1:numel(this.ixToTarget);
    end
end

methods (Static)
    % helper functions, accessible from outside via <classname>.function()
    % without an instance of the class.

    function ndx = sub2ind_double(sz,varargin)
        %SUB2IND_double Linear index from multiple subscripts.
        %   Works like sub2ind but always returns double
        %   also slightly faster, but no checks
        %========================================
        sz  = double(sz);
        ndx = double(varargin{end}) - 1;
        for i = length(sz)-1:-1:1
            ix  = double(varargin{i});
            ndx = sz(i)*ndx + ix-1;
        end
        ndx = ndx + 1;
    end % sub2ind_double

    function N = cast2MinimalUint( N )
        Nmax = max( reshape(N,[],1) );
        Nmin = min( reshape(N,[],1) );
        if Nmin < 0 || Nmax > intmax('uint64')
            return
        end

        if Nmax > intmax('uint32')
            idxClass = 'uint64';
        elseif Nmax > intmax('uint16')
            idxClass = 'uint32';
        else
            idxClass = 'uint16';
        end

        N = cast( N, idxClass );
    end % cast2MinimalUint()

end % of methods (Static)

end % classdef
