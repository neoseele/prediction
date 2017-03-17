# -*- coding: utf-8 -*-
from __future__ import print_function
import random

import os
import cv2
import numpy as np

from keras.optimizers import SGD
from keras.models import load_model
from keras import backend as K

IMAGE_SIZE = 64

def resize_with_pad(image, height=IMAGE_SIZE, width=IMAGE_SIZE):

    def get_padding_size(image):
        h, w, _ = image.shape
        longest_edge = max(h, w)
        top, bottom, left, right = (0, 0, 0, 0)
        if h < longest_edge:
            dh = longest_edge - h
            top = dh // 2
            bottom = dh - top
        elif w < longest_edge:
            dw = longest_edge - w
            left = dw // 2
            right = dw - left
        else:
            pass
        return top, bottom, left, right

    top, bottom, left, right = get_padding_size(image)
    BLACK = [0, 0, 0]
    constant = cv2.copyMakeBorder(image, top , bottom, left, right,
        cv2.BORDER_CONSTANT, value=BLACK)
    resized_image = cv2.resize(constant, (height, width))

    return resized_image

def predict(model_path, image):
    model = load_model(model_path)

    if image.shape != (1, IMAGE_SIZE, IMAGE_SIZE, 3):
        image = resize_with_pad(image)
        image = image.reshape((1, IMAGE_SIZE, IMAGE_SIZE, 3))

    image = image.astype('float32')
    image /= 255
    result = model.predict_proba(image) # numpy.ndarray
    print(result)

    # predictions = result[0].tolist()
    # if predictions[0] > 0.8:
    #     return 0 # boss
    # else:
    #     return 1 # non boss

    result = model.predict_classes(image)
    return result[0]
