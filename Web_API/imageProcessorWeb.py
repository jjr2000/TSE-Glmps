import cv2
import numpy as np
import base64
from io import BytesIO
from PIL import Image
import mapper
import imutils
import sys
import googleCloud as gc
import log

from flask import Flask
from flask_restful import Resource, Api


def fromBase64(base64Data): #For converting a URL base64 string into a opencv image
        binary = base64.b64decode(base64Data)
        data = np.asarray(bytearray(binary), dtype="uint8")
        #log.write(f'data:{data}')
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
                        hull = cv2.approxPolyDP(hull,0.1*cv2.arcLength(hull,True),True) # Finding the approx shape based off the convex hull and arc lenght of the coords
                        if len(hull)==4: #If the shape has 4 points
                                cv2.drawContours(image,[hull],0,(0,255,0),4)
                                approx=mapper.mapp(hull)
                                points=np.float32([[0,0],[400,0],[400,400],[0,400]])  #map to 400*400 target image
                                perspective=cv2.getPerspectiveTransform(approx,points)  #get the top view effect
                                warp=cv2.warpPerspective(image,perspective,(400,400)) #if the album is at an angle then this will try and get it as if we were looking directly on top
                                return warp
        
        
def crop(image, coords):
        pass
        pts=np.float32([[0,0],[800,0],[800,800],[0,800]])  #map to 800*800 target window

        op=cv2.getPerspectiveTransform(approx,pts)  #get the top or bird eye view effect
        cv2.imshow("op", op)
        dst=cv2.warpPerspective(image,op,(800,800))
        cv2.imshow("final", dst)

def decodeBase64(filePath):     #I used this for debugging keeping it here incase its needed
        with open(filePath, "rb") as bruh:      #decoding from a URL safe base64 string from a txt file
            im = bruh.read()
        im = fromBase64(st3[2:-1])      #For whatever reason some extra characters get added during string encoding which is REQUIRED for any encoding or decoding so
                                        #these additional characters are always an additional " at the end and another b' at the start so be gone chars
        retval, buffer = cv2.imencode('.jpg', im)       #encoding the decoded base64 string as a jpg image 
        cv2.imshow("hellppp", buffer)
        


         
def findAlbum(b64String_in):
        #with open("12.jpg", "rb") as imageFile:
        #        st = base64.urlsafe_b64encode(imageFile.read())
        
        #then converting it back to a regular image, this will all be replaced when integrated with the web api
        img = fromBase64(b64String_in)
        #cv2.imwrite('imgBase.jpeg', img)
        image= img
        #image = scale(image, 20) #scaling the image, but this is no longer required as the application will scale to reduce bandwidth needs and server processing

        processed = imageProc(image) #applying image processing techniques
        #cv2.imwrite('processed.jpeg', processed)
        image = contours(image,processed) #finding the contours and convexhull to find the album cover, then it gets cropped
        b64String_out = None    #if the album is not found it will default to None
        #cv2.imwrite('image.jpeg', image)
        #log.write(f'pre Try:{image}')
        try:
                retval, buffer = cv2.imencode('.jpg', image) #encoding the image as a jpg
                #log.write(f'buffer:{buffer}')
                bufferString = base64.b64encode(buffer)
                b64String_out = gc.detect_web(bufferString)
                #log.write(f'b64String_out:{b64String_out}')
                #b64String_out = str(base64.urlsafe_b64encode(buffer)) #then encoding the image and converting it to a string so the server can return it with json
                #return b64String_out #found album returned
        except:
                return null
        else:
                return b64String_out
        
        
        




