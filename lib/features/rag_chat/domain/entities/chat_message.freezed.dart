// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'chat_message.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Citation {

 String? get chunkId; int? get index; String? get snippet; int? get page; String? get label;
/// Create a copy of Citation
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CitationCopyWith<Citation> get copyWith => _$CitationCopyWithImpl<Citation>(this as Citation, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Citation&&(identical(other.chunkId, chunkId) || other.chunkId == chunkId)&&(identical(other.index, index) || other.index == index)&&(identical(other.snippet, snippet) || other.snippet == snippet)&&(identical(other.page, page) || other.page == page)&&(identical(other.label, label) || other.label == label));
}


@override
int get hashCode => Object.hash(runtimeType,chunkId,index,snippet,page,label);

@override
String toString() {
  return 'Citation(chunkId: $chunkId, index: $index, snippet: $snippet, page: $page, label: $label)';
}


}

/// @nodoc
abstract mixin class $CitationCopyWith<$Res>  {
  factory $CitationCopyWith(Citation value, $Res Function(Citation) _then) = _$CitationCopyWithImpl;
@useResult
$Res call({
 String? chunkId, int? index, String? snippet, int? page, String? label
});




}
/// @nodoc
class _$CitationCopyWithImpl<$Res>
    implements $CitationCopyWith<$Res> {
  _$CitationCopyWithImpl(this._self, this._then);

  final Citation _self;
  final $Res Function(Citation) _then;

/// Create a copy of Citation
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? chunkId = freezed,Object? index = freezed,Object? snippet = freezed,Object? page = freezed,Object? label = freezed,}) {
  return _then(Citation(
chunkId: freezed == chunkId ? _self.chunkId : chunkId // ignore: cast_nullable_to_non_nullable
as String?,index: freezed == index ? _self.index : index // ignore: cast_nullable_to_non_nullable
as int?,snippet: freezed == snippet ? _self.snippet : snippet // ignore: cast_nullable_to_non_nullable
as String?,page: freezed == page ? _self.page : page // ignore: cast_nullable_to_non_nullable
as int?,label: freezed == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [Citation].
extension CitationPatterns on Citation {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Citation value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Citation() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Citation value)  $default,){
final _that = this;
switch (_that) {
case _Citation():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Citation value)?  $default,){
final _that = this;
switch (_that) {
case _Citation() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? chunkId,  int? index,  String? snippet,  int? page,  String? label)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Citation() when $default != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? chunkId,  int? index,  String? snippet,  int? page,  String? label)  $default,) {final _that = this;
switch (_that) {
case _Citation():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? chunkId,  int? index,  String? snippet,  int? page,  String? label)?  $default,) {final _that = this;
switch (_that) {
case _Citation() when $default != null:
return $default(_that.chunkId,_that.index,_that.snippet,_that.page,_that.label);case _:
  return null;

}
}

}

/// @nodoc


class _Citation implements Citation {
  const _Citation({this.chunkId, this.index, this.snippet, this.page, this.label});
  

@override final  String? chunkId;
@override final  int? index;
@override final  String? snippet;
@override final  int? page;
@override final  String? label;

/// Create a copy of Citation
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CitationCopyWith<_Citation> get copyWith => __$CitationCopyWithImpl<_Citation>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Citation&&(identical(other.chunkId, chunkId) || other.chunkId == chunkId)&&(identical(other.index, index) || other.index == index)&&(identical(other.snippet, snippet) || other.snippet == snippet)&&(identical(other.page, page) || other.page == page)&&(identical(other.label, label) || other.label == label));
}


@override
int get hashCode => Object.hash(runtimeType,chunkId,index,snippet,page,label);

@override
String toString() {
  return 'Citation(chunkId: $chunkId, index: $index, snippet: $snippet, page: $page, label: $label)';
}


}

