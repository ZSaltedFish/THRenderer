# THRenderer

THRenderer は、Unity URP 用の PBR ベースのトゥーンシェーダーであり、Fresnel リムライト、アウトライン、金属反射をサポートしています。

## 特徴
- **PBR ライティング**（Metallic、Smoothness、Ambient Occlusion（AO）をサポート）
- **トゥーンスタイルのエフェクト**
  - **Fresnel リムライト** によりキャラクターの輪郭を強調
  - **アウトラインレンダリング** によりアニメ風の外枠を描画
- **カスタムライティングモデル** により、Unity URP のライティングと統合された自然なトゥーンシェーディングを実現
- **複数の光源と影に対応**（Unity のメインライトおよび追加ライトをサポート）

## インストールと使用方法
### 必要環境
- Unity 2022 以上
- Universal Render Pipeline（URP）

### Package Manager からインストール
1. Unity を開き、**Edit → Project Settings** に移動し、**Scriptable Render Pipeline** が **URP** に設定されていることを確認する。
2. **Unity Package Manager** を開く（**Window → Package Manager**）。
3. **`+`** ボタンをクリックし、**`Add package from git URL...`** を選択。
4. 以下の Git URL を入力：https://github.com/ZSaltedFish/THRenderer.git?path=Packages/THRenderer
5. Unity がシェーダーをダウンロードし、インポートするのを待つ。

## サンプル画像
![2780904d201ca2876a5c910b8823b28a](https://github.com/user-attachments/assets/09bd43bc-6dce-4d23-b48f-777e16792183)

上の画像は、Unity URP での **THRenderer** のレンダリング結果を示しています。アウトライン、金属反射、PBR ライティングが含まれています。

## パラメータ一覧
![image](https://github.com/user-attachments/assets/a27a8585-1838-4a77-8f75-cd2eaa6aaf74)

| パラメータ                | 説明 |
|--------------------------|------|
| Main Texture            | アルベド（ベースカラー）テクスチャ |
| Shadow Texture          | トゥーン影の計算に影響を与えるシャドウマップ |
| PBR Texture (smo:RGB)   | PBR テクスチャの各チャンネル：R = Smoothness、G = Metallic、B = Ambient Occlusion（AO） |
| Normal Texture          | 法線マップ（表面のディテールを制御） |
| Fresnel Enable          | Fresnel リムライトの有効化 |
| Cartoon Fresnel         | リムライトの強度を調整（値が大きいほど効果が弱くなる） |
| Outline Color           | アウトラインの色を設定 |
| Outline Size            | アウトラインの太さを調整 |
| Auto Screen Size Outline | 画面サイズに応じてアウトラインの大きさを自動調整するかどうか |

