// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'event_image_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$EventImageModel {

 String get id;
@JsonKey(name: 'event_id') String? get eventId; String get url;
@JsonKey(name: 'is_primary') bool get isPrimary;
/// Create a copy of EventImageModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EventImageModelCopyWith<EventImageModel> get copyWith => _$EventImageModelCopyWithImpl<EventImageModel>(this as EventImageModel, _$identity);

  /// Serializes this EventImageModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EventImageModel&&(identical(other.id, id) || other.id == id)&&(identical(other.eventId, eventId) || other.eventId == eventId)&&(identical(other.url, url) || other.url == url)&&(identical(other.isPrimary, isPrimary) || other.isPrimary == isPrimary));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,eventId,url,isPrimary);

@override
String toString() {
  return 'EventImageModel(id: $id, eventId: $eventId, url: $url, isPrimary: $isPrimary)';
}


}

/// @nodoc
abstract mixin class $EventImageModelCopyWith<$Res>  {
  factory $EventImageModelCopyWith(EventImageModel value, $Res Function(EventImageModel) _then) = _$EventImageModelCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'event_id') String? eventId, String url,@JsonKey(name: 'is_primary') bool isPrimary
});




}
/// @nodoc
class _$EventImageModelCopyWithImpl<$Res>
    implements $EventImageModelCopyWith<$Res> {
  _$EventImageModelCopyWithImpl(this._self, this._then);

  final EventImageModel _self;
  final $Res Function(EventImageModel) _then;

/// Create a copy of EventImageModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? eventId = freezed,Object? url = null,Object? isPrimary = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,eventId: freezed == eventId ? _self.eventId : eventId // ignore: cast_nullable_to_non_nullable
as String?,url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,isPrimary: null == isPrimary ? _self.isPrimary : isPrimary // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [EventImageModel].
extension EventImageModelPatterns on EventImageModel {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _EventImageModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _EventImageModel() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _EventImageModel value)  $default,){
final _that = this;
switch (_that) {
case _EventImageModel():
return $default(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _EventImageModel value)?  $default,){
final _that = this;
switch (_that) {
case _EventImageModel() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'event_id')  String? eventId,  String url, @JsonKey(name: 'is_primary')  bool isPrimary)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _EventImageModel() when $default != null:
return $default(_that.id,_that.eventId,_that.url,_that.isPrimary);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'event_id')  String? eventId,  String url, @JsonKey(name: 'is_primary')  bool isPrimary)  $default,) {final _that = this;
switch (_that) {
case _EventImageModel():
return $default(_that.id,_that.eventId,_that.url,_that.isPrimary);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'event_id')  String? eventId,  String url, @JsonKey(name: 'is_primary')  bool isPrimary)?  $default,) {final _that = this;
switch (_that) {
case _EventImageModel() when $default != null:
return $default(_that.id,_that.eventId,_that.url,_that.isPrimary);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _EventImageModel implements EventImageModel {
  const _EventImageModel({required this.id, @JsonKey(name: 'event_id') this.eventId, required this.url, @JsonKey(name: 'is_primary') this.isPrimary = false});
  factory _EventImageModel.fromJson(Map<String, dynamic> json) => _$EventImageModelFromJson(json);

@override final  String id;

@override@JsonKey(name: 'event_id') final  String? eventId;
@override final  String url;

@override@JsonKey(name: 'is_primary') final  bool isPrimary;

/// Create a copy of EventImageModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EventImageModelCopyWith<_EventImageModel> get copyWith => __$EventImageModelCopyWithImpl<_EventImageModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$EventImageModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _EventImageModel&&(identical(other.id, id) || other.id == id)&&(identical(other.eventId, eventId) || other.eventId == eventId)&&(identical(other.url, url) || other.url == url)&&(identical(other.isPrimary, isPrimary) || other.isPrimary == isPrimary));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,eventId,url,isPrimary);

@override
String toString() {
  return 'EventImageModel(id: $id, eventId: $eventId, url: $url, isPrimary: $isPrimary)';
}


}

/// @nodoc
abstract mixin class _$EventImageModelCopyWith<$Res> implements $EventImageModelCopyWith<$Res> {
  factory _$EventImageModelCopyWith(_EventImageModel value, $Res Function(_EventImageModel) _then) = __$EventImageModelCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'event_id') String? eventId, String url,@JsonKey(name: 'is_primary') bool isPrimary
});




}
/// @nodoc
class __$EventImageModelCopyWithImpl<$Res>
    implements _$EventImageModelCopyWith<$Res> {
  __$EventImageModelCopyWithImpl(this._self, this._then);

  final _EventImageModel _self;
  final $Res Function(_EventImageModel) _then;

/// Create a copy of EventImageModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? eventId = freezed,Object? url = null,Object? isPrimary = null,}) {
  return _then(_EventImageModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,eventId: freezed == eventId ? _self.eventId : eventId // ignore: cast_nullable_to_non_nullable
as String?,url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,isPrimary: null == isPrimary ? _self.isPrimary : isPrimary // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
