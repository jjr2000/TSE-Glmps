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

def index():
    return "hello welcome to GLIMPS, don't poke around here to much\n might crash"



class imageSend(Resource):
    def get(self, string):
        #print(type(string), file=sys.stderr)
        #pls = string.encode("utf-8")
        string = bytearray(string, 'utf-8')
        foundAlbum = ipw.findAlbum(string[2:-1])
        #print(foundAlbum[:10])
        return {"image" : foundAlbum}


api.add_resource(imageSend, '/imageSend/<string>')

if __name__ == '__main__':
    app.run(debug=True)

    
