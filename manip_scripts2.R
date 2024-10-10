### lecture de la base des donnees

df

##Enchaîner les opérations avec le pipe

names(df)
unique(dis.label1)
tmp.1=filter(df,dis.label1=="Aru")
tmp.1=select(tmp.1, dis.label2, dis.variable1)
arrange(tmp.1, dis.label2)
View(tmp.1)

### avec l'utilisation de pipe

df%>%
    filter(dis.label1=="Aru")%>%
  select(dis.label2, dis.variable1)%>%
  arrange(dis.label2)

## vous allez constaté que 
# nous trouvons les mêmes résultats
# NOTA  : On appelle une suite d’instructions de ce type un pipeline.

## L’utilisation du pipe n’est pas obligatoire, mais elle rend les scripts plus lisibles et plus rapides à saisir. 
#On l’utilisera donc dans ce qui suit.

## liste des territoires et leurs Population/Déplacement

ter <- df %>% 
  filter(dis.variable1 == "admin2") %>% 
  select(dis.label1, dis.label2)

##Opérations groupées
#group_by
#Un élément très important de dplyr est la fonction group_by. 
#Elle permet de définir des groupes de lignes à partir des valeurs d’une ou plusieurs colonnes.
#Par exemple, on peut grouper les vols selon leur mois :

vr.1= df %>% 
  group_by(dis.label2)%>%
  mutate(mean_taill_terr = max(n, na.rm=TRUE))%>%
    select(dis.label2, dis.label1, mean_taill_terr)

#group_by peut aussi être utile avec filter, 
#par exemple pour sélectionner les vols avec le retard 
#au départ le plus important pour chaque mois :

df %>% 
  group_by(month) %>% 
  filter(dep_delay == max(dep_delay, na.rm = TRUE))

#Attention : la clause group_by marche pour les verbes déjà vus précédemment, 
#sauf pour arrange, qui par défaut trie la table sans tenir compte des groupes. 
#Pour obtenir un tri par groupe, il faut lui ajouter l’argument .by_group = TRUE.

df %>% 
  group_by(month) %>% 
  dplyr::arrange(desc(dep_delay))

### nous constatons que la première commande ne tient pas compte des mois 
### nous allons maintenant utilisé la seconde commande qui tiendra compte des mois car nous avions ajouter by.group


df %>% 
  group_by(month) %>% 
  dplyr::arrange(desc(dep_delay), .by_group = TRUE)

###summarise et count
### summarise permet d’agréger les lignes du tableau en effectuant une opération “résumée” sur une ou plusieurs colonnes. 
##Par exemple, si on souhaite connaître les retards moyens au départ et à l’arrivée pour l’ensemble des vols du tableau flights :

df %>% 
  dplyr::summarise(
    retard_dep = mean(dep_delay, na.rm=TRUE),
    retard_arr = mean(arr_delay, na.rm=TRUE)
  )

#Cette fonction est en général utilisée avec group_by, puisqu’elle permet du coup d’agréger et résumer les lignes du tableau groupe par groupe. 
#Si on souhaite calculer le délai maximum, le délai minimum et le délai moyen au départ pour chaque mois, on pourra faire :

df %>%
  group_by(dis.label2) %>%
  dplyr::summarise(
    max_n = max(n, na.rm=TRUE),
    min_n = min(n, na.rm=TRUE),
    mean_n = mean(n, na.rm=TRUE)
  )

## summarise dispose d’un opérateur spécial, n(), qui retourne le nombre de lignes du groupe. 
## Ainsi si on veut le nombre de vols par destination, on peut utiliser :

df %>%
  group_by(dis.label2) %>%
  dplyr::summarise(nb = n())

#n() peut aussi être utilisée avec filter et mutate.
#À noter que quand on veut compter le nombre de lignes par groupe, on peut utiliser directement la fonction count. 
#Ainsi le code suivant est identique au précédent :

df %>%
  dplyr::count(dis.label2)

#Grouper selon plusieurs variables
#On peut grouper selon plusieurs variables à la fois, il suffit de les indiquer dans la clause du group_by :

df %>%
  group_by(month, dest) %>%
  dplyr::summarise(nb = n()) %>%
  dplyr::arrange(desc(nb))

#On peut également compter selon plusieurs variables :

df %>% 
  dplyr::count(origin, dest) %>% 
  dplyr::arrange(desc(n))

##On peut utiliser plusieurs opérations de groupage dans le même pipeline. 
#Ainsi, si on souhaite déterminer le couple origine/destination ayant le plus grand nombre de vols selon le mois de l’année, 
#on devra procéder en deux étapes :d’abord grouper selon mois, origine et destination pour calculer le nombre de vols
#puis grouper uniquement selon le mois pour sélectionner la ligne avec la valeur maximale.

#Au final, on obtient le code suivant :

df %>%
  group_by(dis.variable1, dis.label1, dis.label2) %>%
  dplyr::summarise(nb = n()) %>%
  group_by(dis.label1) %>%
  filter(nb == max(nb))

#Lorsqu’on effectue un group_by suivi d’un summarise, le tableau résultat est automatiquement dégroupé de la dernière variable de regroupement. 
#Ainsi le tableau généré par le code suivant est groupé par month et origin :

df %>%
  group_by(month, origin, dest) %>%
  dplyr::summarise(nb = n())

#Cela peut permettre “d’enchaîner” les opérations groupées. 
#Dans l’exemple suivant on calcule le pourcentage des trajets pour chaque destination par rapport à tous les trajets du mois :

df.1 = df %>%
  filter(dis.variable1=="admin2")

df.1 %>%
  group_by(dis.label1, dis.label2) %>%
  dplyr::summarise(nb = n()) %>% 
  mutate(stat = nb / sum(nb) * 100)

#On peut à tout moment “dégrouper” un tableau à l’aide de ungroup. 
#Ce serait par exemple nécessaire, dans l’exemple précédent, 
#si on voulait calculer le pourcentage sur le nombre total de vols plutôt que sur le nombre de vols par mois :

stats=df.1 %>%
  group_by(dis.label1, dis.label2) %>%
  dplyr::summarise(nb = n()) %>% 
  ungroup() %>% 
  mutate(pourcentage = nb / sum(nb) * 100)

#À noter que count, par contre, renvoit un tableau non groupé :

df %>% 
  dplyr::count(month, dest)

#Autres fonctions utiles
#dplyr contient beaucoup d’autres fonctions utiles pour la manipulation de données

#sample_n et sample_frac
#sample_n et sample_frac permettent de sélectionner un nombre de lignes ou une fraction des lignes d’un tableau aléatoirement. 
#Ainsi si on veut choisir 5 lignes au hasard dans le tableau airports :

df.2 %>% sample_n(5)

#Si on veut tirer au hasard 10% des lignes de flights :

df.2 %>% sample_frac(0.1)
df %>% sample_frac(0.1)

