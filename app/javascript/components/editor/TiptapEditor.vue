<template>
  <div class="editor-container rounded-lg border">
    <!-- <div class="fullscreen-toggle-button flex justify-end items-end ">
      <button @click="toggleFullscreen">
        <v-icon :icon="isFullscreen ? 'mdi-fullscreen-exit' : 'mdi-fullscreen'"></v-icon>
      </button>
    </div> -->

    <bubble-menu
      :editor="editor"
      :update-delay="0"
      v-if="editor"
      class="flex gap-4 w-fit p-1 rounded-md bg-surface"
    >
      <!-- Existing formatting buttons -->
      <!-- <button @click="editor.chain().focus().toggleBold().run()" class="hover:bg-success">
        <span class="rounded-md" :class="{ 'font-bold': editor.isActive('bold') }">
          Bold
        </span>
      </button>

      <button @click="editor.chain().focus().toggleItalic().run()" class="hover:bg-success">
        <span class="p-2" :class="{ 'italic': editor.isActive('italic') }">
          Italic
        </span>
      </button>

      <button @click="editor.chain().focus().toggleUnderline().run()" class="hover:bg-success">
        <span class="p-2" :class="{ 'underline': editor.isActive('underline') }">
          underline
        </span>
      </button>

      <button @click="editor.chain().focus().toggleStrike().run()" class="hover:bg-success">
        <span class="p-2" :class="{ 'line-through': editor.isActive('strike') }">
          Strike
        </span>
      </button>

      <button @click="editor.chain().focus().toggleCode().run()" class="hover:bg-success">
        <span class="p-2" :class="{ 'is-active': editor.isActive('code') }">
          CodeStyle
        </span>
      </button>

      <button @click="editor.chain().focus().toggleSubscript().run()" class="hover:bg-success">
        <span class="p-2" :class="{ 'is-active': editor.isActive('subscript') }">
          subscript
        </span>
      </button>

      <button @click="editor.chain().focus().toggleSuperscript().run()" class="hover:bg-success">
        <span class="p-2" :class="{ 'is-active': editor.isActive('superscript') }">
          superscript
        </span>
      </button>

      <button @click="editor.chain().focus().toggleCodeBlock().run()" :class="{ 'is-active': editor.isActive('codeBlock') }">
        code
      </button>

      <button @click="setLink" class="hover:bg-success">
        <span class="p-2 flex" :class="{ 'underline': editor.isActive('link') }">
          Set link
        </span>
      </button>
      <button @click="editor.chain().focus().unsetLink().run()" :disabled="!editor.isActive('link')" class="hover:bg-success">
        <span class="p-2 flex">
          Unset link
        </span>
      </button> -->

    <!-- Headings Dropdown -->
    <dropdown v-model="bubbleHeadingsMenu" :offset="8" bottom>
      <template v-slot:activator="{ props }">
        <button v-bind="props" class="hover:bg-success">
          <v-icon class="text-primary" icon="mdi-format-size"></v-icon>
        </button>
      </template>

      <template #dropdown>
        <v-list>
          <v-list-item @click="editor.chain().focus().toggleHeading({ level: 1 }).run()" :class="{ 'is-active': editor.isActive('heading', { level: 1 }) }">
            <v-list-item-content>
              <v-list-item-title><h1>Heading</h1></v-list-item-title>
            </v-list-item-content>
          </v-list-item>
          <v-list-item @click="editor.chain().focus().toggleHeading({ level: 2 }).run()" :class="{ 'is-active': editor.isActive('heading', { level: 2 }) }">
            <v-list-item-content>
              <v-list-item-title><h2>Heading</h2></v-list-item-title>
            </v-list-item-content>
          </v-list-item>
          <v-list-item @click="editor.chain().focus().toggleHeading({ level: 3 }).run()" :class="{ 'is-active': editor.isActive('heading', { level: 3 }) }">
            <v-list-item-content>
              <v-list-item-title><h3>Heading</h3></v-list-item-title>
            </v-list-item-content>
          </v-list-item>
          <v-list-item @click="editor.chain().focus().toggleHeading({ level: 4 }).run()" :class="{ 'is-active': editor.isActive('heading', { level: 4 }) }">
            <v-list-item-content>
              <v-list-item-title><h4>Heading</h4></v-list-item-title>
            </v-list-item-content>
          </v-list-item>
          <v-list-item @click="editor.chain().focus().toggleHeading({ level: 5 }).run()" :class="{ 'is-active': editor.isActive('heading', { level: 5 }) }">
            <v-list-item-content>
              <v-list-item-title><h5>Heading</h5></v-list-item-title>
            </v-list-item-content>
          </v-list-item>
        </v-list>
      </template>
    </dropdown>

    <!-- Font Family Dropdown -->
    <dropdown v-model="fontFamilyMenu" :offset="8" bottom>
      <template v-slot:activator="{ props }">
        <button v-bind="props" class="hover:bg-success">
          <v-icon class="text-primary" icon="mdi-format-font"></v-icon>
        </button>
      </template>

      <template #dropdown>
        <v-list>
          <v-list-item @click="editor.chain().focus().setFontFamily('Inter').run()" :class="{ 'is-active': editor.isActive('textStyle', { fontFamily: 'Inter' }) }">
            <v-list-item-content>
              <v-list-item-title>Inter</v-list-item-title>
            </v-list-item-content>
          </v-list-item>
          <v-list-item @click="editor.chain().focus().setFontFamily('Comic Sans MS, Comic Sans').run()" :class="{ 'is-active': editor.isActive('textStyle', { fontFamily: 'Comic Sans MS, Comic Sans' }) }">
            <v-list-item-content>
              <v-list-item-title>Comic Sans</v-list-item-title>
            </v-list-item-content>
          </v-list-item>
          <v-list-item @click="editor.chain().focus().setFontFamily('serif').run()" :class="{ 'is-active': editor.isActive('textStyle', { fontFamily: 'serif' }) }">
            <v-list-item-content>
              <v-list-item-title>Serif</v-list-item-title>
            </v-list-item-content>
          </v-list-item>
          <v-list-item @click="editor.chain().focus().setFontFamily('monospace').run()" :class="{ 'is-active': editor.isActive('textStyle', { fontFamily: 'monospace' }) }">
            <v-list-item-content>
              <v-list-item-title>Monospace</v-list-item-title>
            </v-list-item-content>
          </v-list-item>
          <v-list-item @click="editor.chain().focus().setFontFamily('cursive').run()" :class="{ 'is-active': editor.isActive('textStyle', { fontFamily: 'cursive' }) }">
            <v-list-item-content>
              <v-list-item-title>Cursive</v-list-item-title>
            </v-list-item-content>
          </v-list-item>
          <v-list-item @click="editor.chain().focus().unsetFontFamily().run()">
            <v-list-item-content>
              <v-list-item-title>Unset font family</v-list-item-title>
            </v-list-item-content>
          </v-list-item>
        </v-list>
      </template>
    </dropdown>

      <!-- Dropdown Menu for Formatting -->
      <dropdown v-model="formattingMenu" :offset="8" bottom>
        <template v-slot:activator="{ props }">
          <button v-bind="props" class="hover:bg-success">
            <v-icon class="text-primary" icon="mdi-format-color-highlight"></v-icon>
          </button>
        </template>

        <template #dropdown>
          <v-list>
            <v-list-item @click="editor.chain().focus().toggleBold().run()" :class="['hover:bg-info', { 'font-bold': editor.isActive('bold') }]">
              Bold
            </v-list-item>

            <v-list-item @click="editor.chain().focus().toggleItalic().run()" :class="['hover:bg-info', { 'italic': editor.isActive('italic') }]">
              Italic
            </v-list-item>

            <v-list-item @click="editor.chain().focus().toggleUnderline().run()" :class="['hover:bg-info', { 'underline': editor.isActive('underline') }]">
              Underline
            </v-list-item>

            <v-list-item @click="editor.chain().focus().toggleStrike().run()" :class="['hover:bg-info', { 'line-through': editor.isActive('strike') }]">
              Strike
            </v-list-item>

            <v-list-item @click="editor.chain().focus().toggleCode().run()" :class="['hover:bg-info', { 'is-active': editor.isActive('code') }]">
              CodeStyle
            </v-list-item>

            <v-list-item @click="editor.chain().focus().toggleSubscript().run()" :class="['hover:bg-info', { 'is-active': editor.isActive('subscript') }]">
              Subscript
            </v-list-item>

            <v-list-item @click="editor.chain().focus().toggleSuperscript().run()" :class="['hover:bg-info', { 'is-active': editor.isActive('superscript') }]">
              Superscript
            </v-list-item>

            <v-list-item @click="editor.chain().focus().toggleCodeBlock().run()" :class="['hover:bg-info', { 'is-active': editor.isActive('codeBlock') }]">
              Code
            </v-list-item>

            <v-list-item @click="setLink" :class="['hover:bg-info', { 'underline': editor.isActive('link') }]">
              Set link
            </v-list-item>
            <v-list-item @click="editor.chain().focus().unsetLink().run()" :disabled="!editor.isActive('link')" class="hover:bg-success">
              Unset link
            </v-list-item>
          </v-list>
        </template>
      </dropdown>

      <!-- Color Menu -->
      <dropdown
        v-model="colorMenu"
        :offset="8"
        bottom
      >
        <template v-slot:activator="{ props }">
          <button v-bind="props" class="hover:bg-success">
            <v-icon class="text-primary" icon="mdi-palette"></v-icon>
          </button>

        </template>

        <template #dropdown>
          <v-list>
            <v-list-item>
              <input
                type="color"
                @click.stop
                @input="editor.chain().focus().setColor($event.target.value).run()"
                :value="editor.getAttributes('textStyle').color"
                class="border rounded-md"
              >
            </v-list-item>
            <v-list-item
              v-for="color in colors"
              :key="color.name"
              @click="setColor(color.value)"
              :class="{ 'is-active': editor.isActive('textStyle', { color: color.value }) }"
            >
              <v-list-item-content>
                <v-list-item-title>
                  <span :style="{ color: color.value }">{{ color.name }}</span>
                </v-list-item-title>
              </v-list-item-content>
            </v-list-item>
            <v-list-item @click="unsetColor">
              <v-list-item-content>
                <v-list-item-title>Unset color</v-list-item-title>
              </v-list-item-content>
            </v-list-item>
          </v-list>
        </template>

      </dropdown>

      <!-- Dropdown Menu for Text Alignment -->
      <dropdown v-model="alignmentMenu" :offset="8" bottom>
        <template v-slot:activator="{ props }">
          <button v-bind="props" class="hover:bg-success">
            <v-icon class="text-primary" icon="mdi-format-align-left"></v-icon>
          </button>
        </template>

        <template #dropdown>
          <v-list>
            <v-list-item @click="editor.chain().focus().setTextAlign('left').run()" :class="{ 'is-active': editor.isActive({ textAlign: 'left' }) }">
              Left
            </v-list-item>
            <v-list-item @click="editor.chain().focus().setTextAlign('center').run()" :class="{ 'is-active': editor.isActive({ textAlign: 'center' }) }">
              Center
            </v-list-item>
            <v-list-item @click="editor.chain().focus().setTextAlign('right').run()" :class="{ 'is-active': editor.isActive({ textAlign: 'right' }) }">
              Right
            </v-list-item>
            <v-list-item @click="editor.chain().focus().setTextAlign('justify').run()" :class="{ 'is-active': editor.isActive({ textAlign: 'justify' }) }">
              Justify
            </v-list-item>
            <v-list-item @click="editor.chain().focus().unsetTextAlign().run()">
              Unset text align
            </v-list-item>
          </v-list>
        </template>
      </dropdown>

      <!-- Dropdown Menu for Text Highlight -->
      <dropdown v-model="highlightMenu" :offset="8" bottom>
        <template v-slot:activator="{ props }">
          <button v-bind="props" class="hover:bg-success">
            <v-icon class="text-primary" icon="mdi-marker"></v-icon>
          </button>
        </template>

        <template #dropdown>
          <v-list>
            <v-list-item  @click="editor.chain().focus().toggleHighlight().run()" :class="{ 'is-active': editor.isActive('highlight') }">
              Highlight
            </v-list-item>
            <v-list-item @click="editor.chain().focus().toggleHighlight({ color: '#ffc078' }).run()" :class="{ 'is-active': editor.isActive('highlight', { color: '#ffc078' }) }">
              Orange
            </v-list-item>
            <v-list-item @click="editor.chain().focus().toggleHighlight({ color: '#8ce99a' }).run()" :class="{ 'is-active': editor.isActive('highlight', { color: '#8ce99a' }) }">
              Green
            </v-list-item>
            <v-list-item @click="editor.chain().focus().toggleHighlight({ color: '#74c0fc' }).run()" :class="{ 'is-active': editor.isActive('highlight', { color: '#74c0fc' }) }">
              Blue
            </v-list-item>
            <v-list-item  @click="editor.chain().focus().toggleHighlight({ color: '#b197fc' }).run()" :class="{ 'is-active': editor.isActive('highlight', { color: '#b197fc' }) }">
              Purple
            </v-list-item>

            <v-list-item  @click="editor.chain().focus().toggleHighlight({ color: '#FF0000' }).run()" :class="{ 'is-active': editor.isActive('highlight', { color: '#b197fc' }) }">
              Red
            </v-list-item>
          </v-list>
        </template>
      </dropdown>
    </bubble-menu>

    <!-- Existing floating menu if needed -->
    <floating-menu :editor="editor" :tippy-options="{ duration: 1000 }" v-if="editor" class="flex gap-4 w-fit p-1 ml-5 rounded-md bg-surface">
      <!-- Headings Dropdown -->
      <dropdown v-model="headingsMenu" :offset="8" bottom>
        <template v-slot:activator="{ props }">
          <button v-bind="props" class="hover:bg-success">
            <v-icon class="text-primary hover:bg-info" icon="mdi-format-size"></v-icon>
          </button>
        </template>

        <template #dropdown>
          <v-list>
            <v-list-item @click="editor.chain().focus().toggleHeading({ level: 1 }).run()" :class="{ 'is-active': editor.isActive('heading', { level: 1 }) }">
              <v-list-item-content>
                <v-list-item-title><h1>Heading</h1></v-list-item-title>
              </v-list-item-content>
            </v-list-item>
            <v-list-item @click="editor.chain().focus().toggleHeading({ level: 2 }).run()" :class="{ 'is-active': editor.isActive('heading', { level: 2 }) }">
              <v-list-item-content>
                <v-list-item-title><h2>Heading</h2></v-list-item-title>
              </v-list-item-content>
            </v-list-item>
            <v-list-item @click="editor.chain().focus().toggleHeading({ level: 3 }).run()" :class="{ 'is-active': editor.isActive('heading', { level: 3 }) }">
              <v-list-item-content>
                <v-list-item-title><h3>Heading</h3></v-list-item-title>
              </v-list-item-content>
            </v-list-item>
            <v-list-item @click="editor.chain().focus().toggleHeading({ level: 4 }).run()" :class="{ 'is-active': editor.isActive('heading', { level: 4 }) }">
              <v-list-item-content>
                <v-list-item-title><h4>Heading</h4></v-list-item-title>
              </v-list-item-content>
            </v-list-item>
            <v-list-item @click="editor.chain().focus().toggleHeading({ level: 5 }).run()" :class="{ 'is-active': editor.isActive('heading', { level: 5 }) }">
              <v-list-item-content>
                <v-list-item-title><h5>Heading</h5></v-list-item-title>
              </v-list-item-content>
            </v-list-item>
          </v-list>
        </template>
      </dropdown>

      <!-- Lists Dropdown -->
      <dropdown v-model="listsMenu" :offset="8" bottom>
        <template v-slot:activator="{ props }">
          <button v-bind="props" class="hover:bg-success">
            <v-icon class="text-primary" icon="mdi-list-box-outline"></v-icon>
          </button>
        </template>

        <template #dropdown>
          <v-list>
            <v-list-item @click="editor.chain().focus().toggleBulletList().run()" :class="{ 'is-active': editor.isActive('bulletList') }">
              <v-list-item-content>
                <v-list-item-title>Unordered List</v-list-item-title>
              </v-list-item-content>
            </v-list-item>
            <v-list-item @click="editor.chain().focus().toggleOrderedList().run()" :class="{ 'is-active': editor.isActive('orderedList') }">
              <v-list-item-content>
                <v-list-item-title>Ordered List</v-list-item-title>
              </v-list-item-content>
            </v-list-item>
            <v-list-item @click="editor.chain().focus().toggleTaskList().run()" :class="{ 'is-active': editor.isActive('taskList') }">
              <v-list-item-content>
                <v-list-item-title>Task List</v-list-item-title>
              </v-list-item-content>
            </v-list-item>
          </v-list>
        </template>
      </dropdown>

      <!-- Other Elements Dropdown -->
      <dropdown v-model="otherElementsMenu" :offset="8" bottom>
        <template v-slot:activator="{ props }">
          <button v-bind="props" class="hover:bg-success">
            <v-icon class="text-primary" icon="mdi-tune-vertical"></v-icon>
          </button>
        </template>

        <template #dropdown>
          <v-list>
            <v-list-item @click="editor.chain().focus().toggleCodeBlock().run()" :class="{ 'is-active': editor.isActive('codeBlock') }">
              <v-list-item-content>
                <v-list-item-title>Code</v-list-item-title>
              </v-list-item-content>
            </v-list-item>
            <v-list-item @click="addVideo">
              <v-list-item-content>
                <v-list-item-title>YouTube</v-list-item-title>
              </v-list-item-content>
            </v-list-item>
            <v-list-item @click="addImage">
              <v-list-item-title>Set image</v-list-item-title>
            </v-list-item>
          </v-list>
        </template>
      </dropdown>
    </floating-menu>
    <editor-content ref="editorRef" :class="isFullscreen ? `fullscreen bg-info` : ''" :editor="editor" />
  </div>
