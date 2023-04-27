############################
# Generate transition probability matrices and run stats on them
# This script is for Spalaeornis note group sequence data collated by Abhinav
# Part of Jagan et al. 2022 
# Written by Shikhara Bhat
# IISER Pune, India
# Date: Fri Dec 24 17:07:03 2021
###########################
library(stringr)
library(tidyr)

#gen_trans_prob generates pairwise transtion probabilities between of different note types

gen_trans_prob=function(df,global_note_num=9){
  
  #make a list of the complete state space possible
  global_statespace <- c(letters[1:7],'k','l')
  
  #initialize with small pseudocounts to avoid zeroes
  pseudocount = 0.0001
  avg_matrix=matrix(rep(pseudocount,(global_note_num)**2), nrow=global_note_num,ncol=global_note_num)
  marginalproblist=rep(pseudocount,global_note_num)
  
  # marginal probability of occurrence
  #we are summing n_{ij} over all j to find this
  #to account for edge effects, this is better than just calculating number
  #of times that notetype i occurred
  for (i in 1:global_note_num){
    note=global_statespace[i]
    marginalprob=0
    
    #calculate n_{i.}, i.e n_{ij} summed over all j
    for (j in 1:global_note_num){
      note_2=global_statespace[j]
      marginalprob <- marginalprob + sum(str_count(df$note.sequence,pattern=paste(as.character(note),as.character(note_2),sep='')))
    } 
    #add to list
    marginalproblist[i] <- marginalproblist[i] + marginalprob
  }
  
  # transition probabilities
  # we want to calculate n_{ij} for each i and j
  # we can then divide by the marginal probabilities obtained above
  # to obtain the MLE for the transition probabilities
  for (i in 1:nrow(df)){
    
    #extract a focal sequence from the list
    seq=df$note.sequence[i]
    
    #find which notes are present in the sequence
    local_statespace = (unique(unlist(str_split(seq,pattern=''))))
    
    #calculate n_{ij}
    for (j in 1:length(local_statespace)){
      note1=local_statespace[j]
      for (k in 1:length(global_statespace)){
        if (local_statespace[j]==global_statespace[k]){
          marginalprob=marginalproblist[k]
          note_index=k
            for (l in 1:length(local_statespace)){
              note2=local_statespace[l]
              for (m in 1:length(global_statespace)){
                if (note2== global_statespace[m]){
                  note_index2=m
                  t_km <- sum((str_count(seq,pattern = paste(as.character(note1),as.character(note2),sep='')))/marginalprob)
                  avg_matrix[note_index,note_index2] <- avg_matrix[note_index,note_index2] + t_km
                }
              }
            }
        }
      }
    }
  }
  
  rownames <- rep('a',global_note_num)
  colnames <- rep('b',global_note_num)
  for (i in 1:global_note_num){
    rownames[i] <- paste('t',as.character(global_statespace[i]),'_',sep='')
    colnames[i] <- paste('t','_',as.character(global_statespace[i]),sep='')
  }
  
  rownames(avg_matrix) <- rownames
  colnames(avg_matrix) <- colnames
  
  #Return marginal probabilities, transition matrix, total number of notes sampled
  return (list('pi'=marginalproblist/sum(marginalproblist),'T'=avg_matrix,'n'=round(sum(marginalproblist))))
}

# determining start and end states
start_end_states=function(df){
  df$note.sequence=sub("(.{1})(.*)",'0\\1\\20',df$note.sequence)
  return(df)
}

