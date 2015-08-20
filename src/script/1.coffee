###
  1.coffee
  リソースパック型を出力します
###
fs = require "fs-extra"
util = require "./util.js"
output = require "./output.js"

exports.output = (json, callback) ->
  type = 1
  packVer = json["pack-version"]
  minecraftVer = json["minecraft-version"]

  # 翻訳ファイルコピー
  for mod in json.mods
    if !fs.existsSync("../../../MinecraftModLangFiles/#{mod.name}/#{mod.version}/")
      console.log "Doesn't exist! : " + "/#{mod.name}/#{mod.version}/"
    else
      # advanced時
      if mod.advanced?
        switch mod.advanced.type
          when "zip" then path = "To_zip,jar"
          when "config" then path = "To_config"
          else console.log "Error: Unknown advanced.type"
        # ファイル指定時
        if mod.advanced.file? then fileName = mod.advanced.file else fileName = ""
        fs.copySync("../../../MinecraftModLangFiles/#{mod.name}/#{mod.version}/#{fileName}",
                    "../../temp/#{minecraftVer} - #{packVer} - 1/#{path}/#{mod.name} - #{mod.version}/#{fileName}")

      if mod.path?
        # pathが配列の時
        if util.isArray(mod.path)
          for key, val of mod.path
            fs.copySync("../../../MinecraftModLangFiles/#{mod.name}/#{mod.version}/#{key}",
                        "../../temp/#{minecraftVer} - #{packVer} - 1/#{val}")
        else if util.isString(mod.path)
          fs.copySync("../../../MinecraftModLangFiles/#{mod.name}/#{mod.version}",
                      "../../temp/#{minecraftVer} - #{packVer} - 1/#{mod.path}")

  # readme作成
  title = "/lang_S_#{minecraftVer}(リソースパック型)///////////////////////by S/////"
  readme = output.makeReadmeText(json, type, title)
  fs.writeFileSync("../../temp/#{minecraftVer} - #{packVer} - 1/Readme - 導入前に読んでください.txt",
                   readme)

  # zip
  outputName = "S_lang_files_#{minecraftVer}_#{packVer}.zip"
  output.zipUp(outputName, json, type, callback)
  return
