// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'subscription_status.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$UsageBucket {

 int get used; int get limit; String get period;
/// Create a copy of UsageBucket
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UsageBucketCopyWith<UsageBucket> get copyWith => _$UsageBucketCopyWithImpl<UsageBucket>(this as UsageBucket, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UsageBucket&&(identical(other.used, used) || other.used == used)&&(identical(other.limit, limit) || other.limit == limit)&&(identical(other.period, period) || other.period == period));
}


@override
int get hashCode => Object.hash(runtimeType,used,limit,period);

@override
String toString() {
  return 'UsageBucket(used: $used, limit: $limit, period: $period)';
}


}

/// @nodoc
abstract mixin class $UsageBucketCopyWith<$Res>  {
  factory $UsageBucketCopyWith(UsageBucket value, $Res Function(UsageBucket) _then) = _$UsageBucketCopyWithImpl;
@useResult
$Res call({
 int used, int limit, String period
});




}
/// @nodoc
class _$UsageBucketCopyWithImpl<$Res>
    implements $UsageBucketCopyWith<$Res> {
  _$UsageBucketCopyWithImpl(this._self, this._then);

  final UsageBucket _self;
  final $Res Function(UsageBucket) _then;

/// Create a copy of UsageBucket
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? used = null,Object? limit = null,Object? period = null,}) {
  return _then(UsageBucket(
used: null == used ? _self.used : used // ignore: cast_nullable_to_non_nullable
as int,limit: null == limit ? _self.limit : limit // ignore: cast_nullable_to_non_nullable
as int,period: null == period ? _self.period : period // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [UsageBucket].
extension UsageBucketPatterns on UsageBucket {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UsageBucket value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UsageBucket() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UsageBucket value)  $default,){
final _that = this;
switch (_that) {
case _UsageBucket():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UsageBucket value)?  $default,){
final _that = this;
switch (_that) {
case _UsageBucket() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int used,  int limit,  String period)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UsageBucket() when $default != null:
return $default(_that.used,_that.limit,_that.period);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int used,  int limit,  String period)  $default,) {final _that = this;
switch (_that) {
case _UsageBucket():
return $default(_that.used,_that.limit,_that.period);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int used,  int limit,  String period)?  $default,) {final _that = this;
switch (_that) {
case _UsageBucket() when $default != null:
return $default(_that.used,_that.limit,_that.period);case _:
  return null;

}
}

}

/// @nodoc


class _UsageBucket implements UsageBucket {
  const _UsageBucket({required this.used, required this.limit, required this.period});
  

@override final  int used;
@override final  int limit;
@override final  String period;

/// Create a copy of UsageBucket
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UsageBucketCopyWith<_UsageBucket> get copyWith => __$UsageBucketCopyWithImpl<_UsageBucket>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UsageBucket&&(identical(other.used, used) || other.used == used)&&(identical(other.limit, limit) || other.limit == limit)&&(identical(other.period, period) || other.period == period));
}


@override
int get hashCode => Object.hash(runtimeType,used,limit,period);

@override
String toString() {
  return 'UsageBucket(used: $used, limit: $limit, period: $period)';
}


}

