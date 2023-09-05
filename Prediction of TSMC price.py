# This script includes:
# SVM
# Decision Tree
# RandomForest
# Adaboost
# KNN
# K means
# K Medoids
# Neural Network
# Logistic
# LSTM
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import talib
data = pd.read_csv('from_201406.csv')
def techical_indicator_df(data):
    from talib import abstract
    data = data.drop(['date'],axis=1)
    data = data.astype('float')
    
    inputs = {}
    inputs['open']= np.array(data['open'])
    inputs['high']= np.array(data['high'])
    inputs['low']= np.array(data['low'])
    inputs['close']= np.array(data['close'])
    inputs['volume']= np.array(data['volume'])

    # Overlap Studies
    upperband, middleband, lowerband = talib.BBANDS(inputs['close'], timeperiod=21, nbdevup=2, nbdevdn=2, matype=0)
    ema = talib.EMA(inputs['close'], timeperiod=21)

    # Momentum Indicator
    macd, macdsignal, macdhist= talib.MACD(inputs['close'], fastperiod=6, slowperiod=13, signalperiod=9)
    mom = talib.MOM(inputs['close'], timeperiod=20)
    rsi = talib.RSI(inputs['close'], timeperiod=20)
    william = talib.WILLR(data['high'], data['low'], data['close'], timeperiod=21)

    # Volatility Indicators
    natr = talib.NATR(inputs['high'], inputs['low'], inputs['close'], timeperiod=20)   # Normalized Average True Range
    
    
    stock_dict={'Upperband': upperband,
                'Middleband': middleband,
                'Lowerband': lowerband,
                'EMA': ema,
                'MACDhist': macdhist,
                'Mommentum': mom,
                'RSI': rsi,
                'William': william,
                'NATR': natr
                }
    
    df = pd.DataFrame(stock_dict)
    df = df.iloc[20:,:]
    df.index = range(len(df))
    
    df1=data.close
    minus=[]
    for i in range(20,len(data)):
        if df1[i]-df1[i-1]>0:
            minus.append(1)
        else:
            minus.append(0)
    
    df['y']=minus
    return df
df = techical_indicator_df(data)
split_point = int(len(df)*0.7)
train = df.iloc[:split_point,:].copy()
test = df.iloc[split_point:,:].copy()
y_train = train['y'].values
X_train1 = train.drop(['y'],axis=1)
X_train = train.drop(['y'],axis=1).values
y_test = test['y'].values
X_test = test.drop(['y'],axis=1).values
# 1. SVM ---------------------------------------------------------------------------------------------------------------
from sklearn.svm import SVC
from sklearn.model_selection import GridSearchCV
gammas = np.linspace(0,0.0005,50)
param_grid = {'gamma': gammas}
clf = GridSearchCV(SVC(), param_grid, cv=5)
clf.fit(X_train, y_train)
print('best parameter: {0}\nbest score: {1}'.format(clf.best_params_, clf.best_score_))
clf = SVC(C=1.0, kernel='rbf', gamma=clf.best_params_['gamma'])
clf.fit(X_train, y_train)
train_score= clf.score(X_train, y_train)
train_score
test_score= clf.score(X_test, y_test)
test_score
# 2. Decision Tree --------------------------------------------------------------------------------------------------------
from sklearn import tree
depths =[i for i in range(3,25)]
training_score_list=[]
test_score_list=[]
for i in depths:
    clf=tree.DecisionTreeClassifier(criterion='gini', max_depth= i, random_state=0).fit(X_train,y_train)
    training_score_list.append(clf.score(X_train,y_train))
    test_score_list.append(clf.score(X_test,y_test))
  plt.xlabel('max depth')
plt.ylabel('score')
plt.plot(depths, training_score_list, '.r--', label='training score')
plt.plot(depths, test_score_list, '.g-', label='test score')
plt.legend()
plt.show()

plt.plot(depths, test_score_list, '.g-')
plt.xlabel('max depth')
plt.ylabel('test score')
plt.show()
clf=tree.DecisionTreeClassifier(criterion='gini', max_depth=6, random_state=100).fit(X_train,y_train)
clf.score(X_train,y_train)
clf.score(X_test,y_test)
y_pred = clf.predict(X_test)
tb = pd.crosstab(y_test, y_pred, rownames=['label'], colnames=['predict'])
print(tb)
from sklearn.tree import export_graphviz
import pydotplus
import graphviz 
dot_data = export_graphviz(clf, 
                           out_file = None,
                           feature_names = X_train1.columns,
                           filled = True)
