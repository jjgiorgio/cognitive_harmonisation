%% LOAD DUMMY DATA AND HEADINGS
home_dir=cd;
txt = input('what is the name of the unscaled data, eg. nim_dummy_data? ',"s");

load([home_dir,'/data/ref_data.mat'],'headings');
T = readtable([home_dir,'/data/',txt,'.csv']);

nim_headings = T.Properties.VariableNames';
SCALE_MERGE = cell(1,133); %create empty cell to load data into

%% LOAD DEMOGRAPHIC DATA %%
%% phase
SCALE_MERGE{1,find(headings == 'Phase')} = T.dataset;

%% rid
SCALE_MERGE{1,find(headings == 'RID')} = T.nimId;

%% sex
SCALE_MERGE{1,find(headings == 'sex')} = T.sex;

%% diagnosis
nim_diagnosis = categorical(T.diagnosis);
nim_numerical_diagnosis = nan(length(T.diagnosis),1);

for i=1:length(T.diagnosis)
    if nim_diagnosis(i) == 'hc'
        nim_numerical_diagnosis(i) = 1;
    elseif nim_diagnosis(i) == 'mci'
        nim_numerical_diagnosis(i) = 2;
    elseif nim_diagnosis(i) == 'ad'
        nim_numerical_diagnosis(i) = 3;
    end
end
SCALE_MERGE{1,find(headings == 'diagnosis')} = nim_numerical_diagnosis;

%% dob
SCALE_MERGE{1,find(headings == 'dob')} = T.dob;

%% educationyears
SCALE_MERGE{1,find(headings == 'educationyears')} = T.education_years;

%% age at test
SCALE_MERGE{1,find(headings == 'ageattest')} = T.age_at_test_date;

%% test date
SCALE_MERGE{1,find(headings == 'testdate')} = T.test_date;

%% LOAD COGNITIVE DATA, SCALE AS NECESSARY %%
%% mean reaction time
SCALE_MERGE{1,find(headings == 'meanreactiontime')} = T.mean_reaction_time;

%% pal3
SCALE_MERGE{1,find(headings == 'pal3')} = T.pal_3;

%% palerr
SCALE_MERGE{1,find(headings == 'palerr')} = T.pal_adj_err;

%% socsolvemoves
SCALE_MERGE{1,find(headings == 'socsolvmoves')} = T.soc_solv_moves;

%% acetime
SCALE_MERGE{1,find(headings == 'acetime')} = T.ace_time;

%% aceplace
SCALE_MERGE{1,find(headings == 'aceplace')} = T.ace_place;

%% ace3wds - mmse 3 words comprehension
SCALE_MERGE{1,find(headings == 'ace3wds')} = T.ace_3wds;

%% acesubtr7world
SCALE_MERGE{1,find(headings == 'acesubtr7world')} = T.ace_subtr7_world;

%% acerepwds
SCALE_MERGE{1,find(headings == 'acerepwds')} = T.ace_repwds;

%% aceaddress
SCALE_MERGE{1,find(headings == 'aceaddress')} = T.ace_address;

%% acepolitic
SCALE_MERGE{1,find(headings == 'acepolitic')} = T.ace_politic;

%% aceletters
SCALE_MERGE{1,find(headings == 'aceletters')} = T.ace_letters;

%% aceanimals
SCALE_MERGE{1,find(headings == 'aceanimals')} = T.ace_animals;

%% acerorders
SCALE_MERGE{1,find(headings == 'acerorders')} = T.acer_orders;

%% acersentence
SCALE_MERGE{1,find(headings == 'acersentence')} = T.acer_sentence;

%% acerepeat1
SCALE_MERGE{1,find(headings == 'acerepeat1')} = T.ace_repeat1;

%% acerepeat2
SCALE_MERGE{1,find(headings == 'acerepeat2')} = T.ace_repeat2;

%% acerepeat3
SCALE_MERGE{1,find(headings == 'acerepeat3')} = T.ace_repeat3;

%% acename
SCALE_MERGE{1,find(headings == 'acename')} = T.ace_name;

%% aceindicat
SCALE_MERGE{1,find(headings == 'aceindicat')} = T.ace_indicat;

%% aceread
SCALE_MERGE{1,find(headings == 'aceread')} = T.ace_read;

%% acediagram
SCALE_MERGE{1,find(headings == 'acediagram')} = T.ace_diagram;

%% acecube
SCALE_MERGE{1,find(headings == 'acecube')} = T.ace_cube;

%% clock5
SCALE_MERGE{1,find(headings == 'clock5')} = T.clock_5;

%% acenbpoint
SCALE_MERGE{1,find(headings == 'acenbpoint')} = T.ace_nbpoint;

%% aceidlettr
SCALE_MERGE{1,find(headings == 'aceidlettr')} = T.ace_idlettr;

