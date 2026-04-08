// lib/features/thanh_vien/services/tv_yeu_cau_service.dart

import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/errors/error_parser.dart';

import '../models/yeu_cau_cu_tru_model.dart';
import '../models/thanh_vien_request.dart';

import 'package:flutter/material.dart';
import 'dart:convert';

class YeuCauCuTruService {
  YeuCauCuTruService._();

  static final YeuCauCuTruService instance = YeuCauCuTruService._();

  Dio get _dio => ApiClient.instance.dio;

  // ── Danh sách yêu cầu (phân trang) ────────────────────────────────────

  Future<YeuCauCuTruListResult> getYeuCauList(
    GetListYeuCauCuTruRequest request,
  ) async {
    try {
      final response = await _dio.post(
        '/api/quan-he-cu-tru/yeu-cau/get-list',
        data: request.toJson(),
      );
      final data = response.data as Map<String, dynamic>;
      return YeuCauCuTruListResult.fromJson(
        data['result'] as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw ErrorParser.parse(
        e.response?.data,
        statusCode: e.response?.statusCode,
      );
    } catch (_) {
      throw const AppException('Lỗi không xác định');
    }
  }

  // ── Chi tiết một yêu cầu ───────────────────────────────────────────────

  Future<YeuCauCuTruModel> getYeuCauById(int requestId) async {
    try {
      final response = await _dio.post(
        '/api/quan-he-cu-tru/yeu-cau/get-by-id',
        data: {'requestId': requestId},
      );
      final data = response.data as Map<String, dynamic>;
      return YeuCauCuTruModel.fromJson(data['result'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ErrorParser.parse(
        e.response?.data,
        statusCode: e.response?.statusCode,
      );
    } catch (_) {
      throw const AppException('Lỗi không xác định');
    }
  }

  // ── Tạo mới yêu cầu ───────────────────────────────────────────────────

  Future<YeuCauCuTruModel> createYeuCau(TaoYeuCauCuTruRequest request) async {
    try {
      // ── TEMP DEBUG ──
      debugPrint('=== createYeuCau payload ===');
      debugPrint(jsonEncode(request.toJson()));
      // ────────────────

      final response = await _dio.post(
        '/api/quan-he-cu-tru/yeu-cau',
        data: request.toJson(),
      );

      // ── TEMP DEBUG ──
      debugPrint('=== createYeuCau response ===');
      debugPrint(jsonEncode(response.data));
      // ────────────────

      final data = response.data as Map<String, dynamic>;
      return YeuCauCuTruModel.fromJson(data['result'] as Map<String, dynamic>);
    } on DioException catch (e) {
      // ── TEMP DEBUG ──
      debugPrint('=== createYeuCau DioException ===');
      debugPrint('status: ${e.response?.statusCode}');
      debugPrint('data: ${jsonEncode(e.response?.data)}');
      // ────────────────
      throw ErrorParser.parse(
        e.response?.data,
        statusCode: e.response?.statusCode,
      );
    } catch (_) {
      throw const AppException('Lỗi không xác định');
    }
  }

  // Future<YeuCauCuTruModel> createYeuCau(TaoYeuCauCuTruRequest request) async {
  //   try {
  //     final response = await _dio.post(
  //       '/api/quan-he-cu-tru/yeu-cau',
  //       data: request.toJson(),
  //     );
  //     final data = response.data as Map<String, dynamic>;
  //     return YeuCauCuTruModel.fromJson(data['result'] as Map<String, dynamic>);
  //   } on DioException catch (e) {
  //     throw ErrorParser.parse(
  //       e.response?.data,
  //       statusCode: e.response?.statusCode,
  //     );
  //   } catch (_) {
  //     throw const AppException('Lỗi không xác định');
  //   }
  // }

  // ── Cập nhật yêu cầu (submit / withdraw / edit) ───────────────────────

  Future<YeuCauCuTruModel> updateYeuCau(
    CapNhatYeuCauCuTruRequest request,
  ) async {
    try {
      final response = await _dio.put(
        '/api/quan-he-cu-tru/yeu-cau',
        data: request.toJson(),
      );
      final data = response.data as Map<String, dynamic>;
      return YeuCauCuTruModel.fromJson(data['result'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ErrorParser.parse(
        e.response?.data,
        statusCode: e.response?.statusCode,
      );
    } catch (_) {
      throw const AppException('Lỗi không xác định');
    }
  }
}