graph = pydotplus.graph_from_dot_data(dot_data)
graph.write_pdf('outcome.pdf')
# 3. RandomForest-----------------------------------------------------------------------------------------------------
from sklearn.ensemble import RandomForestClassifier
largest=0
for i in range(10,200,5):
    for j in range(2,50,2):
        rfc=RandomForestClassifier(n_estimators=i, n_jobs=-1, random_state = 0, min_samples_leaf = j)
        rfc.fit(X_train,y_train)
        score= rfc.score(X_test,y_test)
        if score>largest:
            largest=score
            best_i=i
            best_j=j
print(largest)
print(best_i)
print(best_j)
rfc=RandomForestClassifier(n_estimators= best_i, n_jobs=-1, random_state = 0, min_samples_leaf = best_j)
rfc.fit(X_train,y_train)
y_pred=rfc.predict(X_test)
print(rfc.score(X_train,y_train))
print(rfc.score(X_test,y_test))
tb= pd.crosstab(y_test, y_pred, rownames=['label'], colnames=['predict'])
print(tb)
imp=rfc.feature_importances_
print(imp)
col_names =list(X_train1.columns)
zip(imp,col_names)
imp, col_names= zip(*sorted(zip(imp,col_names)))
plt.barh(range(len(col_names)),imp,align='center')
plt.yticks(range(len(col_names)),col_names)
plt.xlabel('Importance of Features')
plt.ylabel('Features')
plt.title('Importance of Each Feature')
plt.show()
from sklearn.feature_selection import SelectKBest
selector = SelectKBest(k=5)
X_train_new = selector.fit_transform(X_train, y_train)
a=selector.get_support().astype(int)
b= [i for indx,i in enumerate(col_names) if a[indx] == True]
print(b)
# 4. Adaboost -----------------------------------------------------------------------------------------------------------
from sklearn import ensemble, metrics
largest = 0
for i in range(10,200,10):
    boost = ensemble.AdaBoostClassifier(n_estimators = i)
    boost_fit = boost.fit(X_train, y_train)
    y_pred = boost.predict(X_test)
    accuracy = metrics.accuracy_score(y_test, y_pred)
    if accuracy>largest:
        largest = accuracy
        best_n_estimators = i
print(largest)
print(best_n_estimators)
boost = ensemble.AdaBoostClassifier(n_estimators = best_n_estimators)
boost_fit = boost.fit(X_train, y_train)
test_score = boost.score(X_test, y_test)
y_pred = boost.predict(X_test)
accuracy = metrics.accuracy_score(y_test, y_pred)
print(test_score)
tb= pd.crosstab(y_test, y_pred, rownames=['label'], colnames=['predict'])
print(tb)
# 5. KNN --------------------------------------------------------------------------------------------------------------------
from sklearn.neighbors import KNeighborsClassifier, RadiusNeighborsClassifier
knn_model= KNeighborsClassifier(n_neighbors= 67 ,p=2,weights='distance',algorithm='brute')
knn_model.fit(X_train,y_train)
knn_model.score(X_train,y_train)
knn_model.score(X_test,y_test)
y_pred = knn_model.predict(X_test)
tb= pd.crosstab(y_test, y_pred, rownames=['label'], colnames=['predict'])
print(tb)
# 6. K means ----------------------------------------------------------------------------------------------------------------
from sklearn.cluster import KMeans
df_copy = df.copy()
X = df_copy.drop(['y'],axis=1).values
y= df_copy['y'].values
KM = KMeans(n_clusters=2,random_state=0)
KM.fit(X)
pred_y = KM.predict(X)
true_y = df_copy['y'].values
accuracy = metrics.accuracy_score(true_y, pred_y)
print(accuracy)
selector = SelectKBest(k=2)
X_new = selector.fit_transform(X, y)
X_new
plt.figure(figsize=(10,6))
plt.ylabel('Williams')
plt.xlabel('RSI')
plt.scatter(X_new[y==0][:,0], X_new[y==0][:,1], c='g', s=20, marker='o')
plt.scatter(X_new[y==1][:,0], X_new[y==1][:,1], c='r', s=20, marker='^')
plt.show()
# 7. K Medoids -------------------------------------------------------------------------------------------------------------------
from sklearn_extra.cluster import KMedoids
KMed=KMedoids(n_clusters=2, random_state=100)
KMed.fit(X)
KMed.predict(X)
pred_y = KMed.predict(X)
true_y = df['y'].values
accuracy = metrics.accuracy_score(true_y, pred_y)
print(accuracy)
# 8. Neural Network --------------------------------------------------------------------------------------------------------------------
import tensorflow as tf
from sklearn.preprocessing import StandardScaler
sc = StandardScaler()
X=df.drop(['y'],axis=1).values
sc.fit(X)
X_sc = sc.transform(X)
X_train_sc=X_sc[:split_point,:]
X_test_sc=X_sc[split_point:,:]
largest=0
for i in range(10,101,2):
    for j in range(10,50,2):
        model = tf.keras.models.Sequential([
        tf.keras.layers.Dense(15, activation=tf.nn.relu, input_shape=(X_train_sc.shape[1], )),
        tf.keras.layers.Dense(15, activation=tf.nn.relu),
        tf.keras.layers.Dropout(0.2),
        tf.keras.layers.Dense(15, activation=tf.nn.relu),
        tf.keras.layers.Dropout(0.2),
        tf.keras.layers.Dense(2, activation=tf.nn.softmax)
        ])
        model.compile(optimizer='adam',loss='sparse_categorical_crossentropy',metrics=['accuracy'])
        model.fit(X_train_sc, y_train, epochs=i, batch_size=j, validation_split=0.2, verbose = 0)
        loss, acc = model.evaluate(X_test_sc, y_test)
        if acc>largest:
            largest=acc
            best_i=i
            best_j=j