/// @nodoc
abstract mixin class _$UsageBucketCopyWith<$Res> implements $UsageBucketCopyWith<$Res> {
  factory _$UsageBucketCopyWith(_UsageBucket value, $Res Function(_UsageBucket) _then) = __$UsageBucketCopyWithImpl;
@override @useResult
$Res call({
 int used, int limit, String period
});




}
/// @nodoc
class __$UsageBucketCopyWithImpl<$Res>
    implements _$UsageBucketCopyWith<$Res> {
  __$UsageBucketCopyWithImpl(this._self, this._then);

  final _UsageBucket _self;
  final $Res Function(_UsageBucket) _then;

/// Create a copy of UsageBucket
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? used = null,Object? limit = null,Object? period = null,}) {
  return _then(_UsageBucket(
used: null == used ? _self.used : used // ignore: cast_nullable_to_non_nullable
as int,limit: null == limit ? _self.limit : limit // ignore: cast_nullable_to_non_nullable
as int,period: null == period ? _self.period : period // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc
mixin _$SubscriptionStatus {

 String get tier; String get status; bool get paywallEnabled; UsageBucket get documents; UsageBucket get chatMessages; UsageBucket get ocrPages;
/// Create a copy of SubscriptionStatus
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SubscriptionStatusCopyWith<SubscriptionStatus> get copyWith => _$SubscriptionStatusCopyWithImpl<SubscriptionStatus>(this as SubscriptionStatus, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SubscriptionStatus&&(identical(other.tier, tier) || other.tier == tier)&&(identical(other.status, status) || other.status == status)&&(identical(other.paywallEnabled, paywallEnabled) || other.paywallEnabled == paywallEnabled)&&(identical(other.documents, documents) || other.documents == documents)&&(identical(other.chatMessages, chatMessages) || other.chatMessages == chatMessages)&&(identical(other.ocrPages, ocrPages) || other.ocrPages == ocrPages));
}


@override
int get hashCode => Object.hash(runtimeType,tier,status,paywallEnabled,documents,chatMessages,ocrPages);

@override
String toString() {
  return 'SubscriptionStatus(tier: $tier, status: $status, paywallEnabled: $paywallEnabled, documents: $documents, chatMessages: $chatMessages, ocrPages: $ocrPages)';
}


}

/// @nodoc
abstract mixin class $SubscriptionStatusCopyWith<$Res>  {
  factory $SubscriptionStatusCopyWith(SubscriptionStatus value, $Res Function(SubscriptionStatus) _then) = _$SubscriptionStatusCopyWithImpl;
@useResult
$Res call({
 String tier, String status, bool paywallEnabled, UsageBucket documents, UsageBucket chatMessages, UsageBucket ocrPages
});


$UsageBucketCopyWith<$Res> get documents;$UsageBucketCopyWith<$Res> get chatMessages;$UsageBucketCopyWith<$Res> get ocrPages;

}
/// @nodoc
class _$SubscriptionStatusCopyWithImpl<$Res>
    implements $SubscriptionStatusCopyWith<$Res> {
  _$SubscriptionStatusCopyWithImpl(this._self, this._then);

  final SubscriptionStatus _self;
  final $Res Function(SubscriptionStatus) _then;

/// Create a copy of SubscriptionStatus
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? tier = null,Object? status = null,Object? paywallEnabled = null,Object? documents = null,Object? chatMessages = null,Object? ocrPages = null,}) {
  return _then(SubscriptionStatus(
tier: null == tier ? _self.tier : tier // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,paywallEnabled: null == paywallEnabled ? _self.paywallEnabled : paywallEnabled // ignore: cast_nullable_to_non_nullable
as bool,documents: null == documents ? _self.documents : documents // ignore: cast_nullable_to_non_nullable
as UsageBucket,chatMessages: null == chatMessages ? _self.chatMessages : chatMessages // ignore: cast_nullable_to_non_nullable
as UsageBucket,ocrPages: null == ocrPages ? _self.ocrPages : ocrPages // ignore: cast_nullable_to_non_nullable
as UsageBucket,
  ));
}
/// Create a copy of SubscriptionStatus
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UsageBucketCopyWith<$Res> get documents {
  
  return $UsageBucketCopyWith<$Res>(_self.documents, (value) {
    return _then(_self.copyWith(documents: value));
  });
}/// Create a copy of SubscriptionStatus
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UsageBucketCopyWith<$Res> get chatMessages {
  
  return $UsageBucketCopyWith<$Res>(_self.chatMessages, (value) {
    return _then(_self.copyWith(chatMessages: value));
  });
}/// Create a copy of SubscriptionStatus
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UsageBucketCopyWith<$Res> get ocrPages {
  
  return $UsageBucketCopyWith<$Res>(_self.ocrPages, (value) {
    return _then(_self.copyWith(ocrPages: value));
  });
}
}


/// Adds pattern-matching-related methods to [SubscriptionStatus].
extension SubscriptionStatusPatterns on SubscriptionStatus {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SubscriptionStatus value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SubscriptionStatus() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SubscriptionStatus value)  $default,){
final _that = this;
switch (_that) {
case _SubscriptionStatus():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SubscriptionStatus value)?  $default,){
final _that = this;
switch (_that) {
case _SubscriptionStatus() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String tier,  String status,  bool paywallEnabled,  UsageBucket documents,  UsageBucket chatMessages,  UsageBucket ocrPages)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SubscriptionStatus() when $default != null:
return $default(_that.tier,_that.status,_that.paywallEnabled,_that.documents,_that.chatMessages,_that.ocrPages);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String tier,  String status,  bool paywallEnabled,  UsageBucket documents,  UsageBucket chatMessages,  UsageBucket ocrPages)  $default,) {final _that = this;
switch (_that) {
case _SubscriptionStatus():
return $default(_that.tier,_that.status,_that.paywallEnabled,_that.documents,_that.chatMessages,_that.ocrPages);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String tier,  String status,  bool paywallEnabled,  UsageBucket documents,  UsageBucket chatMessages,  UsageBucket ocrPages)?  $default,) {final _that = this;
switch (_that) {
case _SubscriptionStatus() when $default != null:
return $default(_that.tier,_that.status,_that.paywallEnabled,_that.documents,_that.chatMessages,_that.ocrPages);case _:
  return null;

}
}

}

