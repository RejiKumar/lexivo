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

 String get id;@JsonKey(name: 'user_id') String get userId; String? get title;@JsonKey(name: 'storage_key') String? get storageKey; String get status;@JsonKey(name: 'extracted_text') String? get extractedText;@JsonKey(name: 'short_summary') String? get shortSummary;@JsonKey(name: 'detailed_summary') String? get detailedSummary;@JsonKey(name: 'summary_status') String get summaryStatus;@JsonKey(name: 'translated_text') String? get translatedText;@JsonKey(name: 'source_lang') String? get sourceLang;@JsonKey(name: 'target_lang') String? get targetLang;@JsonKey(name: 'translation_status') String get translationStatus;@JsonKey(name: 'created_at') DateTime? get createdAt;@JsonKey(name: 'updated_at') DateTime? get updatedAt;
/// Create a copy of DocumentDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DocumentDtoCopyWith<DocumentDto> get copyWith => _$DocumentDtoCopyWithImpl<DocumentDto>(this as DocumentDto, _$identity);

  /// Serializes this DocumentDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DocumentDto&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.title, title) || other.title == title)&&(identical(other.storageKey, storageKey) || other.storageKey == storageKey)&&(identical(other.status, status) || other.status == status)&&(identical(other.extractedText, extractedText) || other.extractedText == extractedText)&&(identical(other.shortSummary, shortSummary) || other.shortSummary == shortSummary)&&(identical(other.detailedSummary, detailedSummary) || other.detailedSummary == detailedSummary)&&(identical(other.summaryStatus, summaryStatus) || other.summaryStatus == summaryStatus)&&(identical(other.translatedText, translatedText) || other.translatedText == translatedText)&&(identical(other.sourceLang, sourceLang) || other.sourceLang == sourceLang)&&(identical(other.targetLang, targetLang) || other.targetLang == targetLang)&&(identical(other.translationStatus, translationStatus) || other.translationStatus == translationStatus)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,title,storageKey,status,extractedText,shortSummary,detailedSummary,summaryStatus,translatedText,sourceLang,targetLang,translationStatus,createdAt,updatedAt);

@override
String toString() {
  return 'DocumentDto(id: $id, userId: $userId, title: $title, storageKey: $storageKey, status: $status, extractedText: $extractedText, shortSummary: $shortSummary, detailedSummary: $detailedSummary, summaryStatus: $summaryStatus, translatedText: $translatedText, sourceLang: $sourceLang, targetLang: $targetLang, translationStatus: $translationStatus, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $DocumentDtoCopyWith<$Res>  {
  factory $DocumentDtoCopyWith(DocumentDto value, $Res Function(DocumentDto) _then) = _$DocumentDtoCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'user_id') String userId, String? title,@JsonKey(name: 'storage_key') String? storageKey, String status,@JsonKey(name: 'extracted_text') String? extractedText,@JsonKey(name: 'short_summary') String? shortSummary,@JsonKey(name: 'detailed_summary') String? detailedSummary,@JsonKey(name: 'summary_status') String summaryStatus,@JsonKey(name: 'translated_text') String? translatedText,@JsonKey(name: 'source_lang') String? sourceLang,@JsonKey(name: 'target_lang') String? targetLang,@JsonKey(name: 'translation_status') String translationStatus,@JsonKey(name: 'created_at') DateTime? createdAt,@JsonKey(name: 'updated_at') DateTime? updatedAt
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
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? userId = null,Object? title = freezed,Object? storageKey = freezed,Object? status = null,Object? extractedText = freezed,Object? shortSummary = freezed,Object? detailedSummary = freezed,Object? summaryStatus = null,Object? translatedText = freezed,Object? sourceLang = freezed,Object? targetLang = freezed,Object? translationStatus = null,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(DocumentDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,storageKey: freezed == storageKey ? _self.storageKey : storageKey // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,extractedText: freezed == extractedText ? _self.extractedText : extractedText // ignore: cast_nullable_to_non_nullable
as String?,shortSummary: freezed == shortSummary ? _self.shortSummary : shortSummary // ignore: cast_nullable_to_non_nullable
as String?,detailedSummary: freezed == detailedSummary ? _self.detailedSummary : detailedSummary // ignore: cast_nullable_to_non_nullable
as String?,summaryStatus: null == summaryStatus ? _self.summaryStatus : summaryStatus // ignore: cast_nullable_to_non_nullable
as String,translatedText: freezed == translatedText ? _self.translatedText : translatedText // ignore: cast_nullable_to_non_nullable
as String?,sourceLang: freezed == sourceLang ? _self.sourceLang : sourceLang // ignore: cast_nullable_to_non_nullable
as String?,targetLang: freezed == targetLang ? _self.targetLang : targetLang // ignore: cast_nullable_to_non_nullable
as String?,translationStatus: null == translationStatus ? _self.translationStatus : translationStatus // ignore: cast_nullable_to_non_nullable
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'user_id')  String userId,  String? title, @JsonKey(name: 'storage_key')  String? storageKey,  String status, @JsonKey(name: 'extracted_text')  String? extractedText, @JsonKey(name: 'short_summary')  String? shortSummary, @JsonKey(name: 'detailed_summary')  String? detailedSummary, @JsonKey(name: 'summary_status')  String summaryStatus, @JsonKey(name: 'translated_text')  String? translatedText, @JsonKey(name: 'source_lang')  String? sourceLang, @JsonKey(name: 'target_lang')  String? targetLang, @JsonKey(name: 'translation_status')  String translationStatus, @JsonKey(name: 'created_at')  DateTime? createdAt, @JsonKey(name: 'updated_at')  DateTime? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DocumentDto() when $default != null:
return $default(_that.id,_that.userId,_that.title,_that.storageKey,_that.status,_that.extractedText,_that.shortSummary,_that.detailedSummary,_that.summaryStatus,_that.translatedText,_that.sourceLang,_that.targetLang,_that.translationStatus,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'user_id')  String userId,  String? title, @JsonKey(name: 'storage_key')  String? storageKey,  String status, @JsonKey(name: 'extracted_text')  String? extractedText, @JsonKey(name: 'short_summary')  String? shortSummary, @JsonKey(name: 'detailed_summary')  String? detailedSummary, @JsonKey(name: 'summary_status')  String summaryStatus, @JsonKey(name: 'translated_text')  String? translatedText, @JsonKey(name: 'source_lang')  String? sourceLang, @JsonKey(name: 'target_lang')  String? targetLang, @JsonKey(name: 'translation_status')  String translationStatus, @JsonKey(name: 'created_at')  DateTime? createdAt, @JsonKey(name: 'updated_at')  DateTime? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _DocumentDto():
return $default(_that.id,_that.userId,_that.title,_that.storageKey,_that.status,_that.extractedText,_that.shortSummary,_that.detailedSummary,_that.summaryStatus,_that.translatedText,_that.sourceLang,_that.targetLang,_that.translationStatus,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'user_id')  String userId,  String? title, @JsonKey(name: 'storage_key')  String? storageKey,  String status, @JsonKey(name: 'extracted_text')  String? extractedText, @JsonKey(name: 'short_summary')  String? shortSummary, @JsonKey(name: 'detailed_summary')  String? detailedSummary, @JsonKey(name: 'summary_status')  String summaryStatus, @JsonKey(name: 'translated_text')  String? translatedText, @JsonKey(name: 'source_lang')  String? sourceLang, @JsonKey(name: 'target_lang')  String? targetLang, @JsonKey(name: 'translation_status')  String translationStatus, @JsonKey(name: 'created_at')  DateTime? createdAt, @JsonKey(name: 'updated_at')  DateTime? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _DocumentDto() when $default != null:
return $default(_that.id,_that.userId,_that.title,_that.storageKey,_that.status,_that.extractedText,_that.shortSummary,_that.detailedSummary,_that.summaryStatus,_that.translatedText,_that.sourceLang,_that.targetLang,_that.translationStatus,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DocumentDto implements DocumentDto {
  const _DocumentDto({required this.id, @JsonKey(name: 'user_id') required this.userId, this.title, @JsonKey(name: 'storage_key') this.storageKey, required this.status, @JsonKey(name: 'extracted_text') this.extractedText, @JsonKey(name: 'short_summary') this.shortSummary, @JsonKey(name: 'detailed_summary') this.detailedSummary, @JsonKey(name: 'summary_status') this.summaryStatus = 'idle', @JsonKey(name: 'translated_text') this.translatedText, @JsonKey(name: 'source_lang') this.sourceLang, @JsonKey(name: 'target_lang') this.targetLang, @JsonKey(name: 'translation_status') this.translationStatus = 'idle', @JsonKey(name: 'created_at') this.createdAt, @JsonKey(name: 'updated_at') this.updatedAt});
  factory _DocumentDto.fromJson(Map<String, dynamic> json) => _$DocumentDtoFromJson(json);

@override final  String id;
@override@JsonKey(name: 'user_id') final  String userId;
@override final  String? title;
@override@JsonKey(name: 'storage_key') final  String? storageKey;
@override final  String status;
@override@JsonKey(name: 'extracted_text') final  String? extractedText;
@override@JsonKey(name: 'short_summary') final  String? shortSummary;
@override@JsonKey(name: 'detailed_summary') final  String? detailedSummary;
@override@JsonKey(name: 'summary_status') final  String summaryStatus;
@override@JsonKey(name: 'translated_text') final  String? translatedText;
@override@JsonKey(name: 'source_lang') final  String? sourceLang;
@override@JsonKey(name: 'target_lang') final  String? targetLang;
@override@JsonKey(name: 'translation_status') final  String translationStatus;
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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DocumentDto&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.title, title) || other.title == title)&&(identical(other.storageKey, storageKey) || other.storageKey == storageKey)&&(identical(other.status, status) || other.status == status)&&(identical(other.extractedText, extractedText) || other.extractedText == extractedText)&&(identical(other.shortSummary, shortSummary) || other.shortSummary == shortSummary)&&(identical(other.detailedSummary, detailedSummary) || other.detailedSummary == detailedSummary)&&(identical(other.summaryStatus, summaryStatus) || other.summaryStatus == summaryStatus)&&(identical(other.translatedText, translatedText) || other.translatedText == translatedText)&&(identical(other.sourceLang, sourceLang) || other.sourceLang == sourceLang)&&(identical(other.targetLang, targetLang) || other.targetLang == targetLang)&&(identical(other.translationStatus, translationStatus) || other.translationStatus == translationStatus)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,title,storageKey,status,extractedText,shortSummary,detailedSummary,summaryStatus,translatedText,sourceLang,targetLang,translationStatus,createdAt,updatedAt);

