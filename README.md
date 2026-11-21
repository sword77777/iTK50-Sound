# iTK50-Sound

iTK50 系列板的音效二進位檔存放區。**沒有網頁、沒有 Pages、不在任何網站上連結**，純粹是給 SLK03
用「音效檔來源網址」去抓的檔案庫。使用者透過 SLK03 的 Web UI 選檔燒錄，不需要直接下載。

## 目錄

| 路徑 | 內容 |
|---|---|
| `sound/*.raw` | 音效檔，每個都是 4 MB 位址空間的 raw 8-bit PCM 串流 |
| `sound/manifest.json` | 清單（含大小、SHA256、檔名） |
| `_build_manifest.ps1` | 重新產生 manifest.json |

## 取用方式（SLK03，免 token）

SLK03 只需要記一個根網址：

```
https://raw.githubusercontent.com/sword77777/iTK50-Sound/main/
```

然後：

```
GET <base>sound/manifest.json      → 取得清單（純 JSON，不是 base64）
GET <base>sound/t90_v3.raw         → 取得原始二進位
```

`manifest.json` 裡的 `base_url` 欄位就是上面那個根網址，`files[].file` 是相對於它的路徑
（`sound/t90_v3.raw`）。SLK03 只要 `base_url + file` 接起來就能抓，不必拼接、不必解析 API 回應。

`raw.githubusercontent.com` 是 CDN，匿名可讀、沒有 API rate limit、支援 Range 請求。

## 新增或替換音效檔

1. 把新的 `.raw` 放進 `sound\`（檔名全小寫、底線、不要空白）。
2. 編輯 `_build_manifest.ps1` 最上面的 `$map`，加一筆 `src / file / title`。
3. 執行 `pwsh -NoProfile -File _build_manifest.ps1`。
4. commit + push。

> 只放正式版。舊版（`V3\CH2\old`）與測試檔（`cen haya`）不放。

## 注意

- 檔案是**整段 PCM 音效流**（開頭 `0x80` 是無聲中點），不含任何檔頭。
- 每個檔 2.1~3.7 MB，短於 4 MB；燒錄前要先 Bulk Erase，沒寫到的尾端維持抹除狀態。
- repo 是 public（因為免 token 才能匿名讀），但刻意**不開 Pages、不在網站上放連結**，
  所以沒有任何人會「逛到」這些檔；要下載必須知道確切網址。
- 若日後真的要完全擋住匿名讀取，唯一辦法是改回 private + token（GitHub 沒有第三種）。
- 4 MB 二進位放 git 會累積歷史大小；檔案數量多起來時改用 Releases 存資產。
