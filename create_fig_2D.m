% function create_fig_2D
%
% This function creates Figure 2D of the paper:
%
%   *********************************************************************
%   * Van den Berg, R. & Ma, W.J. (2018). A resource-rational theory of *
%   *   set size effects in human visual working memory. Elife.         *
%   *********************************************************************
%
% Written by Ronald van den Berg, 2018

function create_fig_2D

% model parameters for simulations
lambda = .01; 
beta   = 2;

% precompute lookup table for mapping between kappa and J
kappa_map   = [linspace(0,10,2500) linspace(10.001,5000,1000)];
J_map       = kappa_map.*besseli(1,kappa_map,1)./besseli(0,kappa_map,1);

% experimental parameters for simulations
p_i_vec = [1/8, 1/4, 1/2, 1];

% open figure
figure
set(gcf,'Position',get(gcf,'Position').*[0.1 0.1 1.8 .6]);
hold on

%-%-%-%-%-%-%-%
% Left panel  %
%-%-%-%-%-%-%-%
subplot(1,3,1);
Jbar_vec = linspace(.1,20,1000);
for jj=1:numel(Jbar_vec)    
    % convert Jbar (resource) to kappa (concentration parameter of corresponding Von Mises noise distribution)
    kappa = interp1(J_map,kappa_map,Jbar_vec(jj),'linear','extrap');    
    % discretize Von Mises to numerically evaluate the intergral over epsilon
    [VM_x, VM_y] = discretize_VM(kappa);    
    % compute expected cost terms
    C_behavioral = abs(VM_x).^beta;  % memory error loss
    Cbar_behavioral(jj) = mean(sum(bsxfun(@times,VM_y,C_behavioral),2)); % expected behavioral cost per item
    Cbar_neural(jj) = Jbar_vec(jj); % expected neural cost per item
end
cols = [1 0 0; 0 .8 0; 0 0 1; 1 0 1; 0 .5 1; 0 0 0; .5 .5 0; 0 .5 .5];
hold on
for ii=1:numel(p_i_vec)
    plot(Jbar_vec,p_i_vec(ii).*Cbar_behavioral,'color',cols(ii,:));
end
plot(Jbar_vec,lambda*Cbar_neural(1,:),'k','linewidth',2);
ylim([0 0.25])
set(gca,'Ytick',[]);
xlabel('Jbar');
ylabel('Expected cost per item (a.u.)');
xlim([0 16]);
box off

%-%-%-%-%-%-%-%-%
% Cental panel  %
%-%-%-%-%-%-%-%-%
subplot(1,3,2);
hold on
for ii=1:numel(p_i_vec)
    Cbar_total = p_i_vec(ii)*Cbar_behavioral + lambda*Cbar_neural; % expected total cost
    plot(Jbar_vec,Cbar_total,'color',cols(ii,:),'linewidth',1.5);
    plot(Jbar_vec,Cbar_total,'k--','linewidth',1);
    Jopt(ii) = Jbar_vec(Cbar_total==min(Cbar_total));
    plot([Jopt(ii) Jopt(ii)],[0 min(Cbar_total)],'k:','color',cols(ii,:));    
end
ylim([0 0.25])
set(gca,'Ytick',[]);
xlabel('Jbar');
xlim([0 16]);
box off

%-%-%-%-%-%-%-%
% Right panel %
%-%-%-%-%-%-%-%
subplot(1,3,3);
hold on
p_i_vec_finer = linspace(0,1,100);
for ii=1:numel(p_i_vec_finer)
    Cbar_total = p_i_vec_finer(ii)*Cbar_behavioral + lambda*Cbar_neural; % expected total cost
    J_opt_finer(ii) = Jbar_vec(Cbar_total==min(Cbar_total));
end
plot(p_i_vec_finer,J_opt_finer,'k-');
for ii=1:numel(p_i_vec)
    plot(p_i_vec(ii),Jopt(ii),'ko','markerfacecolor',cols(ii,:))
end
set(gca,'TickDir','out','TickLength',get(gca,'TickLength')*2,'Ytick',0:3:12,'Xtick',0:.2:1)
ylim([0 12])
xlim([0 1]);
xlabel('p_i');
ylabel('Jbar_{optimal}');
box off
fprintf('Jbar_optimal = %2.1f, %2.1f, %2.1f, %2.1f\n',Jopt)

% Discretize VM distributions into equally-spaced bins (1 distribution per element in kappa vector)
function [VM_x, VM_y] = discretize_VM(kappa)
VM_x = linspace(-pi,pi,101);
VM_x = VM_x(2:end)-diff(VM_x(1:2))/2;
VM_y = exp(bsxfun(@times,kappa',cos(VM_x)));
VM_y = bsxfun(@rdivide,VM_y,sum(VM_y,2));
