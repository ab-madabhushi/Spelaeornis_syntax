%% Reading data files 
seq_data=readtable("Spelaeornis Project - tb note seq data.csv");
note_seq=seq_data.noteSequence;
noteseq=string(note_seq);


%% Song complexity metric
ind_no=seq_data.UnitNo;

song_lengthtb=[];
no_notestb=[];

for i=1:length(noteseq)
    c=split(noteseq(i),"");
    no_notestb(i)=length(unique(c))-1;
    song_lengthtb(i)=length(c)-2;
    
end
song_complexitytb=no_notestb./song_lengthtb;
song_complexitytb=song_complexitytb';
song_no=unique(ind_no);
i=0;
for i=1:length(song_no)
    ind=ind_no==song_no(i);
    song_comsub=(song_complexitytb(ind));
    avg_songtb(i)=mean(song_comsub);
end       %% Calculate song complexity metric for each species through the above code and save construct one vector with all species like below

%% 
song_complexity=[avg_songrft,avg_songrt,avg_songbw,avg_songng,avg_songgb,avg_songch,avg_songpt,avg_songtb];

groups=[zeros(1,length(avg_songrft')),ones(1,length(avg_songrt')),2*ones(1,length(avg_songbw')),3*ones(1,length(avg_songng')),4*ones(1,length(avg_songgb')),5*ones(1,length(avg_songch')),6*ones(1,length(avg_songpt')),7*ones(1,length(avg_songtb'))];
%% 
csvwrite('song_complexity raw.csv',song_comfile)

%% UPGMA Distance tree code

%% Interspecific levenshtein distance with notegroups

sp_1=readtable('Spelaeornis Project - ch noteshare seq.csv');
sp_2=readtable('Spelaeornis Project - pt noteshare seq.csv');
sp1_seq=sp_1.noteSequence;
sp1_seq=string(sp1_seq);
sp2_seq=sp_2.noteSequence;
sp2_seq=string(sp2_seq);

% levenshtein distance
levensh_pair=[];
for i=1:length(sp1_seq)
    for j=1:length(sp2_seq)
        levensh_pair(i,j)=editDistance(sp1_seq(i),sp2_seq(j));
    end
end
sp_dist=median(levensh_pair,[1,2])
sp_iqr=iqr(levensh_pair,[1,2]) %% calculate pair-wise median levenshtein distance for each species and enter the value in the matrix below.
%% building tree showing evolution of song sequences

dist_matrix(8,7)=13 %% change i j th entry as per species 


%% Saving distance matrix
dist_matrix=array2table(dist_matrix)
writetable(dist_matrix, 'Spelaeornis pairwise distance_new.csv')
%% Tree
species={'S. caudatus', 'S. badeigularis','S. troglodytoides','S. chocolatinus','S. reptatus','S. oatesi','S. kinneari','S. longicaudatus'}
phyltree=seqlinkage(dist_matrix,'UPGMA',species)

h=plot(phyltree,'orient','left')
xlabel("Song Sequence Similarity")
title('UPGMA Distance tree for song sequences in \it Spelaeornis')

