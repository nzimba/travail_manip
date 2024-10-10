##Enchaîner les opérations avec le pipe

names(df.1)
unique(df.1$dest)
tmp.1=filter(df.1,dest=="LAX")
tmp.1=select(tmp.1, dep_delay, arr_delay)
arrange(tmp.1, dep_delay)
View(tmp.1)

### avec l'utilisation de pipe

df.1%>%
    filter(dest=="LAX")%>%
  select(dep_delay, arr_delay)%>%
  arrange(dep_delay)

## vous allez constaté que 
# nous trouvons les mêmes résultats
# NOTA  : On appelle une suite d’instructions de ce type un pipeline.

## L’utilisation du pipe n’est pas obligatoire, mais elle rend les scripts plus lisibles et plus rapides à saisir. 
#On l’utilisera donc dans ce qui suit.

delay_la <- df.1 %>% 
  filter(dest == "LAX") %>% 
  select(dep_delay, arr_delay)

##Opérations groupées
#group_by
#Un élément très important de dplyr est la fonction group_by. 
#Elle permet de définir des groupes de lignes à partir des valeurs d’une ou plusieurs colonnes.
#Par exemple, on peut grouper les vols selon leur mois :

df.1 %>% 
  group_by(month)%>%
  mutate(mean_deplay_month = mean(dep_delay, na.rm=TRUE))%>%
    select(dep_delay, month, mean_deplay_month)

#group_by peut aussi être utile avec filter, 
#par exemple pour sélectionner les vols avec le retard 
#au départ le plus important pour chaque mois :

df.1 %>% 
  group_by(month) %>% 
  filter(dep_delay == max(dep_delay, na.rm = TRUE))

#Attention : la clause group_by marche pour les verbes déjà vus précédemment, 
#sauf pour arrange, qui par défaut trie la table sans tenir compte des groupes. 
#Pour obtenir un tri par groupe, il faut lui ajouter l’argument .by_group = TRUE.

df.1 %>% 
  group_by(month) %>% 
  dplyr::arrange(desc(dep_delay))

### nous constatons que la première commande ne tient pas compte des mois 
### nous allons maintenant utilisé la seconde commande qui tiendra compte des mois car nous avions ajouter by.group


df.1 %>% 
  group_by(month) %>% 
  dplyr::arrange(desc(dep_delay), .by_group = TRUE)

###summarise et count
### summarise permet d’agréger les lignes du tableau en effectuant une opération “résumée” sur une ou plusieurs colonnes. 
##Par exemple, si on souhaite connaître les retards moyens au départ et à l’arrivée pour l’ensemble des vols du tableau flights :

df.1 %>% 
  dplyr::summarise(
    retard_dep = mean(dep_delay, na.rm=TRUE),
    retard_arr = mean(arr_delay, na.rm=TRUE)
  )

#Cette fonction est en général utilisée avec group_by, puisqu’elle permet du coup d’agréger et résumer les lignes du tableau groupe par groupe. 
#Si on souhaite calculer le délai maximum, le délai minimum et le délai moyen au départ pour chaque mois, on pourra faire :

df.1 %>%
  group_by(month_name) %>%
  dplyr::summarise(
    max_delay = max(dep_delay, na.rm=TRUE),
    min_delay = min(dep_delay, na.rm=TRUE),
    mean_delay = mean(dep_delay, na.rm=TRUE)
  )

## summarise dispose d’un opérateur spécial, n(), qui retourne le nombre de lignes du groupe. 
## Ainsi si on veut le nombre de vols par destination, on peut utiliser :

df.1 %>%
  group_by(dest) %>%
  dplyr::summarise(nb = n())

#n() peut aussi être utilisée avec filter et mutate.
#À noter que quand on veut compter le nombre de lignes par groupe, on peut utiliser directement la fonction count. 
#Ainsi le code suivant est identique au précédent :

df.1 %>%
  dplyr::count(dest)

#Grouper selon plusieurs variables
#On peut grouper selon plusieurs variables à la fois, il suffit de les indiquer dans la clause du group_by :

df.1 %>%
  group_by(month, dest) %>%
  dplyr::summarise(nb = n()) %>%
  dplyr::arrange(desc(nb))

#On peut également compter selon plusieurs variables :

df.1 %>% 
  dplyr::count(origin, dest) %>% 
  dplyr::arrange(desc(n))

##On peut utiliser plusieurs opérations de groupage dans le même pipeline. 
#Ainsi, si on souhaite déterminer le couple origine/destination ayant le plus grand nombre de vols selon le mois de l’année, 
#on devra procéder en deux étapes :d’abord grouper selon mois, origine et destination pour calculer le nombre de vols
#puis grouper uniquement selon le mois pour sélectionner la ligne avec la valeur maximale.

#Au final, on obtient le code suivant :

df.1 %>%
  group_by(month_name, origin, dest) %>%
  dplyr::summarise(nb = n()) %>%
  group_by(month_name) %>%
  filter(nb == max(nb))

#Lorsqu’on effectue un group_by suivi d’un summarise, le tableau résultat est automatiquement dégroupé de la dernière variable de regroupement. 
#Ainsi le tableau généré par le code suivant est groupé par month et origin :

df.1 %>%
  group_by(month, origin, dest) %>%
  dplyr::summarise(nb = n())

#Cela peut permettre “d’enchaîner” les opérations groupées. 
#Dans l’exemple suivant on calcule le pourcentage des trajets pour chaque destination par rapport à tous les trajets du mois :

df.1 %>%
  group_by(month, dest) %>%
  dplyr::summarise(nb = n()) %>% 
  mutate(pourcentage = nb / sum(nb) * 100)

#On peut à tout moment “dégrouper” un tableau à l’aide de ungroup. 
#Ce serait par exemple nécessaire, dans l’exemple précédent, 
#si on voulait calculer le pourcentage sur le nombre total de vols plutôt que sur le nombre de vols par mois :

df.1 %>%
  group_by(month, dest) %>%
  dplyr::summarise(nb = n()) %>% 
  ungroup() %>% 
  mutate(pourcentage = nb / sum(nb) * 100)

#À noter que count, par contre, renvoit un tableau non groupé :

df.1 %>% 
  dplyr::count(month, dest)

#Autres fonctions utiles
#dplyr contient beaucoup d’autres fonctions utiles pour la manipulation de données

#sample_n et sample_frac
#sample_n et sample_frac permettent de sélectionner un nombre de lignes ou une fraction des lignes d’un tableau aléatoirement. 
#Ainsi si on veut choisir 5 lignes au hasard dans le tableau airports :

df.2 %>% sample_n(5)

#Si on veut tirer au hasard 10% des lignes de flights :

df.2 %>% sample_frac(0.1)
df.1 %>% sample_frac(0.1)

