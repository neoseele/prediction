# -*- coding: utf-8 -*-
import cv2
import datetime

def resize_with_pad(image, height, width):

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
    constant = cv2.copyMakeBorder(
        image, top , bottom, left, right,
        cv2.BORDER_CONSTANT, value=BLACK)
    resized_image = cv2.resize(constant, (height, width))

    return resized_image


def debug(msg):
    print("DEBUG:{} [{}]".format(
        msg, datetime.datetime.now().strftime("%Y%m%d_%H%M%S_%f"))
    )
