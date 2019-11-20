import DAN

if __name__ == '__main__':
    model = models.DANNet(num_classes=31)
    print(model)
    if cuda:
        model.cuda()
    train(model)