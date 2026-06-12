abstract class AppRoutes {
  static const dashboard = '/';
  static const projects = '/projects';
  static const projectDetail = '/project/:id';
  static const teleprompter = '/teleprompter/:id';
  static const structures = '/structures';
  static const prompts = '/prompts';
  static const analytics = '/analytics';
  static const suggestions = '/suggestions';
  static const settings = '/settings';

  static String projectDetailPath(String id) => '/project/$id';
  static String teleprompterPath(String id) => '/teleprompter/$id';
}
