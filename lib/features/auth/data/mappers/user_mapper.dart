// features/auth/data/mappers/user_mapper.dart

import 'package:snacky/features/auth/data/models/user_model.dart';
import 'package:snacky/features/auth/domain/entities/user_entity.dart';

extension UserModelMapper on UserModel {
  UserEntity toEntity() {
    return UserEntity(
      id: id,
      nom: nom, // Changé de name à nom
      email: email,
      role: role,
      token: token,
    );
  }
}

extension UserEntityMapper on UserEntity {
  UserModel toModel() {
    return UserModel(
      id: id,
      nom: nom, // Changé de name à nom
      email: email,
      role: role,
      token: token,
    );
  }
}
