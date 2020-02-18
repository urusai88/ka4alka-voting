extension ListExtension<T> on List<T> {
  bool hasIndex(int index) {
    return this.length > index;
  }
}

extension IterableExtension<T> on Iterable<T> {
  Iterable<T> insert(T element) sync* {
    var it = iterator;

    var zero = true;

    while (true) {
      if (zero) {
        zero = false;

        if (it.moveNext())
          yield it.current;
        else
          break;
      }

      if (it.moveNext()) {
        yield element;
        yield it.current;
      } else
        break;
    }
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
