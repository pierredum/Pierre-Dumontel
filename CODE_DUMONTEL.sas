/* Tout le programme a ete realise avec SAS STUDIO, puis tester avec SAS ENTERPRISE GUIDE pour 
verifier si tout concorder entre les 2. Dans SAS STUDIO, l operation libname n est pas necessaire, 
elle peut l'etre autre part. les chemins renseignes dans l etape infile  sont a changer en fonction de
qui utilisent le code. */

libname 

/* Quelques macro variables simplifiants les taches repetitives */
/* Pour le chemin des fichiers */

%let account = PROJET.ACCOUNT;
%let card = PROJET.CARD;
%let client = PROJET.CLIENT;
%let disp = PROJET.DISP;
%let district = PROJET.DISTRICT;
%let loan = PROJET.LOAN;
%let order = PROJET.ORDER; 
%let trans = PROJET.trans; 

%let nbre = Nombre de clients;
%let order = PROJET.order;
%let emprunt = Nombre d emprunt catégorie ;

/*****************************************************************************************************************************************/
/************************************************** PREMIERE PARTIE **********************************************************************/
/*****************************************************************************************************************************************/

/*****************************************************************************************************************************************/
/******************************************************* QUESTION 1 **********************************************************************/
/*****************************************************************************************************************************************/

/* Commentaires sur la question : comme l'enonce l'indique, il s'agit pour cette question d'utiliser les options infile et input d'une DATA STEP,
en tenant compte du format des variables, notamment pour les dates et les variables numeriques pour lesquelles 
des operations seront realises dans la suite. En ce qui concerne le traitement de la table CLIENT, pour creer la table sexe et la table birth_corr,
l'option SUBSTR a ete utilise pour extraire les informations necessaires a la construction de ses tables, en utilisant parfois des variables
ephemeres. Pour ensuite les recomposer et creer les variables finales. De plus afin de calculer l'age des clients en 2010, une variable 
year_2010_bis a ete ajoute a la table*/

/* Account */ 

DATA &account; 
	infile"/home/u49899053/PROJET_MACRO/account.txt"
		dlm =";" dsd firstobs=2;
	input account_id :$6. district_id :$4. frequency :$25. date yymmdd6.;
	format date YYMMDD10.;
	options yearcutoff=1900;
	run; 
	
/* Card */ 

data &card; 
	infile"/home/u49899053/PROJET_MACRO/card.txt"
		dlm =";" dsd firstobs=2;
	length card_id disp_id type issued $ 25;
	input card_id disp_id type issued; 
run; 
	
OPTION YEARCUTOFF =1900;
DATA &card;
  set &card;
  issued_corr = input(issued, yymmdd6.);
  format issued_corr yymmdd10. ;
RUN; 

/* Client */ 
data &client; 
	infile"/home/u49899053/PROJET_MACRO/client.txt"
		dlm =";" dsd firstobs=2;
	length client_id $ 25 birth_number $ 25 
		district_id $20;
	input client_id birth_number district_id; 
	run; 

OPTION YEARCUTOFF =1900;
DATA &client;
	set &client; 
 	var = substr(birth_number, 3,6);
	var2= substr(var, 1,2); 
	attrib sexe label="Sexe";
	IF var2 >12 THEN sexe ="F";
	ELSE sexe ="M";
RUN; 
DATA &client;
	set &client (keep=client_id birth_number district_id sexe);
	  format an $4.;
	  format jour $2.;
	  format mois $2.; 
	  format mois_for_date $2.;
	  format date_new ddmmyy10. ; 
	  format birth_corr yymmdd10.;
	  jour = substr(birth_number,5,4) ;
	  mois = substr(birth_number,3) ;
	  an = substr(birth_number,1,2) ;  
	  IF mois>12 THEN mois_for_date = mois-50;
	  ELSE mois_for_date = mois;
	  date_new = mdy(mois_for_date,jour,an); 
	  birth_corr = date_new;
	  year_2010 = year(birth_corr);
	  age_2010 = 2010-year_2010;
RUN; 
DATA &client;
	set &client (keep=client_id birth_number district_id sexe birth_corr age_2010);
RUN; 

/* Disp */ 

data &disp; 
	infile"/home/u49899053/PROJET_MACRO/disp.txt"
		dlm =";" dsd firstobs=2;
	length disp_id $20 client_id $20 account_id $20 type $20 ;
	input disp_id client_id account_id type; 
