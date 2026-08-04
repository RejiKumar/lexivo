// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'export_job.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ExportSectionToggles {

 bool get includeSummary; bool get includeTranslation; bool get includeChat;
/// Create a copy of ExportSectionToggles
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ExportSectionTogglesCopyWith<ExportSectionToggles> get copyWith => _$ExportSectionTogglesCopyWithImpl<ExportSectionToggles>(this as ExportSectionToggles, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ExportSectionToggles&&(identical(other.includeSummary, includeSummary) || other.includeSummary == includeSummary)&&(identical(other.includeTranslation, includeTranslation) || other.includeTranslation == includeTranslation)&&(identical(other.includeChat, includeChat) || other.includeChat == includeChat));
}


@override
int get hashCode => Object.hash(runtimeType,includeSummary,includeTranslation,includeChat);

@override
String toString() {
  return 'ExportSectionToggles(includeSummary: $includeSummary, includeTranslation: $includeTranslation, includeChat: $includeChat)';
}


}

/// @nodoc
abstract mixin class $ExportSectionTogglesCopyWith<$Res>  {
  factory $ExportSectionTogglesCopyWith(ExportSectionToggles value, $Res Function(ExportSectionToggles) _then) = _$ExportSectionTogglesCopyWithImpl;
@useResult
$Res call({
 bool includeSummary, bool includeTranslation, bool includeChat
});




}
/// @nodoc
class _$ExportSectionTogglesCopyWithImpl<$Res>
    implements $ExportSectionTogglesCopyWith<$Res> {
  _$ExportSectionTogglesCopyWithImpl(this._self, this._then);

  final ExportSectionToggles _self;
  final $Res Function(ExportSectionToggles) _then;

/// Create a copy of ExportSectionToggles
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? includeSummary = null,Object? includeTranslation = null,Object? includeChat = null,}) {
  return _then(ExportSectionToggles(
includeSummary: null == includeSummary ? _self.includeSummary : includeSummary // ignore: cast_nullable_to_non_nullable
as bool,includeTranslation: null == includeTranslation ? _self.includeTranslation : includeTranslation // ignore: cast_nullable_to_non_nullable
as bool,includeChat: null == includeChat ? _self.includeChat : includeChat // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [ExportSectionToggles].
extension ExportSectionTogglesPatterns on ExportSectionToggles {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ExportSectionToggles value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ExportSectionToggles() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ExportSectionToggles value)  $default,){
final _that = this;
switch (_that) {
case _ExportSectionToggles():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ExportSectionToggles value)?  $default,){
final _that = this;
switch (_that) {
case _ExportSectionToggles() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool includeSummary,  bool includeTranslation,  bool includeChat)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ExportSectionToggles() when $default != null:
return $default(_that.includeSummary,_that.includeTranslation,_that.includeChat);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool includeSummary,  bool includeTranslation,  bool includeChat)  $default,) {final _that = this;
switch (_that) {
case _ExportSectionToggles():
return $default(_that.includeSummary,_that.includeTranslation,_that.includeChat);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool includeSummary,  bool includeTranslation,  bool includeChat)?  $default,) {final _that = this;
switch (_that) {
case _ExportSectionToggles() when $default != null:
return $default(_that.includeSummary,_that.includeTranslation,_that.includeChat);case _:
  return null;

}
}

}

/// @nodoc


class _ExportSectionToggles extends ExportSectionToggles {
  const _ExportSectionToggles({this.includeSummary = false, this.includeTranslation = false, this.includeChat = false}): super._();
  

@override@JsonKey() final  bool includeSummary;
@override@JsonKey() final  bool includeTranslation;
@override@JsonKey() final  bool includeChat;

/// Create a copy of ExportSectionToggles
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ExportSectionTogglesCopyWith<_ExportSectionToggles> get copyWith => __$ExportSectionTogglesCopyWithImpl<_ExportSectionToggles>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ExportSectionToggles&&(identical(other.includeSummary, includeSummary) || other.includeSummary == includeSummary)&&(identical(other.includeTranslation, includeTranslation) || other.includeTranslation == includeTranslation)&&(identical(other.includeChat, includeChat) || other.includeChat == includeChat));
}


@override
int get hashCode => Object.hash(runtimeType,includeSummary,includeTranslation,includeChat);

@override
String toString() {
  return 'ExportSectionToggles(includeSummary: $includeSummary, includeTranslation: $includeTranslation, includeChat: $includeChat)';
}


}

