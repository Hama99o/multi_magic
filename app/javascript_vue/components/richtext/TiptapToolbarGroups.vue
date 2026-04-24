<template>
  <div id="tiptap-toolbar" :class="isMobile ? 'flex flex-wrap' :  '' ">
    <TiptapToolbarGroup>
      <TiptapToolbarButton
        label="Undo"
        :disabled="!editorInstance?.can().chain().focus().undo().run()"
        @click="editorInstance?.chain().focus().undo().run()"
      >
        <IconArrowBackUp class="h-5 w-5" />
      </TiptapToolbarButton>
      <TiptapToolbarButton
        label="Redo"
        :disabled="!editorInstance?.can().chain().focus().redo().run()"
        @click="editorInstance?.chain().focus().redo().run()"
      >
        <IconArrowForwardUp class="h-5 w-5" />
      </TiptapToolbarButton>
    </TiptapToolbarGroup>
    <TiptapToolbarGroup>
      <!-- <div class="w-[80px]">
        <v-select
          v-model="select"
          item-title="state"
          item-value="abbr"
          variant="solo"
          :items="items"
          single-line
        >
          <template #item="{ item }">
            <div class="flex items-center cursor-pointer hover:grey text-nowrap hover:bg-sky-700">
              <span class="mr-1 cursor-pointer">{{ item.raw}}</span>
            </div>
          </template>
          <template #selection="{ item }">
            <div class="flex items-center  text-nowrap ">
              <span class="mr-1">{{ item.raw }}</span>
            </div>
          </template>
        </v-select>
      </div> -->
      <TiptapToolbarButton
        label="Heading 1"
        :is-active="editorInstance?.isActive('heading', { level: 1 })"
        @click="editorInstance?.chain().focus().toggleHeading({ level: 1 }).run()"
      >
        <IconH1 class="h-5 w-5" />
      </TiptapToolbarButton>
      <TiptapToolbarButton
        label="Heading 2"
        :is-active="editorInstance?.isActive('heading', { level: 2 })"
        @click="editorInstance?.chain().focus().toggleHeading({ level: 2 }).run()"
      >
        <IconH2 class="h-5 w-5" />
      </TiptapToolbarButton>
      <TiptapToolbarButton
        label="Heading 3"
        :is-active="editorInstance?.isActive('heading', { level: 3 })"
        @click="editorInstance?.chain().focus().toggleHeading({ level: 3 }).run()"
      >
        <IconH3 class="h-5 w-5" />
      </TiptapToolbarButton>
      <!-- <TiptapToolbarButton
          label="Heading 4"
          :is-active="editorInstance?.isActive('heading', { level: 4 })"
          @click="editorInstance?.chain().focus().toggleHeading({ level: 4 }).run()"
        >
          <IconH4 class="h-5 w-5" />
        </TiptapToolbarButton>
        <TiptapToolbarButton
          label="Heading 5"
          :is-active="editorInstance?.isActive('heading', { level: 5 })"
          @click="editorInstance?.chain().focus().toggleHeading({ level: 5 }).run()"
        >
          <IconH5 class="h-5 w-5" />
        </TiptapToolbarButton>
        <TiptapToolbarButton
          label="Heading 6"
          :is-active="editorInstance?.isActive('heading', { level: 6 })"
          @click="editorInstance?.chain().focus().toggleHeading({ level: 6 }).run()"
        >
          <IconH6 class="h-5 w-5" />
        </TiptapToolbarButton> -->
      <!-- Color Menu -->
      <dropdown v-model="colorMenu" :offset="8" bottom>
        <template #activator="{ props }">
          <TiptapToolbarButton label="Color" v-bind="props" :text-color="selectedColor">
            <IconPalette class="h-5 w-5" />
          </TiptapToolbarButton>
        </template>

        <template #dropdown>
          <v-list class="flex flex-col items-center justify-center">
            <v-list-item>
              <TiptapToolbarButton label="reset" @click="unsetColor">
                <IconRestore class="h-5 w-5" />
              </TiptapToolbarButton>
            </v-list-item>

            <v-list-item>
              <v-color-picker
                v-model="selectedColor"
                show-swatches
                :swatches="swatches"
                @click.stop
                @update:model-value="setColor"
              ></v-color-picker>
            </v-list-item>
          </v-list>
        </template>
      </dropdown>

      <!-- Dropdown Menu for Text Highlight -->
      <dropdown v-model="highlightMenu" :offset="8" bottom>
        <template #activator="{ props }">
          <TiptapToolbarButton label="highlight" v-bind="props" :text-color="selectedHighlighColor">
            <IconHighlight class="h-5 w-5" />
          </TiptapToolbarButton>
        </template>

        <template #dropdown>
          <v-list class="flex flex-col items-center justify-center">
            <v-list-item>
              <TiptapToolbarButton label="reset" @click="unsetHighlight">
                <IconRestore class="h-5 w-5" />
              </TiptapToolbarButton>
            </v-list-item>

            <v-list-item>
              <v-color-picker
                v-model="selectedHighlighColor"
                show-swatches
                :swatches="swatches"
                @click.stop
                @update:model-value="setHighlight"
              ></v-color-picker>
            </v-list-item>
          </v-list>
        </template>
      </dropdown>
    </TiptapToolbarGroup>
    <TiptapToolbarGroup>
      <TiptapToolbarButton
        label="Bold"
        :is-active="editorInstance?.isActive('bold')"
        @click="editorInstance?.chain().focus().toggleBold().run()"
      >
        <IconBold class="h-5 w-5" />
      </TiptapToolbarButton>
      <TiptapToolbarButton
        label="Italic"
        :is-active="editorInstance?.isActive('italic')"
        @click="editorInstance?.chain().focus().toggleItalic().run()"
      >
        <IconItalic class="h-5 w-5" />
      </TiptapToolbarButton>
      <TiptapToolbarButton
        label="Underline"
        :is-active="editorInstance?.isActive('underline')"
        @click="editorInstance?.chain().focus().toggleUnderline().run()"
      >
        <IconUnderline class="h-5 w-5" />
      </TiptapToolbarButton>
      <TiptapToolbarButton
        label="Strikethrough"
        :is-active="editorInstance?.isActive('strike')"
        @click="editorInstance?.chain().focus().toggleStrike().run()"
      >
        <IconStrikethrough class="h-5 w-5" />
      </TiptapToolbarButton>
    </TiptapToolbarGroup>
    <TiptapToolbarGroup>
      <TiptapToolbarButton
        label="Bold"
        :is-active="editorInstance?.isActive('bulletList')"
        @click="editorInstance?.chain().focus().toggleBulletList().run()"
      >
        <IconListDetails class="h-5 w-5" />
      </TiptapToolbarButton>
      <TiptapToolbarButton
        label="Ordered list"
        :is-active="editorInstance?.isActive('orderedList')"
        @click="editorInstance?.chain().focus().toggleOrderedList().run()"
      >
        <IconListNumbers class="h-5 w-5" />
      </TiptapToolbarButton>
      <!-- <TiptapToolbarButton
        label="Task List"
        :is-active="editorInstance?.isActive('orderedList')"
        @click="editorInstance.chain().focus().toggleTaskList().run()"
      >
        <IconListNumbers class="h-5 w-5" />
      </TiptapToolbarButton> -->
    </TiptapToolbarGroup>
    <TiptapToolbarGroup>
      <TiptapToolbarButton
        label="Code Block"
        class="hover:bg-info"
        :is-active="editorInstance?.isActive('codeBlock')"
        @click="editorInstance?.chain().focus().toggleCodeBlock().run()"
      >
        <IconSourceCode class="h-5 w-5" />
      </TiptapToolbarButton>
      <TiptapToolbarButton
        label="Code"
        class="hover:bg-info"
        :is-active="editorInstance?.isActive('code')"
        @click="editorInstance?.chain().focus().toggleCode().run()"
      >
        <IconCode class="h-5 w-5" />
      </TiptapToolbarButton>
      <TiptapToolbarButton
        label="Link"
        :is-active="editorInstance?.isActive('link')"
        @click="$emit('openLinkDialog')"
      >
        <IconLink class="h-5 w-5" />
      </TiptapToolbarButton>
      <TiptapToolbarButton label="Image" @click="$emit('openImageDialog')">
        <IconPhoto class="h-5 w-5" />
      </TiptapToolbarButton>
      <TiptapToolbarButton
        label="Blockquote"
        :is-active="editorInstance?.isActive('blockquote')"
        @click="editorInstance?.chain().focus().toggleBlockquote().run()"
      >
        <IconBlockquote class="h-5 w-5" />
      </TiptapToolbarButton>
      <TiptapToolbarButton label="Table" @click="$emit('openTableDialog')">
        <svg
          xmlns="http://www.w3.org/2000/svg"
          viewBox="0 0 24 24"
          class="h-5 w-5"
          fill="currentColor"
        >
          <path
            d="M5,4H19A2,2 0 0,1 21,6V18A2,2 0 0,1 19,20H5A2,2 0 0,1 3,18V6A2,2 0 0,1 5,4M5,8V12H11V8H5M13,8V12H19V8H13M5,14V18H11V14H5M13,14V18H19V14H13Z"
          />
        </svg>
      </TiptapToolbarButton>
      <TiptapToolbarButton label="Youtube" @click="$emit('openYoutubeDialog')">
        <IconMovie class="h-5 w-5" />
      </TiptapToolbarButton>
      <TiptapToolbarButton
        label="Horizontal Line"
        @click="editorInstance?.chain().focus().setHorizontalRule().run()"
      >
        <IconMinus class="h-5 w-5" />
      </TiptapToolbarButton>
    </TiptapToolbarGroup>
    <TiptapToolbarGroup v-if="editorInstance?.isActive('table')">
      <TiptapToolbarButton label="Remove table" @click="editorInstance?.commands.deleteTable()">
        <svg
          xmlns="http://www.w3.org/2000/svg"
          viewBox="0 0 24 24"
          class="h-5 w-5"
          fill="currentColor"
        >
          <path
            d="M15.46,15.88L16.88,14.46L19,16.59L21.12,14.46L22.54,15.88L20.41,18L22.54,20.12L21.12,21.54L19,19.41L16.88,21.54L15.46,20.12L17.59,18L15.46,15.88M4,3H18A2,2 0 0,1 20,5V12.08C18.45,11.82 16.92,12.18 15.68,13H12V17H13.08C12.97,17.68 12.97,18.35 13.08,19H4A2,2 0 0,1 2,17V5A2,2 0 0,1 4,3M4,7V11H10V7H4M12,7V11H18V7H12M4,13V17H10V13H4Z"
          />
        </svg>
      </TiptapToolbarButton>
      <TiptapToolbarButton
        label="Add column before"
        @click="editorInstance?.commands.addColumnBefore()"
      >
        <svg
          xmlns="http://www.w3.org/2000/svg"
          viewBox="0 0 24 24"
          class="h-5 w-5"
          fill="currentColor"
        >
          <path
            d="M13,2A2,2 0 0,0 11,4V20A2,2 0 0,0 13,22H22V2H13M20,10V14H13V10H20M20,16V20H13V16H20M20,4V8H13V4H20M9,11H6V8H4V11H1V13H4V16H6V13H9V11Z"
          />
        </svg>
      </TiptapToolbarButton>
      <TiptapToolbarButton
        label="Add column after"
        @click="editorInstance?.commands.addColumnAfter()"
      >
        <svg
          xmlns="http://www.w3.org/2000/svg"
          viewBox="0 0 24 24"
          class="h-5 w-5"
          fill="currentColor"
        >
          <path
            d="M11,2A2,2 0 0,1 13,4V20A2,2 0 0,1 11,22H2V2H11M4,10V14H11V10H4M4,16V20H11V16H4M4,4V8H11V4H4M15,11H18V8H20V11H23V13H20V16H18V13H15V11Z"
          />
        </svg>
      </TiptapToolbarButton>
      <TiptapToolbarButton label="Remove column" @click="editorInstance?.commands.deleteColumn()">
        <svg
          xmlns="http://www.w3.org/2000/svg"
          viewBox="0 0 24 24"
          class="h-5 w-5"
          fill="currentColor"
        >
          <path
            d="M4,2H11A2,2 0 0,1 13,4V20A2,2 0 0,1 11,22H4A2,2 0 0,1 2,20V4A2,2 0 0,1 4,2M4,10V14H11V10H4M4,16V20H11V16H4M4,4V8H11V4H4M17.59,12L15,9.41L16.41,8L19,10.59L21.59,8L23,9.41L20.41,12L23,14.59L21.59,16L19,13.41L16.41,16L15,14.59L17.59,12Z"
          />
        </svg>
      </TiptapToolbarButton>
      <TiptapToolbarButton label="Add row before" @click="editorInstance?.commands.addRowBefore()">
        <svg
          xmlns="http://www.w3.org/2000/svg"
          viewBox="0 0 24 24"
          class="h-5 w-5"
          fill="currentColor"
        >
          <path
            d="M22,14A2,2 0 0,0 20,12H4A2,2 0 0,0 2,14V21H4V19H8V21H10V19H14V21H16V19H20V21H22V14M4,14H8V17H4V14M10,14H14V17H10V14M20,14V17H16V14H20M11,10H13V7H16V5H13V2H11V5H8V7H11V10Z"
          />
        </svg>
      </TiptapToolbarButton>
      <TiptapToolbarButton label="Add row after" @click="editorInstance?.commands.addRowAfter()">
        <svg
          xmlns="http://www.w3.org/2000/svg"
          viewBox="0 0 24 24"
          class="h-5 w-5"
          fill="currentColor"
        >
          <path
            d="M22,10A2,2 0 0,1 20,12H4A2,2 0 0,1 2,10V3H4V5H8V3H10V5H14V3H16V5H20V3H22V10M4,10H8V7H4V10M10,10H14V7H10V10M20,10V7H16V10H20M11,14H13V17H16V19H13V22H11V19H8V17H11V14Z"
          />
        </svg>
      </TiptapToolbarButton>
      <TiptapToolbarButton label="Remove row" @click="editorInstance?.commands.deleteRow()">
        <svg
          xmlns="http://www.w3.org/2000/svg"
          viewBox="0 0 24 24"
          class="h-5 w-5"
          fill="currentColor"
        >
          <path
            d="M9.41,13L12,15.59L14.59,13L16,14.41L13.41,17L16,19.59L14.59,21L12,18.41L9.41,21L8,19.59L10.59,17L8,14.41L9.41,13M22,9A2,2 0 0,1 20,11H4A2,2 0 0,1 2,9V6A2,2 0 0,1 4,4H20A2,2 0 0,1 22,6V9M4,9H8V6H4V9M10,9H14V6H10V9M16,9H20V6H16V9Z"
          />
        </svg>
      </TiptapToolbarButton>
      <TiptapToolbarButton
        label="Merge or split cell"
        @click="editorInstance?.commands.mergeOrSplit()"
      >
        <svg
          xmlns="http://www.w3.org/2000/svg"
          viewBox="0 0 24 24"
          class="h-5 w-5"
          fill="currentColor"
        >
          <path
            d="M5,10H3V4H11V6H5V10M19,18H13V20H21V14H19V18M5,18V14H3V20H11V18H5M21,4H13V6H19V10H21V4M8,13V15L11,12L8,9V11H3V13H8M16,11V9L13,12L16,15V13H21V11H16Z"
          />
        </svg>
      </TiptapToolbarButton>
    </TiptapToolbarGroup>
    <TiptapToolbarGroup>
      <v-menu location="bottom">
        <template #activator="{ props }">
          <v-btn v-bind="props" variant="text" density="compact" icon="mdi mdi-dots-vertical">
          </v-btn>
        </template>
        <div class="z-999 mt-3 rounded bg-surface">
          <TiptapToolbarGroup>
            <TiptapToolbarButton
              label="Subscript"
              :is-active="editorInstance.isActive('subscript')"
              @click="editorInstance.chain().focus().toggleSubscript().run()"
            >
              <IconSubscript class="h-5 w-5" />
            </TiptapToolbarButton>
            <TiptapToolbarButton
              label="Superscript"
              :is-active="editorInstance.isActive('superscript')"
              @click="editorInstance.chain().focus().toggleSuperscript().run()"
            >
              <IconSuperscript class="h-5 w-5" />
            </TiptapToolbarButton>
          </TiptapToolbarGroup>
          <TiptapToolbarGroup v-if="editorInstance?.isActive('imageBlock')">
            <TiptapToolbarButton
              label="Align right"
              :is-active="editorInstance?.isActive('imageBlock', { align: 'left' })"
              @click="
                editorInstance
                  .chain()
                  .focus(undefined, { scrollIntoView: false })
                  .setImageBlockAlign('left')
                  .run()
              "
            >
              <IconAlignLeft class="h-5 w-5" />
            </TiptapToolbarButton>
            <TiptapToolbarButton
              label="Align center"
              :is-active="editorInstance?.isActive('imageBlock', { align: 'center' })"
              @click="
                editorInstance
                  .chain()
                  .focus(undefined, { scrollIntoView: false })
                  .setImageBlockAlign('center')
                  .run()
              "
            >
              <IconAlignCenter class="h-5 w-5" />
            </TiptapToolbarButton>
            <TiptapToolbarButton
              label="Align right"
              :is-active="editorInstance?.isActive('imageBlock', { align: 'right' })"
              @click="
                editorInstance
                  .chain()
                  .focus(undefined, { scrollIntoView: false })
                  .setImageBlockAlign('right')
                  .run()
              "
            >
              <IconAlignRight class="h-5 w-5" />
            </TiptapToolbarButton>
          </TiptapToolbarGroup>
          <TiptapToolbarGroup v-else>
            <TiptapToolbarButton
              label="Align right"
              :is-active="editorInstance?.isActive({ textAlign: 'left' })"
              @click="editorInstance?.chain().focus().setTextAlign('left').run()"
            >
              <IconAlignLeft class="h-5 w-5" />
            </TiptapToolbarButton>
            <TiptapToolbarButton
              label="Align center"
              :is-active="editorInstance?.isActive({ textAlign: 'center' })"
              @click="editorInstance?.chain().focus().setTextAlign('center').run()"
            >
              <IconAlignCenter class="h-5 w-5" />
            </TiptapToolbarButton>
            <TiptapToolbarButton
              label="Align right"
              :is-active="editorInstance?.isActive({ textAlign: 'right' })"
              @click="editorInstance?.chain().focus().setTextAlign('right').run()"
            >
              <IconAlignRight class="h-5 w-5" />
            </TiptapToolbarButton>
            <TiptapToolbarButton
              label="Align justify"
              :is-active="editorInstance?.isActive({ textAlign: 'justify' })"
              @click="editorInstance?.chain().focus().setTextAlign('justify').run()"
            >
              <IconAlignJustified class="h-5 w-5" />
            </TiptapToolbarButton>
          </TiptapToolbarGroup>
        </div>
      </v-menu>
    </TiptapToolbarGroup>
  </div>