run; 

/* District */ 

data &district; 
	infile"/home/u49899053/PROJET_MACRO/district.txt"
		dlm =";" dsd firstobs=2;
	length A1 $20 A2 $25 A3 $25;
	input A1 A2 A3 A4 A5 A6 A7 A8 A9 A10 A11 A12 A13 A14 A15 A16; 
run; 
DATA &district;
	set &district(rename=(A1=DISTRICT_ID A2=DISTRICT_NAME A3 = region));
RUN; 


/* Loan */ 

data &loan; 
	infile"/home/u49899053/PROJET_MACRO/loan.txt"
		dlm =";" dsd firstobs=2;
	input loan_id :$20. account_id :$20.  date : yymmdd6. amount :16. duration :8.   payments :$4. status :$20.  ; 
	format date yymmdd10. amount DOLLARS16.;
	options yearcutoff=1900;
run; 

/* order */

data &order; 
	infile"/home/u49899053/PROJET_MACRO/order.txt"
		dlm =";" dsd firstobs=2;
	input order_id :$20. account_id :$20.  bank_to :$20. account_to amount k_symbol :$20.; 
	options yearcutoff=1900;
run; 

/* trans */ 
data &trans; 
	infile"/home/u49899053/PROJET_MACRO/trans.txt"
		dlm =";" dsd firstobs=2;
	input trans_id :$20. account_id :$20. date : yymmdd6. type :$20. operation :$20. amount :$10. balance k_symbol bank account; 
	format date yymmdd10.;
run; 

/*****************************************************************************************************************************************/
/******************************************************* QUESTION 3 **********************************************************************/
/*****************************************************************************************************************************************/
PROC SQL; 
	SELECT district_id, sexe, COUNT(DISTINCT client_id) AS nb1 label="&nbre."
	FROM &client
	GROUP BY district_id, sexe 
	ORDER BY district_id
	;
QUIT; 

/*****************************************************************************************************************************************/
/******************************************************* QUESTION 4 **********************************************************************/
/*****************************************************************************************************************************************/

PROC SQL; 
	SELECT DISTINCT A.district_id, DISTRICT_NAME, region, sexe, COUNT(DISTINCT client_id) AS nb1 label="&nbre."
	FROM &client A , &district B
	WHERE client.district_id = district.district_id
	GROUP BY A.district_id, sexe 
	ORDER BY A.district_id
	;
QUIT; 

/*****************************************************************************************************************************************/
/******************************************************* QUESTION 5 **********************************************************************/
/*****************************************************************************************************************************************/

PROC SQL; 
	SELECT DISTINCT district.district_id,DISTRICT_NAME, region, COUNT(DISTINCT client_id) AS nbc label="&nbre.",
	COUNT(DISTINCT case when (sexe="M") then client_id end ) as nbm label ="&nbre. hommes",
	COUNT(DISTINCT case when (sexe="F") then client_id end ) as nbf label ="&nbre. femmes"
	FROM &district, &client
	WHERE client.district_id = district.district_id 
	GROUP BY district.district_id
	HAVING nbc >100
	;
QUIT; 
/*****************************************************************************************************************************************/
/******************************************************* QUESTION 6 **********************************************************************/
/*****************************************************************************************************************************************/

PROC SQL; 	
	SELECT age_2010, 
	COUNT(DISTINCT A.client_id) as nb6 label ="Nombres de clients",
	COUNT( B.order_id) as nb6or label = "Nombres d'ordres"
	FROM &client A , &order B, &disp C 
	WHERE client.client_id = disp.client_id and disp.account_id = order.account_id
	GROUP BY age_2010
	ORDER BY age_2010 asc
	;
QUIT;
/*****************************************************************************************************************************************/
/******************************************************* QUESTION 7 **********************************************************************/
/*****************************************************************************************************************************************/

