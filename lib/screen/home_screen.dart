import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: MediaQuery.of(context).size.width,
        // decoration 사용하는 경우 "color:" 는 BoxDecoration 안에 설정해야함. 동시에 같은 레벨로 쓰면 에러발생.
        decoration: getBoxDecoration(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _Logo(),
            // Padding을 써도되지만 한번 감싸야해서.. 귀찮으니 SizedBox쓰는 경우가 많다고함.
            SizedBox(height: 30.0,),
            _AppName()
          ],
        ),
      ),
    );
  }

  BoxDecoration getBoxDecoration() {
    return BoxDecoration(
      /**
       * LinearGradient : 세로로 그라데이션
       * RadialGradient : 안쪽에서 바깥으로 그라데이션
       */
      gradient: LinearGradient(
        begin: Alignment.topCenter, // 시작색 위치
        end: Alignment.bottomCenter,
        // 시작색부터 적용
        colors: [
          Color(0xFF2A3A7C),
          Color(0xFF000118),
        ],
      ),
    );
  }
}

class _Logo extends StatelessWidget {
  const _Logo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Image.asset('asset/image/logo.png');
  }
}

class _AppName extends StatelessWidget {
  const _AppName({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final textStyle = TextStyle(
      color: Colors.white,
      fontSize: 30.0,
      fontWeight: FontWeight.w300,
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'VIDEO',
          style: textStyle,
        ),
        Text(
          'PLAYER',
          // copyWith : 기존 설정 유지 + 추가되는 항목만 덮어쓰기
          style: textStyle.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

