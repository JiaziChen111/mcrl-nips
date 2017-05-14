function [T,R,states]=oneArmedMouselabMDP(nr_hallway_cells,nr_branches,nr_leafs_per_branch,mu_reward,sigma_reward,cost)

nr_leafs = nr_branches*nr_leafs_per_branch;
nr_cells = nr_hallway_cells + nr_leafs;

sigma0=sqrt(nr_cells)*sigma_reward;
mu_other=mu_reward*nr_cells;

resolution=sigma0/50;
mu_values=(mu_reward-2*sigma0):resolution:(mu_reward+2*sigma0);
sigma_values=sigma_reward*(0:nr_cells);
[MUs,SIGMAs]=meshgrid(mu_values,sigma_values);

observation_indices = 0:(power(2,nr_cells)-1);
nr_observation_indices = numel(observation_indices);

states.mu=repmat(MUs,[1,1,nr_observation_indices]);
states.sigma=repmat(SIGMAs,[1,1,nr_observation_indices]);
for id=1:numel(nr_observation_indices)
    states.observation_id(:,:,id)=observation_indices(id)*ones(size(MUs));
end

%state = (obs_id, delta_mu, sigma_mu)
nr_states=numel(MUs)*2^nr_cells+1; %each combination of mu and sigma is a state and there is one additional terminal state
nr_actions=nr_cells+1; %action 0 = act, action i: observe cell i

state_nr =@(observation_vector,mu,sigma) numel(MUs)*bi2de(observation_vector)+...
    find(and( MUs(:)==mu,SIGMAs(:)==sigma));

%b) define transition matrix
T=zeros(nr_states,nr_states,nr_actions);
R=zeros(nr_states,nr_states,nr_actions);

R(:,:,2:nr_actions)=-cost; %cost of sampling

for from=1:(nr_states-1)
    
    current_mu=states.mu(from);
    current_sigma=states.sigma(from);
    
    if current_sigma>0 %there is still something to be observed
        sample_values=(mu_reward-3*current_sigma):resolution:(mu_reward+3*current_sigma);
        p_samples=discreteNormalPMF(sample_values,mu_reward,current_sigma);
        
        %In this case, the prior is the likelihood. Hence, both have the
        %same precision. Therefore, the posterior mean is the average of
        %the prior mean and the observation, and the posterior precision is
        %twice as high as the current precision.
        
        posterior_means  = (current_mu + sample_values - mu_reward );
        posterior_sigmas = sqrt(current_sigma^2-sigma_reward^2)*ones(size(posterior_means));
        
        [discrepancy_mu, mu_index] = min(abs(repmat(posterior_means,[numel(mu_values),1])-...
            repmat(mu_values',[1,numel(posterior_means)])));
        
        [discrepancy_sigma, sigma_index] = min(abs(repmat(posterior_sigmas,[numel(sigma_values),1])-...
            repmat(sigma_values',[1,numel(posterior_sigmas)])));
        
        to=struct('mu',mu_values(mu_index),'sigma',sigma_values(sigma_index),...
            'index',sub2ind([numel(sigma_values),numel(mu_values)],sigma_index,mu_index));
        
        %sum the probabilities of all samples that lead to the same state
        T(from,unique(to.index),1)=grpstats(p_samples,to.index,{@sum});
        
    else
        T(from,:,2:end)=repmat([zeros(1,nr_states-1),1],[1,1,nr_actions-1]);
    end
    
    %reward of acting
    R(from,nr_states,2)=max(mu_other,current_mu);
end
T(:,:,2)=repmat([zeros(1,nr_states-1),1],[nr_states,1]);
T(end,:,:)=repmat([zeros(1,nr_states-1),1],[1,1,2]);

start_state.index=sub2ind(size(MUs),find(sigma_values==start_state.sigma),...
    find(mu_values==start_state.delta_mu));

states.MUs=MUs;
states.SIGMAs=SIGMAs;
states.start_state=start_state;
states.mu_values=mu_values;
states.sigma_values=sigma_values;
end