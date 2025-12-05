// lib/i18n/localization_manager.dart
//创建一个 StateNotifier 来管理当前的文本字典和加载状态。
//原先官方的arb不好用

//由于无法使用
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 状态类型：存储当前语言的所有键值对
typedef StringsMap = Map<String, String>;

// 默认语言代码和文件路径
const String _defaultLangCode = 'zh';
const String _basePath = 'lib/i18n/l10n/app_';

// ----------------------------------------------------
// Provider 定义
// ----------------------------------------------------

// 1. 管理当前的语言代码
final languageCodeProvider = StateProvider<String>((ref) => _defaultLangCode);

// 2. 提供 LocalizationManager 实例和当前加载的字符串
final localizationManagerProvider =
StateNotifierProvider<LocalizationManager, StringsMap>((ref) {
  // 监听语言代码的变化
  final languageCode = ref.watch(languageCodeProvider);
  return LocalizationManager(languageCode: languageCode);
});

// ----------------------------------------------------
// StateNotifier：加载和管理字符串
// ----------------------------------------------------

class LocalizationManager extends StateNotifier<StringsMap> {
  final String languageCode;

  LocalizationManager({required this.languageCode}) : super({}) {
    _loadStrings(languageCode);
  }

  Future<void> _loadStrings(String code) async {
    final path = '$_basePath$code.json';
    try {
      // 1. 从项目资源中加载 JSON 字符串
      final String jsonString = await rootBundle.loadString(path);

      // 2. 解析 JSON
      final Map<String, dynamic> jsonMap = json.decode(jsonString);

      // 3. 更新状态
      state = jsonMap.map((key, value) => MapEntry(key, value.toString()));
    } catch (e) {
      print(
          "Error loading localization file for $code: $e. Falling back to default.");
      // 如果加载失败（例如找不到文件），回退到默认语言
      if (code != _defaultLangCode) {
        _loadStrings(_defaultLangCode);
      } else {
        // 连默认语言都加载失败，则清空状态
        state = {};
      }
    }
  }

  // 暴露给 UI 的核心翻译方法
  String translate(String key, {Map<String, String>? replacements}) {
    String? text = state[key];

    if (text == null) {
      // 找不到键时返回调试信息
      return '!!$key!!';
    }

    // 简单的占位符替换 (用于 dataLoadFailed: {error})
    if (replacements != null) {
      replacements.forEach((placeholder, value) {
        text = text!.replaceAll('{$placeholder}', value);
      });
    }

    return text!;
  }
}

// ----------------------------------------------------
// 辅助方法：便捷获取翻译文本
// ----------------------------------------------------

extension TranslateExtension on WidgetRef {
  /// 通过 ref.t.translate('key') 即可获取翻译文本
  LocalizationManager get t => read(localizationManagerProvider.notifier);
}