/* Afin d avoir la sortie la plus approprie, il faut specifier la ou il y a besoin le format = DOLLAR16. */
PROC SQL; 
	SELECT A.type, 
	Count(DISTINCT B.loan_id) as nb_compte label ="Nombre de comptes avec un emprunt", 
	MIN(B.amount) format = DOLLAR16. AS min_montant label = "Montant minimum des emprunts" ,
	ROUND(AVG(B.amount)) format = DOLLAR16. AS avg_montant label = "Montant moyen des emprunts",
	MAX(B.amount) format = DOLLAR16. AS max_montant label = "Montant maximum des emprunts",
	MIN(B.duration) AS min_duration label = "durée minimum", 
	ROUND(AVG(B.duration)) AS avg_duration label = "Durée moyenne",
	MAX(B.duration) AS max_duration label = "durée maximum",
	COUNT(DISTINCT case when (status="A") then B.loan_id end ) as loan_A label ="&emprunt A ",
	COUNT(DISTINCT case when (status="B") then B.loan_id end ) as loan_B label ="&emprunt B ",
	COUNT(DISTINCT case when (status="C") then B.loan_id end ) as loan_A label ="&emprunt C ",
	COUNT(DISTINCT case when (status="D") then B.loan_id end ) as loan_A label ="&emprunt D "
	FROM &card A, &loan B , &account C , &disp D
	WHERE loan.account_id = account.account_id = disp.account_id and card.disp_id = disp.disp_id 
	GROUP BY A.type
	;
QUIT; 

/*****************************************************************************************************************************************/
/******************************************************* QUESTION 8 **********************************************************************/
/*****************************************************************************************************************************************/

PROC SQL; 
	SELECT B.status, A.type, 
	Count(DISTINCT B.loan_id) as nb_compte label ="Nombre de comptes avec un emprunt", 
	ROUND(AVG(B.amount)) format = DOLLAR16. AS avg_montant label = "Montant moyen des emprunts",
	MIN(B.amount) format = DOLLAR16. AS min_montant label = "Montant minimum des emprunts" ,
	MAX(B.amount) format = DOLLAR16. AS max_montant label = "Montant maximum des emprunts",
	VAR(B.amount) AS variance_montant label="Variance des montants", 
	STD(B.amount) AS std_montant label = "Ecart moyen des montants",
	ROUND(AVG(B.duration)) AS avg_duration label = "Durée moyenne",
	MIN(B.duration) AS min_duration label = "durée minimum", 
	MAX(B.duration) AS max_duration label = "durée maximum",
	VAR(B.duration) AS variance_duration label="Variance des durées", 
	STD(B.duration) AS std_duration label = "Ecart moyen des durées"
	FROM &card A, &loan B , &account C , &disp D
	WHERE loan.account_id = account.account_id = disp.account_id and card.disp_id = disp.disp_id 
	GROUP BY B.status, A.type
	;
QUIT; 

/*****************************************************************************************************************************************/
/******************************************************* QUESTION 9 **********************************************************************/
/*****************************************************************************************************************************************/

/* Pour garder toutes les lignes de la table client, on effectue un premier left join de client sur une 
des deux autres tables, puis un second left join de la nouvelle table cree sur la troisieme table a fusionner. 
Enfin, afin d eviter de dupliquer des variables dans la nouvelle table client_macro, on specifie 
toutes les variables ajoutees dans la nouvelle table. */ 

%let first_join = projet.first_join; 
PROC SQL;
	CREATE TABLE &first_join AS
		SELECT A.client_id, A.age_2010,
		A.birth_number, A.district_id, A.birth_corr, A.sexe,
		B.disp_id, b.account_id, b.type
		FROM &client A LEFT JOIN &disp B 
		on disp.client_id = client.client_id; 
;
	CREATE TABLE projet.client_macro AS
		SELECT A.client_id, A.age_2010, A.birth_number, A.district_id, A.birth_corr, A.sexe,
		A.disp_id, A.account_id, A.type AS disp_type label = "Type dist",
		B.card_id, B.type AS card_type label = "Type card", B.issued, B.issued_corr
		FROM &first_join A LEFT JOIN &card B 
		on first_join.disp_id = card.disp_id; 
QUIT;

/*****************************************************************************************************************************************/
/******************************************************* DEUXIEME PARTIE **********************************************************************/
/*****************************************************************************************************************************************/

/* Il est necessaire de commencer par creer, dans une DATA step, une variable aleatoire grace a la fonction ranuni
et de trier par ordre croissant cette variable. Afin que cette variable soit creee une seule fois */ 

DATA PROJET.client_macro ;
	set projet.client_macro;
	ran = ranuni(0);
RUN; 
PROC SORT DATA= PROJET.client_macro;
by ran; 
RUN; 

