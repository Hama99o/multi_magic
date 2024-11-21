<template>
  <v-container v-if="isMenuOpen" id="menuContainer" class="max-w-sm p-1">
    <v-card>
      <v-card-text class="p-0">
        <template v-if="items.length">
          <v-list dense class="max-h-60 overflow-auto">
            <v-list-item
              v-for="(item, index) in items"
              :key="index"
              class="rounded-md transition-colors"
              @click="selectItem(index)"
            >
              <v-list-item-title>
                {{ item.title }}
              </v-list-item-title>
            </v-list-item>
          </v-list>
        </template>
        <div v-else class="py-4 text-center text-surface">No results found</div>
      </v-card-text>
    </v-card>
  </v-container>

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
    ref="imageDialog"
    :record-id="editor?.options?.recordId"
    @close="imageDialog.dialog = false"
    @insert="insertImage"
  />
</template>

<script setup>
import { ref, watch } from 'vue';
import { Editor } from '@tiptap/vue-3';
import TiptapImageDialog from '@/components/richtext/TiptapImageDialog.vue';
import TiptapVideoDialog from '@/components/richtext/TiptapVideoDialog.vue';
import TiptapTableDialog from '@/components/richtext/TiptapTableDialog.vue';

const props = defineProps({
  items: {
    type: Array,
    required: true,
  },

  command: {
    type: Function,
    required: true,
  },

  editor: { type: Editor, default: null },
});

const selectedIndex = ref(0);
const imageDialog = ref(null);
const showAddYoutubeDialog = ref(false);
const showAddTableDialog = ref(false);
const isMenuOpen = ref(true);
const item = ref(null);

watch(
  () => props.items,
  () => {
    selectedIndex.value = 0;
  },
);

watch(
  () => imageDialog.value?.dialog,
  () => {
    if (item.value && imageDialog.value && !imageDialog.value.dialog) {
      props?.command(item.value);
    }
  },
);

watch(
  () => showAddYoutubeDialog.value?.dialog,
  () => {
    if (item.value && showAddYoutubeDialog.value && !showAddYoutubeDialog.value.dialog) {
      props?.command(item.value);
    }
  },
);

watch(
  () => showAddTableDialog.value?.dialog,
  () => {
    if (item.value && showAddTableDialog.value && !showAddTableDialog.value.dialog) {
      props?.command(item.value);
    }
  },
);

const selectItem = (index) => {
  item.value = props.items[index];

  if (item.value) {
    if (item.value.title === 'Image') {
      imageDialog.value.dialog = true;
    } else if (item.value.title === 'Youtube') {
      showAddYoutubeDialog.value.dialog = true;
    } else if (item.value.title === 'Table') {
      showAddTableDialog.value.dialog = true;
    } else {
      props.command(item.value);
    }
  }
};

function insertImage(url) {
  props.editor?.chain().focus().setImageBlock({ src: url }).run();
  props.command(item.value);
}

function insertYoutubeVideo(url) {
  props.editor?.commands.setYoutubeVideo({
    src: url,
    width: 400,
    height: 300,
  });
  props.command(item.value);
}

function insertTable(table) {
  props.editor
    ?.chain()
    .focus()
    .insertTable({
      rows: table.rows,
      cols: table.columns,
      withHeaderRow: table.withHeader,
    })
    .run();
    props.command(item.value);
}
</script>
