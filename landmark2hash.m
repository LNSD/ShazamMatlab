function H = landmark2hash( L, id_song )
%LANDMARK2HASH Convierte la info de un landmark a un codigo de 20 bits
%   Detailed explanation goes here
%   L = [ti , fi , fj - fi , tj - ti; ...]
%   H = [id_song, ti, hash_value; ...]
%   hash_value = 8bits(f1) + 6 bits(f2 - f1) + 6 bits(t2 - t1) = 20 bits

H = zeros(size(L,1), 3);

H(:, 1) = id_song;
H(:, 2) = uint32(L(:, 1)); % ti
H(:, 3) = uint32(L(:, 2)*2^12 + L(:, 3)*2^6 + L(:, 4)); %hash_value
end

