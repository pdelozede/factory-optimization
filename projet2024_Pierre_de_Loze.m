clear
%lecture des données 
[nbProduits, nbClients, capaProd, capaCrossdock, demande, a, b, penalite, coutStockUsine, coutCamionUsine, coutCamionClient] = lireFichier('instance1.dat');

%exemple d'appel à la résolution du modèle
[solution, fval] = optimProd(2,nbProduits, nbClients, capaProd, capaCrossdock, demande, a, b, penalite, coutStockUsine, coutCamionUsine, coutCamionClient);
%%
[MM,result] = plotOptim(nbProduits, nbClients, capaProd, capaCrossdock, demande, a, b, penalite, coutStockUsine, coutCamionUsine, coutCamionClient);
plot(MM,result)
title('Résultat=f(CapaCrossdock)');
xlabel('CapaCrossdock');
ylabel('Résultat');
%%
%%%% PROGRAMMATION DES MODELES (à compléter)%%%%%%%%%%%%%%%
function [solution, fval] = optimProd(modele, nbProduits, nbClients, capaProd, capaCrossdock, demande, a, b, penalite, coutStockUsine, coutCamionUsine, coutCamionClient)

 
      
        

 
    if modele==1
        %TODO : compléter avec le code du PL
            D1=max(b);  %Dernier jour de délai de livraison toléré.
            N=[];
            for i=1:nbProduits
    
                N(end+1)= floor(sum(demande(i,:))/capaProd(i))+1;
            end
            J=0;
            D2=max(N);   %Nombre de jour minimal satisfaisant l'intégralité de la production demandée.
            for i=1:nbProduits
                for j=1:nbClients
                    J=J+demande(i,j);
                end
            end
            D3=floor(J/capaCrossdock)+1;      %Nombre minimal de jour nécessaire pour envoyer tout les produits aux clients.

            T=max([D1,D2,D3]);
            
            model1=optimproblem('ObjectiveSense','minimize');
            ns=optimvar('ns',nbProduits,T,'LowerBound',0);   %produits stockés 
            np=optimvar('np',nbProduits,T,'LowerBound',0);   %produits fabriqués
            nr=optimvar('nr',nbProduits,T,nbClients,'LowerBound',0);   %produits reçus par client chaque jour
            p = optimvar('p',nbClients,1, 'LowerBound', 0); % Expression d optimisation pour p  ensemble des produits reçu hors délai
           
            model1.Objective=sum(coutStockUsine*ns)+penalite*p;
            for l=1:nbClients
                 % Calcul des intervalles en fonction des clients
                d1 = [1:a(l), b(l):T];
                d1 = d1(d1 >= 0 & d1 <= T); % Filtrer les indices valides
                t1=linspace((a(l)-1),0,a(l));
                t2=linspace(0,T-b(l),T-b(l)+1);
                t=[t1 t2];   %permet d'avoir un vecteur qui calcule les jours d'avance/de retard
                % Sinon, p(l) est défini comme la somme sur nr(:, d1, l)
                model1.Constraints.(['pConstraint_' num2str(l)]) = p(l) == sum(sum(nr(:, d1, l) * t',2)); %(['pConstraint_' num2str(l)]) permet de donner un nom différent à chaque contrainte générée            
            end
            
            
            stock=optimconstr(nbProduits,T);
            transit=optimconstr(nbProduits,T);
            prod=optimconstr(nbProduits,T);
            
            
            %pour le premier jour
            
            stock(:,1)=np(:,1)-sum(reshape(nr(:,1,:),[nbProduits,nbClients]),2)==ns(:,1);
            transit(:,1)=sum(sum(reshape(nr(:,1,:),[nbProduits,nbClients]),2))<=capaCrossdock;
            prod(:,1)=np(:,1)<=capaProd';

            %Pour les jours >=2
            
            for k=2:T
                stock(:,k)=ns(:,k)==ns(:,k-1)+np(:,k)-sum(reshape(nr(:,k,:),[nbProduits,nbClients]),2);
                transit(:,k)=sum(sum(reshape(nr(:,k,:),[nbProduits,nbClients]),2))<=capaCrossdock;
                prod(:,k)=np(:,k)<=capaProd';  
            end
            
            model1.Constraints.stock=stock;
            model1.Constraints.transit=transit;
            model1.Constraints.prod=prod;
            
            
            
            %contrainte pour s'assurer du nombre de produit livré en fin
            %de période T.
            demanded=optimconstr(nbProduits,nbClients);
            for m=1:nbProduits
                for n=1:nbClients
                    demanded(m,n)=sum(nr(m,:,n))==demande(m,n);
                end
            end    
            model1.Constraints.demande=demanded;
            
            %Initialisation
            X0.ns = zeros(nbProduits, T);
            X0.ne = zeros(nbProduits, T);
            X0.np = zeros(nbProduits, T);
            X0.nr = zeros(nbProduits, T, nbClients);
            X0.p = zeros(nbClients, 1);
            tic
            [solution,fval,flag,output]=solve(model1,X0)
            toc
       
    elseif modele==2
            %TODO : compléter avec le code de IP1
            D1=max(b);               
            N=[];
            for i=1:nbProduits
    
                N(end+1)= floor(sum(demande(i,:))/capaProd(i))+1;
            end
            J=0;
            D2=max(N);           
            for i=1:nbProduits
                for j=1:nbClients
                    J=J+demande(i,j);
                end
            end
            D3=floor(J/capaCrossdock)+1;

            T=max([D1,D2,D3])
    
            M=1000; %Suffisamment grand pour les donées du problème (demande max client, capaCrossDock, CapaProd < M)
                    %mais suffisamment petit pour limiter les temps de
                    %calculs
            
            model2=optimproblem('ObjectiveSense','minimize');
            ns=optimvar('ns',nbProduits,T,'LowerBound',0);   %produits stockés
            np=optimvar('np',nbProduits,T,'LowerBound',0);   %produits fabriqués
            nr=optimvar('nr',nbProduits,T,nbClients,'LowerBound',0);   %produits reçus par client chaque jour
            p = optimvar('p',nbClients,1, 'LowerBound', 0); % Expression d optimisation pour p  ensemble des produits reçu hors délai
            cu=optimvar('cu',nbProduits,T,'Type','integer','LowerBound',0,'UpperBound',1);   %camions usine -> entrepôt
            cc=optimvar('cc',nbClients,T,'LowerBound',0,'UpperBound',1,'Type','integer');   %camions entrepôt -> clients

            
            
            model2.Objective=sum(coutStockUsine*ns)+penalite*p+coutCamionUsine*sum(cu,2)+coutCamionClient*sum(cc,2);
            
            
            for l=1:nbClients
                 % Calcul des intervalles en fonction des clients
                d1 = [1:a(l), b(l):T];
                d1 = d1(d1 >= 0 & d1 <= T); % Filtrer les indices valides
                t1=linspace((a(l)-1),0,a(l));
                t2=linspace(0,T-b(l),T-b(l)+1);
                t=[t1 t2];   %permet d'avoir un vecteur qui calcule les jours d'avance/de retard
                % Sinon, p(l) est défini comme la somme sur nr(:, d1, l)
                model2.Constraints.(['pConstraint_' num2str(l)]) = p(l) == sum(sum(nr(:, d1, l) * t',2)); %(['pConstraint_' num2str(l)]) permet de donner un nom différent à chaque contrainte générée            
            end
            
            stock=optimconstr(nbProduits,T);
            transit=optimconstr(nbProduits,T);
            prod=optimconstr(nbProduits,T);
            exportu=optimconstr(nbProduits,T);    
            exportc=optimconstr(nbClients,T);
            
            %pour le premier jour
            stock(:,1)=np(:,1)-sum(reshape(nr(:,1,:),[nbProduits,nbClients]),2)==ns(:,1);
            transit(:,1)=sum(sum(reshape(nr(:,1,:),[nbProduits,nbClients]),2))<=capaCrossdock;
            prod(:,1)=np(:,1)<=capaProd';
                
            %pour le transport usine -> entrepôt        
            for i=1:nbProduits
                exportu(i,1)=sum(nr(i,1,:))<=M*cu(i,1); %Si les clients ont une demande non-nulle d'un produit i, on envoie un camion de l'usine i
            end
            
            
            %pour le transport entrepôt -> clients
            for j=1:nbClients
                exportc(j,1)=sum(nr(:,1,j))<=M*cc(j,1)'; %Si la demande d'un client est non-nulles, on lui envoie un camion
            end    
            
            
            %Pour les jours >=2
            for k=2:T
                stock(:,k)=ns(:,k)==ns(:,k-1)+np(:,k)-sum(reshape(nr(:,k,:),[nbProduits,nbClients]),2);
                transit(:,k)=sum(sum(reshape(nr(:,k,:),[nbProduits,nbClients]),2))<=capaCrossdock;
                prod(:,k)=np(:,k)<=capaProd';
                %pour le transport usine -> entrepôt 
                for i=1:nbProduits
                    exportu(i,k)=sum(nr(i,k,:))<=M*cu(i,k);
                    %Si les clients ont une demande non-nulle d'un produit i, on envoie un camion de l'usine i
                end
                %pour le transport entrepôt -> clients
                for j=1:nbClients
                    exportc(j,k)=sum(nr(:,k,j))<=M*cc(j,k)'; 
                    %Si la demande d'un client est non-nulles, on lui envoie un camion
                end 
            end
            
            
            model2.Constraints.stock=stock;
            model2.Constraints.transit=transit;
            model2.Constraints.prod=prod;
            model2.Constraints.exportu=exportu;
            model2.Constraints.exportc=exportc;
            
            %contraintes permettant d'atteindre la quantité demandée par les
            %clients
            demanded=optimconstr(nbProduits,nbClients);
            for m=1:nbProduits
                for n=1:nbClients
                    demanded(m,n)=sum(nr(m,:,n))==demande(m,n);
                end
            end    
            model2.Constraints.demande=demanded;
            
            %Initialisation
            X0.ns = zeros(nbProduits, T);
            X0.np = zeros(nbProduits, T);
            X0.nr = zeros(nbProduits, T, nbClients);
            X0.p = zeros(nbClients, 1);
            X0.cu=zeros(nbProduits,T);
            X0.cc=zeros(nbClients,T);
            tic
            [solution,fval,flag,output]=solve(model2,X0,'Solver','intlinprog')
            toc
    elseif modele==3 
         %TODO : compléter avec le code de IP2
        D1=max(b);  
            N=[];
            for i=1:nbProduits
    
                N(end+1)= floor(sum(demande(i,:))/capaProd(i))+1;
            end
            J=0;
            D2=max(N);
            for i=1:nbProduits
                for j=1:nbClients
                    J=J+demande(i,j);
                end
            end
            D3=floor(J/capaCrossdock)+1;

            T=max([D1,D2,D3])
    
            M=1000;
            
            model3=optimproblem('ObjectiveSense','minimize');
            ns=optimvar('ns',nbProduits,T,'LowerBound',0);   %produits stockés
            np=optimvar('np',nbProduits,T,'LowerBound',0);   %produits fabriqués
            nr=optimvar('nr',nbProduits,T,nbClients,'LowerBound',0);   %produits reçus par client chaque jour
            p = optimvar('p',nbClients,1, 'LowerBound', 0); % Expression d optimisation pour p  ensemble des produits reçu hors délai
            cu=optimvar('cu',nbProduits,T,'Type','integer','LowerBound',0,'UpperBound',1);
            cc=optimvar('cc',nbClients,T,'LowerBound',0,'UpperBound',1,'Type','integer');

            
            
            model3.Objective=sum(coutStockUsine*ns)+penalite*p+coutCamionUsine*sum(cu,2)+coutCamionClient*sum(cc,2);
            
            
            for l=1:nbClients
                % Calcul des intervalles en fonction des clients
                d1 = [1:a(l), b(l):T];
                d1 = d1(d1 >= 0 & d1 <= T); % Filtrer les indices valides
                t1=linspace((a(l)-1),0,a(l));
                t2=linspace(0,T-b(l),T-b(l)+1);
                t=[t1 t2];   %permet d'avoir un vecteur qui calcule les jours d'avance/de retard
                % Sinon, p(l) est défini comme la somme sur nr(:, d1, l)
                model3.Constraints.(['pConstraint_' num2str(l)]) = p(l) == sum(sum(nr(:, d1, l) * t',2)); %(['pConstraint_' num2str(l)]) permet de donner un nom différent à chaque contrainte générée            
            end
            
            stock=optimconstr(nbProduits,T);
            transit=optimconstr(nbProduits,T);
            prod=optimconstr(nbProduits,T);
            exportu=optimconstr(nbProduits,T,nbClients);   
            exportc=optimconstr(nbClients,T,nbClients);
            
            %pour le premier jour
            stock(:,1)=np(:,1)-sum(reshape(nr(:,1,:),[nbProduits,nbClients]),2)==ns(:,1);
            transit(:,1)=sum(sum(reshape(nr(:,1,:),[nbProduits,nbClients]),2))<=capaCrossdock;
            prod(:,1)=np(:,1)<=capaProd';
                
            %pour le transport usine -> entrepôt        
            for m=1:nbProduits
                for n=1:nbClients
                    exportu(m,1,n)=nr(m,1,n)<=M*cu(m,1); 
                    %on regarde individuellement chaque client si il a besoin d'un produit i. Si oui, on fait partir un camion de l'usine i.
                end
            end    
            
            %pour le transport entrepôt -> clients
            for j=1:nbClients   
                for l=1:nbProduits
                    exportc(j,1,l)=nr(l,1,j)<=M*cc(j,1);
                    %On regarde si chaque client doit recevoir un produit
                end
            end    
            
            %Pour les jours >=2
            for k=2:T
                stock(:,k)=ns(:,k)==ns(:,k-1)+np(:,k)-sum(reshape(nr(:,k,:),[nbProduits,nbClients]),2);
                transit(:,k)=sum(sum(reshape(nr(:,k,:),[nbProduits,nbClients]),2))<=capaCrossdock;
                prod(:,k)=np(:,k)<=capaProd';
                %transport usine -> entrepôt
                for m=1:nbProduits
                    for n=1:nbClients
                        exportu(m,k,n)=nr(m,k,n)<=M*cu(m,k); 
                        %on regarde individuellement chaque client si il a besoin d'un produit i. Si oui, on fait partir un camion de l'usine i.
                    end
                end
                %transport entrepôt -> clients 
                for j=1:nbClients
                    for l=1:nbProduits
                        exportc(j,k,l)=nr(l,k,j)<=M*cc(j,k);
                    end
                end 
            end
            
            
            model3.Constraints.stock=stock;
            model3.Constraints.transit=transit;
            model3.Constraints.prod=prod;
            model3.Constraints.exportu=exportu;
            model3.Constraints.exportc=exportc;

            %contrainte permattant d'atteindre la quantité commandée par
            %les clients
            demanded=optimconstr(nbProduits,nbClients);
            for m=1:nbProduits
                for n=1:nbClients
                    demanded(m,n)=sum(nr(m,:,n))==demande(m,n);
                end
            end    
            model3.Constraints.demande=demanded;
            
            %Initialisation
            X0.ns = zeros(nbProduits, T);
            X0.np = zeros(nbProduits, T);
            X0.nr = zeros(nbProduits, T, nbClients);
            X0.p = zeros(nbClients, 1);
            X0.cu=zeros(nbProduits,T);
            X0.cc=zeros(nbClients,T);
            tic
            [solution,fval,flag,output]=solve(model3,X0,'Solver','intlinprog')
            toc 

    else 
        fprintf("Le paramètre modele devrait valoir 1, 2 ou, 3 \n ")
    end
 
end


%%% A compléter
function [MM,result]= plotOptim(nbProduits, nbClients, capaProd, capaCrossdock, demande, a, b, penalite, coutStockUsine, coutCamionUsine, coutCamionClient)
    %TODO : à compléter
    L=50;
    MM=linspace(100,300,L);
    result=zeros(L,1);
    for i=1:length(MM)
       [~, result(i)] = optimProd(1, nbProduits, nbClients, capaProd, MM(i), demande, a, b, penalite, coutStockUsine, coutCamionUsine, coutCamionClient) ;
    end
end

%%%%%%%FONCTION DE PARSAGE (ne pas modifier)%%%%%%%%
function [nbProduits, nbClients, capaProd, capaCrossdock, demande, a, b, penalite, coutStockUsine, coutCamionUsine, coutCamionClient]=lireFichier(filename)
% lecture du fichier de données
instanceParameters = fileread(filename);
% suppression des éventuels commentaires
instanceParameters = regexprep(instanceParameters, '/\*.*?\*/', '');
% évaluation des paramètres
eval(instanceParameters);
end