%% acerepaddr
SCALE_MERGE{1,find(headings == 'acerepaddr')} = T.ace_repaddr;

%% acerepaddr2
SCALE_MERGE{1,find(headings == 'acerepaddr2')} = T.ace_repaddr2;

%% acescore
SCALE_MERGE{1,find(headings == 'acescore')} = T.ace_score;

%% aceattent
SCALE_MERGE{1,find(headings == 'aceattent')} = T.ace_attent;

%% acemem 
SCALE_MERGE{1,find(headings == 'acemem')} = T.ace_mem;

%% acefluency
SCALE_MERGE{1,find(headings == 'acefluency')} = T.ace_fluency;

%% acelang
SCALE_MERGE{1,find(headings == 'acelang')} = T.ace_lang;

%% acevisuo
SCALE_MERGE{1,find(headings == 'acevisuo')} = T.ace_visuo;

%% mmsetotal
SCALE_MERGE{1,find(headings == 'mmsetotal')} = T.mmse;

%% mmorientation
SCALE_MERGE{1,find(headings == 'mmorientation')} = T.mm_orientation;

%% mmsetotal
SCALE_MERGE{1,find(headings == 'mmsetotal')} = T.mmse;

%% traila
SCALE_MERGE{1,find(headings == 'traila')} = T.trail_a;

%% trailb
SCALE_MERGE{1,find(headings == 'trailb')} = T.trail_b;

%% ravlt1
SCALE_MERGE{1,find(headings == 'ravlt1')} = T.ravlt1;

%% ravlt2
SCALE_MERGE{1,find(headings == 'ravlt2')} = T.ravlt2;

%% ravlt3
SCALE_MERGE{1,find(headings == 'ravlt3')} = T.ravlt3;

%% ravlt4
SCALE_MERGE{1,find(headings == 'ravlt4')} = T.ravlt4;

%% ravlt5
SCALE_MERGE{1,find(headings == 'ravlt5')} = T.ravlt5;

%% ravlttot
SCALE_MERGE{1,find(headings == 'ravlttot')} = T.ravlt_tot;

%% ravltlearn
SCALE_MERGE{1,find(headings == 'ravltlearn')} = T.ravlt_learn;

%% ravlt3m
SCALE_MERGE{1,find(headings == 'ravlt3m')} = T.ravlt_3m;

%% ravlt30m
SCALE_MERGE{1,find(headings == 'ravlt30m')} = T.ravlt_30m;

%% ravltrecog
SCALE_MERGE{1,find(headings == 'ravltrecog')} = T.ravlt_recog;

%% cdmemory
SCALE_MERGE{1,find(headings == 'cdmemory')} = T.cdmemory;

%% cdorient
SCALE_MERGE{1,find(headings == 'cdorient')} = T.cdorient;

%% cdjudge
SCALE_MERGE{1,find(headings == 'cdjudge')} = T.cdjudge;

%% cdcommun
SCALE_MERGE{1,find(headings == 'cdcommun')} = T.cdcommun;

%% cdhome
SCALE_MERGE{1,find(headings == 'cdhome')} = T.cdhome;

%% cdcare
SCALE_MERGE{1,find(headings == 'cdcare')} = T.cdcare;

%% cdsob
SCALE_MERGE{1,find(headings == 'cdsob')} = T.cdsob;

%% cdglobal
SCALE_MERGE{1,find(headings == 'cdglobal')} = T.cdglobal;

%% inecomotor
SCALE_MERGE{1,find(headings == 'inecomotor')} = T.ineco_motor;

%% inecoconf
SCALE_MERGE{1,find(headings == 'inecoconf')} = T.ineco_conf;

%% inecogo
SCALE_MERGE{1,find(headings == 'inecogo')} = T.ineco_go;

%% inecoverbmem
SCALE_MERGE{1,find(headings == 'inecoverbmem')} = T.ineco_verb_mem;

%% inecospatmem
SCALE_MERGE{1,find(headings == 'inecospatmem')} = T.ineco_spat_mem;

%% inecoproverbs
SCALE_MERGE{1,find(headings == 'inecoproverbs')} = T.ineco_proverbs;

%% inecohayling
SCALE_MERGE{1,find(headings == 'inecohayling')} = T.ineco_hayling;

%% inecototal
SCALE_MERGE{1,find(headings == 'inecototal')} = T.ineco_total;

%% dspanbac
SCALE_MERGE{1,find(headings == 'dspanbac')} = T.ineco_dspan*2;

%% ppt
SCALE_MERGE{1,find(headings == 'ppt')} = T.ppt;

%% CATCHING OUTLIERS %%
 load([home_dir,'/data/metadata.mat'])

metadata = metadata([1:46,65:147,153:156],:); %remove variables from metadata which didn't make the final harmonised dataset
metadata.ul(85)=10; %change the ceiling of wais digit symbol to 10 (now discretized)
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
