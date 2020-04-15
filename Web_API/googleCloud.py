import log

def detect_web(imageBase):
    """Detects web annotations given an image."""
    from google.cloud import vision
    import io
    import base64
    try:
        log.write('pre client load')
        client = vision.ImageAnnotatorClient()
        log.write('client loaded')
        #imageBaseAsBytes = base64.b64decode(imageBase)
        #log.write(f'imageBase: {imageBase}')
        imageBaseAsBytes = base64.b64decode(imageBase)
        #log.write(f'imageBaseAsBytes: {imageBaseAsBytes}')
        image = vision.types.Image(content=imageBaseAsBytes)
        log.write('image element made')
        #log.write('image Loaded')
        response = client.web_detection(image=image)
        #log.write('response Loaded')
        log.write(f'Response:/n{response}')
        annotations = response.web_detection

        if annotations.best_guess_labels:
            for label in annotations.best_guess_labels:
                return label.label

    except Exception as err:
        log.write(err)

    return None

"""    if annotations.best_guess_labels:
        for label in annotations.best_guess_labels:
            print('\nBest guess label: {}'.format(label.label))

    if annotations.pages_with_matching_images:
        print('\n{} Pages with matching images found:'.format(
            len(annotations.pages_with_matching_images)))

        for page in annotations.pages_with_matching_images:
            print('\n\tPage url   : {}'.format(page.url))

            if page.full_matching_images:
                print('\t{} Full Matches found: '.format(
                       len(page.full_matching_images)))

                for image in page.full_matching_images:
                    print('\t\tImage url  : {}'.format(image.url))

            if page.partial_matching_images:
                print('\t{} Partial Matches found: '.format(
                       len(page.partial_matching_images)))

                for image in page.partial_matching_images:
                    print('\t\tImage url  : {}'.format(image.url))

    if annotations.web_entities:
        print('\n{} Web entities found: '.format(
            len(annotations.web_entities)))

        for entity in annotations.web_entities:
            print('\n\tScore      : {}'.format(entity.score))
            print(u'\tDescription: {}'.format(entity.description))

    if annotations.visually_similar_images:
        print('\n{} visually similar images found:\n'.format(
            len(annotations.visually_similar_images)))

        for image in annotations.visually_similar_images:
            print('\tImage url    : {}'.format(image.url))

    if response.error.message:
        raise Exception(
            '{}\nFor more info on error messages, check: '
            'https://cloud.google.com/apis/design/errors'.format(
                response.error.message)) """

