require(data.table)

require(fmsb)

require(ggplot2)

require(RColorBrewer)



create_beautiful_radarchart <- function(data, color = "#00AFBB", 
                                        vlabels = colnames(data), vlcex = 0.7,
                                        caxislabels = NULL, title = NULL, ...){
  radarchart(
    data,
    # change axistype to 1 to display value range on plot
    axistype = 0,
    # Customize the polygon
    pcol = color,
    pfcol = scales::alpha(color, 0.5),
    plwd = 2,
    plty = 1,
    # Customize the grid
    cglcol = "grey",
    cglty = 1,
    cglwd = 0.8,
    # Customize the axis
    axislabcol = "grey", 
    # Variable labels
    vlcex = vlcex,
    vlabels = vlabels,
    caxislabels = caxislabels,
    title = title, ...
  )
}



# 10 items BIG 5

big510_raw <- fread("answerdf_big5_10items.tsv",header = T)

candidate_labels_german=c("trifft überhaupt nicht zu", "trifft eher nicht zu", "weder noch", "eher zutreffend", "trifft voll und ganz zu")

items_german=c("Ich bin eher zurückhaltend, reserviert.","Ich schenke anderen leicht Vertrauen, glaube an das Gute im Menschen.","Ich bin bequem, neige zur Faulheit.","Ich bin entspannt, lasse mich durch Stress nicht aus der Ruhe bringen.","Ich habe nur wenig künstlerisches Interesse.","Ich gehe aus mir heraus, bin gesellig.","Ich neige dazu, andere zu kritisieren.","Ich erledige Aufgaben gründlich.","Ich werde leicht nervös und unsicher.","Ich habe eine aktive Vorstellungskraft, bin phantasievoll.")

candidate_labels_english = c("Disagree strongly", "Disagree a little", "Neither agree nor disagree", "Agree a little", "Agree strongly")

items_english=c("I see myself as someone who is reserved.","I see myself as someone who is generally trusting.","I see myself as someone who tends to be lazy.","I see myself as someone who is relaxed, handles stress well.","I see myself as someone who has few artistic interests.","I see myself as someone who is outgoing, sociable.","I see myself as someone who tends to find fault with others.","I see myself as someone who does a thorough job.","I see myself as someone who gets nervous easily.","I see myself as someone who has an active imagination.")

# check if there is strong bimodality
# to see if models understand responses as ranked

en_answers <- melt(big510_raw[lang == "en",.SD,c("model","item_index"),.SDcols=paste(1:5)],id.vars = c("model","item_index"))

ggplot(en_answers,aes(x=variable,y=value,group=item_index,color=as.factor(item_index))) + geom_line() + facet_wrap( ~ model ) +
  theme_bw() + scale_color_manual(values=c('#a6cee3','#1f78b4','#b2df8a','#33a02c','#fb9a99','#e31a1c','#fdbf6f','#ff7f00','#cab2d6','#6a3d9a','#ffff99','#b15928')) +
  labs(color='Item #') + xlab("Response") + ylab("Model Score") + theme(strip.background =element_rect(fill="white"))

ggsave("enanswers_distlines.pdf",scale=3.2)


de_answers <- melt(big510_raw[lang == "de",.SD,c("model","item_index"),.SDcols=paste(1:5)],id.vars = c("model","item_index"))

ggplot(de_answers,aes(x=variable,y=value,group=item_index,color=as.factor(item_index))) + geom_line() + facet_wrap( ~ model ) +
  theme_bw() + scale_color_manual(values=c('#a6cee3','#1f78b4','#b2df8a','#33a02c','#fb9a99','#e31a1c','#fdbf6f','#ff7f00','#cab2d6','#6a3d9a','#ffff99','#b15928')) +
  labs(color='Item #') + xlab("Response") + ylab("Model Score") + theme(strip.background =element_rect(fill="white"))

ggsave("deanswers_distlines.pdf",width=9.42,height = 6.2/2)

# check different aggregation
# stick with argmax per model

big510_raw[,max_response:=max.col(.SD),.SDcols=paste(1:5)]

# update, correctly reversed
big510_raw[item_index %in% c(1,3,4,5,7),max_response:=6-max_response]

# Scoring the BFI-10 scales:
#   Extraversion: 1R, 6; Agreeableness: 2, 7R; Conscientiousness: 3R, 8; Neuroticism: 4R, 9;
# Openness: 5R; 10 (R D item is reversed-scored).

big510_raw[item_index %in% c(1,6),dimension:="extraversion",c("model","lang")]

big510_raw[item_index %in% c(2,7),dimension:="agreeableness",c("model","lang")]

big510_raw[item_index %in% c(3,8),dimension:="conscientiousness",c("model","lang")]

big510_raw[item_index %in% c(4,9),dimension:="neuroticism",c("model","lang")]

big510_raw[item_index %in% c(5,10),dimension:="openness",c("model","lang")]

big510_raw_scored <- big510_raw[,.(dimension_score=mean(max_response)),c("model","lang","dimension")]


# one example
# big510_raw_scored[lang=="en" & model=="microsoft/deberta-base-mnli",.(dimension,dimension_score)]


