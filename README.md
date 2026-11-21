# iTK50-Sound（私有）

iTK50 系列板的音效二進位檔存放區。**只給 SLK03 取用**，不開 Pages、不對外公開。
任何需要這批檔案的人類使用者，都應該從 SLK03 的 Web UI 選檔燒錄，不需要也不應該直接下載。

## 目錄

| 路徑 | 內容 |
|---|---|
| `sound/*.raw` | 音效檔，每個都是 4 MB 位址空間的 raw 8-bit PCM 串流 |
| `sound/manifest.json` | 清單（含大小、SHA256、API 路徑） |
| `_build_manifest.ps1` | 重新產生 manifest.json |

## 取用方式（SLK03）

私有 repo 的檔案**不能匿名抓**，SLK03 必須帶 fine-grained token（權限只需要
`Contents: Read`，範圍只給這個 repo）。

取清單（含大小與 sha256）：

```
GET https://api.github.com/repos/sword77777/iTK50-Sound/contents/sound/manifest.json
Authorization: Bearer <token>
Accept: application/vnd.github.raw
```

取單一檔案（直接拿二進位，不是 base64 JSON）：

```
GET https://api.github.com/repos/sword77777/iTK50-Sound/contents/sound/t90_v3.raw
Authorization: Bearer <token>
Accept: application/vnd.github.raw
```

或用清單 API 拿 `download_url` 再帶同一個 header 去抓。兩種都可以，4 MB 以下不必分塊。

## 新增或替換音效檔

1. 把新的 `.raw` 放進 `sound\`（檔名全小寫、底線、不要空白）。
2. 編輯 `_build_manifest.ps1` 最上面的 `$map`，加一筆 `src / file / title`。
3. 執行 `pwsh -NoProfile -File _build_manifest.ps1`。
4. commit + push。

> 只放正式版。舊版（`V3\CH2\old`）與測試檔（`cen haya`）不放。

## 注意

- 檔案是**整段 PCM 音效流**（開頭 `0x80` 是無聲中點），不含任何檔頭。
- 每個檔 2.1~3.7 MB，短於 4 MB；燒錄前要先 Bulk Erase，沒寫到的尾端維持抹除狀態。
- 這個 repo **不要改成 public**，一改檔案就等於公開。
- 4 MB 二進位放 git 會累積歷史大小；檔案數量多起來時改用 Releases 存資產。
