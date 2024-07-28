import torch
import torchvision
import numpy as np
import tensorflow as tf
import torch.nn as nn
import os
from tensorflow.keras.datasets import mnist
from model import BNN

def train_step(x, t, criterion, optimizer, model):
	model.train()
	preds = model(x)
	loss = criterion(preds, t)
	optimizer.zero_grad()
	loss.backward()
	optimizer.step()
	return loss, preds

def save_weigth(model):
	weight1 = model.fc1.weight
	weight1 = torch.where(weight1 >= 0, 1, 0)
	bias1 = model.fc1.bias
	bias1 = torch.where(bias1 >= 0, 1, 0)
	weight2 = model.fc2.weight
	weight2 = torch.where(weight2 >= 0, 1, 0)
	bias2 = model.fc2.bias
	bias2 = torch.where(bias2 >= 0, 1, 0)
	weight3 = model.fc3.weight
	weight3 = torch.where(weight3 >= 0, 1, 0)
	bias3 = model.fc3.bias
	bias3 = torch.where(bias3 >= 0, 1, 0)
	weight4 = model.fc4.weight
	weight4 = torch.where(weight4 >= 0, 1, 0)
	bias4 = model.fc4.bias
	bias4 = torch.where(bias4 >= 0, 1, 0)
 
def main():
	model = BNN()

	# load
	path = "model_weight.pth"
	if os.path.isfile(path):
		model.load_state_dict(torch.load(path)) 

	# data load
	(train_images, train_labels), (test_images, test_labels) = mnist.load_data()
	train_images = train_images.reshape(len(train_images), 28*28)
	test_images = test_images.reshape(len(test_images), 28*28)
	train_labels = tf.keras.utils.to_categorical(train_labels, 10)
	test_labels = tf.keras.utils.to_categorical(test_labels, 10)
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
		results = model(x).detach().numpy()
		for i in range(len(results)):
			result = np.argmax(results[i])
			ref = np.argmax(t[i].detach().numpy())
			if result == ref:
				correct += 1
			count += 1
	print("correct rate : ", correct / count)


if __name__ == "__main__":
	main()