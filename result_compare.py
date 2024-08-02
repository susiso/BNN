import numpy as np

torch_result = np.loadtxt("label.txt")
quartus_result = np.loadtxt("result_hardBNN.txt")

print(torch_result, quartus_result)

count = 0
for i in range(10000):
	if torch_result[i] == quartus_result[i]:
		count += 1
accuracy = count / 10000
print(accuracy)