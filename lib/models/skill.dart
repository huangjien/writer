class Skill {
  final String id;
  final String name;
  final String? description;
  final Map<String, dynamic> template;
  final String author;
  final List<String> owners;
  final bool isPublic;
  final bool isActive;
  final bool isVerified;
  final String createdAt;

  Skill({
    required this.id,
    required this.name,
    this.description,
    required this.template,
    required this.author,
    required this.owners,
    required this.isPublic,
    required this.isActive,
    required this.isVerified,
    required this.createdAt,
  });

  factory Skill.fromJson(Map<String, dynamic> json) {
    return Skill(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      template: json['template'] as Map<String, dynamic>,
      author: json['author'] as String,
      owners: (json['owners'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      isPublic: json['is_public'] as bool? ?? false,
      isActive: json['is_active'] as bool? ?? true,
      isVerified: json['is_verified'] as bool? ?? false,
      createdAt: json['created_at'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      if (description != null) 'description': description,
      'template': template,
      'author': author,
      'owners': owners,
      'is_public': isPublic,
      'is_active': isActive,
      'is_verified': isVerified,
      'created_at': createdAt,
    };
  }
}

class CreateSkillRequest {
  final String name;
  final String? description;
  final Map<String, dynamic> template;

  CreateSkillRequest({
    required this.name,
    this.description,
    required this.template,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      if (description != null) 'description': description,
      'template': template,
    };
  }
}

class UpdateSkillRequest {
  final String? name;
  final String? description;
  final Map<String, dynamic>? template;

  UpdateSkillRequest({this.name, this.description, this.template});

  Map<String, dynamic> toJson() {
    return {
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (template != null) 'template': template,
    };
  }
}

class ExecuteSkillRequest {
  final String skillName;
  final Map<String, dynamic> input;

  ExecuteSkillRequest({required this.skillName, required this.input});

  Map<String, dynamic> toJson() {
    return {'skill_name': skillName, 'input': input};
  }
}

class ExecuteSkillResponse {
  final dynamic result;

  ExecuteSkillResponse({required this.result});

  factory ExecuteSkillResponse.fromJson(Map<String, dynamic> json) {
    return ExecuteSkillResponse(result: json['result']);
  }

  Map<String, dynamic> toJson() {
    return {'result': result};
  }
}

class ValidateSkillRequest {
  final Map<String, dynamic> template;

  ValidateSkillRequest({required this.template});

  Map<String, dynamic> toJson() {
    return {'template': template};
  }
}

class ValidateSkillResponse {
  final bool isValid;
  final List<String>? errors;

  ValidateSkillResponse({required this.isValid, this.errors});

  factory ValidateSkillResponse.fromJson(Map<String, dynamic> json) {
    return ValidateSkillResponse(
      isValid: json['is_valid'] as bool,
      errors: (json['errors'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'is_valid': isValid, if (errors != null) 'errors': errors};
  }
}

class SkillsListResponse {
  final List<Skill> skills;
  final int total;

  SkillsListResponse({required this.skills, required this.total});

  factory SkillsListResponse.fromJson(Map<String, dynamic> json) {
    return SkillsListResponse(
      skills:
          (json['skills'] as List<dynamic>?)
              ?.map((e) => Skill.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      total: json['total'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {'skills': skills.map((e) => e.toJson()).toList(), 'total': total};
  }
}

class SkillVersion {
  final String version;
  final String createdAt;
  final String? createdBy;

  SkillVersion({
    required this.version,
    required this.createdAt,
    this.createdBy,
  });

  factory SkillVersion.fromJson(Map<String, dynamic> json) {
    return SkillVersion(
      version: json['version'] as String,
      createdAt: json['created_at'] as String,
      createdBy: json['created_by'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'version': version,
      'created_at': createdAt,
      if (createdBy != null) 'created_by': createdBy,
    };
  }
}

class SkillVersionsResponse {
  final String skillId;
  final List<SkillVersion> versions;

  SkillVersionsResponse({required this.skillId, required this.versions});

  factory SkillVersionsResponse.fromJson(Map<String, dynamic> json) {
    return SkillVersionsResponse(
      skillId: json['skill_id'] as String,
      versions:
          (json['versions'] as List<dynamic>?)
              ?.map((e) => SkillVersion.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'skill_id': skillId,
      'versions': versions.map((e) => e.toJson()).toList(),
    };
  }
}

class AddOwnerRequest {
  final String ownerId;

  AddOwnerRequest({required this.ownerId});

  Map<String, dynamic> toJson() {
    return {'owner_id': ownerId};
  }
}
