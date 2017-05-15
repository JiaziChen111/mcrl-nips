%% Import data from text file.
% Script for importing data from the following text file:
%
%    /Users/Falk/Dropbox/PhD/Metacognitive RL/mcrl-experiment/data/1/human/A/graph.csv
%
% To extend the code to different selected data or a different text file,
% generate a function instead of a script.

% Auto-generated by MATLAB on 2017/02/17 16:56:38

%% Initialize variables.
if strcmp(getenv('USER'),'paulkrueger')
    rootpath = '~/Desktop/Tom_Griffiths/';  
else
    rootpath = '~/Dropbox/PhD/Metacognitive RL/';
end
path=[rootpath,'mcrl-experiment/data/1/human/',experiment_version];
rawpath=[rootpath,'mcrl-experiment/data/1/human_raw/',experiment_version];
filename = [path,'/graph.csv'];
delimiter = ',';
startRow = 2;

%% Format string for each line of text:
%   column1: double (%f)
%	column2: text (%q)
%   column3: text (%q)
%	column4: text (%q)
%   column5: text (%q)
%	column6: double (%f)
%   column7: double (%f)
%	column8: text (%q)
%   column9: text (%q)
%	column10: double (%f)
%   column11: double (%f)
%	column12: double (%f)
%   column13: double (%f)
%	column14: text (%q)
%   column15: text (%q)
%	column16: text (%q)
%   column17: double (%f)
% For more information, see the TEXTSCAN documentation.

if strcmp(experiment_version,'B')
    formatSpec = '%f%q%q%q%q%f%f%q%q%f%f%f%f%q%q%q%f%[^\n\r]';
else
    formatSpec = '%f%q%q%q%q%q%q%f%f%q%q%f%f%f%f%q%q%q%f%[^\n\r]';
end

%% Open the text file.
fileID = fopen(filename,'r');

%% Read columns of data according to format string.
% This call is based on the structure of the file used to generate this
% code. If an error occurs for a different file, try regenerating the code
% from the Import Tool.
dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter, 'HeaderLines' ,startRow-1, 'ReturnOnError', false);

if strcmp(experiment_version,'B')
    dataArray = {dataArray{1:5},cell(size(dataArray{1})),cell(size(dataArray{1})),dataArray{6:end}};
end

%% Close the text file.
fclose(fileID);

%% Post processing for unimportable data.
% No unimportable data rules were applied during the import, so no post
% processing code is included. To generate code which works for
% unimportable data, select unimportable cells in a file and regenerate the
% script.

%% Allocate imported array to column variable names
nr_trials = length(unique(dataArray{:, 14}));
pid = dataArray{:, 19};
finished_idx = true(size(pid));
% index participants who didn't complete the HIT
for i = 1:length(unique(pid))
    idx = pid==i-1;
    if sum(idx) ~= nr_trials
        finished_idx(idx) = false;
    end
end
pid = pid(finished_idx);
VarName1 = dataArray{1}(finished_idx);
actionTimes = dataArray{2}(finished_idx);
actions = dataArray{3}(finished_idx);
clickTimes = dataArray{4}(finished_idx);
clicks = dataArray{5}(finished_idx);
condition = dataArray{6}(finished_idx);
delays = dataArray{7}(finished_idx);
infoCost = dataArray{8}(finished_idx);
minTime = dataArray{9}(finished_idx);
path1 = dataArray{10}(finished_idx);
rt = dataArray{11}(finished_idx);
score = dataArray{12}(finished_idx);
time_elapsed = dataArray{13}(finished_idx);
trialID = dataArray{14}(finished_idx);
trialIndex = dataArray{15}(finished_idx);
trial_type = dataArray{16}(finished_idx);
worker_id = dataArray{17}(finished_idx);
assignment_id = dataArray{18}(finished_idx);

%% Clear temporary variables
clearvars filename delimiter startRow formatSpec fileID dataArray ans;

%% 
action_numbers=containers.Map();
action_numbers('right')=1;
action_numbers('up')=2;
action_numbers('left')=3;
action_numbers('down')=4;

action_strings=actions;
clear actions

click_strings=clicks;
clear clicks nr_clicks

