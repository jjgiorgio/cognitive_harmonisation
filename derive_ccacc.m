%% derive the CC-ACC
home_dir=cd;
load([home_dir,'/data/component_look_up.mat'])
load([home_dir,'/data/TARGET_Imputed.mat'])

%% select cols for each domain
gen_cols=find(ismember(headings,GeneralComponents));
gen_headings=headings(gen_cols);

ef_cols=find(ismember(headings,ExecutiveFunctionComponents));
ef_headings=headings(ef_cols);

memory_cols=find(ismember(headings,MemoryComponents));
mem_headings=headings(memory_cols);
%% stack domain tests
memory_tests=[];
ef_tests=[];
gen_tests=[];
for i=1:length(memory_cols)
    memory_tests(:,i) = TARGET_Imputed{1,memory_cols(i)};
end

for i=1:length(ef_cols)
    ef_tests(:,i) = TARGET_Imputed{1,ef_cols(i)};
end

for i=1:length(gen_cols)
    gen_tests(:,i) = TARGET_Imputed{1,gen_cols(i)};
end


% ensure directions indicate lower is more impaired
ef_tests(:,find(ef_headings=='traila')) = 150 - ef_tests(:,find(ef_headings=='traila'));
ef_tests(:,find(ef_headings=='trailb')) = 300 - ef_tests(:,find(ef_headings=='trailb'));
gen_tests(:,find(gen_headings=='adastotal13')) = 85 - gen_tests(:,find(gen_headings=='adastotal13'));
memory_tests(:,find(mem_headings=='adasq1')) = 10 - memory_tests(:,find(mem_headings=='adasq1'));
memory_tests(:,find(mem_headings=='adasq4')) = 10 - memory_tests(:,find(mem_headings=='adasq4'));
memory_tests(:,find(mem_headings=='adasq8')) = 12 - memory_tests(:,find(mem_headings=='adasq8'));

c_cog_dat.memory_tests=memory_tests;
c_cog_dat.ef_tests=ef_tests;
c_cog_dat.gen_tests=gen_tests;

%% Variance normalise individual scores using the pooled sample baseline CN mean,std
load([home_dir,'/data/variance_norm_params.mat'])

c_cog_dat.memory_tests_norm=(c_cog_dat.memory_tests-variance_norm_params.memory_mean)./variance_norm_params.memory_std;
c_cog_dat.memory_tests_norm_sum=sum(c_cog_dat.memory_tests_norm');
c_cog_dat.ef_tests_norm=(c_cog_dat.ef_tests-variance_norm_params.ef_mean)./variance_norm_params.ef_std;
c_cog_dat.ef_tests_norm_sum=sum(c_cog_dat.ef_tests_norm');
c_cog_dat.gen_tests_norm=(c_cog_dat.gen_tests-variance_norm_params.gen_mean)./variance_norm_params.gen_std;
c_cog_dat.gen_tests_norm_sum=sum(c_cog_dat.gen_tests_norm');

%% Sum scores
c_cog_dat.mem_zscore=(c_cog_dat.memory_tests_norm_sum - ccacc_norm_params.mean_p1)./ccacc_norm_params.std_p1;
c_cog_dat.ef_zscore=(c_cog_dat.ef_tests_norm_sum - ccacc_norm_params.mean_p2)./ccacc_norm_params.std_p2;
c_cog_dat.gen_zscore=(c_cog_dat.gen_tests_norm_sum - ccacc_norm_params.mean_p3)./ccacc_norm_params.std_p3;
c_cog_dat.ccacc_sum=c_cog_dat.mem_zscore+c_cog_dat.ef_zscore+2*c_cog_dat.gen_zscore;
c_cog_dat.ccacc=(c_cog_dat.ccacc_sum - ccacc_norm_params.mean_ccacbl)./ccacc_norm_params.std_ccacbl;
%% stack final data
for i=1:8
    ccacc_headings(i)=headings(i);
    CC_ACC{1,i}=TARGET_Imputed{1,i};
end
CC_ACC{1,9}=c_cog_dat.ccacc';
ccacc_headings(9)='CCACC';
CC_ACC{1,10}=c_cog_dat.mem_zscore';
ccacc_headings(10)='MEM_Zscore';
CC_ACC{1,11}=c_cog_dat.ef_zscore';
ccacc_headings(11)='EF_Zscore';
CC_ACC{1,12}=c_cog_dat.gen_zscore';
ccacc_headings(12)='GEN_Zscore';
%% save data
save([home_dir,'/data/TARGET_CCACC.mat'],'CC_ACC','ccacc_headings')

T_out=table();
for i=1:length(CC_ACC)
    if isempty(CC_ACC{i})
   CC_ACC{i}=nan(size(CC_ACC{1}));     
   T_out(:,i)=table(CC_ACC{i});
    else
    T_out(:,i)=table(CC_ACC{i});
    end
end

T_out.Properties.VariableNames=ccacc_headings;
writetable(T_out,[home_dir,'/data/TARGET_CCACC.csv'])










