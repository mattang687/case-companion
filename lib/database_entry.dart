class Entry {
  Entry({this.id, this.time, this.temp, this.hum});

  int id;
  int time;
  int temp;
  int hum;

  static final columns = ["id", "time", "temp", "hum"];

  Map toMap() {
    Map map = {
      "time": time,
      "temp": temp,
      "hum": hum
    };

    if (id != null) {
      map["id"] = id;
    }

    return map;
  }

  static Entry fromMap(Map map) {
    return Entry(
      id: map["id"],
      time: map["time"],
      temp: map["temp"],
      hum: map["hum"],
    );
  }
}