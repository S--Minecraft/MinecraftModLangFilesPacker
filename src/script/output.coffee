###
  output.coffee
  Output
###
fs = require "fs-extra"
archiver = require "archiver"
util = require "./util.js"

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
    if util.exist(caution.type, type.toString())
      readmeCaution += @cautionTransform(caution)
  readmePath = ""
  if type is 1 or type is 2
    readmePath += "《配置場所(config/zip/jar)》\r\n"
    for mod in json.mods
      if mod.advanced?
        readmePath += "#{mod.name}(#{mod.version}): "
        if mod.advanced.type is "config" and type is 1
          readmePath += ".minecraftフォルダ/config/#{mod.advanced.path}\r\n"
        else if mod.advanced.type is "zip"
          readmePath += "modのzipやjar/#{mod.advanced.path}\r\n"
    readmePath += "\r\n"
  readmeCredits = "《クレジット》\r\n"
  for mod in json.mods
    if mod.contributors?
      readmeCredits += "#{mod.name}のlangファイル\r\n"
      readmeCredits += "-#{mod.contributors}様\r\n\r\n"
  readmeAfter = fs.readFileSync("../template/Readme-after.txt", {encoding: "utf8"})

  readme = readmeBBefore + "\r\n" + readmeBefore + "\r\n"
  readme += readmeCaution + readmePath + readmeCredits + readmeAfter
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
