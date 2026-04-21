// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'event_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$EventModel {

 String get id; String get title; String? get description; String? get slug; DateTime get startDatetime; DateTime? get endDatetime; String? get price; String? get currency; String? get status; String? get moderationStatus; String? get moderationComment; DateTime? get moderatedAt; VenueModel get venue; CategoryModel? get category; List<CategoryModel>? get categories;// Lista completa de categorías
 List<EventImageModel>? get images; UserWithProfileModel? get promoter; String? get promoterDirectId;// promoter_id del tile (cuando no viene objeto promoter completo)
 bool get isFavorite;// Si está en favoritos del usuario
 String? get sourceUrl;// URL del origen del evento
 DateTime? get createdAt; DateTime? get updatedAt; DateTime? get deletedAt;
/// Create a copy of EventModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EventModelCopyWith<EventModel> get copyWith => _$EventModelCopyWithImpl<EventModel>(this as EventModel, _$identity);

  /// Serializes this EventModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EventModel&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.slug, slug) || other.slug == slug)&&(identical(other.startDatetime, startDatetime) || other.startDatetime == startDatetime)&&(identical(other.endDatetime, endDatetime) || other.endDatetime == endDatetime)&&(identical(other.price, price) || other.price == price)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.status, status) || other.status == status)&&(identical(other.moderationStatus, moderationStatus) || other.moderationStatus == moderationStatus)&&(identical(other.moderationComment, moderationComment) || other.moderationComment == moderationComment)&&(identical(other.moderatedAt, moderatedAt) || other.moderatedAt == moderatedAt)&&(identical(other.venue, venue) || other.venue == venue)&&(identical(other.category, category) || other.category == category)&&const DeepCollectionEquality().equals(other.categories, categories)&&const DeepCollectionEquality().equals(other.images, images)&&(identical(other.promoter, promoter) || other.promoter == promoter)&&(identical(other.promoterDirectId, promoterDirectId) || other.promoterDirectId == promoterDirectId)&&(identical(other.isFavorite, isFavorite) || other.isFavorite == isFavorite)&&(identical(other.sourceUrl, sourceUrl) || other.sourceUrl == sourceUrl)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,title,description,slug,startDatetime,endDatetime,price,currency,status,moderationStatus,moderationComment,moderatedAt,venue,category,const DeepCollectionEquality().hash(categories),const DeepCollectionEquality().hash(images),promoter,promoterDirectId,isFavorite,sourceUrl,createdAt,updatedAt,deletedAt]);

@override
String toString() {
  return 'EventModel(id: $id, title: $title, description: $description, slug: $slug, startDatetime: $startDatetime, endDatetime: $endDatetime, price: $price, currency: $currency, status: $status, moderationStatus: $moderationStatus, moderationComment: $moderationComment, moderatedAt: $moderatedAt, venue: $venue, category: $category, categories: $categories, images: $images, promoter: $promoter, promoterDirectId: $promoterDirectId, isFavorite: $isFavorite, sourceUrl: $sourceUrl, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt)';
}


}

