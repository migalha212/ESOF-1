enum NavigationItems {
  navMap('/map'),
  navLanding('/landing'),
  navSearch('/search'),
  navNotifications('/notifications'),
  navMapProfile('/map/profile'),
  navSearchProfile('/search/profile'),
  navMapSearch('/map/search'),
  navAddBusiness('/addbusiness');
  const NavigationItems(this.route);

  final String route;
}
