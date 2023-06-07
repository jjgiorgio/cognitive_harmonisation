%% setup  
home_dir=cd;
txt = input('what is the name of the scaled merged data, eg. aibl_dummy_data_SCALE_MERGE? ',"s");
while exist([home_dir,'/data/',txt,'.mat']) ==0
txt = input('file not found, what is the name of the scaled merged data, eg. aibl_dummy_data_SCALE_MERGE? ',"s");
end
display(['imputing from ',txt])
addpath([home_dir,'/functions'])
load([home_dir,'/data/ref_data.mat'],'headings')
load([home_dir,'/data/',txt,'.mat'])
txt_2 = input('what is the ground truth hold out variable, eg. ravlttot? ',"s");

%% stack TAGET Data
stacked_TARGET=nan(length(SCALE_MERGE{1,1}),length(9:length(headings)));
for i =9:length(headings)
    if ~isempty(SCALE_MERGE{1,i})
stacked_TARGET(:,i-8)=SCALE_MERGE{1,i};
stacked_headings(i-8)=headings(i);
    end  
end

hold_out_id=find(stacked_headings==txt_2);

TARGET_Impute=stacked_TARGET;
TARGET_Identifier=SCALE_MERGE{1,2};
num_tested=~isnan(TARGET_Impute); 
figure; imagesc(num_tested); title('Variables Collected');
number_of_test_per_sub=sum(num_tested,2);
max_n_tests=max(number_of_test_per_sub); % find the maximum overlap of tests
TARGET_Impute(number_of_test_per_sub<max_n_tests/2,:)=NaN; % exclude visits with less than half of variables

txt_3 = input('run fast impute?, y/n ',"s");

%% within sample imputation  
if txt_3(1)=='n'
n_cores=feature('numcores');
if n_cores>22
    n_cores=22;
end
parpool('local',n_cores-2);
load([home_dir,'/data/ref_data.mat'])

TARGET_Impute=stacked_TARGET;
TARGET_Identifier=SCALE_MERGE{1,2};
num_tested=~isnan(TARGET_Impute); 
figure; imagesc(num_tested); title('Variables Collected');
number_of_test_per_sub=sum(num_tested,2);
max_n_tests=max(number_of_test_per_sub); % find the maximum overlap of tests
TARGET_Impute(number_of_test_per_sub<max_n_tests/2,:)=NaN; % exclude visits with less than half of variables
[TARGET_Impute]=knn_seq_unique(TARGET_Identifier,TARGET_Impute,4,1,hold_out_id,txt_2); % use RAVLT total to optimise k

%%  
load([home_dir,'/data/ref_data.mat'])
%% stack_mega_matrix
REFERNCE_inds=1:length(reference_mat);
TARGET_inds=REFERNCE_inds(end)+1:REFERNCE_inds(end)+length(TARGET_Impute);
stacked_mega_target=[reference_mat;TARGET_Impute];

%% optimise k by holding out the ground truth variable for TARGET
GRND_TRUTH=stacked_mega_target(TARGET_inds,hold_out_id);
stacked_mega_target(TARGET_inds,hold_out_id)=nan;
search_k=1:20;
parfor i=1:length(search_k)
    k=search_k(i);
temp_stacked_mega=stacked_mega_target;
num_tested=~isnan(stacked_mega_target);       
number_of_test_per_sub=sum(num_tested,2);


non_empty=find(number_of_test_per_sub~=0); 
temp_mat= temp_stacked_mega(non_empty,:);

