
function [full_matrix]=knn_seq_unique(identifier,dappled_matrix,k,optimisek,ref_col,fig_name)
%% sequential knn removing future assment
% Note function assumes that the majority of rows has 'full' data

% in-
% identifier: id to ensure that values imputed into a row are from different individuals
% dappled_matrix: matrix with varying degrees of missingness -assumes 1. that
% there is sufficient sample with 'full' variables, 2. a floor has been
% applied to the number of missing variables (i.e. remove rows with more
% than half tests missing).
% k: nearest neighbours to average over in imputation -should be optimised-
% optimisek: flag to poll through several different values of k and select
% the value of k that minimised the MSE for a hidden 10% of entries from
% ref_col: the reference col to compare with to set the optimal k

if optimisek
    hidden_sample=randsample(1:length(dappled_matrix),round(length(dappled_matrix)*.1));
    opt_dappled=dappled_matrix;
    grnd_truth=dappled_matrix(hidden_sample,ref_col);
    opt_dappled(hidden_sample,ref_col)=nan;
   m_sqerror=zeros(1,9);
      scan_k=1:20;
    parfor i=1:length(scan_k)
        k=scan_k(i);
        [full_matrix]=knn_seq_unique(identifier,opt_dappled,k,0,[]);
        imp_ref=full_matrix(hidden_sample,ref_col);
        m_sqerror(i) = nanmean((grnd_truth-imp_ref).^2);
    end
    rmse=m_sqerror.^.5;
[k, k_ind] = knee_pt(rmse,scan_k,1);
if min(rmse(1:k_ind))<rmse(k_ind)
    [~,k_ind]=min(rmse(1:k_ind));
    k=scan_k(k_ind);
end
figure;
plot(scan_k,rmse,'k--')
hold on
a=plot(scan_k(k_ind),rmse(k_ind),'ro');
xlabel('K')
ylabel('RMSE')
legend(a,{'Sected k'})
title(['Within Target Sample',10, 'Selected k for Best RMSE ',fig_name,' k=',num2str(k)])
end

num_tested=~isnan(dappled_matrix);
number_of_test_per_sub=sum(num_tested,2);
non_empty_rows=find(number_of_test_per_sub>0); % determine rows with sufficient data to impute into


temporary_matrix=dappled_matrix(non_empty_rows,:); % build temporary matrix for stacking rows

missing_data=1; % set flag to continue itterating through varying degrees of missingness
while missing_data
    
    num_tested=~isnan(temporary_matrix);  %
    
    [B, ~, ib] = unique(num_tested, 'rows');
    numoccurences = accumarray(ib, 1);
    indices = accumarray(ib, find(ib), [], @(rows){rows});
    A = cellfun(@(v)v(1),indices); % find out the rows that have the same missing variables (i.e. impute out of this sample, should be fairly large)
    number_of_test_per_sub=sum(num_tested,2);
    find_max_overlap=find(number_of_test_per_sub(A)==max(number_of_test_per_sub(A))); % if there are 2 arangements of data with max variables pick the one with largest sample
    if length(find_max_overlap)>1
        [~,max_samples_ind]=max(numoccurences(find_max_overlap)); % find the rows that have max data avaiable and use as reference
        find_max_overlap=find_max_overlap(max_samples_ind);
    end
    
    ref_mat=temporary_matrix(indices{find_max_overlap},:); % build reference matrix and store inds to restack into temporary_matrix
    ref_indicies=indices{find_max_overlap};
    
    A(find_max_overlap)=[];
    indices(find_max_overlap,:)=[];
    numoccurences(find_max_overlap)=[];
    
    max_cols=find(~isnan(ref_mat(1,:)));
    
    next_most_rows=find(number_of_test_per_sub(A)==max(number_of_test_per_sub(A)));
    next_rows_to_append=next_most_rows(find(numoccurences(next_most_rows)==max(numoccurences(next_most_rows)))); % find the next most complete rows to impute values from the ref mat into
    
    
    for stack_row=next_rows_to_append' % if there are different arangements of cols that have same degree of missingness itterate through the list
        
        app_mat=temporary_matrix([indices{stack_row}],:); % define the matrix to append
        
        keep_inds_ref=find(~ismember(identifier(ref_indicies),identifier(indices{stack_row}))); % check to see that the same individulas in the append sample aren't in the ref sample
        
        if ~isempty(keep_inds_ref)
            temp=[ref_mat(keep_inds_ref,:);app_mat]; % remove these folk from the ref sample if they are in both
            indicies_restack=[ref_indicies(keep_inds_ref);indices{stack_row}];
        else
            temp=[ref_mat;app_mat]; % Keep everyone
            indicies_restack=[ref_indicies;indices{stack_row}];
        end
        
        temp=knnimpute_ignore_nan(temp(:,max_cols)',k); % impute the values from ref into append
        temporary_matrix(indicies_restack,max_cols)=temp';  % restack the data into temporary_matrix
    end
    
    num_tested=~isnan(temporary_matrix); % check to see that are still missing subs
    number_of_test_per_sub=sum(num_tested,2);
    missing_data=length(unique(number_of_test_per_sub))~=1; % if all rows have 'full' data then lower the flag
    
end

full_matrix=nan(size(dappled_matrix));
full_matrix(non_empty_rows,:)=temporary_matrix; % restack the full data to return

end

