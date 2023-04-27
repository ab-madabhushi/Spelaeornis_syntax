The sequences folder contains sequences of _Spelaeornis_. 
Files named as **notegroup seq** consists of notegroup sequences and files named as **note seq** consists of note type sequences.
_Spelaeornis Project- Note Sharing data.csv_ contains the note parameter data for all the species in addition to the note type and note group classification. The coloumns _Note group_new_ and _Note type_new_ correspond to the **final** classifications.
PCA was conducted on the correlation matrix of note parameter data to construct the signal space of _Spelaeornis_ (using pcacorr.m function- see scripts_spelaeornis folder).
_song complexity.csv_ consists of song complexity data for all the species. This data was used to make the box plot in figure 2 and to conduct the Kruskal Wallis test.
_KL divergence.csv_ contains the pairwise divergence values of Kullback Leibler Homogeneity test. Figure for this in supplementary. The code **FOMC_transition_probabilities_KL_divergence.R** was used to compute these values (see _scripts_spelaeornis_ folder). The input for this function is _notegroup sequences_ (see sequences folder).
_Spelaeornis pariwise distance_new.csv_ contains pairwise median Levenshtein distances between the notegroup sequences of _Spelaeornis_. This was used to construct the UPGMA distance tree.
