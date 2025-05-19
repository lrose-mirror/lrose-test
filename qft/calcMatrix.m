function [matOut1,matOut2,matOut3]=calcMatrix(inS,d,w,delta)

% Create state vectors
inCut=inS(:,1:end-1);

cutoff=size(inCut,1);

% Calculate matrix elements
matOut1=zeros(cutoff,cutoff,length(w));
matOut2=zeros(cutoff,cutoff,length(w));
matOut3=zeros(cutoff,cutoff,length(w));

parfor ii=1:cutoff
    %for ii=1:cutoff
    for jj=1:cutoff
        diffIJ=inCut(ii,:)-inCut(jj,:);

        nonZeroAll=diffIJ~=0;
        nonZero=sum(nonZeroAll);
        indNZ=find(nonZeroAll==1);

        if nonZero==0 % Zero
            matOut1(ii,jj,:)=squeeze(matOut1(ii,jj,:))+sum((inCut(ii,:)+1/2).*(w./2),2);
            matOut2(ii,jj,:)=squeeze(matOut2(ii,jj,:))+sum((inCut(ii,:)+1/2),2)./w;
            matOut3(ii,jj,:)=squeeze(matOut3(ii,jj,:))+sum((3.*(1+2.*inCut(ii,:)+2.*inCut(ii,:).^2))./(4.*w.^2),2);
        elseif nonZero==1 % One
            diff1=inCut(ii,indNZ)-inCut(jj,indNZ);
            n=min([inCut(ii,indNZ),inCut(jj,indNZ)]);
            if abs(diff1)==2
                matOut1(ii,jj,:)=squeeze(matOut1(ii,jj,:))+sqrt((n+1)*(n+2))./(2.*w).* ...
                    ((-w.^2)/2);
                matOut2(ii,jj,:)=squeeze(matOut2(ii,jj,:))+sqrt((n+1)*(n+2))./(2.*w);
                matOut3(ii,jj,:)=squeeze(matOut3(ii,jj,:))+sqrt((n+1)*(n+2))./(2.*w).*(3+2*n)./(w);
            elseif abs(diff1)==4
                matOut3(ii,jj,:)=squeeze(matOut3(ii,jj,:))+1./(4*w.^2)*sqrt((n+1)*(n+2)*(n+3)*(n+4));
            end
        elseif nonZero==2 % Two
            diffDist=indNZ(2)-indNZ(1);
            if abs(diffDist)==1 | abs(diffDist)==d-1
                n=min([inCut(ii,indNZ(1)),inCut(jj,indNZ(1))]);
                m=min([inCut(ii,indNZ(2)),inCut(jj,indNZ(2))]);
                diff2=inCut(ii,indNZ(1))-inCut(jj,indNZ(1));
                diff3=inCut(ii,indNZ(2))-inCut(jj,indNZ(2));
                if abs(diff2)==1 & abs(diff3)==1
                    matOut1(ii,jj,:)=squeeze(matOut1(ii,jj,:))-1./(2.*w*delta^2)*sqrt((n+1)*(m+1));
                end
            end
        end
    end
end