enum NavigationItems {
  navMap('/map'),
  navLanding('/landing'),
  navSearch('/search'),
  navNotifications('/notifications'),
  navAddBusiness('/addbusiness');

  const NavigationItems(this.route);

  final String route;
}
