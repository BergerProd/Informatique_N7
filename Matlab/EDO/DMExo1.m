clear all
close all

%% Exercice 1 : Demande Biochimique en Oxyg�ne 

%On utilise les variables globales afin qu'elles soient prises en compte
%dans la fonction D(t)
global Lo Dosat Kd Kr Do V 

%Donn�es Num�riques
n = 1000 ;%nombres de points
dt = 0.01; %pas de temps

%Param�tres
Lo = 10.9;
Dosat = 9.1;
Kd = 0.3;
Kr = 0.41;
Do = 7.6;
V=0.3;

%Initialisation
t = linspace(0,dt*n,n);
Deficit=zeros(1,n); %D : Deficit en Oxyg�ne
DOsat=zeros(1,n); %DOSat : Saturation du Dioxyg�ne
BOD=zeros(1,n); %BOD Demande Biochimique en Oxyg�ne
DO=zeros(1,n); %Demande en Oxyg�ne

for i=1:n
   Deficit(i)=D(t(i));
   DOsat(i)=Dosat;
   BOD(i)= Lo*exp(-Kd*t(i));
end    

DO = -Deficit + DOsat; %Construction de DO


%Calcul de tmax
A =( -Kd^2 *Lo )/(Kr-Kd);

B = (Kd*Lo*Kr)/(Kr-Kd);

C = Do*Kr;

tmax = log((C-B)/A) / (Kr - Kd);
xmax = tmax*V*3600*24;
Deficit_tmax=D(tmax);

%Trac� de Figure%
figure(1).Name = "Demande Biochimique en Oxyg�ne dans un cours d'eau";
plot(t,Deficit,t,DOsat,t,DO,t,BOD)
hold on
grid on
title('Demande Biochimique en Oxyg�ne')
xlabel('t en jours')
ylabel('en mg/L')
legend('D','DOSat','DO','BOD')
hold off;


%% Exercice 2 : Ecosyst�me Dynamique Goemons-Patelles

%On utilise les variables globales afin qu'elles soient prises en compte
%dans les fonctions
global k1 k2 k3 k4 k5 beta
    k1 = 1.1;
    k2 = 1e-5;
    k3 = 1e-3;
    k4 = 0.9;
    k5 = 1e-4;
    beta = 0.02;
    
%Donn�es Num�riques
t_fin = 50;


%Conditions Initales
Goemonts_0 = [1000, 5000, 30000, 10000];
Patelles_0 = [100, 500, 3000, 10000];


%Initialisation Figures

figure(2).Name = "Evolutions des Proies et des Pr�dateurs au cours du Temps";

%Goemonts - Temps
subplot(2,1,1);
grid on
ylabel('Goemonts')
xlabel('Temps (s)')
%Patelles - Temps
subplot(2,1,2);
grid on
ylabel('Patelles')
xlabel('Temps (s)')

colors = ['r' , 'g', 'b', 'm'];
marker = ['x', 'o', '+' ,'d'];


figure(3).Name = "Point d'inflexion";
grid on
xlabel('Goemonts')
ylabel('Patelles')


for i=1:length(Goemonts_0)
    % On envoit � chaque fois les conditions initiales
    [temps, solution] = solveur(Patelles_0(i), Goemonts_0(i), t_fin); 
    
    
    hold(subplot(2,1,1), 'on')
    plot(temps, solution(:,1),colors(i)) %Y(1) d�finit les Goemonts
    hold(subplot(2,1,1), 'off')
    
    hold(subplot(2,1,2), 'on')
    plot(temps, solution(:,2),colors(i), 'Parent', ax2) %Y(2) d�finit les Patelles
    hold(subplot(2,1,2), 'off')
    
    
     hold(figure(3), 'on')
     plot(solution(:,2), solution(:,1), '-', 'Parent', ax3, 'DisplayName',num2str(G0));
     plot(Patelles_0(i), Goemonts_0(i), 'r', 'marker', marker(i), 'markerfacecolor', 'none')
     hold(figure(3), 'off')
end


%% Fonctions 

function [out]=D(t)
%Fonction pour Exercice 1 qui permet de d�finir le D�ficit en Oxyg�ne
global Lo Kd Kr Do %definies comme globales
%Input : temps courant
%Output : scalaire valeur de D au temps courant

out=(Kd*Lo)*(exp(-t*Kd)-exp(-Kr*t))/(Kr-Kd) + (Do)*exp(-Kr*t);
end

function [temps, solution] = solveur(Patelles_0, Goemonts_0, t_fin)

[temps,solution] = ode45(@(temps,Y)systeme(temps,Y), [0, t_fin], [Goemonts_0, Patelles_0]);
end


function out = systeme(temps, Y)
global k1 k2 k3 k4 k5 beta
    out = zeros(2,1);%initialisation d'un vecteur dimensions 2*1
    out(1) = Y(1) * (k1 - k2*Y(1) - k3*Y(2));
    out(2) = Y(2) * (beta*k3*Y(1) - k4 - k5*Y(2));
end