@override
String toString() {
  return 'DocumentDto(id: $id, userId: $userId, title: $title, storageKey: $storageKey, status: $status, extractedText: $extractedText, shortSummary: $shortSummary, detailedSummary: $detailedSummary, summaryStatus: $summaryStatus, translatedText: $translatedText, sourceLang: $sourceLang, targetLang: $targetLang, translationStatus: $translationStatus, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$DocumentDtoCopyWith<$Res> implements $DocumentDtoCopyWith<$Res> {
  factory _$DocumentDtoCopyWith(_DocumentDto value, $Res Function(_DocumentDto) _then) = __$DocumentDtoCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'user_id') String userId, String? title,@JsonKey(name: 'storage_key') String? storageKey, String status,@JsonKey(name: 'extracted_text') String? extractedText,@JsonKey(name: 'short_summary') String? shortSummary,@JsonKey(name: 'detailed_summary') String? detailedSummary,@JsonKey(name: 'summary_status') String summaryStatus,@JsonKey(name: 'translated_text') String? translatedText,@JsonKey(name: 'source_lang') String? sourceLang,@JsonKey(name: 'target_lang') String? targetLang,@JsonKey(name: 'translation_status') String translationStatus,@JsonKey(name: 'created_at') DateTime? createdAt,@JsonKey(name: 'updated_at') DateTime? updatedAt
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
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? userId = null,Object? title = freezed,Object? storageKey = freezed,Object? status = null,Object? extractedText = freezed,Object? shortSummary = freezed,Object? detailedSummary = freezed,Object? summaryStatus = null,Object? translatedText = freezed,Object? sourceLang = freezed,Object? targetLang = freezed,Object? translationStatus = null,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_DocumentDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,storageKey: freezed == storageKey ? _self.storageKey : storageKey // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,extractedText: freezed == extractedText ? _self.extractedText : extractedText // ignore: cast_nullable_to_non_nullable
as String?,shortSummary: freezed == shortSummary ? _self.shortSummary : shortSummary // ignore: cast_nullable_to_non_nullable
as String?,detailedSummary: freezed == detailedSummary ? _self.detailedSummary : detailedSummary // ignore: cast_nullable_to_non_nullable
as String?,summaryStatus: null == summaryStatus ? _self.summaryStatus : summaryStatus // ignore: cast_nullable_to_non_nullable
as String,translatedText: freezed == translatedText ? _self.translatedText : translatedText // ignore: cast_nullable_to_non_nullable
as String?,sourceLang: freezed == sourceLang ? _self.sourceLang : sourceLang // ignore: cast_nullable_to_non_nullable
as String?,targetLang: freezed == targetLang ? _self.targetLang : targetLang // ignore: cast_nullable_to_non_nullable
as String?,translationStatus: null == translationStatus ? _self.translationStatus : translationStatus // ignore: cast_nullable_to_non_nullable
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


/// @nodoc
mixin _$SummaryStatusDto {

 String get id;@JsonKey(name: 'summary_status') String get summaryStatus;
/// Create a copy of SummaryStatusDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SummaryStatusDtoCopyWith<SummaryStatusDto> get copyWith => _$SummaryStatusDtoCopyWithImpl<SummaryStatusDto>(this as SummaryStatusDto, _$identity);

  /// Serializes this SummaryStatusDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SummaryStatusDto&&(identical(other.id, id) || other.id == id)&&(identical(other.summaryStatus, summaryStatus) || other.summaryStatus == summaryStatus));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,summaryStatus);

@override
String toString() {
  return 'SummaryStatusDto(id: $id, summaryStatus: $summaryStatus)';
}


}

