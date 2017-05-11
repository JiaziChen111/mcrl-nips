function solve_MouselabMDP_SAVIO(c)

addpath('/global/home/users/flieder/matlab_code/MatlabTools/')
%create meta-level MDP

add_pseudorewards=false;
pseudoreward_type='none';

mean_payoff=4.5;
std_payoff=10.6;

load('/global/home/users/flieder/matlab_code/MouselabMDPExperiment_normalized')

actions_by_state{1}=[];
actions_by_state{2}=[1];
actions_by_state{3}=[2];
actions_by_state{4}=[3];
actions_by_state{5}=[4];
actions_by_state{6}=[1,1];
actions_by_state{7}=[2,2];
actions_by_state{8}=[3,3];
actions_by_state{9}=[4,4];
actions_by_state{10}=[1,1,2];
actions_by_state{11}=[1,1,4];
actions_by_state{12}=[2,2,3];
actions_by_state{13}=[2,2,4];
actions_by_state{14}=[3,3,2];
actions_by_state{15}=[3,3,4];
actions_by_state{16}=[4,4,3];
actions_by_state{17}=[4,4,1];
for e=1:numel(experiment)
    experiment(e).actions_by_state=actions_by_state;
    experiment(e).hallway_states=2:9;
    experiment(e).leafs=10:17;
    experiment(e).parent_by_state=[1,1,1,1,1,2,3,4,5,6,6,7,7,8,8,9,9];
end

meta_MDP=MouselabMDPMetaMDPNIPS(add_pseudorewards,pseudoreward_type,mean_payoff,std_payoff,experiment);
meta_MDP.cost_per_click=c;

mu0=[1;1;1];
nr_features=numel(mu0);
sigma0=0.1;
glm0=BayesianGLM(nr_features,sigma0);
glm0.mu_n=mu0(:);

feature_extractor=@(s,c,meta_MDP) meta_MDP.extractStateActionFeatures(s,c);

%load MouselabMDPMetaMDPTestFeb-17-2017

nr_training_episodes=2000;
nr_reps=1;
first_episode=1; last_rep=nr_training_episodes;
for rep=1:nr_reps
    glm(rep)=glm0;
    tic()
    [glm(rep),MSE(first_episode:nr_training_episodes,rep),...
        returns(first_episode:nr_training_episodes,rep)]=BayesianSARSAQ(...
        meta_MDP,feature_extractor,nr_training_episodes-first_episode+1,glm(rep));
    disp(['Repetition ',int2str(rep),' took ',int2str(round(toc()/60)),' minutes.'])
end

clear avg_returns, clear sem_avg_return, clear avg_RMSE, clear sem_RMSE
bin_width=20;
for r=1:nr_reps
    [avg_returns(:,r),sem_avg_return(:,r)]=binnedAverage(returns(:,r),bin_width);
    [avg_RMSE(:,r),sem_RMSE(:,r)]=binnedAverage(sqrt(MSE(:,r)),bin_width);
end
best_run=argmax(avg_returns(end,:));

avg_MSE=mean(MSE(:,best_run),2);

R_total=mean(returns(:,best_run),2);

nr_episodes=size(R_total,1);
bin_width=50;
episode_nrs=bin_width:bin_width:nr_episodes;
[avg_RMSE,sem_RMSE]=binnedAverage(sqrt(avg_MSE),bin_width);
[avg_R,sem_R]=binnedAverage(R_total,bin_width);

%{
figure()
subplot(2,1,1)
errorbar(episode_nrs,avg_R,sem_R,'g-o','LineWidth',2), hold on
set(gca,'FontSize',16)
xlabel('Episode','FontSize',16)
ylabel('R_{total}','FontSize',16),
title('Semi-gradient SARSA (Q) in Mouselab Task','FontSize',18)
%ylim([0,10])
xlim([0,nr_episodes+5])
%hold on
%plot(smooth(R_total,100),'r-')
%legend('RMSE','R_{total}')
xlabel('#Episodes','FontSize',16)
subplot(2,1,2)
errorbar(episode_nrs,avg_RMSE,sem_RMSE,'g-o','LineWidth',2), hold on
xlim([0,nr_episodes+5])
set(gca,'FontSize',16)
xlabel('Episode','FontSize',16)
ylabel('RMSE','FontSize',16),
%legend('with PR','without PR')
%hold on
%plot(smooth(R_total,100),'r-')
%legend('RMSE','R_{total}')
xlabel('#Episodes','FontSize',16)
%}
feature_names=meta_MDP.feature_names;

