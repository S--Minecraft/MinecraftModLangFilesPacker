###
  0.coffee
  通常型を出力します
###
fs = require "fs-extra"
util = require "./util.js"
archiver = require "archiver"
del = require "del"

# cautionをテキストに変換
exports.cautionTransform = (caution) ->
  text = "《#{caution.title}》\r\n"
  text += "#{caution.description}\r\n\r\n"
  return text

exports.output = (json, callback) ->
  packVer = json["pack-version"]
  minecraftVer = json["minecraft-version"]

  # 翻訳ファイルコピー
  for mod in json.mods
    if !fs.existsSync("../../../MinecraftModLangFiles/#{mod.name}/#{mod.version}/")
      console.log "Doesn't exist! : " + "/#{mod.name}/#{mod.version}/"
    else
      folderName = mod.name + " - " + mod.version
      fs.copySync("../../../MinecraftModLangFiles/#{mod.name}/#{mod.version}/",
                  "../../temp/#{minecraftVer} - #{packVer}/#{folderName}/")

  # readme作成
  readmeBBefore = "////////////////////////////////////////////////////////////////\r\n"
  readmeBBefore += "/lang_S_#{minecraftVer}(通常型)//////////////////////////////////by S/////"
  readmeBefore = fs.readFileSync("../template/Readme-before.txt", {encoding: "utf8"})
  readmeCaution = ""
  for caution in json.cautions
    if util.exist(caution.type, "0")
      readmeCaution += @cautionTransform(caution)
  readmeCredits = "《クレジット》\r\n"
  for mod in json.mods
    if mod.contributors?
      readmeCredits += "#{mod.name}のlangファイル\r\n"
      readmeCredits += "-#{mod.contributors}様\r\n\r\n"
  readmeAfter = fs.readFileSync("../template/Readme-after.txt", {encoding: "utf8"})

  readme = readmeBBefore + "\r\n" + readmeBefore + "\r\n"
  readme += readmeCaution + readmeCredits + readmeAfter
  fs.writeFileSync("../../temp/#{minecraftVer} - #{packVer}/Readme - 導入前に読んでください.txt",
                   readme)

  # zip
  zip = archiver "zip"
  outputZip = fs.createWriteStream("../../output/zip/lang_S_#{minecraftVer}_#{packVer}.zip")
  outputZip.on("close", ->
    console.log "lang_S_#{minecraftVer}_#{packVer}.zip #{zip.pointer()} total bytes"
    # tempを削除する
    if fs.existsSync("../../temp/#{minecraftVer} - #{packVer}")
      fs.removeSync("../../temp/#{minecraftVer} - #{packVer}")
    callback()
    return
  )
  zip.on("error", (err) ->
    console.log err
    return
  )
  zip.pipe(outputZip)
  zip.bulk([
    {expand: true, cwd: "../../temp/#{minecraftVer} - #{packVer}/", src: ["**"]}
  ])
  zip.finalize()
  return
