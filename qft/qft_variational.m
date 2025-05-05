clear all
close all

figdir='/scr/virga1/rsfdata/projects/qft/';

% Initialize
d=6;
nMax=10;

w=1:0.25:10;
lambda=1;
delta=1/d;
m2=-(fliplr(0:2:20));
%m2=-16;

%cutoffAll=800:100:2000;
cutoffAll=100;

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

for kk=1:length(cutoffAll)
    cutoff=cutoffAll(kk);

    disp(['Cutoff: ',num2str(cutoff)]);

    minAllE=nan(1,length(m2));
    minAllEw=nan(1,length(m2));
    vecAllE=nan(cutoff,length(m2));
    minAllO=nan(1,length(m2));
    % minAllOw=nan(1,length(m2));
    % vecAllO=nan(cutoff,length(m2));
    x2exE=nan(1,length(m2));
    x4exE=nan(1,length(m2));

    for jj=1:length(m2)

        disp(['Loop over m: ',num2str(jj),' of ',num2str(length(m2))]);

        disp('Even');
        % Evens
        [matOutE1,matOutE2,matOutE3]=calcMatrix(evensS,d,w',lambda,delta,m2(jj),cutoff);
        matOutE=matOutE1+matOutE2.*(m2(jj)+2./delta.^2)./2+matOutE3.*lambda./delta;
        %matOutE=calcMatrix1(evensS,d,w',lambda,delta,m2(jj),cutoff);
        %matOutE2=calcMatrix_working(evensS,d,w(2),lambda,delta,m2(jj));

        % Eigen values
        minE=nan(1,length(w));
        vE=nan(cutoff,length(w));
        
        for ii=1:length(w)
            [V,D]=eig(matOutE(:,:,ii));
            ee=(D(sub2ind(size(D),1:size(D,1),1:size(D,2))))';
            [minE(ii),minEind]=min(ee);
            vE(:,ii)=V(:,minEind);
        end

        [minAllE(jj),minAllEind]=min(minE);
        minAllEw(jj)=w(minAllEind);
        vecAllE(:,jj)=vE(:,minAllEind);

        matThisE2=matOutE2(:,:,minAllEind);
        x2exE(jj)=vecAllE(:,jj)'*matThisE2*vecAllE(:,jj)/2;
        matThisE3=matOutE3(:,:,minAllEind);
        x4exE(jj)=vecAllE(:,jj)'*matThisE3*vecAllE(:,jj)/2;

        % disp('Odd');
        % % Odds
        % matOutO=calcMatrix(oddsS,d,w',lambda,delta,m2(jj),cutoff);
        % 
        % % Eigen values
        % minO=nan(1,length(w));
        % 
        % for ii=1:length(w)
        %     eo=eig(matOutO(:,:,ii));
        %     eo=sort(eo);
        %     minO(ii)=min(eo);
        % end
        % 
        % minAllO(jj)=min(minO);
    end

    bc=1-x4exE./x2exE.^2./3./d;
    % diffEO=abs(minAllE-minAllO);
    % 
    % [minDiffEO,minInd]=min(diffEO);
    % 
    % %% Plot
    % 
    % yUp=max([minAllE,minAllO]);
    % yDown=min([minAllE,minAllO]);

    close all
    f1 = figure('Position',[200 500 600 1000],'DefaultAxesFontSize',12);

    t = tiledlayout(2,1,'TileSpacing','tight','Padding','tight');

    s1=nexttile(1);

    hold on
    plot(m2,bc,'-b','LineWidth',2);
    % plot(m2,minAllO,'-g','LineWidth',2);
    % 
    % xlabel('m2');
    % ylabel('Minimum');
    % 
    % xlim([m2(1),m2(end)]);
    % ylim([floor(yDown),ceil(yUp)+1]);
    % 
    % legend('Even','Odd');
    % 
    % text(m2(1)+0.02,ceil(yUp),['Minimum difference: ',num2str(minDiffEO),' at m2=',num2str(m2(minInd))],'FontSize',12);
    % 
    % grid on
    % box on
    % 
    % s2=nexttile(2);
    % 
    % hold on
    % plot(m2,minAllO-minAllE,'-k','LineWidth',2);
    % 
    % xlabel('m2');
    % ylabel('Minimum difference');
    % 
    % xlim([m2(1),m2(end)]);
    % %ylim([floor(yDown),ceil(yUp)+1]);
    % 
    % legend('Odd minus even');
    % 
    % %text(m2(1)+0.02,ceil(yUp),['Minimum difference: ',num2str(minDiffEO),' at m2=',num2str(m2(minInd))],'FontSize',12);
    % 
    % grid on
    % box on
    % 
    % print([figdir,'qft_variations_cutoff',num2str(cutoff),'.png'],'-dpng','-r0');

end
%% Stop parallel pool

poolobj=gcp('nocreate');
delete(poolobj);