/// @nodoc
abstract mixin class $SummaryStatusDtoCopyWith<$Res>  {
  factory $SummaryStatusDtoCopyWith(SummaryStatusDto value, $Res Function(SummaryStatusDto) _then) = _$SummaryStatusDtoCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'summary_status') String summaryStatus
});




}
/// @nodoc
class _$SummaryStatusDtoCopyWithImpl<$Res>
    implements $SummaryStatusDtoCopyWith<$Res> {
  _$SummaryStatusDtoCopyWithImpl(this._self, this._then);

  final SummaryStatusDto _self;
  final $Res Function(SummaryStatusDto) _then;

/// Create a copy of SummaryStatusDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? summaryStatus = null,}) {
  return _then(SummaryStatusDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,summaryStatus: null == summaryStatus ? _self.summaryStatus : summaryStatus // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [SummaryStatusDto].
extension SummaryStatusDtoPatterns on SummaryStatusDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SummaryStatusDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SummaryStatusDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SummaryStatusDto value)  $default,){
final _that = this;
switch (_that) {
case _SummaryStatusDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SummaryStatusDto value)?  $default,){
final _that = this;
switch (_that) {
case _SummaryStatusDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'summary_status')  String summaryStatus)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SummaryStatusDto() when $default != null:
return $default(_that.id,_that.summaryStatus);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'summary_status')  String summaryStatus)  $default,) {final _that = this;
switch (_that) {
case _SummaryStatusDto():
return $default(_that.id,_that.summaryStatus);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'summary_status')  String summaryStatus)?  $default,) {final _that = this;
switch (_that) {
case _SummaryStatusDto() when $default != null:
return $default(_that.id,_that.summaryStatus);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SummaryStatusDto implements SummaryStatusDto {
  const _SummaryStatusDto({required this.id, @JsonKey(name: 'summary_status') required this.summaryStatus});
  factory _SummaryStatusDto.fromJson(Map<String, dynamic> json) => _$SummaryStatusDtoFromJson(json);

@override final  String id;
@override@JsonKey(name: 'summary_status') final  String summaryStatus;

/// Create a copy of SummaryStatusDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SummaryStatusDtoCopyWith<_SummaryStatusDto> get copyWith => __$SummaryStatusDtoCopyWithImpl<_SummaryStatusDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SummaryStatusDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SummaryStatusDto&&(identical(other.id, id) || other.id == id)&&(identical(other.summaryStatus, summaryStatus) || other.summaryStatus == summaryStatus));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,summaryStatus);

@override
String toString() {
  return 'SummaryStatusDto(id: $id, summaryStatus: $summaryStatus)';
}


}

/// @nodoc
abstract mixin class _$SummaryStatusDtoCopyWith<$Res> implements $SummaryStatusDtoCopyWith<$Res> {
  factory _$SummaryStatusDtoCopyWith(_SummaryStatusDto value, $Res Function(_SummaryStatusDto) _then) = __$SummaryStatusDtoCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'summary_status') String summaryStatus
});




}
/// @nodoc
class __$SummaryStatusDtoCopyWithImpl<$Res>
    implements _$SummaryStatusDtoCopyWith<$Res> {
  __$SummaryStatusDtoCopyWithImpl(this._self, this._then);

  final _SummaryStatusDto _self;
  final $Res Function(_SummaryStatusDto) _then;

/// Create a copy of SummaryStatusDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? summaryStatus = null,}) {
  return _then(_SummaryStatusDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,summaryStatus: null == summaryStatus ? _self.summaryStatus : summaryStatus // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$TranslationRequestDto {

@JsonKey(name: 'source_lang') String get sourceLang;@JsonKey(name: 'target_lang') String get targetLang;
/// Create a copy of TranslationRequestDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TranslationRequestDtoCopyWith<TranslationRequestDto> get copyWith => _$TranslationRequestDtoCopyWithImpl<TranslationRequestDto>(this as TranslationRequestDto, _$identity);

  /// Serializes this TranslationRequestDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TranslationRequestDto&&(identical(other.sourceLang, sourceLang) || other.sourceLang == sourceLang)&&(identical(other.targetLang, targetLang) || other.targetLang == targetLang));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,sourceLang,targetLang);

@override
String toString() {
  return 'TranslationRequestDto(sourceLang: $sourceLang, targetLang: $targetLang)';
}


}

/// @nodoc
abstract mixin class $TranslationRequestDtoCopyWith<$Res>  {
  factory $TranslationRequestDtoCopyWith(TranslationRequestDto value, $Res Function(TranslationRequestDto) _then) = _$TranslationRequestDtoCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'source_lang') String sourceLang,@JsonKey(name: 'target_lang') String targetLang
});




}
/// @nodoc
class _$TranslationRequestDtoCopyWithImpl<$Res>
    implements $TranslationRequestDtoCopyWith<$Res> {
  _$TranslationRequestDtoCopyWithImpl(this._self, this._then);

  final TranslationRequestDto _self;
  final $Res Function(TranslationRequestDto) _then;

/// Create a copy of TranslationRequestDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? sourceLang = null,Object? targetLang = null,}) {
  return _then(TranslationRequestDto(
sourceLang: null == sourceLang ? _self.sourceLang : sourceLang // ignore: cast_nullable_to_non_nullable
as String,targetLang: null == targetLang ? _self.targetLang : targetLang // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [TranslationRequestDto].
extension TranslationRequestDtoPatterns on TranslationRequestDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TranslationRequestDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TranslationRequestDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TranslationRequestDto value)  $default,){
final _that = this;
switch (_that) {
case _TranslationRequestDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TranslationRequestDto value)?  $default,){
final _that = this;
switch (_that) {
case _TranslationRequestDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'source_lang')  String sourceLang, @JsonKey(name: 'target_lang')  String targetLang)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TranslationRequestDto() when $default != null:
return $default(_that.sourceLang,_that.targetLang);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'source_lang')  String sourceLang, @JsonKey(name: 'target_lang')  String targetLang)  $default,) {final _that = this;
switch (_that) {
case _TranslationRequestDto():
return $default(_that.sourceLang,_that.targetLang);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'source_lang')  String sourceLang, @JsonKey(name: 'target_lang')  String targetLang)?  $default,) {final _that = this;
switch (_that) {
case _TranslationRequestDto() when $default != null:
return $default(_that.sourceLang,_that.targetLang);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TranslationRequestDto implements TranslationRequestDto {
  const _TranslationRequestDto({@JsonKey(name: 'source_lang') required this.sourceLang, @JsonKey(name: 'target_lang') required this.targetLang});
  factory _TranslationRequestDto.fromJson(Map<String, dynamic> json) => _$TranslationRequestDtoFromJson(json);

@override@JsonKey(name: 'source_lang') final  String sourceLang;
@override@JsonKey(name: 'target_lang') final  String targetLang;

/// Create a copy of TranslationRequestDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TranslationRequestDtoCopyWith<_TranslationRequestDto> get copyWith => __$TranslationRequestDtoCopyWithImpl<_TranslationRequestDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TranslationRequestDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TranslationRequestDto&&(identical(other.sourceLang, sourceLang) || other.sourceLang == sourceLang)&&(identical(other.targetLang, targetLang) || other.targetLang == targetLang));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,sourceLang,targetLang);

@override
String toString() {
  return 'TranslationRequestDto(sourceLang: $sourceLang, targetLang: $targetLang)';
}


}

/// @nodoc
abstract mixin class _$TranslationRequestDtoCopyWith<$Res> implements $TranslationRequestDtoCopyWith<$Res> {
  factory _$TranslationRequestDtoCopyWith(_TranslationRequestDto value, $Res Function(_TranslationRequestDto) _then) = __$TranslationRequestDtoCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'source_lang') String sourceLang,@JsonKey(name: 'target_lang') String targetLang
});




}
/// @nodoc
class __$TranslationRequestDtoCopyWithImpl<$Res>
    implements _$TranslationRequestDtoCopyWith<$Res> {
  __$TranslationRequestDtoCopyWithImpl(this._self, this._then);

  final _TranslationRequestDto _self;
  final $Res Function(_TranslationRequestDto) _then;

/// Create a copy of TranslationRequestDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? sourceLang = null,Object? targetLang = null,}) {
  return _then(_TranslationRequestDto(
sourceLang: null == sourceLang ? _self.sourceLang : sourceLang // ignore: cast_nullable_to_non_nullable
as String,targetLang: null == targetLang ? _self.targetLang : targetLang // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$TranslationStatusDto {

 String get id;@JsonKey(name: 'translation_status') String get translationStatus;@JsonKey(name: 'source_lang') String? get sourceLang;@JsonKey(name: 'target_lang') String? get targetLang;
/// Create a copy of TranslationStatusDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TranslationStatusDtoCopyWith<TranslationStatusDto> get copyWith => _$TranslationStatusDtoCopyWithImpl<TranslationStatusDto>(this as TranslationStatusDto, _$identity);

  /// Serializes this TranslationStatusDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TranslationStatusDto&&(identical(other.id, id) || other.id == id)&&(identical(other.translationStatus, translationStatus) || other.translationStatus == translationStatus)&&(identical(other.sourceLang, sourceLang) || other.sourceLang == sourceLang)&&(identical(other.targetLang, targetLang) || other.targetLang == targetLang));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,translationStatus,sourceLang,targetLang);

@override
String toString() {
  return 'TranslationStatusDto(id: $id, translationStatus: $translationStatus, sourceLang: $sourceLang, targetLang: $targetLang)';
}


}

/// @nodoc
abstract mixin class $TranslationStatusDtoCopyWith<$Res>  {
  factory $TranslationStatusDtoCopyWith(TranslationStatusDto value, $Res Function(TranslationStatusDto) _then) = _$TranslationStatusDtoCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'translation_status') String translationStatus,@JsonKey(name: 'source_lang') String? sourceLang,@JsonKey(name: 'target_lang') String? targetLang
});




}
/// @nodoc
class _$TranslationStatusDtoCopyWithImpl<$Res>
    implements $TranslationStatusDtoCopyWith<$Res> {
  _$TranslationStatusDtoCopyWithImpl(this._self, this._then);

  final TranslationStatusDto _self;
  final $Res Function(TranslationStatusDto) _then;

/// Create a copy of TranslationStatusDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? translationStatus = null,Object? sourceLang = freezed,Object? targetLang = freezed,}) {
  return _then(TranslationStatusDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,translationStatus: null == translationStatus ? _self.translationStatus : translationStatus // ignore: cast_nullable_to_non_nullable
as String,sourceLang: freezed == sourceLang ? _self.sourceLang : sourceLang // ignore: cast_nullable_to_non_nullable
as String?,targetLang: freezed == targetLang ? _self.targetLang : targetLang // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [TranslationStatusDto].
extension TranslationStatusDtoPatterns on TranslationStatusDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TranslationStatusDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TranslationStatusDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TranslationStatusDto value)  $default,){
final _that = this;
switch (_that) {
case _TranslationStatusDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TranslationStatusDto value)?  $default,){
final _that = this;
switch (_that) {
case _TranslationStatusDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'translation_status')  String translationStatus, @JsonKey(name: 'source_lang')  String? sourceLang, @JsonKey(name: 'target_lang')  String? targetLang)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TranslationStatusDto() when $default != null:
return $default(_that.id,_that.translationStatus,_that.sourceLang,_that.targetLang);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'translation_status')  String translationStatus, @JsonKey(name: 'source_lang')  String? sourceLang, @JsonKey(name: 'target_lang')  String? targetLang)  $default,) {final _that = this;
switch (_that) {
case _TranslationStatusDto():
return $default(_that.id,_that.translationStatus,_that.sourceLang,_that.targetLang);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'translation_status')  String translationStatus, @JsonKey(name: 'source_lang')  String? sourceLang, @JsonKey(name: 'target_lang')  String? targetLang)?  $default,) {final _that = this;
switch (_that) {
case _TranslationStatusDto() when $default != null:
return $default(_that.id,_that.translationStatus,_that.sourceLang,_that.targetLang);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TranslationStatusDto implements TranslationStatusDto {
  const _TranslationStatusDto({required this.id, @JsonKey(name: 'translation_status') required this.translationStatus, @JsonKey(name: 'source_lang') this.sourceLang, @JsonKey(name: 'target_lang') this.targetLang});
  factory _TranslationStatusDto.fromJson(Map<String, dynamic> json) => _$TranslationStatusDtoFromJson(json);

@override final  String id;
@override@JsonKey(name: 'translation_status') final  String translationStatus;
@override@JsonKey(name: 'source_lang') final  String? sourceLang;
@override@JsonKey(name: 'target_lang') final  String? targetLang;

/// Create a copy of TranslationStatusDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TranslationStatusDtoCopyWith<_TranslationStatusDto> get copyWith => __$TranslationStatusDtoCopyWithImpl<_TranslationStatusDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TranslationStatusDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TranslationStatusDto&&(identical(other.id, id) || other.id == id)&&(identical(other.translationStatus, translationStatus) || other.translationStatus == translationStatus)&&(identical(other.sourceLang, sourceLang) || other.sourceLang == sourceLang)&&(identical(other.targetLang, targetLang) || other.targetLang == targetLang));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,translationStatus,sourceLang,targetLang);

@override
String toString() {
  return 'TranslationStatusDto(id: $id, translationStatus: $translationStatus, sourceLang: $sourceLang, targetLang: $targetLang)';
}


}

/// @nodoc
abstract mixin class _$TranslationStatusDtoCopyWith<$Res> implements $TranslationStatusDtoCopyWith<$Res> {
  factory _$TranslationStatusDtoCopyWith(_TranslationStatusDto value, $Res Function(_TranslationStatusDto) _then) = __$TranslationStatusDtoCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'translation_status') String translationStatus,@JsonKey(name: 'source_lang') String? sourceLang,@JsonKey(name: 'target_lang') String? targetLang
});




}
/// @nodoc
class __$TranslationStatusDtoCopyWithImpl<$Res>
    implements _$TranslationStatusDtoCopyWith<$Res> {
  __$TranslationStatusDtoCopyWithImpl(this._self, this._then);

  final _TranslationStatusDto _self;
  final $Res Function(_TranslationStatusDto) _then;

/// Create a copy of TranslationStatusDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? translationStatus = null,Object? sourceLang = freezed,Object? targetLang = freezed,}) {
  return _then(_TranslationStatusDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,translationStatus: null == translationStatus ? _self.translationStatus : translationStatus // ignore: cast_nullable_to_non_nullable
as String,sourceLang: freezed == sourceLang ? _self.sourceLang : sourceLang // ignore: cast_nullable_to_non_nullable
as String?,targetLang: freezed == targetLang ? _self.targetLang : targetLang // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$CitationDto {

@JsonKey(name: 'chunk_id') String? get chunkId; int? get index; String? get snippet; int? get page; String? get label;
/// Create a copy of CitationDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CitationDtoCopyWith<CitationDto> get copyWith => _$CitationDtoCopyWithImpl<CitationDto>(this as CitationDto, _$identity);

  /// Serializes this CitationDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CitationDto&&(identical(other.chunkId, chunkId) || other.chunkId == chunkId)&&(identical(other.index, index) || other.index == index)&&(identical(other.snippet, snippet) || other.snippet == snippet)&&(identical(other.page, page) || other.page == page)&&(identical(other.label, label) || other.label == label));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,chunkId,index,snippet,page,label);

@override
String toString() {
  return 'CitationDto(chunkId: $chunkId, index: $index, snippet: $snippet, page: $page, label: $label)';
}


}

/// @nodoc
abstract mixin class $CitationDtoCopyWith<$Res>  {
  factory $CitationDtoCopyWith(CitationDto value, $Res Function(CitationDto) _then) = _$CitationDtoCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'chunk_id') String? chunkId, int? index, String? snippet, int? page, String? label
});




}
/// @nodoc
class _$CitationDtoCopyWithImpl<$Res>
    implements $CitationDtoCopyWith<$Res> {
  _$CitationDtoCopyWithImpl(this._self, this._then);

  final CitationDto _self;
  final $Res Function(CitationDto) _then;

/// Create a copy of CitationDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? chunkId = freezed,Object? index = freezed,Object? snippet = freezed,Object? page = freezed,Object? label = freezed,}) {
  return _then(CitationDto(
chunkId: freezed == chunkId ? _self.chunkId : chunkId // ignore: cast_nullable_to_non_nullable
as String?,index: freezed == index ? _self.index : index // ignore: cast_nullable_to_non_nullable
as int?,snippet: freezed == snippet ? _self.snippet : snippet // ignore: cast_nullable_to_non_nullable
as String?,page: freezed == page ? _self.page : page // ignore: cast_nullable_to_non_nullable
as int?,label: freezed == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [CitationDto].
extension CitationDtoPatterns on CitationDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CitationDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CitationDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CitationDto value)  $default,){
final _that = this;
switch (_that) {
case _CitationDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CitationDto value)?  $default,){
final _that = this;
switch (_that) {
case _CitationDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'chunk_id')  String? chunkId,  int? index,  String? snippet,  int? page,  String? label)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CitationDto() when $default != null:
return $default(_that.chunkId,_that.index,_that.snippet,_that.page,_that.label);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'chunk_id')  String? chunkId,  int? index,  String? snippet,  int? page,  String? label)  $default,) {final _that = this;
switch (_that) {
case _CitationDto():
return $default(_that.chunkId,_that.index,_that.snippet,_that.page,_that.label);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'chunk_id')  String? chunkId,  int? index,  String? snippet,  int? page,  String? label)?  $default,) {final _that = this;
switch (_that) {
case _CitationDto() when $default != null:
return $default(_that.chunkId,_that.index,_that.snippet,_that.page,_that.label);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CitationDto implements CitationDto {
  const _CitationDto({@JsonKey(name: 'chunk_id') this.chunkId, this.index, this.snippet, this.page, this.label});
  factory _CitationDto.fromJson(Map<String, dynamic> json) => _$CitationDtoFromJson(json);

@override@JsonKey(name: 'chunk_id') final  String? chunkId;
@override final  int? index;
@override final  String? snippet;
@override final  int? page;
@override final  String? label;

/// Create a copy of CitationDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CitationDtoCopyWith<_CitationDto> get copyWith => __$CitationDtoCopyWithImpl<_CitationDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CitationDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CitationDto&&(identical(other.chunkId, chunkId) || other.chunkId == chunkId)&&(identical(other.index, index) || other.index == index)&&(identical(other.snippet, snippet) || other.snippet == snippet)&&(identical(other.page, page) || other.page == page)&&(identical(other.label, label) || other.label == label));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,chunkId,index,snippet,page,label);

@override
String toString() {
  return 'CitationDto(chunkId: $chunkId, index: $index, snippet: $snippet, page: $page, label: $label)';
}


}

/// @nodoc
abstract mixin class _$CitationDtoCopyWith<$Res> implements $CitationDtoCopyWith<$Res> {
  factory _$CitationDtoCopyWith(_CitationDto value, $Res Function(_CitationDto) _then) = __$CitationDtoCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'chunk_id') String? chunkId, int? index, String? snippet, int? page, String? label
});




}
/// @nodoc
class __$CitationDtoCopyWithImpl<$Res>
    implements _$CitationDtoCopyWith<$Res> {
  __$CitationDtoCopyWithImpl(this._self, this._then);

  final _CitationDto _self;
  final $Res Function(_CitationDto) _then;

/// Create a copy of CitationDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? chunkId = freezed,Object? index = freezed,Object? snippet = freezed,Object? page = freezed,Object? label = freezed,}) {
  return _then(_CitationDto(
chunkId: freezed == chunkId ? _self.chunkId : chunkId // ignore: cast_nullable_to_non_nullable
as String?,index: freezed == index ? _self.index : index // ignore: cast_nullable_to_non_nullable
as int?,snippet: freezed == snippet ? _self.snippet : snippet // ignore: cast_nullable_to_non_nullable
as String?,page: freezed == page ? _self.page : page // ignore: cast_nullable_to_non_nullable
as int?,label: freezed == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$ChatDto {

 String get id;@JsonKey(name: 'user_id') String get userId;@JsonKey(name: 'document_id') String get documentId;@JsonKey(name: 'created_at') DateTime? get createdAt;@JsonKey(name: 'updated_at') DateTime? get updatedAt;
/// Create a copy of ChatDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChatDtoCopyWith<ChatDto> get copyWith => _$ChatDtoCopyWithImpl<ChatDto>(this as ChatDto, _$identity);

  /// Serializes this ChatDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChatDto&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.documentId, documentId) || other.documentId == documentId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,documentId,createdAt,updatedAt);

@override
String toString() {
  return 'ChatDto(id: $id, userId: $userId, documentId: $documentId, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $ChatDtoCopyWith<$Res>  {
  factory $ChatDtoCopyWith(ChatDto value, $Res Function(ChatDto) _then) = _$ChatDtoCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'user_id') String userId,@JsonKey(name: 'document_id') String documentId,@JsonKey(name: 'created_at') DateTime? createdAt,@JsonKey(name: 'updated_at') DateTime? updatedAt
});




}
/// @nodoc
class _$ChatDtoCopyWithImpl<$Res>
    implements $ChatDtoCopyWith<$Res> {
  _$ChatDtoCopyWithImpl(this._self, this._then);

  final ChatDto _self;
  final $Res Function(ChatDto) _then;

/// Create a copy of ChatDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? userId = null,Object? documentId = null,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(ChatDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,documentId: null == documentId ? _self.documentId : documentId // ignore: cast_nullable_to_non_nullable
as String,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [ChatDto].
extension ChatDtoPatterns on ChatDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ChatDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ChatDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ChatDto value)  $default,){
final _that = this;
switch (_that) {
case _ChatDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ChatDto value)?  $default,){
final _that = this;
switch (_that) {
case _ChatDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'user_id')  String userId, @JsonKey(name: 'document_id')  String documentId, @JsonKey(name: 'created_at')  DateTime? createdAt, @JsonKey(name: 'updated_at')  DateTime? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ChatDto() when $default != null:
return $default(_that.id,_that.userId,_that.documentId,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'user_id')  String userId, @JsonKey(name: 'document_id')  String documentId, @JsonKey(name: 'created_at')  DateTime? createdAt, @JsonKey(name: 'updated_at')  DateTime? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _ChatDto():
return $default(_that.id,_that.userId,_that.documentId,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'user_id')  String userId, @JsonKey(name: 'document_id')  String documentId, @JsonKey(name: 'created_at')  DateTime? createdAt, @JsonKey(name: 'updated_at')  DateTime? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _ChatDto() when $default != null:
return $default(_that.id,_that.userId,_that.documentId,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ChatDto implements ChatDto {
  const _ChatDto({required this.id, @JsonKey(name: 'user_id') required this.userId, @JsonKey(name: 'document_id') required this.documentId, @JsonKey(name: 'created_at') this.createdAt, @JsonKey(name: 'updated_at') this.updatedAt});
  factory _ChatDto.fromJson(Map<String, dynamic> json) => _$ChatDtoFromJson(json);

@override final  String id;
@override@JsonKey(name: 'user_id') final  String userId;
@override@JsonKey(name: 'document_id') final  String documentId;
@override@JsonKey(name: 'created_at') final  DateTime? createdAt;
@override@JsonKey(name: 'updated_at') final  DateTime? updatedAt;

/// Create a copy of ChatDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ChatDtoCopyWith<_ChatDto> get copyWith => __$ChatDtoCopyWithImpl<_ChatDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ChatDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ChatDto&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.documentId, documentId) || other.documentId == documentId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,documentId,createdAt,updatedAt);

@override
String toString() {
  return 'ChatDto(id: $id, userId: $userId, documentId: $documentId, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$ChatDtoCopyWith<$Res> implements $ChatDtoCopyWith<$Res> {
  factory _$ChatDtoCopyWith(_ChatDto value, $Res Function(_ChatDto) _then) = __$ChatDtoCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'user_id') String userId,@JsonKey(name: 'document_id') String documentId,@JsonKey(name: 'created_at') DateTime? createdAt,@JsonKey(name: 'updated_at') DateTime? updatedAt
});




}
/// @nodoc
class __$ChatDtoCopyWithImpl<$Res>
    implements _$ChatDtoCopyWith<$Res> {
  __$ChatDtoCopyWithImpl(this._self, this._then);

  final _ChatDto _self;
  final $Res Function(_ChatDto) _then;

/// Create a copy of ChatDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? userId = null,Object? documentId = null,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_ChatDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,documentId: null == documentId ? _self.documentId : documentId // ignore: cast_nullable_to_non_nullable
as String,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}