</template>

<script setup lang="ts">
import { ref, onBeforeUnmount } from 'vue';
import { storeToRefs } from 'pinia';
import { FloatingMenu, BubbleMenu, EditorContent, Editor } from '@tiptap/vue-3';
import StarterKit from '@tiptap/starter-kit';
import Placeholder from '@tiptap/extension-placeholder';
import Text from '@tiptap/extension-text'
import Subscript from '@tiptap/extension-subscript'
import Superscript from '@tiptap/extension-superscript'
import Underline from '@tiptap/extension-underline'
import Link from '@tiptap/extension-link'
import BulletList from '@tiptap/extension-bullet-list'
import CodeBlock from '@tiptap/extension-code-block'
import Blockquote from '@tiptap/extension-blockquote'
import TaskItem from '@tiptap/extension-task-item'
import TaskList from '@tiptap/extension-task-list'
import ListItem from '@tiptap/extension-list-item'
import OrderedList from '@tiptap/extension-ordered-list'
import Youtube from '@tiptap/extension-youtube'
import { Color } from '@tiptap/extension-color'
import Dropdown from '@/components/button/Dropdown.vue';
import TextAlign from '@tiptap/extension-text-align'
import TextStyle from '@tiptap/extension-text-style'
import FontFamily from '@tiptap/extension-font-family'
import Focus from '@tiptap/extension-focus'
import Table from '@tiptap/extension-table'
import TableCell from '@tiptap/extension-table-cell'
import TableHeader from '@tiptap/extension-table-header'
import TableRow from '@tiptap/extension-table-row'
import Heading from '@tiptap/extension-heading'
import Highlight from '@tiptap/extension-highlight'
import Image from '@tiptap/extension-image'
import Collaboration from '@tiptap/extension-collaboration'
import CollaborationCursor from '@tiptap/extension-collaboration-cursor'
import * as Y from 'yjs'
import { WebrtcProvider } from 'y-webrtc'

