enum AuthFailure {
  usernameTaken,
  emailTaken,
  invalidCredentials,
  invalidCode,
  unknownAccount,
}

class AuthResult<T> {
  final T? value;
  final AuthFailure? failure;

  const AuthResult._(this.value, this.failure);

  const AuthResult.success(T value) : this._(value, null);

  const AuthResult.failure(AuthFailure failure) : this._(null, failure);

  bool get isSuccess => failure == null;
}
