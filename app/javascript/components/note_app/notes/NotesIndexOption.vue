<template>
  <v-card>
    <v-layout>
      <v-app-bar class="bg-background">
        <v-app-bar-nav-icon @click="rail = !rail; drawer = true" icon="mdi mdi-format-list-bulleted-type"></v-app-bar-nav-icon>
        <v-toolbar-title>
          <div :class="isMobile ? '!text-sm' : ''" class="flex gap-5 justify-between items-center">
            <span v-if="!isMobile" class="max-w-[150px] truncate">
              {{ filterTitle }}
            </span>

            <!-- Search Input -->
            <v-text-field
              v-model="search"
              class="w-full md:w-[258px] max-w-[600px] rounded-lg"
              variant="outlined"
              density="compact"
              hide-details
              clearable
              prepend-inner-icon="mdi-magnify"
              placeholder="Search notes"
              @update:model-value="$emit('searchNote', $event)"
            />

            <div>
              <v-btn
                @click="$emit('createNewNote')"
                icon
                size="small"
                class="!bg-surface hover:bg-primary rounded-full shadow-md mr-3"
                elevation="2"
              >
                <v-icon class="text-primary" size="32" icon="mdi-plus" />
              </v-btn>

              <!-- Toggle View Button -->
              <v-btn
                icon
                size="small"
                @click="$emit('toggleView')"
              >
                <v-icon class="text-primary" size="32" :icon="listViewColor" />
              </v-btn>
            </div>
          </div>
        </v-toolbar-title>
      </v-app-bar>

      <v-navigation-drawer
        v-model="drawer"
        :rail="rail"
        permanent
        :width="isMobile ? 150 : 200"
        class="bg-background"
      >
        <v-list>
          <v-list-item
            @click="filterNotes({})"
            :class="!selectedTagId && currentPageTab == 'all_notes' ? 'bg-secondary' : ''"
            class="hover:bg-gray-800"
          >
            <v-list-item-content class="flex gap-2">
              <v-icon>mdi-lightbulb-outline</v-icon> <v-list-item-title v-if="drawer">Notes</v-list-item-title>
            </v-list-item-content>
          </v-list-item>

          <v-list-item
            @click="$emit('openTrashDialog')"
            :class="!selectedTagId && currentPageTab == 'trash' ? 'bg-secondary' : ''"
            class="hover:bg-gray-800"
          >
            <v-list-item-content class="flex gap-2">
              <v-icon>mdi-trash-can-outline</v-icon> <v-list-item-title v-if="drawer">Trash</v-list-item-title>
            </v-list-item-content>
          </v-list-item>
        </v-list>
        <v-divider class="border-gray-700"></v-divider>

        <!-- Draggable list of saved signatures -->
        <draggable
          key="draggable"
          item-key="item"
          :list="tags"
          v-bind="dragOptions"
          class="flex flex-col gap-2"
          handle=".drag"
          @start="drag = true"
          :delay="50"
          :delay-on-touch-only="true"
          @end="drag = false"
          @change="getListAfterDrag($event)"
        >
          <template #item="{ element, index }">
            <v-list-item class="hover:bg-gray-800" :class="selectedTagId == element.id ? 'bg-secondary' : ''">
              <v-list-item-content @click="filterNotes(element)" class="flex gap-2 cursor-pointer ">
                <v-icon class="drag">mdi-label</v-icon> <v-list-item-title v-if="drawer" >{{ element.name }}</v-list-item-title>
              </v-list-item-content>
            </v-list-item>
          </template>
        </draggable>

        <v-list-item
          @click="editLabels"
          class="hover:bg-gray-800"
        >
          <v-list-item-content class="flex gap-2">
            <v-icon>mdi-plus</v-icon> <v-list-item-title v-if="drawer">Edit labels</v-list-item-title>
          </v-list-item-content>
        </v-list-item>
      </v-navigation-drawer>

      <v-main >
        <v-container fluid class="min-h-screen bg-background">
          <div v-if="currentPageTab === 'trash'">
            <note-table
              v-if="noteIndexType == 'table'"
              :notes="trashesNotes"
              :note-index-type="noteIndexType"
              @open-invite-user-dialog="openInviteUserDialog"
              @open-tag-dialog="openTagDialog"
              @open-note-dialog="openNoteDialog"
              @destroy-note="destroyNote"
              :isTrash="true"
            />

            <note-card
              v-else
              :notes="trashesNotes"
              :isTrash="true"
              :note-index-type="noteIndexType"
              @open-invite-user-dialog="openInviteUserDialog"
              @open-tag-dialog="openTagDialog"
              @open-note-dialog="openNoteDialog"
              @destroy-note="destroyNote"
              @item-restore="$emit('noteRestore', $event)"
              @trash-delete-permanently="$emit('noteDeletePermanently', $event)"
            />
          </div>

          <div v-else>
            <note-table
              v-if="noteIndexType == 'table'"
              :notes="notes"
              :note-index-type="noteIndexType"
              @open-invite-user-dialog="openInviteUserDialog"
              @open-tag-dialog="openTagDialog"
              @open-note-dialog="openNoteDialog"
              @destroy-note="destroyNote"
              :isTrash="false"
            />

            <note-card
              v-else
              :notes="notes"
              :note-index-type="noteIndexType"
              @open-invite-user-dialog="openInviteUserDialog"
              @open-tag-dialog="openTagDialog"
              @open-note-dialog="openNoteDialog"
              @destroy-note="destroyNote"
              :isTrash="false"
            />
          </div>

          <invite-user
            ref="inviteUser"
            @add-user="inviteUserWithEmail"
          />

          <open-note
            v-if="notes || trashesNotes"
            ref="isNoteOpened"
            :isTrash="currentPageTab === 'trash'"
            v-model:note="selectedNote"
            @add-user="inviteUserWithEmail"
          />

          <tag-dialog
            ref="isTagDialogOpened"
            :note="selectedNoteForTag"
          />
        </v-container>
      </v-main>
    </v-layout>
  </v-card>

  <v-dialog v-model="dialog" max-width="400">
    <v-card>
      <v-card-title>
        Edit Labels
        <v-spacer></v-spacer>
        <v-btn icon @click="dialog = false">
          <v-icon>mdi-close</v-icon>
        </v-btn>
      </v-card-title>

      <v-divider></v-divider>

      <v-card-text>
        <v-text-field
          v-if="isCreateTagInputShow"
          v-model="newTag"
          ref="createNewTagRef"
          append-inner-icon="mdi mdi-check"
          prepend-inner-icon="mdi-close-circle"
          type="text"
          label="Create new label"
          variant="solo"
          :error-messages="createTagInputErrorMessage"
          @click:append-inner="createNewTag"
          @click:prepend-inner="isCreateTagInputShow= false"
          @keyup.enter="createNewTag"
        ></v-text-field>

        <div v-else @click="openCreateTagInput">
          <v-btn
            icon
            size="small"
            class="!bg-surface hover:bg-primary rounded-full shadow-md mr-3"
            elevation="2"
          >
            <v-icon class="text-primary" size="32" icon="mdi-plus" />
          </v-btn>
          Create new label
        </div>

        <v-list dense class="max-h-[400px]">
          <v-list-item
            v-for="tag in tags"
            :key="tag.id"
            @mouseover="hoveredTag = tag"
            @mouseleave="hoveredTag = null"
            >
            <!-- <v-list-item-content> -->
              <!-- <template v-if="editingTag === tag.id">
                <v-text-field
                  v-model="tag.name"
                  dense
                  outlined
                  @blur="saveTag(tag)"
                  @keyup.enter="saveTag(tag)"
                />
              </template>
              <template v-else>
                <v-list-item-title>{{ tag.name }}</v-list-item-title>
              </template>
            </v-list-item-content> -->


            <v-list-item-action v-if="editingTag === tag.id" class="flex flex-1 justify-between">
              <v-text-field
                v-model="tag.name"
                append-inner-icon="mdi mdi-check"
                prepend-inner-icon="mdi-close-circle"
                type="text"
                label="Update label"
                variant="solo"
                :error-messages="createTagInputErrorMessage"
                @click:append-inner="updateSelectedTag(tag)"
                @click:prepend-inner="editingTag = null"
                @keyup.enter="updateSelectedTag(tag)"
              ></v-text-field>
            </v-list-item-action>

            <v-list-item-action v-else class="flex flex-1 justify-between">
              <div class="flex">
                <!-- Delete Button -->
                <div class="mr-2">
                  <v-icon
                    small
                    @click="deleteSelectedTag(tag.id)"
                    v-if="hoveredTag?.id === tag.id"
                  >mdi-delete</v-icon>
                  <v-icon
                    v-else
                    small
                  >mdi-label</v-icon>
                </div>

                <span class="line-clamp-1 max-w-[220px]">
                  <v-list-item-title>{{ tag.name }}</v-list-item-title>
                </span>
              </div>

              <!-- Edit Button -->
              <v-icon
                small
                class="mr-2"
                @click="startEditing(tag)"
                >mdi-pencil</v-icon>
                <!-- v-show="hoveredTag === tag.id || editingTag === tag.id" -->
            </v-list-item-action>

          </v-list-item>
        </v-list>
      </v-card-text>

      <v-card-actions>
        <v-btn color="primary" @click="dialog = false">Done</v-btn>
      </v-card-actions>
    </v-card>
  </v-dialog>
