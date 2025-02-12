import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'file_picker_provider.g.dart';

@Riverpod(keepAlive: true)
FilePicker filePicker(Ref ref) => FilePicker.platform;
