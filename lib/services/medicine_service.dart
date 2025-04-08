import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:medical_storage/models/attribute.dart';
import 'package:medical_storage/models/medicine_category.dart';
import 'package:medical_storage/models/medicine_media.dart';
import 'package:medical_storage/models/medicine.dart';

import '../models/brand.dart';
import '../models/media_type.dart';
import 'base_service.dart';

class MedicineService extends BaseService<Medicine> {
  MedicineService() : super(
      endpoint: 'medicines',
      fromJson: Medicine.fromJson
  );
  // Cấu hình base URL - thay thế bằng URL thực tế của API

  // Lấy danh sách thuốc bán chạy nhất
  Future<List<Medicine>> getMedicineBestSaling() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/medicines/getMedicineBestSaling'),
        headers: {
          'Content-Type': 'application/json',
          // Thêm headers xác thực nếu cần
          // 'Authorization': 'Bearer $token'
        },
      );

      if (response.statusCode == 200) {
        final String utf8Body = utf8.decode(response.bodyBytes);
        List<dynamic> body = json.decode(utf8Body);
        return body.map((dynamic item) => Medicine.fromJson(item)).toList();
      } else {
        throw Exception('Không thể tải danh sách thuốc bán chạy. Mã lỗi: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  // Lấy danh sách thuốc mới nhất
  Future<List<Medicine>> getMedicineNew() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/medicines/newest'));


      if (response.statusCode == 200) {
        final String utf8Body = utf8.decode(response.bodyBytes);
        final List<dynamic> data = json.decode(utf8Body);

        List<Medicine> medicines = [];

        // Duyệt và xử lý từng mục
        for (var item in data) {
          try {
            // Chuyển đổi id sang String an toàn
            item['id'] = item['id'] == null ? null : item['id'].toString();

            // Tạo đối tượng Medicine
            Medicine medicine = Medicine.fromJson(item);
            if (medicine.id != null) {
              try {
                final brandResponse = await http.get(
                  Uri.parse('$baseUrl/brands/${medicine.brandId}'),
                  headers: {'Content-Type': 'application/json'},
                );

                if (brandResponse.statusCode == 200) {
                  final brandData = json.decode(utf8.decode(brandResponse.bodyBytes));
                  // Kiểm tra kiểu dữ liệu của brandData
                  if (brandData is Map<String, dynamic>) {
                    final Brand brand = Brand.fromJson(brandData);
                    medicine = medicine.copyWith(
                        brand: brand
                    );
                  } else {
                  }
                } else {
                }
              } catch (mediaError) {
              }
            }

            // Lấy media
            if (medicine.id != null) {
              try {
                final mediaResponse = await http.get(
                  Uri.parse('$baseUrl/medicine-media/by-medicine/${medicine.id}'),
                  headers: {'Content-Type': 'application/json'},
                );

                if (mediaResponse.statusCode == 200) {
                  final mediaData = json.decode(utf8.decode(mediaResponse.bodyBytes));
                  if (mediaData is List) {
                    medicine = medicine.copyWith(
                        media: mediaData.map<MedicineMedia>((item) {
                          // Đảm bảo các trường không bị null
                          if (item is! Map<String, dynamic>) {
                            return MedicineMedia(
                                medicine: medicine,
                                mediaType: MediaType.image,
                                mediaUrl: '',
                                mainImage: false
                            );
                          }

                          // Đảm bảo id được chuyển sang String
                          item['id'] = item['id'] == null ? null : item['id'].toString();

                          return MedicineMedia.fromJson(item);
                        }).toList()
                    );
                  }
                } else {
                }
              } catch (mediaError) {
              }
            }

            // Lấy attributes
            if (medicine.id != null) {
              try {
                final attributeResponse = await http.get(
                  Uri.parse('$baseUrl/attributes/medicine/${medicine.id}'),
                  headers: {'Content-Type': 'application/json'},
                );

                if (attributeResponse.statusCode == 200) {
                  final attributeData = json.decode(utf8.decode(attributeResponse.bodyBytes));

                  if (attributeData is List) {
                    medicine = medicine.copyWith(
                        attributes: attributeData.map<Attribute>((item) {
                          // Đảm bảo các trường không bị null
                          if (item is! Map<String, dynamic>) {
                            return Attribute(
                                name: '',
                                priceIn: 0,
                                priceOut: 0,
                                stock: 0
                            );
                          }

                          // Đảm bảo id được chuyển sang String
                          item['id'] = item['id'] == null ? null : item['id'].toString();

                          // Xử lý các trường số
                          item['priceIn'] = (item['priceIn'] ?? 0).toDouble();
                          item['priceOut'] = (item['priceOut'] ?? 0).toDouble();
                          item['stock'] = item['stock'] ?? 0;

                          return Attribute.fromJson(item);
                        }).toList()
                    );
                  }
                } else {
                }
              } catch (attributeError) {
              }
            }

            medicines.add(medicine);
          } catch (e) {
          }
        }

        return medicines;
      } else {
        throw Exception('Failed to load medicines: ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to get new medicines');
    }
  }

  // Tìm kiếm thuốc với nhiều tham số
  Future<List<Medicine>> searchMedicines({
    String? name,
    String? categoryId,
    String? brandId,
    String? rangePrice,
    String? sortBy,
  }) async {
    try {
      // Xây dựng query parameters
      var queryParameters = <String, String>{};
      if (name != null && name.isNotEmpty) {
        queryParameters['name'] = name;
      }
      if (categoryId != null && categoryId.isNotEmpty) {
        queryParameters['categoryId'] = categoryId;
      }
      if (brandId != null && brandId.isNotEmpty) {
        queryParameters['brandId'] = brandId;
      }
      if (rangePrice != null && rangePrice.isNotEmpty) {
        queryParameters['rangePrice'] = rangePrice;
      }
      if (sortBy != null && sortBy.isNotEmpty) {
        queryParameters['sortBy'] = sortBy;
      }

      // Tạo URL với query parameters
      var url = Uri.parse('$baseUrl/medicines/search').replace(
        queryParameters: queryParameters,
      );

      // Gửi request
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final String utf8Body = utf8.decode(response.bodyBytes);
        List<dynamic> body = json.decode(utf8Body);
        return body.map((dynamic item) => Medicine.fromJson(item)).toList();
      } else {
        throw Exception('Tìm kiếm thuốc thất bại. Mã lỗi: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  // Lấy danh sách media của một loại thuốc
  Future<List<MedicineMedia>> getAllMediaByMedicineId(String medicineId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/medicine-media/by-medicine/$medicineId'),
        headers: {
          'Content-Type': 'application/json',
        },
      );


      if (response.statusCode == 200) {
        final String utf8Body = utf8.decode(response.bodyBytes);
        List<dynamic> body = json.decode(utf8Body);
        return body.map((dynamic item) => MedicineMedia.fromJson(item)).toList();
      } else {
        throw Exception('Không thể tải media cho thuốc. Mã lỗi: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<Medicine> getMedicineById(String medicineId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/medicines/$medicineId'),
        headers: {
          'Content-Type': 'application/json',
        },
      );


      if (response.statusCode == 200) {
        final String utf8Body = utf8.decode(response.bodyBytes);
        final Map<String, dynamic> body = json.decode(utf8Body);
        return Medicine.fromJson(body);
      } else {
        throw Exception('Không thể tải chi tiết thuốc. Mã lỗi: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }
  // Lấy chi tiết một loại thuốc theo ID

  // Lọc thuốc theo khoảng giá
  Future<List<Medicine>> filterMedicinesByPriceRange(double minPrice, double maxPrice) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/medicines/filter?minPrice=$minPrice&maxPrice=$maxPrice'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final String utf8Body = utf8.decode(response.bodyBytes);
        List<dynamic> body = json.decode(utf8Body);
        return body.map((dynamic item) => Medicine.fromJson(item)).toList();
      } else {
        throw Exception('Lọc thuốc theo giá thất bại. Mã lỗi: ${response.statusCode}');
      }
    } catch (e) {rethrow;
    }
  }

  // Lấy thuốc theo danh mục
  Future<List<Medicine>> getMedicinesByCategory(String categoryId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/medicines/category/$categoryId'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final String utf8Body = utf8.decode(response.bodyBytes);
        List<dynamic> body = json.decode(utf8Body);
        return body.map((dynamic item) => Medicine.fromJson(item)).toList();
      } else {
        throw Exception('Không thể tải thuốc theo danh mục. Mã lỗi: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }
  Future<Brand> getBrandById(String brandId) async {
    final response = await http.get(Uri.parse('$baseUrl/brands/$brandId'));

    if (response.statusCode == 200) {
      final brandData = json.decode(utf8.decode(response.bodyBytes));
      return Brand.fromJson(brandData);
    } else {
      throw Exception('Failed to load brand');
    }
  }
  // Lấy tất cả các loại thuốc
  Future<List<Medicine>> getAllMedicines() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/medicines'));
      if (response.statusCode == 200) {
        final String utf8Body = utf8.decode(response.bodyBytes);
        final List<dynamic> data = json.decode(utf8Body);
        List<Medicine> medicines = [];

        // Duyệt và xử lý từng mục
        for (var item in data) {
          try {
            // Chuyển đổi id sang String an toàn
            item['id'] = item['id'] == null ? null : item['id'].toString();

            // Tạo đối tượng Medicine
            Medicine medicine = Medicine.fromJson(item);

            if (medicine.id != null) {
              try {
                final brandResponse = await http.get(
                  Uri.parse('$baseUrl/brands/${medicine.brandId}'),
                  headers: {'Content-Type': 'application/json'},
                );

                if (brandResponse.statusCode == 200) {
                  final brandData = json.decode(utf8.decode(brandResponse.bodyBytes));
                  medicine = medicine.copyWith(
                      brand: brandData
                  );
                } else {
                }
              } catch (mediaError) {
              }
            }

            // Lấy media
            if (medicine.id != null) {
              try {
                final mediaResponse = await http.get(
                  Uri.parse('$baseUrl/medicine-media/by-medicine/${medicine.id}'),
                  headers: {'Content-Type': 'application/json'},
                );

                if (mediaResponse.statusCode == 200) {
                  final mediaData = json.decode(utf8.decode(mediaResponse.bodyBytes));

                  if (mediaData is List) {
                    medicine = medicine.copyWith(
                        media: mediaData.map<MedicineMedia>((item) {
                          // Đảm bảo các trường không bị null
                          if (item is! Map<String, dynamic>) {
                            return MedicineMedia(
                                medicine: medicine,
                                mediaType: MediaType.image,
                                mediaUrl: '',
                                mainImage: false
                            );
                          }

                          // Đảm bảo id được chuyển sang String
                          item['id'] = item['id'] == null ? null : item['id'].toString();

                          return MedicineMedia.fromJson(item);
                        }).toList()
                    );
                  }
                } else {
                }
              } catch (mediaError) {
              }
            }

            // Lấy attributes
            if (medicine.id != null) {
              try {
                final attributeResponse = await http.get(
                  Uri.parse('$baseUrl/attributes/medicine/${medicine.id}'),
                  headers: {'Content-Type': 'application/json'},
                );
                if (attributeResponse.statusCode == 200) {
                  final attributeData = json.decode(utf8.decode(attributeResponse.bodyBytes));
                  if (attributeData is List) {
                    medicine = medicine.copyWith(
                        attributes: attributeData.map<Attribute>((item) {
                          // Đảm bảo các trường không bị null
                          if (item is! Map<String, dynamic>) {
                            return Attribute(
                                name: '',
                                priceIn: 0,
                                priceOut: 0,
                                stock: 0
                            );
                          }

                          // Đảm bảo id được chuyển sang String
                          item['id'] = item['id'] == null ? null : item['id'].toString();

                          // Xử lý các trường số
                          item['priceIn'] = (item['priceIn'] ?? 0).toDouble();
                          item['priceOut'] = (item['priceOut'] ?? 0).toDouble();
                          item['stock'] = item['stock'] ?? 0;

                          return Attribute.fromJson(item);
                        }).toList()
                    );
                  }
                } else {
                }
              } catch (attributeError) {
              }
            }

            medicines.add(medicine);
          } catch (e) {
          }
        }

        return medicines;
      } else {
        throw Exception('Không thể tải danh sách thuốc. Mã lỗi: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }
  Future<List<Medicine>> enrichMedicineList(List<Medicine> medicines) async {
    try {
      final enrichedMedicines = await Future.wait(medicines.map((medicine) async {
        try {
          // In ra ID để kiểm tra

          // Bắt buộc phải có ID
          if (medicine.id == null) {
            return medicine;
          }

          // Thử lấy media
          List<MedicineMedia> media = [];
          try {
            media = await getAllMediaByMedicineId(medicine.id!);
          } catch (mediaError) {
          }

          // Thử lấy chi tiết thuốc
          Medicine? fullMedicineDetails;
          try {
            fullMedicineDetails = await getMedicineById(medicine.id!);
          } catch (detailError) {
          }

          // Trả về thuốc với dữ liệu mới nếu có
          return medicine.copyWith(
            media: media.isNotEmpty ? media : medicine.media,
            attributes: fullMedicineDetails?.attributes.isNotEmpty == true
                ? fullMedicineDetails!.attributes
                : medicine.attributes,
          );
        } catch (e) {
          return medicine;
        }
      }));

      return enrichedMedicines;
    } catch (e) {
      return medicines;
    }
  }
}

