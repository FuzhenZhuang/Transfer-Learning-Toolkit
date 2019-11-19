import os
import tensorflow as tf
import keras.backend.tensorflow_backend as K
os.environ['KERAS_BACKEND'] = "tensorflow"
# os.environ["CUDA_VISIBLE_DEVICES"] = '0'
gpu_options = tf.GPUOptions(allow_growth=True)
sess = tf.InteractiveSession(
    config=tf.ConfigProto(
        gpu_options=gpu_options))
K.set_session(sess)
from keras.models import Model
from keras.layers import Input
from keras.layers.core import Dense, Dropout
from keras.callbacks import EarlyStopping
from keras.utils.np_utils import to_categorical
import numpy as np
import scipy.sparse as scp
import warnings
from sklearn import svm
class SDA(object):
    '''
    Implements Stacked Denoising Autoencoders in Keras.
    To read more about the SDA, check the following paper:
        Vincent P , Larochelle H , Bengio Y , et al.
        Extracting and Composing Robust Features with Denoising Autoencoders[C]//
        International Conference on Machine Learning. ACM, 2008.
    The code is modified according to https://github.com/MadhumitaSushil/SDAE
    '''

    def __init__(
            self,
            nb_layers=2,
            nb_hid=[100],
            dropout=[0.1],
            enc_act=['tanh'],
            dec_act=['linear'],
            bias=True,
            loss_fn='mse',
            batch_size=32,
            nb_epoch=300,
            optimizer='adam',
            verbose=1,
            base_classifer=svm.LinearSVC()):
        '''
        Initializes parameters for stacked denoising autoencoders
        :param nb_layers: number of layers, i.e., number of autoencoders to stack on top of each other.
        :param nb_hid: list with the number of hidden nodes per layer. If only one value specified, same value is used for all the layers
        :param dropout: list with the proportion of X_train nodes to mask at each layer. If only one value is provided, all the layers share the value.
        :param enc_act: list with activation function for encoders at each layer. Typically sigmoid.
               See also keras.activations for available activation functions.
        :param dec_act: list with activation function for decoders at each layer.
               Typically the same as encoder for binary X_train, linear for real X_train.
               See also keras.activations for available activation functions.
        :param bias: True to use bias value.
        :param loss_fn: The loss function. Typically 'mse' is used for real values. Options can be found here: https://keras.io/objectives/
        :param batch_size: mini batch size for gradient update
        :param nb_epoch: number of epochs to train each layer
        :param optimizer: The optimizer to use. See also keras.optimizers.
        :param verbose: Verbosity mode, 0, 1, or 2.
        '''
        self.nb_layers = nb_layers
        # if only one value specified for nb_hid, dropout, enc_act or dec_act,
        # use the same parameters for all layers.
        self.nb_hid, self.dropout, self.enc_act, self.dec_act = \
            self._assert_input(nb_layers, nb_hid, dropout, enc_act, dec_act)
        self.bias = bias
        self.loss_fn = loss_fn
        self.batch_size = batch_size
        self.nb_epoch = nb_epoch
        self.optimizer = optimizer
        self.verbose = verbose

        self.encoder_model = None
        self.fine_tuned_model = None

    def fit(self, X_train=None, X_val=None, patience=1, dropout_all=False, model_layers=None):
        '''
        Should be called before self.transform and self.fine_tune
        Pretrains layers of a stacked denoising autoencoder to generate low-dimensional representation of data.
        Returns a list of pretrained sda layers for continue training pre-trained model_layers, if required.
        The self.encoder_model can be used in supervised task by adding a classification/regression layer on top,
        see also self.fine_tune.
        :param X_train: input data (scipy sparse matrix supported). shape:(num_samples,num_features)
        :param X_val: validation data (scipy sparse matrix supported). shape:(num_samples,num_features)
        :param patience: number of epochs with no improvement after which training will be stopped. Useful when X_val is not None.
        :param dropout_all: True to include dropout layer between all layers in the learned encoder model.
               By default, dropout is only present for input in the learned encoder model.
        :param model_layers: [DA1,DA2,...],Pretrained cur_model layers, to continue training pre-trained model_layers, if required
        :return : model_layers for continue training pre-trained model_layers, if required
        '''
        self._print_sda_config()
        if model_layers is not None:
            self.nb_layers = len(model_layers)
        else:
            model_layers = [None] * self.nb_layers

        encoders = []
        for cur_layer in range(self.nb_layers):
            if model_layers[cur_layer] is None:
                # same dim of output units as input units (to reconstruct the
                # signal)
                nb_dim = X_train.shape[1]
                input_layer = Input(shape=(nb_dim,))
                # masking input data to learn to generalize, and prevent
                # identity learning
                dropout_layer = Dropout(self.dropout[cur_layer])
                in_dropout = dropout_layer(input_layer)
                encoder_layer = Dense(
                    units=self.nb_hid[cur_layer],
                    kernel_initializer='glorot_uniform',
                    activation=self.enc_act[cur_layer],
                    name='encoder' + str(cur_layer),
                    use_bias=self.bias)
                encoder = encoder_layer(in_dropout)
                decoder_layer = Dense(
                    units=nb_dim,
                    use_bias=self.bias,
                    kernel_initializer='glorot_uniform',
                    activation=self.dec_act[cur_layer],
                    name='decoder' + str(cur_layer))
                decoder = decoder_layer(encoder)
                cur_model = Model(input_layer, decoder)
                cur_model.compile(loss=self.loss_fn, optimizer=self.optimizer)
            else:
                cur_model = model_layers[cur_layer]
            print("Training layer " + str(cur_layer))
            if X_val is not None:
                early_stopping = EarlyStopping(
                    monitor='val_loss', patience=patience, verbose=1)
                cur_model.fit_generator(
                    generator=data_generator.batch_generator(
                        X_train,
                        X_train,
                        batch_size=self.batch_size,
                        shuffle=True),
                    callbacks=[early_stopping],
                    epochs=self.nb_epoch,
                    steps_per_epoch=int(np.ceil(X_train.shape[0] / self.batch_size)),
                    verbose=self.verbose,
                    validation_data=data_generator.batch_generator(
                        X_val,
                        X_val,
                        batch_size=self.batch_size,
                        shuffle=False),
                    validation_steps=int(np.ceil(X_val.shape[0] / self.batch_size)))
            else:
                cur_model.fit_generator(
                    generator=data_generator.batch_generator(
                        X_train,
                        X_train,
                        batch_size=self.batch_size,
                        shuffle=True),
                    epochs=self.nb_epoch,
                    steps_per_epoch=int(np.ceil(X_train.shape[0] / self.batch_size)),
                    verbose=self.verbose,
                )

            print("Layer " + str(cur_layer) + " has been trained.")

            model_layers[cur_layer] = cur_model
            encoder_layer = cur_model.layers[-2]
            encoders.append(encoder_layer)

            # train = 0 because we do not want to use dropout to get hidden node value,since is a train-only behavior,
            # used only to learn weights. output of second layer: hidden
            # layer(encoder layer)
            X_train = self._get_intermediate_output(
                cur_model,
                X_train,
                n_layer=2,
                train=0,
                n_out=self.nb_hid[cur_layer],
                batch_size=self.batch_size)
            assert X_train.shape[1] == self.nb_hid[cur_layer], "Output of hidden layer not retrieved"
            if X_val is not None:
                X_val = self._get_intermediate_output(
                    cur_model,
                    X_val,
                    n_layer=2,
                    train=0,
                    n_out=self.nb_hid[cur_layer],
                    batch_size=self.batch_size)
        self.encoder_model = self._build_model_from_encoders(
            encoders, dropout_all=dropout_all)
        return model_layers

    def _build_model_from_encoders(self, encoding_layers, dropout_all=False):
        '''
        Builds a deep NN model that generates low-dimensional representation of input, based on pretrained layers.
        :param encoding_layers: pretrained encoder layers
        :param dropout_all: True to include dropout layer between all layers. By default, dropout is only present for input.
        :return model with each encoding layer as a layer of a NN
        '''
        input_layer = Input(shape=(encoding_layers[0].input_shape[1],))
        dropouted = Dropout(self.dropout[0])(input_layer)

        for i in range(len(encoding_layers)):
            if i and dropout_all:
                dropouted = Dropout(self.dropout[i])(dropouted)

            encoding_layers[i].inbound_nodes = []
            dropouted = encoding_layers[i](dropouted)
        model = Model(input_layer, dropouted)
        return model

    def fine_tune(
            self,
            X_train,
            y_train,
            X_val=None,
            y_val=None,
            nb_classes=2,
            patience=1,
            final_act_fn='softmax',
            loss='categorical_crossentropy',
            optimizer='adam',
            batch_size=32,
            nb_epoch=300,
            verbose=1):
        '''
        Should be called after self.fit!
        The self.encoder_model can be used in supervised task by adding a classification/regression layer on top.
        Classification by fine-tuning a pre-trained encoder model for a given task.
        :param X_train: input data (scipy sparse matrix supported). shape:(num_samples,num_features)
        :param y_train: input data labels. class vector to be converted into a matrix(integers from 0 to num_classes).
        :param X_val: validation data (scipy sparse matrix supported). shape:(num_samples,num_features)
        :param y_val: validation data labels. class vector to be converted into a matrix(integers from 0 to num_classes).
        :param nb_classes: number of classes.
        :param patience: number of epochs with no improvement after which training will be stopped. Useful when X_val is not None.
        :param final_act_fn: The activation function for classification. Typically 'softmax'.
               See also keras.activations for available activation functions.
        :param loss: The loss function for classification. Typically 'categorical_crossentropy'.
               See also keras.losses for available loss functions.
        :param optimizer: The optimizer to use. See also keras.optimizers.
        :param batch_size: mini batch size for gradient update
        :param nb_epoch: number of epochs to train.
        :param verbose: Verbosity mode, 0, 1, or 2.
        '''
        if self.encoder_model is None:
            raise ValueError('Please fit on some data first.')
        output=Dense(nb_classes, activation=final_act_fn)(self.encoder_model.output)
        model=Model(self.encoder_model.input,output)
        model.compile(loss=loss, optimizer=optimizer)
        if X_val is not None:
            early_stopping = EarlyStopping(monitor='val_loss', patience=patience, verbose=0)
            model.fit_generator(
                generator=data_generator.batch_generator(
                    X_train,
                    y_train,
                    batch_size=batch_size,
                    shuffle=True,
                    nb_classes=nb_classes,
                    one_hot=True),
                steps_per_epoch=int(np.ceil(X_train.shape[0]/batch_size)),
                callbacks=[early_stopping],
                epochs=nb_epoch,
                verbose=verbose,
                validation_data=data_generator.batch_generator(
                    X_val,
                    y_val,
                    batch_size=batch_size,
                    shuffle=False,
                    nb_classes=nb_classes,
                    one_hot=True),
                validation_steps=int(np.ceil(X_val.shape[0]/batch_size)))
        else:
            model.fit_generator(
                generator=data_generator.batch_generator(
                    X_train,
                    y_train,
                    batch_size=batch_size,
                    shuffle=True,
                    nb_classes=nb_classes,
                    one_hot=True),
                steps_per_epoch=int(np.ceil(X_train.shape[0]/batch_size)),
                epochs=nb_epoch,
                verbose=verbose)

        self.fine_tuned_model=model

    def predict(self, X, batch_size=32):
        '''
        Should be called after self.fit and self.fine_tune!
        Generates class probability predictions for the input samples.
        :param X: input data (scipy sparse matrix supported). shape:(num_samples,num_features)
        :param batch_size: mini batch size for gradient update
        :return: probability predictions for X
        '''
        if self.fine_tuned_model is None:
            raise ValueError('Please fine_tune on some data first.')
        preds=self.fine_tuned_model.predict_generator(generator=data_generator.batch_generator(
                        X,
                        None,
                        batch_size=batch_size,
                        shuffle=False), steps=int(np.ceil(X.shape[0] / batch_size)))
        if preds.min() < 0. or preds.max() > 1.:
            warnings.warn('Network returning invalid probability values. '
                          'The last layer might not normalize predictions '
                          'into probabilities '
                          '(like softmax or sigmoid would).')
        return preds

    def transform(self, X, batch_size=32):
        """
        Should be called after self.fit!
        Transform the X into the dense representation of the last layer of the learned encoder model.
        The dense representation of X can be used in some traditional models, such as LR, SVM, KNN or clustering.
        :param X: input data (scipy sparse matrix supported). shape:(num_samples,num_features)
        :param batch_size: mini batch size for gradient update
        :return : The dense representation of the last layer of the learned encoder model of X.
        """
        if self.encoder_model is None:
            raise ValueError('Please fit on some data first.')
        transformed_rep = self.encoder_model.predict_generator(
            generator=data_generator.batch_generator(
                X, None, batch_size=batch_size, shuffle=False), steps=int(np.ceil(X.shape[0]/batch_size)))

        return transformed_rep

    def fit_predict(self, Xs, Xt, X_test, Ys, Y_test):
        ut = self.fit(Xs, Xt)
        Xs = self.transform(Xs)
        self.base_classifer.fit(Xs, Ys)
        X_test = self.transform(X_test)
        y_pred = self.base_classifer.predict(X_test)
        acc = accuracy_score(Y_test, y_pred)
        return acc

    def _print_sda_config(self):
        """
        Print the configuration of the SDA
        """
        print("Number of layers: " + str(self.nb_layers))

        print("Hidden nodes: ")
        s = ''
        for i in range(self.nb_layers):
            s += str(self.nb_hid[i]) + ' '
        print(s)

        print("Dropout: ")
        s = ''
        for i in range(self.nb_layers):
            s += str(self.dropout[i]) + ' '
        print(s)

        s = ''
        print("Encoder activation: ")
        for i in range(self.nb_layers):
            s += str(self.enc_act[i]) + ' '
        print(s)

        print("Decoder activation: ")
        s = ''
        for i in range(self.nb_layers):
            s += str(self.dec_act[i]) + ' '
        print(s)

        print("Epochs: " + str(self.nb_epoch))
        print("Bias: " + str(self.bias))
        print("Loss: " + str(self.loss_fn))
        print("Batch size: " + str(self.batch_size))
        print("Optimizer: " + str(self.optimizer))

    def _assert_input(self, nb_layers, nb_hid, dropout, enc_act, dec_act):
        '''
        If the hidden nodes, dropout proportion, encoder activation function or decoder activation function is given, it uses the same parameter for all the layers.
        Errors out if there is a size mismatch between number of layers and parameters for each layer.
        '''

        if len(nb_hid) == 1:
            nb_hid = nb_hid * nb_layers

        if len(dropout) == 1:
            dropout = dropout * nb_layers

        if len(enc_act) == 1:
            enc_act = enc_act * nb_layers

        if len(dec_act) == 1:
            dec_act = dec_act * nb_layers

        assert (nb_layers == len(nb_hid) == len(dropout) == len(enc_act) == len(dec_act)), \
            "Please specify as many hidden nodes, dropout proportion on input, " \
            "and encoder and decoder activation function, as many layers are there, using list data structure."

        return nb_hid, dropout, enc_act, dec_act

    def _get_intermediate_output(
            self,
            model,
            X_train,
            n_layer,
            train,
            n_out,
            batch_size,
            dtype=np.float32):
        '''
        Returns output of a given intermediate layer in a model
        :param model: model to get output from
        :param X_train: sparse representation of input data
        :param n_layer: the layer number for which output is required
        :param train: (0/1) 1 to use training config, like dropout noise.
        :param n_out: number of output nodes in the given layer (pre-specify so as to use generator function with sparse matrix to get layer output)
        :param batch_size: the num of instances to convert to dense at a time
        :return value of intermediate layer
        '''
        data_out = np.zeros(shape=(X_train.shape[0], n_out))

        x_batch_gen = data_generator.x_generator(
            X_train, batch_size=batch_size, shuffle=False)
        stop_iter = int(np.ceil(X_train.shape[0] / batch_size))

        for i in range(stop_iter):
            cur_batch, cur_batch_idx = next(x_batch_gen)
            data_out[cur_batch_idx, :] = self._get_nth_layer_output(
                model, n_layer, X=cur_batch, train=train)

        return data_out.astype(dtype, copy=False)

    def _get_nth_layer_output(self, model, n_layer, X, train=1):
        '''
        Returns output of nth layer in a given model.
        :param model: keras model to get an intermediate value out of
        :param n_layer: the layer number to get the value of
        :param X: input data for which layer value should be computed and returned.
        :param train: (1/0): 1 to use the same setting as training (for example, with Dropout, etc.), 0 to use the same setting as testing phase for the model.
        :return the value of n_layer in the given model, input, and setting
        '''
        get_nth_layer_output = K.function([model.layers[0].input, K.learning_phase()],
                                          [model.layers[n_layer].output])
        return get_nth_layer_output([X, train])[0]

