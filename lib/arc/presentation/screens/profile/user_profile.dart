import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hii_xuu_social/arc/data/models/data_models/post.dart';
import 'package:hii_xuu_social/arc/data/models/data_models/user.dart';
import 'package:hii_xuu_social/arc/presentation/blocs/profile/profile_bloc.dart';
import 'package:hii_xuu_social/arc/presentation/screens/chat/child/box_chat_screen.dart';
import 'package:hii_xuu_social/arc/presentation/screens/home/child/detail_post.dart';
import 'package:hii_xuu_social/arc/presentation/screens/home/widget/post_item.dart';
import 'package:hii_xuu_social/arc/presentation/screens/profile/widget/empty_user_profile.dart';
import 'package:hii_xuu_social/arc/presentation/screens/profile/widget/loading_profile.dart';
import 'package:hii_xuu_social/arc/presentation/widgets/custom_button.dart';
import 'package:hii_xuu_social/src/styles/dimens.dart';
import 'package:hii_xuu_social/src/styles/images.dart';
import 'package:hii_xuu_social/src/utilities/navigation_service.dart';
import 'package:hii_xuu_social/src/validators/constants.dart';
import 'package:hii_xuu_social/src/validators/static_variable.dart';
import 'package:hii_xuu_social/src/validators/translation_key.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../blocs/notice/notice_bloc.dart';
import '../search/following_follower_list.dart';
import 'widget/full_image.dart';

class UserProfile extends StatefulWidget {
  final String userId;

  const UserProfile({Key? key, required this.userId}) : super(key: key);

  @override
  _UserProfileState createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider<ProfileBloc>(
      create: (context) => ProfileBloc(),
      child: _Body(
        userId: widget.userId,
      ),
    );
  }
}

class _Body extends StatefulWidget {
  final String userId;

  const _Body({Key? key, required this.userId}) : super(key: key);

  @override
  State<_Body> createState() => _BodyState();
}

class _BodyState extends State<_Body> {
  UserData _user = UserData();
  bool _isFollowing = false;
  List<PostData> _listPhotos = [];
  int _currentIndexTab = 0;

  @override
  void initState() {
    super.initState();
    context.read<ProfileBloc>().add(InitProfileUserEvent(widget.userId));
  }

  void goToBoxChat(UserData user) {
    navService.push(
      MaterialPageRoute(
        builder: (context) => BoxChatScreen(
          userId: user.userId ?? '',
          username: user.fullName ?? '',
          imageUser: user.imageUrl,
        ),
      ),
    );
  }

