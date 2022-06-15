// import 'dart:io';

// import 'package:flutter/material.dart';
// import 'package:carousel_slider/carousel_slider.dart';
// import 'package:audioplayers/audio_cache.dart';
// import 'package:audioplayers/audioplayers.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:kutumba/components/alert.dart';
// import 'package:kutumba/components/version_check.dart';
// import 'package:kutumba/models/user.dart';
// import 'package:kutumba/providers/auth.dart';
// import 'package:kutumba/providers/user_provider.dart';
// import 'package:provider/provider.dart';
// import 'package:url_launcher/url_launcher.dart';

// import 'package:kutumba/components/loader.dart';
// import 'package:kutumba/models/artist.dart';
// import 'package:kutumba/services/api.dart';
// import 'package:kutumba/utils/app_url.dart';

// import '../main_drawer.dart';
// import '../components/header_logo.dart';

// class Sample extends StatefulWidget {
//   @override
//   State<StatefulWidget> createState() {
//     return _Sample();
//   }
// }
// const kUrl1 = 'https://luan.xyz/files/audio/ambient_c_motion.mp3';
// const kUrl2 = 'https://luan.xyz/files/audio/nasa_on_a_mission.mp3';

// class _Sample extends State<Sample> {
//   final ApiService _api = ApiService();
//   AuthProvider _auth = AuthProvider();
//   bool isAuthenticated = false;

//   List<Artist> artists = [];
//   String appMusic;
//   String fbLink;
//   String instagramLink;
//   String youtubeLink;
//   String twitterLink;

//   bool loading = true;
//   AudioCache audioCache = AudioCache();
//   AudioPlayer audioPlayer = AudioPlayer(playerId: 'home_audio');
//   bool playerMode = true;

//   List<AudioFile> audiolist = [
//     AudioFile(
//       title: 'Sample 1',
//       url: 'https://demo.kutumba8.com/uploads/audio/1618828176.mp3',
//       playingstatus: 0
//     ),
//     AudioFile(
//       title: 'Sample 2',
//       url: 'https://demo.kutumba8.com/uploads/audio/1618828253.mp3',
//       playingstatus: 0
//     )
//   ];

//   void getHomePage() async {
//     try{
//       Map jsonResult = await _api.fetchHomepage(); 

//       if(jsonResult == null) {
//         Alert.errorSnackbar(context, 'Something went wrong!');
//         return;
//       }
      
//       final List artistsList = jsonResult['artists'];
//       artists = artistsList.map((val) => Artist.fromJson(val)).toList();

//       Map siteConfig = jsonResult['site_config'];
//       appMusic = AppUrl.baseURL + siteConfig['home_page_audio'];
      
//       fbLink = siteConfig['facebook_link'];
//       instagramLink = siteConfig['instagram_link'];
//       twitterLink = siteConfig['twitter_link'];
//       youtubeLink = siteConfig['youtube_link'];

//       if (Platform.isIOS) {
//         if (audioCache.fixedPlayer != null) {
//           audioCache.fixedPlayer.startHeadlessService();
//         }
//         audioPlayer.startHeadlessService();
//       }
      
//       await audioPlayer.setUrl(appMusic); // prepare the player with this audio but do not start playing
//       await audioPlayer.setReleaseMode(ReleaseMode.LOOP);
//       // await audioPlayer.resume();
//       await audioPlayer.play(appMusic);

//       setState(() {
//         loading = false;
//       });

//       VersionCheck.checkLatestVersion(context);
//     }catch(e) {
//       Alert.errorSnackbar(context, 'Something went wrong!');
//     }
//   }

//   @override
//   void initState() {
//     super.initState();    
//     getHomePage();
//   }

//   @override
//   void dispose() {
//     if(audioPlayer != null)
//       audioPlayer.stop();
//     super.dispose();
//   }

//   @override
//   void didChangeDependencies() {
//     final user = Provider.of<UserProvider>(context).user;
//     print('home');
//     print(user?.username);

//     isAuthenticated = user != null;

//     super.didChangeDependencies();
//   }

//   @override
//   Widget build(BuildContext context) {
    