class data_generator(object):
    @classmethod
    def batch_generator(
            cls,
            X,
            Y=None,
            batch_size=32,
            shuffle=True,
            nb_classes=2,
            one_hot=False,
            seed=1337):
        '''
        Creates batches of data from given dataset, given a batch size. Returns dense representation of sparse input.
        :param X: input features, sparse or dense
        :param Y: input labels, sparse or dense. If Y is None, return generated X only.
        :param batch_size: number of instances in each batch
        :param shuffle: If True, shuffle input instances.
        :param nb_classes: number of classes for one-hot labels.
        :param one_hot: Weather to transform Y to one_hot labels.
        :param seed: fixed seed for shuffling data, for replication
        :return batch of input features and <labels>
        '''
        number_of_batches = int(
            np.ceil(
                X.shape[0] /
                batch_size))  # ceil function allows for creating last batch off remaining samples
        counter = 0
        sample_index = np.arange(X.shape[0])
        if shuffle:
            np.random.seed(seed)
            np.random.shuffle(sample_index)
        if Y is not None and one_hot:
            Y = to_categorical(Y, nb_classes)
        sparse = False
        if scp.issparse(X):
            sparse = True

        while True:
            batch_index = sample_index[batch_size *
                                       counter:batch_size * (counter + 1)]
            if sparse:
                # converts to dense array
                x_batch = X[batch_index, :].toarray()
                if Y is not None:
                    # converts to dense array
                    y_batch = Y[batch_index, :].toarray()
            else:
                x_batch = X[batch_index, :]
                if Y is not None:
                    y_batch = Y[batch_index, :]
            counter += 1
            if Y is not None:
                yield x_batch, y_batch
            else:
                yield x_batch
            if counter == number_of_batches:
                if shuffle:
                    np.random.shuffle(sample_index)
                counter = 0

    @classmethod
    def x_generator(cls, X, batch_size, shuffle, seed=1337):
        '''
        Creates batches of data from given input, given a batch size. Returns dense representation of sparse input one batch a time.
        :param X: input features, can be sparse or dense
        :param batch_size: number of instances in each batch
        :param shuffle: If True, shuffle input instances.
        :param seed: fixed seed for shuffling data, for replication
        :return batch of input data
        '''
        number_of_batches = int(
            np.ceil(
                X.shape[0] /
                batch_size))  # ceil function allows for creating last batch off remaining samples
        counter = 0
        sample_index = np.arange(X.shape[0])

        if shuffle:
            np.random.seed(seed)
            np.random.shuffle(sample_index)

        sparse = False
        if scp.issparse(X):
            sparse = True

        while counter < number_of_batches:
            batch_index = sample_index[batch_size *
                                       counter:batch_size * (counter + 1)]
            if sparse:
                # converts to dense array
                x_batch = X[batch_index, :].toarray()
            else:
                x_batch = X[batch_index, :]
            yield x_batch, batch_index
            counter += 1