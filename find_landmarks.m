function [L, S, maxes] = find_landmarks(D, dilate_size)
%FIND_LANDMARKS Extraccion landmarks
%   L - Matriz con los landmarks
%   S - Espectrograma pre-procesado
%   maxes - Matriz con la posicion de los maximos de S

%% Obtencion espectrograma S
    N = 512; % 512/8000 = 64ms
    solape = N/2; 
    ventana = hamming(N);

    [S, F, T] = spectrogram(D(:,1), ventana, solape);
    S = S(1:end-1,:); % S tiene 257 filas. Quitar la ultima -> 8 bits

%% Pre-procesado del espectrograma
    S = abs(S);
    S = max(S, max(S(:))/1e3); % Eliminar picos pequeños.
    S = 20*log10(S); % Tomar dB.
    S = S - mean(S(:)); % Restar valor medio.
    
    % Filtramos por filas
    B = [1, -1]; A = [1, -0.98]; 
    S = filter(B, A, S.'); % Filtra por columnas -> Trasponemos
    S = S.'; % Deshacemos la traposicion

%% Extracción de máximos
    SE = strel('square', dilate_size); % Generamos elemento estructurante cuadrado para la dilatacion.
    S_dil = imdilate(S, SE); % Realizamos a S la dilatacion.
    
    [row, col] = find(S == S_dil); % Buscamos puntos donde la imagen dilatada sea igual a la original
    maxes = [row, col];

%% Emparejamiento de máximos y formación de L
    
    L = NaN;
    tmaxes = sortrows(maxes,2);
    for i = 1:size(tmaxes, 1)
        ti = tmaxes(i, 2);
        fi = tmaxes(i, 1);
        
        [row, col] = find( (tmaxes(:, 2)-ti) < 64, 1, 'last');
        
        fmaxes = tmaxes(i+1:row, :);
        fmaxes = sortrows(fmaxes, 1);       
        [rowi, col] = find( abs(fmaxes(:, 1)-fi) < 32, 1, 'first');
        [rowe, col] = find( abs(fmaxes(:, 1)-fi) < 32, 1, 'last');
        
        J = fmaxes(rowi:rowe, :);
        
        if(length(J) > 0)
            l = [ones(size(J,1),1), ones(size(J,1),1), J(:,1) - fi, J(:,2) - ti];
            l(:,1) = ti;
            l(:,2) = fi;
            
            if(size(l,1) > 3)
                l = l(1:3, :);
            end
            
            if(length(L) > 1)
                L = [L; l];
            else
                L = l;
            end
        end
    end
end

