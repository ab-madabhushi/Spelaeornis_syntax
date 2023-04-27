% Double-Blind 

%% Read files

data_real=readtable("Double Blind analysis - Sheet1.csv");
data_anand=readtable("Double Blind new - Sheet1.csv");

seq_real=data_real.NoteGroupSequence;
%data_anand=data_anand(15:end);
seq_anand=data_anand.NoteGroupSequence;


seqreal=string(seq_real);
seqanand=string(seq_anand);

%% error

song_length=[]
for i=1:length(seqreal)
    song_length(i)=length(char(seqreal(i)));
end

error=[];
for i=1:length(seqreal)
    error(i)=editDistance(seqreal(i),seqanand(i));
end

error_percent=(error./song_length)*100;

mean_error=mean(error_percent)