/*****************************************************************************************************************************************/
/******************************************************* PARTIE A - QUESTION 1 **********************************************************************/
/*****************************************************************************************************************************************/

/* L'option OBS permet de selectionner un nombre d observations, 
la variable ran etant deja ordonnee. */ 
	
PROC SQL;
	CREATE TABLE PROJET.ASV1 AS
		SELECT *
		FROM projet.client_macro (OBS=200)
		;		
QUIT;
	
/*****************************************************************************************************************************************/
/******************************************************* PARTIE A - QUESTION 2 **********************************************************************/
/*****************************************************************************************************************************************/

/* La table en entree */ 
%let table = PROJET.CLIENT_MACRO;
/* La table en sortie */
%let ASV2 = projet.ASV2; 
/* Le nombre d'observations*/
%let nb_obs = 200;
 
/* Par rapport a la question precedente, cette question permet de decider de la table en entree, 
de la table en sortie et du nombre d observations en dehors de la PROC SQL*/

PROC SQL;
	CREATE TABLE &ASV2 as 
		SELECT *
		FROM &table (OBS =&nb_obs) 
		;
QUIT; 

/*****************************************************************************************************************************************/
/******************************************************* PARTIE A - QUESTION 3 **********************************************************************/
/*****************************************************************************************************************************************/


/* Nouvelle table en sortie */
%let ASV3 = projet.ASV3;
/* Le pourcentage d'observations*/ 
%let pourcentage_obs = 20; 

/*Par rapport a la question precedente, pour selectionner un pourcentage de la table en entree uniquement, 
on utilise la fonction WHERE sur la variable generee par ranuni(0) ou l option between 
permet de selectionner une partie de la table en entree, ici pas exactement 20%, 
mais environ 20%.*/

PROC SQL noprint;
	CREATE TABLE &ASV3 as 
		SELECT *
		FROM &table 
		WHERE ran between 0 and 0.&pourcentage_obs.
		;		
QUIT; 

/*****************************************************************************************************************************************/
/******************************************************* PARTIE A - QUESTION 4 **********************************************************************/
/*****************************************************************************************************************************************/

/* Dans cette question, la macro fonction permet de centraliser les parametres des macro variables */

%let ASV4 = projet.ASV4;
%MACRO AS(open = , quit = , number= );
	PROC SQL;
		CREATE TABLE &quit as 
			SELECT *
			FROM &open
			WHERE ran between 0 and 0.&number.
			;		
	QUIT;  
%MEND;
%AS(open=&table,quit=&ASV4, number=&pourcentage_obs);

/*****************************************************************************************************************************************/
/******************************************************* PARTIE B - QUESTION 1 **********************************************************************/
/*****************************************************************************************************************************************/

/*Dans une PROC SQL la fonction INTO permet de stocker dans une macro variable les informations demandees dans
SELECT. Ici il s'agit de mettre dans une macro variable chaque strate de la variable de stratification, et ceux 
peu importe le nombre de strates qui composent la variable de stratification. Par exemple deux avec sexe, trois avec 
card_type. Dans une autre macro variable, on met le nombre de strates total, qui sera utile pour faire des boucles
et ceux peu importe le nombre de strates.

Dans toute cette partie B, la variable indiquee dans la macro variable ASTR0i (i de 1 a 5) peut etre remplacee par une autre variable de stratification, 
par exemple card_type, disp_type, sexe… 

Dans le rendu du projet, les tables en sortie correspondent a card_type et sexe en tant que variables de stratification. 
Pour Card_type, les tables en sortie sont les tables strate1, strate2 et strate3 generees a la question 2; 
les tables ech1, ech2 et ech3 generees a la question 3 et la table recolle generee a la question 4. 
Pour Sexe les tables en sortie sont les tables strate1 et strate2 generees a la question 2; 
les tables ech1 et ech2 generees a la question 3 et la table recolle generee a la question 4. 

*/

%MACRO ASTR(var_strat);
	PROC SQL noprint; 
		SELECT DISTINCT &var_strat , COUNT(DISTINCT &var_strat)
		INTO :nom_strat1 - , :nb_valeurs
		FROM projet.client_macro
		WHERE &var_strat is not missing; 
	;
	%do i=1 %to &nb_valeurs;
		%put valeur numero &i correspondant à la variable de stratification :  &&nom_strat&i;
	%end;
	%put Le nombre de valeurs prises par la variable de stratification : &nb_valeurs;
	QUIT;
