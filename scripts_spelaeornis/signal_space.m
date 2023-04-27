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
%csvwrite('pc_score.csv',score,0,0)
%csvwrite('pc_loadings.csv',coeff,0,0)
%csvwrite('pc_percentage.csv',expl,0,0)
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
CaptureFigVid([-20,10;-110,10;-190,80;-290,10;-380,10],'signal_space 3d1_test',OptionZ);



%% Randomization Test
% Expected Distributions
sp_id=s_data(:,end);
i=1
n=1000
avgdist_exp=NaN(n,1);
sp=unique(sp_id);
sp_avgdist=NaN(n,8);
for i=1:n
    rows=size(sp_id,1);
    row_new=randperm(rows);
    sp_rand=sp_id(row_new,:);
    intsp_dist=NaN(8,8);
    for j= 1:length(sp)-1
        ind=sp_rand==sp(j);
        score_sub=score(ind,:);
        for m=j+1:length(sp)
            ind2=sp_rand==sp(m);
            score_sub2=score(ind2,:);
            intsp_dist(j,m)=mean(pdist2(score_sub(:,1:3),score_sub2(:,1:3)),"all");
        end
        sp_avgdist(i,j)=nanmean(intsp_dist(j,:));  
    end
    avgdist_exp(i)=nanmean(sp_avgdist(i,:))


end

%% Observed
j=1
m=1
obs_avgdist=[];
intob_dist=NaN(8,8)
for j= 1:length(sp)-1
        ind=sp_id==sp(j);
        score_sub=score(ind,:);
        for m=j+1:length(sp)
            ind2=sp_id==sp(m);
            score_sub2=score(ind2,:);
            intob_dist(j,m)=mean(pdist2(score_sub(:,1:3),score_sub2(:,1:3)),["all"]);
        end
        obs_avgdist=nanmean(intob_dist(j,:));

end

%% Z score and Z test

mean_dist= mean(avgdist_exp);
std_dist=std(avgdist_exp);

z_score= (obs_avgdist-mean_dist)/std_dist;

[h,p,ci,zval]=ztest(obs_avgdist,mean_dist,std_dist)
