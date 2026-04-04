# SMU-2026-CAPSTONE
팀 잇다 : <여기요> 개발용 브랜치입니다.

## 문서

- 머지 전 확인용 체크리스트: [MERGE_CHECKLIST.md](./MERGE_CHECKLIST.md)

## Yeogiyo! Client 버전관리

- 2026-04-01 1.0 ver
  > 변경사항 <br>
  > 1.시설 탭 View, Model, Service, ViewModel 개발 <br>
  > 2.Search, review, profile(my_reviews 제외), nonpayment View, ViewModel 구현 <br>
  > 3.Splash, Login, SignUp View, ViewModel 구현 <br>
  > 4.지도 View, ViewModel 구현 Constants 설정, Google Map API 연동 및 시설 탭 지도 추가 <br>
  > 5.ChatGPT - View, ViewModel 구현 및 FastAPI를 통한 연동 <br>
  > 6.기능 간 충돌 및 화면 이동 오류 수정(lib/app_router.dart; Context.go() 부분 수정) <br>


  >기타 사항
  >추가 바람

  <details>  
    <summary>수정 파일 목록 펼치기/접기</summary>    
    
    ### 수정된 파일 목록
    README.md  
    android/app/build.gradle.kts  
    android/app/src/main/AndroidManifest.xml  
    android/settings.gradle.kts  
    ios/Runner/AppDelegate.swift  
    ios/Runner/Info.plist  
    lib/app.dart  
    lib/auth/view/login_view.dart  
    lib/auth/view/signup_view.dart    
    lib/auth/view/splash_view.dart <br>
    lib/auth/viewmodel/auth_viewmodel.dart <br>
    lib/chat/service/chat_service.dart <br>
    lib/chat/view/chat_view.dart <br>
    lib/chat/viewmodel/chat_viewmodel.dart <br>
    lib/core/constants.dart <br>
    lib/facility/model/hospital_model.dart <br>
    lib/facility/model/pharmacy_model.dart <br>
    lib/facility/model/school_model.dart <br>
    lib/facility/service/hospital_service.dart <br>
    lib/facility/service/pharmacy_service.dart <br>
    lib/facility/service/school_service.dart <br>
    lib/facility/view/facility_detail_view.dart <br>
    lib/facility/view/facility_list_view.dart <br>
    lib/facility/viewmodel/facility_detail_viewmodel.dart <br>
    lib/facility/viewmodel/facility_list_viewmodel.dart <br>
    lib/home/view/home_view.dart <br>
    lib/home/viewmodel/home_viewmodel.dart <br>
    lib/main.dart <br>
    lib/map/view/map_view.dart <br>
    lib/map/viewmodel/map_viewmodel.dart <br>
    lib/non_payment/view/non_payment_view.dart <br>
    lib/profile/view/app_info_view.dart <br>
    lib/profile/view/language_setting_view.dart <br>
    lib/profile/view/profile_view.dart <br>
    lib/review/view/review_write_view.dart <br>
    lib/router/app_router.dart <br>
    lib/search/view/search_view.dart <br>
    lib/shell/main_shell.dart <br>
    pubspec.lock <br>
    pubspec.yaml <br>
    test/widget_test.dart <br>
    web/index.html <br>

  </details>
