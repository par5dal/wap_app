// lib/features/discovery/data/datasources/discovery_remote_data_source.dart

import 'package:dio/dio.dart';
import 'package:wap_app/core/network/paginated_response.dart';
import 'package:wap_app/features/discovery/data/models/category_model.dart';
import 'package:wap_app/features/discovery/data/models/promoter_model.dart';

abstract class DiscoveryRemoteDataSource {
  Future<PaginatedResponse<CategoryModel>> getCategories({
    int page = 1,
    int limit = 20,
    String? search,
  });

  Future<PaginatedResponse<PromoterModel>> getPromoters({
    int page = 1,
    int limit = 20,
    String? search,
  });
}

class DiscoveryRemoteDataSourceImpl implements DiscoveryRemoteDataSource {
  final Dio dio;

  DiscoveryRemoteDataSourceImpl({required this.dio});

  @override
  Future<PaginatedResponse<CategoryModel>> getCategories({
    int page = 1,
    int limit = 20,
    String? search,
  }) async {
    final queryParameters = <String, dynamic>{'page': page, 'limit': limit};

    if (search != null && search.isNotEmpty) {
      queryParameters['search'] = search;
    }

    final response = await dio.get(
      '/categories',
      queryParameters: queryParameters,
    );

    return PaginatedResponse<CategoryModel>(
      data: (response.data['data'] as List)
          .map((e) => CategoryModel.fromJson(e))
          .toList(),
      meta: response.data['meta'] != null
          ? PaginationMeta.fromJson(response.data['meta'])
          : PaginationMeta(
              page: page,
              limit: limit,
              total: (response.data['data'] as List).length,
              totalPages: 1,
            ),
    );
  }

  @override
  Future<PaginatedResponse<PromoterModel>> getPromoters({
    int page = 1,
    int limit = 20,
    String? search,
  }) async {
    final queryParameters = <String, dynamic>{'page': page, 'limit': limit};

    if (search != null && search.isNotEmpty) {
      queryParameters['search'] = search;
    }

    final response = await dio.get(
      '/promoters',
      queryParameters: queryParameters,
    );

    return PaginatedResponse<PromoterModel>(
      data: (response.data['data'] as List)
          .map((e) => PromoterModel.fromJson(e))
          .toList(),
      meta: response.data['meta'] != null
          ? PaginationMeta.fromJson(response.data['meta'])
          : PaginationMeta(
              page: page,
              limit: limit,
              total: (response.data['data'] as List).length,
              totalPages: 1,
            ),
    );
  }
}
