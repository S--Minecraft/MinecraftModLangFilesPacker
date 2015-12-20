###
  2.coffee
  直接導入型を出力します
###
fs = require "fs-extra"
util = require "./util.js"
output = require "./output.js"

exports.output = (json, callback) ->
  type = 2
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
        # ファイル指定時
        if mod.advanced.file? then fileName = mod.advanced.file else fileName = ""
        if mod.advanced.type is "config"
          if not util.existInArray(paths, mod.advanced.path)
            fs.copySync("../../../MinecraftModLangFiles/#{mod.name}/#{mod.version}/#{fileName}",
                        "../../temp/#{minecraftVer} - #{packVer} - 2/.minecraft/config/#{mod.advanced.path}/#{fileName}")
          else
            fs.copySync("../../../MinecraftModLangFiles/#{mod.name}/#{mod.version}/#{fileName}",
                        "../../temp/#{minecraftVer} - #{packVer} - 2/.minecraft/config/#{mod.advanced.path} - #{mod.version}/#{fileName}")
            escaped.push(mod)
          paths.push(mod.advanced.path)
        else if mod.advanced.type is "zip"
          fs.copySync("../../../MinecraftModLangFiles/#{mod.name}/#{mod.version}/#{fileName}",
                      "../../temp/#{minecraftVer} - #{packVer} - 2/To_zip,jar/#{mod.name} - #{mod.version}/#{fileName}")
      if mod.path?
        # pathがオブジェクトの時
        if util.isObject(mod.path)
          for key, val of mod.path
            if not util.existInArray(paths, val)
              fs.copySync("../../../MinecraftModLangFiles/#{mod.name}/#{mod.version}/#{key}",
                          "../../temp/S_lang_files_in_#{minecraftVer}/#{val}")
            else
              fs.copySync("../../../MinecraftModLangFiles/#{mod.name}/#{mod.version}/#{key}",
                          "../../temp/S_lang_files_in_#{minecraftVer}/#{val} - #{mod.version}")
              escaped.push(mod)
            paths.push(val)
        else if util.isString(mod.path)
          if not util.existInArray(paths, mod.path)
            fs.copySync("../../../MinecraftModLangFiles/#{mod.name}/#{mod.version}",
                        "../../temp/S_lang_files_in_#{minecraftVer}/#{mod.path}")
          else
            fs.copySync("../../../MinecraftModLangFiles/#{mod.name}/#{mod.version}",
                        "../../temp/S_lang_files_in_#{minecraftVer}/#{mod.path} - #{mod.version}")
            escaped.push(mod)
          paths.push(mod.path)

  #pack.mcmetaとpack.png
  fs.copySync("../template/pack.mcmeta",
              "../../temp/S_lang_files_in_#{minecraftVer}/pack.mcmeta")
  fs.copySync("../template/pack.png",
              "../../temp/S_lang_files_in_#{minecraftVer}/pack.png")

  #S_lang_files_in_version.txt
  fs.mkdirsSync("../../temp/#{minecraftVer} - #{packVer} - 2/.minecraft/resourcepacks/")
  fs.writeFileSync("../../temp/#{minecraftVer} - #{packVer} - 2/.minecraft/resourcepacks/S_lang_files_in_version.txt",
                   "#{minecraftVer} - #{packVer}")

  # readme作成
  title = "/lang_S_#{minecraftVer}(直接導入型)//////////////////////////////by S/////"
  readme = output.makeReadmeText(json, type, title, escaped)
  fs.outputFileSync("../../temp/#{minecraftVer} - #{packVer} - 2/Readme - 導入前に読んでください.txt", readme)

  # リソースパックのzip
  output.zipOne("temp/#{minecraftVer} - #{packVer} - 2/.minecraft/resourcepacks/S_lang_files_in_#{minecraftVer}.zip","temp/S_lang_files_in_#{minecraftVer}", json, ->
    # リソースパックがzipされてから実行する
    # zip
    output.zipUp("S_lang_files_Ex_#{minecraftVer}_#{packVer}.zip", json, type, callback)
    return
  )
  return