/// @nodoc
mixin _$ChatMessageDto {

 String get id;@JsonKey(name: 'chat_id') String get chatId; String get role; String get content; List<CitationDto>? get citations;@JsonKey(name: 'created_at') DateTime? get createdAt;
/// Create a copy of ChatMessageDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChatMessageDtoCopyWith<ChatMessageDto> get copyWith => _$ChatMessageDtoCopyWithImpl<ChatMessageDto>(this as ChatMessageDto, _$identity);

  /// Serializes this ChatMessageDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChatMessageDto&&(identical(other.id, id) || other.id == id)&&(identical(other.chatId, chatId) || other.chatId == chatId)&&(identical(other.role, role) || other.role == role)&&(identical(other.content, content) || other.content == content)&&const DeepCollectionEquality().equals(other.citations, citations)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,chatId,role,content,const DeepCollectionEquality().hash(citations),createdAt);

@override
String toString() {
  return 'ChatMessageDto(id: $id, chatId: $chatId, role: $role, content: $content, citations: $citations, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $ChatMessageDtoCopyWith<$Res>  {
  factory $ChatMessageDtoCopyWith(ChatMessageDto value, $Res Function(ChatMessageDto) _then) = _$ChatMessageDtoCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'chat_id') String chatId, String role, String content, List<CitationDto>? citations,@JsonKey(name: 'created_at') DateTime? createdAt
});




}
/// @nodoc
class _$ChatMessageDtoCopyWithImpl<$Res>
    implements $ChatMessageDtoCopyWith<$Res> {
  _$ChatMessageDtoCopyWithImpl(this._self, this._then);

  final ChatMessageDto _self;
  final $Res Function(ChatMessageDto) _then;

/// Create a copy of ChatMessageDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? chatId = null,Object? role = null,Object? content = null,Object? citations = freezed,Object? createdAt = freezed,}) {
  return _then(ChatMessageDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,chatId: null == chatId ? _self.chatId : chatId // ignore: cast_nullable_to_non_nullable
as String,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as String,content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String,citations: freezed == citations ? _self.citations : citations // ignore: cast_nullable_to_non_nullable
as List<CitationDto>?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [ChatMessageDto].
extension ChatMessageDtoPatterns on ChatMessageDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ChatMessageDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ChatMessageDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ChatMessageDto value)  $default,){
final _that = this;
switch (_that) {
case _ChatMessageDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ChatMessageDto value)?  $default,){
final _that = this;
switch (_that) {
case _ChatMessageDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'chat_id')  String chatId,  String role,  String content,  List<CitationDto>? citations, @JsonKey(name: 'created_at')  DateTime? createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ChatMessageDto() when $default != null:
return $default(_that.id,_that.chatId,_that.role,_that.content,_that.citations,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'chat_id')  String chatId,  String role,  String content,  List<CitationDto>? citations, @JsonKey(name: 'created_at')  DateTime? createdAt)  $default,) {final _that = this;
switch (_that) {
case _ChatMessageDto():
return $default(_that.id,_that.chatId,_that.role,_that.content,_that.citations,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'chat_id')  String chatId,  String role,  String content,  List<CitationDto>? citations, @JsonKey(name: 'created_at')  DateTime? createdAt)?  $default,) {final _that = this;
switch (_that) {
case _ChatMessageDto() when $default != null:
return $default(_that.id,_that.chatId,_that.role,_that.content,_that.citations,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ChatMessageDto implements ChatMessageDto {
  const _ChatMessageDto({required this.id, @JsonKey(name: 'chat_id') required this.chatId, required this.role, required this.content,  List<CitationDto>? citations, @JsonKey(name: 'created_at') this.createdAt}): _citations = citations;
  factory _ChatMessageDto.fromJson(Map<String, dynamic> json) => _$ChatMessageDtoFromJson(json);

@override final  String id;
@override@JsonKey(name: 'chat_id') final  String chatId;
@override final  String role;
@override final  String content;
 final  List<CitationDto>? _citations;
@override List<CitationDto>? get citations {
  final value = _citations;
  if (value == null) return null;
  if (_citations is EqualUnmodifiableListView) return _citations;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

@override@JsonKey(name: 'created_at') final  DateTime? createdAt;

/// Create a copy of ChatMessageDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ChatMessageDtoCopyWith<_ChatMessageDto> get copyWith => __$ChatMessageDtoCopyWithImpl<_ChatMessageDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ChatMessageDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ChatMessageDto&&(identical(other.id, id) || other.id == id)&&(identical(other.chatId, chatId) || other.chatId == chatId)&&(identical(other.role, role) || other.role == role)&&(identical(other.content, content) || other.content == content)&&const DeepCollectionEquality().equals(other._citations, _citations)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,chatId,role,content,const DeepCollectionEquality().hash(_citations),createdAt);

@override
String toString() {
  return 'ChatMessageDto(id: $id, chatId: $chatId, role: $role, content: $content, citations: $citations, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$ChatMessageDtoCopyWith<$Res> implements $ChatMessageDtoCopyWith<$Res> {
  factory _$ChatMessageDtoCopyWith(_ChatMessageDto value, $Res Function(_ChatMessageDto) _then) = __$ChatMessageDtoCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'chat_id') String chatId, String role, String content, List<CitationDto>? citations,@JsonKey(name: 'created_at') DateTime? createdAt
});




}
/// @nodoc
class __$ChatMessageDtoCopyWithImpl<$Res>
    implements _$ChatMessageDtoCopyWith<$Res> {
  __$ChatMessageDtoCopyWithImpl(this._self, this._then);

  final _ChatMessageDto _self;
  final $Res Function(_ChatMessageDto) _then;

/// Create a copy of ChatMessageDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? chatId = null,Object? role = null,Object? content = null,Object? citations = freezed,Object? createdAt = freezed,}) {
  return _then(_ChatMessageDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,chatId: null == chatId ? _self.chatId : chatId // ignore: cast_nullable_to_non_nullable
as String,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as String,content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String,citations: freezed == citations ? _self._citations : citations // ignore: cast_nullable_to_non_nullable
as List<CitationDto>?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}


/// @nodoc
mixin _$ChatMessageListDto {

 List<ChatMessageDto> get items;
/// Create a copy of ChatMessageListDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChatMessageListDtoCopyWith<ChatMessageListDto> get copyWith => _$ChatMessageListDtoCopyWithImpl<ChatMessageListDto>(this as ChatMessageListDto, _$identity);

  /// Serializes this ChatMessageListDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChatMessageListDto&&const DeepCollectionEquality().equals(other.items, items));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(items));

@override
String toString() {
  return 'ChatMessageListDto(items: $items)';
}


}

/// @nodoc
abstract mixin class $ChatMessageListDtoCopyWith<$Res>  {
  factory $ChatMessageListDtoCopyWith(ChatMessageListDto value, $Res Function(ChatMessageListDto) _then) = _$ChatMessageListDtoCopyWithImpl;
@useResult
$Res call({
 List<ChatMessageDto> items
});




}
/// @nodoc
class _$ChatMessageListDtoCopyWithImpl<$Res>
    implements $ChatMessageListDtoCopyWith<$Res> {
  _$ChatMessageListDtoCopyWithImpl(this._self, this._then);

  final ChatMessageListDto _self;
  final $Res Function(ChatMessageListDto) _then;

/// Create a copy of ChatMessageListDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? items = null,}) {
  return _then(ChatMessageListDto(
items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<ChatMessageDto>,
  ));
}

}


/// Adds pattern-matching-related methods to [ChatMessageListDto].
extension ChatMessageListDtoPatterns on ChatMessageListDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ChatMessageListDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ChatMessageListDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ChatMessageListDto value)  $default,){
final _that = this;
switch (_that) {
case _ChatMessageListDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ChatMessageListDto value)?  $default,){
final _that = this;
switch (_that) {
case _ChatMessageListDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<ChatMessageDto> items)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ChatMessageListDto() when $default != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<ChatMessageDto> items)  $default,) {final _that = this;
switch (_that) {
case _ChatMessageListDto():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<ChatMessageDto> items)?  $default,) {final _that = this;
switch (_that) {
case _ChatMessageListDto() when $default != null:
return $default(_that.items);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ChatMessageListDto implements ChatMessageListDto {
  const _ChatMessageListDto({ List<ChatMessageDto> items = const []}): _items = items;
  factory _ChatMessageListDto.fromJson(Map<String, dynamic> json) => _$ChatMessageListDtoFromJson(json);

 final  List<ChatMessageDto> _items;
@override@JsonKey() List<ChatMessageDto> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}


/// Create a copy of ChatMessageListDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ChatMessageListDtoCopyWith<_ChatMessageListDto> get copyWith => __$ChatMessageListDtoCopyWithImpl<_ChatMessageListDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ChatMessageListDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ChatMessageListDto&&const DeepCollectionEquality().equals(other._items, _items));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_items));

@override
String toString() {
  return 'ChatMessageListDto(items: $items)';
}


}

/// @nodoc
abstract mixin class _$ChatMessageListDtoCopyWith<$Res> implements $ChatMessageListDtoCopyWith<$Res> {
  factory _$ChatMessageListDtoCopyWith(_ChatMessageListDto value, $Res Function(_ChatMessageListDto) _then) = __$ChatMessageListDtoCopyWithImpl;
@override @useResult
$Res call({
 List<ChatMessageDto> items
});




}
/// @nodoc
class __$ChatMessageListDtoCopyWithImpl<$Res>
    implements _$ChatMessageListDtoCopyWith<$Res> {
  __$ChatMessageListDtoCopyWithImpl(this._self, this._then);

  final _ChatMessageListDto _self;
  final $Res Function(_ChatMessageListDto) _then;

/// Create a copy of ChatMessageListDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? items = null,}) {
  return _then(_ChatMessageListDto(
items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<ChatMessageDto>,
  ));
}


}


