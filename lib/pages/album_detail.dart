import 'package:flutter/material.dart';
import 'package:kutumba/components/header_logo.dart';
import 'package:kutumba/models/album.dart';
import 'package:kutumba/utils/app_url.dart';

class AlbumDetail extends StatefulWidget {
  const AlbumDetail({super.key});

  @override
  State<AlbumDetail> createState() => _AlbumDetailState();
}

class _AlbumDetailState extends State<AlbumDetail> {
  @override
  Widget build(BuildContext context) {
    final arguments = ModalRoute.of(context)?.settings.arguments;

    if (arguments == null || arguments is! Map) {
      return Scaffold(
        backgroundColor: Colors.black12,
        appBar: AppBar(
          backgroundColor: Colors.black12,
          title: const HeaderLogo(),
          centerTitle: false,
        ),
        body: const Center(
          child: Text(
            'Album information not found.',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }

    final Album album = arguments['album'] as Album;

    return Scaffold(
      backgroundColor: Colors.black12,
      appBar: AppBar(
        backgroundColor: Colors.black12,
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
                      image: NetworkImage(
                        AppUrl.baseURL + album.coverPhoto,
                      ),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                Text(
                  album.name,
                  style: const TextStyle(
                    color: Color.fromARGB(255, 175, 175, 175),
                    fontSize: 18,
                    fontWeight: FontWeight.w400,
                    letterSpacing: 5,
                  ),
                ),
                const SizedBox(height: 15),
                _buildInfoRow(
                  label: 'Artist:',
                  value: album.artist,
                ),
                const SizedBox(height: 10),
                _buildInfoRow(
                  label: 'Release Date:',
                  value: album.releaseDate,
                ),
                const SizedBox(height: 10),
                _buildInfoRow(
                  label: 'Label:',
                  value: album.label,
                ),
                const SizedBox(height: 10),
                _buildInfoRow(
                  label: '${album.track.length} tracks',
                  value: album.totalTime,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required String label,
    required String value,
  }) {
    const textStyle = TextStyle(
      color: Color.fromARGB(255, 175, 175, 175),
      fontSize: 14,
      fontWeight: FontWeight.w400,
      letterSpacing: 4,
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: textStyle,
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(
            value,
            style: textStyle,
          ),
        ),
      ],
    );
  }
}