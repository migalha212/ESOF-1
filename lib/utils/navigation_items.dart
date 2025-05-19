enum NavigationItems {
  navMap('/map'),
  navLanding('/landing'),
  navSearch('/search'),
  navNotifications('/notifications'),
  navMapProfile('/map/profile'),
  navSearchProfile('/search/profile'),
  navMapSearch('/map/search'),
  navAddBusiness('/addbusiness'),
  navAddEvent('/add_event'),
  navProfile('/profile'),
  navLogin('/login'),
  navRegister('/register'),
  navBookmarksProfile('/bookmarks/profile'),
  navBookmarks('/bookmarks');
  const NavigationItems(this.route);

  final String route;
}