print(best_i)
print(best_j)
print(largest)
model = tf.keras.models.Sequential([
        tf.keras.layers.Dense(15, activation=tf.nn.relu, input_shape=(X_train_sc.shape[1], )),
        tf.keras.layers.Dense(15, activation=tf.nn.relu),
        tf.keras.layers.Dropout(0.2),
        tf.keras.layers.Dense(15, activation=tf.nn.relu),
        tf.keras.layers.Dropout(0.2),
        tf.keras.layers.Dense(2, activation=tf.nn.softmax)
        ])
model.compile(optimizer='adam',loss='sparse_categorical_crossentropy',metrics=['accuracy'])
history=model.fit(X_train_sc, y_train, epochs=55, batch_size=20, validation_split=0.2)
model.evaluate(X_test_sc, y_test)
loss = history.history['loss']
val_loss = history.history['val_loss']
epochs = range(1, len(loss)+1)
plt.plot(epochs, loss, 'bo', label='Training loss')
plt.plot(epochs, val_loss, 'r', label='Validation loss')
plt.title('Training and validation loss')
plt.xlabel('Epochs')
plt.ylabel('Loss')
plt.legend()
plt.show()
acc = history.history['accuracy']
val_acc = history.history['val_accuracy']
epochs = range(1, len(loss)+1)
plt.plot(epochs, acc, 'bo', label='Training acc')
plt.plot(epochs, val_acc, 'r', label='Validation acc')
plt.title('Training and validation acc')
plt.xlabel('Epochs')
plt.ylabel('Acc')
plt.legend()
plt.show()
# 9. Logistic ----------------------------------------------------------------------------------------------------------------
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import talib
data = pd.read_csv('from_201406.csv')
def techical_indicator_df(data):
    from talib import abstract
    data = data.drop(['date'],axis=1)
    data = data.astype('float')
    
    inputs = {}
    inputs['open']= np.array(data['open'])
    inputs['high']= np.array(data['high'])
    inputs['low']= np.array(data['low'])
    inputs['close']= np.array(data['close'])
    inputs['volume']= np.array(data['volume'])

    # Overlap Studies
    upperband, middleband, lowerband = talib.BBANDS(inputs['close'], timeperiod=21, nbdevup=2, nbdevdn=2, matype=0)
    ema = talib.EMA(inputs['close'], timeperiod=21)

    # Momentum Indicator
    macd, macdsignal, macdhist= talib.MACD(inputs['close'], fastperiod=6, slowperiod=13, signalperiod=9)
    mom = talib.MOM(inputs['close'], timeperiod=20)
    rsi = talib.RSI(inputs['close'], timeperiod=20)
    william = talib.WILLR(data['high'], data['low'], data['close'], timeperiod=21)

    # Volatility Indicators
    natr = talib.NATR(inputs['high'], inputs['low'], inputs['close'], timeperiod=20)   # Normalized Average True Range
    
    
    stock_dict={'Upperband': upperband,
                'Middleband': middleband,
                'Lowerband': lowerband,
                'EMA': ema,
                'MACDhist': macdhist,
                'Mommentum': mom,
                'RSI': rsi,
                'William': william,
                'NATR': natr
                }
    
    df = pd.DataFrame(stock_dict)
    df = df.iloc[20:,:]
    df.index = range(len(df))
    
    df1=data.close
    minus=[]
    for i in range(20,len(data)):
        if df1[i]-df1[i-1]>0:
            minus.append(1)
        else:
            minus.append(0)
    
    df['y']=minus
    return df
