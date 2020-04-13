import requests
import json
import base64
import log
import io
from PIL import Image
newsize = (806, 381)

image_file = Image.open("Image_Processor/4.jpg")  
im = image_file.resize(newsize)
angle = 270
out = im.rotate(angle, expand=True)
imgByteArr = io.BytesIO()
out.save(imgByteArr, format='JPEG')
imgByteArr = imgByteArr.getvalue()
base64string = str(base64.b64encode(imgByteArr))[2:-1]


url = f'http://127.0.0.1:5000/imageSend?image={base64string}'

log.write(url)

payload = {}
headers= {}

response = requests.request("POST", url, headers=headers)

print(response.text)
