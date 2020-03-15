import io, os
from google.cloud import vision

os.environ['GOOGLE_APPLICATION_CREDENTIALS'] = r"VisionAPiTest-9a0fd4175f77.json"
client = vision.ImageAnnotatorClient()

file_name = "webtestimg.jpg"
with io.open(file_name, 'rb') as image_file:
    content = image_file.read()

image = vision.types.Image(content=content)
response = client.web_detection(image=image)
web_detection = response.web_detection

web_detection.best_guess_labels
web_detection.full_matching_images
web_detection.pages_with_matching_images

for entity in web_detection.web_entities:
    print(entity.description)
    print(entity.score)
    print('-'*70)