/// @nodoc
mixin _$ChatMessageCreateDto {

 String get content;
/// Create a copy of ChatMessageCreateDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChatMessageCreateDtoCopyWith<ChatMessageCreateDto> get copyWith => _$ChatMessageCreateDtoCopyWithImpl<ChatMessageCreateDto>(this as ChatMessageCreateDto, _$identity);

  /// Serializes this ChatMessageCreateDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChatMessageCreateDto&&(identical(other.content, content) || other.content == content));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,content);

@override
String toString() {
  return 'ChatMessageCreateDto(content: $content)';
}


}

/// @nodoc
abstract mixin class $ChatMessageCreateDtoCopyWith<$Res>  {
  factory $ChatMessageCreateDtoCopyWith(ChatMessageCreateDto value, $Res Function(ChatMessageCreateDto) _then) = _$ChatMessageCreateDtoCopyWithImpl;
@useResult
$Res call({
 String content
});




}
/// @nodoc
class _$ChatMessageCreateDtoCopyWithImpl<$Res>
    implements $ChatMessageCreateDtoCopyWith<$Res> {
  _$ChatMessageCreateDtoCopyWithImpl(this._self, this._then);

  final ChatMessageCreateDto _self;
  final $Res Function(ChatMessageCreateDto) _then;

/// Create a copy of ChatMessageCreateDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? content = null,}) {
  return _then(ChatMessageCreateDto(
content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [ChatMessageCreateDto].
extension ChatMessageCreateDtoPatterns on ChatMessageCreateDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ChatMessageCreateDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ChatMessageCreateDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ChatMessageCreateDto value)  $default,){
final _that = this;
switch (_that) {
case _ChatMessageCreateDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ChatMessageCreateDto value)?  $default,){
final _that = this;
switch (_that) {
case _ChatMessageCreateDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String content)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ChatMessageCreateDto() when $default != null:
return $default(_that.content);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String content)  $default,) {final _that = this;
switch (_that) {
case _ChatMessageCreateDto():
return $default(_that.content);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String content)?  $default,) {final _that = this;
switch (_that) {
case _ChatMessageCreateDto() when $default != null:
return $default(_that.content);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ChatMessageCreateDto implements ChatMessageCreateDto {
  const _ChatMessageCreateDto({required this.content});
  factory _ChatMessageCreateDto.fromJson(Map<String, dynamic> json) => _$ChatMessageCreateDtoFromJson(json);

@override final  String content;

/// Create a copy of ChatMessageCreateDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ChatMessageCreateDtoCopyWith<_ChatMessageCreateDto> get copyWith => __$ChatMessageCreateDtoCopyWithImpl<_ChatMessageCreateDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ChatMessageCreateDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ChatMessageCreateDto&&(identical(other.content, content) || other.content == content));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,content);

@override
String toString() {
  return 'ChatMessageCreateDto(content: $content)';
}


}

/// @nodoc
abstract mixin class _$ChatMessageCreateDtoCopyWith<$Res> implements $ChatMessageCreateDtoCopyWith<$Res> {
  factory _$ChatMessageCreateDtoCopyWith(_ChatMessageCreateDto value, $Res Function(_ChatMessageCreateDto) _then) = __$ChatMessageCreateDtoCopyWithImpl;
@override @useResult
$Res call({
 String content
});




}
/// @nodoc
class __$ChatMessageCreateDtoCopyWithImpl<$Res>
    implements _$ChatMessageCreateDtoCopyWith<$Res> {
  __$ChatMessageCreateDtoCopyWithImpl(this._self, this._then);

  final _ChatMessageCreateDto _self;
  final $Res Function(_ChatMessageCreateDto) _then;

/// Create a copy of ChatMessageCreateDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? content = null,}) {
  return _then(_ChatMessageCreateDto(
content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$ExportRequestDto {

@JsonKey(name: 'include_summary') bool get includeSummary;@JsonKey(name: 'include_translation') bool get includeTranslation;@JsonKey(name: 'include_chat') bool get includeChat;
/// Create a copy of ExportRequestDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ExportRequestDtoCopyWith<ExportRequestDto> get copyWith => _$ExportRequestDtoCopyWithImpl<ExportRequestDto>(this as ExportRequestDto, _$identity);

  /// Serializes this ExportRequestDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ExportRequestDto&&(identical(other.includeSummary, includeSummary) || other.includeSummary == includeSummary)&&(identical(other.includeTranslation, includeTranslation) || other.includeTranslation == includeTranslation)&&(identical(other.includeChat, includeChat) || other.includeChat == includeChat));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,includeSummary,includeTranslation,includeChat);

@override
String toString() {
  return 'ExportRequestDto(includeSummary: $includeSummary, includeTranslation: $includeTranslation, includeChat: $includeChat)';
}


}

/// @nodoc
abstract mixin class $ExportRequestDtoCopyWith<$Res>  {
  factory $ExportRequestDtoCopyWith(ExportRequestDto value, $Res Function(ExportRequestDto) _then) = _$ExportRequestDtoCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'include_summary') bool includeSummary,@JsonKey(name: 'include_translation') bool includeTranslation,@JsonKey(name: 'include_chat') bool includeChat
});




}
/// @nodoc
class _$ExportRequestDtoCopyWithImpl<$Res>
    implements $ExportRequestDtoCopyWith<$Res> {
  _$ExportRequestDtoCopyWithImpl(this._self, this._then);

  final ExportRequestDto _self;
  final $Res Function(ExportRequestDto) _then;

/// Create a copy of ExportRequestDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? includeSummary = null,Object? includeTranslation = null,Object? includeChat = null,}) {
  return _then(ExportRequestDto(
includeSummary: null == includeSummary ? _self.includeSummary : includeSummary // ignore: cast_nullable_to_non_nullable
as bool,includeTranslation: null == includeTranslation ? _self.includeTranslation : includeTranslation // ignore: cast_nullable_to_non_nullable
as bool,includeChat: null == includeChat ? _self.includeChat : includeChat // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [ExportRequestDto].
extension ExportRequestDtoPatterns on ExportRequestDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ExportRequestDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ExportRequestDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ExportRequestDto value)  $default,){
final _that = this;
switch (_that) {
case _ExportRequestDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ExportRequestDto value)?  $default,){
final _that = this;
switch (_that) {
case _ExportRequestDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'include_summary')  bool includeSummary, @JsonKey(name: 'include_translation')  bool includeTranslation, @JsonKey(name: 'include_chat')  bool includeChat)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ExportRequestDto() when $default != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'include_summary')  bool includeSummary, @JsonKey(name: 'include_translation')  bool includeTranslation, @JsonKey(name: 'include_chat')  bool includeChat)  $default,) {final _that = this;
switch (_that) {
case _ExportRequestDto():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'include_summary')  bool includeSummary, @JsonKey(name: 'include_translation')  bool includeTranslation, @JsonKey(name: 'include_chat')  bool includeChat)?  $default,) {final _that = this;
switch (_that) {
case _ExportRequestDto() when $default != null:
return $default(_that.includeSummary,_that.includeTranslation,_that.includeChat);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ExportRequestDto implements ExportRequestDto {
  const _ExportRequestDto({@JsonKey(name: 'include_summary') this.includeSummary = false, @JsonKey(name: 'include_translation') this.includeTranslation = false, @JsonKey(name: 'include_chat') this.includeChat = false});
  factory _ExportRequestDto.fromJson(Map<String, dynamic> json) => _$ExportRequestDtoFromJson(json);

@override@JsonKey(name: 'include_summary') final  bool includeSummary;
@override@JsonKey(name: 'include_translation') final  bool includeTranslation;
@override@JsonKey(name: 'include_chat') final  bool includeChat;

/// Create a copy of ExportRequestDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ExportRequestDtoCopyWith<_ExportRequestDto> get copyWith => __$ExportRequestDtoCopyWithImpl<_ExportRequestDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ExportRequestDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ExportRequestDto&&(identical(other.includeSummary, includeSummary) || other.includeSummary == includeSummary)&&(identical(other.includeTranslation, includeTranslation) || other.includeTranslation == includeTranslation)&&(identical(other.includeChat, includeChat) || other.includeChat == includeChat));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,includeSummary,includeTranslation,includeChat);

@override
String toString() {
  return 'ExportRequestDto(includeSummary: $includeSummary, includeTranslation: $includeTranslation, includeChat: $includeChat)';
}


}

/// @nodoc
abstract mixin class _$ExportRequestDtoCopyWith<$Res> implements $ExportRequestDtoCopyWith<$Res> {
  factory _$ExportRequestDtoCopyWith(_ExportRequestDto value, $Res Function(_ExportRequestDto) _then) = __$ExportRequestDtoCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'include_summary') bool includeSummary,@JsonKey(name: 'include_translation') bool includeTranslation,@JsonKey(name: 'include_chat') bool includeChat
});




}
/// @nodoc
class __$ExportRequestDtoCopyWithImpl<$Res>
    implements _$ExportRequestDtoCopyWith<$Res> {
  __$ExportRequestDtoCopyWithImpl(this._self, this._then);

  final _ExportRequestDto _self;
  final $Res Function(_ExportRequestDto) _then;

/// Create a copy of ExportRequestDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? includeSummary = null,Object? includeTranslation = null,Object? includeChat = null,}) {
  return _then(_ExportRequestDto(
includeSummary: null == includeSummary ? _self.includeSummary : includeSummary // ignore: cast_nullable_to_non_nullable
as bool,includeTranslation: null == includeTranslation ? _self.includeTranslation : includeTranslation // ignore: cast_nullable_to_non_nullable
as bool,includeChat: null == includeChat ? _self.includeChat : includeChat // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$ExportStatusDto {

 String get id;@JsonKey(name: 'document_id') String get documentId;@JsonKey(name: 'include_summary') bool get includeSummary;@JsonKey(name: 'include_translation') bool get includeTranslation;@JsonKey(name: 'include_chat') bool get includeChat;@JsonKey(name: 'export_status') String get exportStatus;@JsonKey(name: 'storage_key') String? get storageKey;@JsonKey(name: 'signed_url') String? get signedUrl;@JsonKey(name: 'error_message') String? get errorMessage;@JsonKey(name: 'created_at') DateTime? get createdAt;@JsonKey(name: 'updated_at') DateTime? get updatedAt;
/// Create a copy of ExportStatusDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ExportStatusDtoCopyWith<ExportStatusDto> get copyWith => _$ExportStatusDtoCopyWithImpl<ExportStatusDto>(this as ExportStatusDto, _$identity);

  /// Serializes this ExportStatusDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ExportStatusDto&&(identical(other.id, id) || other.id == id)&&(identical(other.documentId, documentId) || other.documentId == documentId)&&(identical(other.includeSummary, includeSummary) || other.includeSummary == includeSummary)&&(identical(other.includeTranslation, includeTranslation) || other.includeTranslation == includeTranslation)&&(identical(other.includeChat, includeChat) || other.includeChat == includeChat)&&(identical(other.exportStatus, exportStatus) || other.exportStatus == exportStatus)&&(identical(other.storageKey, storageKey) || other.storageKey == storageKey)&&(identical(other.signedUrl, signedUrl) || other.signedUrl == signedUrl)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,documentId,includeSummary,includeTranslation,includeChat,exportStatus,storageKey,signedUrl,errorMessage,createdAt,updatedAt);

@override
String toString() {
  return 'ExportStatusDto(id: $id, documentId: $documentId, includeSummary: $includeSummary, includeTranslation: $includeTranslation, includeChat: $includeChat, exportStatus: $exportStatus, storageKey: $storageKey, signedUrl: $signedUrl, errorMessage: $errorMessage, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $ExportStatusDtoCopyWith<$Res>  {
  factory $ExportStatusDtoCopyWith(ExportStatusDto value, $Res Function(ExportStatusDto) _then) = _$ExportStatusDtoCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'document_id') String documentId,@JsonKey(name: 'include_summary') bool includeSummary,@JsonKey(name: 'include_translation') bool includeTranslation,@JsonKey(name: 'include_chat') bool includeChat,@JsonKey(name: 'export_status') String exportStatus,@JsonKey(name: 'storage_key') String? storageKey,@JsonKey(name: 'signed_url') String? signedUrl,@JsonKey(name: 'error_message') String? errorMessage,@JsonKey(name: 'created_at') DateTime? createdAt,@JsonKey(name: 'updated_at') DateTime? updatedAt
});




}
/// @nodoc
class _$ExportStatusDtoCopyWithImpl<$Res>
    implements $ExportStatusDtoCopyWith<$Res> {
  _$ExportStatusDtoCopyWithImpl(this._self, this._then);

  final ExportStatusDto _self;
  final $Res Function(ExportStatusDto) _then;

/// Create a copy of ExportStatusDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? documentId = null,Object? includeSummary = null,Object? includeTranslation = null,Object? includeChat = null,Object? exportStatus = null,Object? storageKey = freezed,Object? signedUrl = freezed,Object? errorMessage = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(ExportStatusDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,documentId: null == documentId ? _self.documentId : documentId // ignore: cast_nullable_to_non_nullable
as String,includeSummary: null == includeSummary ? _self.includeSummary : includeSummary // ignore: cast_nullable_to_non_nullable
as bool,includeTranslation: null == includeTranslation ? _self.includeTranslation : includeTranslation // ignore: cast_nullable_to_non_nullable
as bool,includeChat: null == includeChat ? _self.includeChat : includeChat // ignore: cast_nullable_to_non_nullable
as bool,exportStatus: null == exportStatus ? _self.exportStatus : exportStatus // ignore: cast_nullable_to_non_nullable
as String,storageKey: freezed == storageKey ? _self.storageKey : storageKey // ignore: cast_nullable_to_non_nullable
as String?,signedUrl: freezed == signedUrl ? _self.signedUrl : signedUrl // ignore: cast_nullable_to_non_nullable
as String?,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [ExportStatusDto].
extension ExportStatusDtoPatterns on ExportStatusDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ExportStatusDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ExportStatusDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ExportStatusDto value)  $default,){
final _that = this;
switch (_that) {
case _ExportStatusDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ExportStatusDto value)?  $default,){
final _that = this;
switch (_that) {
case _ExportStatusDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'document_id')  String documentId, @JsonKey(name: 'include_summary')  bool includeSummary, @JsonKey(name: 'include_translation')  bool includeTranslation, @JsonKey(name: 'include_chat')  bool includeChat, @JsonKey(name: 'export_status')  String exportStatus, @JsonKey(name: 'storage_key')  String? storageKey, @JsonKey(name: 'signed_url')  String? signedUrl, @JsonKey(name: 'error_message')  String? errorMessage, @JsonKey(name: 'created_at')  DateTime? createdAt, @JsonKey(name: 'updated_at')  DateTime? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ExportStatusDto() when $default != null:
return $default(_that.id,_that.documentId,_that.includeSummary,_that.includeTranslation,_that.includeChat,_that.exportStatus,_that.storageKey,_that.signedUrl,_that.errorMessage,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'document_id')  String documentId, @JsonKey(name: 'include_summary')  bool includeSummary, @JsonKey(name: 'include_translation')  bool includeTranslation, @JsonKey(name: 'include_chat')  bool includeChat, @JsonKey(name: 'export_status')  String exportStatus, @JsonKey(name: 'storage_key')  String? storageKey, @JsonKey(name: 'signed_url')  String? signedUrl, @JsonKey(name: 'error_message')  String? errorMessage, @JsonKey(name: 'created_at')  DateTime? createdAt, @JsonKey(name: 'updated_at')  DateTime? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _ExportStatusDto():
return $default(_that.id,_that.documentId,_that.includeSummary,_that.includeTranslation,_that.includeChat,_that.exportStatus,_that.storageKey,_that.signedUrl,_that.errorMessage,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'document_id')  String documentId, @JsonKey(name: 'include_summary')  bool includeSummary, @JsonKey(name: 'include_translation')  bool includeTranslation, @JsonKey(name: 'include_chat')  bool includeChat, @JsonKey(name: 'export_status')  String exportStatus, @JsonKey(name: 'storage_key')  String? storageKey, @JsonKey(name: 'signed_url')  String? signedUrl, @JsonKey(name: 'error_message')  String? errorMessage, @JsonKey(name: 'created_at')  DateTime? createdAt, @JsonKey(name: 'updated_at')  DateTime? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _ExportStatusDto() when $default != null:
return $default(_that.id,_that.documentId,_that.includeSummary,_that.includeTranslation,_that.includeChat,_that.exportStatus,_that.storageKey,_that.signedUrl,_that.errorMessage,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ExportStatusDto implements ExportStatusDto {
  const _ExportStatusDto({required this.id, @JsonKey(name: 'document_id') required this.documentId, @JsonKey(name: 'include_summary') this.includeSummary = false, @JsonKey(name: 'include_translation') this.includeTranslation = false, @JsonKey(name: 'include_chat') this.includeChat = false, @JsonKey(name: 'export_status') required this.exportStatus, @JsonKey(name: 'storage_key') this.storageKey, @JsonKey(name: 'signed_url') this.signedUrl, @JsonKey(name: 'error_message') this.errorMessage, @JsonKey(name: 'created_at') this.createdAt, @JsonKey(name: 'updated_at') this.updatedAt});
  factory _ExportStatusDto.fromJson(Map<String, dynamic> json) => _$ExportStatusDtoFromJson(json);

@override final  String id;
@override@JsonKey(name: 'document_id') final  String documentId;
@override@JsonKey(name: 'include_summary') final  bool includeSummary;
@override@JsonKey(name: 'include_translation') final  bool includeTranslation;
@override@JsonKey(name: 'include_chat') final  bool includeChat;
@override@JsonKey(name: 'export_status') final  String exportStatus;
@override@JsonKey(name: 'storage_key') final  String? storageKey;
@override@JsonKey(name: 'signed_url') final  String? signedUrl;
@override@JsonKey(name: 'error_message') final  String? errorMessage;
@override@JsonKey(name: 'created_at') final  DateTime? createdAt;
@override@JsonKey(name: 'updated_at') final  DateTime? updatedAt;

/// Create a copy of ExportStatusDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ExportStatusDtoCopyWith<_ExportStatusDto> get copyWith => __$ExportStatusDtoCopyWithImpl<_ExportStatusDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ExportStatusDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ExportStatusDto&&(identical(other.id, id) || other.id == id)&&(identical(other.documentId, documentId) || other.documentId == documentId)&&(identical(other.includeSummary, includeSummary) || other.includeSummary == includeSummary)&&(identical(other.includeTranslation, includeTranslation) || other.includeTranslation == includeTranslation)&&(identical(other.includeChat, includeChat) || other.includeChat == includeChat)&&(identical(other.exportStatus, exportStatus) || other.exportStatus == exportStatus)&&(identical(other.storageKey, storageKey) || other.storageKey == storageKey)&&(identical(other.signedUrl, signedUrl) || other.signedUrl == signedUrl)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,documentId,includeSummary,includeTranslation,includeChat,exportStatus,storageKey,signedUrl,errorMessage,createdAt,updatedAt);

@override
String toString() {
  return 'ExportStatusDto(id: $id, documentId: $documentId, includeSummary: $includeSummary, includeTranslation: $includeTranslation, includeChat: $includeChat, exportStatus: $exportStatus, storageKey: $storageKey, signedUrl: $signedUrl, errorMessage: $errorMessage, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$ExportStatusDtoCopyWith<$Res> implements $ExportStatusDtoCopyWith<$Res> {
  factory _$ExportStatusDtoCopyWith(_ExportStatusDto value, $Res Function(_ExportStatusDto) _then) = __$ExportStatusDtoCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'document_id') String documentId,@JsonKey(name: 'include_summary') bool includeSummary,@JsonKey(name: 'include_translation') bool includeTranslation,@JsonKey(name: 'include_chat') bool includeChat,@JsonKey(name: 'export_status') String exportStatus,@JsonKey(name: 'storage_key') String? storageKey,@JsonKey(name: 'signed_url') String? signedUrl,@JsonKey(name: 'error_message') String? errorMessage,@JsonKey(name: 'created_at') DateTime? createdAt,@JsonKey(name: 'updated_at') DateTime? updatedAt
});




}
/// @nodoc
class __$ExportStatusDtoCopyWithImpl<$Res>
    implements _$ExportStatusDtoCopyWith<$Res> {
  __$ExportStatusDtoCopyWithImpl(this._self, this._then);

  final _ExportStatusDto _self;
  final $Res Function(_ExportStatusDto) _then;

/// Create a copy of ExportStatusDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? documentId = null,Object? includeSummary = null,Object? includeTranslation = null,Object? includeChat = null,Object? exportStatus = null,Object? storageKey = freezed,Object? signedUrl = freezed,Object? errorMessage = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_ExportStatusDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,documentId: null == documentId ? _self.documentId : documentId // ignore: cast_nullable_to_non_nullable
as String,includeSummary: null == includeSummary ? _self.includeSummary : includeSummary // ignore: cast_nullable_to_non_nullable
as bool,includeTranslation: null == includeTranslation ? _self.includeTranslation : includeTranslation // ignore: cast_nullable_to_non_nullable
as bool,includeChat: null == includeChat ? _self.includeChat : includeChat // ignore: cast_nullable_to_non_nullable
as bool,exportStatus: null == exportStatus ? _self.exportStatus : exportStatus // ignore: cast_nullable_to_non_nullable
as String,storageKey: freezed == storageKey ? _self.storageKey : storageKey // ignore: cast_nullable_to_non_nullable
as String?,signedUrl: freezed == signedUrl ? _self.signedUrl : signedUrl // ignore: cast_nullable_to_non_nullable
as String?,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}


