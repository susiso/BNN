# Binarized Neural Network (BNN)のハードウェア実装
BNNでMNISTの手書き数字の画像を分類する。<br>
全結合層だけのBNNをPytrochで学習し、重みをverilogに反映する。<br>
分類精度はソフトウェアが95.4%、ハードウェアが90.54%となった。
## ソフトウェア（Python）
Pytorchで自作のBNNモデルを作成する
### 層構成
次元は<br>
784 -> 256 -> 128 -> 32 -> 10 <br>
すべて全結合層とした。活性化関数はsign関数で0以上なら1、それ以外は-1とした。
角層の重みおよび、活性化関数(step)の出力は-1か1の1bitで表現される。（ハードウェアでは1, 0に変換する）<br>
勾配のデータは浮動小数点で保持し、学習時はその値を用いて計算する。
step関数は勾配がほとんど0となるため、勾配計算時はtanhに近似して計算した。<br>
データセットはMNISTの手書き数字で、訓練データ60000枚、テストデータ10000枚である。<br>
出力の最大値のインデックスを分類結果とし、正解率を評価指標とした。

### ファイルの詳細
layers.py：自作レイヤー <br>
model.py：自作モデルBNN <br>
main.py：BNNでの学習および分類性能評価を行う。重みはverilogディレクトリ以下にテキストファイル（w1.txt, b1.txt ...）として保存する。<br>
また、テストデータの画像をpbm（1ビットグレースケール）としてverilogディレクトリに出力し、テストデータの正解ラベルをlabel.txtとして出力する。<br>
result_compare.py：ハードウェアBNNの出力とテストデータの正解ラベルを比較し、正解率を求める。<br>
model_weight.pth：Pytrochの形式の重みの情報 <br>
label.txt：テストデータの正解ラベル <br>
result_hardBNN.txt：ハードウェアBNN（verilog）のテストデータに対する出力結果 <br>

## ハードウェア（verilog）
verilogディレクトリ以下でquartusを使用してハードウェアBNNの検証を行った。

### 層構成
2値を-1, 1から1, 0に変換し、Pythonのモデルを再現した。<br>
積和演算をxorで、活性化関数を比較器で置き換えている。<br>

### ファイルの詳細
image_reg.v：画像メモリ。入力された画像データを保持する。<br>
input_layer.v：入力層（784x256）<br>
mid1_layer.v：中間層1（256x128）<br>
mid2_layer.v：中間層2（128x32）<br>
mid3_layer.v：中間層3（32x10_6bit）<br>
output_layer.v：出力層（10_6bit -> 整数（4bit））<br>
BinarizedNeuralNetwork.v：topモジュール<br>
test_top.v：BinarizedNeuralNetwork.vのテストベンチ<br>

まず、上位ディレクトリでmain.pyにより、画像データ、重みのデータをverilogディレクトリ内に生成する。<br>
（imageディレクトリを作ってまとめたかったが、テストベンチでサブディレクトリの画像をうまく読み込めなかった）<br>
次に、test_top.vによりシミュレーションを行う。結果をテキストファイル（result.txt）として出力する。<br>
正解率はresult.txtとlabel.txt（main.pyによって生成）によって行う。

