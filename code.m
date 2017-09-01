im = imread('YOUR/PICTURE/PATH.jpg');
im = rgb2gray(im);
scale = 1 / ((size(im, 1) * size(im, 2)) / (1000*500));
im = imresize(im, scale);
% figure imshow(im);
% figure imhist(im);

[level,EM] = graythresh(im);
BW = imbinarize(im,level);
% figure imshowpair(im,BW,'montage');

im_fill = imfill(BW, 'holes');
% figure imshow(im_fill);
im_addad = im_fill - BW;
% figure imshow(im_addad);
se = strel('square', 3);
im_addad = imopen(im_addad, se);
im_addad = imclose(im_addad, se);
% figure imshow(im_addad);
im_addad2 = ~im_addad;
% figure, imshow(im_addad2);
im_fill = im_fill .* im_addad2;
% figure, imshow(im_fill);


numberOfPixel = double(uint16(size(im, 1) * size(im, 2) * 0.001));
im_fill2 = bwareaopen(im_fill, min(numberOfPixel, 100));
% figure, imshow(im_fill2);
% im_fill3 = ~bwareaopen(~im_fill2, min(numberOfPixel, 50));
% figure imshow(im_fill3);

stats = regionprops(im_fill2,'all');
% im_masked = im;
% im_masked2 = uint8(zeros(size(im)));

index = [];

for I = 1:size(stats, 1)
    upper_left_x = stats(I).BoundingBox(1);
    upper_left_y = stats(I).BoundingBox(2);
    x_width = stats(I).BoundingBox(3);
    y_width = stats(I).BoundingBox(4);
    lower_right_x = upper_left_x + x_width;
    lower_right_y = upper_left_y + y_width;
    upper_left_x_int = int32(upper_left_x);
    upper_left_y_int = int32(upper_left_y);
        
    nesbat = x_width/y_width;
    if nesbat < 6 && nesbat > 2 && stats(I).Orientation > -20 && stats(I).Orientation < 20 &&  stats(I).EulerNumber <= -2 && stats(I).EulerNumber >= -9
        index = [index, I];
%         disp(['I = ', num2str(I)])
    end
    
%     im_masked(upper_left_y_int:upper_left_y_int+y_width-1, upper_left_x_int:upper_left_x_int+x_width-1) = im_masked(upper_left_y_int:upper_left_y_int+y_width-1, upper_left_x_int:upper_left_x_int+x_width-1) .* uint8(~stats(I).Image);
%     im_masked2(upper_left_y_int:upper_left_y_int+y_width-1, upper_left_x_int:upper_left_x_int+x_width-1) = im_masked2(upper_left_y_int:upper_left_y_int+y_width-1, upper_left_x_int:upper_left_x_int+x_width-1) + im_masked(upper_left_y_int:upper_left_y_int+y_width-1, upper_left_x_int:upper_left_x_int+x_width-1);
end

figure, imshow(im);
hold on;
for I = 1:size(index, 2)
    upper_left_x = stats(index(I)).BoundingBox(1); upper_left_x = upper_left_x - (x_width.*0.1);
    upper_left_y = stats(index(I)).BoundingBox(2);
    x_width = stats(index(I)).BoundingBox(3); x_width = x_width + (x_width .* 0.4);
    y_width = stats(index(I)).BoundingBox(4);
    lower_right_x = upper_left_x + x_width;
    lower_right_y = upper_left_y + y_width;
        
    line([upper_left_x upper_left_x+x_width],[upper_left_y upper_left_y],'LineWidth', 3, 'Color','green');
    line([upper_left_x upper_left_x],[upper_left_y upper_left_y+y_width],'LineWidth', 3, 'Color','green');
    line([lower_right_x lower_right_x-x_width],[lower_right_y lower_right_y],'LineWidth', 3, 'Color','green');
    line([lower_right_x lower_right_x],[lower_right_y lower_right_y-y_width],'LineWidth', 3, 'Color','green');
end
hold off;


for I = 1:size(index, 2)
    upper_left_x = stats(index(I)).BoundingBox(1); upper_left_x = upper_left_x - (upper_left_x.*0.1);
    upper_left_y = stats(index(I)).BoundingBox(2);
    x_width = stats(index(I)).BoundingBox(3); x_width = x_width + (x_width .* 0.4);
    y_width = stats(index(I)).BoundingBox(4);
    lower_right_x = upper_left_x + x_width;
    lower_right_y = upper_left_y + y_width;

    stats2 = regionprops(~im_addad2,'all');
    figure;
    num_counter = 0;
    for Y = 1:size(stats2, 1)
        upper_left_x_s2 = stats2(Y).BoundingBox(1);
        upper_left_y_s2 = stats2(Y).BoundingBox(2);
        x_s2_width = stats2(Y).BoundingBox(3);
        y_s2_width = stats2(Y).BoundingBox(4);
        lower_right_x_s2 = upper_left_x_s2 + x_s2_width;
        lower_right_y_s2 = upper_left_y_s2 + y_s2_width;
        upper_left_x_s2_int = int32(upper_left_x_s2);
        upper_left_y_s2_int = int32(upper_left_y_s2);

        nesbat = y_s2_width/x_s2_width;
        
       if num_counter < 12 && upper_left_x_s2 >= upper_left_x && upper_left_y_s2 >= upper_left_y && upper_left_x_s2 <= lower_right_x && upper_left_y_s2 <= lower_right_y
            num_counter = num_counter + 1;
            subplot(1, 12, num_counter);
            imshow(imresize(im(upper_left_y_s2:upper_left_y_s2+y_s2_width, upper_left_x_s2:upper_left_x_s2+x_s2_width), 10));
       end
    end
end