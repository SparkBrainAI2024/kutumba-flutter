import 'package:flutter/material.dart';
import 'package:kutumba/models/album.dart';
import 'package:kutumba/utils/app_url.dart';
import './../components/header_logo.dart';

class AlbumDetail extends StatefulWidget {
  const AlbumDetail({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _AlbumDetail();
  }
}

class _AlbumDetail extends State<AlbumDetail> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Map data = ModalRoute.of(context).settings.arguments;

    final Album album = data['album'];

    return Scaffold(
      backgroundColor: Colors.black12,
      appBar: AppBar(
        backgroundColor: Colors.black12,
        // Here we take the value from the MyAlbumsPage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: const HeaderLogo(),
        centerTitle: false,
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 400,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    image: DecorationImage(
                      image: NetworkImage(AppUrl.baseURL + album.coverPhoto),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 15),
                    Text(album.name,
                        style: const TextStyle(
                            color: Color.fromARGB(255, 175, 175, 175),
                            fontSize: 18,
                            fontWeight: FontWeight.w400,
                            letterSpacing: 5)),
                    const SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const Expanded(
                          flex: 2,
                          child: Text('Artist:',
                              style: TextStyle(
                                  color: Color.fromARGB(255, 175, 175, 175),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  letterSpacing: 4)),
                        ),
                        Expanded(
                          flex: 3,
                          child: Text(album.artist,
                              style: const TextStyle(
                                  color: Color.fromARGB(255, 175, 175, 175),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  letterSpacing: 4)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const Expanded(
                          flex: 2,
                          child: Text('Release Date:',
                              style: TextStyle(
                                  color: Color.fromARGB(255, 175, 175, 175),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  letterSpacing: 4)),
                        ),
                        Expanded(
                          flex: 3,
                          child: Text(album.releaseDate,
                              style: const TextStyle(
                                  color: Color.fromARGB(255, 175, 175, 175),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  letterSpacing: 4)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const Expanded(
                          flex: 2,
                          child: Text('Label:',
                              style: TextStyle(
                                  color: Color.fromARGB(255, 175, 175, 175),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  letterSpacing: 4)),
                        ),
                        Expanded(
                          flex: 3,
                          child: Text(album.label,
                              style: const TextStyle(
                                  color: Color.fromARGB(255, 175, 175, 175),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  letterSpacing: 4)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 2,
                          child: Text(
                              album.track.length.toString() + ' tracks',
                              style: const TextStyle(
                                  color: Color.fromARGB(255, 175, 175, 175),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  letterSpacing: 4)),
                        ),
                        Expanded(
                          flex: 3,
                          child: Text(album.totalTime,
                              style: const TextStyle(
                                  color: Color.fromARGB(255, 175, 175, 175),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  letterSpacing: 4)),
                        ),
                      ],
                    )
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
