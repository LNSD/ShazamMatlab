function [ hashes, next_song_id ] = create_database( directory_name )
%CREATE_DATABASE Crea la base de datos de hashes.
%   Busca si existe en la carpeta el archivo donde se
%   almacenan los hash. Si no existe lo crea.

exists = false;
dirlist = dir(directory_name);

for i = 1:length(dirlist)
    if (strcmp(dirlist(i).name, 'hashes.mat'))
        
        exists = true;
        vars = load(strcat(directory_name,'/', dirlist(i).name), 'hashes', 'next_song_id');
        
        hashes = vars.hashes;
        next_song_id = vars.next_song_id;
    end
end

if ~exists % Si no existe hashes.mat se crea.
    hashes = containers.Map('KeyType','uint32','ValueType','any');
    next_song_id = 0;
    
    save(strcat(directory_name,'/','hashes'), 'hashes', 'next_song_id');
end

end