/// @nodoc
abstract mixin class _$ExportSectionTogglesCopyWith<$Res> implements $ExportSectionTogglesCopyWith<$Res> {
  factory _$ExportSectionTogglesCopyWith(_ExportSectionToggles value, $Res Function(_ExportSectionToggles) _then) = __$ExportSectionTogglesCopyWithImpl;
@override @useResult
$Res call({
 bool includeSummary, bool includeTranslation, bool includeChat
});




}
/// @nodoc
class __$ExportSectionTogglesCopyWithImpl<$Res>
    implements _$ExportSectionTogglesCopyWith<$Res> {
  __$ExportSectionTogglesCopyWithImpl(this._self, this._then);

  final _ExportSectionToggles _self;
  final $Res Function(_ExportSectionToggles) _then;

/// Create a copy of ExportSectionToggles
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? includeSummary = null,Object? includeTranslation = null,Object? includeChat = null,}) {
  return _then(_ExportSectionToggles(
includeSummary: null == includeSummary ? _self.includeSummary : includeSummary // ignore: cast_nullable_to_non_nullable
as bool,includeTranslation: null == includeTranslation ? _self.includeTranslation : includeTranslation // ignore: cast_nullable_to_non_nullable
as bool,includeChat: null == includeChat ? _self.includeChat : includeChat // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

/// @nodoc
mixin _$ExportJob {

 String get id; String get documentId; ExportSectionToggles get toggles; ExportJobStatus get status; String? get storageKey; String? get signedUrl; String? get errorMessage;
/// Create a copy of ExportJob
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ExportJobCopyWith<ExportJob> get copyWith => _$ExportJobCopyWithImpl<ExportJob>(this as ExportJob, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ExportJob&&(identical(other.id, id) || other.id == id)&&(identical(other.documentId, documentId) || other.documentId == documentId)&&(identical(other.toggles, toggles) || other.toggles == toggles)&&(identical(other.status, status) || other.status == status)&&(identical(other.storageKey, storageKey) || other.storageKey == storageKey)&&(identical(other.signedUrl, signedUrl) || other.signedUrl == signedUrl)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage));
}


@override
int get hashCode => Object.hash(runtimeType,id,documentId,toggles,status,storageKey,signedUrl,errorMessage);

@override
String toString() {
  return 'ExportJob(id: $id, documentId: $documentId, toggles: $toggles, status: $status, storageKey: $storageKey, signedUrl: $signedUrl, errorMessage: $errorMessage)';
}


}

/// @nodoc
abstract mixin class $ExportJobCopyWith<$Res>  {
  factory $ExportJobCopyWith(ExportJob value, $Res Function(ExportJob) _then) = _$ExportJobCopyWithImpl;
@useResult
$Res call({
 String id, String documentId, ExportSectionToggles toggles, ExportJobStatus status, String? storageKey, String? signedUrl, String? errorMessage
});


$ExportSectionTogglesCopyWith<$Res> get toggles;

}
/// @nodoc
class _$ExportJobCopyWithImpl<$Res>
    implements $ExportJobCopyWith<$Res> {
  _$ExportJobCopyWithImpl(this._self, this._then);

  final ExportJob _self;
  final $Res Function(ExportJob) _then;

/// Create a copy of ExportJob
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? documentId = null,Object? toggles = null,Object? status = null,Object? storageKey = freezed,Object? signedUrl = freezed,Object? errorMessage = freezed,}) {
  return _then(ExportJob(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,documentId: null == documentId ? _self.documentId : documentId // ignore: cast_nullable_to_non_nullable
as String,toggles: null == toggles ? _self.toggles : toggles // ignore: cast_nullable_to_non_nullable
as ExportSectionToggles,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ExportJobStatus,storageKey: freezed == storageKey ? _self.storageKey : storageKey // ignore: cast_nullable_to_non_nullable
as String?,signedUrl: freezed == signedUrl ? _self.signedUrl : signedUrl // ignore: cast_nullable_to_non_nullable
as String?,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of ExportJob
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ExportSectionTogglesCopyWith<$Res> get toggles {
  
  return $ExportSectionTogglesCopyWith<$Res>(_self.toggles, (value) {
    return _then(_self.copyWith(toggles: value));
  });
}
}


/// Adds pattern-matching-related methods to [ExportJob].
extension ExportJobPatterns on ExportJob {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ExportJob value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ExportJob() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ExportJob value)  $default,){
final _that = this;
switch (_that) {
case _ExportJob():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ExportJob value)?  $default,){
final _that = this;
switch (_that) {
case _ExportJob() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String documentId,  ExportSectionToggles toggles,  ExportJobStatus status,  String? storageKey,  String? signedUrl,  String? errorMessage)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ExportJob() when $default != null:
return $default(_that.id,_that.documentId,_that.toggles,_that.status,_that.storageKey,_that.signedUrl,_that.errorMessage);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String documentId,  ExportSectionToggles toggles,  ExportJobStatus status,  String? storageKey,  String? signedUrl,  String? errorMessage)  $default,) {final _that = this;
switch (_that) {
case _ExportJob():
return $default(_that.id,_that.documentId,_that.toggles,_that.status,_that.storageKey,_that.signedUrl,_that.errorMessage);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String documentId,  ExportSectionToggles toggles,  ExportJobStatus status,  String? storageKey,  String? signedUrl,  String? errorMessage)?  $default,) {final _that = this;
switch (_that) {
case _ExportJob() when $default != null:
return $default(_that.id,_that.documentId,_that.toggles,_that.status,_that.storageKey,_that.signedUrl,_that.errorMessage);case _:
  return null;

}
}

}

