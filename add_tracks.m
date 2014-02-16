function add_tracks( directory_name, varargin )
%ADD_TRACKS Generación base de datos.
% Debe leer todos los wav y mp3 de una carpeta
%   1 - Remuestrea a 8kHz
%   2 - Extrae hashes
%   3 - Guarda resultados
%
% Tres niveles de verbosidad estan definidos para debugging:
%   - 'd': Muestra: 'song_id <-> nombre cancion' + Elapsed time
%   - 'dd': Muestra 'Elapsed time' subprocesos
%   - 'ddd': Muestra, cancion a cancion, STFT + Landmarks
% Ejemplo: add_tracks('Target', 'dd')

clc

%% Inicializacion de variables
[hashes, song_id] = create_database(directory_name);
dirlist = dir(directory_name);
debug = 0;

if length(varargin) == 1
    mode = varargin{1};
    if strcmp(mode,'d')
        debug = 1;
    end
    if strcmp(mode,'dd')
        debug = 2;
    end
    if strcmp(mode,'ddd')
        debug = 3;
    end
end

if debug >= 1
    tic % Calculo del tiempo de procesado. Inicio del 'stopwatch'
end

%% Recorremos el directorio en busca de archivos de audio.

for i = 1:length(dirlist)
    [pathstr, name, ext] = fileparts(dirlist(i).name);
    if (strcmp(ext,'.mp3') || strcmp(ext,'.wav') || strcmp(ext,'.wave'))

        if debug == 0
            STR = sprintf('song_id: %d - Track: %s', song_id, dirlist(i).name);
            disp(STR);
        else
            if debug >= 1
                t_ini = toc;
                STR = sprintf('Start track processing: \n\tAssigned song_id: %d \n\tTrack name: %s', song_id, dirlist(i).name);
                disp(STR);
            end
        end
        
        
        %% Remuestreo a 8kHz
        % Debug: Subprocess time init
        if debug >= 2
            t_ini_d = toc;
        end
        
        file_name = strcat(directory_name,'/',dirlist(i).name);
        [y,Fs] = audioread(file_name);
        % info = audioinfo(file_name)
        
        [P,Q] = rat(8000/Fs);
        x = resample(y,P,Q);
        
        % Debug: Subprocess time clac + display
        if debug >= 2
            t_end_d = toc;
            STR = sprintf('\nResampling: \n\tElapsed time: %.5f \n', (t_end_d-t_ini_d));
            disp(STR);
        end
        
        %% Extraccion de hashes
        
        % Debug: Subprocess time init
        if debug >= 2
            t_ini_d = toc;
        end
        
        [L, S, maxes] = find_landmarks(x, 30);
        
         % Debug: Subprocess time clac + display
        if debug >= 2
            t_end_d = toc;
            STR = sprintf('\nFind_landmarks: \n\tElapsed time: %.5f \n', (t_end_d-t_ini_d));
            disp(STR);
            
            t_ini_d = toc;
        end
        
        H = landmark2hash(L, song_id);
        
        % Debug: Subprocess time clac + display
        if debug >= 2
            t_end_d = toc;
            STR = sprintf('\nLandmark2Hash: \n\tElapsed time: %.5f \n', (t_end_d-t_ini_d));
            disp(STR);
        end
        
        %% Almacenamiento de resultados
        
         % Debug: Subprocess time init
        if debug >= 2
            t_ini_d = toc;
        end
        
        hashes = record_hashes(H, hashes);
        
        % Debug: Subprocess time clac + display
        if debug >= 2
            t_end_d = toc;
            STR = sprintf('\nRecord_hashes: \n\tElapsed time: %.5f \n', (t_end_d-t_ini_d));
            disp(STR);
        end
        
        % Debug: Show landmarks
        if debug >= 3   
            show_landmarks(L,S,maxes);
            pause
        end
        
        % Debug: Elapsed time info (Track total)
        if debug >= 1
            t_end = toc;
            STR = sprintf('End: \n\tsong_id: %d \n\tElapsed time: %.5f',song_id, (t_end-t_ini));
            disp(STR);
        end
        
        song_id = song_id+1;
    end
end

%% Almacenamiento en disco
    next_song_id = song_id;
    save(strcat(directory_name,'/','hashes'), 'hashes', 'next_song_id');

    % Debug: Elapsed time info (Total)
    if debug >= 1
        t_end = toc;
        STR = sprintf('\n\nResult: \n\tTotal songs: %d \n\tTotal elapsed time: %.5f',song_id, t_end);
        disp(STR);
    end
end

