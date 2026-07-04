import 'package:flutter_test/flutter_test.dart';

import 'package:cc_resume_app/data/resume_knowledge.dart';
import 'package:cc_resume_app/pdf/resume_constants.dart';

void main() {
  group('ResumeConstants', () {
    test('every experience has a non-empty period', () {
      for (final exp in ResumeConstants.experiences) {
        expect(exp.period, isNotEmpty, reason: '${exp.title} missing period');
        expect(exp.location, isNot(contains('|')),
            reason: '${exp.title} location still contains the period');
      }
    });
  });

  group('ResumeKnowledge', () {
    test('system prompt is grounded in resume facts', () {
      final prompt = ResumeKnowledge.buildSystemPrompt();
      expect(prompt, contains(ResumeConstants.name));
      expect(prompt, contains('Medisa'));
      expect(prompt, contains(ResumeConstants.contactEmail));
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
