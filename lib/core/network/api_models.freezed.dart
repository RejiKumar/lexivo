// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'api_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AuthSessionDto {

 String get subject; String? get email;@JsonKey(name: 'display_name') String? get displayName;
/// Create a copy of AuthSessionDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AuthSessionDtoCopyWith<AuthSessionDto> get copyWith => _$AuthSessionDtoCopyWithImpl<AuthSessionDto>(this as AuthSessionDto, _$identity);

  /// Serializes this AuthSessionDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AuthSessionDto&&(identical(other.subject, subject) || other.subject == subject)&&(identical(other.email, email) || other.email == email)&&(identical(other.displayName, displayName) || other.displayName == displayName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,subject,email,displayName);

@override
String toString() {
  return 'AuthSessionDto(subject: $subject, email: $email, displayName: $displayName)';
}


}

/// @nodoc
abstract mixin class $AuthSessionDtoCopyWith<$Res>  {
  factory $AuthSessionDtoCopyWith(AuthSessionDto value, $Res Function(AuthSessionDto) _then) = _$AuthSessionDtoCopyWithImpl;
@useResult
$Res call({
 String subject, String? email,@JsonKey(name: 'display_name') String? displayName
});




}
/// @nodoc
class _$AuthSessionDtoCopyWithImpl<$Res>
    implements $AuthSessionDtoCopyWith<$Res> {
  _$AuthSessionDtoCopyWithImpl(this._self, this._then);

  final AuthSessionDto _self;
  final $Res Function(AuthSessionDto) _then;

/// Create a copy of AuthSessionDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? subject = null,Object? email = freezed,Object? displayName = freezed,}) {
  return _then(AuthSessionDto(
subject: null == subject ? _self.subject : subject // ignore: cast_nullable_to_non_nullable
as String,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,displayName: freezed == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [AuthSessionDto].
extension AuthSessionDtoPatterns on AuthSessionDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AuthSessionDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AuthSessionDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AuthSessionDto value)  $default,){
final _that = this;
switch (_that) {
case _AuthSessionDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AuthSessionDto value)?  $default,){
final _that = this;
switch (_that) {
case _AuthSessionDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String subject,  String? email, @JsonKey(name: 'display_name')  String? displayName)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AuthSessionDto() when $default != null:
return $default(_that.subject,_that.email,_that.displayName);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String subject,  String? email, @JsonKey(name: 'display_name')  String? displayName)  $default,) {final _that = this;
switch (_that) {
case _AuthSessionDto():
return $default(_that.subject,_that.email,_that.displayName);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String subject,  String? email, @JsonKey(name: 'display_name')  String? displayName)?  $default,) {final _that = this;
switch (_that) {
case _AuthSessionDto() when $default != null:
return $default(_that.subject,_that.email,_that.displayName);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AuthSessionDto implements AuthSessionDto {
  const _AuthSessionDto({required this.subject, this.email, @JsonKey(name: 'display_name') this.displayName});
  factory _AuthSessionDto.fromJson(Map<String, dynamic> json) => _$AuthSessionDtoFromJson(json);

@override final  String subject;
@override final  String? email;
@override@JsonKey(name: 'display_name') final  String? displayName;

/// Create a copy of AuthSessionDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AuthSessionDtoCopyWith<_AuthSessionDto> get copyWith => __$AuthSessionDtoCopyWithImpl<_AuthSessionDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AuthSessionDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AuthSessionDto&&(identical(other.subject, subject) || other.subject == subject)&&(identical(other.email, email) || other.email == email)&&(identical(other.displayName, displayName) || other.displayName == displayName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,subject,email,displayName);

@override
String toString() {
  return 'AuthSessionDto(subject: $subject, email: $email, displayName: $displayName)';
}


}

/// @nodoc
abstract mixin class _$AuthSessionDtoCopyWith<$Res> implements $AuthSessionDtoCopyWith<$Res> {
  factory _$AuthSessionDtoCopyWith(_AuthSessionDto value, $Res Function(_AuthSessionDto) _then) = __$AuthSessionDtoCopyWithImpl;
@override @useResult
$Res call({
 String subject, String? email,@JsonKey(name: 'display_name') String? displayName
});




}
/// @nodoc
class __$AuthSessionDtoCopyWithImpl<$Res>
    implements _$AuthSessionDtoCopyWith<$Res> {
  __$AuthSessionDtoCopyWithImpl(this._self, this._then);

  final _AuthSessionDto _self;
  final $Res Function(_AuthSessionDto) _then;

/// Create a copy of AuthSessionDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? subject = null,Object? email = freezed,Object? displayName = freezed,}) {
  return _then(_AuthSessionDto(
subject: null == subject ? _self.subject : subject // ignore: cast_nullable_to_non_nullable
as String,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,displayName: freezed == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$UserProfileDto {

 String get id;@JsonKey(name: 'external_id') String get externalId; String? get email;@JsonKey(name: 'display_name') String? get displayName;@JsonKey(name: 'created_at') DateTime? get createdAt;@JsonKey(name: 'updated_at') DateTime? get updatedAt;
/// Create a copy of UserProfileDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UserProfileDtoCopyWith<UserProfileDto> get copyWith => _$UserProfileDtoCopyWithImpl<UserProfileDto>(this as UserProfileDto, _$identity);

  /// Serializes this UserProfileDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UserProfileDto&&(identical(other.id, id) || other.id == id)&&(identical(other.externalId, externalId) || other.externalId == externalId)&&(identical(other.email, email) || other.email == email)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,externalId,email,displayName,createdAt,updatedAt);

@override
String toString() {
  return 'UserProfileDto(id: $id, externalId: $externalId, email: $email, displayName: $displayName, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $UserProfileDtoCopyWith<$Res>  {
  factory $UserProfileDtoCopyWith(UserProfileDto value, $Res Function(UserProfileDto) _then) = _$UserProfileDtoCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'external_id') String externalId, String? email,@JsonKey(name: 'display_name') String? displayName,@JsonKey(name: 'created_at') DateTime? createdAt,@JsonKey(name: 'updated_at') DateTime? updatedAt
});




}
/// @nodoc
class _$UserProfileDtoCopyWithImpl<$Res>
    implements $UserProfileDtoCopyWith<$Res> {
  _$UserProfileDtoCopyWithImpl(this._self, this._then);

  final UserProfileDto _self;
  final $Res Function(UserProfileDto) _then;

/// Create a copy of UserProfileDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? externalId = null,Object? email = freezed,Object? displayName = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(UserProfileDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,externalId: null == externalId ? _self.externalId : externalId // ignore: cast_nullable_to_non_nullable
as String,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,displayName: freezed == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [UserProfileDto].
extension UserProfileDtoPatterns on UserProfileDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UserProfileDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UserProfileDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UserProfileDto value)  $default,){
final _that = this;
switch (_that) {
case _UserProfileDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UserProfileDto value)?  $default,){
final _that = this;
switch (_that) {
case _UserProfileDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'external_id')  String externalId,  String? email, @JsonKey(name: 'display_name')  String? displayName, @JsonKey(name: 'created_at')  DateTime? createdAt, @JsonKey(name: 'updated_at')  DateTime? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UserProfileDto() when $default != null:
return $default(_that.id,_that.externalId,_that.email,_that.displayName,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'external_id')  String externalId,  String? email, @JsonKey(name: 'display_name')  String? displayName, @JsonKey(name: 'created_at')  DateTime? createdAt, @JsonKey(name: 'updated_at')  DateTime? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _UserProfileDto():
return $default(_that.id,_that.externalId,_that.email,_that.displayName,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'external_id')  String externalId,  String? email, @JsonKey(name: 'display_name')  String? displayName, @JsonKey(name: 'created_at')  DateTime? createdAt, @JsonKey(name: 'updated_at')  DateTime? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _UserProfileDto() when $default != null:
return $default(_that.id,_that.externalId,_that.email,_that.displayName,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UserProfileDto implements UserProfileDto {
  const _UserProfileDto({required this.id, @JsonKey(name: 'external_id') required this.externalId, this.email, @JsonKey(name: 'display_name') this.displayName, @JsonKey(name: 'created_at') this.createdAt, @JsonKey(name: 'updated_at') this.updatedAt});
  factory _UserProfileDto.fromJson(Map<String, dynamic> json) => _$UserProfileDtoFromJson(json);

@override final  String id;
@override@JsonKey(name: 'external_id') final  String externalId;
@override final  String? email;
@override@JsonKey(name: 'display_name') final  String? displayName;
@override@JsonKey(name: 'created_at') final  DateTime? createdAt;
@override@JsonKey(name: 'updated_at') final  DateTime? updatedAt;

/// Create a copy of UserProfileDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UserProfileDtoCopyWith<_UserProfileDto> get copyWith => __$UserProfileDtoCopyWithImpl<_UserProfileDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UserProfileDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UserProfileDto&&(identical(other.id, id) || other.id == id)&&(identical(other.externalId, externalId) || other.externalId == externalId)&&(identical(other.email, email) || other.email == email)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,externalId,email,displayName,createdAt,updatedAt);

@override
String toString() {
  return 'UserProfileDto(id: $id, externalId: $externalId, email: $email, displayName: $displayName, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$UserProfileDtoCopyWith<$Res> implements $UserProfileDtoCopyWith<$Res> {
  factory _$UserProfileDtoCopyWith(_UserProfileDto value, $Res Function(_UserProfileDto) _then) = __$UserProfileDtoCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'external_id') String externalId, String? email,@JsonKey(name: 'display_name') String? displayName,@JsonKey(name: 'created_at') DateTime? createdAt,@JsonKey(name: 'updated_at') DateTime? updatedAt
});




}
/// @nodoc
class __$UserProfileDtoCopyWithImpl<$Res>
    implements _$UserProfileDtoCopyWith<$Res> {
  __$UserProfileDtoCopyWithImpl(this._self, this._then);

  final _UserProfileDto _self;
  final $Res Function(_UserProfileDto) _then;

/// Create a copy of UserProfileDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? externalId = null,Object? email = freezed,Object? displayName = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_UserProfileDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,externalId: null == externalId ? _self.externalId : externalId // ignore: cast_nullable_to_non_nullable
as String,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,displayName: freezed == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}


/// @nodoc
mixin _$UserProfileUpdateDto {

@JsonKey(name: 'display_name') String? get displayName; String? get email;
/// Create a copy of UserProfileUpdateDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UserProfileUpdateDtoCopyWith<UserProfileUpdateDto> get copyWith => _$UserProfileUpdateDtoCopyWithImpl<UserProfileUpdateDto>(this as UserProfileUpdateDto, _$identity);

  /// Serializes this UserProfileUpdateDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UserProfileUpdateDto&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.email, email) || other.email == email));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,displayName,email);

@override
String toString() {
  return 'UserProfileUpdateDto(displayName: $displayName, email: $email)';
}


}

/// @nodoc
abstract mixin class $UserProfileUpdateDtoCopyWith<$Res>  {
  factory $UserProfileUpdateDtoCopyWith(UserProfileUpdateDto value, $Res Function(UserProfileUpdateDto) _then) = _$UserProfileUpdateDtoCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'display_name') String? displayName, String? email
});




}
/// @nodoc
class _$UserProfileUpdateDtoCopyWithImpl<$Res>
    implements $UserProfileUpdateDtoCopyWith<$Res> {
  _$UserProfileUpdateDtoCopyWithImpl(this._self, this._then);

  final UserProfileUpdateDto _self;
  final $Res Function(UserProfileUpdateDto) _then;

/// Create a copy of UserProfileUpdateDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? displayName = freezed,Object? email = freezed,}) {
  return _then(UserProfileUpdateDto(
displayName: freezed == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String?,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [UserProfileUpdateDto].
extension UserProfileUpdateDtoPatterns on UserProfileUpdateDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UserProfileUpdateDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UserProfileUpdateDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UserProfileUpdateDto value)  $default,){
final _that = this;
switch (_that) {
case _UserProfileUpdateDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UserProfileUpdateDto value)?  $default,){
final _that = this;
switch (_that) {
case _UserProfileUpdateDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'display_name')  String? displayName,  String? email)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UserProfileUpdateDto() when $default != null:
return $default(_that.displayName,_that.email);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'display_name')  String? displayName,  String? email)  $default,) {final _that = this;
switch (_that) {
case _UserProfileUpdateDto():
return $default(_that.displayName,_that.email);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'display_name')  String? displayName,  String? email)?  $default,) {final _that = this;
switch (_that) {
case _UserProfileUpdateDto() when $default != null:
return $default(_that.displayName,_that.email);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UserProfileUpdateDto implements UserProfileUpdateDto {
  const _UserProfileUpdateDto({@JsonKey(name: 'display_name') this.displayName, this.email});
  factory _UserProfileUpdateDto.fromJson(Map<String, dynamic> json) => _$UserProfileUpdateDtoFromJson(json);

@override@JsonKey(name: 'display_name') final  String? displayName;
@override final  String? email;

/// Create a copy of UserProfileUpdateDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UserProfileUpdateDtoCopyWith<_UserProfileUpdateDto> get copyWith => __$UserProfileUpdateDtoCopyWithImpl<_UserProfileUpdateDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UserProfileUpdateDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UserProfileUpdateDto&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.email, email) || other.email == email));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,displayName,email);

@override
String toString() {
  return 'UserProfileUpdateDto(displayName: $displayName, email: $email)';
}


}

/// @nodoc
abstract mixin class _$UserProfileUpdateDtoCopyWith<$Res> implements $UserProfileUpdateDtoCopyWith<$Res> {
  factory _$UserProfileUpdateDtoCopyWith(_UserProfileUpdateDto value, $Res Function(_UserProfileUpdateDto) _then) = __$UserProfileUpdateDtoCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'display_name') String? displayName, String? email
});




}
/// @nodoc
class __$UserProfileUpdateDtoCopyWithImpl<$Res>
    implements _$UserProfileUpdateDtoCopyWith<$Res> {
  __$UserProfileUpdateDtoCopyWithImpl(this._self, this._then);

  final _UserProfileUpdateDto _self;
  final $Res Function(_UserProfileUpdateDto) _then;

/// Create a copy of UserProfileUpdateDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? displayName = freezed,Object? email = freezed,}) {
  return _then(_UserProfileUpdateDto(
displayName: freezed == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String?,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$DocumentDto {

 String get id;@JsonKey(name: 'user_id') String get userId; String? get title;@JsonKey(name: 'storage_key') String? get storageKey; String get status;@JsonKey(name: 'created_at') DateTime? get createdAt;@JsonKey(name: 'updated_at') DateTime? get updatedAt;
/// Create a copy of DocumentDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DocumentDtoCopyWith<DocumentDto> get copyWith => _$DocumentDtoCopyWithImpl<DocumentDto>(this as DocumentDto, _$identity);

  /// Serializes this DocumentDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DocumentDto&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.title, title) || other.title == title)&&(identical(other.storageKey, storageKey) || other.storageKey == storageKey)&&(identical(other.status, status) || other.status == status)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,title,storageKey,status,createdAt,updatedAt);

@override
String toString() {
  return 'DocumentDto(id: $id, userId: $userId, title: $title, storageKey: $storageKey, status: $status, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $DocumentDtoCopyWith<$Res>  {
  factory $DocumentDtoCopyWith(DocumentDto value, $Res Function(DocumentDto) _then) = _$DocumentDtoCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'user_id') String userId, String? title,@JsonKey(name: 'storage_key') String? storageKey, String status,@JsonKey(name: 'created_at') DateTime? createdAt,@JsonKey(name: 'updated_at') DateTime? updatedAt
});




}
/// @nodoc
class _$DocumentDtoCopyWithImpl<$Res>
    implements $DocumentDtoCopyWith<$Res> {
  _$DocumentDtoCopyWithImpl(this._self, this._then);

  final DocumentDto _self;
  final $Res Function(DocumentDto) _then;

/// Create a copy of DocumentDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? userId = null,Object? title = freezed,Object? storageKey = freezed,Object? status = null,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(DocumentDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,storageKey: freezed == storageKey ? _self.storageKey : storageKey // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [DocumentDto].
extension DocumentDtoPatterns on DocumentDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DocumentDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DocumentDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DocumentDto value)  $default,){
final _that = this;
switch (_that) {
case _DocumentDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DocumentDto value)?  $default,){
final _that = this;
switch (_that) {
case _DocumentDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'user_id')  String userId,  String? title, @JsonKey(name: 'storage_key')  String? storageKey,  String status, @JsonKey(name: 'created_at')  DateTime? createdAt, @JsonKey(name: 'updated_at')  DateTime? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DocumentDto() when $default != null:
return $default(_that.id,_that.userId,_that.title,_that.storageKey,_that.status,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'user_id')  String userId,  String? title, @JsonKey(name: 'storage_key')  String? storageKey,  String status, @JsonKey(name: 'created_at')  DateTime? createdAt, @JsonKey(name: 'updated_at')  DateTime? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _DocumentDto():
return $default(_that.id,_that.userId,_that.title,_that.storageKey,_that.status,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'user_id')  String userId,  String? title, @JsonKey(name: 'storage_key')  String? storageKey,  String status, @JsonKey(name: 'created_at')  DateTime? createdAt, @JsonKey(name: 'updated_at')  DateTime? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _DocumentDto() when $default != null:
return $default(_that.id,_that.userId,_that.title,_that.storageKey,_that.status,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DocumentDto implements DocumentDto {
  const _DocumentDto({required this.id, @JsonKey(name: 'user_id') required this.userId, this.title, @JsonKey(name: 'storage_key') this.storageKey, required this.status, @JsonKey(name: 'created_at') this.createdAt, @JsonKey(name: 'updated_at') this.updatedAt});
  factory _DocumentDto.fromJson(Map<String, dynamic> json) => _$DocumentDtoFromJson(json);

@override final  String id;
@override@JsonKey(name: 'user_id') final  String userId;
@override final  String? title;
@override@JsonKey(name: 'storage_key') final  String? storageKey;
@override final  String status;
@override@JsonKey(name: 'created_at') final  DateTime? createdAt;
@override@JsonKey(name: 'updated_at') final  DateTime? updatedAt;

/// Create a copy of DocumentDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DocumentDtoCopyWith<_DocumentDto> get copyWith => __$DocumentDtoCopyWithImpl<_DocumentDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DocumentDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DocumentDto&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.title, title) || other.title == title)&&(identical(other.storageKey, storageKey) || other.storageKey == storageKey)&&(identical(other.status, status) || other.status == status)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,title,storageKey,status,createdAt,updatedAt);

@override
String toString() {
  return 'DocumentDto(id: $id, userId: $userId, title: $title, storageKey: $storageKey, status: $status, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$DocumentDtoCopyWith<$Res> implements $DocumentDtoCopyWith<$Res> {
  factory _$DocumentDtoCopyWith(_DocumentDto value, $Res Function(_DocumentDto) _then) = __$DocumentDtoCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'user_id') String userId, String? title,@JsonKey(name: 'storage_key') String? storageKey, String status,@JsonKey(name: 'created_at') DateTime? createdAt,@JsonKey(name: 'updated_at') DateTime? updatedAt
});




}
/// @nodoc
class __$DocumentDtoCopyWithImpl<$Res>
    implements _$DocumentDtoCopyWith<$Res> {
  __$DocumentDtoCopyWithImpl(this._self, this._then);

  final _DocumentDto _self;
  final $Res Function(_DocumentDto) _then;

/// Create a copy of DocumentDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? userId = null,Object? title = freezed,Object? storageKey = freezed,Object? status = null,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_DocumentDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,storageKey: freezed == storageKey ? _self.storageKey : storageKey // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}


/// @nodoc
mixin _$DocumentListDto {

 List<DocumentDto> get items;
/// Create a copy of DocumentListDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DocumentListDtoCopyWith<DocumentListDto> get copyWith => _$DocumentListDtoCopyWithImpl<DocumentListDto>(this as DocumentListDto, _$identity);

  /// Serializes this DocumentListDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DocumentListDto&&const DeepCollectionEquality().equals(other.items, items));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(items));

@override
String toString() {
  return 'DocumentListDto(items: $items)';
}


}

/// @nodoc
abstract mixin class $DocumentListDtoCopyWith<$Res>  {
  factory $DocumentListDtoCopyWith(DocumentListDto value, $Res Function(DocumentListDto) _then) = _$DocumentListDtoCopyWithImpl;
@useResult
$Res call({
 List<DocumentDto> items
});




}
/// @nodoc
class _$DocumentListDtoCopyWithImpl<$Res>
    implements $DocumentListDtoCopyWith<$Res> {
  _$DocumentListDtoCopyWithImpl(this._self, this._then);

  final DocumentListDto _self;
  final $Res Function(DocumentListDto) _then;

/// Create a copy of DocumentListDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? items = null,}) {
  return _then(DocumentListDto(
items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<DocumentDto>,
  ));
}

}


