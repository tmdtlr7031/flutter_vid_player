import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';

// 다른 곳에서 참고할 수 있게 컴포넌트로,,
class CustomVideoPlayer extends StatefulWidget {
  final XFile video;
  final VoidCallback onNewVideoPressed;

  const CustomVideoPlayer({
    Key? key,
    required this.video,
    required this.onNewVideoPressed,
  }) : super(key: key);

  @override
  State<CustomVideoPlayer> createState() => _CustomVideoPlayerState();
}

class _CustomVideoPlayerState extends State<CustomVideoPlayer> {
  VideoPlayerController? videoPlayerController;
  Duration currentPosition = Duration();
  bool showControls = false;

  // initState 는 async 사용 불가
  @override
  void initState() {
    super.initState();
    initializeController(); // initState 실행 후 initializeController() 끝날때까지 기다리지는 않는다!
  }

  @override
  void didUpdateWidget(covariant CustomVideoPlayer oldWidget) {
    // oldWidget : 새로운 위젯이 생성되기 전 위젯
    super.didUpdateWidget(oldWidget);

    if (oldWidget.video.path != widget.video.path) {
      initializeController();
    }
  }

  initializeController() async {
    /**
     * 해당 코드 없으면 Failed assertion: line 147 pos 15: 'value >= min && value <= max': is not true. 발생
     * - 바꾸기전 영상의 currentPosition 초기화 없이 파일이 바뀌면서 싱크가 안 맞아서 발생
     * - maxPosition: videoPlayerController.value.duration을 보면 initialize 전엔 0초가 디폴트다. 따라서 videoPlayerController는 비동기로 초기화가 이뤄지기 때문에
     * - videoPlayerController 초기화 호출 전에 영상이 바뀌면 기존 영상이 1초 이상인 경우 maxPosition = 0 으로 인해 _SliderBottom의 slider 위젯에서 유효성에 걸려 에러 발생
     */
    currentPosition = Duration();

    videoPlayerController = VideoPlayerController.file(
      File(widget.video.path),
    );

    await videoPlayerController!.initialize();

    // videoPlayerController 값 변경될 때마다 실행됨
    videoPlayerController!.addListener(() {
      final currentPosition = videoPlayerController!.value.position;

      setState(() {
        this.currentPosition = currentPosition;
      });
    });

    // 선택된 파일 변경 시 새로 그려주기 위해
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (videoPlayerController == null) {
      // initializeController() 기다리지 않기 때문에 null 가능
      return CircularProgressIndicator();
    }
    return AspectRatio(
      // 영상 비율로 맞추기
      aspectRatio: videoPlayerController!.value.aspectRatio,
      child: GestureDetector(
        onTap: () {
          setState(() {
            showControls = !showControls;
          });
        },
        child: Stack(
          children: [
            VideoPlayer(
              videoPlayerController!,
            ),
            if (showControls)
              _Controls(
                isPlaying: videoPlayerController!.value.isPlaying,
                onForwardPressed: onForwardPressed,
                onPlayPressed: onPlayPressed,
                onReversePressed: onReversePressed,
              ),
            if (showControls)
              _NewVideo(
                onPressed: widget.onNewVideoPressed,
              ),
            _SliderBottom(
              currentPosition: currentPosition,
              maxPosition: videoPlayerController!.value.duration,
              onSliderChanged: onSliderChanged,
            ),
          ],
        ),
      ),
    );
  }

  void onSliderChanged(double val) {
    /**
     * 그럼 setState 했을때 왜 안되나?
     *  - addListener 로 인해 영상이 실행중이면 videoPlayerController 값이 바뀌게 되어 currentPosition 값을 변경해주고 있지만
     *  - 슬라이더를 움직이면 (onChanged) currentPosition 값은 바뀌겠지만, 해당 시점의 영상을 바뀌지 않아 의미가 없기 때문.
     *  - 따라서 슬라이더를 움직였을 때, 해당 초에 맞는 영상 시간은 맞추면 실행될 때 setState로 인해 currentPosition 값이 바뀌게 됨
     */
    videoPlayerController!.seekTo(Duration(seconds: val.toInt()));
  }

