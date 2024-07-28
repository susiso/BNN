import torch
import torch.nn as nn
import torch.nn.functional as F

class StepActivationFunction(torch.autograd.Function):
  @staticmethod
  def forward(ctx, x):
    ctx.save_for_backward(x)
    return torch.where(x >= 0, 1., -1.)

  @staticmethod
  def backward(ctx, dL_dy):
    x, = ctx.saved_tensors
    dL_dx = 1 / torch.cosh(x ** 2) * dL_dy
    return dL_dx

class BinaryLinearFunction(torch.autograd.Function):
  @staticmethod
  def forward(ctx, input, weight, bias):
    w = torch.sign(weight)
    b = torch.sign(bias)
    ctx.save_for_backward(input, w, b)
    return torch.mm(input, torch.t(w)) + b.unsqueeze(0).expand(input.shape[0], w.shape[0])

  @staticmethod
  def backward(ctx, grad_output):
    input, w, b = ctx.saved_tensors
    grad_input = torch.mm(grad_output, w.clone())
    grad_weight = torch.mm(torch.t(grad_output), input.clone())
    grad_bias = grad_output.sum(0)
    return grad_input, grad_weight, grad_bias

class BinaryLinearLayer(nn.Module):
  def __init__(self, in_features, out_features):
    super().__init__()
    self.in_features = in_features
    self.out_features = out_features
    
    weight = torch.empty(out_features, in_features, requires_grad = True)
    nn.init.normal_(weight, mean=0, std=1)
    self.weight = nn.Parameter(weight)

    bias = torch.empty(out_features, requires_grad = True)
    nn.init.normal_(bias, mean=0, std=1)
    self.bias = nn.Parameter(bias)

    self.fn = BinaryLinearFunction.apply

  def forward(self, x):
    return self.fn(x, self.weight, self.bias)
