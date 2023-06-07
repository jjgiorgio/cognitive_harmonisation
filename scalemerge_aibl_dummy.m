%% LOAD DUMMY DATA AND HEADINGS
home_dir=cd;
txt = input('what is the name of the unscaled data, eg. aibl_dummy_data? ',"s");

load([home_dir,'/data/ref_data.mat'],'headings');
T = readtable([home_dir,'/data/',txt,'.csv']);

aibl_headings = T.Properties.VariableNames';
SCALE_MERGE = cell(1,133); %create empty cell array to align data

%% LOAD DEMOGRAPHIC DATA %%
%% phase
aibl_Phase = categorical(repmat(["aibl"], (size(T,1)),1)); %add phase name which was not present in original aibl data
SCALE_MERGE{1,find(headings == 'Phase')} = aibl_Phase;

%% RID
SCALE_MERGE{1,find(headings == 'RID')} = T.AIBL_ID;


%% sex
SCALE_MERGE{1,find(headings == 'sex')} = T.Demographic_Sex;

%% diagnosis
aibl_diagnosis = categorical(T.Demographic_AD_MCI_H_O_at_presentation);
aibl_numerical_diagnosis = nan(length(T.Demographic_AD_MCI_H_O_at_presentation),1);

for i=1:length(T.Demographic_AD_MCI_H_O_at_presentation)
    if aibl_diagnosis(i) == 'hc'
        aibl_numerical_diagnosis(i) = 1;
    elseif aibl_diagnosis(i) == 'mci'
        aibl_numerical_diagnosis(i) = 2;
    elseif aibl_diagnosis(i) == 'ad'
        aibl_numerical_diagnosis(i) = 3;
    end
end
SCALE_MERGE{1,find(headings == 'diagnosis')} = aibl_numerical_diagnosis;

%% dob: as we are only given months and years, everyone is assumed to be born on
% the first of the month

numerical_dates = T.Demographic_YearMonthOfBirth;
aibl_dob = datetime(fix(numerical_dates/100),rem(numerical_dates,100), ones(size(numerical_dates)), 'Format','dd/MM/yyyy');
SCALE_MERGE{1,find(headings == 'dob')} = aibl_dob;

%% educationyears
SCALE_MERGE{1,find(headings == 'educationyears')} = T.Demographic_Years_of_Education_Exact;

%% LOAD COGNITIVE DATA, SCALE AS NECESSARY %%
%% ace3wds - mmse 3 words comprehension
aibl_3wds_1 = T.Neuropsych_MMSE_registration_apple;
aibl_3wds_2 = T.Neuropsych_MMSE_registration_penny;
aibl_3wds_3 = T.Neuropsych_MMSE_registration_table;
aibl_3wds = [aibl_3wds_1 + aibl_3wds_2 + aibl_3wds_3];
SCALE_MERGE{1,find(headings == 'ace3wds')} = aibl_3wds;


%% acesubtr7world
% from AIBL take the serial 7s as most people have scores for this but not
% for spelling WORLD backwards
aibl_subtr7 = (T.Neuropsych_MMSE_sevens_1 + T.Neuropsych_MMSE_sevens_2 + T.Neuropsych_MMSE_sevens_3 + T.Neuropsych_MMSE_sevens_4 + T.Neuropsych_MMSE_sevens_5);
SCALE_MERGE{1,find(headings == 'acesubtr7world')} = aibl_subtr7;

%% acerepwds
aibl_repwds = (T.Neuropsych_MMSE_recall_1 + T.Neuropsych_MMSE_recall_2 + T.Neuropsych_MMSE_recall_3);
SCALE_MERGE{1,find(headings == 'acerepwds')} = aibl_repwds;

%% aceletters
aibl_fas = T.Neuropsych_FAS__total_;
aibl_letters = aibl_fas/3; 
group_letters = [0,2,4,6,8,11,14,18,inf];

discretized_aibl_letters = discretize(aibl_letters, group_letters);
discretized_aibl_letters = discretized_aibl_letters -1;
SCALE_MERGE{1,find(headings == 'aceletters')} = discretized_aibl_letters;

%% aceanimals
aibl_animals = T.Neuropsych_Category_Fluency_Animals;
group_animals = [0,5,7,9,11,14,17,22,inf];

discretized_aibl_animals = discretize(aibl_animals, group_animals);
discretized_aibl_animals = discretized_aibl_animals-1;
SCALE_MERGE{1,find(headings == 'aceanimals')} = discretized_aibl_animals;

%% acerorders
aibl_orders = (T.Neuropsych_MMSE_comprehension_1 + T.Neuropsych_MMSE_comprehension_2 +T.Neuropsych_MMSE_comprehension_3 + T.Neuropsych_MMSE_reading);
SCALE_MERGE{1,find(headings == 'acerorders')} = aibl_orders;

%% acersentence
SCALE_MERGE{1,find(headings == 'acersentence')} = T.Neuropsych_MMSE_writing;

%% acerepeat3
SCALE_MERGE{1,find(headings == 'acerepeat3')} = T.Neuropsych_MMSE_repetition;

%% acediagram
SCALE_MERGE{1,find(headings == 'acediagram')} = T.Neuropsych_MMSE_drawing;

%% clock5
SCALE_MERGE{1,find(headings == 'clock5')} = T.Neuropsych_ADNI_Clock_Score_Total;

%% mmorientation
aibl_mmorientation = (T.Neuropsych_MMSE_building + T.Neuropsych_MMSE_city + T.Neuropsych_MMSE_date +T.Neuropsych_MMSE_day ...
                        + T.Neuropsych_MMSE_floor + T.Neuropsych_MMSE_month + T.Neuropsych_MMSE_season + T.Neuropsych_MMSE_state ...
                        + T.Neuropsych_MMSE_suburb + T.Neuropsych_MMSE_year);

