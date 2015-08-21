###
  0.coffee
  通常型を出力します
###
fs = require "fs-extra"
util = require "./util.js"
output = require "./output.js"

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
  readme = output.makeReadmeText(json, 0, title)
  fs.writeFileSync("../../temp/#{minecraftVer} - #{packVer} - 0/Readme - 導入前に読んでください.txt",
                   readme)

  # zip
  output.zipUp("lang_S_#{minecraftVer}_#{packVer}.zip", json, 0, callback)
  return
