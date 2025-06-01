class ApiRoutes {
  static const String baseUrl = 'http://5.59.233.32:8080';

  static String getAds = '$baseUrl/ads/public-city/1/';
  static String adsByCategory(int categoryId) => '$baseUrl/ads/public-city/1/category/$categoryId';
  static String getAdById(int id) => '$baseUrl/ads/$id/';
}
