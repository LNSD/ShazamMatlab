function show_landmarks(L, S, maxes, varargin)
%SHOW_LANDMARKS Extracción landmarks: Comprobación
%   L, S y maxes son los resultados de find landmarks
%   T - Parametro T = [t1, t2] <-- varargin = arg entrada opcional

t1 = 1;
t2 = size(S,2);

if length(varargin) == 1
    T = varargin{1};
    t1 = T(1);
    t2 = T(2);
end

pcolor(S(:,t1:t2)); shading interp
pause 

hold on
if ~(isempty(maxes) && isempty(L))
    % Dibujo circulos en los maximos
    plot(maxes(:,2), maxes(:,1), 'Ok','LineWidth', 2);
    
    % Dibujo relaciones con linea roja
    for i = 1:size(L,1)
        ti = L(i,1);
        fi = L(i,2);
        tj = L(i,4) + ti;
        fj = L(i,3) + fi;

        plot([ti,tj],[fi,fj], 'r','LineWidth', 2) 
    end
end

hold off

end
