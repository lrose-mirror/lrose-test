% Read and diplay radar data

clear all;
close all;

addpath(genpath('~/git/lrose-test/bomb_snowstorm/analysis/utils/'));

maxRange=[];

figdir=['~/data/bomb_snowstorm/figures/'];

%% Loop through cases

fileID = fopen('compareFiles.txt');
inAll=textscan(fileID,'%s %s %s %f %f %f %f %f %f %f %f %s %s');
fclose(fileID);

for aa=1:size(inAll{1,1},1)

    %% Read file 1
    infile1=inAll{1,1}(aa);

    disp(['File 1: ',infile1{:}]);

    fileType=inAll{1,12}(aa);

    if strcmp(fileType{:},'nc')
        data1=[];

        data1.DBZ_F=[];
        data1.VEL_F=[];
        data1.WIDTH_F=[];
        data1.ZDR_F=[];
        data1.PHIDP_F=[];
        data1.RHOHV_F=[];
        data1.REGR_ORDER=[];

        data1=read_spol(infile1{:},data1);

    elseif strcmp(fileType{:},'table')
        data1=readDataTables(infile{:},' ');
        data1.azimuth=data1.azimuth';
    end

    %% Read file 2
    infile2=inAll{1,2}(aa);

    disp(['File 2: ',infile2{:}]);

    fileType=inAll{1,13}(aa);

    if strcmp(fileType{:},'nc')
        data2=[];

        data2.DBZ_F=[];
        data2.VEL_F=[];
        data2.WIDTH_F=[];
        data2.ZDR_F=[];
        data2.PHIDP_F=[];
        data2.RHOHV_F=[];
        data2.REGR_ORDER=[];

        data2=read_spol(infile2{:},data2);

    elseif strcmp(fileType{:},'table')
        data2=readDataTables(infile{:},' ');
        data2.azimuth=data2.azimuth';
    end

    %% Match azimuths

    [~,ia,ib]=intersect(data1.azimuth,data2.azimuth);

    inFields=fields(data1);
    for ii=1:size(inFields,1)
        if ~strcmp(inFields{ii},'range')
            data1.(inFields{ii})=data1.(inFields{ii})(ia,:);
            data2.(inFields{ii})=data2.(inFields{ii})(ib,:);
        end
    end
    
    %% Cut range
    if ~isempty(maxRange)
        
        goodInds=find(data1.range<=maxRange);

        for ii=1:size(inFields,1)
            if ~(strcmp(inFields{ii},'azimuth') | strcmp(inFields{ii},'elevation') | strcmp(inFields{ii},'time'))
                data1.(inFields{ii})=data1.(inFields{ii})(:,goodInds);
                data2.(inFields{ii})=data2.(inFields{ii})(:,goodInds);
            end
        end
    end

    %% Plot preparation

    ang_p = deg2rad(90-data1.azimuth);

    angMat=repmat(ang_p,size(data1.range,1),1);

    XX = (data1.range.*cos(angMat));
    YY = (data1.range.*sin(angMat));

    %% Z
    close all

    figure('Position',[200 500 2800 1200],'DefaultAxesFontSize',12);

    s1=subplot(2,4,1);
    surf(XX,YY,data1.DBZ_F,'edgecolor','none');
    view(2);
    caxis([-10 65])
    cb1=colorbar('XTick',-10:3:65);
    title('DBZ (dBZ)')
    xlabel('km');
    ylabel('km');
    s1.Colormap=dbz_default2;

    grid on
    box on
    
    %freezeColors(cb1);
    freezeColors(s1);
            
    %% ZDR

    s2=subplot(2,4,2);
    h=surf(XX,YY,data1.ZDR_F,'edgecolor','none');
    view(2);
    title('ZDR (dB)')
    xlabel('km');
    ylabel('km');

    s2.Colormap=zdr_default;
    colLims=[-inf,-20,-2,-1,-0.8,-0.6,-0.4,-0.2,0,0.2,0.4,0.6,0.8,1,1.5,2,2.5,3,4,5,6,8,10,15,20,50,99,inf];
    applyColorScale(h,data1.ZDR_F,colormap(zdr_default),colLims);

    grid on
    box on

    freezeColors(s2);
    freezeColors(colorbar);

    %% VEL

    s3=subplot(2,4,3);
    h=surf(XX,YY,data1.VEL_F,'edgecolor','none');
    view(2);
    title('VEL (m s^{-1})')
    xlabel('km');
    ylabel('km');

    grid on
    box on

    colM=colormap(vel_default2);
    colLims=[-inf,-30,-26,-21,-17,-13,-10,-8,-6,-4,-2,-1,0,1,2,4,6,8,10,13,17,21,26,30,inf];
    applyColorScale(h,data1.VEL_F,colM,colLims);

    freezeColors(colorbar);
    freezeColors(s3);

    %% ORDER

    s4=subplot(2,4,4);
    h=surf(XX,YY,data1.REGR_ORDER,'edgecolor','none');
    view(2);
    title('ORDER')
    xlabel('km');
    ylabel('km');

    s4.Colormap=turbo(12);
    caxis([0,12]);
    colorbar;

    grid on
    box on

    freezeColors(colorbar);
    freezeColors(s4);

    %% PHIDP

    s5=subplot(2,4,5);
    surf(XX,YY,data1.PHIDP_F,'edgecolor','none');
    view(2);
    colorbar
    caxis([-60,92]);
    title('PHIDP (deg)')
    xlabel('km');
    ylabel('km');
    s5.Colormap=phidp_default;

    grid on
    box on

    freezeColors(colorbar);
    freezeColors(s5);

    %% RHOHV

    s6=subplot(2,4,6);
    h=surf(XX,YY,data1.RHOHV_F,'edgecolor','none');
    view(2);
    title('RHOHV')
    xlabel('km');
    ylabel('km');

    colM=colormap(rhohv_default);
    colLims=[-inf,0,0.7,0.8,0.85,0.9,0.91,0.92,0.93,0.94,0.95,0.96,0.97,0.975,0.98,0.985,0.99,0.995,1.1,inf];
    applyColorScale(h,data1.RHOHV_F,colM,colLims);

    grid on
    box on

    freezeColors(colorbar);
    freezeColors(s6);

    %% WIDTH

    s7=subplot(2,4,7);
    h=surf(XX,YY,data1.WIDTH_F,'edgecolor','none');
    view(2);
    title('WIDTH (m s^{-1})')
    xlabel('km');
    ylabel('km');

    colM=colormap(width_default);
    colLims=[-inf,0,0.5,1,1.5,2,2.5,3,4,5,6,7,8,10,12.5,15,20,25,50,inf];
    applyColorScale(h,data1.WIDTH_F,colM,colLims);

    grid on
    box on

    freezeColors(colorbar);
    freezeColors(s7);

    %% Save first zoom

    linkaxes([s1,s2,s3,s4,s5,s6,s7],'xy');
    outstr=inAll{1,2}(aa);
    outstr=outstr{:};

    xlimits1=[inAll{1,3}(aa),inAll{1,4}(aa)];
    ylimits1=[inAll{1,5}(aa),inAll{1,6}(aa)];
    
    xlim(xlimits1)
    ylim(ylimits1)
    daspect(s1,[1 1 1]);
    daspect(s2,[1 1 1]);
    daspect(s3,[1 1 1]);
    daspect(s4,[1 1 1]);
    daspect(s5,[1 1 1]);
    daspect(s6,[1 1 1]);
    daspect(s7,[1 1 1]);
       
    print([figdir,outstr,'_zoom1.png'],'-dpng','-r0');

    %% Save second zoom

    xlimits2=[inAll{1,7}(aa),inAll{1,8}(aa)];
    ylimits2=[inAll{1,9}(aa),inAll{1,10}(aa)];
    
    xlim(xlimits2)
    ylim(ylimits2)
    daspect(s1,[1 1 1]);
    daspect(s2,[1 1 1]);
    daspect(s3,[1 1 1]);
    daspect(s4,[1 1 1]);
    daspect(s5,[1 1 1]);
    daspect(s6,[1 1 1]);
    daspect(s7,[1 1 1]);
        
    print([figdir,outstr,'_zoom2.png'],'-dpng','-r0');

end