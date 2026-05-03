class Counter {
  int _count = 0;

 void increment () => value++;

  void decrement () => value--;

  int get value => _count;

  set value (int newValue) {
    if (newValue < 0) {
      _count = 0;
    } else {
      _count = newValue;
    }
  }
}