big510_raw_scored_wide <- dcast(big510_raw_scored,model+lang ~ dimension,value.var="dimension_score")

varnames=c("openness","neuroticism","agreeableness","extraversion","conscientiousness")

minmaxdt <- data.table(rbind(rep(5,5),rep(1,5)))

colnames(minmaxdt) <- varnames

enmodels <- big510_raw_scored_wide[lang=="en",unique(model)]


dev.off()


par(mar=c(0,0,1,0),xpd = NA,mfrow=c(3,2))

for(enmodel in enmodels){

  pldt <- rbind(minmaxdt,big510_raw_scored_wide[lang=="en" & model==enmodel,.(openness,neuroticism,agreeableness,extraversion,conscientiousness)])

  create_beautiful_radarchart(pldt,title=paste(enmodel,"(en)"))
}
# export settings
# portrait
# 10x8
# big544_models_en.pdf

dev.off()

par(mar=c(0,0,0,0),oma=c(0,0,1,0),mfrow=c(1,3))

demodels <- big510_raw_scored_wide[lang=="de",unique(model)]

for(demodel in demodels){
  
  pldt <- rbind(minmaxdt,big510_raw_scored_wide[lang=="de" & model==demodel,.(openness,neuroticism,agreeableness,extraversion,conscientiousness)])
  
  create_beautiful_radarchart(pldt)
  
  title(paste(demodel,"(de)"),line=-1)
}
# export settings
# portrait
# 10x4
# big544_models_de.pdf

# landscape
# 11.69 x 4.135

# for scoring, see
# https://psychology.stackexchange.com/questions/18613/converting-big-5-questionnaire-data-to-big-5-scores-using-r








# new and easier
# update, adjusted above one too

# 44 items BIG 5

# scoring rules in
# 44_items_big5/BFI-Scoring.doc

big544_raw <- fread("answerdf_big5_44items_english.tsv",header = T)

# do with argmax per model
big544_raw[,max_response:=max.col(.SD),.SDcols=paste(1:5)]

# those to be reversed
big544_raw[item_index %in% c(2,6,8,9,12,18,21,23,24,27,31,34,35,37,41,43),max_response:=6-max_response]

# assign to domains
# Extraversion: 1, 6R 11, 16, 21R, 26, 31R, 36
# Agreeableness: 2R, 7, 12R, 17, 22, 27R, 32, 37R, 42
# Conscientiousness: 3, 8R, 13, 18R, 23R, 28, 33, 38, 43R
# Neuroticism: 4, 9R, 14, 19, 24R, 29, 34R, 39
# Openness: 5, 10, 15, 20, 25, 30, 35R, 40, 41R, 44

big544_raw[item_index %in% c(1,6,11,16,21,26,31,36),dimension:="extraversion",c("model","lang")]

big544_raw[item_index %in% c(2,7,12,17,22,27,32,37,42),dimension:="agreeableness",c("model","lang")]

big544_raw[item_index %in% c(3,8,13,18,23,28,33,38,43),dimension:="conscientiousness",c("model","lang")]

big544_raw[item_index %in% c(4,9,14,19,24,29,34,39),dimension:="neuroticism",c("model","lang")]

big544_raw[item_index %in% c(5,10,15,20,25,30,35,40,41,44),dimension:="openness",c("model","lang")]


big544_raw_scored <- big544_raw[,.(dimension_score=mean(max_response)),c("model","lang","dimension")]


# for new distlines
big544_models <- big544_raw_scored[lang=="en",unique(model)]

big544_models_short <- c("XLMRoBERTa","multilingualDeBERTa","BART","DistilBART","DistilRoBERTa","DeBERTa")

big544_raw_short <- merge(big544_raw,data.table(model=big544_models,model_short=big544_models_short),all.x=T)

big544_distlines_dt <- melt(big544_raw_short[lang == "en",.SD,c("model_short","item_index"),.SDcols=paste(1:5)],id.vars = c("model_short","item_index"))

ggplot(big544_distlines_dt[item_index %in% 1:10],aes(x=variable,y=value,group=item_index,color=as.factor(item_index))) + geom_line() + geom_point() + facet_wrap( ~ model_short ) +
  theme_bw(base_size=25) + scale_color_manual(values=c('#a6cee3','#1f78b4','#b2df8a','#33a02c','#fb9a99','#e31a1c','#fdbf6f','#ff7f00','#cab2d6','#6a3d9a','#ffff99','#b15928')) +
  labs(color='Item #') + xlab("Response") + ylab("Model Score") + theme(strip.background =element_rect(fill="white")) + guides(colour="none")

# + guides(color = guide_legend(ncol=2))
  # theme(legend.key.size = unit(1.2,"line")) +
  # guides(color = guide_legend(override.aes = list(size = 4),nrow = 1))

# ggsave("enanswers_distlines_44items.pdf",height=8,width=10)




# for radar plots
big544_raw_scored_wide <- dcast(big544_raw_scored,model+lang ~ dimension,value.var="dimension_score")




# right order in the plots
varnames=c("openness","neuroticism","agreeableness","extraversion","conscientiousness")

