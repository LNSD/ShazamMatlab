function hashes = record_hashes(H, hashes)
%RECORD_HASHES Guarda el hash en el map.
%   H: Hash a guardar
%       1 - id song
%       2 - ti 
%       3 - hash value
%   hashes: Map donde se almacenan los hashes.
%
%NOTA: Si ya se han añadido una relacion hash & id/ti, no se comprueba, lo
%   añade otra vez aunque ya exista. No debe ser problema si no se
%   intenta añadir 2 veces el mismo hash.

    
    for i = 1:size(H,1)
        
        id = H(i,1);
        ti = H(i,2);
        hash = H(i,3);
        new_value = uint32(id*2^16 + ti);
        
        if isKey(hashes, hash)
            hashes(hash) = [hashes(hash), new_value];
%             ids = cell2mat(values(hashes,{hash}));
%             ids = [ids, new_value];
%             hashes = [hashes; containers.Map(hash, ids)];
        else
            hashes(hash) = new_value;
%             new_hash = containers.Map(hash, new_value);
%             hashes = [hashes; new_hash];
        end
    end

end