%MEND; 
%ASTR (sexe);
/*****************************************************************************************************************************************/
/******************************************************* PARTIE B - QUESTION 2 **********************************************************************/
/*****************************************************************************************************************************************/

/* Dans cette question on veut creer des tables selon les strates. Pour cela on integre dans la boucle do
 une PROC SQL CREATE TABLE, avec les indications (option WHERE) permettant de conserver dans chaque 
 table les observations concernées par le nom de la strate uniquement */

%MACRO ASTRV02(var_strat);
	PROC SQL noprint;  
		SELECT DISTINCT &var_strat , COUNT(DISTINCT &var_strat)
		INTO :nom_strat1 - , :nb_valeurs
		FROM &table
		WHERE &var_strat is not missing; 
	QUIT;

		;
		%do i=1 %to &nb_valeurs;
			%put La valeur numero &i correspondant à la variable de stratification :  &&nom_strat&i;
		
			PROC SQL;
				CREATE TABLE PROJET.strate&i AS
					SELECT *
					FROM &table
					WHERE &var_strat = "&&nom_strat&i" ;
			QUIT;
		%end;
	 
	 	%put Le nombre de valeurs prises par la variable de stratification : &nb_valeurs;
%MEND; 
%ASTRV02 (sexe);

/*****************************************************************************************************************************************/
/******************************************************* PARTIE B - QUESTION 3 **********************************************************************/
/*****************************************************************************************************************************************/

/* Toujours dans la boucle do, afin de repeter l'operation pour chaque strate et ceux peu importe 
le nombre de strates. On utilise a nouveau la variable ran cree dans la partie A pour selectionner un echantillon
Puis dans une nouvelle PROC SQL on cree des echantillons a partir de ran, en conservant ici environ 20% (option WHERE BETWEEN 
donne environ 20% des observations).*/

%MACRO ASTRV03(var_strat, pourcentage_ech);
	PROC SQL noprint;  
		SELECT DISTINCT &var_strat , COUNT(DISTINCT &var_strat)
		INTO :nom_strat1 - , :nb_valeurs
		FROM &table
		WHERE &var_strat is not missing; 
	QUIT;

		;
		%do i=1 %to &nb_valeurs;
			%put La valeur numero &i correspondant à la variable de stratification : &&nom_strat&i;
		
			PROC SQL;
				CREATE TABLE PROJET.strate&i AS
					SELECT * 
					FROM &table
					WHERE &var_strat = "&&nom_strat&i" 
					ORDER BY ran;
			QUIT;
		
			PROC SQL ;
				CREATE TABLE projet.ech&i AS
					SELECT *
					FROM projet.strate&i 
					WHERE ran Between 0 and 0.&pourcentage_ech.
					;
			QUIT;
		
		%end;
	 
	 	%put Le nombre de valeurs prises par la variable de stratification : &nb_valeurs;
%MEND; 

%ASTRV03 (sexe, 20);

/*****************************************************************************************************************************************/
/******************************************************* PARTIE B - QUESTION 4 **********************************************************************/
/*****************************************************************************************************************************************/
/* On rajoute ici les lignes de code necessaires pour assembler les 3 echantillons crees a la question
precedente. Pour cela on utilise une DATA step, avec dans la fonction set, une boucle do permettant
d utiliser tout les echantillons crees quelque soit le nombre de strates, sachant que toutes les tables 
de sous echantillon ont les memes colonnes. */


%MACRO ASTRV04(var_strat, pourcentage_ech);
	PROC SQL noprint;  
		SELECT DISTINCT &var_strat , COUNT(DISTINCT &var_strat)
		INTO :nom_strat1 - , :nb_valeurs
		FROM &table
		WHERE &var_strat is not missing; 
	QUIT;

		;
		%do i=1 %to &nb_valeurs;
			%put La valeur numero &i correspondant à la variable de stratification :  &&nom_strat&i;
		
			PROC SQL;
				CREATE TABLE PROJET.strate&i AS
					SELECT *
					FROM &table
					WHERE &var_strat = "&&nom_strat&i" 
					ORDER BY ran ;
			QUIT;
		
			PROC SQL ;
				CREATE TABLE projet.ech&i AS
					SELECT *
					FROM projet.strate&i 
					WHERE ran Between 0 and 0.&pourcentage_ech.
					;
			QUIT;
		
		%end;
		
		DATA projet.recolle ;
			SET %do i=1 %to &nb_valeurs;
				projet.ech&i
				%end ;
			;
		RUN;
	 
	 	%put Le nombre de valeurs prises par la variable de stratification : &nb_valeurs;
