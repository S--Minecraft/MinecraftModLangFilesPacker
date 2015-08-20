###
  0.coffee
  通常型を出力します
###
fs = require "fs-extra"
util = require "./util.js"
archiver = require "archiver"

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
                  "../../temp/#{minecraftVer} - #{packVer} - 0/#{folderName}/")

  # readme作成
  title = "/lang_S_#{minecraftVer}(通常型)//////////////////////////////////by S/////"
  readme = util.makeReadmeText(json,title)
  fs.writeFileSync("../../temp/#{minecraftVer} - #{packVer} - 0/Readme - 導入前に読んでください.txt",
                   readme)

  # zip
  zip = archiver "zip"
  outputZip = fs.createWriteStream("../../output/zip/lang_S_#{minecraftVer}_#{packVer}.zip")
  outputZip.on("close", ->
    console.log "lang_S_#{minecraftVer}_#{packVer}.zip #{zip.pointer()} total bytes"
    # tempを削除する
    if fs.existsSync("../../temp/#{minecraftVer} - #{packVer} - 0")
      fs.removeSync("../../temp/#{minecraftVer} - #{packVer} - 0")
    callback()
    return
  )
  zip.on("error", (err) ->
    console.log err
    return
  )
  zip.pipe(outputZip)
  zip.bulk([
    {expand: true, cwd: "../../temp/#{minecraftVer} - #{packVer} - 0/", src: ["**"]}
  ])
  zip.finalize()
  return
