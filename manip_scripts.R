### packages à télécharger

library(tidyverse)
library(dplyr)
library(nycflights13)
library(readxl)

### data d'expérimentations

data_all = read_excel("C:/Users/User/OneDrive - ACTED/travail_articles_Yan's/2024-09-10/manipulation_données/connection_manip/travail_manip/data/Analyses_2024-09-19_1.xlsx", sheet="Analysis_ALL")


### renomer les datasets
### structures des datasets
df= data_all
str(df)
View(df)
names(df)
class(df)
dim(df)

### commande slice 

slice(df, 10)
slice(df, 1:6)   ## slice peut aussi afficher le même résultat que head(df)
head(df)

### filtre territoire

unique(dis.variable1)

### commande filter
names(df)
unique(df$dis.label2)
filter(df, dis.variable1=="admin2")   ### filtre le territoire
filter(df, n>100 & n<250)             ### filtre dans l'ensemble les données selon la taille de l'échantillon compris entre 100 et 250

filter(df, N==max(N))
filter(df, n==max(n))

### commande select

names(df)
select(df, dis.variable1, dis.label1, dis.label2,)

### les compléments dans les commandes select, starts_with, ends_with, contains ou matches

select(df, starts_with("dis"))
select(df, ends_with("on"))
select(df, contains("ou"))

###all_of et any_of permettent de fournir une liste de variables 
#à extraire sous forme de vecteur textuel. Alors que all_of renverra une erreur 
#si une variable n’est pas trouvée dans le tableau de départ, any_of sera moins stricte.

select(df, all_of(c("dis.variable1", "dis.label1")))
select(df, any_of(c("dis.variable1", "dis.label1","beni")))

##where permets de sélectionner des variables à partir d’une fonction qui renvoie une valeur logique. 
#Par exemple, pour sélectionner seulement les variables textuelles.
str(df)
select(df, where(is.character))
select(df, where(is.numeric))

##select peut être utilisée pour réordonner les colonnes d’une table 
#en utilisant la fonction everything(), qui sélectionne l’ensemble des colonnes non encore sélectionnées. 
#Ainsi, si on souhaite faire passer la colonne name en première position de la table airports, on peut faire :

select(df, dis.label1, dis.variable1, everything())

#Pour réordonner des colonnes, on pourra aussi avoir recours à relocate en indiquant les premières variables. 
#IL n’est pas nécessaire d’ajouter everything() car avec relocate toutes les variables sont conservées.

relocate(df, dis.variable1, dis.label1, dis.label2)

#Une variante de select est rename, qui permet de renommer facilement des colonnes. 
#On l’utilise en lui passant des paramètres de la forme nouveau_nom = ancien_nom. 
#Ainsi, si on veut renommer les colonnes lon et lat de airports en longitude et latitude :

##dplyr::rename(df.2, longitude=lon, latitude=lat, altitude=alt)

##arrange
#arrange réordonne les lignes d’un tableau selon une ou plusieurs colonnes.
#Ainsi, si on veut trier le tableau flights selon le retard au départ croissant :

#dplyr::arrange(df, month)
#dplyr::arrange(df, dep_delay)

dplyr::arrange(df, dis.label1, dis.variable1)

#Si on veut trier selon une colonne par ordre décroissant, on lui applique la fonction desc() : 
# ordre decroissant

dplyr::arrange(df, desc(dis.label1))

##Combiné avec slice, arrange permet 
#par exemple de sélectionner les trois vols ayant eu le plus de retard :

tmp = dplyr::arrange(df, desc(dis.label1))
slice(tmp,1:3)

#mutate
#mutate permet de créer de nouvelles colonnes dans le tableau de données, 
#en général à partir de variables existantes.

#Par exemple, la table airports contient l’altitude de l’aéroport en pieds. 
#Si on veut créer une nouvelle variable alt_m avec l’altitude en mètres, on peut faire :

df.2 <- mutate(df.2, alt_m = alt / 3.2808)
select(df.2, name, alt, alt_m)

#On peut créer plusieurs nouvelles colonnes en une seule fois, 
#et les expressions successives peuvent prendre en compte les résultats des calculs précédents. 
#L’exemple suivant convertit d’abord la distance en kilomètres dans une variable distance_km, 
#puis utilise cette nouvelle colonne pour calculer la vitesse en km/h.

df <- mutate(df, 
                  distance_km = distance / 0.62137,
                  vitesse = distance_km / air_time * 60)
select(df, distance, distance_km, vitesse)

#À noter que mutate est évidemment parfaitement compatible avec les fonctions vues dans le chapitre sur les recodages : 
#fonctions de forcats, if_else, case_when…
#L’avantage d’utiliser mutate est double. 
#D’abord il permet d’éviter d’avoir à saisir le nom du tableau de données dans les conditions d’un if_else ou d’un case_when :

df <- mutate(df,
                  type_retard = case_when(
                    dep_delay > 0 & arr_delay > 0 ~ "Retard départ et arrivée",
                    dep_delay > 0 & arr_delay <= 0 ~ "Retard départ",
                    dep_delay <= 0 & arr_delay > 0 ~ "Retard arrivée",
                    TRUE ~ "Aucun retard"))

#Utiliser mutate pour les recodages permet aussi de les intégrer dans un pipeline de traitement de données, 
#concept présenté dans la section suivante.
#Citons également les fonctions "recode" et "recode_factor".

df$month_name <- recode_factor(flights$month,
                                    "1" = "Jan",
                                    "2" = "Feb",
                                    "3" = "Mar",
                                    "4" = "Apr",
                                    "5" = "May",
                                    "6" = "Jun",
                                    "7" = "Jul",
                                    "8" = "Aug",
                                    "9" = "Sep",
                                    "10" = "Oct",
                                    "11" = "Nov",
                                    "12" = "Dec"
)

