class Marker {
  Duration start;

  Marker(this.start);

  factory Marker.fromJson(Map<String, dynamic> json) {
    String _start = json['Start']!;
    List<String> splitDuration = _start.split(':');
    int m = int.parse(splitDuration[0]);
    List<String> splitRemaining = splitDuration[1].split('.');

    return Marker(
      Duration(
        minutes: m,
        seconds: int.parse(splitRemaining[0]),
        milliseconds: int.parse(splitRemaining[1]),
      ),
    );
  }
}
