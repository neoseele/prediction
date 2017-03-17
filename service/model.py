# -*- coding: utf-8 -*-
from flask import Flask, current_app
import cv2
from keras.models import load_model
from config import IMAGE_SIZE
from service import utils

def predict(model_path, image):
    model = load_model(model_path)
    current_app.logger.info(utils.debug('A'))

    # useful when testing with full size image
    if image.shape != (IMAGE_SIZE, IMAGE_SIZE, 3):
        image = utils.resize_with_pad(image)

    image = image.reshape((1, IMAGE_SIZE, IMAGE_SIZE, 3))
    image = image.astype('float32')
    image /= 255

    result = model.predict_proba(image) # numpy.ndarray
    print(result)
    current_app.logger.info(utils.debug('b'))

    # predictions = result[0].tolist()
    # if predictions[0] > 0.8:
    #     return 0 # boss
    # else:
    #     return 1 # non boss

    result = model.predict_classes(image)
    current_app.logger.info(utils.debug('c'))

    return result[0]
