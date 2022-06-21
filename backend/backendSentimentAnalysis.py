
##                 Abdulkadir GÜLLÜOĞLU Meryem AKHAN
##                      4095                4020
import re
import numpy as np 
import pandas as pd # DATA SETİNİ OKUMA VE DÜZENLEME
import json
from urllib import response
from flask import Flask,jsonify,request
# RNN MODELİNİ KURMAK İÇİN KERAS KUTUPHANESİNİ KULLANACAĞIZ
from tensorflow.keras.models import Sequential
from tensorflow.keras.layers import Dense, GRU, Embedding
from tensorflow.keras.optimizers import Adam
from tensorflow.keras.preprocessing.text import Tokenizer
from tensorflow.keras.preprocessing.sequence import pad_sequences

df1 = pd.read_csv('data/tweetset.csv', encoding="windows-1254")
df2 = pd.read_csv('data/TurkishTweets.csv')
df1 = df1.drop(['Unnamed: 2', 'Unnamed: 3', 'Unnamed: 4', 'Unnamed: 5'], axis = 1)


df2 = df2.dropna()
df2["Etiket"].replace({"kızgın": "Negative", "korku": "Negative", "mutlu": "Positive", 
                        "surpriz": "Positive", "üzgün": "Negative"}, inplace=True)
df2.columns = ['Tweets', 'Sentiment']
df1["Tip"].replace({"Pozitif": "Positive", " Negatif": "Negative", "Negatif": "Negative" }, inplace=True)
df1 = df1.reindex(columns=['Paylaşım','Tip'])
df1.columns = ['Tweets', 'Sentiment']
df= pd.concat([df1,pd.DataFrame.from_records(df2)])


df['Tweets'] = [token.lower() for token in df['Tweets']]
df['Tweets'] = df['Tweets'].replace('@[A-Za-z0-9]+', '', regex=True).replace('@[A-Za-z0-9]+', '', regex=True)
df['Tweets'] = df['Tweets'].replace(r'http\S+', '', regex=True).replace(r'www\S+', '', regex=True)


sentences = df['Tweets'].copy()

new_sent = []

for sentence in sentences:
    new_sentence = re.sub('[0-9]+', '', sentence)
    new_sent.append(new_sentence)
    
df['Tweets'] = new_sent

import string

table = str.maketrans('', '', string.punctuation)
sentences = df['Tweets'].copy()
new_sent = []
for sentence in sentences:
    words = sentence.split()
    stripped = [w.translate(table) for w in words]
    new_sent.append(stripped)

df['Tweets'] = new_sent

df['Sentiment'].replace({"Negative": 0, "Positive" : 1},inplace=True)

etiket=df['Sentiment'].values
data=df['Tweets'].values

bol_say = int(len(data) * 0.80) 
x_train, x_text = data[:bol_say], data[bol_say:] 
y_train, y_test = etiket[:bol_say], etiket[bol_say:] 


## data setteki en cok kullanılan 10000 kelimeyi  ayırarak gerisini yok sayıyoruz
num_words = 10000
tokenizer = Tokenizer(num_words=num_words)
tokenizer.fit_on_texts(data)

# Tokenleştirme
x_train_tokens = tokenizer.texts_to_sequences(x_train) ## egitim setini tokenleştirdik
x_test_tokens = tokenizer.texts_to_sequences(x_text)

## RNN aynı boyutta veri kümelerinde çalıştığından datalar kısaltcaz veya 0 atarak uzatcaz (eşitlemek için)
num_tokens = [len(tokens) for tokens in x_train_tokens + x_test_tokens ]   ## her yorumda kac token oldugu hesaplanır
num_tokens = np.array(num_tokens) ## dizi numpy arraye ceviriyoruz
max_tokens = np.mean(num_tokens) + 2 * np.std(num_tokens) ## cumlelerin ortalama kelime sayısının 2 fazlasıyla standart sapmasını topluyoruz
max_tokens = int(max_tokens)

## pading ekleme 
x_train_pad = pad_sequences(x_train_tokens, maxlen=max_tokens) # pad_sequences keras kutupanesının fonksıyonudur
x_test_pad = pad_sequences(x_test_tokens, maxlen=max_tokens)





### MODELİN OLUŞTURULMASI 


model = Sequential() ## Keras kullanarak model oluşturuyoruz
embedding_size = 50 ## kullanılcak kelime vektörlerinin uzunluğu
# input içindeki kelimelerin vektörlerini output olarak verir
model.add(Embedding(input_dim=num_words,
                    output_dim=embedding_size,
                    input_length=max_tokens,
                    name='layer'))          ## 10000 e 50 boyutunda matris oluşturuyoruz
model.add(GRU(units= 16, return_sequences=True)) # unit = 16 nöron sayısı // return_sequence bir sonraki layerları ekleyecegımız ıcın true
model.add(GRU(units= 8, return_sequences=True))
model.add(GRU(units= 4)) # son noron oldugu ıcın return_sequeces oto false bırakıyoruz
model.add(Dense(1, activation='sigmoid')) # cıkıs noronu oldugu ıcın Dense kullanıldı ve sigmoid fonk 0 ile 1 arası degerler doner yanı mutlu ve mutsuz

# Optimizasyon
optimizer = Adam(lr= 1e-3)  # 1e-3 ==== 0.001 

# Modelin Derlenmesi 
model.compile(loss='binary_crossentropy',
              optimizer='Adam',
              metrics=['accuracy']) # yanlızca 2 sınıf oldugu ıcın loss için binary_crossentropy kullandık // metris masarı oranını gormek ıcın kullanıldı


## MODELİN EĞİTİMİ
model.fit(x_train_pad, y_train, epochs=8, batch_size=256) # 8 defa eğitiyoruz modeli
global metin

def degeriolc(text1):
    texts = [text1]
    tokens = tokenizer.texts_to_sequences(texts)
    tokens_pad = pad_sequences(tokens, maxlen= max_tokens)
    deger = model.predict(tokens_pad)
    sayi = float(deger)
    sayi*=100
    sayi=int(sayi)
    if deger > 0.5:
        degerstr=str(sayi)
        return "😊"+"%"+degerstr
    else:
        sayi=100-sayi        
        degerstr=str(sayi)
        return "🙁"+"%"+degerstr
    
    
    


app = Flask(__name__) 


@app.route('/nlp', methods = ['GET','POST'])
def index():
    global response
    if(request.method=="POST"):
        request_data= request.data
        request_data= json.loads(request_data.decode('utf_8'))
        text=request_data['text']
        text = str(text)
        response=degeriolc(text)
        print(text)
        print(response)
        return ""
    else:
        return jsonify({'merhaba':response})
    
    

if __name__ == "__main__":
    app.run(debug = True) 