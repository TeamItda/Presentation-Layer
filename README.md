# SMU-2026-CAPSTONE
팀 잇다 : &lt;여기요>

# Yeogiyo! Client

상명대학교 컴퓨터과학과 캡스톤디자인 5분반 잇다(Itda) 팀의 
<Yeogiyo!> 프로젝트 Client Repository 입니다.

# GitHub Role

해당 Repository는 다음과 같은 규칙을 따르고 있습니다.

## GitHub Branch

### 개발을 시작할 때

0. repository를 local로 가져옵니다. #예시입니다. 프로젝트를 처음 시작할 때 한 번만 하면 됩니다.
```Shell
git clone https://github.com/TeamItda/Client.git
```

1. 개발을 시작할 때는 현재(Origin) Repository에서 Issue를 생성합니다.
   <img width="1024" alt="시작 1" src="https://github.com/TeamItda/GITHUB-TEST/blob/182877d04e844f592efba6f44c84f56bef664cb6/2%EB%8B%A8%EA%B3%84.PNG">

2. 이후 Issue에서 Origin Repository의 Dev Branch에서 새로운 Branch를 생성합니다. 
**오른쪽 아래에 `Create a Branch`를 통해서 생성합니다!!**
   <img width="1024" alt="시작 2" src="https://github.com/TeamItda/GITHUB-TEST/blob/182877d04e844f592efba6f44c84f56bef664cb6/3%EB%8B%A8%EA%B3%84.PNG">

   - 이때 브랜치 이름은 다음을 따릅니다.
     - **새로운 기능 개발 : feature/#[Issue의 번호]**
     - **버그 픽스 : fix/#[Issue의 번호]**
     - **기능 리팩토링 : refactor/#[Issue의 번호]**

<img width="1024" alt="시작 3" src="https://github.com/TeamItda/GITHUB-TEST/blob/182877d04e844f592efba6f44c84f56bef664cb6/4%EB%8B%A8%EA%B3%84.PNG">

3. Local에서 Fetch를 통해 만든 New Branch(feature or fix or refactor)을 들고옵니다. 
(VScode의 경우 Git 확장 프로그램 또는 터미널 기능을 이용하면 됩니다.)

```Shell
git fetch origin
```

4. 2.에서 만든 해당 Branch로 checkout 이후 기능 개발을 진행합니다.

```Shell
git checkout feature/1 # 예시입니다.
```

### 개발을 종료할 때

1. 기능 개발이 종료되면 현재(Origin) Repository의 Branch(feature or fix or refactor)로 변경 사항을 Add 및 Push 합니다.

```Shell
git add abc.dart 또는 . #(.은 모든 변경 사항을 추가한다는 것을 의미합니다.)
git commit -m "fix login" # 예시입니다. 커밋 설명 메세지를 작성할 수 있습니다.
git push origin feature/1 # 예시입니다.
```

github 웹사이트에 들어가서 위에 보이는 Compare & Pull Request 버튼을 누릅니다!
   <img width="1024" alt="종료 1" src="https://github.com/TeamItda/GITHUB-TEST/blob/182877d04e844f592efba6f44c84f56bef664cb6/5%EB%8B%A8%EA%B3%84.PNG">

개발 종료 후 Merge할 Base branch를 미리 확인해주세요. 
   <img width="1024" alt="종료 2" src="https://github.com/TeamItda/GITHUB-TEST/blob/182877d04e844f592efba6f44c84f56bef664cb6/6%EB%8B%A8%EA%B3%84.PNG">
   
3. Code Review 이후 마지막으로 Approve한 사람은 `Dev`(원하는 파일 경로)로 `Merge`를 해줍니다.

4. PR(Pull Request)이 `Merge`되면 Local에서는 dev Branch로 checkout합니다.

```Shell
git checkout dev
```

5. Local에서 현재(Origin) Repository의 dev Branch를 pull 받습니다. (변경된 코드 새로 받아오기)

```Shell
git pull origin dev
```

## Branch Naming Convention

| Commit Type | Description      |
| ----------- | ---------------- |
| main        | 배포용           |
| dev         | 개발 커밋 통합용 |
| feature     | 기능 개발용      |
| fix         | 버그 수정용      |
| refactor    | 코드 리팩토링    |

main 브랜치는 배포에만 사용하며
기본적으로 개발과정에서는 dev 브랜치를 사용합니다. 
여러가지 개발을 병행할 때 다른 브랜치들을 사용합니다.

## Commit Convention (커밋 메세지 양식 ; 작성해야 커밋 가능합니다.)

| Commit Type | Description                                                                |
| ----------- | -------------------------------------------------------------------------- |
| feat        | Add new features                                                           |
| fix         | Fix bugs                                                                   |
| docs        | Modify documentation                                                       |
| style       | Code formatting, missing semicolons, no changes to the code itself         |
| refactor    | Code refactoring                                                           |
| test        | Add test code, refactor test code                                          |
| chore       | Modify package manager, and other miscellaneous changes (e.g., .gitignore) |
| design      | Change user UI design, such as CSS                                         |
| comment     | Add or modify necessary comments                                           |
| rename      | Only changes to file or folder names or locations                          |
| remove      | Only performing the action of deleting files                               |

## Pull Request Convention (풀 리퀘스트 메세지 양식)

| Icon | Code       | Description                       |
| ---- | ---------- | --------------------------------- |
| 🎨   | :art       | Improve code structure/formatting |
| ⚡️  | :zap       | Performance improvement           |
| 🔥   | :fire      | Delete code/files                 |
| 🐛   | :bug       | Fix bugs                          |
| 🚑   | :ambulance | Urgent fixes                      |
| ✨   | :sparkles  | Introduce new features            |
| 💄   | :lipstick  | Add/modify UI/style files         |


## 참고 링크
https://develoft.tistory.com/7 #vscode를 이용한 방법

https://velog.io/@tlsgks48/GitHub-%EA%B9%83%ED%97%88%EB%B8%8C-Repository%EC%97%90-%EC%BD%94%EB%93%9C-%EC%98%AC%EB%A6%AC%EA%B8%B0-%EB%B0%8F-%EA%B0%80%EC%A0%B8%EC%98%A4%EA%B8%B0 #안드로이드 스튜디오를 이용한 방법
