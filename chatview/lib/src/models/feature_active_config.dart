class FeatureActiveConfig {
  const FeatureActiveConfig({
    this.enableSwipeToReply = true,
    this.enableTextField = true,
    this.enableCurrentUserProfileAvatar = false,
    this.enableOtherUserProfileAvatar = true,
    this.enablePagination = false,
    this.enableChatSeparator = true,
  });

  /// Used for enable/disable swipe to reply.
  final bool enableSwipeToReply;

  /// Used for enable/disable text field.
  final bool enableTextField;

  /// Used for enable/disable current user profile circle.
  final bool enableCurrentUserProfileAvatar;

  /// Used for enable/disable other users profile circle.
  final bool enableOtherUserProfileAvatar;

  /// Used for enable/disable pagination.
  final bool enablePagination;

  /// Used for enable/disable chat separator widget.
  final bool enableChatSeparator;
}