SCALE_MERGE{1,find(headings == 'mmorientation')} = aibl_mmorientation;

%% mmnaming
aibl_naming = (T.Neuropsych_MMSE_naming_pencil + T.Neuropsych_MMSE_naming_watch);
SCALE_MERGE{1,find(headings == 'mmnaming')} = aibl_naming;

%% mmsetotal
SCALE_MERGE{1,find(headings == 'mmsetotal')} = T.Neuropsych_MMSE;

%% ravlt1
SCALE_MERGE{1,find(headings == 'ravlt1')} = (T.Neuropsych_CVLT_T1/16)*15;

%% ravlt2
SCALE_MERGE{1,find(headings == 'ravlt2')} = (T.Neuropsych_CVLT_T2/16)*15;

%% ravlt3
SCALE_MERGE{1,find(headings == 'ravlt3')} = (T.Neuropsych_CVLT_T3/16)*15;

%% ravlt4
SCALE_MERGE{1,find(headings == 'ravlt4')} = (T.Neuropsych_CVLT_T4/16)*15;

%% ravlt5
SCALE_MERGE{1,find(headings == 'ravlt5')} = (T.Neuropsych_CVLT_T5/16)*15;

%% ravlttot
SCALE_MERGE{1,find(headings == 'ravlttot')} = (T.Neuropsych_List_A_1_5_RAW/16)*15;

%% ravltlearn
SCALE_MERGE{1,find(headings == 'ravltlearn')} = (T.Neuropsych_CVLT_T5 - T.Neuropsych_CVLT_T1) * (15/16);

%% ravlt3m
SCALE_MERGE{1,find(headings == 'ravlt3m')} = (T.Neuropsych_List_A_T6_Retention__RAW_/16)*15;

%% ravlt30m
SCALE_MERGE{1,find(headings == 'ravlt30m')} = (T.Neuropsych_List_A_Delayed_Recall__RAW_/16)*15;

%% ravltrecog
SCALE_MERGE{1,find(headings == 'ravltrecog')} = (T.Neuropsych_List_A_Recognition__RAW_/16)*15;

%% cdmemory
SCALE_MERGE{1,find(headings == 'cdmemory')} = T.Neuropsych_CDR_memory;

%% cdorient
SCALE_MERGE{1,find(headings == 'cdorient')} = T.Neuropsych_CDR_orientation;

%% cdjudge
SCALE_MERGE{1,find(headings == 'cdjudge')} = T.Neuropsych_CDR_judgment;

%% cdcommun
SCALE_MERGE{1,find(headings == 'cdcommun')} = T.Neuropsych_CDR_community;

%% cdhome
SCALE_MERGE{1,find(headings == 'cdhome')} = T.Neuropsych_CDR_home_hobbies;

%% cdcare
SCALE_MERGE{1,find(headings == 'cdcare')} = T.Neuropsych_CDR_personal_care;

%% cdsob
SCALE_MERGE{1,find(headings == 'cdsob')} = T.Neuropsych_CDR_SOB;

%% cdglobal
SCALE_MERGE{1,find(headings == 'cdglobal')} = T.Neuropsych_CDR_global;

%% bntspont15 (US versions taken! rather than Aus version)
SCALE_MERGE{1,find(headings == 'bntspont15')} = (T.Neuropsych_BNT___No_Cue__US_RAW_)/2;

%% bntstim15
%NA
%% bntcstim15
SCALE_MERGE{1,find(headings == 'bntcstim15')} = (T.Neuropsych_BNT___Stimulus_cued_score__US_)/2;
%% bntphon15
%NA
%% bntcphon15
SCALE_MERGE{1,find(headings == 'bntcphon15')} = (T.Neuropsych_BNT___Phonemic_cued_score__US_)/2;

%% bnttotal15
%NA
%% wasidigitsymbol
group_wais = [0,10,16,20,30,39,47,54,57,62,88];
aibl_wais = discretize(T.Neuropsych_Raw_score__digit_symbol_coding_, group_wais);
SCALE_MERGE{1,find(headings == 'waisdigitsymbol')} = aibl_wais;

%% limmtotal
SCALE_MERGE{1,find(headings == 'limmtotal')} = T.Neuropsych_Recall_RAW__LM1_;

%% ldeltotal
SCALE_MERGE{1,find(headings == 'ldeltotal')} = T.Neuropsych_Recall_RAW__LMII_;

%% dspanfor
SCALE_MERGE{1,find(headings == 'dspanfor')} = (T.Neuropsych_Digit_Span_Fwd/16)*12;

%% dspanbac
SCALE_MERGE{1,find(headings == 'dspanbac')} = (T.Neuropsych_Digit_Span_Fwd/14)*12;

%% rcftcopy
SCALE_MERGE{1,find(headings == 'rcftcopy')} = T.Neuropsych_RCFT_Copy__RAW_;

%% rcftimm
SCALE_MERGE{1,find(headings == 'rcftimm')} = T.Neuropsych_RCFT_3_min_delay__RAW_;

%% rcftdel
SCALE_MERGE{1,find(headings == 'rcftdel')} = T.Neuropsych_RCFT_30_min_delay__RAW_;

%% rcftrecog
SCALE_MERGE{1,find(headings == 'rcftrecog')} = T.Neuropsych_RCFT_Recog__RAW_;

%% CATCHING OUTLIERS %%
load([home_dir,'/data/metadata.mat'])

metadata = metadata([1:46,65:147,153:156],:); %remove variables from metadata which didn't make the final harmonised dataset
metadata.ul(85)=10; %change scaling of digit symbol substitution (dizcretized/10)
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

%% SAVE DATA %%

SCALE_MERGE={SCALE_MERGE{1,:}};
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
