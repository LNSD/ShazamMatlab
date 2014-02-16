function [ R ] = get_hash_hits(H, hashes)
%GET_HASH_HITS Buscar los hashes en la base de datos
%   H: son los hashes del query 
%                                H = [id_song, ti, hash_value; ...]
%   R: Matriz resultado que contiene para cada fila
%                                R = [song_id, diff_offset_time, hash; ...]
%   Donde diff_offset_time = t_target - t_query
%   Ordena filas de R segun song id
   R = NaN;
   query_keys = num2cell(H(:,3).');
   for i = 1:size(query_keys,2)
       if isKey(hashes, query_keys(i))
           ids = values(hashes, query_keys(i));
           ids = cell2mat(ids);

           id_target = (ids/(2^16)).';
           t_target = rem(ids,2^16).';
           t_query = H(i,2);
           hash_value = H(i,3);
           
           if  length(R) < 2
               R = [id_target, t_target - t_query, hash_value*ones(size(t_target))];
           else
               r = [id_target, t_target - t_query, hash_value*ones(size(t_target))];
               R = [R; r];
           end
       end
   end
   
   R = sortrows(R,1);
end

