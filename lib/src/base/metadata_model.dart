import 'dart:typed_data';

class AudioMetaData {
  final String? albumTitle;
  final String? artist;
  final String? title;
  final String? cdtracknumber;
  final String? duration;
  final String? genre;
  final String? bitrate;
  final String? year;
  final String? releaseDate;
  final Uint8List? imageData;

  const AudioMetaData(
      {this.albumTitle,
      this.artist,
      this.title,
      this.cdtracknumber,
      this.duration,
      this.genre,
      this.bitrate,
      this.year,
      this.releaseDate,
      this.imageData});

  factory AudioMetaData.fromJson(Map json) => AudioMetaData(
      albumTitle: json['albumTitle'],
      artist: json['artist'],
      title: json['title'],
      cdtracknumber: json['cdtracknumber'],
      genre: json['genre'],
      duration: json['duration'],
      bitrate: json['bitrate'],
      year: json['year'],
      releaseDate: json['releaseDate'],
      imageData: json['artwork']);
}
