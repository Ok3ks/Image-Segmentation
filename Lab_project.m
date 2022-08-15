%Reads colour pattern image from hard-disc 
% and returns an array representing the colour pattern 
% result = colourMatrix(filename)
% Location of the black circles is used for finding the
% edge of the image 
% jf

image1 = 'org_1.png'; image2 = 'proj_3.png';

colormat = colourMatrix(image1,image2);

figure(1)
imshowpair(loadImage(image1),loadImage(image2),"montage")



function [col_arr] = colourMatrix(image1,image2)
%performs all operations in one go 

%Loads in a reference, undistorted, image1 'org_1.png'
%if startsWith(image2, ['rot','proj','proj1','proj2'])
%corrects and undistorts the image
%co_ord = circleCoordinates(image1);

new_b_img = correctImage(image1,image2);
%end

a = loadImage(image1); b = loadImage(image2);
figure(2)
imshowpair(new_b_img, b, "montage")

%finds the color array of the corrected image
%cor_img = imguidedfilter(new_b_img,a);

cor_img = new_b_img;
col_arr = findColours(cor_img);

end


function [registered] = correctImage(ref_img, img)
% Function un-distorts the remaining images using the 
% circle coordinates as an anchor

a = loadImage(ref_img); b = loadImage(img);

org_circ_coord = circleCoordinates(a);

centroids = circleCoordinates(b);

%Undistort
%centroids: Moving points are circle coordinates of distorted points
%org_circ_coord:Fixed points are circle coordinates of undistorted images

%for warped transformation, use projective
mytform = fitgeotrans(centroids, org_circ_coord, 'projective');

%creating fixed size of output image using ortho image as a reference
Rfixed = imref2d(size(ref_img));

%constrains registered to this size
registered = imwarp(b,mytform,OutputView=Rfixed);

%crops to size of reference image
croppedImage = imcrop(registered, [0,0,480,480]);

end

function [org_circ_coord] = circleCoordinates(image)
%Finds the coordinates of the four black circles

new_ref = smoothedchannels(image);


ref_img_bw = im2bw(new_ref,0.1);

%inverts the mask for better identification
ref_img_bw = ~ref_img_bw;


%use of bwlabel for precision in identification of objects
[ref_label,~] = bwlabel(ref_img_bw,8);

%calculates centroids of each shape as coordinate
k = regionprops(ref_label,"Centroid");

%concatenates each coordinate value into an array
org_circ_coord = cat(1,k.Centroid);
end 

function [new_rgb] = smoothedchannels(new_img)

ref = new_img;

ref_red = ref(:,:,1);
ref_green = ref(:,:,2);
ref_blue = ref(:,:,3);

ref_red_smth = imgaussfilt(ref_red,2.5);
ref_green_smth = imgaussfilt(ref_green,2.5);
ref_blue_smth = imgaussfilt(ref_blue,2.5);

%Creates new smoothed Rgb space
new_rgb = cat(3, ref_red_smth, ref_green_smth, ref_blue_smth);
end

function [col_arr] = findColours(new_img)
%Finds the colours from a double image array, and returns the result of the
%colours

hsv = rgb2hsv(new_img);

%Finding Hue
h = hsv(:,:,1);

box_size = 75;
padding = 10;

col_arr = strings(4,4);

%Moving across the square verically and horizonatally
for a=0:3
    for b= 0:3 

        hue = h(75+(a*box_size)+padding*a:150+(a*box_size)+padding*a, 75+(b*box_size)+padding*b:150+b*box_size+padding*b);


        M = mean(hue, 'all') * 360;

        if M < 15 || M > 330
            col_arr(a+1,b+1) = "r";     
        end
        if M > 90 && M < 135
            col_arr(a+1,b+1) = "g";
        end
        if M > 195 && M < 265
            col_arr(a+1,b+1) = "b";
        end

        if M > 30 && M < 60
            col_arr(a+1,b+1) = "y";
        end
    end
end

end


function [img] = loadImage(filename)
%Takes in a file of type uint8 and outputs an
% array of type double 
img = imread(filename);
if isa(img,'uint8')
    img = double(img)/255;
else
    error("This image is a of unkown type")
end
end
