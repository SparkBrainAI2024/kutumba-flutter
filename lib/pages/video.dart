import 'package:flick_video_player/flick_video_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kutumba/components/alert.dart';
import 'package:kutumba/components/header_logo.dart';
import 'package:kutumba/models/video.dart';
import 'package:kutumba/models/video_comment.dart';
import 'package:kutumba/pages/payment.dart';
import 'package:kutumba/services/api.dart';
import 'package:kutumba/services/user_api.dart';
import 'package:kutumba/utils/app_url.dart';
import 'package:kutumba/utils/refresh_token.dart';
import 'package:video_player/video_player.dart';

class VideoPage extends StatefulWidget {
  final Video video;

  const VideoPage(this.video, {Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _VideoPageState();
  }
}

class _VideoPageState extends State<VideoPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final ApiService _api = ApiService();

  bool loading = false;
  bool commenting = false;

  List<VideoComment> comments = [];

  FlickManager? flickManager;

  String comment = '';

  @override
  void initState() {
    super.initState();

    flickManager = FlickManager(
      videoPlayerController: VideoPlayerController.network(
        '${AppUrl.baseURL}${widget.video.videoFile}?type=api',
      ),
    );

    getComments();
  }

  // ---------------------------------------------------------------------------
  // COMMENTS
  // ---------------------------------------------------------------------------