const html = ref(null);
const formattingMenu = ref(false)
const colorMenu = ref(false)
const alignmentMenu = ref(false)
const fontFamilyMenu = ref(false)
const listsMenu = ref(false)
const otherElementsMenu = ref(false)
const bubbleHeadingsMenu = ref(false)
const headingsMenu = ref(false)
const highlightMenu = ref(false)
const isFullscreen = ref(false);
const editorRef = ref(null);
const ydoc = new Y.Doc()
const provider = ref(null);

if (!provider.value) {
  provider.value = new WebrtcProvider('tiptap-collaboration-cursor-extension', ydoc);
} else {
  console.warn("Provider for this room already exists!");
}

const emits = defineEmits(['on-save']);
const width = '640'
const height = '480'
const props = defineProps({
  content: {
    type: String,
    default: ''
  },
  lastname: {
    type: String,
    default: 'user99o'
  },
  extensions: {
    type: Array,
    default: () => []
  },
  isEditable: {
    type: Boolean,
    default: true,
  },
});

const editor = new Editor({
  editable: props.isEditable,
  extensions: [
    StarterKit,
    Text,
    Subscript,
    Superscript,
    Underline,
    BulletList,
    CodeBlock,
    Blockquote,
    TaskItem,
    ListItem,
    TaskList,
    Color,
    TextStyle,
    FontFamily,
    Table,
    TableCell,
    TableHeader,
    TableRow,
    Image,
    // Collaboration.configure({
    //   document: ydoc,
    // }),
    // CollaborationCursor.configure({
    //   provider: provider.value,
    //   user: {
    //     name: props.lastname,
    //     color: '#f183ac',
    //   },
    // }),
    Highlight.configure({ multicolor: true }),
    Heading.configure({
      levels: [1, 2, 3, 4, 5, 6],
    }),
    // Focus.configure({
    //   className: 'has-focus',
    //   mode: 'all',
    // }),
    TaskItem.configure({
      nested: true,
    }),
    OrderedList,
    Youtube,
    TextAlign.configure({
          types: ['heading', 'paragraph'],
        }),
    Link.configure({
      openOnClick: true,
      defaultProtocol: 'https',
    }),
    Placeholder.configure({
      // Use a placeholder:
      placeholder: 'Write something …',
      // Use different placeholders depending on the node type:
      // placeholder: ({ node }) => {
      //   if (node.type.name === 'heading') {
      //     return 'What’s the title?'
      //   }

      //   return 'Can you add some further context?'
      // },
    }),
    ...props.extensions // Include additional extensions if any
  ],
  content: props.content,
  autofocus: props.isEditable // Automatically focus the editor when it is initialized
});

