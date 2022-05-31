%%%%%%%%%%%%%%% 
% 
% Test a set of images and calculate PSNR/SSIM
% 
%%%%%%%%%%%%%%% 

%% dir
blur_data = 'blur_kc8';
psf_dir = 'E:\project\INFWIDE\exp\benchmark\simu_data\Hu_dataset_exp\kernel\';
gt_dir = 'E:\project\INFWIDE\exp\benchmark\simu_data\Hu_dataset_exp\gt\';
img_dir = ['E:\project\INFWIDE\exp\benchmark\simu_data\Hu_dataset_exp\', blur_data, '\'];
res_dir = ['../results/Hu_dataset_exp/', blur_data, '/'];

% file info
[psf_names,psf_num] = listdir(psf_dir);
[gt_names,gt_num] = listdir(gt_dir);
[img_names,img_num] = listdir(img_dir);

% make dir
if ~exist(res_dir,'dir')
	mkdir(res_dir)
end


%% param
% sigma: standard deviation for Gaussian noise (for inlier data)
% reg_str: regularization strength for sparse priors
sigma = 30/255;
reg_str = 0.1;


%% run
psnrs = zeros(img_num,1);
ssims = zeros(img_num,1);
h = waitbar(0, 'start deblurring');

for n = 1:img_num
	% read data
	img = imread(strcat(img_dir, img_names(n)));
	img = double(img)/255;

	psf = imread(strcat(psf_dir, psf_names(n)));
	if size(psf,3) == 3
		psf = rgb2gray(psf);
	end
	psf = double(psf);
	psf = psf / sum(psf(:));

	% deblur
	deblurred = deconv_outlier(img, psf, sigma, reg_str);

	% cal psnr/ssim
	gt = imread(strcat(gt_dir, gt_names(n)));
	gt = single(gt)/255;

	psnr_n = psnr(deblurred, gt);
	ssim_n = ssim(deblurred, gt);
	
	psnrs(n) = psnr_n;
	ssims(n) = ssim_n;

	fprintf("PSNR %.2f, SSIM %.4f\n",psnr_n, ssim_n);

	% show & save
	figure(1)
	subplot(131),imshow(img),title('input');
	subplot(132),imshow(deblurred),title('deblurred');
	subplot(133),imshow(gt),title('gt');

	imwrite(deblurred, [res_dir,'deblurred_' num2str(n,'%03d'),'.png'])
	
	waitbar(n/img_num, h, sprintf('Finished %d / %d', n, img_num))
end

figure
plot(1:img_num, psnrs, 'ro'), title('psnrs')
figure
plot(1:img_num,ssims, 'b*'), title('ssims')


aver_psnr = mean(psnrs);
aver_ssim = mean(ssims);
dlmwrite([res_dir '_psnr_all.txt'], psnrs', 'delimiter', '\t', 'precision','%.2f')
dlmwrite([res_dir '_ssim_all.txt'], ssims', 'delimiter', '\t', 'precision','%.4f')
dlmwrite([res_dir '_aver_performance.txt'], [aver_psnr,aver_ssim], 'delimiter', '\t', 'precision','%.4f')

fprintf("================\n Aver. PSNR %.2f, Aver. SSIM %.4f\n",aver_psnr, aver_ssim);
