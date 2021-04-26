library(dplyr) # Create new variable 
library(tidyr) # Create new variable 
library("gtools") # Macro variable 
library(gmodels) # For Crosstable 
library(ggplot2) 
library(ggcorrplot)


############################ Nettoyage du dataset ########################################################
names(data2)
str(data2)
data2 <- subset(data2, data2$EDUCATION!= 0 & data2$MARRIAGE!=0 & data2$EDUCATION !=5 & data2$EDUCATION!=6)
colnames(data2)[25] <- 'defaut'
data2$SEX[data2$SEX == 2] <- 0
data2$defaut <- as.factor(data2$defaut)
data2$EDUCATION <- as.factor(data2$EDUCATION)
data2$MARRIAGE <- as.factor(data2$MARRIAGE)
data2$SEX <- as.factor(data2$SEX)
data2$PAY_0 <- as.factor(data2$PAY_0)
data2$PAY_2 <- as.factor(data2$PAY_2)
data2$PAY_3 <- as.factor(data2$PAY_3)
data2$PAY_4 <- as.factor(data2$PAY_4)
data2$PAY_5 <- as.factor(data2$PAY_5)
data2$PAY_6 <- as.factor(data2$PAY_6)

data2 <- data2[,-1]
data2
##################################################################################################
############################# Default of payment next month #####################################

text_pie = function(vector,labels=c()) {
  vector = vector/sum(vector)*2*pi
  temp = c()
  j = 0
  l = 0
  for (i in 1:length(vector)) {
    k = vector[i]/2        
    j =  j+l+k
    l = k
    text(cos(j)/2,sin(j)/2,labels[i])
  }
  vector = temp
}
gp_default = table(card$`default payment next month`)
pie(prop.table(gp_default),labels="", main = "Proportion de défaut", radius = 1)
text_pie(prop.table(gp_default),c("Défaut (77,8%)"," Pas de défaut (22,1%)"))

##########################################################################################################
############################# Informations standards sur les clients #####################################
### Sexe ### 

data2$SEX <- as.factor(data2$SEX)
tsexe = table(data2$SEX)
pie(prop.table(tsexe),labels="", main = "Proportion Homme-Femme", radius = 1)
text_pie(prop.table(tsexe),c("Hommes (40%) ","Femmes (60%)"))

### Age, Mariage, Education ### 

ggplot(data2,aes(x = SEX, y = ..count.. / sum(..count..), fill=defaut)) + 
  geom_bar(position = "stack", color="Black")+ 
  labs(x = "SEX", y="pourcentage", title = "Proportion d'hommes et de femmes",
       subtitle= "Sexe = 0 pour les hommes, defaut = 1 pour une personne en défaut") + 
  scale_y_continuous(labels = scales::percent)

ggplot(data2, aes(x = AGE, y = ..count.. / sum(..count..), fill = defaut)) + 
  geom_histogram(position = "stack", color="black") + 
  labs(x = "Age", y="pourcentage", title = "Répartition des observations selon l'âge",
       subtitle= "Age en années, defaut = 1 pour une personne en défaut") + 
  scale_y_continuous(labels = scales::percent)

ggplot(data2,aes(x = MARRIAGE, y = ..count.. / sum(..count..), fill=defaut)) + 
  geom_bar(position = "stack", color="Black")+ 
  labs(x = "MARRIAGE", y="pourcentage") + 
  scale_y_continuous(labels = scales::percent)

ggplot(data2,aes(x = EDUCATION, fill=defaut, y = ..count.. / sum(..count..))) + 
  geom_bar(position = "stack", color="Black")+
  labs(x = "EDUCATION", y="pourcentage") + 
  scale_y_continuous(labels = scales::percent)

?CrossTable
CrossTable(round(data2$SEX),(data2$EDUCATION),prop.t=F,prop.c=T,prop.r=T,prop.chisq=F,chisq=F,expected=F)
CrossTable(data2$MARRIAGE, data2$EDUCATION, prop.t=F,prop.c=T,prop.r=T,prop.chisq=F,chisq=F,expected=F)

##########################################################################################################
############################# Type de clients et défaut de paiment #####################################

# Conditionnal summary 
tapply(data2$EDUCATION, data2$defaut, summary)
tapply(data2$LIMIT_BAL, data2$SEX, summary)
tapply(data2$LIMIT_BAL, data2$MARRIAGE, summary)
tapply(data2$LIMIT_BAL, data2$EDUCATION, summary)

ggplot(data2,
       aes(y = AGE, x = LIMIT_BAL, color=defaut)) + 
  geom_point(size = 2, alpha=.8) + 
  scale_x_continuous(breaks = seq(20, 80, 5),
                                       limits=c(20, 80)) + 
  labs(x = "Age",y = "Montant emprunté",
                    title = "Montant emprunté en fonction de l'âge des individus")

