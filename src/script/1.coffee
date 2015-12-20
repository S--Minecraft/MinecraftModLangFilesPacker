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

  baseToPath = "../../temp/#{minecraftVer} - #{packVer} - 1"

  # 翻訳ファイルコピー
  for mod in json.mods
    baseFromPath = "../../../MinecraftModLangFiles/#{mod.name}/#{mod.version}"

    if !fs.existsSync(baseFromPath)
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
        fs.copySync("#{baseFromPath}/#{fileName}", "#{baseToPath}/#{path}/#{mod.name} - #{mod.version}/#{fileName}")

      if mod.path?
        # pathがオブジェクトの時
        if util.isObject(mod.path)
          for key, val of mod.path
            toPath = "#{baseToPath}/#{val}"
            if util.existInArray(paths, val)
              toPath += " - #{mod.version}"
              escaped.push(mod)
            fs.copySync("#{baseFromPath}/#{key}", toPath)
            paths.push(val)
        else if util.isString(mod.path)
          toPath = "#{baseToPath}/#{mod.path}"
          if util.existInArray(paths, mod.path)
            toPath += " - #{mod.version}"
            escaped.push(mod)
          fs.copySync(baseFromPath, toPath)
          paths.push(mod.path)

  # readme作成
  title = "/lang_S_#{minecraftVer}(リソースパック型)///////////////////////by S/////"
  readme = output.makeReadmeText(json, type, title, escaped)
  fs.writeFileSync("#{baseToPath}/Readme - 導入前に読んでください.txt",
                   readme)

  #pack.mcmetaとpack.png
  fs.copySync("../template/pack.mcmeta", "#{baseToPath}/pack.mcmeta")
  fs.copySync("../template/pack.png", "#{baseToPath}/pack.png")

  # zip
  output.zipUp("S_lang_files_#{minecraftVer}_#{packVer}.zip", json, type, callback)
  return
