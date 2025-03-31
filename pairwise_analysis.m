
fname='sameOmega_s1';
fps=5;

load(['dat_' fname])
load(['dat_phaseOmega_' fname])

% load dat_vid1111_samespin_10fps_18_212
% load dat_phaseOmegavid1111_samespin_10fps_18_212

Nt=length(Xmat);

%%

omega1=omegaMat(1,:);
omega2=omegaMat(2,:);

% % use this option if you need to smooth noisy omega
% omega1p=smooth(movmedian(omega1,[11 11]),9);
% omega2p=smooth(movmedian(omega2,[21 21]),11);

omega1p=smooth(omega1,5);
omega2p=smooth(omega2,5);

figure()
% plot(omega1)
hold on
% plot(omega2)

plot(omega1p)
plot(omega2p)



%%

x1=Xmat(1,:); y1=Ymat(1,:); % x and y of bot 1
x2=Xmat(2,:); y2=Ymat(2,:); % x and y of bot 2

dist=sqrt((x1-x2).^2+(y1-y2).^2); % this calculates interparticle distance
figure()
plot(dist)

figure()
plot(x1,y1,'LineWidth',2)
hold on
plot(x2,y2,'LineWidth',2)
axis equal

%%
smfac=25;
r1=[smooth(x1,smfac)'; smooth(y1,smfac)'];
r2=[smooth(x2,smfac)'; smooth(y2,smfac)'];

figure()
plot(x1)
hold on
plot(smooth(x1,smfac))

r12_hat=(r2-r1)./vecnorm(r2-r1,2); %unit vector pointing from r1 to r2
r21_hat=(r1-r2)./vecnorm(r1-r2,2); %unit vector pointing from r2 to r1

figure()
subplot(1,2,1)
plot(vecnorm(r1-r2))
subplot(1,2,2)
plot(vecnorm(r2-r1))
%%
orbitalPhase = atan2(r12_hat(2,:),r12_hat(1,:)); %orbital rotation phase angle

figure()
plot(orbitalPhase)

%%

v1=r1(:,2:end)-r1(:,1:end-1);
v2=r2(:,2:end)-r2(:,1:end-1);

figure()
plot(vecnorm(v1),'LineWidth',2)
hold on
plot(vecnorm(v2),'LineWidth',2)
xlabel('Time (frame)')
ylabel('Velocity, tot')

%%
v1_par=([1;1]*dot(v1,r12_hat(:,1:end-1))).*r12_hat(:,1:end-1); % component of v1 parallel to line connecting r1 to r2
v1_perp=v1-v1_par; % perpendicular/transverse component of v1
v2_par=([1;1]*dot(v2,r21_hat(:,1:end-1))).*r21_hat(:,1:end-1); % component of v1 parallel to line connecting r2 to r1
v2_perp=v2-v2_par; % perpendicular/transverse component of v2

tmax=Nt;

fac=20;

% vid = VideoWriter([fname '.mp4'],'MPEG-4');
% vid.FrameRate = 20;
% open(vid);

figure('Position',[100 100 800 600])
set(gcf,'color','w')
for t=10:10:Nt
    subplot(4,2,[1 3])
    plot(r1(1,:),r1(2,:),'LineWidth',1,'Color',[1 0.5 0.5 0.5])
    hold on
    plot(r2(1,:),r2(2,:),'LineWidth',1,'Color',[0.5 0.5 1 0.5])
    ylim([0 700])


    xlim([0 700])


    plot(r1(1,t),r1(2,t),'bo','MarkerSize',30)
    plot(r2(1,t),r2(2,t),'ro','MarkerSize',30)
    plot([r1(1,t) r2(1,t)],[r1(2,t) r2(2,t)],'k')

    % quiver(r1(1,t),r1(2,t),r12_hat(1,t)*fac,r12_hat(2,t)*fac,'k','AutoScale','off','LineWidth',1)
    % quiver(r2(1,t),r2(2,t),r21_hat(1,t)*fac,r21_hat(2,t)*fac,'k','AutoScale','off','LineWidth',1)

    % quiver(r1(1,t),r1(2,t),v1(1,t)*fac,v1(2,t)*fac,'b','AutoScale','off','LineWidth',1.5)
    % quiver(r2(1,t),r2(2,t),v2(1,t)*fac,v2(2,t)*fac,'r','AutoScale','off','LineWidth',1.5)


    plotperp=1;
    plotpar=1;
    if plotperp==1
        quiver(r1(1,t),r1(2,t),v1_perp(1,t)*fac,v1_perp(2,t)*fac,'b','AutoScale','off','LineWidth',1,'MaxHeadSize',5)
        quiver(r2(1,t),r2(2,t),v2_perp(1,t)*fac,v2_perp(2,t)*fac,'r','AutoScale','off','LineWidth',1,'MaxHeadSize',5)
    end

    if plotpar==1
        quiver(r1(1,t),r1(2,t),v1_par(1,t)*fac,v1_par(2,t)*fac,'b','AutoScale','off','LineWidth',1,'MaxHeadSize',5)
        quiver(r2(1,t),r2(2,t),v2_par(1,t)*fac,v2_par(2,t)*fac,'r','AutoScale','off','LineWidth',1,'MaxHeadSize',5)
    end
    title([fname ' time=' num2str(t)])

    subplot(4,2,5)
    plot(dist)
    hold on
    plot(t,dist(t),'ko')
    xlabel('Time (frame)')
    ylabel('Interbot distance')
    xlim([0 tmax])


    subplot(4,2,2)
    plot(vecnorm(v1_par),'LineWidth',1)
    hold on
    plot(vecnorm(v2_par),'LineWidth',1)
    plot(t,vecnorm(v1_par(:,t)),'ko','LineWidth',2)
    hold on
    plot(t,vecnorm(v2_par(:,t)),'ko','LineWidth',2)
    xlabel('Time (frame)')
    ylabel('Velocity, radial')
    legend({'Bot1','Bot2'})
    xlim([0 tmax])

    subplot(4,2,4)
    plot(vecnorm(v1_perp),'LineWidth',1)
    hold on
    plot(vecnorm(v2_perp),'LineWidth',1)
    plot(t,vecnorm(v1_perp(:,t)),'ko','LineWidth',2)
    hold on
    plot(t,vecnorm(v2_perp(:,t)),'ko','LineWidth',2)
    xlabel('Time (frame)')
    ylabel('Velocity, transverse')
    xlim([0 tmax])

    subplot(4,2,6)
    hold on
    plot(omega1p,'LineWidth',1)
    plot(omega2p,'LineWidth',1)
    plot(t,omega1p(t),'ko','LineWidth',2)
    plot(t,omega2p(t),'ko','LineWidth',2)
    xlabel('Time (frame)')
    ylabel('Spinning frequency')
    box on
    xlim([0 tmax])

    subplot(4,2,7)
    plot(orbitalPhase/pi*180)
    hold on
    plot(t,orbitalPhase(t)/pi*180,'ko','LineWidth',2)
    xlabel('Time (frame)')
    ylabel('Orbital phase (^o)')
    ylim([-180 180])
    box on
    xlim([0 tmax])
    
    subplot(4,2,8)
    omegaOrbital=getOmega(orbitalPhase/pi*180)*fps;
    plot(omegaOrbital)

    pause()
    clf

    % frame = getframe(gcf);
    % writeVideo(vid,frame);
    % clf

end
% close(vid)





