# jsonファイルの書き方
- pack-version 配布バージョン名
- minecraft-version 対応本体バージョン
- mods 対応modの配列
 - name mod名
 - version 対応バージョン
 - minecraft-version 対応本体バージョンの配列
 - contributors 貢献した人 (省略可)
 - url 配布url (省略可)
 - path langファイルの場所 (省略可)(オブジェクトでも可)
    - \["送り元"] 送り先 (オブジェクトの場合)
 - advanced configやzipへの導入が必要かどうか(省略可)
    - type configへ導入するかzipへ導入するか
    - path その導入する場所
    - file pathとadvancedが両方ある場合に記述するadvancedのほうへ送るファイルの配列(ない場合はすべて)
 - note BBCode出力するそのmodに関する注意(省略可)
- cautions 注意書き
 - title タイトル
 - description 説明
 - type 注意書きが必要な版の配列(0: 通常版, 1: リソースパック版, 2: 直接導入型)

※ pathとpathの配列とadvanced.pathの重複時の適応順序は
　 advanced.path→pathの配列→path
