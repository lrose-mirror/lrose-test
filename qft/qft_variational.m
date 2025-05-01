clear all
close all

figdir='/scr/virga1/rsfdata/projects/qft/';

% Initialize
d=5;
nMax=10;

w=1:0.1:10;
lambda=1.3;
delta=1/d;
m1=(-4.2:0.1:-3.6);
m2=m1.^2;

cutoff=[];

%% Create pregens

% Create combinations
vecIn=(0:nMax)';
matIn=repmat(vecIn,1,d);
cellIn=num2cell(matIn,1);
sub=cell(1,numel(cellIn));
[sub{:}]=ndgrid(cellIn{:});
sub=cellfun(@(x)x(:),sub,'UniformOutput', false);
allPerms = cell2mat(sub);
C=fliplr(allPerms);

% sort and unique
uSorted=sort(C,2);
uC=unique(uSorted,'rows');

sumC=sum(uC,2);
uSumC=cat(2,uC,sumC);

sC=sortrows(uSumC,size(uSumC,2));

% Split into odd and even
evensS=[];
oddsS=[];

for ii=1:size(sC,1)
    if mod(sC(ii,end),2)==0
        evensS=cat(1,evensS,sC(ii,:));
    else
        oddsS=cat(1,oddsS,sC(ii,:));
    end
end

%% Loop over m2
minAllE=nan(1,length(m2));
minAllO=nan(1,length(m2));

for jj=1:length(m2)

    disp(['Loop over m: ',num2str(jj),' of ',num2str(length(m2))]);

    disp('Even');
    % Evens
    matOutE=calcMatrix(evensS,d,w',lambda,delta,m2(jj),cutoff);

    % Eigen values
    minE=nan(1,length(w));

    for ii=1:length(w)
        ee=eig(matOutE(:,:,ii));
        ee=sort(ee);
        minE(ii)=min(ee);
    end

    minAllE(jj)=min(minE);

    disp('Odd');
    % Odds
    matOutO=calcMatrix(oddsS,d,w',lambda,delta,m2(jj),cutoff);

    % Eigen values
    minO=nan(1,length(w));

    for ii=1:length(w)
        eo=eig(matOutO(:,:,ii));
        eo=sort(eo);
        minO(ii)=min(eo);
    end

    minAllO(jj)=min(minO);
end

diffEO=abs(minAllE-minAllO);

[minDiffEO,minInd]=min(diffEO);

%% Plot

yUp=max([minAllE,minAllO]);
yDown=min([minAllE,minAllO]);

close all
f1 = figure('Position',[200 500 600 600],'DefaultAxesFontSize',12);

hold on
plot(m1,minAllE,'-b','LineWidth',2);
plot(m1,minAllO,'-k','LineWidth',2);

xlabel('m');
ylabel('Minimum');

xlim([m1(1),m1(end)]);
ylim([floor(yDown),ceil(yUp)+1]);

legend('Even','Odd');

text(m1(1)+0.02,ceil(yUp),['Minimum difference: ',num2str(minDiffEO),' at m=',num2str(m1(minInd))],'FontSize',12);

grid on
box on

print([figdir,'qft_variations.png'],'-dpng','-r0');

%% Stop parallel pool

poolobj=gcp('nocreate');
delete(poolobj);