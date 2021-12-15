% Compare convStrat output with lightning data

clear all;
close all;

addpath(genpath('~/git/lrose-test/convstrat/dataProcessing/'));

startTime=datetime(2015,6,1,0,0,0);
endTime=datetime(2015,7,17,0,0,0);

% startTime=datetime(2015,6,1,0,0,0);
% endTime=datetime(2015,6,1,3,0,0);

saveData=1;

indirOrig='/scr/cirrus1/rsfdata/projects/convstrat/mdv/gpm/pecan/input/';
indir=['/scr/cirrus1/rsfdata/projects/pecan/mdv/conv_strat/gpm/'];

outdir=['/scr/cirrus1/rsfdata/projects/convstrat/analysis/gpmPECAN/'];

flist=makeFileList(indir,startTime,endTime,'20YYMMDDxhhmmss',1);

%% Loop through radar files

textureAll=[];
convectivityAll=[];
dbzAll=[];
part3dAll=[];

for ii = 1:length(flist)
    file=flist{ii};

    disp(file);

    texture3D=ncread(file,'DbzTexture3D');
    convectivity3D=ncread(file,'Convectivity3D');
    refl3D=ncread(file,'Dbz3D');
    part3D=ncread(file,'Partition3D');

    highInd=find(refl3D>42);
    highText=texture3D(highInd);
    highConv=convectivity3D(highInd);
    highRefl=refl3D(highInd);
    highPart=part3D(highInd);

    textureAll=cat(1,textureAll,highText);
    convectivityAll=cat(1,convectivityAll,highConv);
    dbzAll=cat(1,dbzAll,highRefl);
    part3dAll=cat(1,part3dAll,highPart);
end

%% Plot conv vs dbz

close all

lfReflConv=cat(2,dbzAll,convectivityAll);
lfReflConv(any(isnan(lfReflConv),2),:)=[];

centers={42.5:1:floor(max(max(lfReflConv(:,1))))+0.5 0.05:0.1:0.95};

tickLocX=0.5:2:50.5;
tickLabelX={'42','44','46','48','50','52','54','56','58',...
    '60','62','64','66','68','70','72','74','76','78','80'};
tickLocY=0.5:1:11.5;
tickLabelY={'0','0.1','0.2','0.3','0.4','0.5','0.6','0.7','0.8','0.9','1'};

N=hist3(lfReflConv,'Ctrs',centers);
N(N==0)=nan;
N=N';

fig=figure('Position',[200 500 900 800],'DefaultAxesFontSize',12);
colormap('jet');

imagesc(N,'AlphaData',~isnan(N))
set(gca,'YDir','normal');
set(gca,'Xtick',tickLocX);
set(gca,'Xticklabel',tickLabelX);
set(gca,'Ytick',tickLocY);
set(gca,'Yticklabel',tickLabelY);
xlim([0.5 ceil(max(max(lfReflConv(:,1))))-42])
ylim([0.5 10.5])
colorbar
xlabel('Reflectivity (dBZ)');
ylabel('Convectivity');

print([outdir,'highRefl_',datestr(startTime,'yyyymmdd_HHMM'),'_to_',datestr(endTime,'yyyymmdd_HHMM'),'.png'],'-dpng','-r0')
%% Save data
if saveData
    save([outdir,'texture_',datestr(startTime,'yyyymmdd_HHMM'),'_to_',datestr(endTime,'yyyymmdd_HHMM'),'.mat'],...
        'textureAll','-v7.3');
    save([outdir,'convectivity_',datestr(startTime,'yyyymmdd_HHMM'),'_to_',datestr(endTime,'yyyymmdd_HHMM'),'.mat'],...
        'convectivityAll','-v7.3');
    save([outdir,'dbz_',datestr(startTime,'yyyymmdd_HHMM'),'_to_',datestr(endTime,'yyyymmdd_HHMM'),'.mat'],...
        'dbzAll','-v7.3');
    save([outdir,'part_',datestr(startTime,'yyyymmdd_HHMM'),'_to_',datestr(endTime,'yyyymmdd_HHMM'),'.mat'],...
        'part3dAll','-v7.3');
end
