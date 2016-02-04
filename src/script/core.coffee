###
  core.coffee
  実行本体
###
# 使用モジュール
fs = require "fs-extra"
util = require "./util.js"

# 実行ファイル一覧
src0 = require "./0.js"
src1 = require "./1.js"
src2 = require "./2.js"
srcBBcode = require "./bbcode.js"
srcMarkdown = require "./markdown.js"

###
  実行
###
# 設定ファイル読み込み
text = fs.readFileSync("../output.cfg", "utf8")
console.log "Read output.cfg"
cfgJSON = JSON.parse(text)

# 設定ファイルパース
i = 0 #temp使用済み数
j = 0 #temp使用予定数
compileType = {}

for key, v of cfgJSON
  compileType[key] = {}
  compileType[key]["all"] = v
  compileType[key][0] = util.existInArray(v, "0") ? false #通常型を出力するか
  compileType[key][1] = util.existInArray(v, "1") ? false #リソースパック型を出力するか
  compileType[key][2] = util.existInArray(v, "2") ? false #直接導入型を出力するか
  compileType[key]["b"] = util.existInArray(v, "b") ? false #BBCodeを出力するか
  compileType[key]["m"] = util.existInArray(v, "m") ? false #Markdownを出力するか

for key, v of compileType
  for key2, v2 of v
    if v2 then j++

# tempフォルダ削除
rmvTemp = () ->
  i++
  if i is j
    fs.removeSync("../../temp")
    console.log("Removed temp")
  return

# 出力
for key, v of compileType
  if v
    console.log "Output #{key}"
    jsonText = fs.readFileSync("../../../MinecraftModLangFiles/modList-#{key}.json", "utf8")
    console.log "Read modList-#{key}.json"
    json = JSON.parse(jsonText)
    if v[0]
      console.log "Output #{key} 通常型"
      src0.output(json, rmvTemp)
    if v[1]
      console.log "Output #{key} リソースパック型"
      src1.output(json, rmvTemp)
    if v[2]
      console.log "Output #{key} 直接導入型"
      src2.output(json, rmvTemp)
    if v["b"]
      console.log "Output #{key} BBCode"
      srcBBcode.output(json)
    if v["m"]
      console.log "Output #{key} Markdown"
      srcMarkdown.output(json)

console.log "Completed"