//     return loading ? Loader() : Scaffold(
//       backgroundColor: Colors.black12,
//       endDrawer: isAuthenticated ? MainDrawer() : null,
//       appBar: AppBar(
//         backgroundColor: Colors.black12,
//         title: HeaderLogo(),
//         centerTitle: false,
//         actions: !isAuthenticated ? [
//           TextButton(
//             child: Text('LOG IN',
//               style: TextStyle(
//                 color: Color.fromARGB(255, 162, 162, 162),
//               )
//             ),
//             onPressed: () {
//               Navigator.pushNamed(context, '/login');
//             },
//           ),
//           TextButton(
//             child: Text('SIGN UP',
//               style: TextStyle(
//                 color: Color.fromARGB(255, 162, 162, 162),
//               )
//             ),
//             onPressed: () {
//               Navigator.pushNamed(context, '/register');
//             },
//           )
//         ] : [],
//       ),
//       body: Stack(
//         children: [
//           ListView(
//             children: [
//               CarouselSlider(
//                 options: CarouselOptions(
//                   autoPlay: true,
//                   height: MediaQuery.of(context).size.height,
//                   viewportFraction: 1.0,
//                   autoPlayInterval: Duration(seconds: 6),
//                 ),
//                 items: artists.map((artist) {
//                   return Builder(
//                     builder: (BuildContext context) {
//                       return Container(
//                         width: MediaQuery.of(context).size.width,
//                         margin: EdgeInsets.symmetric(horizontal: 0.0),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Image.network(
//                               AppUrl.baseURL+artist.photo,
//                               height: 400,
//                               loadingBuilder:(BuildContext context, Widget child,ImageChunkEvent loadingProgress) {
//                                 if (loadingProgress == null) return child;
//                                 return Center(
//                                   heightFactor: 10.0,
//                                   child: CircularProgressIndicator(
//                                     backgroundColor: Colors.black,
//                                     value: loadingProgress.expectedTotalBytes != null ? 
//                                         loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes
//                                         : null,
//                                   ),
//                                 );
//                               },
//                             ),
//                             Padding(
//                               padding: const EdgeInsets.fromLTRB(20,0,20,20),
//                               child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Text(artist.firstName.toUpperCase(),
//                                     style: TextStyle(
//                                       color: Color.fromARGB(255, 162, 162, 162),
//                                       fontSize: 18,
//                                       fontWeight: FontWeight.bold,
//                                       letterSpacing: 12
//                                     )
//                                   ),
//                                   SizedBox(
//                                     height: 10,
//                                   ),
//                                   if(artist.sliderText != null)
//                                     Text(artist.sliderText,
//                                       style: TextStyle(
//                                           color: Color.fromARGB(255, 162, 162, 162),
//                                           fontSize: 14,
//                                           height: 1.4
//                                       )
//                                     )
//                                 ],
//                               )
//                             ),
//                           ]
//                         )
//                       );
//                     },
//                   );
//                 }).toList(),
//               ),
//               StreamProvider<Duration>.value(
//                 initialData: Duration(),
//                 value: audioPlayer.onAudioPositionChanged,
//                 child: Column(
//                   children: [
//                     for(var index=0; index < audiolist.length; index++)
//                       GestureDetector(
//                         onTap: () async {
//                           playerMode = false;
//                           if (audiolist[index].playingstatus == 0) {
//                             await audioPlayer.stop();
//                             await audioPlayer.play(audiolist[index].url);
//                             setState(() {
//                               for (int i = 0; i < audiolist.length; i++) {
//                                 audiolist[i].playingstatus = 0;
//                               }
//                               audiolist[index].playingstatus = 1;
//                             });
//                           } else if (audiolist[index].playingstatus == 1) {
//                             await audioPlayer.stop();
//                             setState(() {
//                               for (int i = 0; i < audiolist.length; i++) {
//                                 audiolist[i].playingstatus = 0;
//                               }
//                             });
//                           }
//                         },
//                         child: ListTile(
//                           leading: Icon(Icons.music_note_outlined),
//                           title: Text(audiolist[index].title),
//                           trailing: audiolist[index].playingstatus == 0
//                               ? Icon(Icons.play_arrow)
//                               : Icon(Icons.pause),
//                         ),
//                       ),
//                     SizedBox(height: 50),
//                   ],
//                 ),
//               ),
//             ]
//           ),
//           Positioned(
//             bottom: 0,
//             right: 0,
//             left: 0,
//             child: Material(
//               color: Colors.black,
//               // decoration: BoxDecoration(color: Colors.black),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                 children: [
//                   IconButton(
//                     icon: Icon(FontAwesomeIcons.facebook),
//                     onPressed: () {
//                       launch(fbLink);
//                     },
//                   ),
//                   IconButton(
//                     icon: Icon(FontAwesomeIcons.instagram),
//                     onPressed: () {
//                       launch(instagramLink);
//                     },
//                   ),
//                   IconButton(
//                     icon: Icon(FontAwesomeIcons.twitter),
//                     onPressed: () {
//                       launch(twitterLink);
//                     },
//                   ),
//                   IconButton(
//                     icon: Icon(FontAwesomeIcons.youtube),
//                     onPressed: () {
//                       launch(youtubeLink);
//                     },
//                   ),
//                   TextButton(
//                     child: Image.network(
//                       AppUrl.baseURL+'themes/asterisk/images/redirect.png',
//                       height: 30,
//                     ),
//                     onPressed: () {
//                       launch('http://www.kutumbaband.com/');
//                     },
//                   )
//                 ],
//               ),
//             ),
//           ),
//           Positioned(
//             top: 0,
//             right: 0,
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.end,
//               children: [
//                 Padding(
//                   padding: EdgeInsets.all(0),
//                   child: TextButton(
//                     style: ButtonStyle(
//                       overlayColor: MaterialStateColor.resolveWith((states) => Colors.black),
//                     ),
//                     child: Image.asset(
//                       playerMode ? "assets/images/audio_play.gif" : "assets/images/audio_pause.png",
//                       height: 30,
//                       alignment: Alignment.topRight,
//                     ),
//                     onPressed: () async {
                      
