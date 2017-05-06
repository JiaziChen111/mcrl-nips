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
X = cat(2,vpi,voc2,bias);
[w,wint,r,rint,stats] = regress(voc30,X);
voc_hat=X*w;
figure();
scatter(voc_hat,voc30);
title(num2str(stats(1)));

sign_disagreement=find(sign(voc_hat).*sign(voc30)==-1)
numel(sign_disagreement)/numel(voc30)

figure()
hist(voc30(sign_disagreement))
max(voc30(sign_disagreement))

E_guess=max(S(1:end-1,:),[],2)./sum(S(1:end-1,:),2);

Q_hat(:,1)=voc_hat+E_guess;
Q_hat(:,2)=E_guess;
V_hat=max(Q_hat,[],2);


valid_states=and(sum(S,2)<=30,sum(S,2)>0);

Q_star=getQFromV(values(:,1),P,R)
R2=corr(Q_star(valid_states,1),Q_hat(valid_states))^2

fig=figure()
scatter(Q_hat(valid_states),Q_star(valid_states,1))
set(gca,'FontSize',16)
xlabel('$\sum_i w_i*f_i$','FontSize',16,'Interpreter','LaTex')
ylabel('$Q^\star$','FontSize',16,'Interpreter','LaTeX')
title(['Linear Fit to Q-function of 1-lightbulb meta-MDP, R^2=',num2str(R2)],'FontSize',16)
