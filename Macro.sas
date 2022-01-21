%put %eval(2+5);

%let Mavar = Ceci est une macro;
%put &Mavar;
%put '&Mavar';
%put "&Mavar";

%let a=bonjour;
%put &&&a;

%let a=b;
%let b=c;
%let c=d;
%put &&&&&&&a;

/*Le programme SAS ci-dessous permet de créer une table à partir de la table PRDSAL2(présente dans la SASHELP) 
et d’afficher les 15 premières ligne de cette nouvelle table. Vous devez ici remplacer tous les éléments qui 
sont en vert par des macro variables que vous allez créer.

Attention : Pour l’élément SASHELP.PRDSAL2 il faut utiliser une macro variable pour la librairie et une autre
pour le nom de la table. Pour le titre et la note, il faut utiliser des macro variables automatiques. */

%let variables=COUNTRY, PRODUCT, ACTUAL;
%let lib=sashelp;
%let tab=prdsal2;


Proc sql noprint;
  Create table TEST as 
   select &variables
     from &lib..&tab.
   where PRODUCT ne "BED" and MONYR lt "01JAN1997"d;
Quit;

Title "Table TEST : fait le &sysdate.";
Footnote "Version SAS : &sysver. ";
Proc print data=TEST(obs=15); run;  

/******************************************************/

Proc sql noprint;
  Create table TEST as 
   select COUNTRY, PRODUCT, ACTUAL
     from SASHELP.PRDSAL2
   where PRODUCT ne "BED" and MONYR lt "01JAN1997"d;
Quit;

Title "Table TEST : fait le xxxx";
Footnote "Version SAS : xxx ";
Proc print data=TEST(obs=15); run;  


data NOTE;
Input PRENOM $  NOTE;
cards;
Maxime  10
Melanie  17
John       14
 ;
run; 

data _NULL_;  
set NOTE;
Call symputx(PRENOM,NOTE);
run; 

%put &Maxime. &Melanie. &John.;


Data _NULL_; 
set NOTE  end = LAST;
Call symputx(compress("VAR"||_N_),NOTE);
If LAST then call symputx("NOBS",_N_);
run; 


/*Exercice 1

/*A l’aide de la PROC SQL, calculer la moyenne de la variable ACTUAL pour chaque type de produit (variable PRODUCT) 
avec la table PRDSAL2. Appeler cette nouvelle variable créée MOY.

A l’aide d’une étape data, créer une macro variable par observation. Celles-ci auront pour contenu la valeur de la variable MOY.

Utilisez ensuite ces informations pour créer une autre table à partir de PRDSAL2 qui ne conservera que les modalités 
dont ACTUAL sera supérieur à la moyenne du produit. */

PROC SQL NOPRINT;
	create table ex1 as
	select distinct PRODUCT, round(mean(actual),0.1)  as MOY
	from sashelp.PRDSAL2
	group by PRODUCT;
quit;

data _null_;
set ex1;
call symputx(compress("moy_"||product), moy);
run;
%put &moy_desk;


proc sql noprint;
	create table ex11 as
	select * 
	from  sashelp.PRDSAL2
	where (product="DESK" and actual gt &moy_desk)
	or (product="CHAIR" and actual gt &moy_chair);
quit;



/**************************************************************/
/**************************************************************/


/*création des macros avec indice*/
/*Crée une macro variable que pour la première ligne*/

Proc sql noprint;
Select  PRENOM,  NOTE
    into  :NAME, :NOTE  
     from NOTE;
Quit;
%put &name &note;


/*Crée une macro variable pour toutes les observations*/

proc sql noprint;
	select prenom, note
	into :name1-:name99,
		 :note1-:note99
	from note;
quit;
%put &name2 &note2;


/*créer une liste de macro*/

Proc sql noprint;
Select  PRENOM,  NOTE
    into  :NAME separated by " " ,
		  :NOTE separated by " "  
     from NOTE;
Quit;
%put &name &note;



/*Exercice 2 :  
 
Rependre l’exercice ci-dessous en utilisant une seule PROC SQL


A l’aide de la PROC SQL, calculer la moyenne de la variable ACTUAL pour chaque type de produit (variable PRODUCT) 
avec la table PRDSAL2. Appeler cette nouvelle variable Moy.

A l’aide d’une étape data, créer une macro variable par observation. Celles-ci auront pour modalités la valeur
de la variable Moy.

Utilisez ensuite ces informations pour créer une autre table à partir de PRDSAL2 qui ne conservera que les modalités
dont ACTUAL sera supérieur à la moyenne du produit. */

PROC SQL noprint;
	select distinct PRODUCT, round(mean(actual),0.1)  as MOY
	into :product1-:product99,
		 :moy1-:moy99
	from SASHELP.PRDSAL2
	group by PRODUCT;

	create table exo2 as 
	select distinct product, actual
	from SASHELP.PRDSAL2
	where (product="&product1" and actual gt &moy1)
	or (product="&product2" and actual gt &moy2);
quit;

%put &product2 &moy2;


/*********************************/
/******MACRO FONCTIONS************/
/*********************************/

%let i = 4 ; 
%let j = &i+1;  %put &j;
%let k = %eval(&i+1); %put &k;


%let i = 5 ; 
%let j = %sysevalf(&i/2) ; 
%let test1 = %sysevalf(&i/2 , boolean) ; 
%let test2 = %sysevalf(&i/2 - . , boolean) ; 

%let plafond=%sysevalf(&i/2 +3 , ceil); 
%let plancher = %sysevalf(&i - 5.5 , floor) ; 



%let nb = 1971 ; 
%let racine2 = %sysfunc(sqrt(&nb),8.2) ; 
%put &racine2;


%let DT1 = %sysfunc(date(), DATE9.); %put &DT1;    
%let DT2 = %sysfunc(mdy(11,2,2018), ddmmyy10.); %put &DT2;



/************************************************/
/*************MACRO PROGRAMMES*******************/
/************************************************/


%macro proced(table=, opt=noobs, vars=); 
    %if %upcase(%scan(&table,1,’.’))=SASHELP %then %do ; 	proc contents data=&table ;
 	run ; 
     %end ; 
    %else %do ; 
	data temp ; 
	set &table ; 
	    if air < 100 then classe = 1 ; 
	   else if air < 200 then classe = 2 ;
                run; 
%end ; 
%mend proced ; 

%proced(table=sashelp.air)


/*************************************/


%macro liste(nbitem=) ; 
  %do i=1 %to &nbitem ; 
       %put Donnees.tab%eval(&i-1); 
  %end; 
%mend;

%liste(nbitem=5);

%macro liste(nbitem) ; 
  %do i=1 %to &nbitem ; 
       %put Donnees.tab%eval(&i-1); 
  %end; 
%mend;

%liste(5);

%macro liste(nbitem) ; 
  %do i=1 %to &nbitem ; 
       %put Donnees.tab%eval(&i-1); 
  %end; 
%mend;
%let k=6;

%liste(&k);



/********************************/


%macro nbmot(chaine,delim); 
 %let i=1; 
    %do %until(&lm=0); 
        %let lm=%length(%scan(&chaine,&i,&delim)) ;
        %let i=%eval(&i+1) ; 
     %end ; 
 %eval(&i-2) ; 
%mend ;

%let plans = 1-2 3-4 ;

%let nb_plans = %nbmot(&plans,' ') ;
 
%put &nb_plans ;