# minimum and maximum
# update, correct order
minmaxdt <- data.table(rbind(rep(5.0,5),rep(1.0,5)))

colnames(minmaxdt) <- varnames

big544_models <- big544_raw_scored_wide[lang=="en",unique(model)]

big544_models_short <- c("multilingualDeBERTa","DistilRoBERTa","BART","XLMRoBERTa","DeBERTa","DistilBART")

# two per row
par(mar=c(0,0,2.5,0),mfrow=c(3,2))

for(x in 1:length(big544_models)){
  
  pldt <- rbind(minmaxdt,big544_raw_scored_wide[lang=="en" & model==big544_models[x],.(openness,neuroticism,agreeableness,extraversion,conscientiousness)])
  
  create_beautiful_radarchart(pldt,vlcex=1.5)
  
  title(paste(big544_models_short[x]),adj = 0.5, line = 1,cex.main=2)
}

# export settings
# portrait
# 10x8
# big544_models.pdf

dev.off()

# three by row

par(mar=c(0,0,2.5,0),mfrow=c(2,3))

for(x in 1:length(big544_models)){
  
  pldt <- rbind(minmaxdt,big544_raw_scored_wide[lang=="en" & model==big544_models[x],.(openness,neuroticism,agreeableness,extraversion,conscientiousness)])
  
  create_beautiful_radarchart(pldt,vlcex=1.5)
  
  title(paste(big544_models_short[x]),adj = 0.5, line = 1,cex.main=2)
}

# export settings
# landscape
# 10x8
# big544_models_3row.pdf


# GERMAN 44 items BIG 5

# scoring rules in
# 44_items_big5/BFI-Scoring.doc

big544_raw_german <- fread("answerdf_big5_44items_german.tsv",header = T)

# do with argmax per model
big544_raw_german[,max_response:=max.col(.SD),.SDcols=paste(1:5)]

# those to be reversed
big544_raw_german[item_index %in% c(2,6,8,9,12,18,21,23,24,27,31,34,35,37,41,43,45),max_response:=6-max_response]

# assign to domains
# Extraversion: 1,6R,11,16,21R,26,31R,36
# Agreeableness: 2R,7,12R,17,22,27R,32,37R,42,45R
# Conscientiousness: 3,8R,13,18R,23R,28,33,38,43R
# Neuroticism: 4,9R,14,19,24R,29,34R,39
# Openness: 5,10,15,20,25,30,35R,40,41R,44

big544_raw_german[item_index %in% c(1,6,11,16,21,26,31,36),dimension:="extraversion",c("model","lang")]

big544_raw_german[item_index %in% c(2,7,12,17,22,27,32,37,42,45),dimension:="agreeableness",c("model","lang")]

big544_raw_german[item_index %in% c(3,8,13,18,23,28,33,38,43),dimension:="conscientiousness",c("model","lang")]

big544_raw_german[item_index %in% c(4,9,14,19,24,29,34,39),dimension:="neuroticism",c("model","lang")]

big544_raw_german[item_index %in% c(5,10,15,20,25,30,35,40,41,44),dimension:="openness",c("model","lang")]


big544_raw_german_scored <- big544_raw_german[,.(dimension_score=mean(max_response)),c("model","lang","dimension")]

big544_raw_german_scored_wide <- dcast(big544_raw_german_scored,model+lang ~ dimension,value.var="dimension_score")



# compare BIG 5 10 items and BIG 5 44 items
par(mar=c(0,0,2.5,0),mfrow=c(1,3))

# right order in the plots
varnames=c("openness","neuroticism","agreeableness","extraversion","conscientiousness")

# minimum and maximum
# update, correct order
minmaxdt <- data.table(rbind(rep(5.0,5),rep(1.0,5)))

colnames(minmaxdt) <- varnames

big544_models_german <- big544_raw_german_scored[lang=="de",unique(model)]

big544_models_german_short <- c("XLMRoBERTa","multilingualDeBERTa","GBERT")

for(x in 1:length(big544_models_german)){
  
  pldt <- rbind(minmaxdt,big544_raw_german_scored_wide[lang=="de" & model==big544_models_german[x],.(openness,neuroticism,agreeableness,extraversion,conscientiousness)])

  create_beautiful_radarchart(pldt,vlcex=1.5)
  
  title(paste(big544_models_german_short[x], "(de)"),adj = 0.5, line = 1,cex.main=2)
}



# Gender

gender_raw <- fread("answerdf_gender.tsv",header = T)

gender_raw[,max_response:=max.col(.SD),.SDcols=paste(1:7)]

# dimensions in sj-docx-1-gpi-10.1177_1368430220987595.docx
# https://journals.sagepub.com/doi/suppl/10.1177/1368430220987595/suppl_file/sj-docx-1-gpi-10.1177_1368430220987595.docx
# unequal number of items? almost all for first one

gender_raw[item_index %in% 1:14,dimension:="Affirmation",c("model","lang")]

gender_raw[item_index %in% c(15,16),dimension:="Gender Normativity",c("model","lang")]

gender_raw[item_index %in% c(17,18,19),dimension:="Uniformity",c("model","lang")]