for i=1:numel(action_strings)
    string=action_strings{i};
    click_strings{i}(click_strings{i}=='u') = [];
    string(string=='u') = [];
    idx = find(string=='p');
    for j = 1:length(idx)
        pos=idx(j)+j-1;
        %string = insertBefore(string,idx(j)+j-1,'u');
        string = [string(1:pos-1),'u',string(pos:end)];
    end
    string=strrep(string,'''right''',num2str(action_numbers('right')));
    string=strrep(string,'''up''',num2str(action_numbers('up')));
    string=strrep(string,'''left''',num2str(action_numbers('left')));
    string=strrep(string,'''down''',num2str(action_numbers('down')));
    
    actions(i,:)=str2num(string);
    eval(['clicks{i}=',strrep(click_strings{i},'''',''),';']);
    
    nr_clicks(i)=numel(clicks{i});
    inspected_all_states(i)=isequal(sort(clicks{i}),2:17);
end

action_time_strings=actionTimes;
clear actionTimes
for i=1:numel(action_time_strings)
    eval(['action_times(i,:)=',strrep(action_time_strings{i},'''',''),';'])    
end

%% put data into one convenient data structure

nr_moves = size(action_times,2);
switch experiment_version
    case 'B'
        load('data/trial_properties.mat')
    case 'C'
        load('data/trial_properties_March1.mat')
    case 'D'
        load('data/trial_properties_control_experiment.mat')
    otherwise
        try
            load(['data/trial_properties_',experiment_version,'.mat'])
        catch
            error('Please specifiy the correct trial_properties file')
        end
end
if strcmp(experiment_version,'B')
    nr_states = 17;
else
    nr_states = length(trial_properties(1).reward_by_state);
end
    nr_subj = length(unique(pid));
s = 0;
for i = unique(pid)'
    s = s + 1;
    idx = pid == i;
    data(s).actions = actions(idx);
    data(s).clicks = clicks(idx);
    data(s).score = score(idx);
    data(s).trialID = trialID(idx);
    if ~strcmp(experiment_version,'B')
        data(s).condition = str2num(cell2mat(condition(find(idx,1,'first'))));
    end
    data(s).experiment_runtime = time_elapsed(find(idx,1,'last'))/1000/60;
    cur_actionTimes = action_times(idx,:);
    cur_clickTimes = clickTimes(idx);
    cur_paths = path1(idx);
    cur_delays = delays(idx);
    for j = 1:nr_trials
        cur_clicks = data(s).clicks{j};
        data(s).path(j,1:nr_moves+1) = str2num(cur_paths{j});
        cur_trial = data(s).trialID(j)+1;
        R = data(s).score(j);
        R_min = trial_properties(cur_trial).R_min;
        R_max = trial_properties(cur_trial).R_max;
        data(s).relative_reward(j,1) = (R-R_min)/(R_max-R_min);
        data(s).took_optimal_path(j,1) = all(trial_properties(cur_trial).optimal_path'==data(s).path(j,:));
        if ~strcmp(experiment_version,'B')
            cur_delays2 = str2num(cell2mat(cur_delays(j)));
            data(s).delays(j,:) = cur_delays2;
            data(s).delays1(j,1) = cur_delays2(1);
            data(s).delays2(j,1) = cur_delays2(2);
            data(s).delays3(j,1) = cur_delays2(3);
        end
        for k = 1:nr_moves
            data(s).nr_clicks(j,k) = sum(str2num(cell2mat(cur_clickTimes(j))) < cur_actionTimes(j,k));
        end
        data(s).nr_clicks1(j,1) = sum(str2num(cell2mat(cur_clickTimes(j))) < cur_actionTimes(j,1));
        data(s).nr_clicks2(j,1) = sum(str2num(cell2mat(cur_clickTimes(j))) < cur_actionTimes(j,2));
        data(s).nr_clicks3(j,1) = sum(str2num(cell2mat(cur_clickTimes(j))) < cur_actionTimes(j,3));
        data(s).clicks1{j} = cur_clicks(str2num(cell2mat(cur_clickTimes(j))) < cur_actionTimes(j,1));
        data(s).clicks2{j} = cur_clicks(str2num(cell2mat(cur_clickTimes(j))) < cur_actionTimes(j,2));
        data(s).clicks3{j} = cur_clicks(str2num(cell2mat(cur_clickTimes(j))) < cur_actionTimes(j,3));
    end
    for j = 1:nr_trials
        data(s).click_locations_before_first_move{data(s).trialID(j)+1} = data(s).clicks{j}(1:data(s).nr_clicks1(j,1));
        data(s).click_locations{data(s).trialID(j)+1} = data(s).clicks{j};
    end
    data(s).workerID = worker_id{find(idx,1,'first')};
    data(s).assignmentID = assignment_id{find(idx,1,'first')};
end

% %% number of clicks
% 
% clear nr_clicks
% 
% idx_FB = [data.condition]==1;
% idx_noFB = [data.condition]==0;
% for f = 1:2
%     if f==1
%         dat=data(idx_FB);
%         nr_clicks(1).nr_subj_feedback = length(dat);
%     else
%         dat=data(idx_noFB);
%         nr_clicks(1).nr_subj_control = length(dat);
%     end
%     for i = 1:nr_trials
%         click_locations = [];
%         for j = 1:length(dat)
%             click_locations = [click_locations,dat(j).click_locations_before_first_move{i}];
%         end
%         for j = 2:17
%             cur_nr_clicks(j-1) = sum(click_locations==j);
%         end
%         if f == 1
%             nr_clicks(i).feedback = cur_nr_clicks;
%         elseif f == 2
%             nr_clicks(i).control = cur_nr_clicks;
%         end
%     end
% end
% for i = 1:nr_trials
%     for j = 1:16
%         Y1 = [ones(1,nr_clicks(i).feedback(j)), zeros(1,nr_clicks(1).nr_subj_feedback-nr_clicks(i).feedback(j))];
%         Y2 = [ones(1,nr_clicks(i).control(j)), zeros(1,nr_clicks(1).nr_subj_control-nr_clicks(i).control(j))];
%         [p,chi2,df,cohens_w] = chi2test({Y1,Y2});
%         isSig(j) = p < 0.05; % p < (1-(1-0.05)^(1/16)); %
%     end
%     nr_clicks(i).isSignificant = isSig;
% end

%% bonuses

formatSpec = '%q%q%q%[^\n\r]';
fileID = fopen([rawpath,'/questiondata.csv'],'r');
delimiter = ',';
dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter, 'HeaderLines' ,1, 'ReturnOnError', false);
fclose(fileID);
bonuses = [];
dataArray = dataArray{3};
for i = 1:length(dataArray)
    bonuses = [bonuses; str2num(dataArray{i})];
end
s = 0;
for i = unique(pid)'
    s = s + 1;
    data(s).bonus = bonuses(s);
end