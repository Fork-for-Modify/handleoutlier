function [file_names, file_num] = listdir(file_path, file_type)
% get_file_names: get file names and account from given path and filetype
%	input:
%       file_path, like 'E:\'
%       file_type, like '.png' | default = ''
%   output:
%       file_nums in cell type, file_num
% 
%	Author: Zhihong Zhang, 2021-12-13

if nargin<2
	file_type='';
end

if ~isfolder(file_path)
     warning([file_path 'is not a directory!'])
end
files = dir(fullfile(file_path, ['*', file_type]));
file_names = string({files.name});
file_names(file_names=="."|file_names=="..")=[];
file_num = length(file_names);

end
