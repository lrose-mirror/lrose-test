clear all
close all

figdir='/scr/virga1/rsfdata/projects/qft/';

% Initialize
d=6;
nMax=10;

w=1:0.25:10;
lambda=1;
delta=1/d;
m2=-(fliplr(10:1:20));
%m2=-16;

cutoffAll=100:100:2000;

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

for kk=1:length(cutoffAll)
    cutoff=cutoffAll(kk);

    disp(['Cutoff: ',num2str(cutoff)]);

    for jj=1:length(m2)

        disp(['Loop over m: ',num2str(jj),' of ',num2str(length(m2))]);

        disp('Even');
        % Evens
        matOutE=calcMatrix(evensS,d,w',lambda,delta,m2(jj),cutoff);
        %matOutE2=calcMatrix_working(evensS,d,w(2),lambda,delta,m2(jj));

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
    f1 = figure('Position',[200 500 600 1000],'DefaultAxesFontSize',12);

    t = tiledlayout(2,1,'TileSpacing','tight','Padding','tight');

    s1=nexttile(1);

    hold on
    plot(m2,minAllE,'-b','LineWidth',2);
    plot(m2,minAllO,'-g','LineWidth',2);

    xlabel('m2');
    ylabel('Minimum');

    xlim([m2(1),m2(end)]);
    ylim([floor(yDown),ceil(yUp)+1]);

    legend('Even','Odd');

    text(m2(1)+0.02,ceil(yUp),['Minimum difference: ',num2str(minDiffEO),' at m2=',num2str(m2(minInd))],'FontSize',12);

    grid on
    box on

    s2=nexttile(2);

    hold on
    plot(m2,minAllO-minAllE,'-k','LineWidth',2);

    xlabel('m2');
    ylabel('Minimum difference');

    xlim([m2(1),m2(end)]);
    %ylim([floor(yDown),ceil(yUp)+1]);

    legend('Odd minus even');

    %text(m2(1)+0.02,ceil(yUp),['Minimum difference: ',num2str(minDiffEO),' at m2=',num2str(m2(minInd))],'FontSize',12);

    grid on
    box on

    print([figdir,'qft_variations_cutoff',num2str(cutoff),'.png'],'-dpng','-r0');

end
%% Stop parallel pool
%
% poolobj=gcp('nocreate');
% delete(poolobj);