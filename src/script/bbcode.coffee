###
  bbcode.coffee
  BBcodeを生成します
###
fs = require "fs-extra"

exports.modJsonToBBcode = (modJson) ->
  bbcode = "[*]"
  if modJson.url?
    bbcode += "[url=#{modJson.url}]#{modJson.name}[/url]・・・"
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
  bbcode = "[bg2=#0000FF][size=130][color=#FFFFFF]" + json["minecraft-version"] + "[/color][/size][/bg2]\r\n"
  bbcode += "[list]\r\n"
  for mod in json.mods
    bbcode += @modJsonToBBcode(mod)
  bbcode += "[/list]"
  fs.writeFile("../../output/bbcode/" + json["minecraft-version"] + " - " + json["pack-version"] + ".txt", bbcode, (err) ->
    if err?
      console.log err
  )
  return
