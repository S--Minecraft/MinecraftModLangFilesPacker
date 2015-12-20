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

  baseToPath = "../../temp/#{minecraftVer} - #{packVer} - 2"
  baseToPathRes = "../../temp/S_lang_files_in_#{minecraftVer}"

  # 翻訳ファイルコピー
  for mod in json.mods
    baseFromPath = "../../../MinecraftModLangFiles/#{mod.name}/#{mod.version}"

    if !fs.existsSync(baseFromPath)
      console.log "Doesn't exist! : " + "/#{mod.name}/#{mod.version}/"
    else
      # advanced時
      if mod.advanced?
        # ファイル指定時
        if mod.advanced.file? then fileName = mod.advanced.file else fileName = ""
        if mod.advanced.type is "config"
          if not util.existInArray(paths, mod.advanced.path)
            toPath = ".minecraft/config/#{mod.advanced.path}/#{fileName}"
          else
            toPath = ".minecraft/config/#{mod.advanced.path} - #{mod.version}/#{fileName}"
            escaped.push(mod)
          paths.push(mod.advanced.path)
        else if mod.advanced.type is "zip"
          toPath = "#{baseToPath}/To_zip,jar/#{mod.name} - #{mod.version}/#{fileName}"
        fs.copySync("#{baseFromPath}/#{fileName}", "#{baseToPath}/#{toPath}")
      if mod.path?
        # pathがオブジェクトの時
        if util.isObject(mod.path)
          for key, val of mod.path
            toPath = "#{baseToPathRes}/#{val}"
            if util.existInArray(paths, val)
              toPath += " - #{mod.version}"
              escaped.push(mod)
            fs.copySync("#{baseFromPath}/#{key}", toPath)
            paths.push(val)
        else if util.isString(mod.path)
          toPath = "#{baseToPathRes}/#{mod.path}"
          if util.existInArray(paths, val)
            toPath += " - #{mod.version}"
            escaped.push(mod)
          fs.copySync("#{baseFromPath}", toPath)
          paths.push(val)
  #pack.mcmetaとpack.png
  fs.copySync("../template/pack.mcmeta", "#{baseToPathRes}/pack.mcmeta")
  fs.copySync("../template/pack.png", "#{baseToPathRes}/pack.png")

  #S_lang_files_in_version.txt
  fs.mkdirsSync("#{baseToPath}/.minecraft/resourcepacks/")
  fs.writeFileSync("#{baseToPath}/.minecraft/resourcepacks/S_lang_files_in_version.txt",
                   "#{minecraftVer} - #{packVer}")

  # readme作成
  title = "/lang_S_#{minecraftVer}(直接導入型)//////////////////////////////by S/////"
  readme = output.makeReadmeText(json, type, title, escaped)
  fs.outputFileSync("#{baseToPath}/Readme - 導入前に読んでください.txt", readme)

  # リソースパックのzip
  output.zipOne("temp/#{minecraftVer} - #{packVer} - 2/.minecraft/resourcepacks/S_lang_files_in_#{minecraftVer}.zip","temp/S_lang_files_in_#{minecraftVer}", json, ->
    # リソースパックがzipされてから実行する
    # zip
    output.zipUp("S_lang_files_Ex_#{minecraftVer}_#{packVer}.zip", json, type, callback)
    return
  )
  return