/// @nodoc
abstract mixin class $EventModelCopyWith<$Res>  {
  factory $EventModelCopyWith(EventModel value, $Res Function(EventModel) _then) = _$EventModelCopyWithImpl;
@useResult
$Res call({
 String id, String title, String? description, String? slug, DateTime startDatetime, DateTime? endDatetime, String? price, String? currency, String? status, String? moderationStatus, String? moderationComment, DateTime? moderatedAt, VenueModel venue, CategoryModel? category, List<CategoryModel>? categories, List<EventImageModel>? images, UserWithProfileModel? promoter, String? promoterDirectId, bool isFavorite, String? sourceUrl, DateTime? createdAt, DateTime? updatedAt, DateTime? deletedAt
});


$VenueModelCopyWith<$Res> get venue;$CategoryModelCopyWith<$Res>? get category;$UserWithProfileModelCopyWith<$Res>? get promoter;

}
/// @nodoc
class _$EventModelCopyWithImpl<$Res>
    implements $EventModelCopyWith<$Res> {
  _$EventModelCopyWithImpl(this._self, this._then);

  final EventModel _self;
  final $Res Function(EventModel) _then;

/// Create a copy of EventModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? description = freezed,Object? slug = freezed,Object? startDatetime = null,Object? endDatetime = freezed,Object? price = freezed,Object? currency = freezed,Object? status = freezed,Object? moderationStatus = freezed,Object? moderationComment = freezed,Object? moderatedAt = freezed,Object? venue = null,Object? category = freezed,Object? categories = freezed,Object? images = freezed,Object? promoter = freezed,Object? promoterDirectId = freezed,Object? isFavorite = null,Object? sourceUrl = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,Object? deletedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,slug: freezed == slug ? _self.slug : slug // ignore: cast_nullable_to_non_nullable
as String?,startDatetime: null == startDatetime ? _self.startDatetime : startDatetime // ignore: cast_nullable_to_non_nullable
as DateTime,endDatetime: freezed == endDatetime ? _self.endDatetime : endDatetime // ignore: cast_nullable_to_non_nullable
as DateTime?,price: freezed == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as String?,currency: freezed == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String?,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String?,moderationStatus: freezed == moderationStatus ? _self.moderationStatus : moderationStatus // ignore: cast_nullable_to_non_nullable
as String?,moderationComment: freezed == moderationComment ? _self.moderationComment : moderationComment // ignore: cast_nullable_to_non_nullable
as String?,moderatedAt: freezed == moderatedAt ? _self.moderatedAt : moderatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,venue: null == venue ? _self.venue : venue // ignore: cast_nullable_to_non_nullable
as VenueModel,category: freezed == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as CategoryModel?,categories: freezed == categories ? _self.categories : categories // ignore: cast_nullable_to_non_nullable
as List<CategoryModel>?,images: freezed == images ? _self.images : images // ignore: cast_nullable_to_non_nullable
as List<EventImageModel>?,promoter: freezed == promoter ? _self.promoter : promoter // ignore: cast_nullable_to_non_nullable
as UserWithProfileModel?,promoterDirectId: freezed == promoterDirectId ? _self.promoterDirectId : promoterDirectId // ignore: cast_nullable_to_non_nullable
as String?,isFavorite: null == isFavorite ? _self.isFavorite : isFavorite // ignore: cast_nullable_to_non_nullable
as bool,sourceUrl: freezed == sourceUrl ? _self.sourceUrl : sourceUrl // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}
/// Create a copy of EventModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$VenueModelCopyWith<$Res> get venue {
  
  return $VenueModelCopyWith<$Res>(_self.venue, (value) {
    return _then(_self.copyWith(venue: value));
  });
}/// Create a copy of EventModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CategoryModelCopyWith<$Res>? get category {
    if (_self.category == null) {
    return null;
  }

  return $CategoryModelCopyWith<$Res>(_self.category!, (value) {
    return _then(_self.copyWith(category: value));
  });
}/// Create a copy of EventModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserWithProfileModelCopyWith<$Res>? get promoter {
    if (_self.promoter == null) {
    return null;
  }

  return $UserWithProfileModelCopyWith<$Res>(_self.promoter!, (value) {
    return _then(_self.copyWith(promoter: value));
  });
}
}


