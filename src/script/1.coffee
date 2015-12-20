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

  paths = []
  escaped = [] # エスケープされたmodのオブジェクトの配列

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
        # pathがオブジェクトの時
        if util.isObject(mod.path)
          for key, val of mod.path
            if not util.existInArray(paths, val)
              fs.copySync("../../../MinecraftModLangFiles/#{mod.name}/#{mod.version}/#{key}",
                          "../../temp/#{minecraftVer} - #{packVer} - 1/#{val}")
            else
              fs.copySync("../../../MinecraftModLangFiles/#{mod.name}/#{mod.version}/#{key}",
                          "../../temp/#{minecraftVer} - #{packVer} - 1/#{val} - #{mod.version}")
              escaped.push(mod)
            paths.push(val)
        else if util.isString(mod.path)
          if not util.existInArray(paths, mod.path)
            fs.copySync("../../../MinecraftModLangFiles/#{mod.name}/#{mod.version}",
                        "../../temp/#{minecraftVer} - #{packVer} - 1/#{mod.path}")
          else
            fs.copySync("../../../MinecraftModLangFiles/#{mod.name}/#{mod.version}",
                        "../../temp/#{minecraftVer} - #{packVer} - 1/#{mod.path} - #{mod.version}")
            escaped.push(mod)
          paths.push(mod.path)

  # readme作成
  title = "/lang_S_#{minecraftVer}(リソースパック型)///////////////////////by S/////"
  readme = output.makeReadmeText(json, type, title, escaped)
  fs.writeFileSync("../../temp/#{minecraftVer} - #{packVer} - 1/Readme - 導入前に読んでください.txt",
                   readme)

  #pack.mcmetaとpack.png
  fs.copySync("../template/pack.mcmeta",
              "../../temp/#{minecraftVer} - #{packVer} - 1/pack.mcmeta")
  fs.copySync("../template/pack.png",
              "../../temp/#{minecraftVer} - #{packVer} - 1/pack.png")

  # zip
  output.zipUp("S_lang_files_#{minecraftVer}_#{packVer}.zip", json, type, callback)
  return