  void onForwardPressed() {
    final maxPosition = videoPlayerController!.value.duration; // 총 영상 길이
    final currentPosition = videoPlayerController!.value.position;

    Duration position = maxPosition; // 기본 0초

    // 영상 총 길이 넘어감 방지
    if ((maxPosition - Duration(seconds: 3)).inSeconds >
        currentPosition.inSeconds) {
      position = currentPosition + Duration(seconds: 3);
    }

    videoPlayerController!.seekTo(position);
  }

  void onPlayPressed() {
    setState(() {
      // 실해중이면 중지, 중지면 실행
      if (videoPlayerController!.value.isPlaying) {
        videoPlayerController!.pause();
      } else {
        videoPlayerController!.play();
      }
    });
  }

  void onReversePressed() {
    final currentPosition = videoPlayerController!.value.position;
    Duration position = Duration(); // 기본 0초

    // 영상이 3초 미만으로 실행된 경우 방지
    if (currentPosition.inSeconds > 3) {
      position = currentPosition - Duration(seconds: 3);
    }

    videoPlayerController!.seekTo(position);
  }
}

class _Controls extends StatelessWidget {
  final VoidCallback onPlayPressed;
  final VoidCallback onReversePressed;
  final VoidCallback onForwardPressed;
  final bool isPlaying; // 시작, 중지 아이콘 변경을 위해

  const _Controls(
      {Key? key,
      required this.onPlayPressed,
      required this.onReversePressed,
      required this.onForwardPressed,
      required this.isPlaying})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.5),
      height: MediaQuery.of(context).size.height,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          renderIconButton(
            onPressed: onReversePressed,
            iconData: Icons.rotate_left,
          ),
          renderIconButton(
            onPressed: onPlayPressed,
            iconData: isPlaying ? Icons.pause : Icons.play_arrow,
          ),
          renderIconButton(
            onPressed: onForwardPressed,
            iconData: Icons.rotate_right,
          ),
        ],
      ),
    );
  }

  Widget renderIconButton({
    required VoidCallback onPressed,
    required IconData iconData,
  }) {
    return IconButton(
      onPressed: onPressed,
      iconSize: 30.0,
      color: Colors.white,
      icon: Icon(
        iconData,
      ),
    );
  }
}

class _NewVideo extends StatelessWidget {
  final VoidCallback onPressed;

  const _NewVideo({
    Key? key,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      // Stack 에서 많이 쓰는 방법으로 위치 정하는 위젯 (Row에 추가해도 되지만 새로운 방법으로 진행)
      right: 0, // 오른쪽끝에서 부터 0px 만큼 이동시켜라
      child: IconButton(
        onPressed: onPressed,
        color: Colors.white,
        iconSize: 30.0,
        icon: Icon(
          Icons.photo_camera_back,
        ),
      ),
    );
  }
}

class _SliderBottom extends StatelessWidget {
  final Duration currentPosition;
  final Duration maxPosition;
  final ValueChanged<double> onSliderChanged;

  const _SliderBottom({
    Key? key,
    required this.currentPosition,
    required this.maxPosition,
    required this.onSliderChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 0,
      right: 0,
      left: 0,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Row(
          children: [
            Text(
              '${currentPosition.inMinutes} : ${(currentPosition.inSeconds % 60).toString().padLeft(2, '0')}', // 61초 나오는거 방지
              style: TextStyle(color: Colors.white),
            ),
            Expanded(
              child: Slider(
                value: currentPosition.inSeconds.toDouble(),
                // onChanged => 직접 슬라이더를 움직일때만 호출
                onChanged: onSliderChanged,
                max: maxPosition.inSeconds.toDouble(),
                min: 0,
              ),
            ),
            Text(
              '${maxPosition.inMinutes} : ${(maxPosition.inSeconds % 60).toString().padLeft(2, '0')}',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