gender_raw[item_index %in% c(20,21),dimension:="Surgery",c("model","lang")]

gender_raw[item_index %in% c(22,23),dimension:="Upbringing",c("model","lang")]


gender_raw_scored <- gender_raw[,.(dimension_score=mean(max_response)),c("model","lang","dimension")]

# for radar plots
gender_raw_scored_wide <- dcast(gender_raw_scored,model+lang ~ dimension,value.var="dimension_score")

# right order in the plots
varnames=c("Affirmation","Gender Normativity","Uniformity","Surgery","Upbringing")

# minimum and maximum
minmaxdt <- data.table(rbind(rep(7,5),rep(1,5)))

colnames(minmaxdt) <- varnames

gender_models <- gender_raw_scored_wide[lang=="en",unique(model)]

par(mar=c(0,0,2.5,0),mfrow=c(2,3))

for(x in 1:length(big544_models)){
  
  pldt <- rbind(minmaxdt,gender_raw_scored_wide[lang=="en" & model==big544_models[x],.SD,.SDcols=varnames])
  
  create_beautiful_radarchart(pldt,vlcex=1.5)
  
  title(paste(big544_models_short[x]),adj = 0.5, line = 1,cex.main=2)
}

# old export settings
# portrait
# 10x8
# gender_models.pdf


# dark tetraed

# scoring rules in
# 44_items_big5/BFI-Scoring.doc

darktetra_raw <- fread("answerdf_darktetrad.tsv",header = T)

# do with argmax per model
darktetra_raw[,max_response:=max.col(.SD),.SDcols=paste(1:5)]

# those to be reversed
darktetra_raw[item_index %in% c(8,9,20,24,28,32,44),max_response:=6-max_response]

# assign to domains
# each of them 12
# NARCISSISM
# MACHIAVELLIANISM
# PSYCHOPATHY
# SADISM

darktetra_raw[item_index %in% 1:12,dimension:="narcissism",c("model","lang")]

darktetra_raw[item_index %in% 13:24,dimension:="machiavellianism",c("model","lang")]

darktetra_raw[item_index %in% 25:36,dimension:="psychopathy",c("model","lang")]

darktetra_raw[item_index %in% 36:48,dimension:="sadism",c("model","lang")]

# values

darktetra_raw_scored <- darktetra_raw[,.(dimension_score=mean(max_response)),c("model","lang","dimension")]

# for radar plots
darktetra_raw_scored_wide <- dcast(darktetra_raw_scored,model+lang ~ dimension,value.var="dimension_score")

# right order in the plots
varnames=c("narcissism","machiavellianism","psychopathy","sadism")

# minimum and maximum
minmaxdt <- data.table(rbind(rep(5,4),rep(1,4)))

colnames(minmaxdt) <- varnames

darktetra_models <- darktetra_raw_scored_wide[lang=="en",unique(model)]


par(mar=c(0,0,2.5,0),mfrow=c(2,3))

for(x in 1:length(big544_models)){
  
  pldt <- rbind(minmaxdt,darktetra_raw_scored_wide[lang=="en" & model==big544_models[x],.SD,.SDcols=varnames])
  
  create_beautiful_radarchart(pldt,vlcex=1.5)
  
  title(paste(big544_models_short[x]),adj = 0.5, line = 1,cex.main=2)
}

# export settings
# portrait
# 10x8
# darktetra_models.pdf

# Values

# male

values_male_raw <- fread("answerdf_values_male.tsv",header = T)

# do with argmax per model
values_male_raw[,max_response:=max.col(.SD),.SDcols=paste(1:6)]

# nothing to be reversed?
# darktetra_raw[item_index %in% c(8,9,20,24,28,32,44),max_response:=6-max_response]

# start with 19 values
# Self-direction Thought    1,23,39  
# Self-direction Action     16,30,56
# Stimulation               10,28,43
# Hedonism                  3,36,46
# Achievement               17,32,48
# Power Dominance           6,29,41
# Power Resources           12,20,44
# Face                      9,24,49
# Security Personal         13,26,53
# Security Societal         2,35,50
# Tradition                 18,33,40  
# Conformity-Rules          15,31,42
# Conformity-Interpersonal  4,22,51
# Humility                  7,38,54
# Universalism-Nature       8,21,45
# Universalism-Concern      5,37,52
# Universalism-Tolerance    14,34,57
# Benevolence-Care         11,25,47
# Benevolence-Dependability 19,27,55

values_male_raw[item_index %in% c(1,23,39),dimension:="Self-direction_Thought",c("model","lang")]

values_male_raw[item_index %in% c(16,30,56),dimension:="Self-direction_Action",c("model","lang")]

values_male_raw[item_index %in% c(10,28,43),dimension:="Stimulation",c("model","lang")]

values_male_raw[item_index %in% c(3,36,46),dimension:="Hedonism",c("model","lang")]

values_male_raw[item_index %in% c(17,32,48),dimension:="Achievement",c("model","lang")]

values_male_raw[item_index %in% c(6,29,41),dimension:="Power_Dominance",c("model","lang")]

values_male_raw[item_index %in% c(12,20,44),dimension:="Power_Resources",c("model","lang")]

