addpath('dataset/COCO/coco/MatlabAPI/');
addpath('../testing/util');

mkdir('dataset/COCO/mask2014')
vis = 0;

load('dataset/COCO/mat/coco.mat');
L = length(coco_kpt);

for i = 1:L
    img_path = coco_kpt(i).image;
	img_paths = split(img_path, '/');
    img_name1 = sprintf('dataset/COCO/mask2014/mask_all_%s_%s.png', img_paths(length(img_paths)-1), img_paths(length(img_paths)));
    img_name2 = sprintf('dataset/COCO/mask2014/mask_miss_%s_%s.png', img_paths(length(img_paths)-1), img_paths(length(img_paths)));
    
    try
        display([num2str(i) '/ ' num2str(L)]);
        imread(img_name1);
        imread(img_name2);
        continue;
    catch
        display([num2str(i) '/ ' num2str(L)]);
        [h,w,~] = size(imread(img_path));
        mask_all = false(h,w);
        mask_miss = false(h,w);
        flag = 0;
        for p = 1:length(coco_kpt(i).annorect)
            %if this person is annotated
            try
                bbox = coco_kpt(i).annorect(p).bbox;
            catch
                %display([num2str(i) ' ' num2str(p)]);
                mask_crowd = logical(MaskApi.decode( coco_kpt(i).annorect(p).segmentation ));
                temp = and(mask_all, mask_crowd);
                mask_crowd = mask_crowd - temp;
                flag = flag + 1;
                coco_kpt(i).mask_crowd = mask_crowd;
                continue;
            end
            
            [X,Y] = meshgrid( 1:w, 1:h );
            mask = inpolygon( X, Y, [bbox(1), bbox(1)+bbox(3), bbox(1)+bbox(3), bbox(1)], [bbox(2), bbox(2), bbox(2)+bbox(4), bbox(2)+bbox(4)]);
            mask_all = or(mask, mask_all);
            
            if coco_kpt(i).annorect(p).num_keypoints <= 0
                mask_miss = or(mask, mask_miss);
            end
        end
        if flag == 1
            mask_miss = not(or(mask_miss,mask_crowd));
            mask_all = or(mask_all, mask_crowd);
        else
            mask_miss = not(mask_miss);
        end
        
        coco_kpt(i).mask_all = mask_all;
        coco_kpt(i).mask_miss = mask_miss;
        
        img_name = sprintf('dataset/COCO/mask2014/mask_all_%s_%s.png', img_paths(length(img_paths)-1), img_paths(length(img_paths)));
        imwrite(mask_all,img_name);
        img_name = sprintf('dataset/COCO/mask2014/mask_miss_%s_%s.png', img_paths(length(img_paths)-1), img_paths(length(img_paths)));
        imwrite(mask_miss,img_name);
        
        if flag == 1 && vis == 1
            im = imread(img_path);
            mapIm = mat2im(mask_all, jet(100), [0 1]);
            mapIm = mapIm*0.5 + (single(im)/255)*0.5;
            figure(1),imshow(mapIm);
            mapIm = mat2im(mask_miss, jet(100), [0 1]);
            mapIm = mapIm*0.5 + (single(im)/255)*0.5;
            figure(2),imshow(mapIm);
            mapIm = mat2im(mask_crowd, jet(100), [0 1]);
            mapIm = mapIm*0.5 + (single(im)/255)*0.5;
            figure(3),imshow(mapIm);
            pause;
            close all;
        elseif flag > 1
            display([num2str(i) ' ' num2str(p)]);
        end
    end
end

save('coco_kpt_mask.mat', 'coco_kpt', '-v7.3');
