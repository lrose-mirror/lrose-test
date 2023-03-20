% Read and diplay S-PolKa data

clear all;
close all;

addpath(genpath('~/git/lrose-test/bomb_snowstorm/analysis/utils/'));

infile='cfrad.20190313_220622.994_to_20190313_220707.820_SUR.nc';
subdir='spol_adapt';

%zoomIn='_zoomCompare';
zoomIn='_zoom150km';

maxRange=[];

baseDir='~/data/bomb_snowstorm/cfradial/';
indir=[baseDir,subdir,'/sur/',infile(7:14),'/'];

figdir=['~/data/bomb_snowstorm/cfradial/figures/'];


if strcmp(zoomIn,'_zoom150km')
    xlimits=[-150 150];
    ylimits=[-150 150];
elseif strcmp(zoomIn,'_zoomCompare')
    xlimits=[-30 150];
    ylimits=[-100 120];
end

data.DBZ_F=[];
data.VEL_F=[];
data.WIDTH_F=[];
data.ZDR_F=[];
data.PHIDP_F=[];
data.RHOHV_F=[];

data=read_spol([indir,infile],data);

%% Cut range
if ~isempty(maxRange);
    inFields=fields(data);

    goodInds=find(data.range<=maxRange);

    for ii=1:size(inFields,1)
        if ~(strcmp(inFields{ii},'azimuth') | strcmp(inFields{ii},'elevation') | strcmp(inFields{ii},'time'))
            data.(inFields{ii})=data.(inFields{ii})(:,goodInds);
        end
    end
end

%% Plot preparation

ang_p = deg2rad(90-data.azimuth);

angMat=repmat(ang_p,size(data.range,1),1);

XX = (data.range.*cos(angMat));
YY = (data.range.*sin(angMat));

%% Z
close all

figure('Position',[200 500 2200 1200],'DefaultAxesFontSize',12);

s1=subplot(2,3,1);
surf(XX,YY,data.DBZ_F,'edgecolor','none');
view(2);
caxis([-10 65])
colorbar('XTick',-10:3:65)
title('DBZ (dBZ)')
xlabel('km');
ylabel('km');
s1.Colormap=dbz_default2;
axis equal
xlim(xlimits)
ylim(ylimits)

freezeColors(s1);

%% ZDR

s2=subplot(2,3,2);
h=surf(XX,YY,data.ZDR_F,'edgecolor','none');
view(2);
title('ZDR (dB)')
xlabel('km');
ylabel('km');

s2.Colormap=zdr_default;
colLims=[-inf,-20,-2,-1,-0.8,-0.6,-0.4,-0.2,0,0.2,0.4,0.6,0.8,1,1.5,2,2.5,3,4,5,6,8,10,15,20,50,99,inf];
applyColorScale(h,data.ZDR_F,colormap(zdr_default),colLims);

axis equal
xlim(xlimits)
ylim(ylimits)

freezeColors(s2);

%% VEL

s3=subplot(2,3,3);
h=surf(XX,YY,data.VEL_F,'edgecolor','none');
view(2);
title('VEL (m s^{-1})')
xlabel('km');
ylabel('km');

colM=colormap(vel_default2);
colLims=[-inf,-30,-26,-21,-17,-13,-10,-8,-6,-4,-2,-1,0,1,2,4,6,8,10,13,17,21,26,30,inf];
applyColorScale(h,data.VEL_F,colM,colLims);

axis equal
xlim(xlimits)
ylim(ylimits)

freezeColors(s3);

%% PHIDP

s4=subplot(2,3,4);
surf(XX,YY,data.PHIDP_F,'edgecolor','none');
view(2);
colorbar
caxis([-60,92]);
title('PHIDP (deg)')
xlabel('km');
ylabel('km');
s4.Colormap=phidp_default;

axis equal
xlim(xlimits)
ylim(ylimits)

freezeColors(s4);

%% RHOHV

s5=subplot(2,3,5);
h=surf(XX,YY,data.RHOHV_F,'edgecolor','none');
view(2);
title('RHOHV')
xlabel('km');
ylabel('km');

colM=colormap(rhohv_default);
colLims=[-inf,0,0.7,0.8,0.85,0.9,0.91,0.92,0.93,0.94,0.95,0.96,0.97,0.975,0.98,0.985,0.99,0.995,1.1,inf];
applyColorScale(h,data.RHOHV_F,colM,colLims);

axis equal
xlim(xlimits)
ylim(ylimits)

freezeColors(s5);

%% WIDTH

s6=subplot(2,3,6);
h=surf(XX,YY,data.WIDTH_F,'edgecolor','none');
view(2);
title('WIDTH (m s^{-1})')
xlabel('km');
ylabel('km');

colM=colormap(width_default);
colLims=[-inf,0,0.5,1,1.5,2,2.5,3,4,5,6,7,8,10,12.5,15,20,25,50,inf];
applyColorScale(h,data.WIDTH_F,colM,colLims);

axis equal
xlim(xlimits)
ylim(ylimits)

% %% ORDER
% 
% f1=figure('Position',[200 500 800 800],'DefaultAxesFontSize',12);
% 
% s=surf(XX,YY,data.order,'edgecolor','none');
% view(2);
% colorbar
% caxis([0 12]);
% title('Order')
% xlabel('km');
% ylabel('km');
% cm=jet(12);
% f1.Colormap=cm;
% axis equal
% xlim(xlimits)
% ylim(ylimits)
% 
% print([figdir,outstrIn,'/',outstr,'_ORDER.png'],'-dpng','-r0');
% 
% %% CMDFLAG
% 
% f1=figure('Position',[200 500 800 800],'DefaultAxesFontSize',12);
% 
% surf(XX,YY,data.cmdFlag,'edgecolor','none');
% view(2);
% cb4=colorbar;
% caxis([-0.5 1.5])
% title('CMD flag')
% xlabel('km');
% ylabel('km');
% f1.Colormap=[0,0,1;1,0,0];
% cb4.Ticks=[0 1];
% axis equal
% xlim(xlimits)
% ylim(ylimits)
% 
print([figdir,outstrIn,'/',outstr,'_.png'],'-dpng','-r0');