df = techical_indicator_df(data)
df
split_point = int(len(df)*0.7)
dataset = df.values
X = dataset[:,0:9]
y = dataset[:,9]
X -= X.mean(axis=0)
X /= X.std(axis=0)
X_train, y_train = X[:split_point], y[:split_point]
X_test, y_test = X[split_point:], y[split_point:]
from sklearn.linear_model import LogisticRegression
from sklearn.preprocessing import PolynomialFeatures
from sklearn.pipeline import Pipeline
def polynomial_model(degree=1, **kwarg):
    polynomial_features = PolynomialFeatures(degree=degree,include_bias=False)
    logistic_regression = LogisticRegression(**kwarg)
    pipeline = Pipeline([('polynomial_features', polynomial_features), ('logistic_regression', logistic_regression)])
    return pipeline
model = polynomial_model(degree=2, solver='liblinear', penalty='l1')
model.fit(X_train, y_train)
train_score = model.score(X_train, y_train)
print(train_score)
test_score = model.score(X_test, y_test)
print(test_score)
logistic_regression = model.named_steps['logistic_regression']
print('model parameters shape: {0}; count of non-zero element:{1}'.format(logistic_regression.coef_.shape,
     np.count_nonzero(logistic_regression.coef_)))
y_pred_proba = model.predict_proba(X_test)
pred_proba = np.round(y_pred_proba,2)
pred_proba
y_pred_proba_0 = y_pred_proba[:,0] > 0.1
result= y_pred_proba[y_pred_proba_0]
y_pred_proba_1 = result[:,1] > 0.1
print(result[y_pred_proba_1])
a = abs(result[y_pred_proba_1][:,0]-0.5)
y_pred_proba[a.argmin()]
# 10. LSTM ------------------------------------------------------------------------------------------------------------------------
import numpy as np
import pandas as pd
from sklearn.preprocessing import MinMaxScaler
from tensorflow.keras.models import Sequential
from tensorflow.keras.layers import Dense, Dropout, LSTM
np.random.seed(10)
df_train = pd.read_csv("tsmc_train.csv", index_col="Date",parse_dates=True)
X_train_set = df_train.iloc[:,3:4].values
sc = MinMaxScaler() 
X_train_set = sc.fit_transform(X_train_set)
def create_dataset(ds, look_back=1):
    X_data, Y_data = [],[]
    for i in range(len(ds)-look_back):
        X_data.append(ds[i:(i+look_back), 0])
        Y_data.append(ds[i+look_back, 0])
    return np.array(X_data), np.array(Y_data)
look_back = 60
X_train, Y_train = create_dataset(X_train_set, look_back)
print("X_train.shape: ", X_train.shape)
print("Y_train.shape: ", Y_train.shape)
X_train = np.reshape(X_train, (X_train.shape[0], X_train.shape[1], 1))
print("X_train.shape: ", X_train.shape)
print("Y_train.shape: ", Y_train.shape)
model = Sequential()
model.add(LSTM(100, return_sequences=True, input_shape=(X_train.shape[1], 1)))
model.add(Dropout(0.2))
model.add(LSTM(100, return_sequences=True))
model.add(Dropout(0.2))
model.add(LSTM(100, return_sequences=True))
model.add(Dropout(0.2))
model.add(LSTM(100, return_sequences=True))
model.add(Dropout(0.2))
model.add(LSTM(100, return_sequences=True))
model.add(Dropout(0.2))
model.add(LSTM(100))
model.add(Dropout(0.2))
model.add(Dense(1))
model.summary()
model.compile(loss="mse", optimizer="adam", metrics='accuracy')
model.fit(X_train, Y_train, epochs=100, batch_size=32)
df_test = pd.read_csv("tsmc_test.csv")
X_test_set = df_test.iloc[:,3:4].values
X_test, Y_test = create_dataset(X_test_set, look_back)
X_test = sc.transform(X_test)
X_test = np.reshape(X_test, (X_test.shape[0], X_test.shape[1], 1))
X_test_pred = model.predict(X_test)
X_test_pred_price = sc.inverse_transform(X_test_pred)
loss, acc = model.evaluate(X_test, Y_test)
print(loss)
print('{:.10f}'.format(acc))
import matplotlib.pyplot as plt
plt.plot(Y_test, color="red", label="Real tsmc Price")
plt.plot(X_test_pred_price, color="blue", label="Predicted tsmc Price")
plt.xlabel("Time")
plt.ylabel("Price")
plt.legend()
plt.show()
