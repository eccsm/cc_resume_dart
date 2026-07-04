import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:cc_resume_app/data/resume_knowledge.dart';
import 'package:cc_resume_app/models/resume.dart';

void main() {
  setUpAll(() {
    // Parse the same resume.json the deployed app fetches. Emit it first:
    //   cd ../site && node scripts/emit-resume-json.mjs
    final file = File('../site/public/data/resume.json');
    expect(file.existsSync(), isTrue,
        reason: 'resume.json missing — run site/scripts/emit-resume-json.mjs');
    Resume.current = Resume.fromJson(
        jsonDecode(file.readAsStringSync()) as Map<String, dynamic>);
  });

  group('Resume model', () {
    test('parses all experiences with non-empty periods', () {
      expect(Resume.I.experiences, isNotEmpty);
      for (final exp in Resume.I.experiences) {
        expect(exp.periodLabel, isNotEmpty,
            reason: '${exp.company} missing period');
        expect(exp.points, isNotEmpty, reason: '${exp.company} has no points');
      }
    });

    test('composed getters produce content', () {
      expect(Resume.I.educationSummary, contains('|'));
      expect(Resume.I.languages, contains('Turkish'));
      expect(Resume.I.certificates, isNotEmpty);
      expect(Resume.I.skills, isNotEmpty);
    });
  });

  group('ResumeKnowledge', () {
    test('system prompt is grounded in resume facts', () {
      final prompt = ResumeKnowledge.buildSystemPrompt();
      expect(prompt, contains(Resume.I.name));
      expect(prompt, contains('Medisa'));
      expect(prompt, contains(Resume.I.contactEmail));
    });

    test('system prompt includes pinned repos when provided', () {
      final prompt = ResumeKnowledge.buildSystemPrompt(
          pinnedRepos: ['linguana (Dart): language learning app']);
      expect(prompt, contains('linguana'));
    });

    test('keyword responses cover the main topics', () {
      expect(ResumeKnowledge.keywordResponse('Tell me about his Java skills'),
          contains('Java'));
      expect(ResumeKnowledge.keywordResponse('kafka experience?'),
          contains('Kafka'));
      expect(ResumeKnowledge.keywordResponse('anything with AI?'),
          contains('GenAI'));
    });

    test('pdf intent detection', () {
      expect(ResumeKnowledge.wantsPdf('can I download the CV?'), isTrue);
      expect(ResumeKnowledge.wantsPdf('what about kafka?'), isFalse);
    });

    test('section navigation intents', () {
      expect(ResumeKnowledge.sectionForQuery('show me his projects'),
          'online_presence');
      expect(ResumeKnowledge.sectionForQuery('what is his tech stack'),
          'skills');
      expect(ResumeKnowledge.sectionForQuery('hello'), isNull);
    });
  });
}
