<template>
  <node-view-wrapper as="div" class="group relative mx-auto flex w-full gap-2">
    <div
      v-if="editor.isEditable"
      class="absolute -top-0.5 items-center transition-opacity group-focus-within:flex group-hover:flex group-focus:flex"
      :class="dialog ? 'flex opacity-100' : 'hidden', isMobile ? '-left-[25px]' : '-left-[55px]'"
    >
      <v-btn v-if="!isMobile" density="compact" variant="text" icon="mdi-dots" @click="handleAdd">
        <IconPlus height="32" widht="32" />
      </v-btn>
      <v-dialog
        v-model="dialog"
        :scrim="false"
        :absolute="true"
        :close-on-content-click="true"
        :contained="true"
        content-class="top-2"
      >
        <template #activator="{ props }">
          <v-btn
            contenteditable="false"
            draggable="true"
            data-drag-handle
            variant="text"
            density="compact"
            icon="mdi mdi-dots-grid"
            @click="dialog = !dialog"
          >
          </v-btn>
        </template>

        <template #default>
          <div class="bg-red w-[30px] gap-2 bg-surface">
            <v-list-item-title>
              <TiptapToolbarButton label="Clear formatting" @click="clearFormatting">
                <IconClearFormatting class="h-5 w-5" />
              </TiptapToolbarButton>
            </v-list-item-title>
            <v-list-item-title>
              <TiptapToolbarButton label="Delete" @click="deleteCurrentBlock">
                <IconTrash class="h-5 w-5" />
              </TiptapToolbarButton>
            </v-list-item-title>

            <v-list-item-title>
              <TiptapToolbarButton label="Duplicate" @click="duplicateCurrentBlock">
                <IconCopy class="h-5 w-5" />
              </TiptapToolbarButton>
            </v-list-item-title>
            <v-list-item-title>
              <TiptapToolbarButton label="Copy" @click="copyNodeToClipboard">
                <IconClipboard class="h-5 w-5" />
              </TiptapToolbarButton>
            </v-list-item-title>
          </div>
        </template>
      </v-dialog>
    </div>
    <node-view-content class="content wrapper w-full overflow-x-auto overflow-y-hidden rounded" />
  </node-view-wrapper>
</template>

<script setup>
import {
  IconPlus,
  IconGridDots,
  IconRestore,
  IconCopy,
  IconClipboard,
  IconTrash,
  IconAlignLeft,
  IconClearFormatting,
} from '@tabler/icons-vue';
import { ref } from 'vue';
import { NodeViewContent, nodeViewProps, NodeViewWrapper } from '@tiptap/vue-3';
import { storeToRefs } from 'pinia';
import { useMobileStore } from "@/stores/mobile";

const { isMobile } = storeToRefs(useMobileStore());
import TiptapToolbarButton from '@/components/richtext/TiptapToolbarButton.vue';

const dialog = ref(false);
const props = defineProps(nodeViewProps);

const clearFormatting = () => {
  const nodePos = props.getPos();
  props.editor.chain().setNodeSelection(nodePos).unsetAllMarks().clearNodes().run();
  // selectNodeText
  // props.editor
  //   .chain()
  //   .focus()
  //   .setTextSelection({ from: nodePos, to: nodePos + nodeTextLength })
  //   .run();
};

const deleteCurrentBlock = () => {
  const node = props.node;
  const nodePos = props.getPos();

  props.editor
    .chain()
    .setMeta('hideDragHandle', true)
    .setNodeSelection(nodePos)
    .deleteSelection()
    .run();
};

const copyNodeToClipboard = () => {
  const copiedText = props.node.textContent;
  if (copiedText) {
    navigator.clipboard.writeText(copiedText);
  }
};

const duplicateCurrentBlock = () => {
  const node = props.node;
  const nodePos = props.getPos();
  props.editor.commands.setNodeSelection(nodePos);

  const { $anchor } = props.editor.state.selection;
  const selectedNode = $anchor.node(1) || props.editor.state.selection.node;

  props.editor
    .chain()
    .setMeta('hideDragHandle', true)
    .insertContentAt(nodePos + (node?.nodeSize || 0), node.toJSON())
    .run();
};

const handleAdd = () => {
  const node = props.node;
  const nodePos = props.getPos() + props.node.nodeSize;

  if (nodePos !== -1) {
    props.editor
      .chain()
      .insertContentAt(nodePos, {
        type: 'draggableItem',
        content: [
          {
            type: 'paragraph',
            attrs: {
              class: null,
              textAlign: 'left',
            },
            content: [
              {
                text: '/',
                type: 'text',
              },
            ],
          },
        ],
      })
      .focus(nodePos + 3)
      .run();
  }
};
</script>
