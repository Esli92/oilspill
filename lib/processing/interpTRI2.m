function [Uout] = interpTRI2(lon, lat, ele, pele, Uin, xp, yp)

Uout = xp*0;
cantP = length(xp);

for ii = 1:cantP
    if (pele(ii)==0)
        pele(ii)=findTRIParticleIni(xp(ii),yp(ii));
    end
    if ~(inside(pele(ii),xp(ii),yp(ii)))
        pele(ii) = findTRIParticle(pele(ii),xp(ii),yp(ii));
    end
    if (pele(ii)>0)
        xt = lon(ele(pele(ii),:));
        yt = lat(ele(pele(ii),:));
        ut = Uin(ele(pele(ii),:));
        
        F = scatteredInterpolant(xt,yt,ut);
        F.ExtrapolationMethod = 'none';
        % Evaluate the interpolant at query locations (xp,yp).
        Uout(ii) = F(xp(ii),yp(ii));
    end
end
end