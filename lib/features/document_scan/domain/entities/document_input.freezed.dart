// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'document_input.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$DocumentBytes {

 List<int> get bytes; String get filename; String get mimeType; DocumentInputKind get source;
/// Create a copy of DocumentBytes
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DocumentBytesCopyWith<DocumentBytes> get copyWith => _$DocumentBytesCopyWithImpl<DocumentBytes>(this as DocumentBytes, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DocumentBytes&&const DeepCollectionEquality().equals(other.bytes, bytes)&&(identical(other.filename, filename) || other.filename == filename)&&(identical(other.mimeType, mimeType) || other.mimeType == mimeType)&&(identical(other.source, source) || other.source == source));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(bytes),filename,mimeType,source);

@override
String toString() {
  return 'DocumentBytes(bytes: $bytes, filename: $filename, mimeType: $mimeType, source: $source)';
}


}

/// @nodoc
abstract mixin class $DocumentBytesCopyWith<$Res>  {
  factory $DocumentBytesCopyWith(DocumentBytes value, $Res Function(DocumentBytes) _then) = _$DocumentBytesCopyWithImpl;
@useResult
$Res call({
 List<int> bytes, String filename, String mimeType, DocumentInputKind source
});




}
/// @nodoc
class _$DocumentBytesCopyWithImpl<$Res>
    implements $DocumentBytesCopyWith<$Res> {
  _$DocumentBytesCopyWithImpl(this._self, this._then);

  final DocumentBytes _self;
  final $Res Function(DocumentBytes) _then;

/// Create a copy of DocumentBytes
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? bytes = null,Object? filename = null,Object? mimeType = null,Object? source = null,}) {
  return _then(DocumentBytes(
bytes: null == bytes ? _self.bytes : bytes // ignore: cast_nullable_to_non_nullable
as List<int>,filename: null == filename ? _self.filename : filename // ignore: cast_nullable_to_non_nullable
as String,mimeType: null == mimeType ? _self.mimeType : mimeType // ignore: cast_nullable_to_non_nullable
as String,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as DocumentInputKind,
  ));
}

}


/// Adds pattern-matching-related methods to [DocumentBytes].
extension DocumentBytesPatterns on DocumentBytes {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DocumentBytes value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DocumentBytes() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DocumentBytes value)  $default,){
final _that = this;
switch (_that) {
case _DocumentBytes():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DocumentBytes value)?  $default,){
final _that = this;
switch (_that) {
case _DocumentBytes() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<int> bytes,  String filename,  String mimeType,  DocumentInputKind source)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DocumentBytes() when $default != null:
return $default(_that.bytes,_that.filename,_that.mimeType,_that.source);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<int> bytes,  String filename,  String mimeType,  DocumentInputKind source)  $default,) {final _that = this;
switch (_that) {
case _DocumentBytes():
return $default(_that.bytes,_that.filename,_that.mimeType,_that.source);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<int> bytes,  String filename,  String mimeType,  DocumentInputKind source)?  $default,) {final _that = this;
switch (_that) {
case _DocumentBytes() when $default != null:
return $default(_that.bytes,_that.filename,_that.mimeType,_that.source);case _:
  return null;

}
}

}

/// @nodoc


class _DocumentBytes implements DocumentBytes {
  const _DocumentBytes({required  List<int> bytes, required this.filename, required this.mimeType, required this.source}): _bytes = bytes;
  

 final  List<int> _bytes;
@override List<int> get bytes {
  if (_bytes is EqualUnmodifiableListView) return _bytes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_bytes);
}

@override final  String filename;
@override final  String mimeType;
@override final  DocumentInputKind source;

/// Create a copy of DocumentBytes
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DocumentBytesCopyWith<_DocumentBytes> get copyWith => __$DocumentBytesCopyWithImpl<_DocumentBytes>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DocumentBytes&&const DeepCollectionEquality().equals(other._bytes, _bytes)&&(identical(other.filename, filename) || other.filename == filename)&&(identical(other.mimeType, mimeType) || other.mimeType == mimeType)&&(identical(other.source, source) || other.source == source));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_bytes),filename,mimeType,source);

@override
String toString() {
  return 'DocumentBytes(bytes: $bytes, filename: $filename, mimeType: $mimeType, source: $source)';
}


}

/// @nodoc
abstract mixin class _$DocumentBytesCopyWith<$Res> implements $DocumentBytesCopyWith<$Res> {
  factory _$DocumentBytesCopyWith(_DocumentBytes value, $Res Function(_DocumentBytes) _then) = __$DocumentBytesCopyWithImpl;
@override @useResult
$Res call({
 List<int> bytes, String filename, String mimeType, DocumentInputKind source
});




}
/// @nodoc
class __$DocumentBytesCopyWithImpl<$Res>
    implements _$DocumentBytesCopyWith<$Res> {
  __$DocumentBytesCopyWithImpl(this._self, this._then);

  final _DocumentBytes _self;
  final $Res Function(_DocumentBytes) _then;

/// Create a copy of DocumentBytes
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? bytes = null,Object? filename = null,Object? mimeType = null,Object? source = null,}) {
  return _then(_DocumentBytes(
bytes: null == bytes ? _self._bytes : bytes // ignore: cast_nullable_to_non_nullable
as List<int>,filename: null == filename ? _self.filename : filename // ignore: cast_nullable_to_non_nullable
as String,mimeType: null == mimeType ? _self.mimeType : mimeType // ignore: cast_nullable_to_non_nullable
as String,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as DocumentInputKind,
  ));
}


}

// dart format on
