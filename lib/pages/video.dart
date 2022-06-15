import 'package:flutter/material.dart';
import 'package:flick_video_player/flick_video_player.dart';
import 'package:flutter/services.dart';
import 'package:kutumba/models/video_comment.dart';
import 'package:kutumba/pages/payment.dart';
import 'package:kutumba/services/user_api.dart';
import 'package:kutumba/utils/refresh_token.dart';
import 'package:video_player/video_player.dart';

import 'package:kutumba/components/alert.dart';
import 'package:kutumba/models/video.dart';
import 'package:kutumba/services/api.dart';
import 'package:kutumba/utils/app_url.dart';

import '../components/header_logo.dart';

class VideoPage extends StatefulWidget {
  final Video video;

  VideoPage(this.video);

  @override
  State<StatefulWidget> createState() {
    return _VideoPage();
  }
}

class _VideoPage extends State<VideoPage> {
  final _formKey = GlobalKey<FormState>();
  bool loading = true;
  final ApiService _api = ApiService();
  List<VideoComment> comments = [];
  FlickManager flickManager;
  bool commenting = false;
  String comment;

  void playVideo(BuildContext context) {
    showDialog(
        context: context,
        barrierColor: Colors.black12.withOpacity(1),
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Stack(
            children: [
              Center(
                  child: FlickVideoPlayer(
                flickManager: flickManager,
                preferredDeviceOrientation: const [
                  DeviceOrientation.portraitUp,
                ],
                preferredDeviceOrientationFullscreen: const [
                  DeviceOrientation.landscapeRight,
                  DeviceOrientation.landscapeLeft
                ],
                systemUIOverlay: const [],
                // flickVideoWithControls: FlickVideoWithControls(
                //   controls: LandscapePlayerControls(),
                // ),
                flickVideoWithControls: const FlickVideoWithControls(
                  controls: FlickPortraitControls(),
                  videoFit: BoxFit.contain,
                ),
                flickVideoWithControlsFullscreen: const FlickVideoWithControls(
                  controls: FlickLandscapeControls(),
                  videoFit: BoxFit.contain,
                ),
              )),
              Positioned(
                top: 10,
                right: 10,
                child: Material(
                  shape: const CircleBorder(),
                  child: IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      flickManager.flickControlManager.pause();

                      Navigator.of(context).pop();
                    },
                  ),
                ),
              ),
            ],
          );
        }).then((val) {
      flickManager.flickControlManager.pause();
    });
  }

  getComments() async {
    Map jsonResult = await _api.fetchVideoComments(widget.video.id);

    if (jsonResult['status']) {
      comments = jsonResult['data'];
    } else {
      if (jsonResult['statusCode'] != null && jsonResult['statusCode'] == 403) {
        Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (context) =>
                Payment('renew', redirectPage: '/videos', hasBackBtn: true)));
        return;
      } else if (jsonResult['statusCode'] != null &&
          (jsonResult['statusCode'] == 402 ||
              jsonResult['statusCode'] == 401)) {
        Map refreshResponse = await RefreshToken.refresh(context);
        if (refreshResponse != null) {
          getComments();
        }

        return;
      } else if (jsonResult['statusCode'] != null &&
          (jsonResult['statusCode'] == 409)) {
        await RefreshToken.logout(context, jsonResult['message']);
        return;
      }
      Alert.errorSnackbar(context, jsonResult['message']);
    }

    setState(() {
      loading = false;
    });
  }

  onComment() async {
    if (_formKey.currentState.validate()) {
      setState(() {
        commenting = true;
      });
      UserService _userapi = UserService();
      Map jsonResult =
          await _userapi.addCommentInVideo(widget.video.id, comment);

      if (jsonResult['status']) {
        _formKey.currentState.reset();
        FocusScope.of(context).unfocus();

        Alert.successSnackbar(context, jsonResult['message']);
      } else {
        if (jsonResult['statusCode'] != null &&
            (jsonResult['statusCode'] == 402 ||
                jsonResult['statusCode'] == 401)) {
          Map refreshResponse = await RefreshToken.refresh(context);
          if (refreshResponse != null) {
            onComment();
          }

          return;
        } else if (jsonResult['statusCode'] != null &&
            (jsonResult['statusCode'] == 409)) {
          await RefreshToken.logout(context, jsonResult['message']);
          return;
        }
        Alert.errorSnackbar(context, jsonResult['message']);
      }

      setState(() {
        commenting = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getComments();

    flickManager = FlickManager(
      videoPlayerController: VideoPlayerController.network(
          AppUrl.baseURL + widget.video.videoFile + '?type=api'),
    );
  }

  @override
  void dispose() {
    flickManager?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black12,
      appBar: AppBar(
        backgroundColor: Colors.black12,
        // Here we take the value from the MyVideosPage object that was created by
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
                Text(widget.video.title,
                    style: const TextStyle(
                      color: Color.fromARGB(255, 175, 175, 175),
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    )),
                const Divider(),
                const Divider(),
                Column(children: [
                  InkWell(
                    child: Stack(
                      children: [
                        Container(
                          height: 400,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            image: DecorationImage(
                              image: NetworkImage(
                                  AppUrl.baseURL + widget.video.thumbnail),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 400,
                          child: Column(
                            children: [
                              Expanded(flex: 5, child: Container()),
                              Expanded(
                                flex: 8,
                                child: Container(
                                    width: double.maxFinite,
                                    padding: const EdgeInsets.all(20),
                                    decoration: const BoxDecoration(
                                      color: Color.fromARGB(160, 0, 0, 0),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Icon(
                                          Icons.play_circle_outline_rounded,
                                          size: 50,
                                          color: Color.fromARGB(
                                              255, 214, 214, 214),
                                        ),
                                        Text(widget.video.title,
                                            style: const TextStyle(
                                                fontSize: 24,
                                                letterSpacing: 1,
                                                fontWeight: FontWeight.w700,
                                                color: Color.fromARGB(
                                                    255, 214, 214, 214))),
                                        if (widget.video.description != null)
                                          Flexible(
                                            child: Text(
                                                widget.video.description,
                                                textAlign: TextAlign.center,
                                                style: const TextStyle(
                                                    height: 1.4,
                                                    fontSize: 14,
                                                    letterSpacing: 1,
                                                    fontWeight:
                                                        FontWeight.bold,
                                                    color: Color.fromARGB(
                                                        255, 214, 214, 214))),
                                          )
                                      ],
                                    )),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                    onTap: () {
                      FocusScope.of(context).unfocus();
                      playVideo(context);
                    },
                  ),
                  const Divider(),
                  const SizedBox(
                    height: 20,
                  ),
                  Text('Comments (${comments.length})',
                      style: const TextStyle(
                        color: Color.fromARGB(255, 175, 175, 175),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      )),
                  const SizedBox(
                    height: 20,
                  ),
                  Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          TextFormField(
                            minLines: 5,
                            maxLines: 8,
                            onChanged: (val) {
                              setState(() => comment = val);
                            },
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            validator: (val) {
                              if (val.isEmpty) return 'Comment is required';
                              return null;
                            },
                            decoration: InputDecoration(
                              fillColor: Colors.grey[900],
                              filled: true,
                              hintText: 'Comment here...',
                            ),
                          ),
                          const SizedBox(height: 15),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              commenting
                                  ? const CircularProgressIndicator()
                                  : MaterialButton(
                                      onPressed: () {
                                        onComment();
                                      },
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(5.0)),
                                      textColor: Colors.white,
                                      color: Theme.of(context).primaryColor,
                                      child: const Text(
                                        'Comment',
                                        style: TextStyle(letterSpacing: 1.5),
                                      ),
                                    ),
                            ],
                          )
                        ],
                      )),
                  const SizedBox(height: 5),
                  loading
                      ? const Center(child: CircularProgressIndicator())
                      : GestureDetector(
                          onTap: () {
                            FocusScope.of(context).unfocus();
                          },
                          child: Container(
                            height: 300.0,
                            padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                            child: ListView.builder(
                                itemCount: comments.length,
                                itemBuilder: (BuildContext context, i) {
                                  return Container(
                                    margin: const EdgeInsets.symmetric(
                                        vertical: 8.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text(
                                          comments[i].name,
                                          style: const TextStyle(
                                            color: Color.fromARGB(
                                                255, 162, 162, 162),
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 1,
                                          ),
                                        ),
                                        const SizedBox(height: 5),
                                        Text(comments[i].comment,
                                            textAlign: TextAlign.left,
                                            style: const TextStyle(
                                                color: Color.fromARGB(
                                                    255, 162, 162, 162),
                                                fontSize: 14,
                                                height: 1.4)),
                                        const Divider(
                                            color: Color.fromARGB(
                                                255, 200, 200, 200)),
                                      ],
                                    ),
                                  );
                                }),
                          ),
                        ),
                ]),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