</template>

<script setup>
import { ref, computed, watch } from 'vue';
import {
  IconArrowBackUp,
  IconArrowForwardUp,
  IconBlockquote,
  IconBold,
  IconH1,
  IconH2,
  IconH3,
  IconH4,
  IconH5,
  IconH6,
  IconSubscript,
  IconSuperscript,
  IconRestore,
  IconPalette,
  IconHighlight,
  IconItalic,
  IconLink,
  IconListDetails,
  IconListNumbers,
  IconMovie,
  IconPhoto,
  IconStrikethrough,
  IconAlignCenter,
  IconAlignRight,
  IconAlignLeft,
  IconAlignJustified,
  IconUnderline,
  IconCode,
  IconSourceCode,
  IconMinus,
} from '@tabler/icons-vue';
import TiptapToolbarGroup from '@/components/richtext/TiptapToolbarGroup.vue';
import TiptapToolbarButton from '@/components/richtext/TiptapToolbarButton.vue';
import Dropdown from '@/components/button/Dropdown.vue';
import { storeToRefs } from 'pinia';
import { useMobileStore } from "@/stores/mobile";

const { isMobile } = storeToRefs(useMobileStore());
const colorMenu = ref(false);
const selectedColor = ref(null);
const highlightMenu = ref(false);
const selectedHighlighColor = ref(null);

