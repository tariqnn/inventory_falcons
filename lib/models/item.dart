class Item {
  final String itemNo;
  final String name;
  double qty;

  Item(this.itemNo, this.name, this.qty);

  Map<String, dynamic> toMap() {
    return {
      'itemNo': itemNo,
      'name': name,
      'qty': qty,
    };
  }
}