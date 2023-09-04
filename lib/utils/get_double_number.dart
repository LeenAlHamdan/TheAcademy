dynamic getDoubleNumber(double price) {
  if (price.toInt() == price) {
    return price.toInt();
  }
  return price.toStringAsFixed(2);
}

List<int> splitPrice(double price) {
  if (price.toInt() == price) {
    return [price.toInt()];
  }
  var afterDecimal = (price - price.floor()).toString();
  var arr = afterDecimal.split('.');

  return [price.floor(), int.parse(arr[1])];
}
