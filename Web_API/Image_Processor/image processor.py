import cv2
import numpy as np
import base64
from io import BytesIO
from PIL import Image
import imutils
import sys

def from_base64(base64_data): #For converting a URL base64 string into a opencv image
        decodedData = base64.urlsafe_b64decode(base64_data) #Decoding
        
        data = np.fromstring(decodedData,np.uint8) #Formatting into a numpy array which opencv can work with
        image = cv2.imdecode(data,cv2.COLOR_RGB2BGR) #Opencv encoding the aray into a RGB colour image 
        return image


#Just for the sake of testing I have been encoding the image as
#a URL safe base64 string
with open("7.jpg", "rb") as imageFile:
    st = base64.urlsafe_b64encode(imageFile.read())
    
#then converting it back to a regular image
img = from_base64(st)
image= img


scale = 20 #Scale factor to reduce image size
width = int(image.shape[1] * scale / 100)
height = int(image.shape[0] * scale / 100)
dimensions = (width, height)
image=cv2.resize(image,dimensions, interpolation = cv2.INTER_AREA) #Resizing the image

gray = cv2.cvtColor(image,cv2.COLOR_BGR2GRAY) #Converting to grayscale
cv2.imshow("gray", gray)

blur = cv2.GaussianBlur(gray,(5,5),0) #performing a gaussian blur
cv2.imshow("blur", blur)

ret3,thresh = cv2.threshold(blur,0,255,cv2.THRESH_BINARY+cv2.THRESH_OTSU) #An adaptive thresh hold using Otsu's algorithm, helps with hight contrast
cv2.imshow("thresh", thresh)

contours,hier = cv2.findContours(thresh,cv2.RETR_LIST,cv2.CHAIN_APPROX_SIMPLE) #Finding contours in the image
#30000,200000
for cnt in contours: #Going through the array of contours
    if cv2.contourArea(cnt)>30000 and cv2.contourArea(cnt)<200000:  # remove small areas like noise etc but also preventing too big of a shape being found
        hull = cv2.convexHull(cnt)    # find the convex hull of contour
        cv2.circle(image,(77,285),5,[200,150,255],-1) # this is just for testing where certaint coordinates are
        print(hull)
        hull = cv2.approxPolyDP(hull,0.1*cv2.arcLength(hull,True),True) # Finding the approx shape based off the convex hull and arc lenght of the coords
        print("after approx poly", hull, "end")
        if len(hull)==4: #If the shape has 4 points
            cv2.drawContours(image,[hull],0,(0,255,0),4) #drawing the shape
            (x,y,w,h) = (hull)
            print(x,y,w,h)

cv2.imshow('img',image)
cv2.waitKey(0)
cv2.destroyAllWindows()
