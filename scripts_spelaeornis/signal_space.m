%% read data files with average song parameters

s_data=readtable("Spelaeornis Project - Note sharing data.csv");
sp_name=table2array(s_data(:,1));
s_data=table2array(s_data(:,10:end));

%% PCA 
song_data=s_data(:,1:end-4);

[coeff, score, latent, expl] = pcacorr(song_data);

%plotting PC components
clf;
scoreplotter3d(score, s_data(:,end), {'Spelaeornis caudatus', 'Spelaeornis badeigularis', 'Spelaeornis troglodytoides','Spelaeornis chocolatinus', 'Spelaeornis reptatus', 'Spelaeornis oatesi','Spelaeornis kinneari','Spelaeornis longicaudatus'});
%for i =1:length(score)
    %text(score(i,1),score(i,2),score(i,3),num2str(sp_name(i)));
%end
hold off;
%% Writing to files
csvwrite('pc_score.csv',score,0,0)
csvwrite('pc_loadings.csv',coeff,0,0)
csvwrite('pc_percentage.csv',expl,0,0)
%% 2d visualisation
%2d visualisation
figure();
colors = brewermap(8,'Set1');
gscatter(score(:,1),score(:,2),s_data(:,end),colors,".",20);
grid on; legend({'Spelaeornis caudatus', 'Spelaeornis badeigularis', 'Spelaeornis troglodytoides','Spelaeornis chocolatinus', 'Spelaeornis reptatus', 'Spelaeornis oatesi','Spelaeornis kinneari','Spelaeornis longicaudatus'});
%for i=1:length(score)
    %text(score(i,1),score(i,2),num2str(sp_name(i)));
%end
    

xlabel('PC1'); ylabel('PC2');

%% Video
%making a video of a 3D PC space for visualizing overlap better
clf; figure(1);
scoreplotter3d(score, s_data(:,end), {'Spelaeornis caudatus', 'Spelaeornis badeigularis', 'Spelaeornis troglodytoides','Spelaeornis chocolatinus', 'Spelaeornis reptatus', 'Spelaeornis oatesi','Spelaeornis kinneari','Spelaeornis longicaudatus'});
xlim([-8 6])
ylim([-4 6])
zlim([-4 4])
%change figure limits to suit visualization
OptionZ.FrameRate=7;OptionZ.Duration=14;OptionZ.Periodic=true;
CaptureFigVid([-20,10;-110,10;-190,80;-290,10;-380,10],'signal_space 3d1',OptionZ);