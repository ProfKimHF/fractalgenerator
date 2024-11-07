clear all
clearvars

fractal_path = '/Users/prof.f/Downloads/image_medium_gif';
export_folder = '/Users/prof.f/Downloads/Fractal_lum_export';

cd(fractal_path);
startN = 0; % object set start number
endN = 999; % object set end number
totalN = 0;
% 1 to 12 objects
substartn = 1; % object start num in a set
subendn = 12; % object end num in a set
%% Put the image data to the cells
for i=startN:endN
    for sub_i = substartn:subendn
        % Load image file name
        if sub_i < 10
            imgname = sprintf('image00%d0%d.gif',i,sub_i);
            final_imgname = sprintf('image00%d0%d',i,sub_i);
        else
            imgname = sprintf('image00%d%d.gif',i,sub_i);
            final_imgname = sprintf('image00%d%d',i,sub_i);
        end
        %imgname
        
        if exist(imgname,'file') % due to noncontinuous file name
            totalN = totalN + 1;
        else
            continue;
        end
        
        [tempimg, map] = imread(imgname);
        %close all; figure(1); hold on; subplot(2,3,1); imshow(tempimg,map); title('original gif')
      %1. convert to rgb space color
        rgb_img = ind2rgb(tempimg, map);
            
        %subplot(2,3,2); imshow(rgb_img); title('gif2rgb convert1')
        lab_space_img = rgb2lab(rgb_img); % change to the lab space color
              
        rgb_img_again = lab2rgb(lab_space_img);
        %subplot(2,3,3); imshow(rgb_img_again);title('lab2rgb convert')
        
        original_cell{totalN,1} = rgb_img;
        name_cell{totalN,1} = final_imgname;
        
        % Convert background color from black to grey
        redD = rgb_img(:,:,1);
        greenD = rgb_img(:,:,2);
        blueD = rgb_img(:,:,3);
        binaryred = redD == 0;
        binarygreen = greenD == 0;
        binaryblue = blueD == 0;
        mask = binaryred & binarygreen & binaryblue;
        mask_cell{totalN,1} = mask;
        acolorval = 1;
        redD(mask(:)==1) = acolorval;
        greenD(mask(:)==1) = acolorval;
        blueD(mask(:)==1) = acolorval;
        maskedimg(:,:,1) = redD;
        maskedimg(:,:,2) = greenD;
        maskedimg(:,:,3) = blueD;
        masked_cell{totalN,1} = maskedimg;
        
        %Convert colorspace from RGB to Lab
        templab = rgb2lab(maskedimg);
        %subplot(2,3,4); imshow(maskedimg);title('rgb2lab')
        
        lab_cell{totalN,1} = templab;
        templum = templab(:,:,1);
        lum_cell{totalN,1} = templum;
    end 
end  
%% Adjust the luminance
        original_cell(~cellfun('isempty',original_cell));
        
        match_cell = SHINE(lum_cell) % for luminance match, enter 2,1,1,1
        
        recover_cell = cell(size(match_cell,1),1);
%% Crop to make the same size of objects and export
        
        for i=1:size(match_cell,1)
            % Convert from cell to mat
            matchedlum = cell2mat(match_cell(i,1));
            labimg = cell2mat(lab_cell(i,1));
            mask = cell2mat(mask_cell(i,1));
            
            % Convert colorspace from Lab to RGB
            labimg(:,:,1) = matchedlum;
            temprecover = lab2rgb(labimg);
            recover_cell{i,1} = temprecover;
            
            % Fill backgroundcolor
            redD2 = temprecover(:,:,1);
            greenD2 = temprecover(:,:,2);
            blueD2 = temprecover(:,:,3);
            redD2(mask(:)==1) = 0/255;
            greenD2(mask(:)==1) = 0/255;
            blueD2(mask(:)==1) = 0/255;
            constbg(:,:,1) = redD2;
            constbg(:,:,2) = greenD2;
            constbg(:,:,3) = blueD2;
            constbg_cell{totalN,1} = constbg;
            
            % Crop image
            [row,col] = find(~mask);
            if min(row) == 1
                first_row = min(row);
            else
                first_row = min(row)-1;
            end
            if max(row) == size(constbg,1);
                last_row = max(row);
            else
                last_row = max(row)+1;
            end
            if min(col) == 1
                first_col = min(col);
            else
                first_col = min(col)-1;
            end
            if max(col) == size(constbg,2);
                last_col = max(col);
            else
                last_col = max(col)+1;
            end
            cropped_img = constbg(first_row:last_row,first_col:last_col,:);
            cropped_img = imresize(cropped_img,[400 400]); %Image size adjust
            final_cell{i,1} = cropped_img;
           %imshow(cropped_img)
            
         %Export image
            filenum = name_cell{i,1};
            cd(export_folder)
            imwrite(cropped_img, [filenum,'.tif'],'tif');
            
        end 

 %% Remove the background color and make transparent (outcome is gif)
   cd(export_folder)
        
  for i=startN:endN
        for sub_i = substartn:subendn
            % Load image file name
            if sub_i < 10
                final_imgname = sprintf('image00%d0%d.tif',i,sub_i);
            else
                final_imgname = sprintf('image00%d%d.tif',i,sub_i);
            end
            %final_imgname
            imshow(final_imgname)
           
            set(gca,'position',[0 0 1 1],'units','normalized') 
            fig = gcf;
            fig.PaperUnits = 'centimeter';
            fig.PaperPosition = [0 0 20 20]; %figure size: centimeter
           
            printgif(final_imgname);
        end
  end
        