weights=[glm(1:nr_reps).mu_n];
%{
figure()
bar(weights),
%bar(w)
%ylim([0,0.3])
set(gca,'XTick',1:numel(feature_names),'XTickLabel',feature_names)
set(gca,'XTickLabelRotation',45,'FontSize',16)
ylabel('Learned Weights','FontSize',16)
title(['Bayesian SARSA without PR, ',int2str(nr_episodes),' episodes'],'FontSize',18)
%}
nr_episodes_evaluation=2000;
meta_MDP.object_level_MDP=meta_MDP.object_level_MDPs(1);
policy=@(state,mdp) contextualThompsonSampling(state,meta_MDP,glm(best_run))
[R_total_evaluation,problems_evaluation,states_evaluation,chosen_actions_evaluation,indices_evaluation]=...
    inspectPolicyGeneral(meta_MDP,policy,nr_episodes_evaluation)

reward_learned_policy=[mean(R_total_evaluation),sem(R_total_evaluation)];
nr_observations_learned_policy=[mean(indices_evaluation.nr_acquisitions),...
    sem(indices_evaluation.nr_acquisitions(:))];

result.policy=policy;
result.reward=reward_learned_policy;
result.weights=weights;
result.features={'VPI','VOC','E[R|act,b]'};
result.nr_observations=nr_observations_learned_policy;
result.returns=R_total_evaluation;
result.cost_per_click=c;

do_save=true;
if do_save
    save(['/global/home/users/flieder/results/MouselabMDPFitBayesianSARSA',...
        int2str(round(100*c)),'.mat'],'result')
end
%% benchmark policy: observing everything before the first move


add_pseudorewards=false;
pseudoreward_type='none';

mean_payoff=4.5;
std_payoff=10.6;

load('/global/home/users/flieder/matlab_code/MatlabTools/MouselabMDPExperiment_normalized')

meta_MDP=MouselabMDPMetaMDPNIPS(add_pseudorewards,pseudoreward_type,mean_payoff,std_payoff,experiment);
meta_mdp.cost_per_click=c;

policy=@(state,mdp) fullObservationPolicy(state,mdp)

nr_episodes_evaluation=2000;
[R_total,problems,states,chosen_actions,indices]=...
    inspectPolicyGeneral(meta_MDP,policy,nr_episodes_evaluation)

reward_full_observation_policy=[mean(R_total),sem(R_total)];
nr_observations_full_observation_policy=...
    [mean(indices.nr_acquisitions),sem(indices.nr_acquisitions(:))];

full_observation_benchmark.policy=policy;
full_observation_benchmark.reward=reward_full_observation_policy;
full_observation_benchmark.nr_observations=nr_observations_full_observation_policy;
full_observation_benchmark.returns=R_total;
full_observation_benchmark.cost_per_click=c;

save(['/global/home/users/flieder/results/','full_observation_benchmark',...
    int2str(round(100*c)),'.mat'],'full_observation_benchmark')

%% comparison of learned policy against full-observation policy
load('/global/home/users/flieder/matlab_code/MatlabTools/results/full_observation_benchmark')
load('/global/home/users/flieder/matlab_code/MatlabTools//results/MouselabMDPFitBayesianSARSA')

[result.reward;full_observation_benchmark.reward]

t=(result.reward(1)-full_observation_benchmark.reward(1))/...
    sqrt(result.reward(2)^2+full_observation_benchmark.reward(2)^2);

p=1-normcdf(t)

%The policy learned by Bayesian SARSA algorithm achieved a significantly
%higher average return than the full-observation policy ($36.73 \pm 0.09$ vs. 
%36.41 \pm 0.09 points per trial, Z=2.66, p=0.004$).
end