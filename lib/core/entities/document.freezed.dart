// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'document.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Document {

 String get id; String get userId; String? get title; String? get storageKey; DocumentStatus get status; String? get extractedText; String? get shortSummary; String? get detailedSummary; SummaryStatus get summaryStatus; DateTime? get createdAt; DateTime? get updatedAt;
/// Create a copy of Document
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DocumentCopyWith<Document> get copyWith => _$DocumentCopyWithImpl<Document>(this as Document, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Document&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.title, title) || other.title == title)&&(identical(other.storageKey, storageKey) || other.storageKey == storageKey)&&(identical(other.status, status) || other.status == status)&&(identical(other.extractedText, extractedText) || other.extractedText == extractedText)&&(identical(other.shortSummary, shortSummary) || other.shortSummary == shortSummary)&&(identical(other.detailedSummary, detailedSummary) || other.detailedSummary == detailedSummary)&&(identical(other.summaryStatus, summaryStatus) || other.summaryStatus == summaryStatus)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,userId,title,storageKey,status,extractedText,shortSummary,detailedSummary,summaryStatus,createdAt,updatedAt);

@override
String toString() {
  return 'Document(id: $id, userId: $userId, title: $title, storageKey: $storageKey, status: $status, extractedText: $extractedText, shortSummary: $shortSummary, detailedSummary: $detailedSummary, summaryStatus: $summaryStatus, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $DocumentCopyWith<$Res>  {
  factory $DocumentCopyWith(Document value, $Res Function(Document) _then) = _$DocumentCopyWithImpl;
@useResult
$Res call({
 String id, String userId, String? title, String? storageKey, DocumentStatus status, String? extractedText, String? shortSummary, String? detailedSummary, SummaryStatus summaryStatus, DateTime? createdAt, DateTime? updatedAt
});




}
/// @nodoc
class _$DocumentCopyWithImpl<$Res>
    implements $DocumentCopyWith<$Res> {
  _$DocumentCopyWithImpl(this._self, this._then);

  final Document _self;
  final $Res Function(Document) _then;

/// Create a copy of Document
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? userId = null,Object? title = freezed,Object? storageKey = freezed,Object? status = null,Object? extractedText = freezed,Object? shortSummary = freezed,Object? detailedSummary = freezed,Object? summaryStatus = null,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(Document(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,storageKey: freezed == storageKey ? _self.storageKey : storageKey // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as DocumentStatus,extractedText: freezed == extractedText ? _self.extractedText : extractedText // ignore: cast_nullable_to_non_nullable
as String?,shortSummary: freezed == shortSummary ? _self.shortSummary : shortSummary // ignore: cast_nullable_to_non_nullable
as String?,detailedSummary: freezed == detailedSummary ? _self.detailedSummary : detailedSummary // ignore: cast_nullable_to_non_nullable
as String?,summaryStatus: null == summaryStatus ? _self.summaryStatus : summaryStatus // ignore: cast_nullable_to_non_nullable
as SummaryStatus,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [Document].
extension DocumentPatterns on Document {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Document value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Document() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Document value)  $default,){
final _that = this;
switch (_that) {
case _Document():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Document value)?  $default,){
final _that = this;
switch (_that) {
case _Document() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String userId,  String? title,  String? storageKey,  DocumentStatus status,  String? extractedText,  String? shortSummary,  String? detailedSummary,  SummaryStatus summaryStatus,  DateTime? createdAt,  DateTime? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Document() when $default != null:
return $default(_that.id,_that.userId,_that.title,_that.storageKey,_that.status,_that.extractedText,_that.shortSummary,_that.detailedSummary,_that.summaryStatus,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String userId,  String? title,  String? storageKey,  DocumentStatus status,  String? extractedText,  String? shortSummary,  String? detailedSummary,  SummaryStatus summaryStatus,  DateTime? createdAt,  DateTime? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _Document():
return $default(_that.id,_that.userId,_that.title,_that.storageKey,_that.status,_that.extractedText,_that.shortSummary,_that.detailedSummary,_that.summaryStatus,_that.createdAt,_that.updatedAt);case _:
  throw StateError('Unexpected subclass');

}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String userId,  String? title,  String? storageKey,  DocumentStatus status,  String? extractedText,  String? shortSummary,  String? detailedSummary,  SummaryStatus summaryStatus,  DateTime? createdAt,  DateTime? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _Document() when $default != null:
return $default(_that.id,_that.userId,_that.title,_that.storageKey,_that.status,_that.extractedText,_that.shortSummary,_that.detailedSummary,_that.summaryStatus,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc


class _Document implements Document {
  const _Document({required this.id, required this.userId, this.title, this.storageKey, required this.status, this.extractedText, this.shortSummary, this.detailedSummary, this.summaryStatus = SummaryStatus.idle, this.createdAt, this.updatedAt});
  

@override final  String id;
@override final  String userId;
@override final  String? title;
@override final  String? storageKey;
@override final  DocumentStatus status;
@override final  String? extractedText;
@override final  String? shortSummary;
@override final  String? detailedSummary;
@override@JsonKey() final  SummaryStatus summaryStatus;
@override final  DateTime? createdAt;
@override final  DateTime? updatedAt;

/// Create a copy of Document
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DocumentCopyWith<_Document> get copyWith => __$DocumentCopyWithImpl<_Document>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Document&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.title, title) || other.title == title)&&(identical(other.storageKey, storageKey) || other.storageKey == storageKey)&&(identical(other.status, status) || other.status == status)&&(identical(other.extractedText, extractedText) || other.extractedText == extractedText)&&(identical(other.shortSummary, shortSummary) || other.shortSummary == shortSummary)&&(identical(other.detailedSummary, detailedSummary) || other.detailedSummary == detailedSummary)&&(identical(other.summaryStatus, summaryStatus) || other.summaryStatus == summaryStatus)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,userId,title,storageKey,status,extractedText,shortSummary,detailedSummary,summaryStatus,createdAt,updatedAt);

@override
String toString() {
  return 'Document(id: $id, userId: $userId, title: $title, storageKey: $storageKey, status: $status, extractedText: $extractedText, shortSummary: $shortSummary, detailedSummary: $detailedSummary, summaryStatus: $summaryStatus, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$DocumentCopyWith<$Res> implements $DocumentCopyWith<$Res> {
  factory _$DocumentCopyWith(_Document value, $Res Function(_Document) _then) = __$DocumentCopyWithImpl;
@override @useResult
$Res call({
 String id, String userId, String? title, String? storageKey, DocumentStatus status, String? extractedText, String? shortSummary, String? detailedSummary, SummaryStatus summaryStatus, DateTime? createdAt, DateTime? updatedAt
});




}
/// @nodoc
class __$DocumentCopyWithImpl<$Res>
    implements _$DocumentCopyWith<$Res> {
  __$DocumentCopyWithImpl(this._self, this._then);

  final _Document _self;
  final $Res Function(_Document) _then;

/// Create a copy of Document
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? userId = null,Object? title = freezed,Object? storageKey = freezed,Object? status = null,Object? extractedText = freezed,Object? shortSummary = freezed,Object? detailedSummary = freezed,Object? summaryStatus = null,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_Document(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,storageKey: freezed == storageKey ? _self.storageKey : storageKey // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as DocumentStatus,extractedText: freezed == extractedText ? _self.extractedText : extractedText // ignore: cast_nullable_to_non_nullable
as String?,shortSummary: freezed == shortSummary ? _self.shortSummary : shortSummary // ignore: cast_nullable_to_non_nullable
as String?,detailedSummary: freezed == detailedSummary ? _self.detailedSummary : detailedSummary // ignore: cast_nullable_to_non_nullable
as String?,summaryStatus: null == summaryStatus ? _self.summaryStatus : summaryStatus // ignore: cast_nullable_to_non_nullable
as SummaryStatus,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