  Future<void> getComments() async {
    try {
      final Map<String, dynamic> jsonResult =
      await _api.fetchVideoComments(widget.video.id);

      if (!mounted) {
        return;
      }

      if (jsonResult['status'] == true) {
        setState(() {
          comments = jsonResult['data'] ?? [];
          loading = false;
        });

        return;
      }

      final int statusCode = jsonResult['statusCode'];

      if (statusCode == 403) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => Payment(
              'renew',
              redirectPage: '/videos',
              hasBackBtn: true,
            ),
          ),
        );
        return;
      }

      if (statusCode == 402 || statusCode == 401) {
        final Map refreshResponse =
        await RefreshToken.refresh(context);

        if (!mounted) {
          return;
        }

        if (refreshResponse != null) {
          await getComments();
        }

        return;
      }

      if (statusCode == 409) {
        await RefreshToken.logout(
          context,
          jsonResult['message'],
        );
        return;
      }

      Alert.errorSnackbar(
        context,
        jsonResult['message']?.toString() ??
            'Unable to load comments.',
      );

      setState(() {
        loading = false;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        loading = false;
      });

      Alert.errorSnackbar(
        context,
        'Unable to load comments.',
      );
    }
  }

  Future<void> onComment() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (comment.trim().isEmpty) {
      return;
    }

    setState(() {
      commenting = true;
    });

    try {
      final UserService userApi = UserService();

      final Map<String, dynamic> jsonResult =
      await userApi.addCommentInVideo(
        widget.video.id,
        comment.trim(),
      );

      if (!mounted) {
        return;
      }

      if (jsonResult['status'] == true) {
        // Clear the text field.
        _formKey.currentState!.reset();

        setState(() {
          comment = '';
          commenting = false;
        });

        Alert.successSnackbar(
          context,
          jsonResult['message']?.toString() ??
              'Comment added successfully.',
        );

        // Refresh comments so the newly added comment appears.
        await getComments();

        return;
      }

      final int statusCode = jsonResult['statusCode'];

      if (statusCode == 402 || statusCode == 401) {
        final Map refreshResponse =
        await RefreshToken.refresh(context);

        if (!mounted) {
          return;
        }

        if (refreshResponse != null) {
          await onComment();
        }

        return;
      }

      if (statusCode == 409) {
        await RefreshToken.logout(
          context,
          jsonResult['message'],
        );
        return;
      }

      Alert.errorSnackbar(
        context,
        jsonResult['message']?.toString() ??
            'Unable to add comment.',
      );

      setState(() {
        commenting = false;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        commenting = false;
      });

      Alert.errorSnackbar(
        context,
        'Something went wrong while adding your comment.',
      );
    }
  }

  // ---------------------------------------------------------------------------
  // VIDEO
  // ---------------------------------------------------------------------------

  void playVideo(BuildContext context) {
    FocusScope.of(context).unfocus();

    showDialog(
      context: context,
      barrierColor: Colors.black,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return Stack(
          children: [
            Center(
              child: FlickVideoPlayer(
                flickManager: flickManager!!,
                preferredDeviceOrientation: const [
                  DeviceOrientation.portraitUp,
                ],
                preferredDeviceOrientationFullscreen: const [
                  DeviceOrientation.landscapeRight,
                  DeviceOrientation.landscapeLeft,
                ],
                systemUIOverlay: const [],
                flickVideoWithControls:
                const FlickVideoWithControls(
                  controls: FlickPortraitControls(),
                  videoFit: BoxFit.contain,
                ),
                flickVideoWithControlsFullscreen:
                const FlickVideoWithControls(
                  controls: FlickLandscapeControls(),
                  videoFit: BoxFit.contain,
                ),
              ),
            ),

            Positioned(
              top: 10,
              right: 10,
              child: Material(
                color: Colors.white,
                shape: const CircleBorder(),
                child: IconButton(
                  icon: const Icon(
                    Icons.close,
                    color: Colors.black,
                  ),
                  onPressed: () {
                    flickManager?.flickControlManager?.pause();

                    if (Navigator.of(dialogContext).canPop()) {
                      Navigator.of(dialogContext).pop();
                    }
                  },
                ),
              ),
            ),
          ],
        );
      },
    ).then((_) {
      if (mounted) {
        flickManager?.flickControlManager?.pause();
      }
    });
  }

  @override
  void dispose() {
    flickManager?.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // UI
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black12,

      appBar: AppBar(
        backgroundColor: Colors.black12,
        title: const HeaderLogo(),
        centerTitle: false,
      ),

      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // -------------------------------------------------------------------
          // VIDEO TITLE
          // -------------------------------------------------------------------

          Text(
            widget.video.title ?? '',
            style: const TextStyle(
              color: Color.fromARGB(255, 175, 175, 175),
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),

          const Divider(),

          // -------------------------------------------------------------------
          // VIDEO THUMBNAIL
          // -------------------------------------------------------------------

          InkWell(
            onTap: () {
              playVideo(context);
            },
            child: Stack(
              children: [
                Container(
                  height: 400,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    image: DecorationImage(
                      image: NetworkImage(
                        AppUrl.baseURL +
                            (widget.video.thumbnail ?? ''),
                      ),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),

                SizedBox(
                  height: 400,
                  width: double.infinity,
                  child: Column(
                    children: [
                      const Expanded(
                        flex: 5,
                        child: SizedBox(),
                      ),

                      Expanded(
                        flex: 8,
                        child: Container(
                          width: double.infinity,
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
                                  255,
                                  214,
                                  214,
                                  214,
                                ),
                              ),

                              Text(
                                widget.video.title ?? '',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 24,
                                  letterSpacing: 1,
                                  fontWeight: FontWeight.w700,
                                  color: Color.fromARGB(
                                    255,
                                    214,
                                    214,
                                    214,
                                  ),
                                ),
                              ),

                              if (widget.video.description != null &&
                                  widget.video.description
                                      .toString()
                                      .trim()
                                      .isNotEmpty)
                                Flexible(
                                  child: Text(
                                    widget.video.description,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      height: 1.4,
                                      fontSize: 14,
                                      letterSpacing: 1,
                                      fontWeight: FontWeight.bold,
                                      color: Color.fromARGB(
                                        255,
                                        214,
                                        214,
                                        214,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          const Divider(),

          // -------------------------------------------------------------------
          // COMMENTS TITLE
          // -------------------------------------------------------------------

          Text(
            'Comments (${comments.length})',
            style: const TextStyle(
              color: Color.fromARGB(255, 175, 175, 175),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 20),

          // -------------------------------------------------------------------
          // COMMENT FORM
          // -------------------------------------------------------------------

          Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  minLines: 5,
                  maxLines: 8,
                  textInputAction: TextInputAction.newline,
                  onChanged: (value) {
                    comment = value;
                  },
                  autovalidateMode:
                  AutovalidateMode.onUserInteraction,
                  validator: (value) {
                    if (value == null ||
                        value.trim().isEmpty) {
                      return 'Comment is required';
                    }

                    return null;
                  },
                  decoration: InputDecoration(
                    fillColor: Colors.grey[900],
                    filled: true,
                    hintText: 'Comment here...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),

                const SizedBox(height: 15),

                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    commenting
                        ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(),
                    )
                        : MaterialButton(
                      onPressed: onComment,
                      shape: RoundedRectangleBorder(
                        borderRadius:
                        BorderRadius.circular(5.0),
                      ),
                      textColor: Colors.white,
                      color:
                      Theme.of(context).primaryColor,
                      child: const Text(
                        'Comment',
                        style: TextStyle(
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // -------------------------------------------------------------------
          // COMMENTS
          // -------------------------------------------------------------------

          if (loading)
            const Padding(
              padding: EdgeInsets.all(20),
              child: Center(
                child: CircularProgressIndicator(),
              ),
            )
          else if (comments.isEmpty)
            const Padding(
              padding: EdgeInsets.all(20),
              child: Center(
                child: Text(
                  'No comments yet.',
                  style: TextStyle(
                    color: Color.fromARGB(
                      255,
                      162,
                      162,
                      162,
                    ),
                    fontSize: 14,
                  ),
                ),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: comments.length,
              itemBuilder: (
                  BuildContext context,
                  int index,
                  ) {
                final VideoComment item = comments[index];

                return Container(
                  margin: const EdgeInsets.symmetric(
                    vertical: 8.0,
                  ),
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name ?? '',
                        style: const TextStyle(
                          color: Color.fromARGB(
                            255,
                            162,
                            162,
                            162,
                          ),
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),

                      const SizedBox(height: 5),

                      Text(
                        item.comment ?? '',
                        textAlign: TextAlign.left,
                        style: const TextStyle(
                          color: Color.fromARGB(
                            255,
                            162,
                            162,
                            162,
                          ),
                          fontSize: 14,
                          height: 1.4,
                        ),
                      ),

                      const Divider(
                        color: Color.fromARGB(
                          255,
                          200,
                          200,
                          200,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}