/// Adds pattern-matching-related methods to [DocumentListDto].
extension DocumentListDtoPatterns on DocumentListDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DocumentListDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DocumentListDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DocumentListDto value)  $default,){
final _that = this;
switch (_that) {
case _DocumentListDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DocumentListDto value)?  $default,){
final _that = this;
switch (_that) {
case _DocumentListDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<DocumentDto> items)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DocumentListDto() when $default != null:
return $default(_that.items);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<DocumentDto> items)  $default,) {final _that = this;
switch (_that) {
case _DocumentListDto():
return $default(_that.items);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<DocumentDto> items)?  $default,) {final _that = this;
switch (_that) {
case _DocumentListDto() when $default != null:
return $default(_that.items);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DocumentListDto implements DocumentListDto {
  const _DocumentListDto({ List<DocumentDto> items = const []}): _items = items;
  factory _DocumentListDto.fromJson(Map<String, dynamic> json) => _$DocumentListDtoFromJson(json);

 final  List<DocumentDto> _items;
@override@JsonKey() List<DocumentDto> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}


/// Create a copy of DocumentListDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DocumentListDtoCopyWith<_DocumentListDto> get copyWith => __$DocumentListDtoCopyWithImpl<_DocumentListDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DocumentListDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DocumentListDto&&const DeepCollectionEquality().equals(other._items, _items));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_items));

@override
String toString() {
  return 'DocumentListDto(items: $items)';
}


}

/// @nodoc
abstract mixin class _$DocumentListDtoCopyWith<$Res> implements $DocumentListDtoCopyWith<$Res> {
  factory _$DocumentListDtoCopyWith(_DocumentListDto value, $Res Function(_DocumentListDto) _then) = __$DocumentListDtoCopyWithImpl;
@override @useResult
$Res call({
 List<DocumentDto> items
});




}
/// @nodoc
class __$DocumentListDtoCopyWithImpl<$Res>
    implements _$DocumentListDtoCopyWith<$Res> {
  __$DocumentListDtoCopyWithImpl(this._self, this._then);

  final _DocumentListDto _self;
  final $Res Function(_DocumentListDto) _then;

/// Create a copy of DocumentListDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? items = null,}) {
  return _then(_DocumentListDto(
items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<DocumentDto>,
  ));
}


}


