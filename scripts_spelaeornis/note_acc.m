dat= readtable("Spelaeornis Project - tb note group.csv")

%dat=table2array(dat)

notelist=dat(:,end);
notelist=table2array(notelist);
note_rand=notelist(randperm(length(notelist)));
notetype=unique(notelist);
zeroes=zeros(length(notelist),1);
%%
for i= 1:length(notetype)
    for j=1:length(note_rand)
        if note_rand{j}== notetype{i}

            zeroes(j)=1;
            break
        end
    end
end
%%
note_acc=cumsum(zeroes);
x=[1:length(notelist)]';
myfit=[]
myfit=fittype('a*(x^b)',...
'dependent',{'y'},'independent',{'x'},...
'coefficients',{'a','b'})
fit_dat=[]
gof=[]
[fit_dat,gof]=fit(x,note_acc, myfit,'start',[0 0]);
%%
xint = linspace(min(x),max(x),2000);
CIF = predint(fit_dat,xint,0.95,'Functional');
CIO = predint(fit_dat,xint,0.95,'obs');
figure();
plot(fit_dat)

hold on
plot(xint,CIF,':g','LineWidth',1) 
legend()
plot(xint,CIO,':m','Linewidth',1)
%legend(['95% CI for estimate','95% CI for prediction'])
str=['R^2 =',num2str(gof.rsquare),newline,...
'y = ',num2str(fit_dat.a),'* x',num2str(fit_dat.b)]
annotation('textbox',[.15 .9 0 0],'string',str,'FitBoxToText','on')
%%
plot(x,note_acc,'.-', 'MarkerSize',8,'Color','b');
xlabel('Number of notes analysed')
ylabel("Number of new notes")
title('{\it S.longicaudatus} note group accumulation curve')