# -*- coding: utf-8 -*-
from flask import Flask, current_app
from keras.models import load_model
from service import utils


def predict(image):
    image_size = current_app.config['IMAGE_SIZE']
    model_path = current_app.config['MODEL_PATH']

    model = load_model(model_path)

    # useful when testing with full size image
    if image.shape != (image_size, image_size, 3):
        image = utils.resize_with_pad(image, image_size, image_size)

    image = image.reshape((1, image_size, image_size, 3))
    image = image.astype('float32')
    image /= 255

    result = model.predict_proba(image)  # numpy.ndarray
    print(result)

    # predictions = result[0].tolist()
    # if predictions[0] > 0.8:
    #     return 0 # boss
    # else:
    #     return 1 # non boss

    result = model.predict_classes(image)

    return result[0]