/// @nodoc


class _SubscriptionStatus extends SubscriptionStatus {
  const _SubscriptionStatus({required this.tier, this.status = 'active', required this.paywallEnabled, required this.documents, required this.chatMessages, required this.ocrPages}): super._();
  

@override final  String tier;
@override@JsonKey() final  String status;
@override final  bool paywallEnabled;
@override final  UsageBucket documents;
@override final  UsageBucket chatMessages;
@override final  UsageBucket ocrPages;

/// Create a copy of SubscriptionStatus
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SubscriptionStatusCopyWith<_SubscriptionStatus> get copyWith => __$SubscriptionStatusCopyWithImpl<_SubscriptionStatus>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SubscriptionStatus&&(identical(other.tier, tier) || other.tier == tier)&&(identical(other.status, status) || other.status == status)&&(identical(other.paywallEnabled, paywallEnabled) || other.paywallEnabled == paywallEnabled)&&(identical(other.documents, documents) || other.documents == documents)&&(identical(other.chatMessages, chatMessages) || other.chatMessages == chatMessages)&&(identical(other.ocrPages, ocrPages) || other.ocrPages == ocrPages));
}


@override
int get hashCode => Object.hash(runtimeType,tier,status,paywallEnabled,documents,chatMessages,ocrPages);

@override
String toString() {
  return 'SubscriptionStatus(tier: $tier, status: $status, paywallEnabled: $paywallEnabled, documents: $documents, chatMessages: $chatMessages, ocrPages: $ocrPages)';
}


}

/// @nodoc
abstract mixin class _$SubscriptionStatusCopyWith<$Res> implements $SubscriptionStatusCopyWith<$Res> {
  factory _$SubscriptionStatusCopyWith(_SubscriptionStatus value, $Res Function(_SubscriptionStatus) _then) = __$SubscriptionStatusCopyWithImpl;
@override @useResult
$Res call({
 String tier, String status, bool paywallEnabled, UsageBucket documents, UsageBucket chatMessages, UsageBucket ocrPages
});


@override $UsageBucketCopyWith<$Res> get documents;@override $UsageBucketCopyWith<$Res> get chatMessages;@override $UsageBucketCopyWith<$Res> get ocrPages;

}
/// @nodoc
class __$SubscriptionStatusCopyWithImpl<$Res>
    implements _$SubscriptionStatusCopyWith<$Res> {
  __$SubscriptionStatusCopyWithImpl(this._self, this._then);

  final _SubscriptionStatus _self;
  final $Res Function(_SubscriptionStatus) _then;

/// Create a copy of SubscriptionStatus
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? tier = null,Object? status = null,Object? paywallEnabled = null,Object? documents = null,Object? chatMessages = null,Object? ocrPages = null,}) {
  return _then(_SubscriptionStatus(
tier: null == tier ? _self.tier : tier // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,paywallEnabled: null == paywallEnabled ? _self.paywallEnabled : paywallEnabled // ignore: cast_nullable_to_non_nullable
as bool,documents: null == documents ? _self.documents : documents // ignore: cast_nullable_to_non_nullable
as UsageBucket,chatMessages: null == chatMessages ? _self.chatMessages : chatMessages // ignore: cast_nullable_to_non_nullable
as UsageBucket,ocrPages: null == ocrPages ? _self.ocrPages : ocrPages // ignore: cast_nullable_to_non_nullable
as UsageBucket,
  ));
}

/// Create a copy of SubscriptionStatus
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UsageBucketCopyWith<$Res> get documents {
  
  return $UsageBucketCopyWith<$Res>(_self.documents, (value) {
    return _then(_self.copyWith(documents: value));
  });
}/// Create a copy of SubscriptionStatus
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UsageBucketCopyWith<$Res> get chatMessages {
  
  return $UsageBucketCopyWith<$Res>(_self.chatMessages, (value) {
    return _then(_self.copyWith(chatMessages: value));
  });
}/// Create a copy of SubscriptionStatus
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UsageBucketCopyWith<$Res> get ocrPages {
  
  return $UsageBucketCopyWith<$Res>(_self.ocrPages, (value) {
    return _then(_self.copyWith(ocrPages: value));
  });
}
}

// dart format on