values_male_raw[item_index %in% c(9,24,49),dimension:="Face",c("model","lang")]

values_male_raw[item_index %in% c(13,26,53),dimension:="Security_Personal",c("model","lang")]

values_male_raw[item_index %in% c(2,35,50),dimension:="Security_Societal",c("model","lang")]

values_male_raw[item_index %in% c(18,33,40),dimension:="Tradition",c("model","lang")]

values_male_raw[item_index %in% c(15,31,42),dimension:="Conformity-Rules",c("model","lang")]

values_male_raw[item_index %in% c(4,22,51),dimension:="Conformity-Interpersonal",c("model","lang")]

values_male_raw[item_index %in% c(7,38,54),dimension:="Humility",c("model","lang")]

values_male_raw[item_index %in% c(8,21,45),dimension:="Universalism-Nature",c("model","lang")]

values_male_raw[item_index %in% c(5,37,52),dimension:="Universalism-Concern",c("model","lang")]

values_male_raw[item_index %in% c(14,34,57),dimension:="Universalism-Tolerance",c("model","lang")]

values_male_raw[item_index %in% c(11,25,47),dimension:="Benevolence-Care",c("model","lang")]

values_male_raw[item_index %in% c(19,27,55),dimension:="Benevolence-Dependability",c("model","lang")]


# 10 value aggregation

# Scoring Key for 10 Original Values with the PVQ-RR Value Scale
# 
# Self-Direction	      1,23,39,16,30,56	        Security		13,26,53,2,35,50
# Stimulation	      10,28,43		        Conformity	15,31,42,4,22,51
# Hedonism	      3,36,46		        Tradition		18,33,40,7,38,54
# Achievement	      17,32,48		        Benevolence	11,25,47,19,27,55
# Power		      6,29,41,12,20,44	        Universalism	8,21,45,5,37,52,14,34,57

values_male_10 <- fread("answerdf_values_male.tsv",header = T)

# do with argmax per model
values_male_10[,max_response:=max.col(.SD),.SDcols=paste(1:6)]


values_male_10[item_index %in% c(1,23,39,16,30,56),dimension:="Self-Direction",c("model","lang")]

values_male_10[item_index %in% c(10,28,43),dimension:="Stimulation",c("model","lang")]

values_male_10[item_index %in% c(3,36,46),dimension:="Hedonism",c("model","lang")]

values_male_10[item_index %in% c(17,32,48),dimension:="Achievement",c("model","lang")]

values_male_10[item_index %in% c(6,29,41,12,20,44),dimension:="Power",c("model","lang")]

values_male_10[item_index %in% c(13,26,53,2,35,50),dimension:="Security",c("model","lang")]

values_male_10[item_index %in% c(15,31,42,4,22,51),dimension:="Conformity",c("model","lang")]

values_male_10[item_index %in% c(18,33,40,7,38,54),dimension:="Tradition",c("model","lang")]

values_male_10[item_index %in% c(11,25,47,19,27,55),dimension:="Benevolence",c("model","lang")]

values_male_10[item_index %in% c(8,21,45,5,37,52,14,34,57),dimension:="Universalism",c("model","lang")]

# those are not used
# c(9,24,49),dimension:="Face"
# values_male_10[which(is.na(values_male_10$dimension))]

values_male_10 <- values_male_10[!(item_index %in% c(9,24,49))]

values_male_10_scored <- values_male_10[,.(dimension_score=mean(max_response)),c("model","lang","dimension")]

# for radar plots
values_male_10_scored_wide <- dcast(values_male_10_scored,model+lang ~ dimension,value.var="dimension_score")

# right order in the plots
# varnames=unique(values_male_10_scored$dimension)

varnames = rev(c("Universalism","Benevolence","Conformity","Tradition","Security","Power","Achievement","Hedonism","Stimulation","Self-Direction"))

# minimum and maximum
minmaxdt <- data.table(rbind(rep(6,length(varnames)),rep(1,length(varnames))))

colnames(minmaxdt) <- varnames

par(mar=c(0,0,2.5,0),mfrow=c(2,3))

for(x in 1:length(big544_models)){
  
  pldt <- rbind(minmaxdt,values_male_10_scored_wide[lang=="en" & model==big544_models[x],.SD,.SDcols=varnames])
  
  create_beautiful_radarchart(pldt,vlcex=1.5)
  
  title(paste(big544_models_short[x]),adj = 0.5, line = 1,cex.main=2)
}



# can be combined to higher-order values
# Scoring Key for Higher Order Values in the PVQ-RR Value Scale
#
# Self-Transcendence	Combine means for universalism-nature, universalism-concern,
# universalism-tolerance, benevolence-care, and benevolence-
#   dependability
#
# Self-Enhancement 	Combine means for achievement, power dominance and power
# resources
#
# Openness to change	Combine means for self-direction thought, self-direction action,
# stimulation and hedonism
#
# Conservation		Combine means for security-personal, security-societal, tradition,
# conformity-rules, conformity-interpersonal
#
# Humility and Face are best treated as separate values because they are on the borders between self-transcendence and conservation (humility) and of self-enhancement and conservation (face). Structural analyses (MDS) can reveal whether these two values could be added to the higher order values to increase reliability in your samples. Analyses in about 120 samples so far indicate that humility is best combined with self-transcendence in about 60% and with conservation in about 40% of samples. Face is best combined with self-enhancement in 45% and with conservation in 55% of samples.