const addImage = () => {
  const url = window.prompt('URL')

  if (url) {
    editor.chain().focus().setImageBlock({ src: url }).run()
  }
}

const addVideo = () => {
  const url = prompt('Enter YouTube URL')

  editor.commands.setYoutubeVideo({
    src: url,
    width: Math.max(320, parseInt(width, 10)) || 640,
    height: Math.max(180, parseInt(height, 10)) || 480,
  })
}

const setLink = () => {
  const previousUrl = editor.getAttributes('link').href
  const url = window.prompt('URL', previousUrl)

  if (url === null) {
    return
  }

  // empty
  if (url === '') {
    editor
      .chain()
      .focus()
      .extendMarkRange('link')
      .unsetLink()
      .run()

    return
  }

  // update link
  editor
    .chain()
    .focus()
    .extendMarkRange('link')
    .setLink({ href: url })
    .run()
}

const addNewText = () => {
  editor.chain().focus().insertContent('<p> </p>').run();
}

const colors = ref([
  { name: 'Red', value: '#F98181' },
  { name: 'Green', value: '#7FDB8A' },
  { name: 'Blue', value: '#70CFF8' },
  // Add more colors as needed
]);

const setColor = (color) => {
  editor.chain().focus().setColor(color).run();
}

const unsetColor = () => {
  editor.chain().focus().unsetColor().run();
}