#######################################################
#Stats
#The below function runs a homogeneity test based on the m.d.i.s
#Reference:
#Kullback et al. 1962 - Tests for contingency tables and Markov chains
#This is the same test used in Bhat et al. 2021
kullback_homogeneity_test <- function(MC_list){
  
  # MC_list contains outputs of the gen_trans_prob function
  # H0: all processes have the same underlying transition matrices
  # Refer to section 9 and table 9.1 of Kullback et.al. 1962
  
  species_list <- names(MC_list)
  
  
  s <- length(species_list) #number of categories
  r <- nrow(MC_list[[species_list[1]]][['T']]) #size of state space
  
  #make lists for calculating quantities
  f <- list() #f_{ijk}
  fij. <- list() #f_{ij.}
  #print(fij.)
  f.jk <- matrix(rep(0,r**2),nrow=r,ncol=r) #f_{.jk}
  f.j. <- rep(0,r) #f_{.j.}
  
  #calculate f_{ijk} and f_{ij.}
  for (i in 1:s){
    sp <- species_list[i]
    MC <- MC_list[[sp]]
    T_freq <- MC[['T']]
    T_num <- T_freq*MC[['n']]
    for (j in 1:r){
      for (k in 1:r){
        #add a small pseudocount if the value is zero
        T_num[j,k] <- round(T_num[j,k]*MC[['pi']][j]) + as.numeric((round(T_num[j,k]*MC[['pi']][j]) == 0))*0.001
        }
    }
    #append to lists
    f[[i]] <- T_num
    fij.[[i]] <- round(MC[['n']]*MC[['pi']]) + as.numeric((round(MC[['n']]*MC[['pi']])==0))*0.001
  }
    
    #calculate f_{.jk} and f_{.j.}
    for (j in 1:r){
      f.j._sum <- 0 #initialize f_{.j.} at 0
      for (k in 1:r){
        f.jk_sum <- 0 #initialize f_{.jk} at 0
        for (i in 1:s){ #loop through all i to compute f_{.jk} for fixed j and k
          f.jk_sum <- f.jk_sum + f[[i]][j,k]
        }
        f.jk[j,k] <- f.jk_sum #add to list
        f.j._sum <- f.j._sum + f.jk_sum #add to f_{.j.} for fixed j (this loop is over k)
      }
      f.j.[j] <- f.j._sum #add to list
    }
    
    #Calculate the test statistic
    
    statistic <- 0 
    
    #The statistic is that corresponding to 'conditional homogeneity' in table 9.1
    for (i in 1:s){
      for (j in 1:r){
        for (k in 1:r){
          log_term_num <- f[[i]][j,k]
          log_term_den <- (fij.[[i]][j]*f.jk[j,k])/(f.j.[j])
          log_term <- log_term_num/log_term_den
          
          #I use -phi because phi is defined as -log (and we want log here)
          statistic <- statistic + f[[i]][j,k]*(log(log_term))
        }
      }
    }
    
    statistic <- 2*statistic
    
    # This test statistic is asymptotically chi-square with df = r(r-1)(s-1)
    df = r*(r-1)*(s-1)
    
    #We can estimate the corresponding p-value using the pchisq function
    #lower.tail = False lets you look for values as extreme or more extreme than
    #the specified value, i.e Pr(X >= statistic)
    #By definition, this is the p-value
    
    p_value = pchisq(statistic,df=df,lower.tail = FALSE)
    
    return(list('statistic'=statistic,'df'=df,'p_value'=p_value))
}

#To run stats, simply call the above and supply the two lists 
#that are outputs of gen_trans_prob as arguments. 

#Ex: for the homogeneity test between 2  sequence data sets df1 and df2, simply 
#execute the following:
#MC_1 <- gen_trans_prob(df1)
#MC_2 <- gen_trans_prob(df2)
#kullback_homogeneity_test(MC_1,MC_2)

###########################################################################
#Running the tests

#path to CSV files containing notegroup sequences
csv_path <- 'D:\\Abhinav\\spelaeornis project\\noteshare seq\\'

#list of all CSVs
files <- list.files(csv_path,pattern='.csv')

#Make lists in which to store outputs
MC_list = list()

#loop through files in directory to get all MC objects
for (file in files){
  
  #extract the species name from the filename
  species <- unlist(strsplit(file,split = '- '))[2]
  species <- unlist(strsplit(species,split=' '))[1]
  
  #import the data and prepare it for analysis
  filepath <- paste(csv_path,file,sep='')
  df <- read.csv(filepath)
  
  #Get the MC object and store to list
  MC_list[[species]] <- gen_trans_prob(df)
}

###########################

#run the test
stats <- kullback_homogeneity_test(MC_list)

###########################
#make pairwise stats comparisons (commented out for now)

pairwise_stats = list()

#generate all possible unique combinations using combn
all_combs <- combn(names(MC_list),2)

#loop through these combinations and perform the test on each pair
for (i in 1:ncol(all_combs)){
      sp1 <- all_combs[1,i]
      sp2 <- all_combs[2,i]
      compare <- paste(sp1,'vs',sp2,sep = ' ')
      pairwise_stats[[compare]] <- 
        kullback_homogeneity_test(list('sp1'=MC_list[[sp1]],'sp2'=MC_list[[sp2]]))
}


