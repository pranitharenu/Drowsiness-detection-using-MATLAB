clear all;
clf('reset');
cam = webcam();
left= imread("left.png");
right=imread('right.png');
noface=imread('notVisible.jfif');
straight=imread('straight.jpg');

image(right)
detector = vision.CascadeObjectDetector(); % Create a detector
detector1 = vision.CascadeObjectDetector('EyePairSmall');
while true
    vid=snapshot(cam);
    image(vid)
    vid = rgb2gray(vid);
    image(vid)
    img = flip(vid, 2);
    image(img)
    bbox = step(detector, img);
    if ~ isempty(bbox)
        biggest_box=1;
        for i=1:rank(bbox) %find the biggest face
            if (bbox(i,3)>bbox(biggest_box,3))
                biggest_box=i;
            end
        end
        im2=bbox(biggest_box,:);
        faceImage = imcrop(img, [389 351 325 325]);
        bboxeyes = step(detector1, faceImage);
        subplot(2,2,1),imshow(img); hold on;
        for i=1:size(bbox,1) %draw all the regions that contain face
            rectangle('position', bbox(i, :), 'lineWidth', 2, 'edgeColor', 'y');
        end
        subplot(2,2,3),imshow(faceImage);
        if ~ isempty(bboxeyes)
            biggest_box_eyes=1;
            for i=1:rank(bboxeyes)
                if (bboxeyes(i,3)>bboxeyes(biggest_box_eyes,3))
                    biggest_box_eyes=i;
                end
            end
            bboxeyeshalf=[bboxeyes(biggest_box_eyes,1),bboxeyes(biggest_box_eyes,2),bboxeyes(biggest_box_eyes,3)/3,bboxeyes(biggest_box_eyes,4)];
            eyesImage = imcrop(faceImage,bboxeyeshalf(1,:));
            eyesImage = imadjust(eyesImage);
            r = bboxeyeshalf(1,4)/4;
            [centers, radii, metric] = imfindcircles(eyesImage, [floor(r-r/4)
                floor(r+r/2)], 'ObjectPolarity','dark', 'Sensitivity', 0.93);
            [M,I] = sort(radii, 'descend');
            eyesPositions = centers;
            subplot(2,2,2),imshow(eyesImage); hold on;
            viscircles(centers, radii,'EdgeColor','b');
            if ~isempty(centers)
                pupil_x=centers(1);
                disL=abs(0-pupil_x); %distance from left edge to center point
                disR=abs(bboxeyes(1,3)/3-pupil_x);%distance from right edge to center point
                subplot(2,2,4);
                if (disL>disR+16)
                    imshow(right);
                elseif (disR>disL)
                    imshow(left);
                else
                    imshow(straight);
                end
            end
        end
    else
        subplot(2,2,4);
        imshow(noface);
    end
    set(gca,'XtickLabel',[],'YtickLabel',[]);
    hold off;
end
