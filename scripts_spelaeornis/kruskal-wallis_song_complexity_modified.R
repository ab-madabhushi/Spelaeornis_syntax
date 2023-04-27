library(tidyverse)
library(ggpubr)
library(rstatix)

#reading the file with song complexity data grouped according to species
songcomplexity=read.csv("D:\\Abhinav\\spelaeornis project\\song complexity.csv", header=TRUE)
songcomplexity=as.data.frame(songcomplexity)

songcomplexity<- songcomplexity %>%
  reorder_levels(groups, order = c("S.caudatus", "S.badeigularis","S. troglodytoides", "S. chocolatinus","S. reptatus","S. oatesi","S. kinneari","S. longicaudatus"))

songcomplexity%>%  
  group_by(groups) %>%
  get_summary_stats(song.complexity, type = "common")

p1 <- ggboxplot(songcomplexity, x = "groups", y = "song.complexity", fill="groups")

res.kruskal <- songcomplexity %>% kruskal_test(song.complexity ~ groups)
songcomplexity %>% kruskal_effsize(song.complexity~ groups)

res1<- dunn_test(data=songcomplexity,formula=song.complexity ~ groups, p.adjust.method = "bonferroni")
#res1


#I just asked it to compute y values for the significance lines thingy manually
#coz I couldn't figure out how add_xy_positions works
p2 <- ggboxplot(songcomplexity, x = "groups", y = "song.complexity",fill = 'groups') +
  stat_pvalue_manual(res1, hide.ns = TRUE,y.position=0.8,step.increase = 0.1) +
  labs(
    subtitle = get_test_label(res.kruskal, detailed = TRUE),
    caption = get_pwc_label(res1)) + theme(legend.position = 'None')
