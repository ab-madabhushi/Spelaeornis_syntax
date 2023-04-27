function scoreplotter3d(score,group,vbls)
    %get unique group labels 
    uniqueGroups = unique(group); 
    x = score(:,1);
    y = score(:,2);
    z = score(:,3);
    % RGB values of your favorite colors: 
    colors = brewermap(length(uniqueGroups),'Set1'); 
    % Initialize some axes
    view(3)
    grid on
    hold on
    % Plot each group individually: 
    for k = 1:length(uniqueGroups)
          % Get indices of this particular unique group:
          ind = group==uniqueGroups(k); 
          % Plot only this group: 
          h=plot3(x(ind),y(ind),z(ind),'.','color',colors(k,:),'markersize',20);
          
    end
    %legend(vbls)
    xlabel('PC1'), ylabel('PC2'), zlabel('PC3')
    set(h, "FontSize", 30,'FontWeight', 'bold')
    
    hold off
end