# values

values_male_raw_scored <- values_male_raw[,.(dimension_score=mean(max_response)),c("model","lang","dimension")]

# for radar plots
values_male_raw_scored_wide <- dcast(values_male_raw_scored,model+lang ~ dimension,value.var="dimension_score")

# right order in the plots
varnames=unique(values_male_raw$dimension)

# minimum and maximum
minmaxdt <- data.table(rbind(rep(6,length(varnames)),rep(1,length(varnames))))

colnames(minmaxdt) <- varnames

values_male_models <- values_male_raw_scored_wide[lang=="en",unique(model)]


op <- par(mar = c(1, 1, 1, 1))
par(mfrow = c(2,3))

for(values_male_model in values_male_models){
  
  pldt <- rbind(minmaxdt,values_male_raw_scored_wide[lang=="en" & model==values_male_model,.SD,.SDcols=varnames])
  
  create_beautiful_radarchart(pldt,title=paste(values_male_model,"(en)"))
}

# export settings
# portrait
# 14x8
# values_male.pdf





# Values

# female

values_female_raw <- fread("answerdf_values_female.tsv",header = T)

# do with argmax per model
values_female_raw[,max_response:=max.col(.SD),.SDcols=paste(1:6)]


values_female_raw[item_index %in% c(1,23,39),dimension:="Self-direction_Thought",c("model","lang")]

values_female_raw[item_index %in% c(16,30,56),dimension:="Self-direction_Action",c("model","lang")]

values_female_raw[item_index %in% c(10,28,43),dimension:="Stimulation",c("model","lang")]

values_female_raw[item_index %in% c(3,36,46),dimension:="Hedonism",c("model","lang")]

values_female_raw[item_index %in% c(17,32,48),dimension:="Achievement",c("model","lang")]

values_female_raw[item_index %in% c(6,29,41),dimension:="Power_Dominance",c("model","lang")]

values_female_raw[item_index %in% c(12,20,44),dimension:="Power_Resources",c("model","lang")]

values_female_raw[item_index %in% c(9,24,49),dimension:="Face",c("model","lang")]

values_female_raw[item_index %in% c(13,26,53),dimension:="Security_Personal",c("model","lang")]

values_female_raw[item_index %in% c(2,35,50),dimension:="Security_Societal",c("model","lang")]

values_female_raw[item_index %in% c(18,33,40),dimension:="Tradition",c("model","lang")]

values_female_raw[item_index %in% c(15,31,42),dimension:="Conformity-Rules",c("model","lang")]

values_female_raw[item_index %in% c(4,22,51),dimension:="Conformity-Interpersonal",c("model","lang")]

values_female_raw[item_index %in% c(7,38,54),dimension:="Humility",c("model","lang")]

values_female_raw[item_index %in% c(8,21,45),dimension:="Universalism-Nature",c("model","lang")]

values_female_raw[item_index %in% c(5,37,52),dimension:="Universalism-Concern",c("model","lang")]

values_female_raw[item_index %in% c(14,34,57),dimension:="Universalism-Tolerance",c("model","lang")]

values_female_raw[item_index %in% c(11,25,47),dimension:="Benevolence-Care",c("model","lang")]

values_female_raw[item_index %in% c(19,27,55),dimension:="Benevolence-Dependability",c("model","lang")]



values_female_raw_scored <- values_female_raw[,.(dimension_score=mean(max_response)),c("model","lang","dimension")]

# for radar plots
values_female_raw_scored_wide <- dcast(values_female_raw_scored,model+lang ~ dimension,value.var="dimension_score")

# right order in the plots
varnames=unique(values_female_raw$dimension)

# minimum and maximum
# reverted!
# minmaxdt <- data.table(rbind(rep(1,length(varnames)),rep(6,length(varnames))))

# corrected
minmaxdt <- data.table(rbind(rep(6,length(varnames)),rep(1,length(varnames))))

colnames(minmaxdt) <- varnames

values_female_models <- values_female_raw_scored_wide[lang=="en",unique(model)]


op <- par(mar = c(1, 1, 1, 1))
par(mfrow = c(2,3))

for(values_female_model in values_female_models){
  
  pldt <- rbind(minmaxdt,values_female_raw_scored_wide[lang=="en" & model==values_female_model,.SD,.SDcols=varnames])
  
  create_beautiful_radarchart(pldt,title=paste(values_female_model,"(en)"))
}

# export settings
# portrait
# 14x8
# values_female.pdf

# 10 values female


values_female_10 <- fread("answerdf_values_female.tsv",header = T)

# do with argmax per model
values_female_10[,max_response:=max.col(.SD),.SDcols=paste(1:6)]


values_female_10[item_index %in% c(1,23,39,16,30,56),dimension:="Self-Direction",c("model","lang")]

