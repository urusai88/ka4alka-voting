extension ListExtension<T> on List<T> {
  bool hasIndex(int index) {
    return this.length > index;
  }
}
