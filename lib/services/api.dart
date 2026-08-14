import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart';
import 'package:kutumba/models/advertisement.dart';
import 'package:kutumba/models/album.dart';
import 'package:kutumba/models/note.dart';
import 'package:kutumba/models/partner.dart';
import 'package:kutumba/models/track.dart';
import 'package:kutumba/models/video.dart';
import 'package:kutumba/models/video_comment.dart';
import 'package:kutumba/utils/app_url.dart';
import 'package:kutumba/utils/user_preferences.dart';

class ApiService {
  Future fetchHomepage() async {
    try {
      var url = Uri.parse(AppUrl.home);
      Response response = await get(url);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return null;
      }
    } catch (e) {
      // print('Error: $e');
      return null;
    }
  }

  Future fetchAlbums() async {
    List<Album> albums = [];
    String? token = await UserPreferences().getToken();

    try {
      var url = Uri.parse(AppUrl.albumList);
      Response response = await get(url, headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer ' + token!
      });

      final Map jsonResult = json.decode(response.body);

      if (response.statusCode == 200) {
        final List albumsList = jsonResult['response'];
        albums = albumsList.map((val) => Album.fromJson(val)).toList();

        return {
          'status': jsonResult['status'] == "1",
          'message': jsonResult['message'],
          'data': albums
        };
      } else {
        return {
          'status': false,
          'statusCode': response.statusCode,
          'message': jsonResult['message']
        };
      }
    } catch (e) {
      // print('Error: $e');
      return {'status': false, 'message': 'Something went wrong!'};
    }
  }

  Future fetchTracks(int albumId) async {
    List<Track> tracks = [];
    String? token = await UserPreferences().getToken();

    Map<String, dynamic> result;

    var url = Uri.parse(AppUrl.trackList + '?album_id=' + albumId.toString());

    return await get(url, headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer ' + token!
    }).then((Response response) async {
      final Map<String, dynamic> responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        final List tracksList = responseData['response'];
        tracks = tracksList.map((val) => Track.fromJson(val)).toList();
        result = {
          'status':
              (responseData['status'] == '1' || responseData['status'] == 1),
          'message': responseData['message'],
          'data': tracks
        };
      } else {
        result = {
          'status': false,
          'statusCode': response.statusCode,
          'message': responseData['message']
        };
      }
      return result;
    }).catchError(onError);
  }

  Future fetchVideos() async {
    List<Video> videos = [];
    String? token = await UserPreferences().getToken();

    Map<String, dynamic> result;
    var url = Uri.parse(AppUrl.videoList);

    return await get(url, headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer ' + token!
    }).then((Response response) async {
      final Map<String, dynamic> responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        final List videosList = responseData['response'];
        videos = videosList.map((val) => Video.fromJson(val)).toList();
        result = {
          'status':
              (responseData['status'] == '1' || responseData['status'] == 1),
          'message': responseData['message'],
          'data': videos
        };
      } else {
        result = {
          'status': false,
          'statusCode': response.statusCode,
          'message': responseData['message']
        };
      }
      return result;
    }).catchError(onError);
  }

  Future fetchVideoComments(int videoId) async {
    List<VideoComment> comments = [];
    String? token = await UserPreferences().getToken();

    Map<String, dynamic> result;
    var url = Uri.parse(AppUrl.videoCommentList);

    final Map<String, dynamic> data = {
      'video_id': videoId,
    };

    return await post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer ' + token!
      },
      body: json.encode(data),
    ).then((Response response) async {
      final Map<String, dynamic> responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        final List commentsList = responseData['response'];
        comments =
            commentsList.map((val) => VideoComment.fromJson(val)).toList();
        result = {
          'status':
              (responseData['status'] == '1' || responseData['status'] == 1),
          'message': responseData['message'],
          'data': comments
        };
      } else {
        result = {
          'status': false,
          'statusCode': response.statusCode,
          'message': responseData['message']
        };
      }
      return result;
    }).catchError(onError);
  }

  Future fetchPartners() async {
    List<Partner> partners = [];

    Map<String, dynamic> result;
    var url = Uri.parse(AppUrl.partnerList);
    String? token = await UserPreferences().getToken();

    return await get(url, headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer ' + token!
    }).then((Response response) async {
      final Map<String, dynamic> responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        final List partnersList = responseData['response'];
        partners = partnersList.map((val) => Partner.fromJson(val)).toList();
        result = {
          'status':
              (responseData['status'] == '1' || responseData['status'] == 1),
          'message': responseData['message'],
          'data': partners
        };
      } else {
        result = {
          'status': false,
          'statusCode': response.statusCode,
          'message': responseData['message']
        };
      }
      return result;
    }).catchError(onError);
  }

  Future fetchNotes() async {
    List<Note> notes = [];

    String? token = await UserPreferences().getToken();

    Map<String, dynamic> result;
    var url = Uri.parse(AppUrl.noteList);

    return await get(url, headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer ' + token!
    }).then((Response response) async {
      final Map<String, dynamic> responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        final List notesList = responseData['response'];
        notes = notesList.map((val) => Note.fromJson(val)).toList();
        result = {
          'status':
              (responseData['status'] == '1' || responseData['status'] == 1),
          'message': responseData['message'],
          'data': notes
        };
      } else {
        result = {
          'status': false,
          'statusCode': response.statusCode,
          'message': responseData['message']
        };
      }
      return result;
    }).catchError(onError);
  }

  Future fetchAdvertisements() async {
    List<Advertisement> advertisements = [];

    Map<String, dynamic> result;
    var url = Uri.parse(AppUrl.advertisementList);

    return await get(url, headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      // 'Authorization': 'Bearer '+ token
    }).then((Response response) async {
      final Map<String, dynamic> responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        final List advertisementsList = responseData['response'];
        advertisements = advertisementsList
            .map((val) => Advertisement.fromJson(val))
            .toList();
        result = {
          'status':
              (responseData['status'] == '1' || responseData['status'] == 1),
          'message': responseData['message'],
          'data': advertisements
        };
      } else {
        result = {'status': false, 'message': responseData['message']};
      }
      return result;
    }).catchError(onError);
  }

  Future checkVersion(String platform, String version) async {
    Map<String, dynamic> result;
    var url = Uri.parse(AppUrl.checkVersion).replace(queryParameters: {
      'version': version,
      'platform': platform,
    });

    return await get(
      url,
    ).then((Response response) async {
      final Map<String, dynamic> responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        result = {
          'status':
              (responseData['status'] == '1' || responseData['status'] == 1),
          'message': responseData['message'],
          'data': responseData['response']
        };
      } else {
        result = {'status': false, 'message': responseData['message']};
      }
      return result;
    }).catchError(onError);
  }

  static onError(error) {
    // print("the error is $error.detail");
    return {'status': false, 'message': 'Something went wrong!', 'data': error};
  }
}
