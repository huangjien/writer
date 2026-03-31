import 'package:flutter_test/flutter_test.dart';
import 'package:writer/models/skill.dart';

void main() {
  group('Skill', () {
    test('fromJson parses all fields', () {
      final skill = Skill.fromJson({
        'id': 's1',
        'name': 'Test Skill',
        'description': 'A test',
        'template': <String, dynamic>{'key': 'value'},
        'author': 'user1',
        'owners': ['user1', 'user2'],
        'is_public': true,
        'is_active': true,
        'is_verified': false,
        'created_at': '2026-01-01',
      });

      expect(skill.id, 's1');
      expect(skill.name, 'Test Skill');
      expect(skill.description, 'A test');
      expect(skill.template, {'key': 'value'});
      expect(skill.author, 'user1');
      expect(skill.owners, ['user1', 'user2']);
      expect(skill.isPublic, true);
      expect(skill.isActive, true);
      expect(skill.isVerified, false);
      expect(skill.createdAt, '2026-01-01');
    });

    test('fromJson uses defaults for nullable bool fields', () {
      final skill = Skill.fromJson({
        'id': 's1',
        'name': 'Test',
        'template': <String, dynamic>{},
        'author': 'u',
        'owners': [],
        'created_at': '2026-01-01',
      });

      expect(skill.isPublic, false);
      expect(skill.isActive, true);
      expect(skill.isVerified, false);
    });

    test('toJson round-trips', () {
      final json = {
        'id': 's1',
        'name': 'Test',
        'description': 'desc',
        'template': <String, dynamic>{'k': 'v'},
        'author': 'u',
        'owners': ['u'],
        'is_public': true,
        'is_active': false,
        'is_verified': true,
        'created_at': '2026-01-01',
      };
      final skill = Skill.fromJson(json);
      final out = skill.toJson();
      expect(out, json);
    });

    test('toJson omits null description', () {
      final skill = Skill(
        id: 's1',
        name: 'Test',
        template: {},
        author: 'u',
        owners: [],
        isPublic: false,
        isActive: true,
        isVerified: false,
        createdAt: '2026-01-01',
      );
      expect(skill.toJson().containsKey('description'), false);
    });
  });

  group('CreateSkillRequest', () {
    test('toJson includes description when present', () {
      final req = CreateSkillRequest(
        name: 'Test',
        description: 'desc',
        template: {'k': 'v'},
      );
      expect(req.toJson(), {
        'name': 'Test',
        'description': 'desc',
        'template': <String, dynamic>{'k': 'v'},
      });
    });

    test('toJson omits description when null', () {
      final req = CreateSkillRequest(name: 'Test', template: {});
      expect(req.toJson().containsKey('description'), false);
    });
  });

  group('UpdateSkillRequest', () {
    test('toJson includes only non-null fields', () {
      final req = UpdateSkillRequest(name: 'New');
      final json = req.toJson();
      expect(json, {'name': 'New'});
      expect(json.containsKey('description'), false);
      expect(json.containsKey('template'), false);
    });

    test('toJson includes all fields when set', () {
      final req = UpdateSkillRequest(
        name: 'N',
        description: 'D',
        template: {'k': 'v'},
      );
      expect(req.toJson().length, 3);
    });
  });

  group('ExecuteSkillRequest', () {
    test('toJson serializes correctly', () {
      final req = ExecuteSkillRequest(
        skillName: 'my-skill',
        input: {'prompt': 'hello'},
      );
      expect(req.toJson(), {
        'skill_name': 'my-skill',
        'input': {'prompt': 'hello'},
      });
    });
  });

  group('ExecuteSkillResponse', () {
    test('fromJson and toJson round-trip', () {
      final resp = ExecuteSkillResponse.fromJson({'result': 'some result'});
      expect(resp.result, 'some result');
      expect(resp.toJson(), {'result': 'some result'});
    });
  });

  group('ValidateSkillRequest', () {
    test('toJson serializes template', () {
      final req = ValidateSkillRequest(template: {'k': 'v'});
      expect(req.toJson(), {
        'template': <String, dynamic>{'k': 'v'},
      });
    });
  });

  group('ValidateSkillResponse', () {
    test('fromJson with errors', () {
      final resp = ValidateSkillResponse.fromJson({
        'is_valid': false,
        'errors': ['error1', 'error2'],
      });
      expect(resp.isValid, false);
      expect(resp.errors, ['error1', 'error2']);
    });

    test('fromJson without errors', () {
      final resp = ValidateSkillResponse.fromJson({'is_valid': true});
      expect(resp.isValid, true);
      expect(resp.errors, null);
    });

    test('toJson omits errors when null', () {
      final resp = ValidateSkillResponse(isValid: true);
      expect(resp.toJson().containsKey('errors'), false);
    });
  });

  group('SkillsListResponse', () {
    test('fromJson parses list', () {
      final resp = SkillsListResponse.fromJson({
        'skills': [
          {
            'id': 's1',
            'name': 'A',
            'template': <String, dynamic>{},
            'author': 'u',
            'owners': [],
            'created_at': '2026-01-01',
          },
        ],
        'total': 1,
      });
      expect(resp.skills.length, 1);
      expect(resp.skills[0].id, 's1');
      expect(resp.total, 1);
    });

    test('fromJson handles null skills', () {
      final resp = SkillsListResponse.fromJson({'total': 0});
      expect(resp.skills, isEmpty);
      expect(resp.total, 0);
    });
  });

  group('SkillVersion', () {
    test('fromJson and toJson round-trip', () {
      final json = {
        'version': '1.0',
        'created_at': '2026-01-01',
        'created_by': 'user1',
      };
      final v = SkillVersion.fromJson(json);
      expect(v.version, '1.0');
      expect(v.createdBy, 'user1');
      expect(v.toJson(), json);
    });

    test('toJson omits createdBy when null', () {
      final v = SkillVersion(version: '1.0', createdAt: '2026-01-01');
      expect(v.toJson().containsKey('created_by'), false);
    });
  });

  group('SkillVersionsResponse', () {
    test('fromJson parses versions', () {
      final resp = SkillVersionsResponse.fromJson({
        'skill_id': 's1',
        'versions': [
          {'version': '1.0', 'created_at': '2026-01-01'},
        ],
      });
      expect(resp.skillId, 's1');
      expect(resp.versions.length, 1);
    });

    test('fromJson handles null versions', () {
      final resp = SkillVersionsResponse.fromJson({'skill_id': 's1'});
      expect(resp.versions, isEmpty);
    });
  });

  group('AddOwnerRequest', () {
    test('toJson serializes ownerId', () {
      final req = AddOwnerRequest(ownerId: 'user1');
      expect(req.toJson(), {'owner_id': 'user1'});
    });
  });
}
