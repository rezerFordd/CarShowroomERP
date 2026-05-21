import 'package:dio/dio.dart';
import 'package:car_showroom/core/api_client.dart';
import 'package:car_showroom/models/car/car_image.dart';

class CarImagesService {
  final ApiClient _apiClient = ApiClient();
  static const String baseImageUrl =
      'https://moscow159.panelka1.ru/static/images/cars/';

  static final Map<int, List<CarImage>> _cache = {};

static String getImageUrl(String imagePath) {
  final baseUrl = 'https://moscow159.panelka1.ru';
  String cleanPath = imagePath.startsWith('/') ? imagePath.substring(1) : imagePath;
  
  if (!cleanPath.startsWith('static/')) {
    cleanPath = 'static/$cleanPath';
  }
  return '$baseUrl/$cleanPath';
}

  Future<List<CarImage>> getCarImages(
    int carId, {
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh && _cache.containsKey(carId)) {
      return _cache[carId]!;
    }
    try {
      final response = await _apiClient.authDio.get(
        '/api/v1/user/cars/$carId/images',
      );
      if (response.statusCode == 200) {
        final List data = response.data;
        final images = data.map((json) => CarImage.fromJson(json)).toList();
        _cache[carId] = images;
        return images;
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
        );
      }
    } on DioException catch (e) {
      throw Exception('Ошибка загрузки изображений: ${e.message}');
    }
  }

  Future<CarImage?> getMainImage(int carId) async {
    final images = await getCarImages(carId);
    if (images.isEmpty) return null;
    return images.firstWhere((img) => img.isMain, orElse: () => images.first);
  }
}