%MEND; 

%ASTRV04 (sexe,20);

/*****************************************************************************************************************************************/
/******************************************************* PARTIE B - QUESTION 5 **********************************************************************/
/*****************************************************************************************************************************************/

/* La macro variable DATATYP permet d indiquer le type de variable de la variable de stratification*/ 

%MACRO ASTRV05(var_strat, pourcentage_ech);
	PROC SQL noprint;  
		SELECT DISTINCT &var_strat , COUNT(DISTINCT &var_strat)
		INTO :nom_strat1 - , :nb_valeurs
		FROM &table
		WHERE &var_strat is not missing; 
	QUIT;

		;
		%do i=1 %to &nb_valeurs;
			%put valeur numero &i correspondant à la variable de stratification :  &&nom_strat&i;
		
				PROC SQL;
					CREATE TABLE PROJET.strate&i AS
					SELECT * 
					FROM &table
					WHERE &var_strat = "&&nom_strat&i"
					ORDER BY ran ;
				QUIT;
		
				PROC SQL ;
					CREATE TABLE projet.ech&i AS
					SELECT *
					FROM projet.strate&i 
					WHERE ran Between 0 and 0.&pourcentage_ech.
					;
				QUIT;
		
		%end;
		
		DATA projet.recolle ;
			SET %do i=1 %to &nb_valeurs;
				projet.ech&i
				%end ;
			;
		RUN;
	 
	 	%put Le nombre de valeurs prises par la variable de stratification : &nb_valeurs;
	 	%let type = %datatyp(&var_strat);
	 	%put Le type de la variable de stratification : &type;
%MEND; 

%ASTRV05 (sexe, 20);

/*****************************************************************************************************************************************/
/******************************************************* PARTIE B - QUESTION 6 **********************************************************************/
/*****************************************************************************************************************************************/

/* La fonction ranuni a permis de generer un nombre unique pour chaque observation, en utilisant 
la fonction COUNT d'une PROC SQL on peut tout simplement compter le nombre d observations dans 
la variable generee par ranuni afin d'obtenir la taille des echantillons et de l echantillon final */

%MACRO ASTRV06(var_strat, pourcentage_ech);
	PROC SQL noprint;  
		SELECT DISTINCT &var_strat , COUNT(DISTINCT &var_strat)
		INTO :nom_strat1 - , :nb_valeurs
		FROM &table
		WHERE &var_strat is not missing; 
	QUIT;
		;
		%do i=1 %to &nb_valeurs;
			%put La valeur numero &i correspondant à la variable de stratification :  &&nom_strat&i;
		
				PROC SQL;
					CREATE TABLE PROJET.strate&i AS
					SELECT *
					FROM &table
					WHERE &var_strat = "&&nom_strat&i" 
					ORDER BY ran ;
				QUIT;
		
				PROC SQL ;
					CREATE TABLE projet.ech&i AS
					SELECT *
					FROM projet.strate&i 
					WHERE ran Between 0 and 0.&pourcentage_ech.
					;
				QUIT;
		
				PROC SQL noprint;  
					SELECT COUNT(DISTINCT ran)
					INTO :tot_var&i 
					FROM projet.ech&i
				;
			QUIT;
		
			%put Le nombre de lignes (observations) dans le sous echantillon &i : &&tot_var&i;
			
		%end;
		
		DATA projet.recolle ;
			SET %do i=1 %to &nb_valeurs;
				projet.ech&i
				%end ;
			;
		RUN;
		
		PROC SQL noprint;  
			SELECT COUNT(DISTINCT ran)
			INTO :tot_final 
			FROM projet.recolle
			;
		QUIT;
		
		%put le nombre de lignes dans la table regroupant les trois sous echantillons : &tot_final;
	
	 	%put  Le nombre de valeurs prises par la variable de stratification : &nb_valeurs;
	 	%let type = %datatyp(&var_strat);
	 	%put Le type de la variable de stratification : &type;
	 	
%MEND; 

%ASTRV06 (sexe, 20);