function matOutE=calcMatrix_working(evensS,d,w,lambda,delta,m2)

% Create state vectors
evens=evensS(:,1:end-1);

stateVe=cell(1,size(evens,1));
normFe=nan(size(evens,1),1);

for ii=1:size(evens,1)
    stateVe{ii}=unique(perms(evens(ii,:)),'rows');
    normFe(ii)=size(stateVe{ii},1);
end

%cutoff=length(stateVe);
cutoff=50;

% Calculate matrix elements
matOutE=zeros(cutoff);

%parfor ii=1:cutoff
for ii=1:cutoff
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
                    matOutE(ii,jj)=matOutE(ii,jj)+sum((stII(kk,:)+1/2).*(w/2+(m2+2./delta.^2)/(2.*w))+ ...
                        (3.*lambda.*(1+2.*stII(kk,:)+2.*stII(kk,:).^2))/(4.*delta.*w.^2));
                elseif nonZero==1 % One
                    diff1=stII(kk,indNZ)-stJJ(ll,indNZ);
                    n=min([stII(kk,indNZ),stJJ(ll,indNZ)]);
                    if abs(diff1)==2
                        matOutE(ii,jj)=matOutE(ii,jj)+sqrt((n+1)*(n+2))/(2*w)* ...
                            ((m2+2/delta^2-w^2)/2+ ...
                            lambda*(3+2*n)/(delta*w));
                    elseif abs(diff1)==4
                        matOutE(ii,jj)=matOutE(ii,jj)+lambda/(4*delta*w^2)*sqrt((n+1)*(n+2)*(n+3)*(n+4));
                    end
                elseif nonZero==2 % Two
                    diffDist=indNZ(2)-indNZ(1);
                    if abs(diffDist)==1 | abs(diffDist)==d-1
                        n=min([stII(kk,indNZ(1)),stJJ(ll,indNZ(1))]);
                        m=min([stII(kk,indNZ(2)),stJJ(ll,indNZ(2))]);
                        diff2=stII(kk,indNZ(1))-stJJ(ll,indNZ(1));
                        diff3=stII(kk,indNZ(2))-stJJ(ll,indNZ(2));
                        if abs(diff2)==1 & abs(diff3)==1
                            matOutE(ii,jj)=matOutE(ii,jj)-1/(2*w*delta^2)*sqrt((n+1)*(m+1));
                        end
                    end
                end
            end
        end
        matOutE(ii,jj)=matOutE(ii,jj)*normOut;
    end
end