/// @nodoc


class _ExportJob extends ExportJob {
  const _ExportJob({required this.id, required this.documentId, this.toggles = const ExportSectionToggles(), this.status = ExportJobStatus.idle, this.storageKey, this.signedUrl, this.errorMessage}): super._();
  

@override final  String id;
@override final  String documentId;
@override@JsonKey() final  ExportSectionToggles toggles;
@override@JsonKey() final  ExportJobStatus status;
@override final  String? storageKey;
@override final  String? signedUrl;
@override final  String? errorMessage;

/// Create a copy of ExportJob
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ExportJobCopyWith<_ExportJob> get copyWith => __$ExportJobCopyWithImpl<_ExportJob>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ExportJob&&(identical(other.id, id) || other.id == id)&&(identical(other.documentId, documentId) || other.documentId == documentId)&&(identical(other.toggles, toggles) || other.toggles == toggles)&&(identical(other.status, status) || other.status == status)&&(identical(other.storageKey, storageKey) || other.storageKey == storageKey)&&(identical(other.signedUrl, signedUrl) || other.signedUrl == signedUrl)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage));
}


@override
int get hashCode => Object.hash(runtimeType,id,documentId,toggles,status,storageKey,signedUrl,errorMessage);

@override
String toString() {
  return 'ExportJob(id: $id, documentId: $documentId, toggles: $toggles, status: $status, storageKey: $storageKey, signedUrl: $signedUrl, errorMessage: $errorMessage)';
}


}

/// @nodoc
abstract mixin class _$ExportJobCopyWith<$Res> implements $ExportJobCopyWith<$Res> {
  factory _$ExportJobCopyWith(_ExportJob value, $Res Function(_ExportJob) _then) = __$ExportJobCopyWithImpl;
@override @useResult
$Res call({
 String id, String documentId, ExportSectionToggles toggles, ExportJobStatus status, String? storageKey, String? signedUrl, String? errorMessage
});


@override $ExportSectionTogglesCopyWith<$Res> get toggles;

}
/// @nodoc
class __$ExportJobCopyWithImpl<$Res>
    implements _$ExportJobCopyWith<$Res> {
  __$ExportJobCopyWithImpl(this._self, this._then);

  final _ExportJob _self;
  final $Res Function(_ExportJob) _then;

/// Create a copy of ExportJob
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? documentId = null,Object? toggles = null,Object? status = null,Object? storageKey = freezed,Object? signedUrl = freezed,Object? errorMessage = freezed,}) {
  return _then(_ExportJob(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,documentId: null == documentId ? _self.documentId : documentId // ignore: cast_nullable_to_non_nullable
as String,toggles: null == toggles ? _self.toggles : toggles // ignore: cast_nullable_to_non_nullable
as ExportSectionToggles,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ExportJobStatus,storageKey: freezed == storageKey ? _self.storageKey : storageKey // ignore: cast_nullable_to_non_nullable
as String?,signedUrl: freezed == signedUrl ? _self.signedUrl : signedUrl // ignore: cast_nullable_to_non_nullable
as String?,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of ExportJob
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ExportSectionTogglesCopyWith<$Res> get toggles {
  
  return $ExportSectionTogglesCopyWith<$Res>(_self.toggles, (value) {
    return _then(_self.copyWith(toggles: value));
  });
}
}

// dart format on
