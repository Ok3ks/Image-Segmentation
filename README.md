# Image-Segmentation
This project required the matching of submitted colour patterns as an image to the standard colour pattern to be used in a game


#Abstract
This is a report about the process of building an image processing application for a game. The game requires players to reconstruct images from memory after being shown an image for a short period of time. The aim of the application is to interpret and compare brick patterns created by the player against original brick patterns. The methods employed in building this application includes thresholding and colour segmentation using hue values. Images were preprocessed by denoising and filtering with a gaussian filter.Distorted images were corrected using coordinates of the black circles as anchors.
Results obtained showing an overall 83.3% accuracy in the function. Challenges faced were the incorrect representation of green and yellow in certain images. Application will perform better with presence of less noise in images.
#Introduction
This is an Image processing application for a game - Lego’s life of George. Lego’s life of George is a game where the player is required to reconstruct a block from memory after being shown an image for a short period of time. The aim of this image processing application is to process the image reconstructed by the player. By processing the reconstructed image, it can be compared for correctness with the correct image. The basic requirement of this application is that the brick patterns from an image be correctly interpreted despite limiting circumstances. Limiting circumstances can include the possible conditions of the submitted image. Conditions such as image lighting, noise,certain degrees of rotation and camera angles(perspective from which the player captures the image), distracting background can be a barrier to the correct interpretation of colours present in the image.This application was created using the image processing toolbox in MATLAB.
#Methods
This section gives an overview and description of the techniques used in the creation of this application. Design decisions are explained and possible methods to improve performance. A family function colourMatrix employs smaller functions which carry out independent tasks. These smaller functions are loadImage, removeSmallElements, smoothedChannels, findCircles, correctImage and findColour. MATLAB functions are present in Appendix A.2.
Function loadImage
This function reads in images of type uint8 and outputs them to type double in the range [0, 1]. The conversion from an unsigned 8 bit integer system to a floating point system enables smooth
 computation and manipulation of pixel data. This is necessary for operations such as denoising, affine transformation on the images. Conversion to a floating point system also expands the range of possible values to negative values.
Function removeSmallElements
This function removes the presence of micro objects in the images.This objects,although insignificant to the eye, may affect computation later on. This process can be viewed as a first layer of denoising the image. This is done by eroding the image and then dilating the resulting image. The same structural element was used to maintain the form of the image as much as possible.
Function smoothedChannels
This function further denoises an image and outputs a filtered image. Filtering is done with MATLAB’s inbuilt function imgaussfilt. To prevent colour mixing,filtering is done in individual channels r,g, and b. After which each filtered channel is concatenated to make a new,filtered rgb channel for the image.
Function findCircles
This function returns the coordinates of circles/ellipses within an image. Fundamentally, this is built using the knowledge that the circles/ellipses are the darkest part of the image. The image is preprocessed within the function by converting it into a floating point system,denoising and filtering. After preprocessing, the image is binarized and thresholded to include only the darkest point of the image. The number of objects is then detected using the bwlabel 8 connected components system, and the centroid of each consequently calculated. The reasoning for the use of centroid is to accommodate asymmetric shapes that may result due to distortion. Imfindcircles is also not preferred as it requires fine tuning, and hard to generalise using one parameter setting.
Function correctImage
This function corrects a noisy or distorted image.Noisy images were denoised and filtered using prior functions smoothedChannels and removeSmallElements An undistorted image is required for accurate computation of the brick patterns. However, distortion could take many form.It could be a change in camera angle or rotation of the image. To build a robust function capable of accurately undistorting any image one has to consider major forms of distortion.The implemented function correctImage was however implemented using an MATLAB inbuilt function fitgeotrans which uses the four black circle coordinates of a reference image which is undistorted as the fixed point, Moving points are coordinates of the black circles/ellipses in the distorted image.Various conditional statements were created within by switching the options parameter in fitgeotrans between 'projective',and ‘affine’ depending on the form of distortion. This provides a transformation matrix which is used to transform the distorted image. Image is undistorted using imwarp and the size constrained using Rfixed. A form of improvement would be the ability to detect the form of distortion from image data instead of the file name as implemented using the set of simulated images.
Function findColours
The input of this function is the smoothed rgb double array to be interpreted.The function converts the rgb format to hsv using the rgb2hsv function. Output from this is then separated into three different arrays, each one representing the hue, saturation and value of the pixels in the image.The reason behind this is that separation of colours is sufficient using hues alone, as each colour in the image represents a hue, as opposed to the rgb scheme which could have values in more than one array (as certain secondary colours are made up of a mixture of certain proportions of red, green or blue)
After the separation into hues, two for loops are created to segment the images vertically and horizontally into smaller squares, such that the median of hue pixel intensities in the square represents the hue of the square. The output of the median is then scaled to 360(a scale which represents all hue values). Conditional statements using the standard hue scale and outputs the string r,g,b or y depending on the hue value present.
This is why the importance of the denoising is emphasised, the presence of noise will heavily skew the values thus leading to a wrong output of present colours,the median was also used as a sort array will have values for noise as outliers. This method also hinges on the correct and precise representation of each box taking into account the starting coordinates and the padding between each box. Values used in this report are a box size of 75 and padding of 10. Empty string arrays were also initialised to improve the speed of the program.
Function colourMatrix
This is a family function which implements and combines prior functions mentioned. This function was hard coded with ‘org_1_png’ as the reference image. Circle coordinates were obtained from this reference image using findCircle and then was used as input to correctImage in addition to the input image.The output is a colour matrix obtained with the function findColours.