# Correlation 
first <- data.frame(limit_bal = data2$LIMIT_BAL,sex =  data2$SEX,
                    educ = data2$EDUCATION, marriage = data2$MARRIAGE,
                  age =  data2$AGE, defaut = data2$defaut)
correlation <- dplyr::select_if(first, is.numeric)
# calulate the correlations
r1 <- cor(correlation , use="complete.obs") 
round(r1,2)
ggcorrplot(r1,
           hc.order = TRUE,
           type = "lower",
           lab = TRUE)


##########################################################################################################
############################# Montant initial à rembourser  #####################################
summary(data2$LIMIT_BAL)

ggplot(data2,aes(x = LIMIT_BAL, fill=defaut, y = ..count.. / sum(..count..))) + 
  geom_histogram(position = "stack", color = "white")+
  labs(x = "Montant total à rembourser", y="pourcentage",
       title = "Distribution des montants à rembourser") + 
  scale_y_continuous(labels = scales::percent)

##########################################################################################################
######################################### Historique de remboursement #####################################


d <- data.frame(PAY_1 = data2$PAY_0, PAY_2 = data2$PAY_2 ,
                PAY_3 = data2$PAY_3, PAY_4 = data2$PAY_4,
                PAY_5 = data2$PAY_5, PAY_6 = data2$PAY_6)

second <- dplyr::select_if(d, is.numeric)
# calulate the correlations
sec <- cor(second, use="complete.obs") 
round(sec,2)
ggcorrplot(sec,
           hc.order = TRUE,
           type = "lower",
           lab = TRUE)


ggplot(data2, aes(x = PAY_0, y = ..count.. / sum(..count..), fill = defaut)) +
  geom_bar(position = "stack",color = "white") +
  labs(title = " ", x = "Situation en Septembre ", y="pourcentage") + 
  scale_y_continuous(labels = scales::percent)

ggplot(data2, aes(x = PAY_2, y = ..count.. / sum(..count..), fill = defaut)) +
  geom_bar(position = "stack",color = "white") +
  labs(title = " ", x = "Situation en Aout", y="pourcentage") + 
  scale_y_continuous(labels = scales::percent)

ggplot(data2, aes(x = PAY_6, y = ..count.. / sum(..count..), fill = defaut)) +
  geom_bar(position = "stack",color = "white") +
  labs(title = " ", x = "Situation en Avril ", y="pourcentage") + 
  scale_y_continuous(labels = scales::percent)

##########################################################################################################
######################################### Montant sur le revelé de compte #####################################

bill <- data.frame(Bill_1 = data2$BILL_AMT1 ,bill_2 = data2$PAY_AMT2,
                 bill_3 = data2$BILL_AMT3,bill_4 = data2$PAY_AMT4, 
                 bill_5 = data2$BILL_AMT5, bill_6 = data2$BILL_AMT6)


dfbill <- dplyr::select_if(bill, is.numeric)
# calulate the correlations
rbill <- cor(dfbill, use="complete.obs") 
round(rbill,2)
ggcorrplot(rbill,
           hc.order = TRUE,
           type = "lower",
           lab = TRUE)

ggplot(data2, aes(x = BILL_AMT1, y = ..count.. / sum(..count..), fill = defaut)) + 
  geom_histogram(position="stack",color="black") + 
  labs(x = "Montant sur le relevé de compte ", y="pourcentage",
       title ="Distribution des montants des factures des individus" ) + 
  scale_y_continuous(labels = scales::percent)+
  scale_x_continuous(limits=c(0, 250000))  


##########################################################################################################
######################################### Montant du paiement précédent #####################################


dd <- data.frame(PAYAMT_1 = data2$PAY_AMT1 ,PAYAMT_2 = data2$PAY_AMT2,
                 PAYAMT_3 = data2$PAY_AMT3,PAYAMT_4 = data2$PAY_AMT4, 
                 PAYAMT_5 = data2$PAY_AMT5, PAYAMT_6 = data2$PAY_AMT6)

df <- dplyr::select_if(dd, is.numeric)
# calulate the correlations
r <- cor(df, use="complete.obs") 
round(r,2)
ggcorrplot(r,
           hc.order = TRUE,
           type = "lower",
           lab = TRUE)

ggplot(data2, aes(x = PAY_AMT1, y = ..count.. / sum(..count..), fill=defaut)) + 
  geom_histogram(position="stack",color="black", bins = 10) + 
  labs(x = "", y = "Frequence") 

####################################################################################################################################################################################################################
####################################################################################################################################################################################################################
########################################################### Debut prédiction #########################################################################


