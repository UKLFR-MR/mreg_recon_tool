function aheader = readHeader(filename)

% open file
if isnumeric(filename)
    mid = filename;
    filename = filenameByMID(mid);
else
    [~, fname] = fileparts(filename);
    mid = midByFilename(fname);
end

fid = fopen(filename,'r');

try
    if ~verLessThan('matlab', '8.4')
        bszopt = {};
    else
        error('Need bufsize option');
    end
catch
    bszopt = {'bufsize', 10000};
end

aheader.mid = mid;
aheader.slice_oversampling_factor = 1;
aheader.trajectory = '';
aheader.sPosition = [0 0 0];

bDoLoop=true;
bDoParse=false;
ascconv_begin = false;
while (bDoLoop)
    s=fgetl(fid);
    if(isempty(s))
        continue;
    end;
    %     display(s);
    %this is necessary for < vb13 (check for end of file)
    if(s==-1)
        bDoLoop=false;
        break;
    elseif(strfind(s,'### ASCCONV BEGIN'))
        ascconv_begin = true;
        continue;
    elseif(ascconv_begin && ~isempty(strfind(s,'%CustomerSeq%')))
        bDoParse=true;
        continue
    elseif(strfind(s,'### ASCCONV END'))
        ascconv_begin = false;
        if bDoParse==true
            bDoParse=false;
            bDoLoop=false;
            break;
        end
    end;
    if(bDoParse)
        try
            c=textscan(s,'%s%s%[^\n]',1, bszopt{:});
        catch
            warning('One line of the header couldn''t be read. Maybe the header is not consistent.');
        end
        
        for i=1:length(c), c{i} = char(c{i}); end  % convertion cellstr to str for each element
        
        if(strcmp(c{1},'ulVersion'))
        elseif(strcmp(c{1},'tSequenceFileName'))
            aheader.sequence = c{3}(2:end-1);  % Without quotation marks
        elseif(strcmp(c{1},'lRepetitions'))
            aheader.numRepetitions=str2double((c{3}))+1;  %%% FT: c{3} is a scalar, str2double is faster
        elseif strcmp(c{1},'sKSpace.ucDimension')
            if length(c{3}) == 1  % should be the case for VD11
                aheader.dimension = str2double(c{3});
            else                  % should be the case for VB17
                c{3} = str2double(c{3}(3:end));
                if c{3}==2
                    aheader.dimension = 2;
                elseif c{3}==4
                    aheader.dimension = 3;
                end
            end
        elseif(strcmp(c{1},'alTR[0]'))
            aheader.tr=str2double((c{3}))*10^(-6);
        elseif(strncmp(c{1},'alTE[', 5))
            aheader.te(str2double(c{1}(6:end-1))+1) = str2double(c{3})*10^(-6);
        elseif(strcmp(c{1},'sProtConsistencyInfo.flNominalB0'))
            aheader.B0=round(str2double((c{3})));
        elseif(strcmp(c{1},'asCoilSelectMeas[0].asList[0].sCoilElementID.tCoilID'))
            aheader.coil=(c{3});
        elseif(strcmp(c{1},'sRXSPEC.alDwellTime[0]'))
            aheader.dwelltime=str2double((c{3}))*10^(-9);
        elseif(strcmp(c{1},'sSliceArray.lSize'))
            aheader.numSlices=str2double((c{3}));
        elseif(strcmp(c{1},'sKSpace.lBaseResolution'))
            aheader.resolution(1)=str2double((c{3}));
        elseif(strcmp(c{1},'sKSpace.lPhaseEncodingLines'))
            aheader.resolution(2)=str2double((c{3}));
        elseif(strcmp(c{1},'sKSpace.dSliceOversamplingForDialog'))
            aheader.slice_oversampling_factor=1+str2double((c{3}));
        elseif(strcmp(c{1},'lTotalScanTimeSec'))
            aheader.TotalScanTimeSec=str2double((c{3}));
        elseif(strcmp(c{1},'adFlipAngleDegree[0]'))
            aheader.flipAngle=str2double((c{3}));
        elseif(strcmp(c{1},'sFastImaging.lSegments'))
            aheader.trajectorySegments=str2double((c{3}));
        elseif(strcmpi(c{1},'sWiPMemBlock.tFree'))  % Case insensitive to work with VB17 and VD11
            aheader.trajectory = c{3}(2:end-1);
            % Read Free long Parameters =>  special card
        elseif(strcmp(c{1},'sWiPMemBlock.alFree[1]'))  % This one is for VB17
            tmp=str2double((c{3}));
            if tmp == 1
                aheader.exc_axis = 'slice';
            elseif tmp == 2
                aheader.exc_axis = 'phase';
            elseif tmp == 3
                aheader.exc_axis = 'read';
            end
        elseif(strcmp(c{1},'sWipMemBlock.alFree[2]'))  % This one is for VD11
            tmp=str2double((c{3}));
            if tmp == 131074
                aheader.exc_axis = 'slice';
            elseif tmp == 2
                aheader.exc_axis = 'phase';
            elseif tmp == 65538
                aheader.exc_axis = 'read';
            end
        elseif(strncmpi(c{1},'sWiPMemBlock.alFree[', 20))
            idx = str2double(c{1}(21:end-1));
            if idx == 2
                aheader.special3=str2double((c{3}));
            elseif idx == 3
                aheader.special4=str2double((c{3}));
            elseif idx == 4
                aheader.special5=str2double((c{3}));
            elseif idx == 5
                aheader.trajectCalib=str2double((c{3}));
            elseif idx == 7
                aheader.DummyScans=str2double((c{3}));
            elseif idx == 8
                aheader.special8=str2double((c{3}));
            elseif idx == 9
                aheader.special9=str2double((c{3}));
                
                % read trajectory indices
            elseif idx > 31 && idx < 56
                aheader.trajectIndices(floor(idx/2)-15, mod(idx, 2)+1)=str2double((c{3}));
            end
            
            % Read double parameters
        elseif(strcmp(c{1},'sWiPMemBlock.adFree[1]'))
            aheader.dspecia1=str2double((c{3}));
        elseif(strcmp(c{1},'sWiPMemBlock.adFree[2]'))
            aheader.dspecial2=str2double((c{3}));
            
        elseif(strcmp(c{1},'sProtConsistencyInfo.tBaselineString')) || (strcmp(c{1},'sProtConsistencyInfo.tMeasuredBaselineString'))
            aheader.IDEA_version = c{3}(5:8);  % only VB17
            
            
        elseif((strncmp(c{1},'sSliceArray.asSlice[', 20)))
            if(strcmp(c{1}(end-14:end),'0].sNormal.dCor'))
                aheader.sNormal.dCor_deg = str2double(c{3})/2/pi*360;
            elseif(strcmp(c{1}(end-15:end),'].sPosition.dCor'))
                aheader.sPosition(str2double(c{1}(21:end-16))+1,1) = str2double(c{3})/1000;
            elseif(strcmp(c{1}(end-15:end),'].sPosition.dSag'))
                aheader.sPosition(str2double(c{1}(21:end-16))+1,2) = str2double(c{3})/1000;
            elseif(strcmp(c{1}(end-15:end),'].sPosition.dTra'))
                aheader.sPosition(str2double(c{1}(21:end-16))+1,3) = str2double(c{3})/1000;
            elseif(strcmp(c{1}(end-11:end),'].dThickness'))
                aheader.sliceThickness(str2double(c{1}(21:end-12))+1)=str2double(c{3});
            elseif(strcmp(c{1}(end-13:end),'0].dReadoutFOV'))
                aheader.fov(1)=str2double((c{3}))*10^(-3);
            elseif(strcmp(c{1}(end-11:end),'0].dPhaseFOV'))
                aheader.fov(2)=str2double((c{3}))*10^(-3);
            elseif(strcmp(c{1}(end-13:end),'0].dInPlaneRot'))
                aheader.inPlaneRot=str2double((c{3}));
            end
        end
    end
end
aheader.sPosition_Coord = {'Cor', 'Sag', 'Tra'};

%determine some indirect parameters from header information
try
aheader.fov(3) = aheader.numSlices*aheader.sliceThickness(1)/1000;
aheader.resolution(3)=aheader.numSlices;
end