class ApiRoutes {
  static const String baseUrl = 'http://176.126.164.86:8000';

  static String getAds = '$baseUrl/ads/public-city/1/';
  static String adsByCategory(int categoryId) =>
      '$baseUrl/ads/public-city/1/category/$categoryId';
  static String getAdById(String id) =>
      '$baseUrl/ads/public-city/1/detail/$id/';
}
