## vid_player
- 보관함에서 선택하는 시나리오로 진행
- `Image Picker` 이용으로 인해 `info.plist` 수정함 -> pub.dev 내용 참고

### gradient
- Container > gradient
  - 보통 배경색 지정을 많이 하기 때문에 BoxDecoration에서 `color: ` 단독으로 빠져있지만 `gradient: ` 사용하면 BoxDecoration 블럭 안에 작성해야함.
  - LinearGradient : 세로로 그라데이션, RadialGradient : 안쪽에서 바깥으로 그라데이션

### 간격 띄우기
- `Padding` 사용해도 되지만, 한번 감싸야하기도 하고 귀찮은 경우가 있다..
- 그래서 `SizedBox(height: 30.0,)` 이런 식으로 간격 띄우기 용으로 사용하기도 함

### copyWith()
- default 셋팅값을 사용하면서 특정 값만 덮어쓰기 하고 싶은 경우 이용
  - textStyle 유지하면서 fontWeight 설정값만 엎어치기
  - ```dart
    final textStyle = TextStyle(
        color: Colors.white,
        fontSize: 30.0,
        fontWeight: FontWeight.w300,
        );
    
    style: textStyle.copyWith(
      fontWeight: FontWeight.w700,
    )
    ```