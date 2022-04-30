import torch
import torch.nn as nn
import torch.nn.parallel
import torch.utils.data
import torch.nn.functional as F


class PointNetfeat(nn.Module):
    def __init__(self):
        super(PointNetfeat, self).__init__()
        # 3-layer MLP (via 1D-CNN) : encoder points individually
        self.conv1 = torch.nn.Conv1d(3, 64, 1) 
        # size of n, in n*3
        # n*3 input gets fed into this layer
        # initialise (in_channels = 3, out_channels = 64, kernel_size = 1)
        self.conv2 = torch.nn.Conv1d(64, 128, 1)
        # done in a 3 step process
        self.conv3 = torch.nn.Conv1d(128, 1024, 1)
        self.bn1 = nn.BatchNorm1d(64)
        self.bn2 = nn.BatchNorm1d(128)
        self.bn3 = nn.BatchNorm1d(1024)

    def forward(self, x):
        x = F.relu(self.bn1(self.conv1(x)))

        x = F.relu(self.bn2(self.conv2(x)))
        x = self.bn3(self.conv3(x))
        x = torch.max(x, 2, keepdim=True)[0]
        # [0] outputs maximum values of each row in the input tensor
        # [1] indices where the values are maximum in that specific row.
        x = x.view(-1, 1024)
        # takes the values from x and outputs the tensor in the shape: [num_dimensions, 1024]
        # eg: [2, 3 ,6144] -> [3, 2048]
        print(x.shape)
        
        return x


class PointNetCls(nn.Module):
    def __init__(self, k=2):
        super(PointNetCls, self).__init__()
        # self initiating the PointNetCls
        self.feat = PointNetfeat()
        # 3 fully connected layers for classification
        self.fc1 = nn.Linear(1024, 512)
        self.fc2 = nn.Linear(512, 256)
        self.fc3 = nn.Linear(256, k)
        self.dropout = nn.Dropout(p=0.3)
        self.bn1 = nn.BatchNorm1d(512)
        self.bn2 = nn.BatchNorm1d(256)
        self.relu = nn.ReLU()

    def forward(self, x):
        x = self.feat(x)
        x = F.relu(self.bn1(self.fc1(x)))
        x = F.relu(self.bn2(self.dropout(self.fc2(x))))
        x = self.fc3(x)
        
        #returns binary classification as the output node is 1 
        return F.log_softmax(x, dim=1)
    
