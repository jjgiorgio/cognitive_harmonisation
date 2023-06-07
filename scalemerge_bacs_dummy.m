%% LOAD DUMMY DATA AND HEADINGS
home_dir=cd;
txt = input('what is the name of the unscaled data, eg. bacs_dummy_data? ',"s");

load([home_dir,'/data/ref_data.mat'],'headings');
T = readtable([home_dir,'/data/',txt,'.csv']);

bacs_headings = T.Properties.VariableNames';
SCALE_MERGE = cell(1,133); %create empty cell array to align data

%% LOAD DEMOGRAPHIC DATA %%
%% phase
SCALE_MERGE{1,find(headings == 'Phase')} = T.group;

%% RID
SCALE_MERGE{1,find(headings == 'RID')} = T.SubjectID;

%% sex
SCALE_MERGE{1,find(headings == 'sex')} = T.sex;

%% diagnosis
%BACS all CN at baseline (aka code 1 (see supplementary table 1), so create string of 1s)
bacs_diag = ones(height(T),1);
SCALE_MERGE{1,find(headings == 'diagnosis')} = bacs_diag;

%% ageattest
SCALE_MERGE{1,find(headings == 'ageattest')} = T.age_at_test;

%% educationyears
SCALE_MERGE{1,find(headings == 'educationyears')} = T.education_years;

%% LOAD COGNITIVE DATA, SCALE AS NECESSARY %%
%% vegetablesfluency
SCALE_MERGE{1,find(headings == 'vegetablesfluency')} = T.vegetables_fluency;

%% aceletters
bacs_letters = T.fas_total/3;
group_letters = [0,2,4,6,8,11,14,18,inf];

discretized_bacs_letters = discretize(bacs_letters, group_letters);
discretized_bacs_letters = discretized_bacs_letters -1;

SCALE_MERGE{1,find(headings == 'aceletters')} = discretized_bacs_letters;

%% aceanimals
bacs_animals = T.animals_fluency;
group_animals = [0,5,7,9,11,14,17,22,inf];

discretized_bacs_animals = discretize(bacs_animals, group_animals);
discretized_bacs_animals = discretized_bacs_animals-1;

SCALE_MERGE{1,find(headings == 'aceanimals')} = discretized_bacs_animals;

%% mmsetotal
SCALE_MERGE{1,find(headings == 'mmsetotal')} = T.mmse_total;

%% traila
SCALE_MERGE{1,find(headings == 'traila')} = T.trail_a;

%% trailb
SCALE_MERGE{1,find(headings == 'trailb')} = T.trail_b;

%% ravlttot
SCALE_MERGE{1,find(headings == 'ravlttot')} = (T.cvlt_1_to_5_fr/16)*15;

%% ravlt3m
SCALE_MERGE{1,find(headings == 'ravlt3m')} = (T.cvlt_sdfr/16)*15;

%% ravlt30m
SCALE_MERGE{1,find(headings == 'ravlt30m')} = (T.cvlt_ldfr/16)*15;

%% ravltrecog
SCALE_MERGE{1,find(headings == 'ravltrecog')} = (T.cvlt_recog/16)*15;

%% bntspont15
SCALE_MERGE{1,find(headings == 'bntspont15')} = T.number_correct;

%% bntstim15
SCALE_MERGE{1,find(headings == 'bntstim15')} = T.number_of_stim_cues_given;

%% bntcstim15
SCALE_MERGE{1,find(headings == 'bntcstim15')} = T.number_corr_with_stim_cues;

%% bntcphon15
SCALE_MERGE{1,find(headings == 'bntcphon15')} = T.number_corr_with_phon_cues;

%% bnttotal15
SCALE_MERGE{1,find(headings == 'bnttotal15')} = T.bnt_total;

%% waisdigitsymbol
group_wais = [0,10,16,20,30,39,47,54,57,62,88];
bacs_wais = discretize(T.digit_symbol, group_wais);
SCALE_MERGE{1,find(headings == 'waisdigitsymbol')} = bacs_wais;

%% wmsvrirecalltotal
SCALE_MERGE{1,find(headings == 'wmsvrirecalltotal')} = T.vri_recall_total;

%% wmsvriirecalltotal
SCALE_MERGE{1,find(headings == 'wmsvriirecalltotal')} = T.vrii_recall_total;

%% wmsvrrecognitiontotal
SCALE_MERGE{1,find(headings == 'wmsvrrecognitiontotal')} = T.vr_recognition_total;

%% limmtotal
SCALE_MERGE{1,find(headings == 'limmtotal')} = T.lm_a_plus_b1/2;

%% dspanfor
SCALE_MERGE{1,find(headings == 'dspanfor')} = (T.ds_forward/16)*12;

%% dspanbac
SCALE_MERGE{1,find(headings == 'dspanbac')} = (T.ds_backward/14)*12;


%% CATCHING OUTLIERS %%
 load([home_dir,'/data/metadata.mat'])

metadata = metadata([1:46,65:147,153:156],:);%remove variables from metadata which didn't make the final harmonised dataset
metadata.ul(85)=10; %change the digit symbol subsitution ceiling to be /10 (discretized)
figure;
    for i = 9:133
        if ~isempty(SCALE_MERGE{1,i})
        hist(SCALE_MERGE{1,i})
        hold on
        plot([metadata.ll(i),metadata.ll(i)],[0,length(SCALE_MERGE{1,i})+50],'k-','LineWidth',5)
        plot([metadata.ul(i),metadata.ul(i)],[0,length(SCALE_MERGE{1,i})+50],'k-','LineWidth',5)
        prop_removed=100*(sum(SCALE_MERGE{1,i} < metadata.ll(i))+sum(SCALE_MERGE{1,i} > metadata.ul(i)))/sum(~isnan(SCALE_MERGE{1,i}));
        SCALE_MERGE{1,i}(SCALE_MERGE{1,i} < metadata.ll(i)) = nan;
        SCALE_MERGE{1,i}(SCALE_MERGE{1,i} > metadata.ul(i)) = nan;
        title([['Percent removed for out of range = ',num2str(prop_removed)],headings(i)])
        if prop_removed>10
warning(['Greater than 10% of entries removed from ',char(headings(i)),' due to data out of range CHECK SCALING!'])
        end
pause(1)
        clf
        end

    end
close all


%% SAVE DATA %
 save([home_dir,'/data/',txt,'_SCALE_MERGE.mat'],'SCALE_MERGE')

T_out=table();
for i=1:length(SCALE_MERGE)
    if isempty(SCALE_MERGE{i})
   SCALE_MERGE{i}=nan(size(SCALE_MERGE{1}));     
   T_out(:,i)=table(SCALE_MERGE{i});
    else
    T_out(:,i)=table(SCALE_MERGE{i});
    end
end

T_out.Properties.VariableNames=headings;
 writetable(T_out,[home_dir,'/data/',txt,'_SCALE_MERGE.csv'])