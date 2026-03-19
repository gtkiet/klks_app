import '../../../core/network/api_client.dart';

class ResidenceService {
  Future<Map<String, dynamic>> getMyResidences() async {
    try {
      final response = await ApiClient.post(
        '/api/cu-dan/quan-he-cu-tru',
        body: {},
      );

      if (response['isOk'] == true) {
        return {'success': true, 'data': response['result'] ?? []};
      } else {
        return {
          'success': false,
          'message': response['errors'] != null && response['errors'].isNotEmpty
              ? response['errors'][0]['description']
              : 'Không thể tải dữ liệu',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Lỗi kết nối server'};
    }
  }

  Future<Map<String, dynamic>> getResidentDetail({
    required int userId,
    required int quanHeCuTruId,
  }) async {
    try {
      final response = await ApiClient.post(
        '/api/cu-dan/thong-tin',
        body: {"userId": userId, "quanHeCuTruId": quanHeCuTruId},
      );

      if (response['isOk'] == true) {
        return {'success': true, 'data': response['result']};
      }

      return {
        'success': false,
        'message':
            response['errors']?[0]?['description'] ??
            'Không thể lấy thông tin cư dân',
      };
    } catch (e) {
      return {'success': false, 'message': 'Lỗi kết nối server'};
    }
  }

  Future<Map<String, dynamic>> getMembersByCanHoId(int canHoId) async {
    try {
      final response = await ApiClient.post(
        '/api/cu-dan/thanh-vien-cu-tru',
        body: {'canHoId': canHoId},
      );

      if (response['isOk'] == true) {
        return {'success': true, 'data': response['result'] ?? []};
      } else {
        return {'success': false, 'errors': response['errors'] ?? []};
      }
    } catch (e) {
      return {
        'success': false,
        'errors': [
          {'description': 'Lỗi khi kết nối server: $e'},
        ],
      };
    }
  }
}
