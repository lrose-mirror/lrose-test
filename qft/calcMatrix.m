function [matOut1,matOut2,matOut3]=calcMatrix(inS,d,w,delta,cutoff)

% Create state vectors
inCut=inS(:,1:end-1);

stateV=cell(1,size(inCut,1));
normF=nan(size(inCut,1),1);

for ii=1:size(inCut,1)
    stateV{ii}=unique(perms(inCut(ii,:)),'rows');
    normF(ii)=size(stateV{ii},1);
end

if isempty(cutoff)
    cutoff=length(inS);
end

% Calculate matrix elements
matOut1=zeros(cutoff,cutoff,length(w));
matOut2=zeros(cutoff,cutoff,length(w));
matOut3=zeros(cutoff,cutoff,length(w));

parfor ii=1:cutoff
%for ii=1:cutoff
    for jj=1:cutoff
        normOut=1/sqrt(normF(ii)*normF(jj));
        stII=stateV{ii};
        stJJ=stateV{jj};

        for kk=1:size(stII,1)
            for ll=1:size(stJJ,1)
                diffIJ=stII(kk,:)-stJJ(ll,:);
                
                nonZeroAll=diffIJ~=0;
                nonZero=sum(nonZeroAll);
                indNZ=find(nonZeroAll==1);

                if nonZero==0 % Zero
                    matOut1(ii,jj,:)=squeeze(matOut1(ii,jj,:))+sum((stII(kk,:)+1/2).*(w./2),2);
                    matOut2(ii,jj,:)=squeeze(matOut2(ii,jj,:))+sum((stII(kk,:)+1/2),2)./w;
                    matOut3(ii,jj,:)=squeeze(matOut3(ii,jj,:))+sum((3.*(1+2.*stII(kk,:)+2.*stII(kk,:).^2))./(4.*w.^2),2);
                elseif nonZero==1 % One
                    diff1=stII(kk,indNZ)-stJJ(ll,indNZ);
                    n=min([stII(kk,indNZ),stJJ(ll,indNZ)]);
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
                        n=min([stII(kk,indNZ(1)),stJJ(ll,indNZ(1))]);
                        m=min([stII(kk,indNZ(2)),stJJ(ll,indNZ(2))]);
                        diff2=stII(kk,indNZ(1))-stJJ(ll,indNZ(1));
                        diff3=stII(kk,indNZ(2))-stJJ(ll,indNZ(2));
                        if abs(diff2)==1 & abs(diff3)==1
                            matOut1(ii,jj,:)=squeeze(matOut1(ii,jj,:))-1./(2.*w*delta^2)*sqrt((n+1)*(m+1));
                        end
                    end
                end
            end
        end
        matOut1(ii,jj,:)=matOut1(ii,jj,:)*normOut;
        matOut2(ii,jj,:)=matOut2(ii,jj,:)*normOut;
        matOut3(ii,jj,:)=matOut3(ii,jj,:)*normOut;
    end
end