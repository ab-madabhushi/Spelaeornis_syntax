library(stringr)
library(tidyr)
#gen_trans_prob generates pariwise transtion probabilities between of different note types

gen_trans_prob=function(df){
  seq=df$note.sequence
  notetype=(unique(unlist(str_split(seq,pattern=''))))
  num=length(notetype)
  avg_matrix=matrix(rep(0,(num)**2), nrow=num,ncol=num)
  marginalproblist=rep(0,num)
  
  # probability of occurence
  for (i in 1:num){
    note=notetype[i]
    marginalprob=0
    for (j in 1:num){
      note_2=notetype[j]
      marginalprob <- marginalprob + sum(str_count(df$note.sequence,pattern=paste(as.character(note),as.character(note_2),sep='')))
    } 
    marginalproblist[i]=marginalprob
  }
  print(marginalproblist)
  # transition probability
  for (i in 1:nrow(df)){
    seq=df$note.sequence[i]
    statespace = (unique(unlist(str_split(seq,pattern=''))))
    for (j in 1:length(statespace)){
      note1=statespace[j]
      for (k in 1:length(notetype)){
        if (statespace[j]==notetype[k]){
          marginalprob=marginalproblist[k]
          ind=k
          if (marginalprob==0){
            next
          }
          else{
            for (l in 1:length(statespace)){
              note2=statespace[l]
              for (m in 1:length(notetype)){
                if (note2== notetype[m]){
                  ind2=m
                  t_km <- sum((str_count(seq,pattern = paste(as.character(note1),as.character(note2),sep='')))/marginalprob)
                  print(t_km)
                  avg_matrix[ind,ind2] <- avg_matrix[ind,ind2] + t_km
                  }
                }
              }
            }
          }
        }
      }
    }
      
  rownames <- rep('a',num)
  colnames <- rep('b',num)
  for (i in 1:num){
    rownames[i] <- paste('t',as.character(notetype[i]),'_',sep='')
    colnames[i] <- paste('t','_',as.character(notetype[i]),sep='')
    }
  
  rownames(avg_matrix) <- rownames
  colnames(avg_matrix) <- colnames
  return (avg_matrix)
}

# determining start and end states
start_end_states=function(df){
  df$note.sequence=sub("(.{1})(.*)",'0\\1\\20',df$note.sequence)
  return(df)
}
# reshaping noteseq output
# Subsampling to prevent over representation by few recordings
sub_sample=function(df){
  num_ind=unique(df$Unit.no)
  ss_min=min(tabulate(df$Unit.no,nbins=length(num_ind)))
  print(ss_min)
  note_new=c()
  note_newsub=c()
  for (i in 1:length(num_ind)){
    ind=df$Unit.no==num_ind[i]
    noteseq=as.data.frame(df$note.sequence[ind])
    noteseq=t(noteseq)
    print(noteseq)
    noteseq_sub=(sample(noteseq,size=ss_min,replace=T))
    print(noteseq_sub)
    for (i in 1:length(noteseq_sub)){
      note_new=rbind(note_new,noteseq_sub[i])
      print(note_new)
    }
    #note_new=rbind(note_new,note_newsub)
  }
  
  print(note_new)
  print(length(note_new[,1]))
  df_new=data.frame()
  df_new=data.frame(matrix(NA,nrow=length(note_new[,1]),ncol=length(colnames(df))))
  colnames(df_new)=colnames(df)
  df_new$note.sequence=(note_new)
  return(df_new)
}
# Using the function above to calculate transition probabilities

setwd("/media/abhinav/New Volume/thesis/spelaeornis project")

df=read.csv('Spelaeornis Project - tb noteshare seq.csv',header=TRUE)
trans_problist=vector(mode="list")
df_new=start_end_states(df)
trans_prob=gen_trans_prob(df_new)

avg_transprob=Reduce("+",trans_problist)/length(trans_problist)

## saving transition probabilities
write.csv(trans_prob,'tb noteshare trans prob_new.csv')
