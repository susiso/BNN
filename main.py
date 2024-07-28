import torch
import torchvision
import numpy as np
import tensorflow as tf
import torch.nn as nn
import os
import cv2
import time
from tensorflow.keras.datasets import mnist
from model import BNN

verilog_path = "verilog"
image_path = "image"

def train_step(x, t, criterion, optimizer, model):
	model.train()
	preds = model(x)
	loss = criterion(preds, t)
	optimizer.zero_grad()
	loss.backward()
	optimizer.step()
	return loss, preds

def save_weigth(model):
	os.makedirs(verilog_path, exist_ok=True)

	w1 = model.fc1.weight
	w1 = torch.where(w1 >= 0, 1, 0)
	b1 = model.fc1.bias
	b1 = torch.where(b1 >= 0, 1, 0)
	w2 = model.fc2.weight
	w2 = torch.where(w2 >= 0, 1, 0)
	b2 = model.fc2.bias
	b2 = torch.where(b2 >= 0, 1, 0)
	w3 = model.fc3.weight
	w3 = torch.where(w3 >= 0, 1, 0)
	b3 = model.fc3.bias
	b3 = torch.where(b3 >= 0, 1, 0)
	w4 = model.fc4.weight
	w4 = torch.where(w4 >= 0, 1, 0)
	b4 = model.fc4.bias
	b4 = torch.where(b4 >= 0, 1, 0)

	with open(os.path.join(verilog_path, "w1.txt"), "w") as f:
		for i in range(784):
			for j in range(256):
				f.write(str(int(w1[j][i])))
			f.write("\n")
	with open(os.path.join(verilog_path, "b1.txt"), "w") as f:
		for j in range(256):
			f.write(str(int(b1[j])))
		f.write("\n")
	with open(os.path.join(verilog_path, "w2.txt"), "w") as f:
		for i in range(256):
			for j in range(128):
				f.write(str(int(w2[j][i])))
			f.write("\n")
	with open(os.path.join(verilog_path, "b2.txt"), "w") as f:
		for j in range(128):
			f.write(str(int(b2[j])))
		f.write("\n")
	with open(os.path.join(verilog_path, "w3.txt"), "w") as f:
		for i in range(128):
			for j in range(32):
				f.write(str(int(w3[j][i])))
			f.write("\n")
	with open(os.path.join(verilog_path, "b3.txt"), "w") as f:
		for j in range(32):
			f.write(str(int(b3[j])))
		f.write("\n")
	with open(os.path.join(verilog_path, "w4.txt"), "w") as f:
		for i in range(32):
			for j in range(10):
				f.write(str(int(w4[j][i])))
			f.write("\n")
	with open(os.path.join(verilog_path, "b4.txt"), "w") as f:
		for j in range(10):
			f.write(str(int(b4[j])))
		f.write("\n")
 
def save_image(filename, data):
	cv2.imwrite(os.path.join(verilog_path, image_path, f"{filename}"), data, [cv2.IMWRITE_PXM_BINARY, 0])
 
def main():
	model = BNN()

	# load
	path = "model_weight.pth"
	if os.path.isfile(path):
		model.load_state_dict(torch.load(path)) 

	# data load
	(train_images, train_labels), (test_images, test_labels_raw) = mnist.load_data()
	train_images = train_images.reshape(len(train_images), 28*28)
	test_images = test_images.reshape(len(test_images), 28*28)
	train_labels = tf.keras.utils.to_categorical(train_labels, 10)
	test_labels = tf.keras.utils.to_categorical(test_labels_raw, 10)
	train_x = torch.tensor(train_images, dtype=torch.float32).reshape(-1, 1, 28, 28)
	train_x = torch.where(train_x >= 128, 1., -1.)
	train_t = torch.tensor(train_labels, dtype=torch.float32)
	train_dataset = torch.utils.data.TensorDataset(train_x, train_t)
	test_x = torch.tensor(test_images, dtype=torch.float32).reshape(-1, 1, 28, 28)
	test_x = torch.where(test_x >= 128, 1., -1.)
	test_t = torch.tensor(test_labels, dtype=torch.float32)
	test_dataset = torch.utils.data.TensorDataset(test_x, test_t)
	batch_size = 1000
	train_dataloader = torch.utils.data.DataLoader(dataset = train_dataset, batch_size = batch_size, shuffle = True)
	test_dataloader = torch.utils.data.DataLoader(dataset = test_dataset, batch_size = batch_size, shuffle = False)
	
	criterion = nn.CrossEntropyLoss()
	optimizer = torch.optim.Adam(model.parameters(), lr = 0.001)

	epochs = 10
	for e in range(epochs):
		train_loss = 0
		# test_loss = 0
		for (x, t) in train_dataloader:
			loss, preds = train_step(x, t, criterion, optimizer, model)
			train_loss += loss
		print(train_loss)
   
	torch.save(model.state_dict(), path)
 
	count = 0
	correct = 0
	for (x, t) in test_dataloader:
		time_start = time.time()
		results = model(x).detach().numpy()
		time_end = time.time()
		for i in range(len(results)):
			result = np.argmax(results[i])
			ref = np.argmax(t[i].detach().numpy())
			if result == ref:
				correct += 1
			count += 1
	print("correct rate : ", correct / count) # 0.9545
	time_predict = time_end - time_start # 0.004732s
	print(f"prediction time: {time_predict}s (1step: {time_predict / 10000})")
	# 重みの保存
	save_weigth(model)
 
	# テストデータの画像を保存
	os.makedirs(os.path.join(verilog_path, image_path), exist_ok=True)
	i = 0
	x_numpy = test_x.to('cpu').detach().numpy().copy()
	x_int = np.squeeze(x_numpy.astype(np.int64))
	print(x_int.shape)
	for li in [x_int]:
		for x in li:
			filename = f"{i:05d}.pbm"
			save_image(filename, x)
			i += 1
	
	# テストデータのラベルを保存
	np.savetxt(os.path.join(verilog_path, image_path, "label.txt"), test_labels_raw.astype(np.int32), fmt="%d")

if __name__ == "__main__":
	main()