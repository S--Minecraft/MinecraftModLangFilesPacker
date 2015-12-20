###
  mkdn.coffee
  BBcodeを生成します
###
fs = require "fs-extra"

exports.modJsonToMarkdown = (modJson) ->
  mkdn = " - "
  if modJson.url?
    mkdn += "[#{modJson.name}](#{modJson.url})・・・"
  else
    mkdn += "#{modJson.name}・・・"
  mkdn += "#{modJson.version}(" + modJson["minecraft-version"].join("/") + ")"
  if modJson.contributors?
    mkdn += " Thanks, #{modJson.contributors}さん"
  if modJson.note?
    mkdn += " #{modJson.note}"
  mkdn += "\r\n"
  return mkdn

exports.output = (json) ->
  mkdn = "# " + json["minecraft-version"] + "\r\n"
  for mod in json.mods
    mkdn += @modJsonToMarkdown(mod)
  fs.writeFile("../../output/markdown/" + json["minecraft-version"] + " - " + json["pack-version"] + ".txt", mkdn, (err) ->
    if err?
      console.log err
  )
  return
