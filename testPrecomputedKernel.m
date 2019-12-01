% To use precomputed kernel, you must include sample serial number as
% the first column of the training and testing data (assume your kernel
% matrix is K, # of instances is n):
% 
% matlab> K1 = [(1:n)', K]; % include sample serial number as first column
% matlab> model = svmtrain(label_vector, K1, '-t 4');
% matlab> [predict_label, accuracy, dec_values] = svmpredict(label_vector, K1, model); % test the training data
% 
% We give the following detailed example by splitting heart_scale into
% 150 training and 120 testing data.  Constructing a linear kernel
% matrix and then using the precomputed kernel gives exactly the same
% testing error as using the LIBSVM built-in linear kernel.

 load heart_scale.mat

 % Split Data
 train_data = heart_scale_inst(1:150,:);
 train_label = heart_scale_label(1:150,:);
 test_data = heart_scale_inst(151:270,:);
 test_label = heart_scale_label(151:270,:);

 % Linear Kernel  0 -- linear: u'*v
 model_linear = svmtrain(train_label, train_data, '-t 0');
 [predict_label_L, accuracy_L, dec_values_L] = svmpredict(test_label, test_data, model_linear);

 
 % Precomputed Kernel
 model_precomputed = svmtrain(train_label, [(1:150)', train_data*train_data'], '-t 4');
 [predict_label_P, accuracy_P, dec_values_P] = svmpredict(test_label, [(1:120)', test_data*train_data'], model_precomputed);

 accuracy_L % Display the accuracy using linear kernel
 accuracy_P % Display the accuracy using precomputed kernel

% Note that for testing, you can put anything in the
% testing_label_vector.  For more details of precomputed kernels, please
% read the section ``Precomputed Kernels'' in the README of the LIBSVM
% package.