/// @nodoc
mixin _$NotificationDto {

 String get id; String get type; String get title; String get body; Map<String, dynamic> get payload;@JsonKey(name: 'read_at') DateTime? get readAt;@JsonKey(name: 'created_at') DateTime? get createdAt;
/// Create a copy of NotificationDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NotificationDtoCopyWith<NotificationDto> get copyWith => _$NotificationDtoCopyWithImpl<NotificationDto>(this as NotificationDto, _$identity);

  /// Serializes this NotificationDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NotificationDto&&(identical(other.id, id) || other.id == id)&&(identical(other.type, type) || other.type == type)&&(identical(other.title, title) || other.title == title)&&(identical(other.body, body) || other.body == body)&&const DeepCollectionEquality().equals(other.payload, payload)&&(identical(other.readAt, readAt) || other.readAt == readAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,type,title,body,const DeepCollectionEquality().hash(payload),readAt,createdAt);

@override
String toString() {
  return 'NotificationDto(id: $id, type: $type, title: $title, body: $body, payload: $payload, readAt: $readAt, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $NotificationDtoCopyWith<$Res>  {
  factory $NotificationDtoCopyWith(NotificationDto value, $Res Function(NotificationDto) _then) = _$NotificationDtoCopyWithImpl;
@useResult
$Res call({
 String id, String type, String title, String body, Map<String, dynamic> payload,@JsonKey(name: 'read_at') DateTime? readAt,@JsonKey(name: 'created_at') DateTime? createdAt
});




}
/// @nodoc
class _$NotificationDtoCopyWithImpl<$Res>
    implements $NotificationDtoCopyWith<$Res> {
  _$NotificationDtoCopyWithImpl(this._self, this._then);

  final NotificationDto _self;
  final $Res Function(NotificationDto) _then;

/// Create a copy of NotificationDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? type = null,Object? title = null,Object? body = null,Object? payload = null,Object? readAt = freezed,Object? createdAt = freezed,}) {
  return _then(NotificationDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,body: null == body ? _self.body : body // ignore: cast_nullable_to_non_nullable
as String,payload: null == payload ? _self.payload : payload // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,readAt: freezed == readAt ? _self.readAt : readAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [NotificationDto].
extension NotificationDtoPatterns on NotificationDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _NotificationDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _NotificationDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _NotificationDto value)  $default,){
final _that = this;
switch (_that) {
case _NotificationDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _NotificationDto value)?  $default,){
final _that = this;
switch (_that) {
case _NotificationDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String type,  String title,  String body,  Map<String, dynamic> payload, @JsonKey(name: 'read_at')  DateTime? readAt, @JsonKey(name: 'created_at')  DateTime? createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _NotificationDto() when $default != null:
return $default(_that.id,_that.type,_that.title,_that.body,_that.payload,_that.readAt,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String type,  String title,  String body,  Map<String, dynamic> payload, @JsonKey(name: 'read_at')  DateTime? readAt, @JsonKey(name: 'created_at')  DateTime? createdAt)  $default,) {final _that = this;
switch (_that) {
case _NotificationDto():
return $default(_that.id,_that.type,_that.title,_that.body,_that.payload,_that.readAt,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String type,  String title,  String body,  Map<String, dynamic> payload, @JsonKey(name: 'read_at')  DateTime? readAt, @JsonKey(name: 'created_at')  DateTime? createdAt)?  $default,) {final _that = this;
switch (_that) {
case _NotificationDto() when $default != null:
return $default(_that.id,_that.type,_that.title,_that.body,_that.payload,_that.readAt,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _NotificationDto implements NotificationDto {
  const _NotificationDto({required this.id, required this.type, required this.title, required this.body,  Map<String, dynamic> payload = const <String, dynamic>{}, @JsonKey(name: 'read_at') this.readAt, @JsonKey(name: 'created_at') this.createdAt}): _payload = payload;
  factory _NotificationDto.fromJson(Map<String, dynamic> json) => _$NotificationDtoFromJson(json);

@override final  String id;
@override final  String type;
@override final  String title;
@override final  String body;
 final  Map<String, dynamic> _payload;
@override@JsonKey() Map<String, dynamic> get payload {
  if (_payload is EqualUnmodifiableMapView) return _payload;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_payload);
}

@override@JsonKey(name: 'read_at') final  DateTime? readAt;
@override@JsonKey(name: 'created_at') final  DateTime? createdAt;

/// Create a copy of NotificationDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$NotificationDtoCopyWith<_NotificationDto> get copyWith => __$NotificationDtoCopyWithImpl<_NotificationDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$NotificationDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _NotificationDto&&(identical(other.id, id) || other.id == id)&&(identical(other.type, type) || other.type == type)&&(identical(other.title, title) || other.title == title)&&(identical(other.body, body) || other.body == body)&&const DeepCollectionEquality().equals(other._payload, _payload)&&(identical(other.readAt, readAt) || other.readAt == readAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,type,title,body,const DeepCollectionEquality().hash(_payload),readAt,createdAt);

@override
String toString() {
  return 'NotificationDto(id: $id, type: $type, title: $title, body: $body, payload: $payload, readAt: $readAt, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$NotificationDtoCopyWith<$Res> implements $NotificationDtoCopyWith<$Res> {
  factory _$NotificationDtoCopyWith(_NotificationDto value, $Res Function(_NotificationDto) _then) = __$NotificationDtoCopyWithImpl;
@override @useResult
$Res call({
 String id, String type, String title, String body, Map<String, dynamic> payload,@JsonKey(name: 'read_at') DateTime? readAt,@JsonKey(name: 'created_at') DateTime? createdAt
});




}
/// @nodoc
class __$NotificationDtoCopyWithImpl<$Res>
    implements _$NotificationDtoCopyWith<$Res> {
  __$NotificationDtoCopyWithImpl(this._self, this._then);

  final _NotificationDto _self;
  final $Res Function(_NotificationDto) _then;

/// Create a copy of NotificationDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? type = null,Object? title = null,Object? body = null,Object? payload = null,Object? readAt = freezed,Object? createdAt = freezed,}) {
  return _then(_NotificationDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,body: null == body ? _self.body : body // ignore: cast_nullable_to_non_nullable
as String,payload: null == payload ? _self._payload : payload // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,readAt: freezed == readAt ? _self.readAt : readAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}


/// @nodoc
mixin _$NotificationListDto {

 List<NotificationDto> get items; int get total;
/// Create a copy of NotificationListDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NotificationListDtoCopyWith<NotificationListDto> get copyWith => _$NotificationListDtoCopyWithImpl<NotificationListDto>(this as NotificationListDto, _$identity);

  /// Serializes this NotificationListDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NotificationListDto&&const DeepCollectionEquality().equals(other.items, items)&&(identical(other.total, total) || other.total == total));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(items),total);

@override
String toString() {
  return 'NotificationListDto(items: $items, total: $total)';
}


}

/// @nodoc
abstract mixin class $NotificationListDtoCopyWith<$Res>  {
  factory $NotificationListDtoCopyWith(NotificationListDto value, $Res Function(NotificationListDto) _then) = _$NotificationListDtoCopyWithImpl;
@useResult
$Res call({
 List<NotificationDto> items, int total
});




}
/// @nodoc
class _$NotificationListDtoCopyWithImpl<$Res>
    implements $NotificationListDtoCopyWith<$Res> {
  _$NotificationListDtoCopyWithImpl(this._self, this._then);

  final NotificationListDto _self;
  final $Res Function(NotificationListDto) _then;

/// Create a copy of NotificationListDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? items = null,Object? total = null,}) {
  return _then(NotificationListDto(
items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<NotificationDto>,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [NotificationListDto].
extension NotificationListDtoPatterns on NotificationListDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _NotificationListDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _NotificationListDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _NotificationListDto value)  $default,){
final _that = this;
switch (_that) {
case _NotificationListDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _NotificationListDto value)?  $default,){
final _that = this;
switch (_that) {
case _NotificationListDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<NotificationDto> items,  int total)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _NotificationListDto() when $default != null:
return $default(_that.items,_that.total);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<NotificationDto> items,  int total)  $default,) {final _that = this;
switch (_that) {
case _NotificationListDto():
return $default(_that.items,_that.total);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<NotificationDto> items,  int total)?  $default,) {final _that = this;
switch (_that) {
case _NotificationListDto() when $default != null:
return $default(_that.items,_that.total);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _NotificationListDto implements NotificationListDto {
  const _NotificationListDto({ List<NotificationDto> items = const <NotificationDto>[], this.total = 0}): _items = items;
  factory _NotificationListDto.fromJson(Map<String, dynamic> json) => _$NotificationListDtoFromJson(json);

 final  List<NotificationDto> _items;
@override@JsonKey() List<NotificationDto> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}

@override@JsonKey() final  int total;

/// Create a copy of NotificationListDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$NotificationListDtoCopyWith<_NotificationListDto> get copyWith => __$NotificationListDtoCopyWithImpl<_NotificationListDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$NotificationListDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _NotificationListDto&&const DeepCollectionEquality().equals(other._items, _items)&&(identical(other.total, total) || other.total == total));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_items),total);

@override
String toString() {
  return 'NotificationListDto(items: $items, total: $total)';
}


}

/// @nodoc
abstract mixin class _$NotificationListDtoCopyWith<$Res> implements $NotificationListDtoCopyWith<$Res> {
  factory _$NotificationListDtoCopyWith(_NotificationListDto value, $Res Function(_NotificationListDto) _then) = __$NotificationListDtoCopyWithImpl;
@override @useResult
$Res call({
 List<NotificationDto> items, int total
});




}
/// @nodoc
class __$NotificationListDtoCopyWithImpl<$Res>
    implements _$NotificationListDtoCopyWith<$Res> {
  __$NotificationListDtoCopyWithImpl(this._self, this._then);

  final _NotificationListDto _self;
  final $Res Function(_NotificationListDto) _then;

/// Create a copy of NotificationListDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? items = null,Object? total = null,}) {
  return _then(_NotificationListDto(
items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<NotificationDto>,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
