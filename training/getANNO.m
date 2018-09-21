dataType = '';
addpath('dataset/COCO/coco/MatlabAPI');

mkdir('dataset/COCO/mat')

annTypes = { 'instances', 'captions', 'person_keypoints' };
annType=annTypes{3}; % specify dataType/annType

coco_kpt = [];
cnt = 0;
imgdir = dir('dataset/COCO/images/*/coco.json');
for i = 1 : length(imgdir)
    annFile = fullfile(imgdir(i).folder, imgdir(i).name);
    fprintf('%s\n', annFile);
    
    coco=CocoApi(annFile);
    my_anno = coco.data.annotations;
	images = coco.data.images;
    prev_id = -1;
    p_cnt = 1;
    
    for j = 1:1:size(my_anno,2)
        
        curr_id = my_anno(j).image_id;
        if(curr_id == prev_id)
            p_cnt = p_cnt + 1;
        else
            p_cnt = 1;
            cnt = cnt + 1;
        end
		imgIndex = find([images.id] == curr_id);
        coco_kpt(cnt).image_id = curr_id;
		coco_kpt(cnt).image = sprintf('%s/%s', imgdir(i).folder, images(imgIndex).file_name);
        coco_kpt(cnt).annorect(p_cnt).bbox = my_anno(j).bbox;
        coco_kpt(cnt).annorect(p_cnt).segmentation = my_anno(j).segmentation;
        coco_kpt(cnt).annorect(p_cnt).area = my_anno(j).bbox(3) * my_anno(j).bbox(4);
        coco_kpt(cnt).annorect(p_cnt).id = my_anno(j).id;
        coco_kpt(cnt).annorect(p_cnt).iscrowd = my_anno(j).iscrowd;
        coco_kpt(cnt).annorect(p_cnt).keypoints = my_anno(j).keypoints;
        coco_kpt(cnt).annorect(p_cnt).num_keypoints = my_anno(j).num_keypoints;
        coco_kpt(cnt).annorect(p_cnt).img_width = coco.loadImgs(curr_id).width;
        coco_kpt(cnt).annorect(p_cnt).img_height = coco.loadImgs(curr_id).height;
        
        prev_id = curr_id;
        
        %fprintf('%d/%d \n', j, size(my_anno, 2));
    end
end
save('dataset/COCO/mat/coco.mat', 'coco_kpt');
