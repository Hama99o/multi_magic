<template>
  <div v-if="selectedNote" class="d-flex flex-column ga-0 pa-4 pa-md-6">
    <!-- Main Content Card -->
    <v-card class="overflow-hidden" elevation="2">
      <!-- Header Section -->
      <v-card-title class="d-flex align-center justify-space-between pa-4 pa-md-6">
        <div class="d-flex align-center ga-3">
          <v-avatar color="primary" size="48">
            <v-icon color="white" size="24">mdi-note-text</v-icon>
          </v-avatar>
          <div>
            <h1 class="text-h5 font-weight-bold">{{ selectedNote.title || 'Untitled Note' }}</h1>
            <p class="text-body-2 text-medium-emphasis ma-0">
              Last updated: {{ filters.formatDateHoursWithoutSeconds(selectedNote.updated_at) }}
            </p>
          </div>
        </div>

        <!-- Close Button -->
        <v-btn
          icon="mdi-arrow-left"
          variant="text"
          size="large"
          class="ml-2"
          @click="goBack"
        >
          <v-icon>mdi-arrow-left</v-icon>
          <v-tooltip activator="parent" location="bottom">Back to Notes</v-tooltip>
        </v-btn>
      </v-card-title>

      <v-divider />

      <!-- Action Buttons Bar -->
      <v-card-subtitle class="pa-4 pa-md-6 pb-0">
        <div class="d-flex ga-2 align-center flex-wrap">
          <v-btn
            v-if="selectedNote && !isTrash"
            variant="outlined"
            size="small"
            :prepend-icon="isLocked ? 'mdi-lock' : 'mdi-lock-open'"
            :color="isLocked ? 'error' : 'success'"
            @click="toggleLock"
          >
            <span class="d-none d-sm-inline">{{ isLocked ? 'Locked' : 'Unlocked' }}</span>
          </v-btn>

          <v-btn
            v-if="selectedNote"
            variant="outlined"
            size="small"
            prepend-icon="mdi-content-copy"
            color="info"
            @click="copyNoteContent"
          >
            <span class="d-none d-sm-inline">Copy Content</span>
          </v-btn>

          <v-spacer />

          <!-- Status Chip -->
          <v-chip
            :color="isTrash ? 'error' : 'success'"
            variant="outlined"
            size="small"
          >
            {{ isTrash ? 'Trashed' : 'Active' }}
          </v-chip>

          <!-- Actions Menu -->
          <v-menu v-if="!isTrash" location="bottom end">
            <template #activator="{ props }">
              <v-btn icon="mdi-dots-vertical" variant="text" size="small" v-bind="props" />
            </template>
            <v-list density="compact">
              <v-list-item
                prepend-icon="mdi-account-plus"
                title="Invite User"
                @click="openInviteUserDialog"
              />
              <v-list-item prepend-icon="mdi-tag" title="Manage Tags" @click="openTagDialog" />
              <v-divider />
              <v-list-item
                prepend-icon="mdi-delete"
                title="Delete Note"
                class="text-error"
                @click="destroyNote"
              />
            </v-list>
          </v-menu>
        </div>
      </v-card-subtitle>

      <!-- Content Section -->
      <v-card-text class="pa-4 pa-md-6">
        <!-- Title Input -->
        <v-text-field
          v-model="selectedNote.title"
          placeholder="Enter note title..."
          variant="outlined"
          density="comfortable"
          :disabled="isTrash || isLocked"
          class="mb-4"
          hide-details
          @update:model-value="updateCurrentNote($event, selectedNote.description)"
        />

        <!-- Editor -->
        <div class="editor-container">
          <tiptap-editor
            v-if="selectedNote.description"
            ref="tiptapEditor"
            :key="editorKey"
            :record-id="selectedNote.id"
            class="editor-content rounded-lg border"
            :lastname="currentUser.lastname"
            :content="selectedNote.description"
            :is-editable="isEditable"
            :with-menu="true"
            autofocus
            @on-save="updateCurrentNote(selectedNote.title, $event)"
          />
        </div>
      </v-card-text>

      <!-- Tags and Shared Users Section -->
      <v-card-text
        v-if="selectedNote?.tags?.length || selectedNote?.shared_users?.length"
        class="pa-4 pa-md-6 pt-0"
      >
        <!-- Tags -->
        <div v-if="selectedNote?.tags?.length" class="mb-4">
          <p class="text-body-2 text-medium-emphasis mb-2">Tags:</p>
          <div class="d-flex ga-2 flex-wrap">
            <v-chip
              v-for="tag in selectedNote.tags"
              :key="tag.id"
              :closable="!isTrash"
              :disabled="isTrash"
              color="primary"
              variant="outlined"
              size="small"
              @click:close="toggleTagToNote(tag)"
            >
              {{ tag.name }}
            </v-chip>
          </div>
        </div>

        <!-- Shared Users -->
        <div v-if="selectedNote?.shared_users?.length">
          <p class="text-body-2 text-medium-emphasis mb-2">Shared with:</p>
          <AvatarStack :users="selectedNote.shared_users" />
        </div>
      </v-card-text>
    </v-card>

    <!-- Dialogs -->
    <InviteUser ref="inviteUser" @add-user="inviteUserWithEmail" />
    <TagDialog ref="isTagDialogOpened" :note="selectedNoteForTag" />
  </div>
