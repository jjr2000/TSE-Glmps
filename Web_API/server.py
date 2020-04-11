from flask import Flask
from flask_restful import Resource, Api
import cv2
import numpy as np
import imageProcessorWeb as ipw #image processing module
import base64
from io import BytesIO
from PIL import Image
import mapper
import imutils
import sys

app = Flask(__name__)
api = Api(app)

@app.route('/')

def index(): #Default index of the website
    return "hello welcome to GLIMPS, don't poke around here to much\n might crash"



class imageSend(Resource): #function call for the /imageSend/ url
    def get(self, string): #this is a get request
        string = bytearray(string, 'utf-8') #encoding the base64 string as utf-8 then turning it into a byte array so it can be decoded and encoded as a jpg correctly
        foundAlbum = ipw.findAlbum(string[2:-1]) #the encoding adds some additional characters to the front and back of the array, this removes them
        return {"image" : foundAlbum} #URL safe base64 string is returned in JSON


api.add_resource(imageSend, '/imageSend/<string>') #adding this function to the API

if __name__ == '__main__':
    app.run(debug=True)

    
