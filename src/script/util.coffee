###
  util.coffee
  Util
###
# indexOfの代用メソッド(高速化)
exports.index = (arr, val) ->
  for a, i in arr
    if a is val
      return i
  return -1;

# 配列ないに存在するかどうか
exports.existInArray = (arr, val) ->
  if @index(arr, val) isnt -1
    return true
  else
    return false

# 配列または文字列に存在するかどうか
exports.exist = (arr, val) ->
  if arr instanceof Array
    return @existInArray(arr, val)
  else
    return (arr is val)