</template>

<script setup>
import { ref, onMounted, computed } from 'vue';
import { storeToRefs } from 'pinia';
import { useRoute, useRouter } from 'vue-router';
import { debounce } from 'lodash';
import { showToast } from '@/utils/showToast';
import { useNoteStore } from '@/stores/note_app/note.store';
import TiptapEditor from '@/components/richtext/TiptapEditor.vue';
import InviteUser from '@/components/note_app/notes/InviteUser.vue';
import TagDialog from '@/components/note_app/notes/TagDialog.vue';
import { useUserStore } from '@/stores/user.store';
import AvatarStack from '@/components/tools/AvatarStack.vue';
import filters from '@/tools/filters';

// Get store data
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
    const idString = Array.isArray(noteId) ? noteId[0] : noteId;
    selectedNote.value = await fetchNote(parseInt(idString));
  } catch (error) {
    console.error('Failed to load note:', error);
  }
});

// Utility methods
const openInviteUserDialog = () => {
  if (inviteUser.value) {
    inviteUser.value.isActive = true;
  }
};

const openTagDialog = () => {
  selectedNoteForTag.value = selectedNote.value;
  if (isTagDialogOpened.value) {
    isTagDialogOpened.value.isActive = true;
  }
};

const toggleTagToNote = async (tag) => {
  try {
    if (selectedNote.value) {
      await toggleTag(selectedNote.value, tag.id);
    }
  } catch (error) {
    console.error(error);
  }
};

const destroyNote = async () => {
  try {
    if (selectedNote.value) {
      await deleteNote(selectedNote.value.id);
      router.push({ name: 'notes' });
      showToast(`${selectedNote.value.title} note deleted successfully`, 'success');
    }
  } catch (error) {
    console.error(error);
  }
};

const isTrash = computed(() => {
  return selectedNote.value?.status === 'trashed';
});

const isEditable = computed(() => !isTrash.value && !isLocked.value);

const toggleLock = () => {
  isLocked.value = !isLocked.value;
  editorKey.value += 1; // Force re-render of the editor
};

const updateCurrentNote = debounce(async (noteTitle, noteDescription) => {
  if (selectedNote.value) {
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
  }
}, 200);

const inviteUserWithEmail = async (role, email, UserAction) => {
  try {
    if (selectedNote.value) {
      const data = { role, email, user_action: UserAction };
      await inviteUserToggle(selectedNote.value.id, data);
      if (inviteUser.value) {
        inviteUser.value.isActive = false;
      }
    }
  } catch (errorMessage) {
    showToast(errorMessage.error, 'error');
  }
};

const goBack = () => {
  router.push({ name: 'notes' });
};

const copyNoteContent = async () => {
  try {
    if (selectedNote.value) {
      // Get plain text content from the note description
      const tempDiv = document.createElement('div');
      tempDiv.innerHTML = selectedNote.value.description;
      const plainText = tempDiv.textContent || tempDiv.innerText || '';

      await navigator.clipboard.writeText(plainText);
      showToast('Note content copied to clipboard', 'success');
    }
  } catch (error) {
    console.error('Failed to copy content:', error);
    showToast('Failed to copy content', 'error');
  }
};
</script>

<style scoped>
.editor-container {
  position: relative;
}

.editor-content {
  min-height: 400px;
  background: rgb(var(--v-theme-surface));
  transition: all 0.3s ease;
  overflow-x: hidden;
  width: 100%;
  word-wrap: break-word;
  overflow-wrap: break-word;
}

.editor-content:focus-within {
  border-color: rgb(var(--v-theme-primary));
  box-shadow: 0 0 0 2px rgba(var(--v-theme-primary), 0.2);
}

/* Responsive adjustments */
@media (max-width: 768px) {
  .d-none.d-sm-inline {
    display: none !important;
  }
}

/* Smooth transitions for hover states */
.v-btn {
  transition: all 0.2s ease;
}

.v-chip {
  transition: all 0.2s ease;
}

.v-chip:hover {
  transform: translateY(-1px);
}

/* Custom scrollbar for the editor area */
.editor-content :deep(.ProseMirror) {
  overflow-x: hidden;
  word-wrap: break-word;
  overflow-wrap: break-word;
}
</style>