const toggleFullscreen = () => {
  if (isFullscreen.value && !window.screenTop && !window.screenY) {
    exitFullscreen();
  } else {
    enterFullscreen();
  }
  isFullscreen.value = !isFullscreen.value;
};

const enterFullscreen = () => {
  const container = document.querySelector('.fullscreen-toggle-button').parentNode;
  if (container?.requestFullscreen) {
    container.requestFullscreen();
  } else if (container.mozRequestFullScreen) { /* Firefox */
    container.mozRequestFullScreen();
  } else if (container.webkitRequestFullscreen) { /* Chrome, Safari and Opera */
    container.webkitRequestFullscreen();
  } else if (container.msRequestFullscreen) { /* IE/Edge */
    container.msRequestFullscreen();
  }

  // Focus the editor after a short delay
  setTimeout(() => {
    if (editor) {
      editor?.view?.dom?.focus()
    }
  }, 300); // Adjust delay if needed
};

const exitFullscreen = () => {
  if (document.exitFullscreen) {
    document.exitFullscreen();
  } else if (document.mozCancelFullScreen) { /* Firefox */
    document.mozCancelFullScreen();
  } else if (document.webkitExitFullscreen) { /* Chrome, Safari and Opera */
    document.webkitExitFullscreen();
  } else if (document.msExitFullscreen) { /* IE/Edge */
    document.msExitFullscreen();
  }
};

onBeforeUnmount(() => {
  editor.destroy();
  if (provider.value) {
    provider.value.destroy();
    provider.value = null; // Clean up the provider reference
  }
});

editor.on('update', ({ editor }) => {
  html.value = editor.getHTML();
  emits('on-save', editor.getHTML());
});
</script>

<style lang="scss">
.editor-container {
  max-height: 500px; /* Set the max-height as per your requirement */
  overflow-y: auto; /* Enable vertical scrollbar */
  border: 1px solid #ccc; /* Optional: Add a border for better visibility */
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
  color: var(--white);
  font-family: 'JetBrainsMono', monospace;
  margin: 1.5rem 0;
  padding: 0.75rem 1rem;

  code {
    color: white;
    font-size: 0.8rem;
    padding: 0;
  }
}

.fullscreen {
  width: 100vw;
  z-index: 9999;
  padding: 5rem;

}

.fullscreen-toggle-button {
  z-index: 10000;
}
</style>
