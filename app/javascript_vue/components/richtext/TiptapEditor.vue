<template>
  <div id="tiptap" class="editor-container" ref="editorContainer">
    <TiptapToolbarGroups
      v-if="editorInstance && withMenu && editorInstance.isEditable"
      class="flex flex-wrap justify-center bg-surface"
      :editor-instance="editorInstance"
      @open-link-dialog="openLinkDialog"
      @open-image-dialog="showAddImageDialog.dialog = true"
      @open-table-dialog="showAddTableDialog.dialog = true"
      @open-youtube-dialog="showAddYoutubeDialog.dialog = true"
    />

    <bubble-menu
      v-if="editorInstance"
      :editor="editorInstance"
      :update-delay="0"
      :tippy-options="{ duration: 100 }"
      class="flex w-fit gap-4 rounded-md bg-surface p-1"
    >
      <TiptapToolbarGroups
        v-if="editorInstance"
        class="flex"
        :editor-instance="editorInstance"
        @open-link-dialog="openLinkDialog"
        @open-image-dialog="showAddImageDialog.dialog = true"
        @open-table-dialog="showAddTableDialog.dialog = true"
        @open-youtube-dialog="showAddYoutubeDialog.dialog = true"
      />
    </bubble-menu>

    <div class="flex flex-col">
      <EditorContent :class="isMobile ? '' : (editorInstance && editorInstance.isEditable ? 'pl-[30px]' :  '')" :editor="editorInstance" />

      <!-- <div class="mx-4 border-t border-gray-300 py-3 text-right text-sm text-gray-500">
        {{ editorInstance?.storage.characterCount.characters() }} characters,
        {{ editorInstance?.storage.characterCount.words() }} words
      </div> -->
    </div>

    <!-- <div>
      {{ contentResult }}
    </div> -->

    <TiptapLinkDialog
      ref="showLinkDialog"
      :current-url="currentLinkInDialog"
      @close="showLinkDialog.dialog = false"
      @update="updateLink"
    />
    <TiptapVideoDialog
      ref="showAddYoutubeDialog"
      @insert="insertYoutubeVideo"
      @close="showAddYoutubeDialog.dialog = false"
    />
    <TiptapTableDialog
      ref="showAddTableDialog"
      @close="showAddTableDialog.dialog = false"
      @insert="insertTable"
    />
    <TiptapImageDialog
      ref="showAddImageDialog"
      :record-id="recordId"
      @close="showAddImageDialog.dialog = false"
      @insert="insertImage"
    />
  </div>
</template>

<script setup lang="ts">
import { onBeforeUnmount, onMounted, ref, watch } from 'vue';
import { EditorContent, useEditor, BubbleMenu } from '@tiptap/vue-3';

