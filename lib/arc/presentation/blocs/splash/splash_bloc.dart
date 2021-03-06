import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hii_xuu_social/arc/data/models/data_models/user.dart';
import 'package:hii_xuu_social/src/config/app_config.dart';
import 'package:hii_xuu_social/src/preferences/app_preference.dart';
import 'package:hii_xuu_social/src/utilities/logger.dart';
import 'package:hii_xuu_social/src/validators/static_variable.dart';

part 'splash_event.dart';

part 'splash_state.dart';

class SplashBloc extends Bloc<SplashEvent, SplashState> {
  FirebaseFirestore fireStore = FirebaseFirestore.instance;

  SplashBloc() : super(InitSplashState()) {
    on<InitSplashEvent>(_onInitialSplashEvent);
  }

  void _onInitialSplashEvent(InitSplashEvent event,
      Emitter<SplashState> emit,) async {
    var userId = await AppPreference().verificationId;
    var seenOnBroad = await AppPreference().seenOnBroad;
    if (seenOnBroad == true) {
      List<String> listUserId = [];
      await fireStore
          .collection(AppConfig.instance.cUser)
          .get()
          .then((QuerySnapshot querySnapshot) {
        for (var doc in querySnapshot.docs) {
          listUserId.add(doc.id);
        }
      });
      StaticVariable.listUserId = listUserId;
      if (userId != null) {
        List<String> _listFollowing = [];
        List<String> _listFollower = [];
        await fireStore
            .collection(AppConfig.instance.cUser)
            .doc(userId)
            .collection(AppConfig.instance.cConnect)
            .doc(AppConfig.instance.cFollowing)
            .collection(AppConfig.instance.cListFollowing)
            .get()
            .then((QuerySnapshot querySnapshot) {
          for (var doc in querySnapshot.docs) {
            _listFollowing.add(doc.id);
          }
        });

        await fireStore
            .collection(AppConfig.instance.cUser)
            .doc(userId)
            .collection(AppConfig.instance.cConnect)
            .doc(AppConfig.instance.cFollowers)
            .collection(AppConfig.instance.cListFollowing)
            .get()
            .then((QuerySnapshot querySnapshot) {
          for (var doc in querySnapshot.docs) {
            _listFollower.add(doc.id);
          }
        });

        await fireStore
            .collection(AppConfig.instance.cUser)
            .doc(userId)
            .collection(AppConfig.instance.cProfile)
            .doc(AppConfig.instance.cBasicProfile)
            .get()
            .then((DocumentSnapshot documentSnapshot) async {
          if (documentSnapshot.exists) {
            var data = documentSnapshot.data();
            LoggerUtils.d(documentSnapshot.data());
            var res = data as Map<String, dynamic>;
            var user = UserData.fromJson(res);
            user.following = _listFollowing;
            user.follower = _listFollower;
            StaticVariable.myData = user;
            var firebaseToken = await AppPreference().firebaseToken;
            await fireStore
                .collection(AppConfig.instance.cUser)
                .doc(user.userId)
                .collection(AppConfig.instance.cProfile)
                .doc(AppConfig.instance.cBasicProfile)
                .set(
              {"firebase_token": firebaseToken},
              SetOptions(merge: true),
            ).then((value) {});
            emit(GotoHomeState());
          } else {
            emit(GoToLoginState());
          }
        });
      } else {
        emit(GoToLoginState());
      }
    } else {
      List<String> listUserId = [];
      await fireStore
          .collection(AppConfig.instance.cUser)
          .get()
          .then((QuerySnapshot querySnapshot) {
        for (var doc in querySnapshot.docs) {
          listUserId.add(doc.id);
        }
      });
      StaticVariable.listUserId = listUserId;
      emit(GoToOnBroadState());
    }
  }
}