</template>

<script setup>
import { ref, computed, nextTick } from 'vue';
import { storeToRefs } from 'pinia';
import { useNoteStore } from '@/stores/note_app/note.store';
import InviteUser from '@/components/note_app/notes/InviteUser.vue';
import TagDialog from '@/components/note_app/notes/TagDialog.vue';
import { showToast } from '@/utils/showToast';
import OpenNote from '@/components/note_app/notes/OpenNote.vue';
import { usePopUpStore } from "@/stores/pop-up.store";
import NoteCard from '@/components/note_app/notes/Card.vue';
import NoteTable from '@/components/note_app/notes/Table.vue';
import { useNoteTagStore } from "@/stores/note_app/tag.store";
import { useMobileStore } from "@/stores/mobile";
import { useRoute, useRouter } from 'vue-router';
import draggable from 'vuedraggable'

const { inviteUserToggle, deleteNote, fetchNotes, fetchNewinfinitePage } = useNoteStore();
const { createTag, fetchTags, fetchSearchTags, deleteTag, updateTag } = useNoteTagStore()

const route = useRoute()
const router = useRouter()

const { tags } = storeToRefs(useNoteTagStore());
const { page, pagination, notes, trashesNotes, selectedTagId, search } = storeToRefs(useNoteStore());
const { isMobile } = storeToRefs(useMobileStore());

