class ItemModel {
  int id;
  int parentId;
  String name;
  ItemModel(this.id, this.name, {this.parentId = 0});
}