import Paragraph from '@tiptap/extension-paragraph';
import Text from '@tiptap/extension-text';
import History from '@tiptap/extension-history';
import Heading from '@tiptap/extension-heading';
import Bold from '@tiptap/extension-bold';
import Italic from '@tiptap/extension-italic';
import Underline from '@tiptap/extension-underline';
import CodeBlock from '@tiptap/extension-code-block';
import Code from '@tiptap/extension-code';
import Strike from '@tiptap/extension-strike';
import ListItem from '@tiptap/extension-list-item';
import BulletList from '@tiptap/extension-bullet-list';
import OrderedList from '@tiptap/extension-ordered-list';
import Link from '@tiptap/extension-link';
import { Blockquote } from '@tiptap/extension-blockquote';
import { HardBreak } from '@tiptap/extension-hard-break';
import { CharacterCount } from '@tiptap/extension-character-count';
import { Youtube } from '@tiptap/extension-youtube';
import Dropcursor from '@tiptap/extension-dropcursor';
import { HorizontalRule } from '@tiptap/extension-horizontal-rule';
import { Table } from '@tiptap/extension-table';
import { TableHeader } from '@tiptap/extension-table-header';
import { TableRow } from '@tiptap/extension-table-row';
import { TableCell } from '@tiptap/extension-table-cell';
import Gapcursor from '@tiptap/extension-gapcursor';
import Image from '@/components/richtext/extenion/Image.js';
import TextAlign from '@tiptap/extension-text-align';
import Highlight from '@tiptap/extension-highlight';
import TaskItem from '@tiptap/extension-task-item';
import TaskList from '@tiptap/extension-task-list';
import Subscript from '@tiptap/extension-subscript';
import Superscript from '@tiptap/extension-superscript';
import { Color } from '@tiptap/extension-color';
import TextStyle from '@tiptap/extension-text-style';
import { storeToRefs } from 'pinia';
import DragHandle from '@/components/richtext/extenion/DraggableItem.js';
import TiptapToolbarGroups from '@/components/richtext/TiptapToolbarGroups.vue';
import Keymap from '@/components/richtext/extenion/Keymap.js';
import type DataTable from '@/models/table';
import TiptapLinkDialog from '@/components/richtext/TiptapLinkDialog.vue';
import TiptapVideoDialog from '@/components/richtext/TiptapVideoDialog.vue';
import TiptapTableDialog from '@/components/richtext/TiptapTableDialog.vue';
import TiptapImageDialog from '@/components/richtext/TiptapImageDialog.vue';
import Commands from '@/components/richtext/slash_commands/commands.js';
import suggestion from '@/components/richtext/slash_commands/suggestion.js';
import BaseDocument from '@/components/richtext/extenion/BaseDocument.js';
import Document from '@/components/richtext/extenion/Document.js';
import { useMobileStore } from '@/stores/mobile';
import ImageAPI from '@/apis/image.api';
import SearchAndReplace from "@sereneinserenade/tiptap-search-and-replace";

const { isMobile } = storeToRefs(useMobileStore());

const emits = defineEmits(['on-save']);

// Create Vuetify instance
const props = defineProps({
  allHeading: { type: Boolean, default: false },
  withBorder: {
    type: Boolean,
    default: true,
  },
  withPadding: {
    type: Boolean,
    default: true,
  },
  content: {
    type: String,
    default: '',
  },
  lastname: {
    type: String,
    default: 'user99o',
  },
  extensions: {
    type: Array,
    default: () => [],
  },
  isEditable: {
    type: Boolean,
    default: true,
  },
  withMenu: {
    type: Boolean,
    default: false,
  },
  recordId: {
    type: Number,
    default: null,
  },
});

const contentResult = ref<string>();
const currentLinkInDialog = ref<string | undefined>();
const showLinkDialog = ref<boolean>();
const showAddYoutubeDialog = ref<boolean>(false);
const showAddTableDialog = ref<boolean>(false);
const showAddImageDialog = ref<boolean>(false);
const dragHandleRef = ref(null);
const selectedNode = ref(null);
const editorInstance = useEditor({
  content: props.content,
  autofocus: props.isEditable, // Automatically focus the editor when it is initialized
  editable: props.isEditable,
  recordId: props.recordId,
  editorProps: {
    attributes: {
      class: 'blog',
    },
  },
  extensions: [
    BaseDocument,
    Document,
    Paragraph,
    Text,
    History,
    Heading.configure({
      levels: [1, 2, 3, 4, 5, 6],
    }),
    Bold,
    Italic,
    Underline,
    Color,
    TextStyle,
    Highlight.configure({ multicolor: true }),
    ListItem,
    TaskList,
    TaskItem.configure({
      nested: true,
    }),
    CodeBlock,

    Commands.configure({
      suggestion,
    }),
    Code,
    Keymap,
    SearchAndReplace.configure(),
    DragHandle,
    Strike,
    ListItem,
    TextAlign.configure({
      types: ['heading', 'paragraph'],
    }),
    BulletList,
    OrderedList,
    Link.configure({
      openOnClick: true,
    }),
    HardBreak,
    Blockquote,
    CharacterCount,
    Youtube,
    Dropcursor.configure({
      width: 2,
      color: '#2563eb',
    }),
    HorizontalRule,
    Table.configure({
      resizable: false,
      allowTableNodeSelection: true,
    }),
    TableRow,
    TableHeader,
    TableCell,
    Gapcursor,
    Subscript,
    Superscript,
    Image,
  ],
  onUpdate: ({ editor }) => {
    contentResult.value = editor.getHTML();
    emits('on-save', editor.getHTML());
  },
});