  Future<void> _showSettingDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true, // user must tap button!
      barrierColor: Colors.black12,
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: Dimens.size50),
          child: AlertDialog(
            elevation: 0,
            insetPadding: EdgeInsets.zero,
            contentPadding: EdgeInsets.zero,
            backgroundColor: Theme.of(context).backgroundColor,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: Dimens.size30),
                ClipRRect(
                  borderRadius: BorderRadius.circular(25),
                  child: SizedBox(
                    height: Dimens.size80,
                    width: Dimens.size80,
                    child: _user.imageUrl == ''
                        ? Image.asset(MyImages.defaultAvt)
                        : Image.network(
                            _user.imageUrl ?? '',
                            fit: BoxFit.cover,
                          ),
                  ),
                ),
                const SizedBox(height: Dimens.size20),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: Dimens.size20),
                  child: Text(
                    'Unfollow ${_user.fullName}?',
                    style: Theme.of(context).textTheme.headline6,
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: Dimens.size10),
                const Divider(),
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop();
                    context
                        .read<ProfileBloc>()
                        .add(OnUnFollowClickedEvent(widget.userId));
                  },
                  child: Container(
                    color: Colors.transparent,
                    height: Dimens.size30,
                    width: MediaQuery.of(context).size.width,
                    child: Center(
                      child: Text(
                        'Unfollow',
                        style: Theme.of(context)
                            .primaryTextTheme
                            .headline6
                            ?.copyWith(
                                color: Theme.of(context).colorScheme.secondary),
                      ),
                    ),
                  ),
                ),
                const Divider(),
                GestureDetector(
                  child: Container(
                    color: Colors.transparent,
                    height: Dimens.size30,
                    width: MediaQuery.of(context).size.width,
                    child: Center(
                      child: Text(
                        'Cancel',
                        style: Theme.of(context).textTheme.headline6,
                      ),
                    ),
                  ),
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                ),
                const SizedBox(height: Dimens.size10),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProfileBloc, ProfileState>(
      listener: (context, state) {
        if (state is InitProfileSuccessState) {
          _user = state.user;
          if ((_user.follower ?? []).contains(StaticVariable.myData?.userId)) {
            _isFollowing = true;
          }
          _listPhotos = [];
          for (PostData post in state.user.posts ?? []) {
            if (post.images!.isNotEmpty) {
              _listPhotos.add(post);
            }
          }
        }
        if (state is OnFollowSuccessState) {
          EasyLoading.dismiss();
          _isFollowing = true;
          context.read<NoticeBloc>().add(FollowedNoticeEvent(
              authId: widget.userId,
              userFollowedId: StaticVariable.myData?.userId ?? ''));
        }
        if (state is OnUnFollowSuccessState) {
          EasyLoading.dismiss();
          _isFollowing = false;
        }
        if (state is LoadingClickedFollowState) {
          EasyLoading.show();
        }
      },
      child: BlocBuilder<ProfileBloc, ProfileState>(
        builder: (context, state) {
          if (state is LoadingInitProfileState) {
            return const LoadingProfile();
          }
          final theme = Theme.of(context);
          final size = MediaQuery.of(context).size;
          return Scaffold(
            backgroundColor: theme.backgroundColor,
            appBar: AppBar(
              elevation: 0,
              backgroundColor: Colors.transparent,
              leading: Padding(
                padding: const EdgeInsets.all(Dimens.size8),
                child: GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                      decoration: BoxDecoration(
                        color: theme.primaryColorLight,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(Dimens.size12),
                        child: Image.asset(MyImages.icBack),
                      )),
                ),
              ),
            ),
            body: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: AnimationLimiter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: AnimationConfiguration.toStaggeredList(
                    duration: const Duration(milliseconds: 300),
                    childAnimationBuilder: (widget) => SlideAnimation(
                      horizontalOffset: 50.0,
                      child: FadeInAnimation(
                        child: widget,
                      ),
                    ),
                    children: [
                      _buildAvatar(theme),
                      const SizedBox(height: Dimens.size15),
                      _buildFullName(theme),
                      const SizedBox(height: Dimens.size8),
                      _buildBio(size, theme),
                      const SizedBox(height: Dimens.size16),
                      _isFollowing == true
                          ? followingWidget(theme)
                          : notFollowingWidget(theme),
                      const SizedBox(height: Dimens.size20),
                      _buildCellCountFollow(theme),
                      _buildTabShowPost(theme),
                      switchTypeListPost(_currentIndexTab),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget switchTypeListPost(int index) {
    Widget newWidget = Container();
    switch (index) {
      case 0:
        newWidget = (_user.posts ?? []).isEmpty
            ? EmptyUserProfile(fullName: _user.fullName)
            : _buildGridImage();
        break;
      case 1:
        newWidget = (_user.posts ?? []).isEmpty
            ? EmptyUserProfile(fullName: _user.fullName)
            : _buildListPost();
        break;
      case 2:
        newWidget = Container();
        break;
    }
    return newWidget;
  }

  Padding _buildTabShowPost(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(Dimens.size15),
      child: Container(
        height: Dimens.size50,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15), color: theme.shadowColor),
        child: Row(
          children: [
            _tab(
                index: 0,
                controller: _currentIndexTab,
                label: TranslationKey.photos.tr(),
                onTap: () {
                  setState(() {
                    _currentIndexTab = 0;
                  });
                }),
            _tab(
                index: 1,
                controller: _currentIndexTab,
                label: TranslationKey.posts.tr(),
                onTap: () {
                  setState(() {
                    _currentIndexTab = 1;
                  });
                }),
          ],
        ),
      ),
    );
  }

  Widget _tab(
      {required int index,
      required int controller,
      String? label,
      required VoidCallback onTap}) {
    final theme = Theme.of(context);
    return Expanded(
      flex: 1,
      child: Padding(
        padding: const EdgeInsets.all(5.0),
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            height: Dimens.size50,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              gradient: index == controller
                  ? LinearGradient(
                      colors: [
                        theme.primaryColor,
                        theme.colorScheme.secondary,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : null,
            ),
            child: Center(
              child: Text(
                label ?? '',
                style: index == controller
                    ? theme.primaryTextTheme.button
                    : theme.primaryTextTheme.headline4,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Padding _buildGridImage() {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: Dimens.size20, vertical: Dimens.size5),
      child: MasonryGridView.count(
        shrinkWrap: true,
        crossAxisSpacing: 15,
        mainAxisSpacing: 15,
        crossAxisCount: 3,
        physics: const BouncingScrollPhysics(),
        itemBuilder: (context, index) {
          return Stack(
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: GestureDetector(
                    onTap: () {
                      navService.push(
                        PageRouteBuilder(
                          opaque: false,
                          pageBuilder: (_, __, ___) =>
                              DetailPostScreen(post: _listPhotos[index]),
                        ),
                      );
                    },
                    child: Hero(
                      tag: _listPhotos[index].images?.first ?? '',
                      child: Image.network(
                        _listPhotos[index].images?.first ?? '',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ),
              (_listPhotos[index].images ?? []).length > 1
                  ? Positioned(
                      top: Dimens.size10,
                      right: Dimens.size10,
                      child: SvgPicture.asset(MyImages.icStack))
                  : Container()
            ],
          );
        },
        itemCount: _listPhotos.length,
      ),
    );
  }

  Widget _buildListPost() {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: Dimens.size5),
        child: ListView.builder(
          shrinkWrap: true,
          physics: const BouncingScrollPhysics(),
          itemBuilder: (context, index) {
            return ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: PostItem(
                  item: _user.posts![index],
                ));
          },
          itemCount: _user.posts?.length,
        ),
      ),
    );
  }

  Row followingWidget(ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: () {
            _showSettingDialog();
          },
          child: SizedBox(
              width: Dimens.size40,
              height: Dimens.size40,
              child: Image.asset(MyImages.icSetting)),
        ),
        const SizedBox(
          width: Dimens.size15,
        ),
        GestureDetector(
          onTap: () => goToBoxChat(_user),
          child: Container(
            height: Dimens.size40,
            width: Dimens.size150,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                border: Border.all(width: 1, color: theme.primaryColor)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(Dimens.size10),
                  child: Image.asset(MyImages.icFlightSelected),
                ),
                Text(
                  TranslationKey.message.tr(),
                  style: theme.textTheme.headline2,
                ),
                const SizedBox(
                  width: Dimens.size10,
                )
              ],
            ),
          ),
        )
      ],
    );
  }

  Row notFollowingWidget(ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CustomButton(
          onTap: () {
            context
                .read<ProfileBloc>()
                .add(OnFollowClickedEvent(widget.userId));
          },
          label: TranslationKey.follow.tr(),
          sizeWidth: Dimens.size120,
          sizeHeight: Dimens.size40,
        ),
        const SizedBox(width: Dimens.size15),
        GestureDetector(
          onTap: () => goToBoxChat(_user),
          child: Container(
            width: Dimens.size40,
            height: Dimens.size40,
            decoration: BoxDecoration(
                color: theme.primaryColorLight,
                border: Border.all(width: 1, color: theme.primaryColor),
                borderRadius: BorderRadius.circular(15)),
            child: Padding(
              padding: const EdgeInsets.all(Dimens.size10),
              child: Image.asset(MyImages.icFlightSelected),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCellCountFollow(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Dimens.size10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          GestureDetector(
            onTap: () {
              navService.push(
                MaterialPageRoute(
                  builder: (context) => ListFollowUserScreen(
                    listUserId: _user.follower ?? [],
                  ),
                ),
              );
            },
            child: Container(
              color: Colors.transparent,
              child: Column(
                children: [
                  Text(
                    _user.follower?.length.toString() ?? '0',
                    style: theme.primaryTextTheme.headline2,
                  ),
                  const SizedBox(height: Dimens.size8),
                  Text(
                    TranslationKey.follower.tr(),
                    style: theme.primaryTextTheme.subtitle1,
                  ),
                ],
              ),
            ),
          ),
          Container(
            height: Dimens.size40,
            color: theme.primaryColor,
            width: Dimens.size1,
          ),
          GestureDetector(
            onTap: () {
              navService.push(
                MaterialPageRoute(
                  builder: (context) => ListFollowUserScreen(
                    listUserId: _user.following ?? [],
                  ),
                ),
              );
            },
            child: Container(
              color: Colors.transparent,
              child: Column(
                children: [
                  Text(
                    _user.following?.length.toString() ?? '0',
                    style: theme.primaryTextTheme.headline2,
                  ),
                  const SizedBox(height: Dimens.size8),
                  Text(
                    TranslationKey.following.tr(),
                    style: theme.primaryTextTheme.subtitle1,
                  ),
                ],
              ),
            ),
          ),
          Container(
            height: Dimens.size40,
            color: theme.primaryColor,
            width: Dimens.size1,
          ),
          Column(
            children: [
              Text(
                _user.posts?.length.toString() ?? '0',
                style: theme.primaryTextTheme.headline2,
              ),
              const SizedBox(height: Dimens.size8),
              Text(
                TranslationKey.posts.tr(),
                style: theme.primaryTextTheme.subtitle1,
              ),
            ],
          )
        ],
      ),
    );
  }

  SizedBox _buildBio(Size size, ThemeData theme) {
    return SizedBox(
      width: size.width,
      child: Text(
        _user.bio ?? '',
        style: theme.primaryTextTheme.bodyText2,
        textAlign: TextAlign.center,
      ),
    );
  }

  Text _buildFullName(ThemeData theme) {
    return Text(
      _user.fullName ?? Constants.fullNameDefault,
      style: theme.primaryTextTheme.headline2,
    );
  }

  Widget _buildAvatar(ThemeData theme) {
    return GestureDetector(
      onTap: () {
        navService.push(
          PageRouteBuilder(
            opaque: false,
            pageBuilder: (_, __, ___) =>
                FullImageScreen(image: [_user.imageUrl ?? '']),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(Dimens.size3),
        decoration: BoxDecoration(
            border: Border.all(width: 1, color: theme.primaryColor),
            borderRadius: BorderRadius.circular(28)),
        child: SizedBox(
          width: Dimens.size80,
          height: Dimens.size80,
          child: Hero(
            tag: _user.imageUrl ?? '',
            child: ClipRRect(
              borderRadius: BorderRadius.circular(25),
              child: _user.imageUrl == ''
                  ? Image.asset(
                      MyImages.defaultAvt,
                      fit: BoxFit.cover,
                    )
                  : Image.network(
                      _user.imageUrl ?? '',
                      fit: BoxFit.cover,
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
