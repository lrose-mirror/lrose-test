function matOut=calcMatrix(inS,d,w,lambda,delta,m2,cutoff)

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
matOut=zeros(cutoff,cutoff,length(w));

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
                    matOut(ii,jj,:)=squeeze(matOut(ii,jj,:))+sum((stII(kk,:)+1/2).*(w./2+(m2+2./delta.^2)./(2.*w))+ ...
                        (3.*lambda.*(1+2.*stII(kk,:)+2.*stII(kk,:).^2))./(4.*delta.*w.^2),2);
                elseif nonZero==1 % One
                    diff1=stII(kk,indNZ)-stJJ(ll,indNZ);
                    n=min([stII(kk,indNZ),stJJ(ll,indNZ)]);
                    if abs(diff1)==2
                        matOut(ii,jj,:)=squeeze(matOut(ii,jj,:))+(sqrt((n+1)*(n+2))/(2.*w).* ...
                            ((m2+2/delta^2-w'.^2)/2+ ...
                            lambda*(3+2*n)/(delta.*w)))';
                    elseif abs(diff1)==4
                        matOut(ii,jj,:)=squeeze(matOut(ii,jj,:))+lambda./(4*delta.*w.^2)*sqrt((n+1)*(n+2)*(n+3)*(n+4));
                    end
                elseif nonZero==2 % Two
                    diffDist=indNZ(2)-indNZ(1);
                    if abs(diffDist)==1 | abs(diffDist)==d-1
                        n=min([stII(kk,indNZ(1)),stJJ(ll,indNZ(1))]);
                        m=min([stII(kk,indNZ(2)),stJJ(ll,indNZ(2))]);
                        diff2=stII(kk,indNZ(1))-stJJ(ll,indNZ(1));
                        diff3=stII(kk,indNZ(2))-stJJ(ll,indNZ(2));
                        if abs(diff2)==1 & abs(diff3)==1
                            matOut(ii,jj,:)=squeeze(matOut(ii,jj,:))-1./(2.*w*delta^2)*sqrt((n+1)*(m+1));
                        end
                    end
                end
            end
        end
        matOut(ii,jj,:)=matOut(ii,jj,:)*normOut;
    end
end