temp=knnimpute_ignore_nan(temp_mat',k);
temp_stacked_mega(non_empty,:)=temp';

temp=[GRND_TRUTH(:,1),temp_stacked_mega(TARGET_inds,hold_out_id)];

[I,J] = ind2sub(size(temp),find(isnan(temp)));
temp(unique(I),:)=[];
r2_holdout(i)=corr(temp(:,1),temp(:,2))^2;  % calc variance explained
mse_holdout(i) = mean((temp(:,2)-temp(:,1)).^2) % calc mean square error 
end
rmse_holdout=mse_holdout.^.5;
scan_k=1:20;
[k, k_ind] = knee_pt(rmse_holdout,scan_k,1);
if min(rmse_holdout(1:k_ind))<rmse_holdout(k_ind)
    [~,k_ind]=min(rmse_holdout(1:k_ind));
    k=scan_k(k_ind);
end
figure;
plot(scan_k,rmse_holdout,'k--')
hold on
a=plot(scan_k(k_ind),rmse_holdout(k_ind),'ro');
xlabel('K')
ylabel('RMSE')
legend(a,{'Selected k'})
title([txt_2,' R2=',num2str(r2_holdout(k_ind)),', Selected k for REFERENCE into TARGET k=',num2str(k)])


%% run imputation to fill in TARGET from ADNI/NIM/NUS/BACS/AIBL
stacked_mega_target_Impute=[reference_mat;TARGET_Impute];
num_tested=~isnan(stacked_mega_target_Impute);     

number_of_test_per_sub=sum(num_tested,2);
non_empty=find(number_of_test_per_sub~=0); 
temp_mat= stacked_mega_target_Impute(non_empty,:);

temp=knnimpute_ignore_nan(temp_mat',k);
stacked_mega_target_Impute(non_empty,:)=temp';

else 
  %% fast impute
disp('Skipping within sample imputation and optimisation of k, using k=3 neighbours')
k=3;
load([home_dir,'/data/ref_data.mat'])
%% stack_mega_matrix

REFERNCE_inds=1:length(reference_mat);
TARGET_inds=REFERNCE_inds(end)+1:REFERNCE_inds(end)+length(TARGET_Impute);
stacked_mega_target=[reference_mat;TARGET_Impute];
TARGET_Identifier=[length(TARGET_Identifier)+1:length(TARGET_Identifier)+length(reference_mat),TARGET_Identifier']';
[stacked_mega_target_Impute]=knn_seq_unique(TARGET_Identifier,stacked_mega_target,k,0,hold_out_id,txt_2); % use RAVLT total to optimise k
end

%% Store TARGET Data
TARGET_Imputed={SCALE_MERGE{1,1:8}};
for i =9:length(headings)
TARGET_Imputed{1,i}=stacked_mega_target_Impute(TARGET_inds,i-8);
end

save([home_dir,'/data/TARGET_Imputed.mat'],'TARGET_Imputed','headings')

T_out=table();
for i=1:length(TARGET_Imputed)
    if isempty(TARGET_Imputed{i})
   TARGET_Imputed{i}=nan(size(TARGET_Imputed{1}));     
   T_out(:,i)=table(TARGET_Imputed{i});
    else
    T_out(:,i)=table(TARGET_Imputed{i});
    end
end

T_out.Properties.VariableNames=headings;
writetable(T_out,[home_dir,'/data/TARGET_Imputed.csv'])


%% Check association of Covariance 
TARGET_CORR=corr(stacked_mega_target_Impute(TARGET_inds,:),stacked_mega_target_Impute(TARGET_inds,:),'row','complete');
POOLED_CORR=corr(stacked_mega_target_Impute(REFERNCE_inds,:),stacked_mega_target_Impute(REFERNCE_inds,:),'row','complete');
load([home_dir,'/data/ADNI_CORR.mat'])

figure; 
imagesc(POOLED_CORR)
title('REFERENCE Correlation Values')
caxis([-1,1])

figure; 
imagesc(ADNI_CORR)
title('ADNI Correlation Values')
caxis([-1,1])

figure; 
imagesc(TARGET_CORR)
title('TARGET Correlation Values')
caxis([-1,1])

upper_triangle_pooled=POOLED_CORR(triu(POOLED_CORR,1)~=0);
upper_triangle_adni=ADNI_CORR(triu(ADNI_CORR,1)~=0);
upper_triangle_target=TARGET_CORR(triu(TARGET_CORR,1)~=0);

figure; plot(upper_triangle_adni,upper_triangle_target,'ko')
title(['TARGET vs ADNI R2=',num2str(corr(upper_triangle_adni,upper_triangle_target)^2)])
figure; plot(upper_triangle_pooled,upper_triangle_target,'ko')
title(['TARGET vs REFERENCE R2=',num2str(corr(upper_triangle_pooled,upper_triangle_target)^2)])

%% Relationship with ADNI Comps
disp(['ADNI COMPS: RAVLT TOTAL vs ADNI MEM R2=',num2str(corr(stacked_mega_target_Impute(TARGET_inds,47),stacked_mega_target_Impute(TARGET_inds,118),'row','complete')^2)]);
disp(['ADNI COMPS: TRAILS B vs ADNI EF R2=',num2str(corr(stacked_mega_target_Impute(TARGET_inds,40),stacked_mega_target_Impute(TARGET_inds,119),'row','complete')^2)]);

delete(gcp('nocreate'))

