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

# 配列内に存在するかどうか
exports.existInArray = (arr, val) ->
  if @index(arr, val) isnt -1
    return true
  else
    return false

# 配列かどうか
exports.isArray = (arr) ->
  return (arr instanceof Array)

# 文字列かどうか
exports.isString = (str) ->
  return (typeof str is "string")

# 配列または文字列に存在するかどうか
exports.exist = (arr, val) ->
  if @isArray(arr)
    return @existInArray(arr, val)
  else
    return (arr is val)
