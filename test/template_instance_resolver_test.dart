import 'package:flutter_test/flutter_test.dart';
import 'package:mnd_core/mnd_core.dart';
import 'package:mnd_player/services/template_instance_resolver.dart';

ContentItem _item({
  required String id,
  String? templateRef,
}) {
  return ContentItem(
    id: id,
    type: 'text',
    text: 'Test $id',
    templateRef: templateRef,
    isTemplateMaster: false,
  );
}

ContentItem _masterItem({required String id}) {
  return ContentItem(
    id: id,
    type: 'container',
    isTemplateMaster: true,
    children: [
      ContentItem(
        id: 'child_${id}_0',
        type: 'text',
        text: 'Child 0 of $id',
      ),
    ],
  );
}

SavedNode _masterNode({required String id}) {
  return SavedNode(
    id: id,
    chapterId: 'ch1',
    title: 'Master Node $id',
    content: {
      'items': [
        {
          'id': 'ni_0',
          'type': 'text',
          'text': 'Node item 0',
        },
      ],
    },
  );
}

void main() {
  group('TemplateInstanceResolver', () {
    final tplMap = <String, TemplateItem>{
      'tpl_a': TemplateItem(
        id: 'tpl_a',
        name: 'Template A',
        kind: TemplateKind.content,
        payload: _masterItem(id: 'mi_a').toJson(),
        contentVersion: 1,
      ),
      'tpl_b': TemplateItem(
        id: 'tpl_b',
        name: 'Template B',
        kind: TemplateKind.content,
        payload: _masterItem(id: 'mi_b').toJson(),
        contentVersion: 2,
      ),
      'tpl_node': TemplateItem(
        id: 'tpl_node',
        name: 'Node Template',
        kind: TemplateKind.node,
        payload: _masterNode(id: 'mn_1').toJson(),
        contentVersion: 1,
      ),
    };

    group('ContentItem resolution', () {
      test('returns instance as-is when not a template instance', () {
        final resolver = TemplateInstanceResolver(templatesById: tplMap);
        final item = _item(id: 'plain');
        final result = resolver.resolveContentItem(item);

        expect(result.id, 'plain');
        expect(result.templateRef, isNull);
      });

      test('returns instance as-is when template not found', () {
        final resolver = TemplateInstanceResolver(templatesById: tplMap);
        final item = _item(id: 'inst', templateRef: 'missing_tpl');
        final result = resolver.resolveContentItem(item);

        expect(result.id, 'inst');
        expect(result.templateRef, 'missing_tpl');
      });

      test('resolves template instance with overridden fields', () {
        final resolver = TemplateInstanceResolver(templatesById: tplMap);
        final item = ContentItem(
          id: 'my_btn',
          type: 'button',
          text: 'Overridden',
          templateRef: 'tpl_a',
          isTemplateMaster: false,
          flex: 2,
          isHidden: true,
        );
        final result = resolver.resolveContentItem(item);

        expect(result.id, 'my_btn');
        expect(result.flex, 2);
        expect(result.isHidden, isTrue);
        expect(result.templateRef, 'tpl_a');
      });

      test('resolves children from master template', () {
        final resolver = TemplateInstanceResolver(templatesById: tplMap);
        final item = ContentItem(
          id: 'inst_with_kids',
          type: 'text',
          text: 'Instance',
          templateRef: 'tpl_a',
          isTemplateMaster: false,
        );
        final result = resolver.resolveContentItem(item);

        expect(result.children, isNotNull);
        expect(result.children!.length, 1);
        expect(result.children![0].type, 'text');
      });

      test('caches resolved content by key', () {
        final resolver = TemplateInstanceResolver(templatesById: tplMap);

        final item = ContentItem(
          id: 'cached_inst',
          type: 'text',
          text: 'Cached',
          templateRef: 'tpl_a',
          isTemplateMaster: false,
        );
        final r1 = resolver.resolveContentItem(item);

        final r2 = resolver.resolveContentItem(item);
        expect(r1.id, r2.id);
      });
    });

    group('tryResolveContentItem', () {
      test('detects missing template', () {
        final resolver = TemplateInstanceResolver(templatesById: tplMap);
        final item = _item(id: 'inst', templateRef: 'missing_tpl');
        final result = resolver.tryResolveContentItem(item);

        expect(result.missingTemplate, isTrue);
      });

      test('resolves and returns metadata', () {
        final resolver = TemplateInstanceResolver(templatesById: tplMap);
        final item = ContentItem(
          id: 'meta_inst',
          type: 'text',
          text: 'Meta',
          templateRef: 'tpl_a',
          isTemplateMaster: false,
        );
        final result = resolver.tryResolveContentItem(item);

        expect(result.missingTemplate, isFalse);
        expect(result.masterVersion, 1);
        expect(result.masterName, 'Template A');
      });
    });

    group('resolveTree', () {
      test('resolves recursively through children', () {
        final resolver = TemplateInstanceResolver(templatesById: tplMap);
        final item = ContentItem(
          id: 'root',
          type: 'container',
          children: [
            ContentItem(
              id: 'sub',
              type: 'text',
              text: 'Sub Instance',
              templateRef: 'tpl_a',
              isTemplateMaster: false,
            ),
          ],
        );
        final result = resolver.resolveTree(item);

        expect(result.children, isNotNull);
        expect(result.children!.length, 1);
        final resolved = result.children![0];
        expect(resolved.templateRef, 'tpl_a');
      });

      test('handles template instances without circular recursion', () {
        final resolver = TemplateInstanceResolver(templatesById: tplMap);
        final item = ContentItem(
          id: 'circ',
          type: 'text',
          text: 'Circular',
          templateRef: 'tpl_a',
          isTemplateMaster: false,
        );
        final result = resolver.resolveTree(item);

        expect(result.templateRef, 'tpl_a');
      });
    });

    group('Node resolution', () {
      test('resolves template-backed node', () {
        final resolver = TemplateInstanceResolver(templatesById: tplMap);
        final node = SavedNode(
          id: 'node_inst',
          chapterId: 'ch1',
          title: 'Instance Node',
          content: {},
          templateRef: 'tpl_node',
          isTemplateMaster: false,
        );
        final result = resolver.resolveNode(node);

        expect(result.id, 'node_inst');
        expect(result.title, 'Master Node mn_1');
        expect(result.templateRef, 'tpl_node');
        expect(result.templateVersion, 1);
        expect(result.content, isNotEmpty);
      });

      test('returns node as-is when not template-backed', () {
        final resolver = TemplateInstanceResolver(templatesById: tplMap);
        final node = SavedNode(
          id: 'plain_node',
          chapterId: 'ch1',
          title: 'Plain Node',
          content: {},
        );
        final result = resolver.resolveNode(node);

        expect(result.id, 'plain_node');
        expect(result.title, 'Plain Node');
      });

      test('returns node as-is when template missing', () {
        final resolver = TemplateInstanceResolver(templatesById: tplMap);
        final node = SavedNode(
          id: 'lost_node',
          chapterId: 'ch1',
          title: 'Lost',
          content: {},
          templateRef: 'missing_tpl',
          isTemplateMaster: false,
        );
        final result = resolver.resolveNode(node);

        expect(result.id, 'lost_node');
      });
    });

    group('Cache management', () {
      test('clearCache empties all caches', () {
        final resolver = TemplateInstanceResolver(templatesById: tplMap);
        final item = ContentItem(
          id: 'clear_test',
          type: 'text',
          text: 'Clear',
          templateRef: 'tpl_a',
          isTemplateMaster: false,
        );
        final r1 = resolver.resolveContentItem(item);

        resolver.clearCache();

        final r2 = resolver.resolveContentItem(item);
        expect(identical(r1, r2), isFalse);
      });

      test('invalidateTemplate removes only that template', () {
        final resolver = TemplateInstanceResolver(templatesById: tplMap);

        final itemA = ContentItem(
          id: 'i_a',
          type: 'text',
          text: 'A',
          templateRef: 'tpl_a',
          isTemplateMaster: false,
        );
        final itemB = ContentItem(
          id: 'i_b',
          type: 'text',
          text: 'B',
          templateRef: 'tpl_b',
          isTemplateMaster: false,
        );
        resolver.resolveContentItem(itemA);
        resolver.resolveContentItem(itemB);

        resolver.invalidateTemplate('tpl_a');

        final rA2 = resolver.resolveContentItem(itemA);
        final rB2 = resolver.resolveContentItem(itemB);

        expect(rA2.templateRef, 'tpl_a');
        expect(rB2.templateRef, 'tpl_b');
      });
    });

    group('resolveList', () {
      test('resolves all items in a list', () {
        final resolver = TemplateInstanceResolver(templatesById: tplMap);
        final items = [
          ContentItem(
            id: 'list_a',
            type: 'text',
            text: 'A',
            templateRef: 'tpl_a',
            isTemplateMaster: false,
          ),
          _item(id: 'list_b'),
        ];
        final result = resolver.resolveList(items);

        expect(result.length, 2);
        expect(result[0].templateRef, 'tpl_a');
        expect(result[1].templateRef, isNull);
      });
    });
  });
}
