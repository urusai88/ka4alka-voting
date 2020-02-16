extension ListExtension<T> on List<T> {
  bool hasIndex(int index) {
    return this.length > index;
  }
}

extension MapExtension<TK, TV> on Map<TK, TV> {
  Map<TK, TV> whereKey(TK key) {
    return whereKeyFn((k) => k == key);
  }

  Map<TK, TV> whereKeyFn(bool compareFn(TK key)) {
    Map<TK, TV> r = Map<TK, TV>();

    for (final key in this.keys) {
      if (compareFn(key)) {
        r[key] = this[key];
      }
    }

    return r;
  }
}