const swatches = ref([
  ['#FF0000', '#AA0000', '#550000'],
  ['#FFFF00', '#AAAA00', '#555500'],
  ['#00FF00', '#00AA00', '#005500'],
  ['#00FFFF', '#00AAAA', '#005555'],
  ['#0000FF', '#0000AA', '#000055'],
]);

const props = defineProps({
  editorInstance: {
    type: Object,
    required: true,
  },
});

const setColor = (event) => {
  selectedColor.value = event;
  props.editorInstance.chain().focus().setColor(event).run();
};

const unsetColor = () => {
  selectedColor.value = null;
  props.editorInstance?.chain().focus().unsetColor().run();
};

const setHighlight = (event) => {
  selectedHighlighColor.value = event;
  props.editorInstance.chain().focus().toggleHighlight({ color: event }).run()
};

const unsetHighlight = () => {
  selectedHighlighColor.value = null;
  props.editorInstance?.chain().focus().unsetMark('highlight').run();
};

watch(
  () => props.editorInstance.getAttributes('textStyle')?.color,
  (newColor) => {
    selectedColor.value = newColor;
  },
);

watch(
  () => props.editorInstance.getAttributes('highlight')?.color,
  (newColor) => {
    selectedHighlighColor.value = newColor;
  },
);

const select = ref({ state: 'Florida', abbr: 'FL' })
const items = ref([
  { state: 'Florida', abbr: 'FL' },
  { state: 'Georgia', abbr: 'GA' },
  { state: 'Nebraska', abbr: 'NE' },
  { state: 'California', abbr: 'CA' },
  { state: 'New York', abbr: 'NY' },
])
</script>
