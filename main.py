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