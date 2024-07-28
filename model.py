import layers
import torch.nn as nn

class BNN(nn.Module):
  def __init__(self):
    super().__init__()
    self.fc1 = layers.BinaryLinearLayer(28 * 28, 256)
    self.step1 = layers.StepActivationFunction.apply
    self.fc2 = layers.BinaryLinearLayer(256, 128)
    self.step2 = layers.StepActivationFunction.apply
    self.fc3 = layers.BinaryLinearLayer(128, 32)
    self.step3 = layers.StepActivationFunction.apply
    self.fc4 = layers.BinaryLinearLayer(32, 10)

  def forward(self, x):
    x = x.view(-1, 28*28)
    x = self.fc1(x)
    x = self.step1(x)
    x = self.fc2(x)
    x = self.step2(x)
    x = self.fc3(x)
    x = self.step3(x)
    x = self.fc4(x)
    return x
