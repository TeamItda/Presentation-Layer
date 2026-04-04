# 머지 체크리스트

## 1. 최신 `dev` 브랜치에서 시작하기

```powershell
git checkout dev
git pull origin dev
```

## 2. 기능 브랜치 변경 범위 먼저 확인하기

```powershell
git diff --stat dev..feature/5
git diff --name-only dev..feature/5
git log --oneline --graph dev..feature/5
```

다음 항목을 먼저 확인합니다.

- 작은 기능인데 변경 파일 수가 너무 많은가?
- 브랜치가 오래되어 `dev`와 차이가 많이 벌어졌는가?
- `lib/app.dart`, `lib/router/app_router.dart` 같은 공용 파일이 포함되어 있는가?

위 항목 중 하나라도 해당되면 통째 머지보다 선별 반영이 더 안전할 가능성이 높습니다.

## 3. 파일을 두 종류로 나누기

통째로 가져와도 비교적 안전한 파일:

- 기능 전용 파일
- 특정 기능 폴더 안에서만 쓰는 파일
- 다른 화면과 직접 연결이 적은 파일

수동으로 비교 후 반영하는 것이 안전한 파일:

- `lib/app.dart`
- `lib/router/app_router.dart`
- `home_view.dart`
- 여러 기능이 함께 연결되는 공용 화면 또는 진입 파일

## 4. 기능 전용 파일만 먼저 가져오기

예시:

```powershell
git checkout feature/5 -- lib/chat/view/chat_view.dart
git checkout feature/5 -- lib/chat/viewmodel/chat_viewmodel.dart
git checkout feature/5 -- lib/chat/service/chat_service.dart
```

## 5. 공용 파일은 먼저 비교하고 직접 수정하기

```powershell
git diff dev..feature/5 -- lib/app.dart
git diff dev..feature/5 -- lib/router/app_router.dart
git show feature/5:lib/app.dart
git show feature/5:lib/router/app_router.dart
```

공용 파일을 수정할 때 기준:

- 최신 `dev`의 동작은 유지한다
- 필요한 기능만 최소 범위로 추가한다
- 관련 없는 최근 변경사항은 덮어쓰지 않는다

## 6. 반영 후 검증하기

```powershell
flutter analyze
flutter test
```

추가로 확인하면 좋은 항목:

- 새 기능 화면이 실제로 열리는가?
- 기존 핵심 화면들도 정상적으로 열리는가?
- 기존 기능이 머지 후에도 그대로 동작하는가?

## 7. 커밋 전 마지막 확인하기

```powershell
git status
git diff --cached --stat
```

확인할 내용:

- 의도한 파일만 스테이징되었는가?
- 공용 파일에 예상보다 많은 수정이 들어가 있지 않은가?
- 변경 내용이 원래 기능 목적과 일치하는가?

## 8. 커밋하기

```powershell
git add .
git commit -m "feature/5 선별 반영"
```

## 빠른 판단 기준

- 작은 기능인데 변경 파일이 많다: 선별 반영 권장
- 오래된 브랜치다: 선별 반영 권장
- `app.dart`, `app_router.dart`가 포함된다: 수동 비교 후 반영 권장
- 기능 전용 폴더만 바뀌었다: 통째 머지도 가능
- 공용 진입 파일이 포함된다: 부분 반영 우선 검토