values_female_10[item_index %in% c(10,28,43),dimension:="Stimulation",c("model","lang")]

values_female_10[item_index %in% c(3,36,46),dimension:="Hedonism",c("model","lang")]

values_female_10[item_index %in% c(17,32,48),dimension:="Achievement",c("model","lang")]

values_female_10[item_index %in% c(6,29,41,12,20,44),dimension:="Power",c("model","lang")]

values_female_10[item_index %in% c(13,26,53,2,35,50),dimension:="Security",c("model","lang")]

values_female_10[item_index %in% c(15,31,42,4,22,51),dimension:="Conformity",c("model","lang")]

values_female_10[item_index %in% c(18,33,40,7,38,54),dimension:="Tradition",c("model","lang")]

values_female_10[item_index %in% c(11,25,47,19,27,55),dimension:="Benevolence",c("model","lang")]

values_female_10[item_index %in% c(8,21,45,5,37,52,14,34,57),dimension:="Universalism",c("model","lang")]

# those are not used
# c(9,24,49),dimension:="Face"
# values_female_10[which(is.na(values_female_10$dimension))]

values_female_10 <- values_female_10[!(item_index %in% c(9,24,49))]

values_female_10_scored <- values_female_10[,.(dimension_score=mean(max_response)),c("model","lang","dimension")]

# for radar plots
values_female_10_scored_wide <- dcast(values_female_10_scored,model+lang ~ dimension,value.var="dimension_score")





values_female_raw_scored_wide[,gender:='f']

values_male_raw_scored_wide[,gender:='m']

minmaxdt[,gender:=c('max','min')]


values_both_models <- rbind(values_female_raw_scored_wide,values_male_raw_scored_wide)


par(mar = c(1,4,1,0),oma=c(2,0,0,2))
par(mfrow = c(2,3))

for(values_female_model in values_female_models){
  
  pldt <- rbind(minmaxdt,values_both_models[lang=="en" & model==values_female_model,.SD,.SDcols=c(varnames,'gender')])
  
  rownames(pldt) <- pldt$gender
  
  pldt[,gender:=NULL]
  
  # axis labels only if needed
  # create_beautiful_radarchart(pldt,title=paste(values_female_model,"(en)"),caxislabels = 2:6)
  
  create_beautiful_radarchart(pldt,title=paste(values_female_model,"(en)"),color = c("#E7B800", "#FC4E07"))

  # Add an horizontal legend
  # inset=c(-0.2,0),
  
}

par(fig = c(0, 1, 0, 1), oma = c(0, 0, 0, 0), mar = c(0, 0, 0, 0), new = TRUE)

legend(
  x = "bottom",  legend = rownames(pldt)[c(3,4)], horiz = T,
  bty = "n", pch = 20 , col = c("#E7B800", "#FC4E07"),
  text.col = "black", cex = 1, pt.cex = 1.5,inset=c(0,.08)
)

# export settings
# portrait
# 14x8
# values_both.pdf



# 10 values both

values_female_10_scored_wide[,gender:='f']

values_male_10_scored_wide[,gender:='m']

varnames = rev(c("Universalism","Benevolence","Conformity","Tradition","Security","Power","Achievement","Hedonism","Stimulation","Self-Direction"))

minmaxdt <- data.table(rbind(rep(6,length(varnames)),rep(1,length(varnames))))

colnames(minmaxdt) <- varnames

minmaxdt[,gender:=c('max','min')]

values_both_10_models <- rbind(values_female_10_scored_wide,values_male_10_scored_wide)



dev.off()

par(mar = c(0,0,2.5,0),oma=c(2,0,0,0))
par(mfrow = c(2,3))

for(x in 1:length(big544_models)){
  
  pldt <- rbind(minmaxdt,values_both_10_models[lang=="en" & model==big544_models[x],.SD,.SDcols=c(varnames,'gender')])
  
  rownames(pldt) <- pldt$gender
  
  pldt[,gender:=NULL]
  
  # axis labels only if needed
  # create_beautiful_radarchart(pldt,title=paste(values_female_model,"(en)"),caxislabels = 2:6)
  
  # create_beautiful_radarchart(pldt,color = c("#E7B800", "#FC4E07"),vlcex=1.5)
  
  create_beautiful_radarchart(pldt,color = c("#D95F02", "#7570B3"),vlcex=1.5)
  
  title(paste(big544_models_short[x]),adj = 0.5, line = 1,cex.main=2)
  
  # Add an horizontal legend
  # inset=c(-0.2,0),
  
}

par(fig = c(0, 1, 0, 1), oma = c(0, 0, 0, 0), mar = c(0, 0, 0, 0), new = TRUE)

legend(
  x = 1.25, y= 0.5,  legend = rownames(pldt)[c(3,4)], horiz = F, pch = 20 , col = c("#D95F02", "#7570B3"),
  text.col = "black",cex=3,bty = "n",pt.cex=7.5,y.intersp=0.45,x.intersp=0.3
)

# values_both.pdf
# 14 x 8


# moral foundations

