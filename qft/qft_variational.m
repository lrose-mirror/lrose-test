clear all
close all

% Initialize
d=5;
nMax=10;
vecIn=(0:nMax)';

w=1;
lambda=1;
delta=1/d;
m2=1;

%% Create pregens

% Create combinations, sort and unique
C=table2array(combinations(vecIn,vecIn,vecIn,vecIn,vecIn));
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

%% Evens

% Create state vectors
evens=evensS(:,1:end-1);

stateVe={};
normFe=nan(size(evens,1),1);

for ii=1:size(evens,1)
    stateVe{end+1}=unique(perms(evens(ii,:)),'rows');
    normFe(ii)=size(stateVe{end},1);
end

cutoff=length(stateVe);

% Calculate matrix elements
matOut=zeros(cutoff);

parfor ii=1:cutoff
    for jj=1:cutoff
        normOut=1/sqrt(normFe(ii)*normFe(jj));
        stII=stateVe{ii};
        stJJ=stateVe{jj};

        for kk=1:size(stII,1)
            for ll=1:size(stJJ,1)
                diffIJ=stII(kk,:)-stJJ(ll,:);
                
                nonZeroAll=diffIJ~=0;
                nonZero=sum(nonZeroAll);
                indNZ=find(nonZeroAll==1);

                if nonZero==0 % Zero
                    matOut(ii,jj)=matOut(ii,jj)+sum((stII(kk,:)+1/2).*(w/2+(m2+2./delta.^2)/(2.*w))+ ...
                        (3.*lambda.*(1+2.*stII(kk,:)+2.*stII(kk,:).^2))/(4.*delta.*w.^2));
                elseif nonZero==1 % One
                    diff1=stII(kk,indNZ)-stJJ(ll,indNZ);
                    n=min([stII(kk,indNZ),stJJ(ll,indNZ)]);
                    if abs(diff1)==2
                        matOut(ii,jj)=matOut(ii,jj)+sqrt((n+1)*(n+2))/(2*w)*(m2/2+1/delta^2-w^2/2+3* ...
                            lambda/(delta*w)+2*lambda*n/(delta*w));
                    elseif abs(diff1)==4
                        matOut(ii,jj)=matOut(ii,jj)+lambda/(4*delta*w^2)*sqrt((n+1)*(n+2)*(n+3)*(n+4));
                    end
                elseif nonZero==2 % Two
                    diffDist=indNZ(2)-indNZ(1);
                    if abs(diffDist)==1
                        n=min([stII(kk,indNZ(1)),stJJ(ll,indNZ(1))]);
                        m=min([stII(kk,indNZ(2)),stJJ(ll,indNZ(2))]);
                        diff2=stII(kk,indNZ(1))-stJJ(ll,indNZ(1));
                        diff3=stII(kk,indNZ(2))-stJJ(ll,indNZ(2));
                        if abs(diff2)==1 & abs(diff3)==1
                            matOut(ii,jj)=matOut(ii,jj)-1/(2*w*delta^2)*sqrt(n*m);
                        end

                    end
                end
            end
        end
    end
end

% Eigen values
ee=eig(matOut);
ee=sort(ee);