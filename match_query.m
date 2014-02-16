function [ R ] = match_query( query, database )
%MATCH_QUERY Busqueda de una cancion en la db (database:Map donde se
%                                              almacenan los hashes)
%   query: ruta a la cancion a buscar.
%   database: Ruta a contenedor MAP con los hashes del target (DB).
%
% La matriz R tiene en cada fila: [song_id, peak_max, offset_max]
%   Ordenar filas de mayor a menor peak_max
%   La primera fila es la mas probable, y comenzaria el query en offset_max
    
    load(database);
    song_id = -1;

    %% Remuestreo a 8kHz
    % info = audioinfo(query)
    [y,Fs] = audioread(query);
    
    [P,Q] = rat(8000/Fs);
    x = resample(y,P,Q);
    %x = x(:);

    %% Extraccion de hashes
    [L, S, maxes] = find_landmarks(x, 30);
    H = landmark2hash(L, song_id);
    show_landmarks(L,S,maxes);
    pause
    close

    %% Buscar los hashes en la base de datos
    %   R: Matriz resultado que contiene para cada fila
    %   R = [song_id, diff_offset_time, hash; ...]
    
    R = get_hash_hits(H, hashes);
       
    %% Buscar los picos de los histogramas
    
    % Ver los track_id distintos
    [uoffset, ind_first] = unique(R(:,1), 'first');
    
    % Contar cuantos distintos hay para cada track
    nr = size(R,1);
    utrkcounts = diff([ind_first', nr+1]).';
    
    R_data = [uoffset, ind_first, utrkcounts];
    R_data = sortrows(R_data, -3);
    
    % Si hay mas de 20 tracks distintos, nos quedamos con los tracks con
    % mayor numero de coincidencias.
    if length(uoffset) > 20
        R_data = R_data(1:20, :);
    end
    
    % Para cada cancion:
    %    Filtrar de R las filas con el song_id correspondiente
    %    Con unique y diff ver cual es el diff_offset_time mas frecuente
    
    nt = size(R_data, 1);
    Res = ones(nt, 3); % Memory preallocation
    
    % Calculo de los inicios y finales de las submatrices de song_id de R(hits)
    inis = R_data(:,2);
    ends = (R_data(:,2)+R_data(:,3)-1);
    
    % Cada cancion restante
    for i = 1:nt
        r = sortrows(R(inis(i):ends(i), :), 2);
        [uoffset, ind_first] = unique(r(:,2), 'first');
        nr = size(r,1);
        utrkcounts = diff([ind_first', nr+1]).';

        r_data = [uoffset, ind_first, utrkcounts];
        [C, I] = max(utrkcounts);
        Res(i,:) = [r(1,1), r_data(I, 1), r_data(I,3)];
    end
    
    %% Mayor pico -> hit
    
    % Ordenar filas de R por la frecuencia del diff_offset_time
    R = sortrows(Res, -3);
end

