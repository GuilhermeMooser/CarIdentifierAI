import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'dart:io';
import '../models/detection_result.dart';
import '../services/api_service.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'dart:io';
import '../models/detection_result.dart';
import '../services/api_service.dart';

// Events
abstract class DetectionEvent extends Equatable {
  const DetectionEvent();

  @override
  List<Object> get props => [];
}

class DetectCarsEvent extends DetectionEvent {
  final File imageFile;

  const DetectCarsEvent(this.imageFile);

  @override
  List<Object> get props => [imageFile];
}

class CheckConnectionEvent extends DetectionEvent {}

// States
abstract class DetectionState extends Equatable {
  const DetectionState();

  @override
  List<Object?> get props => [];
}

class DetectionInitial extends DetectionState {}

class DetectionLoading extends DetectionState {}

class DetectionSuccess extends DetectionState {
  final ApiResponse response;
  final File imageFile;

  const DetectionSuccess(this.response, this.imageFile);

  @override
  List<Object> get props => [response, imageFile];
}

class DetectionError extends DetectionState {
  final String message;

  const DetectionError(this.message);

  @override
  List<Object> get props => [message];
}

class ConnectionChecked extends DetectionState {
  final bool isConnected;

  const ConnectionChecked(this.isConnected);

  @override
  List<Object> get props => [isConnected];
}

// Bloc
class DetectionBloc extends Bloc<DetectionEvent, DetectionState> {
  final ApiService _apiService;

  DetectionBloc(this._apiService) : super(DetectionInitial()) {
    on<DetectCarsEvent>(_onDetectCars);
    on<CheckConnectionEvent>(_onCheckConnection);
  }

  Future<void> _onDetectCars(
      DetectCarsEvent event,
      Emitter<DetectionState> emit,
      ) async {
    emit(DetectionLoading());

    try {
      final response = await _apiService.detectCars(event.imageFile);
      emit(DetectionSuccess(response, event.imageFile));
    } catch (e) {
      emit(DetectionError(e.toString()));
    }
  }

  Future<void> _onCheckConnection(
      CheckConnectionEvent event,
      Emitter<DetectionState> emit,
      ) async {
    final isConnected = await _apiService.checkConnection();
    emit(ConnectionChecked(isConnected));
  }
}