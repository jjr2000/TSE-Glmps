import cv2
import numpy as np
import base64
from io import BytesIO
from PIL import Image
import mapper
import imutils
import sys

from flask import Flask
from flask_restful import Resource, Api


def fromBase64(base64Data): #For converting a URL base64 string into a opencv image
        #print(base64Data[:10])
        #base64Data = base64.urlsafe_b64encode(base64Data)

        file1 = open("post.txt", "w")
        file2 = open("after.txt","w")
        file1.write(str(base64Data))
        decodedData = base64.urlsafe_b64decode(base64Data) #Decoding
        file2.write(str(decodedData))
        data = np.fromstring(decodedData,np.uint8) #Formatting into a numpy array which opencv can work with
        image = cv2.imdecode(data,cv2.COLOR_RGB2BGR) #Opencv encoding the aray into a RGB colour image 
        return image


def scale(image, ratio):    #Scale function 

        scale = ratio #Scale factor to reduce image size
        width = int(image.shape[1] * scale / 100)
        height = int(image.shape[0] * scale / 100)
        dimensions = (width, height)
        image=cv2.resize(image,dimensions, interpolation = cv2.INTER_AREA) #Resizing the image
        return image


def imageProc(image):   #Function contains all image processing (colour grading, threshholding, bluring etc)

        gray = cv2.cvtColor(image,cv2.COLOR_BGR2GRAY) #Converting to grayscale
        #cv2.imshow("gray", gray)

        blur = cv2.GaussianBlur(gray,(5,5),0) #performing a gaussian blur
        #cv2.imshow("blur", blur)

        _,thresh = cv2.threshold(blur,0,255,cv2.THRESH_BINARY+cv2.THRESH_OTSU) #An adaptive thresh hold using Otsu's algorithm, helps with hight contrast
        #cv2.imshow("thresh", thresh)
    
        kernel = np.ones((5,5),np.uint8)
        erosion = cv2.erode(thresh,kernel,iterations = 0)
        #cv2.imshow("err", erosion)
        dilation = cv2.dilate(erosion,kernel,iterations = 0)
        #cv2.imshow("dil", dilation)
        #gradient = cv2.morphologyEx(dilation, cv2.MORPH_BLACKHAT, kernel)
        #cv2.imshow("grad", gradient)
    
        return dilation

def contours(image,processed):
        contours,hier = cv2.findContours(processed,cv2.RETR_LIST,cv2.CHAIN_APPROX_SIMPLE) #Finding contours in the image
        #30000,200000 seem to be the right values 
        for cnt in contours: #Going through the array of contours
                if cv2.contourArea(cnt)>30000 and cv2.contourArea(cnt)<200000:  # remove small areas like noise etc but also preventing too big of a shape being found
                        hull = cv2.convexHull(cnt)    # find the convex hull of contour
                        #cv2.circle(image,(77,285),5,[200,150,255],-1) # this is just for testing where certaint coordinates are
                        #print(hull)
                        hull = cv2.approxPolyDP(hull,0.1*cv2.arcLength(hull,True),True) # Finding the approx shape based off the convex hull and arc lenght of the coords
                        #print("after approx poly", hull, "end")
                        if len(hull)==4: #If the shape has 4 points
                                #cv2.drawContours(image,[hull],0,(0,255,0),4) #drawing the shape
                                #crop(image,hull)
                                #(x,y,w,h) = (hull)
                                #print(x,y,w,h)

                                approx=mapper.mapp(hull)
                                pts=np.float32([[0,0],[400,0],[400,400],[0,400]])  #map to 800*800 target window

                                op=cv2.getPerspectiveTransform(approx,pts)  #get the top or bird eye view effect
                                #cv2.imshow("op", op)
                                dst=cv2.warpPerspective(image,op,(400,400))
                                #cv2.imshow("final", dst)
                                return dst
        #processed = cv2.bitwise_not(processed)
        #cv2.imshow("invt",processed)
        print("no album found")
        return 0

def crop(image, coords):
        pass
        pts=np.float32([[0,0],[800,0],[800,800],[0,800]])  #map to 800*800 target window

        op=cv2.getPerspectiveTransform(approx,pts)  #get the top or bird eye view effect
        cv2.imshow("op", op)
        dst=cv2.warpPerspective(image,op,(800,800))
        cv2.imshow("final", dst)

def decodeBase64(filePath):
        
        with open(filePath, "rb") as bruh:
            im = bruh.read()
        im = fromBase64(st3[2:-1])
        retval, buffer = cv2.imencode('.jpg', im)
        cv2.imshow("hellppp", buffer)
        
         
def findAlbum(b64String_in):
        #then converting it back to a regular image, this will all be replaced when integrated with the web api
        img = fromBase64(b64String_in)
        image= img
        #image = scale(image, 20) #scaling the image
        #scaled = image
        processed = imageProc(image) #applying image processing techniques
        image = contours(image,processed)
        #if len(image) == 0:
        #        return "Failed"
        #else:
        retval, buffer = cv2.imencode('.jpg', image)
        b64String_out = str(base64.urlsafe_b64encode(buffer))
        return b64String_out


        