# scoring
# To score the MFQ yourself, you can copy your answers into the grid below. Then add up the 6 numbers in each of the five columns and write each total in the box at the bottom of the column. The box then shows your score on each of 5 psychological “foundations” of morality. Scores run from 0-30 for each foundation. (Questions 6 and 22 are just used to catch people who are not paying attention. They don't count toward your scores).

# The average politically moderate American’s scores are: 20.2, 20.5, 16.0, 16.5, and 12.6. 
# Liberals generally score a bit higher than that on Harm/care and Fairness/reciprocity, and much lower than that on the other three foundations. Conservatives generally show the opposite pattern. 

mf <- rbindlist(lapply(list("answerdf_mf_1.tsv","answerdf_mf_2.tsv"),fread))

# do with argmax per model
mf[,max_response:=max.col(.SD),.SDcols=paste(0:5)]


mf[item_index %in% c(1,7,12,17,23,28),dimension:="harm-care",c("model","lang")]

mf[item_index %in% c(2,8,13,18,24,29),dimension:="fairness-reciprocity",c("model","lang")]

mf[item_index %in% c(3,9,14,19,25,30),dimension:="in-group-loyalty",c("model","lang")]

mf[item_index %in% c(4,10,15,20,26,31),dimension:="authority-respect",c("model","lang")]

mf[item_index %in% c(5,11,16,21,27,32),dimension:="purity-sanctity",c("model","lang")]

mf[item_index %in% c(5,11,16,21,27,32),dimension:="purity-sanctity",c("model","lang")]


mf_filtered <- mf[!(item_index %in% c(6,22))]

# this time the sum
mf_filtered_scored <- mf_filtered[,.(dimension_score=sum(max_response)),c("model","lang","dimension")]

# for radar plots
mf_filtered_scored_wide <- dcast(mf_filtered_scored,model+lang ~ dimension,value.var="dimension_score")

# right order in the plots
varnames=unique(mf_filtered$dimension)

# range(mf_filtered_scored_wide$`purity-sanctity`)

# minimum and maximum
# was it switched? first maximum, then minimum?
minmaxdt <- data.table(rbind(rep(30,length(varnames)),rep(0,length(varnames))))

colnames(minmaxdt) <- varnames

mf_filtered_models <- mf_filtered_scored_wide[lang=="en",unique(model)]


par(mar=c(0,0,2.5,0),mfrow=c(2,3))

for(x in 1:length(big544_models)){
  
  pldt <- rbind(minmaxdt,mf_filtered_scored_wide[lang=="en" & model==big544_models[x],.SD,.SDcols=varnames])
  
  create_beautiful_radarchart(pldt,vlcex=1.5)
  
  title(paste(big544_models_short[x]),adj = 0.5, line = 1,cex.main=2)
}

# export settings
# portrait
# 14x8
# mf.pdf

# The average politically moderate American’s scores are: 20.2, 20.5, 16.0, 16.5, and 12.6.
# add average

par(mar=c(0,0,2.5,0),mfrow=c(2,3))

for(x in 1:length(big544_models)){
  
  values_with_average <- rbind(mf_filtered_scored_wide[lang=="en" & model==big544_models[x],.SD,.SDcols=varnames],as.data.table(matrix(c(20.2, 20.5, 16.0, 16.5, 12.6),byrow=T,ncol=5,dimnames=list(NULL,varnames))))
  
  pldt <- rbind(minmaxdt,values_with_average)
  
  create_beautiful_radarchart(pldt,vlcex=1.5,color = c("#E7B800", "#FC4E07"),bty='L')
  
  title(paste(big544_models_short[x]),adj = 0.5, line = 1,cex.main=2)
}

# export settings
# portrait
# 14x8
# mf_withaverage.pdf

# tune visualization
# from https://www.datanovia.com/en/blog/beautiful-radar-chart-in-r-using-fmsb-and-ggplot-packages/

create_beautiful_radarchart <- function(data, color = "#00AFBB", 
                                        vlabels = colnames(data), vlcex = 0.7,
                                        caxislabels = NULL, title = NULL, ...){
  radarchart(
    data,
    # change axistype to 1 to display value range on plot
    axistype = 0,
    # Customize the polygon
    pcol = color,
    pfcol = scales::alpha(color, 0.5),
    plwd = 2,
    plty = 1,
    # Customize the grid
    cglcol = "grey",
    cglty = 1,
    cglwd = 0.8,
    # Customize the axis
    axislabcol = "grey", 
    # Variable labels
    vlcex = vlcex,
    vlabels = vlabels,
    caxislabels = caxislabels,
    title = title, ...
  )
}


# if we want to plot more than one subgraphic

# Reduce plot margin using par()
# op <- par(mar = c(1, 2, 2, 2))

# Create the radar charts
# create_beautiful_radarchart(
#   data = df, caxislabels = c(0, 5, 10, 15, 20),
#   color = c("#00AFBB", "#E7B800", "#FC4E07")
# )

# Add an horizontal legend
# legend(
#   x = "bottom", legend = rownames(df[-c(1,2),]), horiz = TRUE,
#   bty = "n", pch = 20 , col = c("#00AFBB", "#E7B800", "#FC4E07"),
#   text.col = "black", cex = 1, pt.cex = 1.5
# )
# par(op)
