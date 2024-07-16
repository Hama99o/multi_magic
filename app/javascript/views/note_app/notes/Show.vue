<template>
  <div
    v-if="selectedNote"
    class="flex w-full flex-col gap-4 rounded-lg bg-background p-4 sm:p-6 bg-surface"
  >
    <!-- Header with action buttons -->
    <div class="flex items-center justify-between">
      <v-menu>
        <template #activator="{ props }">
          <v-icon
            v-if="!isTrash"
            class="text-primary cursor-pointer"
            icon="mdi-dots-vertical"
            v-bind="props"
          ></v-icon>
        </template>
        <v-list class="py-0">
          <div class="flex flex-col">
            <div
              class="cursor-pointer px-4 py-2 hover:bg-gray-200 transition-colors"
              @click.prevent="openInviteUserDialog()"
            >
              Invite User
            </div>
            <div
              class="cursor-pointer px-4 py-2 hover:bg-gray-200 transition-colors"
              @click.prevent="destroyNote()"
            >
              Delete Note
            </div>
            <div
              class="cursor-pointer px-4 py-2 hover:bg-gray-200 transition-colors"
              @click.prevent="openTagDialog()"
            >
              Change Tags
            </div>
          </div>
        </v-list>
      </v-menu>
      <v-icon
        class="text-xl text-primary hover:bg-red-200 p-2 rounded-full transition-colors cursor-pointer"
        icon="mdi mdi-close"
        @click="goBack"
      />
    </div>

    <v-divider v-if="selectedNote?.tags?.length || selectedNote?.shared_users?.length" />

    <!-- Note Title -->
    <v-text-field
      v-model="selectedNote.title"
      placeholder="Title"
      type="text"
      variant="solo-filled"
      class="border-b border-gray-300 focus:outline-none focus:border-blue-500"
      :disabled="isTrash"
      @update:model-value="updateCurrentNote($event, selectedNote.description)"
    />

    <!-- Rich Text Editor for Note Description -->
    <tiptap-editor
      v-if="selectedNote.description"
      ref="tiptapEditor"
      :record-id="selectedNote.id"
      class="bg-background"
      :lastname="currentUser.lastname"
      :content="selectedNote.description"
      :is-editable="!isTrash"
      autofocus
      :withMenu="true"
      @on-save="updateCurrentNote(selectedNote.title, $event)"
    />

    <v-divider v-if="selectedNote?.tags?.length || selectedNote?.shared_users?.length" />

    <!-- Tags Section -->
    <div v-if="selectedNote?.tags?.length" class="flex flex-wrap gap-2">
      <div v-for="tag in selectedNote.tags" :key="tag.id">
        <v-chip
          :closable="!isTrash"
          :disabled="isTrash"
          @click:close="toggleTagToNote(tag)"
          class="bg-gray-200 hover:bg-gray-300 cursor-pointer transition-colors"
        >
          {{ tag.name }}
        </v-chip>
      </div>
    </div>

    <!-- Shared Users Section -->
    <div v-if="selectedNote?.shared_users?.length" class="flex flex-wrap gap-2">
        <AvatarStack :users="selectedNote.shared_users"/>
    </div>

    <v-divider v-if="selectedNote?.tags?.length || selectedNote?.shared_users?.length" />

    <invite-user ref="inviteUser" @add-user="inviteUserWithEmail" />
    <tag-dialog ref="isTagDialogOpened" :note="selectedNoteForTag" />
  </div>
</template>

<script setup>
import { ref, onMounted, computed } from 'vue';
import { storeToRefs } from 'pinia';
import { useRoute, useRouter } from 'vue-router';
import { debounce } from 'lodash';
import { showToast } from '@/utils/showToast';
import { useNoteStore } from '@/stores/note_app/note.store';
import UserAvatar from '@/components/tools/Avatar.vue';
import TiptapEditor from '@/components/richtext/TiptapEditor.vue';
import InviteUser from '@/components/note_app/notes/InviteUser.vue';
import TagDialog from '@/components/note_app/notes/TagDialog.vue';
import { useMobileStore } from '@/stores/mobile';
import { useUserStore } from '@/stores/user.store';
import AvatarStack from '@/components/tools/AvatarStack.vue';

// Get store data
const { isMobile } = storeToRefs(useMobileStore());
const { currentUser } = storeToRefs(useUserStore());
const { fetchNote, updateNote, deleteNote, toggleTag, inviteUserToggle } = useNoteStore();

// Route and selected note setup
const route = useRoute();
const router = useRouter();
const selectedNote = ref(null);

// Dialog and note interaction state
const selectedNoteForTag = ref(null);
const inviteUser = ref(null);
const isTagDialogOpened = ref(null);

// Fetch note on page load using the note ID from the route
onMounted(async () => {
  const noteId = route.params.id;
  try {
    selectedNote.value = await fetchNote(noteId);
  } catch (error) {
    console.error('Failed to load note:', error);
  }
});

// Utility methods
const openInviteUserDialog = () => {
  inviteUser.value.isActive = true;
};

const openTagDialog = () => {
  selectedNoteForTag.value = selectedNote.value;
  isTagDialogOpened.value.isActive = true;
};

const toggleTagToNote = async (tag) => {
  try {
    await toggleTag(selectedNote.value, tag.id);
  } catch (error) {
    console.error(error);
  }
};

const destroyNote = async () => {
  try {
    await deleteNote(selectedNote.value.id);
    router.push({ name: 'notes' });
    showToast(`${selectedNote.value.title} note deleted successfully`, 'primary');
  } catch (error) {
    console.error(error);
  }
};

const isTrash = computed(() => {
  return selectedNote.value.status == 'trashed'
})
const updateCurrentNote = debounce(async (noteTitle, noteDescription) => {
  selectedNote.value.title = noteTitle;
  selectedNote.value.description = noteDescription;

  try {
    await updateNote(selectedNote.value.id, {
      title: noteTitle,
      description: noteDescription || ' ',
    });
  } catch (error) {
    showToast(error.message, 'error');
  }
}, 200);

const inviteUserWithEmail = async (role, email, UserAction) => {
  try {
    const data = { role, email, user_action: UserAction };
    await inviteUserToggle(selectedNote.value.id, data);
    inviteUser.value.isActive = false;
  } catch (errorMessage) {
    showToast(errorMessage.error, 'error');
  }
};

const goBack = () => {
  router.push({ name: 'notes' });
};
</script>
