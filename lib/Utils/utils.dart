String abreviacao(String string) {
  var array = string.trim().split(" ");
  print(array);

  if (array.length == 1) {
    if (array[0].isEmpty) {
      return "";
    }
    return array[0][0];
  }
  return "${array[0][0]}${array[array.length - 1][0]}";
}