const { openPopUp, closePopUp } = usePopUpStore();

const emit = defineEmits(['fetchTagNotes'])

const props = defineProps({
  noteIndexType: { type: String },
  currentUser: { type: Object},
  isTrash: { type: Boolean, default: true },
});

const drawer = ref(true);
const rail= ref(false)
const drag = ref(true)
const drawerWidth = computed(() => drawer.value ? 200 : 56);
const dialog = ref(false);
const hoveredTag = ref(null);
const editingTag = ref(null);
const newTag = ref('');

const dragOptions = ref({
  animation: 200,
  group: 'description',
  disabled: false,
  ghostClass: 'ghost',
});

const currentPageTab = computed(() => {
  return route.query?.page
})

const listViewColor = computed(() => {
  if (props.currentUser?.note_index_type == 'card_grid') {
    return 'mdi-view-module'
  } else if (props.currentUser?.note_index_type == 'card_list') {
    return 'mdi-view-list'
  } else {
    return 'mdi-table'
  }
})

const openCreateTagInput = () => {
  isCreateTagInputShow.value = true
  createTagInputErrorMessage.value = ''
  newTag.value = '';
  nextTick(() => {
    if (createNewTagRef.value) {
      createNewTagRef.value.focus();
    }
  });
};

const filterNotes = (tag) => {
  emit('fetchTagNotes', tag);
};

