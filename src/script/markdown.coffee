###
  bbcode.coffee
  BBcodeを生成します
###
fs = require "fs-extra"

exports.modJsonToBBcode = (modJson) ->
  bbcode = " - "
  if modJson.url?
    bbcode += "[#{modJson.name}](#{modJson.url})・・・"
  else
    bbcode += "#{modJson.name}・・・"
  bbcode += "#{modJson.version}(" + modJson["minecraft-version"].join("/") + ")"
  if modJson.contributors?
    bbcode += " Thanks, #{modJson.contributors}さん"
  if modJson.note?
    bbcode += " #{modJson.note}"
  bbcode += "\r\n"
  return bbcode

exports.output = (json) ->
  bbcode = "# " + json["minecraft-version"] + "\r\n"
  for mod in json.mods
    bbcode += @modJsonToBBcode(mod)
  fs.writeFile("../../output/markdown/" + json["minecraft-version"] + " - " + json["pack-version"] + ".txt", bbcode, (err) ->
    if err?
      console.log err
  )
  return
