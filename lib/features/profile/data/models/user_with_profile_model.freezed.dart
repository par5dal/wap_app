// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_with_profile_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$UserWithProfileModel {

 String get id; String get email; String? get role; bool? get isActive; DateTime get createdAt; DateTime get updatedAt; ProfileModel? get profile;
/// Create a copy of UserWithProfileModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UserWithProfileModelCopyWith<UserWithProfileModel> get copyWith => _$UserWithProfileModelCopyWithImpl<UserWithProfileModel>(this as UserWithProfileModel, _$identity);

  /// Serializes this UserWithProfileModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UserWithProfileModel&&(identical(other.id, id) || other.id == id)&&(identical(other.email, email) || other.email == email)&&(identical(other.role, role) || other.role == role)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.profile, profile) || other.profile == profile));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,email,role,isActive,createdAt,updatedAt,profile);

@override
String toString() {
  return 'UserWithProfileModel(id: $id, email: $email, role: $role, isActive: $isActive, createdAt: $createdAt, updatedAt: $updatedAt, profile: $profile)';
}


}

/// @nodoc
abstract mixin class $UserWithProfileModelCopyWith<$Res>  {
  factory $UserWithProfileModelCopyWith(UserWithProfileModel value, $Res Function(UserWithProfileModel) _then) = _$UserWithProfileModelCopyWithImpl;
@useResult
$Res call({
 String id, String email, String? role, bool? isActive, DateTime createdAt, DateTime updatedAt, ProfileModel? profile
});


$ProfileModelCopyWith<$Res>? get profile;

}
/// @nodoc
class _$UserWithProfileModelCopyWithImpl<$Res>
    implements $UserWithProfileModelCopyWith<$Res> {
  _$UserWithProfileModelCopyWithImpl(this._self, this._then);

  final UserWithProfileModel _self;
  final $Res Function(UserWithProfileModel) _then;

/// Create a copy of UserWithProfileModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? email = null,Object? role = freezed,Object? isActive = freezed,Object? createdAt = null,Object? updatedAt = null,Object? profile = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,role: freezed == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as String?,isActive: freezed == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,profile: freezed == profile ? _self.profile : profile // ignore: cast_nullable_to_non_nullable
as ProfileModel?,
  ));
}
/// Create a copy of UserWithProfileModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ProfileModelCopyWith<$Res>? get profile {
    if (_self.profile == null) {
    return null;
  }

  return $ProfileModelCopyWith<$Res>(_self.profile!, (value) {
    return _then(_self.copyWith(profile: value));
  });
}
}


/// Adds pattern-matching-related methods to [UserWithProfileModel].
extension UserWithProfileModelPatterns on UserWithProfileModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UserWithProfileModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UserWithProfileModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UserWithProfileModel value)  $default,){
final _that = this;
switch (_that) {
case _UserWithProfileModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UserWithProfileModel value)?  $default,){
final _that = this;
switch (_that) {
case _UserWithProfileModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String email,  String? role,  bool? isActive,  DateTime createdAt,  DateTime updatedAt,  ProfileModel? profile)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UserWithProfileModel() when $default != null:
return $default(_that.id,_that.email,_that.role,_that.isActive,_that.createdAt,_that.updatedAt,_that.profile);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String email,  String? role,  bool? isActive,  DateTime createdAt,  DateTime updatedAt,  ProfileModel? profile)  $default,) {final _that = this;
switch (_that) {
case _UserWithProfileModel():
return $default(_that.id,_that.email,_that.role,_that.isActive,_that.createdAt,_that.updatedAt,_that.profile);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String email,  String? role,  bool? isActive,  DateTime createdAt,  DateTime updatedAt,  ProfileModel? profile)?  $default,) {final _that = this;
switch (_that) {
case _UserWithProfileModel() when $default != null:
return $default(_that.id,_that.email,_that.role,_that.isActive,_that.createdAt,_that.updatedAt,_that.profile);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UserWithProfileModel implements UserWithProfileModel {
  const _UserWithProfileModel({required this.id, required this.email, this.role, this.isActive, required this.createdAt, required this.updatedAt, this.profile});
  factory _UserWithProfileModel.fromJson(Map<String, dynamic> json) => _$UserWithProfileModelFromJson(json);

@override final  String id;
@override final  String email;
@override final  String? role;
@override final  bool? isActive;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;
@override final  ProfileModel? profile;

/// Create a copy of UserWithProfileModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UserWithProfileModelCopyWith<_UserWithProfileModel> get copyWith => __$UserWithProfileModelCopyWithImpl<_UserWithProfileModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UserWithProfileModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UserWithProfileModel&&(identical(other.id, id) || other.id == id)&&(identical(other.email, email) || other.email == email)&&(identical(other.role, role) || other.role == role)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.profile, profile) || other.profile == profile));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,email,role,isActive,createdAt,updatedAt,profile);

@override
String toString() {
  return 'UserWithProfileModel(id: $id, email: $email, role: $role, isActive: $isActive, createdAt: $createdAt, updatedAt: $updatedAt, profile: $profile)';
}


}

/// @nodoc
abstract mixin class _$UserWithProfileModelCopyWith<$Res> implements $UserWithProfileModelCopyWith<$Res> {
  factory _$UserWithProfileModelCopyWith(_UserWithProfileModel value, $Res Function(_UserWithProfileModel) _then) = __$UserWithProfileModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String email, String? role, bool? isActive, DateTime createdAt, DateTime updatedAt, ProfileModel? profile
});


@override $ProfileModelCopyWith<$Res>? get profile;

}
/// @nodoc
class __$UserWithProfileModelCopyWithImpl<$Res>
    implements _$UserWithProfileModelCopyWith<$Res> {
  __$UserWithProfileModelCopyWithImpl(this._self, this._then);

  final _UserWithProfileModel _self;
  final $Res Function(_UserWithProfileModel) _then;

/// Create a copy of UserWithProfileModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? email = null,Object? role = freezed,Object? isActive = freezed,Object? createdAt = null,Object? updatedAt = null,Object? profile = freezed,}) {
  return _then(_UserWithProfileModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,role: freezed == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as String?,isActive: freezed == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,profile: freezed == profile ? _self.profile : profile // ignore: cast_nullable_to_non_nullable
as ProfileModel?,
  ));
}

/// Create a copy of UserWithProfileModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ProfileModelCopyWith<$Res>? get profile {
    if (_self.profile == null) {
    return null;
  }

  return $ProfileModelCopyWith<$Res>(_self.profile!, (value) {
    return _then(_self.copyWith(profile: value));
  });
}
}

// dart format on