const editLabels = () => {
  // Implement your label editing logic here
  dialog.value = true
};

const selectedNote = ref(null)
const selectedNoteForTag = ref(null)
const inviteUser = ref(null)
const isNoteOpened = ref(null)
const isTagDialogOpened = ref(null)
const isCreateTagInputShow = ref(true)
const createNewTagRef = ref(false)
const createTagInputErrorMessage = ref('')
const openInviteUserDialog = (note) => {
  selectedNote.value = note
  inviteUser.value.isActive = true
}

const openTagDialog = (note) => {
  selectedNoteForTag.value = note
  isTagDialogOpened.value.isActive = true
}

const openNoteDialog = (note) => {
  selectedNote.value = note
  isNoteOpened.value.isOpen = true
}

const filterTitle = computed(() => {
  return selectedTagId.value ? (tags?.value?.find(t => t.id === selectedTagId.value)?.name ? `${tags?.value?.find(t => t.id === selectedTagId.value)?.name}'s notes` : 'Notes') : 'All notes'
})

const destroyNote = async(note) => {
  try {
    openPopUp({
      componentName: "pop-up-validation",
      title: ("Are you sure you want to delete this note ?"),
      textClose: "No, cancel",
      textConfirm: "Yes, delete this note",
      textLoading: "Deleting ...",
      icon: "mdi-trash-can-outline",
      customClass: "w-[400px]",
      showClose: false,
      async confirm() {
        try {
          await deleteNote(note.id)
          notes.value =  notes.value.filter(n => n.id !== note.id)
          closePopUp();
          showToast(`${note.title} note delete successfully`, 'success');
        } catch (error) {
          if (error.message.includes('not allowed')) {
            showToast(`Unable to delete "${note.title}". This note may be associated with other user and cannot be deleted.`, 'error');
          } else {
            showToast(`There was a problem deleting "${note.title}".`, 'error');
          }
        }
      },
    });
  } catch (error) {
    console.log(error);
  }
};

const inviteUserWithEmail = async(role, email, UserAction) => {
  try {
    const data = {
      role: role,
      email: email,
      user_action: UserAction
    }
    await inviteUserToggle(selectedNote.value?.id, data)
    inviteUser.value.isActive = false
  } catch (errorMessage) {
    showToast(errorMessage.error, 'error');
  }
};
const createNewTag = async () => {
  try {
    const res = await createTag(newTag.value);
    newTag.value = '';
    createTagInputErrorMessage.value = ''
    tags.value?.push(res)
  } catch (errorMessage) {
    console.log()
    createTagInputErrorMessage.value = errorMessage?.name?.[0] || "Failed to create tag"
  }
};

// Start editing a tag
const startEditing = (tag) => {
  editingTag.value = tag.id;
};

// Save updated tag name
const updateSelectedTag = async (tag) => {
  await updateTag(tag.id, { tag: { name: tag.name } });
  editingTag.value = null
  // await store.dispatch('updateTag', tag);
  // editingTag.value = null; // Exit editing mode
  // fetchTags(); // Refresh the list
};

// Delete a tag
const deleteSelectedTag = async (tagId) => {
  await deleteTag(tagId);
  tags.value = tags.value.filter(tag => tag?.id !== tagId )
  // fetchTags(); // Refresh the list
};

const getListAfterDrag = async(data) => {
  await updateTag(data.moved.element.id, { tag: { tag_ids: tags.value.map( tag => tag.id ) } })
}
</script>