(n = nrow(data2))
Ind.test = sample(n,n/3)
Learn = data2[-Ind.test,]
Test = data2[Ind.test,]
dim(Learn)
dim(Test)


########################################
####### Arbre de décision 
########################################

library(rpart)
library(rpart.plot)
lapply(data2,class)


##### rpart par defaut #####
(defaut_Tree <- rpart(defaut~., data=Learn)) 
plotcp(defaut_Tree)
plot(defaut_Tree)
text(defaut_Tree,pretty=0)
table(Test$defaut, predict(defaut_Tree, Test, type = "class"))


(defaut_Tree4 <- rpart(defaut~., data=Learn,control=rpart.control(minsplit=80,cp=0))) 
plotcp(defaut_Tree4)
plot(defaut_Tree4)
text(defaut_Tree4,pretty=0)

table(Test$defaut, predict(defaut_Tree4, Test, type = "class"))

prev_arbre <- predict(defaut_Tree,newdata=Test,type="class")
err_arbre <- sum(prev_arbre!=Test$defaut)/nrow(Test)
err_arbre

TreeOptimal4 <- prune(defaut_Tree4,cp=defaut_Tree4$cptable[which.min(defaut_Tree4$cptable[,4]),1])
prp(TreeOptimal4,extra=1)
predict(TreeOptimal4,Learn[1:10,],type="class" )
table(Test$defaut, predict(TreeOptimal4, Test, type = "class"))


##### rpart avec control, minsplit =  construit un arbre en continuant les découpages dans 
##### les feuilles qui contiennent au moins  observations. 
#### et sans contrainte sur la qualité du découpage (paramètre cp mis à 0).


(defaut_Tree_minsplit <- rpart(defaut~., data=data2))
plotcp(defaut_Tree_minsplit)

defaut_TreeOptimal_minsplit <- prune(defaut_Tree_minsplit,cp=defaut_Tree_minsplit$cptable[which.min(defaut_Tree_minsplit$cptable[,4]),1])
prp(defaut_TreeOptimal_minsplit,extra=1)
predict(defaut_TreeOptimal_minsplit,data2[1:10,] )
table(Test$defaut, predict(defaut_TreeOptimal_minsplit, Test, type="class"))

########################################
####### KNN #######
########################################


# Installing Packages
install.packages("e1071")
install.packages("caTools")
install.packages("class")

# Loading package
library(e1071)
library(caTools)
library(class)

classifier_knn <- knn(train = Learn,
                       test = Test,
                       cl = Learn$defaut,
                       k = 1)



# Confusion Matrix
(cm <- table(Test$defaut, classifier_knn))

plot(Learn, pch=20, col=classifier_knn, cex=0.5, main="Frontière de décision pour k=1 voisins")
points(Learn[,-24], pch=Learn[,24], col=Learn[,24])
legend("topleft", legend=c("Pas défaut", "Défaut"), pch=1:2, col=1:2, bg="white")

# Model Evaluation - Choosing K
# Calculate out of Sample error
misClassError <- mean(classifier_knn != Test$defaut)
print(paste('Accuracy =', 1-misClassError))

# On teste des valeurs de k 
classifier_knn <- knn(train = Learn,
                      test = Test,
                      cl = Learn$defaut,
                      k = 10)
(cm <- table(Test$defaut, classifier_knn))
(misClassError3 <- mean(classifier_knn != Test$defaut))
print(paste('Accuracy =', round(1-misClassError3,4)))

K <- seq(1,10,by=1)
err <- K
ind <- 0
for (ind in K)
  {
  print(ind)
  mod_ppv <- knn(train=Learn[, -24],test=Test[,-24],cl=Learn$defaut,k=K[ind])
  err[ind] <- sum(mod_ppv!=Test$defaut)/nrow(Test)
}

for( min(err) )
  {
  print(min(err))
  print(ind)
  }

######################################################
######## Random Forrest 
################################################

install.packages("randomForest")
library(randomForest)
mod_RF <- randomForest(Learn$defaut~., data = Learn)
imp <- importance(mod_RF)
print(mod_RF)
# On ordonne les variables selon leur importance 
order(imp,decreasing=TRUE)

mod_RF$err.rate[500,1]

## erreur sur échantillon test 
prev <- predict(mod_RF,newdata=Test)
sum(prev!=Test$defaut)/nrow(Test)

# train bagged model

install.packages("caret")
install.packages("ipred")

library(caret)
library(ipred)
ames_bag1 <- bagging(
  formula = defaut ~ .,
  data = Learn,
  nbagg = 200,  
  coob = TRUE,
  control = rpart.control(minsplit = 2, cp = 0)
)

ames_bag1

prev <- predict(ames_bag1,newdata=Test)
sum(prev!=Test$defaut)/nrow(Test)







