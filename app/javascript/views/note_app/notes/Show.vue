<template>
  <div
    v-if="selectedNote"
    class="flex w-full flex-col gap-4 rounded-lg bg-background bg-surface p-4 sm:p-6"
  >
    <!-- Header with action buttons -->
    <div class="flex items-center justify-between">
      <div class="flex gap-2">
        <v-menu>
          <template #activator="{ props }">
            <v-icon
              v-if="!isTrash"
              class="cursor-pointer text-primary"
              icon="mdi-dots-vertical"
              v-bind="props"
            ></v-icon>
          </template>
          <v-list class="py-0">
            <div class="flex flex-col">
              <div
                class="cursor-pointer px-4 py-2 transition-colors hover:bg-gray-200"
                @click.prevent="openInviteUserDialog()"
              >
                Invite User
              </div>
              <div
                class="cursor-pointer px-4 py-2 transition-colors hover:bg-gray-200"
                @click.prevent="destroyNote()"
              >
                Delete Note
              </div>
              <div
                class="cursor-pointer px-4 py-2 transition-colors hover:bg-gray-200"
                @click.prevent="openTagDialog()"
              >
                Change Tags
              </div>
            </div>
          </v-list>
        </v-menu>

        <v-icon
          v-if="selectedNote && !isTrash"
          @click="toggleLock"
          class="cursor-pointer rounded-full p-1 p-4 hover:bg-grey"
          :class="isLocked ? 'text-red-500' : 'text-green-500'"
          >{{ isLocked ? 'mdi-lock' : 'mdi-lock-open' }}</v-icon
        >

        <v-icon
          v-if="selectedNote"
          @click="copyNoteContent"
          class="cursor-pointer rounded-full p-1 p-4 hover:bg-grey text-blue-500"
          >mdi-content-copy</v-icon
        >
      </div>

      <v-icon
        class="cursor-pointer rounded-full p-2 text-xl text-primary transition-colors hover:bg-red-200"
        icon="mdi mdi-close"
        @click="goBack"
      />
    </div>

    <v-divider v-if="selectedNote?.tags?.length || selectedNote?.shared_users?.length" />

    <div class="my-4">
      <v-chip>
        Last update: {{ filters.formatDateHoursWithoutSeconds(selectedNote.updated_at) }}
      </v-chip>
    </div>
    <!-- Note Title -->
    <v-text-field
      v-model="selectedNote.title"
      placeholder="Title"
      type="text"
      variant="solo-filled"
      class="border-b border-gray-300 focus:border-blue-500 focus:outline-none"
      :disabled="isTrash || isLocked"
      @update:model-value="updateCurrentNote($event, selectedNote.description)"
    />

    <!-- Rich Text Editor for Note Description -->
    <tiptap-editor
      v-if="selectedNote.description"
      ref="tiptapEditor"
      :key="editorKey"
      :record-id="selectedNote.id"
      class="bg-background"
      :lastname="currentUser.lastname"
      :content="selectedNote.description"
      :is-editable="isEditable"
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
          class="cursor-pointer bg-gray-200 transition-colors hover:bg-gray-300"
        >
          {{ tag.name }}
        </v-chip>
      </div>
    </div>

    <!-- Shared Users Section -->
    <div v-if="selectedNote?.shared_users?.length" class="flex flex-wrap gap-2">
      <AvatarStack :users="selectedNote.shared_users" />
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
import filters from '@/tools/filters';

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
const isLocked = ref(false);
const editorKey = ref(0);

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
  return selectedNote.value.status == 'trashed';
});

const isEditable = computed(() => !isTrash.value && !isLocked.value);

const toggleLock = () => {
  isLocked.value = !isLocked.value;
  editorKey.value += 1; // Force re-render of the editor
};

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

const copyNoteContent = async () => {
  try {
    // Get plain text content from the note description
    const tempDiv = document.createElement('div');
    tempDiv.innerHTML = selectedNote.value.description;
    const plainText = tempDiv.textContent || tempDiv.innerText || '';

    await navigator.clipboard.writeText(plainText);
    showToast('Note content copied to clipboard', 'success');
  } catch (error) {
    console.error('Failed to copy content:', error);
    showToast('Failed to copy content', 'error');
  }
};
</script>
