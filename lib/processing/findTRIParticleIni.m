function [ peleout ] = findTRIParticleIni(xp,yp)
% findTRIParticle es una funcion para encontrar el triangulo (elemento) en
% el que esta el punto (xp,yp) a partir de su última pisicion conocida que
% es pelein.
global VF;

peleout = xp*0;
cantP = length(xp);
offset = 0.1;

%                 obj.LON = lon;
%                 obj.LAT = lat;
%                 obj.ELE = ele';
for ii = 1:cantP
    lista = [];
    cant = 0;
    Box = find((VF.LON > xp(ii) - offset) & (VF.LON < xp(ii) + offset) & ...
        (VF.LAT > yp(ii) - offset) & (VF.LAT < yp(ii) + offset));
    %     X = VF.LON(Indice);
    %     Y = VF.LAT(Indice);
    Indice = Box;
    for jj = 1:length(Indice)
        vecinos = VF.N2E(Indice(jj),:);
        for kk = 1:12
            if (vecinos(kk) > 0) && (sum(find(lista==vecinos(kk))) == 0)
                cant = cant + 1;
                lista(cant) = vecinos(kk);
            end
        end
    end
    for jj = 1:length(lista)
        if (inside(lista(jj),xp(ii),yp(ii)))
            peleout(ii) = lista(jj);
            break
        end
    end
end

end

