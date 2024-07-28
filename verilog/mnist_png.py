from tensorflow.keras.datasets import mnist
import numpy as np
from PIL import Image, ImageOps
import os

def save_image(filename, data_array):
    im = Image.fromarray(data_array.astype('uint8'))
    im_invert = ImageOps.invert(im)
    im_invert.save(filename)

# Load MNIST Data
(x_train, y_train), (x_test, y_test) = mnist.load_data()

DIR_NAME = "JPEGImages"
if os.path.exists(DIR_NAME) == False:
    os.mkdir(DIR_NAME)

# Save Images
i = 0
for li in [x_test]:
    print("[---------------------------------------------------------------]")
    for x in li:
        filename = "{0}/{1:05d}.jpg".format(DIR_NAME,i)
        print(filename)
        save_image(filename, x)
        i += 1