//                       for (int i = 0; i < audiolist.length; i++) {
//                         audiolist[i].playingstatus = 0;
//                       }
                              
//                       audioPlayer.setUrl(appMusic);
//                       if(playerMode)
//                         await audioPlayer.pause();
//                       else
//                         await audioPlayer.resume();

//                       setState(() {
//                         playerMode = !playerMode;
//                       });
//                     }
//                   )
//                 ),
//               ],
//             ),
//           ),
//         ]
//       )
//     );
//   }
// }

// class Advanced extends StatefulWidget {
//   final AudioPlayer advancedPlayer;

//   const Advanced({Key key, this.advancedPlayer}) : super(key: key);

//   @override
//   _AdvancedState createState() => _AdvancedState();
// }

// class _AdvancedState extends State<Advanced> {
//   bool seekDone;

//   @override
//   void initState() {
//     widget.advancedPlayer.onSeekComplete
//         .listen((event) => setState(() => seekDone = true));
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final audioPosition = Provider.of<Duration>(context);
//     return SingleChildScrollView(
//       child: Column(
//           children: [
//             Column(
//               children: [
//                 Text('Source Url'),
//                 Row(children: [
//                   MaterialButton(
//                     child: Text('A2'),
//                     onPressed: (){
//                       widget.advancedPlayer.setUrl(kUrl1);
//                       widget.advancedPlayer.resume();
//                     },
//                   ),
//                   MaterialButton(
//                       child: Text('A1'),
//                     onPressed: () {
//                       widget.advancedPlayer.setUrl(kUrl2);
//                       widget.advancedPlayer.resume();
//                     }
//                   ),
//                 ], mainAxisAlignment: MainAxisAlignment.spaceEvenly),
//               ],
//             ),
//             Text('Audio Position: ${audioPosition}'),
//             if (seekDone != null) Text(seekDone ? 'Seek Done' : 'Seeking...'),

//             Column(
//               children: [
//                 Text('Control'),
//                 Row(
//                   children: [
//                     MaterialButton(
//                       child: Text('Resume'),
//                       onPressed: () => widget.advancedPlayer.resume(),

//                     ),
//                     MaterialButton(
//                       child: Text('Pause'),
//                       onPressed: () => widget.advancedPlayer.pause(),
//                     ),
//                   ],
//                   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                 ),
//               ],
//             ),
//             SizedBox(height: 60)
            
            
//           ],
        
//       ),
//     );
//   }
// }

// class AudioFile {
//   final String title;
//   final String url;
//   int playingstatus;
//   AudioFile({this.title, this.url, this.playingstatus = 0});
// }