function [vecOut]=calcMatrix_corr(inS,d)

% Create state vectors
inCut=inS(:,1:end-1);

cutoff=size(inCut,1);
distSize=floor(d/2);

% Calculate matrix elements
vecOut=zeros(cutoff,cutoff,distSize);

%parfor ii=1:cutoff
for ii=1:cutoff
    for jj=1:cutoff

        diffIJ=inCut(ii,:)-inCut(jj,:);

        nonZeroAll=diffIJ~=0;
        nonZero=sum(nonZeroAll);
        indNZ=find(nonZeroAll==1);

        if nonZero==2 % Two
            diffDist=indNZ(2)-indNZ(1);
            diffDistAbs=min([abs(diffDist),d-abs(diffDist)]);

            n=min([inCut(ii,indNZ(1)),inCut(jj,indNZ(1))]);
            m=min([inCut(ii,indNZ(2)),inCut(jj,indNZ(2))]);
            diff2=inCut(ii,indNZ(1))-inCut(jj,indNZ(1));
            diff3=inCut(ii,indNZ(2))-inCut(jj,indNZ(2));
            if abs(diff2)==1 & abs(diff3)==1
                vecOut(ii,jj,diffDistAbs)=squeeze(vecOut(ii,jj,diffDistAbs))+sqrt((n+1)*(m+1));
            end
        end
    end
end