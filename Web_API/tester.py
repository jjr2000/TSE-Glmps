import requests
import json
import base64
import log
import io
from PIL import Image
newsize = (380, 806)

image_file = Image.open("Image_Processor/1.jpg")  
image_file = image_file.resize(newsize)
imgByteArr = io.BytesIO()
image_file.save(imgByteArr, format='JPEG')
imgByteArr = imgByteArr.getvalue()
base64string = str(base64.b64encode(imgByteArr))[2:-1]


url = f'http://127.0.0.1:5000/imageSend?image={base64string}'

log.write(url)

payload = {}
headers= {}

response = requests.request("POST", url, headers=headers)

print(response.text)
