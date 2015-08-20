###
  util.coffee
  Util
###
fs = require "fs-extra"
archiver = require "archiver"

# indexOfの代用メソッド(高速化)
exports.index = (arr, val) ->
  for a, i in arr
    if a is val
      return i
  return -1;

# 配列ないに存在するかどうか
exports.existInArray = (arr, val) ->
  if @index(arr, val) isnt -1
    return true
  else
    return false

# 配列かどうか
exports.isArray = (arr) ->
  return (arr instanceof Array)

# 文字列かどうか
exports.isString = (str) ->
  return (typeof str is "string")

# 配列または文字列に存在するかどうか
exports.exist = (arr, val) ->
  if @isArray(arr)
    return @existInArray(arr, val)
  else
    return (arr is val)

# cautionをテキストに変換
exports.cautionTransform = (caution) ->
  text = "《#{caution.title}》\r\n"
  text += "#{caution.description}\r\n\r\n"
  return text

# readme作成
exports.makeReadmeText = (json, type, title) ->
  readmeBBefore = "////////////////////////////////////////////////////////////////\r\n"
  readmeBBefore += title
  readmeBefore = fs.readFileSync("../template/Readme-before.txt", {encoding: "utf8"})
  readmeCaution = ""
  for caution in json.cautions
    if @exist(caution.type, type)
      readmeCaution += @cautionTransform(caution)
  readmeCredits = "《クレジット》\r\n"
  for mod in json.mods
    if mod.contributors?
      readmeCredits += "#{mod.name}のlangファイル\r\n"
      readmeCredits += "-#{mod.contributors}様\r\n\r\n"
  readmeAfter = fs.readFileSync("../template/Readme-after.txt", {encoding: "utf8"})

  readme = readmeBBefore + "\r\n" + readmeBefore + "\r\n"
  readme += readmeCaution + readmeCredits + readmeAfter
  return readme

# zipをする
exports.zipUp = (outputName, json, type, callback) ->
  packVer = json["pack-version"]
  minecraftVer = json["minecraft-version"]

  zip = archiver "zip"
  outputZip = fs.createWriteStream("../../output/zip/#{outputName}")
  outputZip.on("close", ->
    console.log "#{outputName} #{zip.pointer()} total bytes"
    # tempを削除する
    if fs.existsSync("../../temp/#{minecraftVer} - #{packVer} - #{type}")
      fs.removeSync("../../temp/#{minecraftVer} - #{packVer} - #{type}")
    callback()
    return
  )
  zip.on("error", (err) ->
    console.log err
    return
  )
  zip.pipe(outputZip)
  zip.bulk([
    {expand: true, cwd: "../../temp/#{minecraftVer} - #{packVer} - #{type}/", src: ["**"]}
  ])
  zip.finalize()
  return
