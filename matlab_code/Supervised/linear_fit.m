addpath('../MatlabTools/')

tmp = matlab.desktop.editor.getActive;
cd(fileparts(tmp.Filename));

cost = 0.001;
voc1 = zeros(s,1);
voc2 = zeros(s,1);
vpi = zeros(s,1);
voc30 = zeros(s,1);
bias = ones(s,1);
stde=@(st) st(1)*st(2)/((st(1)+st(2))^2+(st(1)+st(2)+1));
stds = zeros(s,1);
to = zeros(s,1);
b = zeros(s,1);
for i=1:s
    st = S(i,:);
%     
%     stds(i) = stde(st);
%     
%     to(i) = sum(st);
%     
%     b(i) = max(st)/sum(st);
%     
%     t = st(1)+ st(2);   
%     mvoc = 1/(t*(t+1))*(st(1)*max(st(1)+1,st(2)) + st(2)*max(st(1),st(2)+1));
%     voc1(i) = mvoc-max(st)/sum(st)-cost;

    voc2(i) = nvoc(3,st,cost);
    
%     vpi(i) = 1 - max(st)/sum(st);
    vpi(i) = valueOfPerfectInformationBernoulli(st(1),st(2));
    
    voc30(i) = nvoc(33-sum(st),st,cost);
end
% X = cat(2,voc2,bias);
% X = cat(2,vpi,voc1,bias)
X = cat(2,vpi,voc2,bias); feature_names={'VPI','VOC_2','1'};
[w,wint,r,rint,stats] = regress(voc30,X);
voc_hat=X*w;
figure();
scatter(voc_hat,voc30);
title(num2str(stats(1)));

sign_disagreement=find(sign(voc_hat).*sign(voc30)==-1)
numel(sign_disagreement)/numel(voc30)

max(voc30(sign_disagreement))

E_guess=max(S(1:end-1,:),[],2)./sum(S(1:end-1,:),2);


%% Plot fit to Q-function

Q_hat(:,1)=voc_hat+E_guess;
Q_hat(:,2)=E_guess;
V_hat=max(Q_hat,[],2);

valid_states=and(sum(S,2)<=30,sum(S,2)>0);

Q_star=getQFromV(values(:,1),P,R);
R2=corr(Q_star(valid_states,1),Q_hat(valid_states))^2;

fig_Q=figure()
scatter(Q_hat(valid_states),Q_star(valid_states,1))
set(gca,'FontSize',16)
xlabel(modelEquation(feature_names,w),'FontSize',16)
ylabel('$Q^\star$','FontSize',16,'Interpreter','LaTeX')
title(['Linear Fit to Q-function of 1-lightbulb meta-MDP, R^2=',num2str(R2)],'FontSize',16)
saveas(fig_Q,'../../results/figures/QFitToyProblem.fig')
saveas(fig_Q,'../../results/figures/QFitToyProblem.png')

load ../../results/lightbulb_problem
lightbulb_problem.mdp=lightbulb_mdp;
lightbulb_problem.fit.w=w;
lightbulb_problem.fit.Q_star=Q_star;
lightbulb_problem.fit.Q_hat=Q_hat;
lightbulb_problem.fit.R2=R2;
lightbulb_problem.fit.feature_names=feature_names;
lightbulb_problem.fit.features=X;
lightbulb_problem.optimal_PR=lightbulb_problem.mdp.optimal_PR;

save('../../results/lightbulb_fit.mat','lightbulb_problem')