<template>
  <div>
    <v-dialog class="" max-width="500" v-model="isActive">
      <template #default>
        <div class="w-full flex flex-col p-6 gap-8 bg-surface">
          <div>
            add tag to note
          </div>
          <div>
            <v-autocomplete
              v-model:search="searchText"
              :items="tags"
              :autofocus="true"
              no-filter
              variant="outlined"
              multiple
              hide-details
              menu-icon=""
              density="compact"
              item-value="id"
              :clear-on-select="true"
              item-text="name"
              label="Tags"
              @click:clear="clear"
              @update:search="searchTag"
            >
              <template v-slot:item="{ item }">
                <v-list-item-content>
                  <v-checkbox
                    v-model="note.tag_ids"
                    color="info"
                    :label="item.raw.name"
                    hide-details
                    :value="item.raw?.id"
                    @click.stop
                    @update:model-value="toggleTagToNote(item.raw)"
                  ></v-checkbox>
                </v-list-item-content>
              </template>
              <template #no-data>
                <v-list-item-content v-if="searchText.length" >
                  <div class="ml-3 px-4 rounded w-fit cursor-pointer" @click="createNewTag(note, searchText)">+ Create "{{searchText}}"</div>
                </v-list-item-content>
              </template>
            </v-autocomplete>
          </div>
        </div>
      </template>
    </v-dialog>
  </div>
</template>

<script setup>
import { ref, onMounted, computed } from 'vue';
import { storeToRefs } from 'pinia';
import { useNoteTagStore } from "@/stores/note_app/tag.store";
import { useNoteStore } from '@/stores/note_app/note.store';

import {debounce} from "lodash";

const { fetchTags } = useNoteTagStore();
const { toggleTag, createTag } = useNoteStore();

const { tags } = storeToRefs(useNoteTagStore());

const emit = defineEmits(['add-user'])

const props = defineProps({
  note: { type: Object, default: () => {} },
});

const isActive = ref(false)
const searchText = ref('')
const isSelected = ref([])
const selectedTag = ref('')
const editedTags = ref([])

defineExpose({
  isActive
})

const clear = () => {
  searchText.value = ''
}

const searchTag = async(x) => {
  try {
    await fetchTags(x);
  } catch (error) {
    console.log(error);
  }
};

const createNewTag = async(note, text) => {
  try {
    await createTag(note.id, text);
  } catch (error) {
    console.log(error);
  }
};

const toggleTagToNote = async(tag) => {
  try {
    toggleTag(props.note, tag.id)
  } catch (error) {
    console.log(error);
  }
};
</script>
