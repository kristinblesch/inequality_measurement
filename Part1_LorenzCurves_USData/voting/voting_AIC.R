
library(dplyr)
library(tidyr)
require(xtable)
require(votesys)

# this code can be used to determine voting results on a county or state level
# decide whether to run voting on a county or state level: 

# on a county level: 
dat <- read.csv("../estimation_procedure/MLE_output_county.csv") %>% select(-1)
colnames(dat)[1] <- "X"

# on a state level: 
dat <- read.csv("../estimation_procedure/MLE_output_state.csv") %>% select(-1)
colnames(dat)[1] <- "X"

num_models <- length(unique(dat$form))

# PLURALITY voting
plurality <- dat %>%group_by(X) %>% mutate(ranking = rank(AIC_c, ties.method = "first" )) %>% filter(ranking==1) %>% 
  group_by(form)%>% summarise(plurality_winner = sum(ranking))%>% arrange(desc(plurality_winner))
table1 <- xtable(plurality, digits = 4, 
                 caption = "Plurality voting for Lorenz curve model, 
                 each county has one vote for the best fitting Lorenz curve model (according to AIC)" )
print.xtable(table1, NA.string= "-", include.rownames = F)

# BORDA count
borda <- dat %>%group_by(X) %>% mutate(ranking = rank(AIC_c, ties.method = "first" )) %>% mutate(borda_points = num_models-ranking) %>% 
  group_by(form) %>%summarise(borda_score = sum(borda_points)) %>% arrange(desc(borda_score))
table2 <- xtable(borda, digits = 4, 
                 caption = "Borda scores for Lorenz curve models, 
                 each county scores the best fitting Lorenz curve model (according to AIC)" )
print.xtable(table2, NA.string= "-", include.rownames = F)

# CONDORCET procedure
condorcet <-  dat %>%group_by(X) %>% mutate(ranking = rank(AIC_c, ties.method = "first" )) %>% 
  select(X,form,ranking) %>% spread(form, ranking)
col_con <- colnames(condorcet)
cc <- unlist(condorcet) %>% matrix(ncol = 18)
colnames(cc) <- col_con
condorcet_matrix <- create_vote(cc[,-1], xtype = 1)$cdc 
cdc_simple(condorcet_matrix)$winner
table3 <- xtable(condorcet_matrix, digits = 0, 
                 caption = "Condorcet dominance matrix in pairwise comparisons of the models" )
print.xtable(table3, NA.string= "-", include.rownames = T)

condorcet_matrix


