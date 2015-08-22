###
  output.coffee
  Output
###
fs = require "fs-extra"
path = require "path"
archiver = require "archiver"
util = require "./util.js"

# cautionをテキストに変換
exports.cautionTransform = (caution) ->
  text = "《#{caution.title}》\r\n"
  text += "#{caution.description}\r\n\r\n"
  return text

# readme作成
exports.makeReadmeText = (json, type, title, escaped) ->
  readmeBBefore = "////////////////////////////////////////////////////////////////\r\n"
  readmeBBefore += title
  readmeBefore = fs.readFileSync("../template/Readme-before.txt", {encoding: "utf8"})
  readmeCaution = ""
  for caution in json.cautions
    if util.exist(caution.type, type.toString())
      readmeCaution += @cautionTransform(caution)
  readmeEscaped = ""
  if escaped? and escaped.length isnt 0
    readmeEscaped += "《導入時の注意》\r\n"
    readmeEscaped += "以下のmodのバージョンのlangファイルは\r\n既定では無効になっています\r\n"
    readmeEscaped += "下記のpathからバージョンを取り除いていただくと有効になります\r\n"
    for mod in escaped
      readmeEscaped += "#{mod.name}(#{mod.version}): #{mod.path} - #{mod.version}"
      if mod.advanced?
        readmeEscaped += " .minecraft/config/#{mod.advanced.path} - #{mod.version}"
      readmeEscaped += "\r\n"
    readmeEscaped += "\r\n"
  readmePath = "《配置場所(config/zip/jar)》\r\n"
  if type is 1 or type is 2
    for mod in json.mods
      if mod.advanced?
        if mod.advanced.type is "config" and type is 1
          readmePath += "#{mod.name}(#{mod.version}): .minecraftフォルダ/config/#{mod.advanced.path}\r\n"
        else if mod.advanced.type is "zip"
          readmePath += "#{mod.name}(#{mod.version}): modのzipやjar/#{mod.advanced.path}\r\n"
  else if type is 0
    for mod in json.mods
      readmePath += "#{mod.name}(#{mod.version}): "
      if mod.path?
        readmePath += "#{mod.path}"
      if mod.advanced?
        if mod.advanced.type is "config"
          readmePath += " .minecraftフォルダ/config/#{mod.advanced.path}"
        else if mod.advanced.type is "zip"
          readmePath += " modのzipやjar/#{mod.advanced.path}"
      readmePath += "\r\n"
  if readmePath is "《配置場所(config/zip/jar)》\r\n"
    readmePath = ""
  else
    readmePath += "\r\n"
  readmeCredits = "《クレジット》\r\n"
  for mod in json.mods
    if mod.contributors?
      readmeCredits += "#{mod.name}のlangファイル\r\n"
      readmeCredits += "-#{mod.contributors}様\r\n"
  readmeCredits += "\r\n"
  readmeAfter = fs.readFileSync("../template/Readme-after.txt", {encoding: "utf8"})

  readme = readmeBBefore + "\r\n" + readmeBefore + "\r\n" + readmeCaution
  readme += readmeEscaped + readmePath + readmeCredits + readmeAfter
  return readme

# zipをする
exports.zipOne = (outputName, inputPlace, json, callback) ->
  zip = archiver "zip"
  outputZip = fs.createWriteStream("../../#{outputName}")
  outputZip.on("close", ->
    name = path.basename(outputName)
    console.log "#{name} #{zip.pointer()} total bytes"
    callback()
    return
  )
  zip.on("error", (err) ->
    console.log err
    return
  )
  zip.pipe(outputZip)
  zip.bulk([
    {expand: true, cwd: "../../#{inputPlace}", src: ["**"]}
  ])
  zip.finalize()
  return

# 配布用zipをする
exports.zipUp = (outputName, json, type) ->
  zip = archiver "zip"
  packVer = json["pack-version"]
  minecraftVer = json["minecraft-version"]

  outputZip = fs.createWriteStream("../../output/zip/#{outputName}")
  outputZip.on("close", ->
    name = path.basename(outputName)
    console.log "#{name} #{zip.pointer()} total bytes"
    return
  )
  zip.on("error", (err) ->
    console.log err
    return
  )
  zip.pipe(outputZip)
  zip.bulk([
    {
      expand: true,
      dot: true,
      cwd: "../../temp/#{minecraftVer} - #{packVer} - #{type}",
      src: ["**"]
    }
  ])
  zip.finalize()
  return