function openLinkDialog() {
  currentLinkInDialog.value = editorInstance.value?.getAttributes('link').href;
  showLinkDialog.value.dialog = true;
}

function updateLink(value?: string) {
  if (!value) {
    editorInstance.value?.chain().focus().extendMarkRange('link').unsetLink().run();
    return;
  }

  editorInstance.value?.chain().focus().extendMarkRange('link').setLink({ href: value }).run();
}

function insertImage(url: string) {
  editorInstance.value?.chain().focus().setImageBlock({ src: url }).run();
}

function insertYoutubeVideo(url: string) {
  editorInstance.value?.commands.setYoutubeVideo({
    src: url,
    width: 400,
    height: 300,
  });
}

function insertTable(table: DataTable) {
  editorInstance.value
    ?.chain()
    .focus()
    .insertTable({
      rows: table.rows,
      cols: table.columns,
      withHeaderRow: table.withHeader,
    })
    .run();
}


const handleDrop = async (event: DragEvent) => {
  event.preventDefault()

  const files = event.dataTransfer?.files
  if (!files.length) {
    return
  }

  // Start a chain and focus on the editor
  const chain = editorInstance.value.chain().focus()

  for (let i = 0; i < files.length; i++) {
    const file = files[i]

    if (!file?.type?.startsWith('image/')) {
      // Ensure the dropped file is an image
      continue // Skip non-image files
    }

    try {
      // Prepare the image file for upload
      const formData = new FormData()
      formData.append('file', file)
      formData.append("note_id", props.recordId)

      // Upload the image to the backend
      const imageUrl = await ImageAPI.createImage(formData)

      // Queue each image insertion in the chain
      chain.setImageBlock({ src: imageUrl })
    } catch (error) {
      console.error('Image upload failed', error)
    }
  }

  // Run the entire chain once all images are processed
  chain.run()
}


onMounted(() => {
  setTimeout(() => (contentResult.value = editorInstance.value?.getHTML()), 250);

  const editorContainer = document.querySelector('.editor-container')
  if (editorContainer) {
    editorContainer.addEventListener('drop', handleDrop)
    editorContainer.addEventListener('dragover', (event) => event.preventDefault()) // Prevent default dragover behavior
  }
});

onBeforeUnmount(() => {
    const editorContainer = document.querySelector('.editor-container')
  if (editorContainer) {
    editorContainer.removeEventListener('drop', handleDrop)
    editorContainer.removeEventListener('dragover', (event) => event.preventDefault())
  }
  editorInstance.value?.destroy();
});
</script>

<style>
.editor-container {
  overflow-y: auto; /* Enable vertical scrollbar */
  padding: 10px; /* Optional: Add some padding */
  box-sizing: border-box; /* Ensure padding and border are included in the total height and width */
}

/* Remove focus-visible outline */
.editor-container .ProseMirror:focus-visible {
  outline: none;
}

pre {
  background: rgb(44, 21, 21);
  border-radius: 0.5rem;
  white-space: pre !important;
  overflow-y: auto;
  color: var(--white);
  font-family: 'JetBrainsMono', monospace;
  margin: 0.5rem 0;
  padding: 0.75rem 1rem;

  code {
    color: white;
    font-size: 0.8rem;
    padding: 0;
  }
}

code {
  background: rgb(44, 21, 21);
  font-family: 'JetBrainsMono', monospace;
  color: white;
  font-size: 0.8rem;
  border-radius: 0.4rem;
  padding: 0.25em 0.3em;
}
</style>
