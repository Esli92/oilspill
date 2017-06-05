function [peleout] = findTRIParticle(pelein,xp,yp)
% findTRIParticle es una funcion para encontrar el triangulo (elemento) en
% el que esta el punto (xp,yp) a partir de su última pisicion conocida que
% es pelein.

peleout = xp*0;
cantP = length(xp);

for ii = 1:cantP
    tmp_pele = pelein(ii);
    if (tmp_pele > 0)
        pos = find(VF.el2el5(tmp_pele,:)==0,1);
        if isempty(pos) 
            pos = 56;
        else 
            pos = pos - 1;
        end
        for kk = 1:pos
            tmp_pele = VF.el2el5(tmp_pele,kk);
            if (inside(tmp_pele,xp(ii),yp(ii)))
                peleout(ii) = tmp_pele;
                break
            end
        end
    end
end
end