###
  2.coffee
  直接導入型を出力します
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
      # advanced時
      if mod.advanced?
        # ファイル指定時
        if mod.advanced.file? then fileName = mod.advanced.file else fileName = ""
        if mod.advanced.type is "config"
          fs.copySync("../../../MinecraftModLangFiles/#{mod.name}/#{mod.version}/#{fileName}",
                      "../../temp/#{minecraftVer} - #{packVer} - 2/.minecraft/config/#{mod.advanced.path}/#{fileName}")
        else if mod.advanced.type is "zip"
          fs.copySync("../../../MinecraftModLangFiles/#{mod.name}/#{mod.version}/#{fileName}",
                      "../../temp/#{minecraftVer} - #{packVer} - 2/To_zip,jar/#{mod.name} - #{mod.version}/#{fileName}")
      if mod.path?
        # pathが配列の時
        if util.isArray(mod.path)
          for key, val of mod.path
            fs.copySync("../../../MinecraftModLangFiles/#{mod.name}/#{mod.version}/#{key}",
                        "../../temp/#{minecraftVer} - #{packVer} - 2/S_lang_files_in_#{minecraftVer}/#{val}")
        else if util.isString(mod.path)
          fs.copySync("../../../MinecraftModLangFiles/#{mod.name}/#{mod.version}",
                      "../../temp/#{minecraftVer} - #{packVer} - 2/S_lang_files_in_#{minecraftVer}/#{mod.path}")

  #pack.mcmetaとpack.png
  fs.copySync("../template/pack.mcmeta",
              "../../temp/#{minecraftVer} - #{packVer} - 2/S_lang_files_in_#{minecraftVer}/pack.mcmeta")
  fs.copySync("../template/pack.png",
              "../../temp/#{minecraftVer} - #{packVer} - 2/S_lang_files_in_#{minecraftVer}/pack.png")

  # リソースパックのzip
  output.zipUp("../../temp/#{minecraftVer} - #{packVer} - 2/.minecraft/resourcepacks/S_lang_files_in_#{minecraftVer}.zip",
               "../../temp/#{minecraftVer} - #{packVer} - 2/S_lang_files_in_#{minecraftVer}", json, 2, ->
                 if fs.existsSync("../../temp/#{minecraftVer} - #{packVer} - 2/S_lang_files_in_#{minecraftVer}")
                   fs.removeSync("../../temp/#{minecraftVer} - #{packVer} - 2/S_lang_files_in_#{minecraftVer}")
                 return
               )

  #S_lang_files_in_version.txt
  fs.mkdirsSync("../../temp/#{minecraftVer} - #{packVer} - 2/.minecraft/resourcepacks/")
  fs.writeFileSync("../../temp/#{minecraftVer} - #{packVer} - 2/.minecraft/resourcepacks/S_lang_files_in_version.txt", "#{minecraftVer} - #{packVer}");

  # readme作成
  title = "/lang_S_#{minecraftVer}(直接導入型)//////////////////////////////by S/////"
  readme = output.makeReadmeText(json, 2, title)
  fs.outputFileSync("../../temp/#{minecraftVer} - #{packVer} - 2/Readme - 導入前に読んでください.txt",
                   readme)

  # zip
  output.zipUp("S_lang_files_Ex_#{minecraftVer}_#{packVer}.zip",
               "../../temp/#{minecraftVer} - #{packVer} - 2/", json, 2, ->
                 return
               )
  return
