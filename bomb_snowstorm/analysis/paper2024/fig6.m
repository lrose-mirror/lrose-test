% Plot hit miss table

clear all
close all

clutt=0; % Plot the ones with or without clutter

R1R2=1;

% 
% indir='/scr/sci/romatsch/data/fromJohn/regModel/';
% figdir='/scr/sci/romatsch/nexrad/tsPlotJohn/regModel/';

%     indir='/scr/sci/romatsch/data/fromJohn/regModel/noClutter/';
%     figdir='/scr/sci/romatsch/nexrad/tsPlotJohn/regModel/noClutterR1/';

indir='/scr/sci/romatsch/data/fromJohn/regModel/widthEst_V3/';
figdir='/scr/sci/romatsch/nexrad/tsPlotJohn/regModel/widthEstR1_V3/';

if ~exist(figdir,'dir')
    mkdir(figdir)
end

infilesAll=dir([indir,'*.d']);

colLims=[-3,3,24; % mphi
    -20,1,20; % mpow
    -0.03,0.02,20; % mrho
    -2,2,16; % mvel
    -2,2,16; % mwth
    -0.25,0.25,20; % mzdr
    0,5,20; % sphi
    0,4,16; % spow
    0,0.015,15; % srho
    0,4,16; % svel
    0,4,16; % swth
    0,1,20]; % szdr

colSD=jet(16);
colSD=colSD(3:end,:);
colSD=cat(1,[1,1,1;0.5,0.5,1],colSD);

colPB=jet(64);
colPB=flipud(colPB(9:end,:));
ls01=linspace(0,1,8);
lsx1=linspace(colPB(end,2),1,8);
lsb=cat(2,ls01',lsx1',ones(8,1));
colPB=cat(1,colPB,lsb);
colPB=cat(1,colPB,[1,1,1;1,0.9,0.9;1,0.8,0.8]);

ls01=linspace(0,1,6);
blues=cat(2,ls01',ls01',ones(6,1));
reds=cat(2,ones(6,1),flipud(ls01'),flipud(ls01'));
colRB=cat(1,blues,reds);
colRB=cat(1,[0,0,0.5;0,0,0.75],colRB,[0.75,0,0;0.5,0,0]);
colRB=flipud(colRB);

for ii=1:length(infilesAll)

    infile=infilesAll(ii).name;

    indata=readData_Torres([indir,infile]);

    velAx=indata.tableOut(:,1,1);
    velAx=[velAx;velAx(end)+(velAx(end)-velAx(end-1))];
    widthAx=indata.width;
    widthAx=[widthAx;widthAx(end)+(widthAx(end)-widthAx(end-1))];

    if R1R2==1
        titlestr={'R1','WN'};
    else
        titlestr={'R2','WN'};
    end

    close all

    fig1=figure('DefaultAxesFontSize',12,'position',[3,100,1500,500]);

    if R1R2==1
        colIn=[2,5];
    else
        colIn=[3,5];
    end

    dname={'d1','d2'};

    for jj=1:2

        plotData=squeeze(indata.tableOut(:,colIn(jj),:));
        plotData=cat(1,plotData,plotData(end,:));
        plotData=cat(2,plotData,plotData(:,end));

        sub=subplot(1,3,jj);
        hold on

        if ii==8 | ii==10 | ii==11
            colormap(colSD);
        elseif ii==2
            colormap(colPB);
        elseif ii==4 | ii==5
            colormap(colRB);
        else
            colormap(jet(colLims(ii,3)));
        end

        pd.(dname{jj})=plotData';

        surf(velAx,widthAx,plotData');

        xlim([velAx(1),velAx(end)]);
        ylim([widthAx(1),widthAx(end)]);

        xtickAll=velAx(1:end-1)+(velAx(2:end)-velAx(1:end-1));
        sub.XTick=xtickAll(1:10:end);
        sub.XTickLabel=cellfun(@(x) num2str(x,'%.1f'),{velAx(1:10:end-1)},'un',0);
        sub.XTickLabelRotation=0;

        sub.YTick=widthAx(1:end-1)+(widthAx(2:end)-widthAx(1:end-1))/2;
        sub.YTickLabel=cellfun(@num2str,{widthAx(1:end-1)},'un',0);

        xlabel('Velocity (m s^{-1})');

        titlen=strsplit(infile,'.');

        title([titlestr{jj},' ',titlen{1}]);

        if jj==1
            ylabel('Spectrum width (m s^{-1})');
            plotPos=sub.Position;
        end
        caxis(colLims(ii,1:2));
        colorbar
    end

    sub1=subplot(1,3,3);
    hold on

    plotData=pd.d2-pd.d1;
    sub1.Colormap=jet(20);

    surf(velAx,widthAx,plotData);

    xlim([velAx(1),velAx(end)]);
    ylim([widthAx(1),widthAx(end)]);

    xtickAll=velAx(1:end-1)+(velAx(2:end)-velAx(1:end-1));
    sub1.XTick=xtickAll(1:10:end);
    sub1.XTickLabel=cellfun(@(x) num2str(x,'%.1f'),{velAx(1:10:end-1)},'un',0);
    sub1.XTickLabelRotation=0;

    sub1.YTick=widthAx(1:end-1)+(widthAx(2:end)-widthAx(1:end-1))/2;
    sub1.YTickLabel=cellfun(@num2str,{widthAx(1:end-1)},'un',0);

    xlabel('Velocity (m s^{-1})');

    titlen=strsplit(infile,'.');

    if R1R2==1
        title(['WN-R1 ',titlen{1}]);
    else
        title(['WN-R2 ',titlen{1}]);
    end

    colLimDiff=max(max(abs(plotData(5:end,8:end))));

    colTick=colLimDiff*2/20;

    caxis([-colLimDiff-colTick,colLimDiff+colTick]);
    cb=colorbar;

    cb.Ticks=-colLimDiff-colTick:colTick:colLimDiff+colTick;

    set(gcf,'PaperPositionMode','auto')
    print(fig1,[figdir,'comp_',titlen{1},'.png'],'-dpng','-r0')
end