/// @nodoc
mixin _$DocumentStatusDto {

 String get id; String get status;
/// Create a copy of DocumentStatusDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DocumentStatusDtoCopyWith<DocumentStatusDto> get copyWith => _$DocumentStatusDtoCopyWithImpl<DocumentStatusDto>(this as DocumentStatusDto, _$identity);

  /// Serializes this DocumentStatusDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DocumentStatusDto&&(identical(other.id, id) || other.id == id)&&(identical(other.status, status) || other.status == status));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,status);

@override
String toString() {
  return 'DocumentStatusDto(id: $id, status: $status)';
}


}

/// @nodoc
abstract mixin class $DocumentStatusDtoCopyWith<$Res>  {
  factory $DocumentStatusDtoCopyWith(DocumentStatusDto value, $Res Function(DocumentStatusDto) _then) = _$DocumentStatusDtoCopyWithImpl;
@useResult
$Res call({
 String id, String status
});




}
/// @nodoc
class _$DocumentStatusDtoCopyWithImpl<$Res>
    implements $DocumentStatusDtoCopyWith<$Res> {
  _$DocumentStatusDtoCopyWithImpl(this._self, this._then);

  final DocumentStatusDto _self;
  final $Res Function(DocumentStatusDto) _then;

/// Create a copy of DocumentStatusDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? status = null,}) {
  return _then(DocumentStatusDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [DocumentStatusDto].
extension DocumentStatusDtoPatterns on DocumentStatusDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DocumentStatusDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DocumentStatusDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DocumentStatusDto value)  $default,){
final _that = this;
switch (_that) {
case _DocumentStatusDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DocumentStatusDto value)?  $default,){
final _that = this;
switch (_that) {
case _DocumentStatusDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String status)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DocumentStatusDto() when $default != null:
return $default(_that.id,_that.status);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String status)  $default,) {final _that = this;
switch (_that) {
case _DocumentStatusDto():
return $default(_that.id,_that.status);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String status)?  $default,) {final _that = this;
switch (_that) {
case _DocumentStatusDto() when $default != null:
return $default(_that.id,_that.status);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DocumentStatusDto implements DocumentStatusDto {
  const _DocumentStatusDto({required this.id, required this.status});
  factory _DocumentStatusDto.fromJson(Map<String, dynamic> json) => _$DocumentStatusDtoFromJson(json);

@override final  String id;
@override final  String status;

/// Create a copy of DocumentStatusDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DocumentStatusDtoCopyWith<_DocumentStatusDto> get copyWith => __$DocumentStatusDtoCopyWithImpl<_DocumentStatusDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DocumentStatusDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DocumentStatusDto&&(identical(other.id, id) || other.id == id)&&(identical(other.status, status) || other.status == status));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,status);

@override
String toString() {
  return 'DocumentStatusDto(id: $id, status: $status)';
}


}

/// @nodoc
abstract mixin class _$DocumentStatusDtoCopyWith<$Res> implements $DocumentStatusDtoCopyWith<$Res> {
  factory _$DocumentStatusDtoCopyWith(_DocumentStatusDto value, $Res Function(_DocumentStatusDto) _then) = __$DocumentStatusDtoCopyWithImpl;
@override @useResult
$Res call({
 String id, String status
});




}
/// @nodoc
class __$DocumentStatusDtoCopyWithImpl<$Res>
    implements _$DocumentStatusDtoCopyWith<$Res> {
  __$DocumentStatusDtoCopyWithImpl(this._self, this._then);

  final _DocumentStatusDto _self;
  final $Res Function(_DocumentStatusDto) _then;

/// Create a copy of DocumentStatusDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? status = null,}) {
  return _then(_DocumentStatusDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
