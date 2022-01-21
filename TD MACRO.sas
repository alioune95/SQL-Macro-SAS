libname Macro "C:\SAS\Master2\Programmation 4\Macro";
%let lib = Macro;

/*Exercice 1
Créer une macro PRINT paramétrée par la variable X qui affichera le contenu de la table X en
paramètre. On affichera aussi le titre « Base de données X (Le nom de la table) ». Appliquer à cette macro,
la table TABINIT se trouvant dans : (Voir en séance). */

%MACRO print(x=);
TITLE "Base de données &x";
PROC PRINT DATA = &x;
RUN;
%MEND;

%print(x=Macro.tabinit);



%MACRO print2(x=, titre=);
TITLE "&titre";
PROC PRINT DATA = &x;
RUN;
%MEND;

%print2(x=Macro.tabinit, titre=Base de données tabinit);



/*Exercice 2 : Paramétrage de fonctions
Créer un macro programme nommé IMPRIM paramétré par : (le nom d’une table) X et (une variable
de cette table) Y.
Le but de la macro étant d’afficher le contenu de la table X avec pour titre « La base de données X a
pour sa variable Y : la moyenne …. , la variance … et l’étendue … »
On utilisera la PROC UNIVARIATE pour obtenir les informations statistiques. (*version 1)
 Note : la moyenne, la variance et l’étendue sont récupérées respectivement grâce à mean, var, range.
On utilisera aussi la PROC SQL pour obtenir les informations statistiques. (*version 2)
On appliquera à cette macro la base de données TABINIT et la variable TAILLE.
On écrira deux *versions de cette macro, une en paramétrage positionnel et l’autre en paramétrage
par mot clé. */

%MACRO imprim(table=, variable=, y=);

PROC UNIVARIATE DATA = &table NOPRINT ;
VAR &variable;
OUTPUT OUT=Mesures MEAN=Moyenne RANGE=Etendu VAR=Variance;
RUN;
 
DATA _NULL_;
SET Mesures;
call symput("moy", moyenne);
call symput("var", variance);
call symput("etendu", Etendu);
RUN;

PROC PRINT DATA = &table;
TITLE "&y";
RUN;

%MEND;

%imprim(table=Macro.tabinit, variable=taille, y=La base de données &table a pour sa variable 
&variable%str(,) la moyenne : &moy%str(,) la variance : &var et l’étendue : &etendu);


/************************************/


%MACRO imprim2 (table, variable);

PROC SQL NOPRINT;
	SELECT round(mean(&variable),0.1),
			range(&variable),
			var(&variable)
	INTO :moyenne, :etendu, :variance
	FROM &table;
QUIT;

%PUT la moyenne est &moyenne%str(,) la variance est &variance et letendu est &etendu ;

%MEND;

%imprim2(Macro.tabinit, taille);


/********************************************/

%MACRO imprim3 (table, variable);

PROC SQL NOPRINT;
	SELECT mean(&variable),
		   range(&variable),
		   var(&variable)
	INTO :moyenne, :etendu, :variance
	FROM &table;
QUIT;

%print2(x=&table, titre=La base de données &table a pour sa variable 
		&variable%str(,) la moyenne : &moyenne%str(,) la variance : &variance et l’étendue : &etendu);

%PUT la moyenne est &moyenne%str(,) la variance est &variance et letendu est &etendu ;

%MEND;

%imprim3(Macro.tabinit, taille);




/*Exercice 3
Construisez le macro programme EXTRAICHAR() ayant pour paramètre «mot » et renvoyant les deux
dernier caractères de mot qui lui sera appliqué. Vous pourriez utiliser les macro fonctions %substr,
%eval et %length.*/


%MACRO EXTRAICHAR(mot);
%PUT &mot;
%PUT ;
%PUT Le mot extrait est : %SUBSTR(&mot, %LENGTH(&mot) -1, 2);
%MEND;

%EXTRAICHAR(france);


%MACRO EXTRAICHAR2(mot, n);
%PUT &mot;
%PUT ;
%PUT Le mot extrait est : %SUBSTR(&mot, %eval(%LENGTH(&mot)-&n+1), &n);
%MEND;

%EXTRAICHAR2(france, 4);


%MACRO EXTRAICHAR3(mot, n);
%if %length(&mot) ge &n %then %do;
	%PUT Le mot saisi est &mot;
	%PUT ;
	%PUT Le mot extrait est : %SUBSTR(&mot, %eval(%LENGTH(&mot)-&n+1), &n);
%end;

%else %do;
	%put La taille demandé est supérieure à la taille du mot;
	%goto toto;
%end;
%toto: %MEND;

%EXTRAICHAR3(france, 7);




/*Exercice 4
Construisez un macro programme LISTE(X,i,n) créant les tables SAS Xi, Xi+1,…,Xn à partir d’une série
de fichiers textes Xi.txt
On considérera la suite de fichiers textes enregistrés dans le dossier macrodon. Les fichiers sont
V1.txt, … , V5.txt. Leurs données correspondent aux variables suivantes : nom$ marque$ age relevé
sur des observations.
Appliquer la macro liste à (V,2,4) . Ceci créera les tables V2, V3, V4 contenant chacune les
observations des fichiers V2.txt, V3.txt, V4.txt.*/


%MACRO LISTE(X,i,n);
%do b=&i %to &n;
	DATA &X&b;
	INFILE "C:\SAS\Master2\Programmation 4\Macro\Macrodon\v&b..txt";
	INPUT nom$ marque$ age;
	RUN;
%end;
%MEND;

%LISTE(X,1,5);



/*Exercice 5
Créer une macro MESDATE(DT=) qui prend en paramètre la date du jour et retourne la date du
premier jour de l’année, la date du dernier jour de l’année, la date -1 an .
On pourra se servir de la macro fonction %sysfunc, de la fonction SAS intnx et de la fonction inputn.
Respectivement les dates seront sorties au format ddmmyy8., ddmmyy10., DATE9. */

%MACRO MESDATE(DT);
%let date = %sysfunc(date(), date9.);
%put La date est : &date;
%put Le premier jour de l%str(%')année est : %sysfunc(intnx(month, "&date"d, 0, b), ddmmyy10.);
%put Le dernier jour de l%str(%')année est : %sysfunc(intnx(month, "&date"d, 0, e), ddmmyy10.);
%put Ce jour à l%str(%')nnée précédente est : %sysfunc(intnx(month, "&date"d, -1), ddmmyy10.);
%MEND;

%MESDATE(date());
