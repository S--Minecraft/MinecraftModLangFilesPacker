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

###
  実行
###
# 設定ファイル読み込み
text = fs.readFileSync("../output.cfg", "utf8")
console.log "Read output.cfg"
cfgJSON = JSON.parse(text)

# 設定ファイルパース
isCompile16Need = cfgJSON["1.6.x"]?
isCompile17Need = cfgJSON["1.7.x"]?
compileType160 = false #1.6.xの通常型を出力するか
compileType161 = false #1.6.xのリソースパック型を出力するか
compileType162 = false #1.6.xの直接導入型を出力するか
compileType16b = false #1.6.xのBBCodeを出力するか
compileType170 = false #1.7.xの通常型を出力するか
compileType171 = false #1.7.xのリソースパック型を出力するか
compileType172 = false #1.7.xの直接導入型を出力するか
compileType17b = false #1.7.xのBBCodeを出力するか

if isCompile16Need
  compileType16 = cfgJSON["1.6.x"]
  compileType160 = util.existInArray(compileType16, "0")
  compileType161 = util.existInArray(compileType16, "1")
  compileType162 = util.existInArray(compileType16, "2")
  compileType16b = util.existInArray(compileType16, "b")
if isCompile17Need
  compileType17 = cfgJSON["1.7.x"]
  compileType170 = util.existInArray(compileType17, "0")
  compileType171 = util.existInArray(compileType17, "1")
  compileType172 = util.existInArray(compileType17, "2")
  compileType17b = util.existInArray(compileType17, "b")

i = 0 #temp使用済み数
j = 0 #temp使用予定数
if compileType160 then j++
if compileType161 then j++
if compileType162 then j++
if compileType170 then j++
if compileType171 then j++
if compileType172 then j++
# tempフォルダ削除
rmvTemp = (json, type) ->
  packVer = json["pack-version"]
  minecraftVer = json["minecraft-version"]
  # tempを削除する
  if fs.existsSync("../../temp/#{minecraftVer} - #{packVer} - #{type}")
    fs.removeSync("../../temp/#{minecraftVer} - #{packVer} - #{type}")
  i++
  if i is j
    fs.removeSync("../../temp")
  return

# 出力
if isCompile16Need
  console.log "Output 1.6.x"
  jsonText16 = fs.readFileSync("../template/modList-1.6.x.json", "utf8")
  console.log "Read modList-1.6.x.json"
  json16 = JSON.parse(jsonText16)
  if compileType160
    console.log "Output 1.6.x 通常型"
    src0.output(json16, rmvTemp)
  if compileType161
    console.log "Output 1.6.x リソースパック型"
    src1.output(json16, rmvTemp)
  if compileType162
    console.log "Output 1.6.x 直接導入型"
    src2.output(json16, rmvTemp)
  if compileType16b
    console.log "Output 1.6.x BBCode"
    srcBBcode.output(json16)

if isCompile17Need
  console.log "Output 1.7.x"
  jsonText17 = fs.readFileSync("../template/modList-1.7.x.json", "utf8")
  console.log "Read modList-1.7.x.json"
  json17 = JSON.parse(jsonText17)
  if compileType170
    console.log "Output 1.7.x 通常型"
    src0.output(json17, rmvTemp)
  if compileType171
    console.log "Output 1.7.x リソースパック型"
    src1.output(json17, rmvTemp)
  if compileType172
    console.log "Output 1.7.x 直接導入型"
    src2.output(json17, rmvTemp)
  if compileType17b
    console.log "Output 1.7.x BBCode"
    srcBBcode.output(json17)

console.log "Completed"

