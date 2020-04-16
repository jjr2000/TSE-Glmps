from flask import Flask
from flask_restful import Resource, Api, reqparse
import cv2
import numpy as np
import imageProcessorWeb as ipw #image processing module
import base64
from io import BytesIO
from PIL import Image
import mapper
import imutils
import sys
import log

app = Flask(__name__)
api = Api(app)

@app.route('/')

def index(): #Default index of the website
    return "hello welcome to GLIMPS, don't poke around here too much, it might crash :/"

class imageSend(Resource): #function call for the /imageSend/ url
    def post(self): #this is a post request
        parser = reqparse.RequestParser()
        parser.add_argument('image', type=str, location='form')
        args = parser.parse_args()
        img = args['image'].replace(" ", "+")
        #img = bytearray(str(args['image']), 'utf-8')
        #foundAlbum = ipw.findAlbum(args['image']) #the encoding adds some additional characters to the front and back of the array, this removes them
        foundAlbum = ipw.findAlbum(img)
        return {"image" : foundAlbum} #URL safe base64 string is returned in JSON

api.add_resource(imageSend, '/imageSend')

if __name__ == '__main__':
    app.run(debug=True)

    