/// Adds pattern-matching-related methods to [EventModel].
extension EventModelPatterns on EventModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _EventModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _EventModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _EventModel value)  $default,){
final _that = this;
switch (_that) {
case _EventModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _EventModel value)?  $default,){
final _that = this;
switch (_that) {
case _EventModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String title,  String? description,  String? slug,  DateTime startDatetime,  DateTime? endDatetime,  String? price,  String? currency,  String? status,  String? moderationStatus,  String? moderationComment,  DateTime? moderatedAt,  VenueModel venue,  CategoryModel? category,  List<CategoryModel>? categories,  List<EventImageModel>? images,  UserWithProfileModel? promoter,  String? promoterDirectId,  bool isFavorite,  String? sourceUrl,  DateTime? createdAt,  DateTime? updatedAt,  DateTime? deletedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _EventModel() when $default != null:
return $default(_that.id,_that.title,_that.description,_that.slug,_that.startDatetime,_that.endDatetime,_that.price,_that.currency,_that.status,_that.moderationStatus,_that.moderationComment,_that.moderatedAt,_that.venue,_that.category,_that.categories,_that.images,_that.promoter,_that.promoterDirectId,_that.isFavorite,_that.sourceUrl,_that.createdAt,_that.updatedAt,_that.deletedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String title,  String? description,  String? slug,  DateTime startDatetime,  DateTime? endDatetime,  String? price,  String? currency,  String? status,  String? moderationStatus,  String? moderationComment,  DateTime? moderatedAt,  VenueModel venue,  CategoryModel? category,  List<CategoryModel>? categories,  List<EventImageModel>? images,  UserWithProfileModel? promoter,  String? promoterDirectId,  bool isFavorite,  String? sourceUrl,  DateTime? createdAt,  DateTime? updatedAt,  DateTime? deletedAt)  $default,) {final _that = this;
switch (_that) {
case _EventModel():
return $default(_that.id,_that.title,_that.description,_that.slug,_that.startDatetime,_that.endDatetime,_that.price,_that.currency,_that.status,_that.moderationStatus,_that.moderationComment,_that.moderatedAt,_that.venue,_that.category,_that.categories,_that.images,_that.promoter,_that.promoterDirectId,_that.isFavorite,_that.sourceUrl,_that.createdAt,_that.updatedAt,_that.deletedAt);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String title,  String? description,  String? slug,  DateTime startDatetime,  DateTime? endDatetime,  String? price,  String? currency,  String? status,  String? moderationStatus,  String? moderationComment,  DateTime? moderatedAt,  VenueModel venue,  CategoryModel? category,  List<CategoryModel>? categories,  List<EventImageModel>? images,  UserWithProfileModel? promoter,  String? promoterDirectId,  bool isFavorite,  String? sourceUrl,  DateTime? createdAt,  DateTime? updatedAt,  DateTime? deletedAt)?  $default,) {final _that = this;
switch (_that) {
case _EventModel() when $default != null:
return $default(_that.id,_that.title,_that.description,_that.slug,_that.startDatetime,_that.endDatetime,_that.price,_that.currency,_that.status,_that.moderationStatus,_that.moderationComment,_that.moderatedAt,_that.venue,_that.category,_that.categories,_that.images,_that.promoter,_that.promoterDirectId,_that.isFavorite,_that.sourceUrl,_that.createdAt,_that.updatedAt,_that.deletedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _EventModel implements EventModel {
  const _EventModel({required this.id, required this.title, this.description, this.slug, required this.startDatetime, this.endDatetime, this.price, this.currency, this.status, this.moderationStatus, this.moderationComment, this.moderatedAt, required this.venue, this.category, final  List<CategoryModel>? categories, final  List<EventImageModel>? images, this.promoter, this.promoterDirectId, this.isFavorite = false, this.sourceUrl, this.createdAt, this.updatedAt, this.deletedAt}): _categories = categories,_images = images;
  factory _EventModel.fromJson(Map<String, dynamic> json) => _$EventModelFromJson(json);

@override final  String id;
@override final  String title;
@override final  String? description;
@override final  String? slug;
@override final  DateTime startDatetime;
@override final  DateTime? endDatetime;
@override final  String? price;
@override final  String? currency;
@override final  String? status;
@override final  String? moderationStatus;
@override final  String? moderationComment;
@override final  DateTime? moderatedAt;
@override final  VenueModel venue;
@override final  CategoryModel? category;
 final  List<CategoryModel>? _categories;
@override List<CategoryModel>? get categories {
  final value = _categories;
  if (value == null) return null;
  if (_categories is EqualUnmodifiableListView) return _categories;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

// Lista completa de categorías
 final  List<EventImageModel>? _images;
// Lista completa de categorías
@override List<EventImageModel>? get images {
  final value = _images;
  if (value == null) return null;
  if (_images is EqualUnmodifiableListView) return _images;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

@override final  UserWithProfileModel? promoter;
@override final  String? promoterDirectId;
// promoter_id del tile (cuando no viene objeto promoter completo)
@override@JsonKey() final  bool isFavorite;
// Si está en favoritos del usuario
@override final  String? sourceUrl;
// URL del origen del evento
@override final  DateTime? createdAt;
@override final  DateTime? updatedAt;
@override final  DateTime? deletedAt;

/// Create a copy of EventModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EventModelCopyWith<_EventModel> get copyWith => __$EventModelCopyWithImpl<_EventModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$EventModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _EventModel&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.slug, slug) || other.slug == slug)&&(identical(other.startDatetime, startDatetime) || other.startDatetime == startDatetime)&&(identical(other.endDatetime, endDatetime) || other.endDatetime == endDatetime)&&(identical(other.price, price) || other.price == price)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.status, status) || other.status == status)&&(identical(other.moderationStatus, moderationStatus) || other.moderationStatus == moderationStatus)&&(identical(other.moderationComment, moderationComment) || other.moderationComment == moderationComment)&&(identical(other.moderatedAt, moderatedAt) || other.moderatedAt == moderatedAt)&&(identical(other.venue, venue) || other.venue == venue)&&(identical(other.category, category) || other.category == category)&&const DeepCollectionEquality().equals(other._categories, _categories)&&const DeepCollectionEquality().equals(other._images, _images)&&(identical(other.promoter, promoter) || other.promoter == promoter)&&(identical(other.promoterDirectId, promoterDirectId) || other.promoterDirectId == promoterDirectId)&&(identical(other.isFavorite, isFavorite) || other.isFavorite == isFavorite)&&(identical(other.sourceUrl, sourceUrl) || other.sourceUrl == sourceUrl)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,title,description,slug,startDatetime,endDatetime,price,currency,status,moderationStatus,moderationComment,moderatedAt,venue,category,const DeepCollectionEquality().hash(_categories),const DeepCollectionEquality().hash(_images),promoter,promoterDirectId,isFavorite,sourceUrl,createdAt,updatedAt,deletedAt]);

@override
String toString() {
  return 'EventModel(id: $id, title: $title, description: $description, slug: $slug, startDatetime: $startDatetime, endDatetime: $endDatetime, price: $price, currency: $currency, status: $status, moderationStatus: $moderationStatus, moderationComment: $moderationComment, moderatedAt: $moderatedAt, venue: $venue, category: $category, categories: $categories, images: $images, promoter: $promoter, promoterDirectId: $promoterDirectId, isFavorite: $isFavorite, sourceUrl: $sourceUrl, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt)';
}


}

/// @nodoc
abstract mixin class _$EventModelCopyWith<$Res> implements $EventModelCopyWith<$Res> {
  factory _$EventModelCopyWith(_EventModel value, $Res Function(_EventModel) _then) = __$EventModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String title, String? description, String? slug, DateTime startDatetime, DateTime? endDatetime, String? price, String? currency, String? status, String? moderationStatus, String? moderationComment, DateTime? moderatedAt, VenueModel venue, CategoryModel? category, List<CategoryModel>? categories, List<EventImageModel>? images, UserWithProfileModel? promoter, String? promoterDirectId, bool isFavorite, String? sourceUrl, DateTime? createdAt, DateTime? updatedAt, DateTime? deletedAt
});


@override $VenueModelCopyWith<$Res> get venue;@override $CategoryModelCopyWith<$Res>? get category;@override $UserWithProfileModelCopyWith<$Res>? get promoter;

}
/// @nodoc
class __$EventModelCopyWithImpl<$Res>
    implements _$EventModelCopyWith<$Res> {
  __$EventModelCopyWithImpl(this._self, this._then);

  final _EventModel _self;
  final $Res Function(_EventModel) _then;

/// Create a copy of EventModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? description = freezed,Object? slug = freezed,Object? startDatetime = null,Object? endDatetime = freezed,Object? price = freezed,Object? currency = freezed,Object? status = freezed,Object? moderationStatus = freezed,Object? moderationComment = freezed,Object? moderatedAt = freezed,Object? venue = null,Object? category = freezed,Object? categories = freezed,Object? images = freezed,Object? promoter = freezed,Object? promoterDirectId = freezed,Object? isFavorite = null,Object? sourceUrl = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,Object? deletedAt = freezed,}) {
  return _then(_EventModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,slug: freezed == slug ? _self.slug : slug // ignore: cast_nullable_to_non_nullable
as String?,startDatetime: null == startDatetime ? _self.startDatetime : startDatetime // ignore: cast_nullable_to_non_nullable
as DateTime,endDatetime: freezed == endDatetime ? _self.endDatetime : endDatetime // ignore: cast_nullable_to_non_nullable
as DateTime?,price: freezed == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as String?,currency: freezed == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String?,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String?,moderationStatus: freezed == moderationStatus ? _self.moderationStatus : moderationStatus // ignore: cast_nullable_to_non_nullable
as String?,moderationComment: freezed == moderationComment ? _self.moderationComment : moderationComment // ignore: cast_nullable_to_non_nullable
as String?,moderatedAt: freezed == moderatedAt ? _self.moderatedAt : moderatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,venue: null == venue ? _self.venue : venue // ignore: cast_nullable_to_non_nullable
as VenueModel,category: freezed == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as CategoryModel?,categories: freezed == categories ? _self._categories : categories // ignore: cast_nullable_to_non_nullable
as List<CategoryModel>?,images: freezed == images ? _self._images : images // ignore: cast_nullable_to_non_nullable
as List<EventImageModel>?,promoter: freezed == promoter ? _self.promoter : promoter // ignore: cast_nullable_to_non_nullable
as UserWithProfileModel?,promoterDirectId: freezed == promoterDirectId ? _self.promoterDirectId : promoterDirectId // ignore: cast_nullable_to_non_nullable
as String?,isFavorite: null == isFavorite ? _self.isFavorite : isFavorite // ignore: cast_nullable_to_non_nullable
as bool,sourceUrl: freezed == sourceUrl ? _self.sourceUrl : sourceUrl // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

/// Create a copy of EventModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$VenueModelCopyWith<$Res> get venue {
  
  return $VenueModelCopyWith<$Res>(_self.venue, (value) {
    return _then(_self.copyWith(venue: value));
  });
}/// Create a copy of EventModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CategoryModelCopyWith<$Res>? get category {
    if (_self.category == null) {
    return null;
  }

  return $CategoryModelCopyWith<$Res>(_self.category!, (value) {
    return _then(_self.copyWith(category: value));
  });
}/// Create a copy of EventModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserWithProfileModelCopyWith<$Res>? get promoter {
    if (_self.promoter == null) {
    return null;
  }

  return $UserWithProfileModelCopyWith<$Res>(_self.promoter!, (value) {
    return _then(_self.copyWith(promoter: value));
  });
}
}

// dart format on