/// @nodoc
abstract mixin class _$CitationCopyWith<$Res> implements $CitationCopyWith<$Res> {
  factory _$CitationCopyWith(_Citation value, $Res Function(_Citation) _then) = __$CitationCopyWithImpl;
@override @useResult
$Res call({
 String? chunkId, int? index, String? snippet, int? page, String? label
});




}
/// @nodoc
class __$CitationCopyWithImpl<$Res>
    implements _$CitationCopyWith<$Res> {
  __$CitationCopyWithImpl(this._self, this._then);

  final _Citation _self;
  final $Res Function(_Citation) _then;

/// Create a copy of Citation
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? chunkId = freezed,Object? index = freezed,Object? snippet = freezed,Object? page = freezed,Object? label = freezed,}) {
  return _then(_Citation(
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
mixin _$ChatMessage {

 String get id; String get chatId; ChatMessageRole get role; String get content; List<Citation> get citations; DateTime? get createdAt;
/// Create a copy of ChatMessage
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChatMessageCopyWith<ChatMessage> get copyWith => _$ChatMessageCopyWithImpl<ChatMessage>(this as ChatMessage, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChatMessage&&(identical(other.id, id) || other.id == id)&&(identical(other.chatId, chatId) || other.chatId == chatId)&&(identical(other.role, role) || other.role == role)&&(identical(other.content, content) || other.content == content)&&const DeepCollectionEquality().equals(other.citations, citations)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,chatId,role,content,const DeepCollectionEquality().hash(citations),createdAt);

@override
String toString() {
  return 'ChatMessage(id: $id, chatId: $chatId, role: $role, content: $content, citations: $citations, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $ChatMessageCopyWith<$Res>  {
  factory $ChatMessageCopyWith(ChatMessage value, $Res Function(ChatMessage) _then) = _$ChatMessageCopyWithImpl;
@useResult
$Res call({
 String id, String chatId, ChatMessageRole role, String content, List<Citation> citations, DateTime? createdAt
});




}
/// @nodoc
class _$ChatMessageCopyWithImpl<$Res>
    implements $ChatMessageCopyWith<$Res> {
  _$ChatMessageCopyWithImpl(this._self, this._then);

  final ChatMessage _self;
  final $Res Function(ChatMessage) _then;

/// Create a copy of ChatMessage
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? chatId = null,Object? role = null,Object? content = null,Object? citations = null,Object? createdAt = freezed,}) {
  return _then(ChatMessage(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,chatId: null == chatId ? _self.chatId : chatId // ignore: cast_nullable_to_non_nullable
as String,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as ChatMessageRole,content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String,citations: null == citations ? _self.citations : citations // ignore: cast_nullable_to_non_nullable
as List<Citation>,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [ChatMessage].
extension ChatMessagePatterns on ChatMessage {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ChatMessage value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ChatMessage() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ChatMessage value)  $default,){
final _that = this;
switch (_that) {
case _ChatMessage():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ChatMessage value)?  $default,){
final _that = this;
switch (_that) {
case _ChatMessage() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String chatId,  ChatMessageRole role,  String content,  List<Citation> citations,  DateTime? createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ChatMessage() when $default != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String chatId,  ChatMessageRole role,  String content,  List<Citation> citations,  DateTime? createdAt)  $default,) {final _that = this;
switch (_that) {
case _ChatMessage():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String chatId,  ChatMessageRole role,  String content,  List<Citation> citations,  DateTime? createdAt)?  $default,) {final _that = this;
switch (_that) {
case _ChatMessage() when $default != null:
return $default(_that.id,_that.chatId,_that.role,_that.content,_that.citations,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc


class _ChatMessage implements ChatMessage {
  const _ChatMessage({required this.id, required this.chatId, required this.role, required this.content,  List<Citation> citations = const [], this.createdAt}): _citations = citations;
  

@override final  String id;
@override final  String chatId;
@override final  ChatMessageRole role;
@override final  String content;
 final  List<Citation> _citations;
@override@JsonKey() List<Citation> get citations {
  if (_citations is EqualUnmodifiableListView) return _citations;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_citations);
}

@override final  DateTime? createdAt;

/// Create a copy of ChatMessage
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ChatMessageCopyWith<_ChatMessage> get copyWith => __$ChatMessageCopyWithImpl<_ChatMessage>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ChatMessage&&(identical(other.id, id) || other.id == id)&&(identical(other.chatId, chatId) || other.chatId == chatId)&&(identical(other.role, role) || other.role == role)&&(identical(other.content, content) || other.content == content)&&const DeepCollectionEquality().equals(other._citations, _citations)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,chatId,role,content,const DeepCollectionEquality().hash(_citations),createdAt);

@override
String toString() {
  return 'ChatMessage(id: $id, chatId: $chatId, role: $role, content: $content, citations: $citations, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$ChatMessageCopyWith<$Res> implements $ChatMessageCopyWith<$Res> {
  factory _$ChatMessageCopyWith(_ChatMessage value, $Res Function(_ChatMessage) _then) = __$ChatMessageCopyWithImpl;
@override @useResult
$Res call({
 String id, String chatId, ChatMessageRole role, String content, List<Citation> citations, DateTime? createdAt
});




}
/// @nodoc
class __$ChatMessageCopyWithImpl<$Res>
    implements _$ChatMessageCopyWith<$Res> {
  __$ChatMessageCopyWithImpl(this._self, this._then);

  final _ChatMessage _self;
  final $Res Function(_ChatMessage) _then;

/// Create a copy of ChatMessage
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? chatId = null,Object? role = null,Object? content = null,Object? citations = null,Object? createdAt = freezed,}) {
  return _then(_ChatMessage(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,chatId: null == chatId ? _self.chatId : chatId // ignore: cast_nullable_to_non_nullable
as String,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as ChatMessageRole,content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String,citations: null == citations ? _self._citations : citations // ignore: cast_nullable_to_non_nullable
as List<Citation>,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

/// @nodoc
mixin _$Chat {

 String get id; String get userId; String get documentId; DateTime? get createdAt; DateTime? get updatedAt;
/// Create a copy of Chat
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChatCopyWith<Chat> get copyWith => _$ChatCopyWithImpl<Chat>(this as Chat, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Chat&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.documentId, documentId) || other.documentId == documentId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,userId,documentId,createdAt,updatedAt);

@override
String toString() {
  return 'Chat(id: $id, userId: $userId, documentId: $documentId, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $ChatCopyWith<$Res>  {
  factory $ChatCopyWith(Chat value, $Res Function(Chat) _then) = _$ChatCopyWithImpl;
@useResult
$Res call({
 String id, String userId, String documentId, DateTime? createdAt, DateTime? updatedAt
});




}
/// @nodoc
class _$ChatCopyWithImpl<$Res>
    implements $ChatCopyWith<$Res> {
  _$ChatCopyWithImpl(this._self, this._then);

  final Chat _self;
  final $Res Function(Chat) _then;

/// Create a copy of Chat
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? userId = null,Object? documentId = null,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(Chat(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,documentId: null == documentId ? _self.documentId : documentId // ignore: cast_nullable_to_non_nullable
as String,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [Chat].
extension ChatPatterns on Chat {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Chat value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Chat() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Chat value)  $default,){
final _that = this;
switch (_that) {
case _Chat():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Chat value)?  $default,){
final _that = this;
switch (_that) {
case _Chat() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String userId,  String documentId,  DateTime? createdAt,  DateTime? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Chat() when $default != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String userId,  String documentId,  DateTime? createdAt,  DateTime? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _Chat():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String userId,  String documentId,  DateTime? createdAt,  DateTime? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _Chat() when $default != null:
return $default(_that.id,_that.userId,_that.documentId,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc


class _Chat implements Chat {
  const _Chat({required this.id, required this.userId, required this.documentId, this.createdAt, this.updatedAt});
  

@override final  String id;
@override final  String userId;
@override final  String documentId;
@override final  DateTime? createdAt;
@override final  DateTime? updatedAt;

/// Create a copy of Chat
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ChatCopyWith<_Chat> get copyWith => __$ChatCopyWithImpl<_Chat>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Chat&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.documentId, documentId) || other.documentId == documentId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,userId,documentId,createdAt,updatedAt);

@override
String toString() {
  return 'Chat(id: $id, userId: $userId, documentId: $documentId, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$ChatCopyWith<$Res> implements $ChatCopyWith<$Res> {
  factory _$ChatCopyWith(_Chat value, $Res Function(_Chat) _then) = __$ChatCopyWithImpl;
@override @useResult
$Res call({
 String id, String userId, String documentId, DateTime? createdAt, DateTime? updatedAt
});




}
/// @nodoc
class __$ChatCopyWithImpl<$Res>
    implements _$ChatCopyWith<$Res> {
  __$ChatCopyWithImpl(this._self, this._then);

  final _Chat _self;
  final $Res Function(_Chat) _then;

/// Create a copy of Chat
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? userId = null,Object? documentId = null,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_Chat(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,documentId: null == documentId ? _self.documentId : documentId // ignore: cast_nullable_to_non_nullable
as String,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
